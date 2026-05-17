import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/diagnostics/app_diagnostics.dart';
import '../../../core/platform/android_keyboard_bridge.dart';
import '../../../core/platform/android_overlay_bridge.dart';
import '../../../core/platform/platform_capabilities.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_components.dart';
import '../../../core/widgets/confirm_action_dialog.dart';
import '../../../core/widgets/local_mode_notice.dart';
import '../../keyboard/domain/keyboard_models.dart';
import '../../settings/application/settings_store_provider.dart';
import '../application/language_pack_catalog_provider.dart';
import '../application/transcription_store.dart';
import '../application/transcription_store_provider.dart';
import '../domain/language_pack_catalog.dart';
import '../domain/transcription_draft.dart';

class VoiceScreen extends ConsumerStatefulWidget {
  const VoiceScreen({super.key});

  @override
  ConsumerState<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends ConsumerState<VoiceScreen> {
  bool _busy = false;
  bool _overlayBusy = false;
  AndroidOverlayStatus? _overlayStatus;
  AndroidKeyboardStatus? _keyboardStatus;
  String? _message;
  List<TranscriptionRecord> _items = const [];

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
    Future<void>.microtask(_loadOverlayStatus);
    Future<void>.microtask(_loadKeyboardStatus);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _busy = true);
    try {
      await _syncKeyboardVoiceRuntimeEvents();
      final store = ref.read(transcriptionStoreProvider);
      await _importKeyboardVoiceEvents(store);
      final rows = await store.list();
      AppDiagnostics.record(
        'voice_load',
        'store=${store.runtimeType}; items=${rows.length}',
      );
      if (mounted) {
        setState(() {
          _items = rows;
          _message = null;
        });
      }
    } catch (error) {
      AppDiagnostics.record('voice_load_error', error);
      if (mounted) {
        setState(() => _message = 'Erreur chargement transcriptions: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _syncKeyboardVoiceRuntimeEvents() async {
    if (!PlatformCapabilities.keyboardImeSupported) {
      return;
    }
    final events =
        await AndroidKeyboardBridge.drainKeyboardVoiceRuntimeEvents();
    if (events.isEmpty) {
      return;
    }
    final notifier = ref.read(languagePackCatalogProvider.notifier);
    for (final event in events) {
      notifier.applyNativeRuntimeStatus(
        runtimeState: event.runtimeState,
        fallbackReason: event.fallbackReason,
        activePackId: event.activePackId,
        lastErrorCode: event.lastErrorCode,
        languageTag: event.languageTag,
        engine: event.engine,
        observedAtUtc: event.capturedAtUtc,
      );
    }
    await _loadKeyboardStatus();
    AppDiagnostics.record(
      'voice_runtime_events_import',
      'events=${events.length}',
    );
  }

  Future<void> _importKeyboardVoiceEvents(TranscriptionStore store) async {
    if (!PlatformCapabilities.keyboardImeSupported) {
      return;
    }
    final events = await AndroidKeyboardBridge.drainKeyboardVoiceEvents();
    for (final event in events) {
      final draft = TranscriptionDraft(
        rawText: event.rawText,
        cleanedText: event.cleanedText,
        language: event.language,
        source: event.source,
        durationMs: event.durationMs,
      );
      if (draft.isValid) {
        await store.insert(draft);
      }
    }
    if (events.isNotEmpty) {
      AppDiagnostics.record('voice_keyboard_import', 'events=${events.length}');
    }
  }

  Future<void> _loadOverlayStatus() async {
    if (!PlatformCapabilities.overlaySupported) {
      return;
    }
    try {
      final status = await AndroidOverlayBridge.getStatus();
      if (!mounted) {
        return;
      }
      setState(() => _overlayStatus = status);
    } on AndroidOverlayBridgeException catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () =>
            _message = 'Overlay status error (${error.code}): ${error.message}',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _message = 'Overlay status error: $error');
    }
  }

  Future<void> _loadKeyboardStatus() async {
    if (!PlatformCapabilities.keyboardImeSupported) {
      return;
    }
    try {
      final status = await AndroidKeyboardBridge.getStatus();
      if (!mounted) {
        return;
      }
      setState(() => _keyboardStatus = status);
    } on AndroidKeyboardBridgeException catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () => _message =
            'Keyboard status error (${error.code}): ${error.message}',
      );
    }
  }

  LanguagePackDeviceProfile _deviceProfile() {
    final status = _keyboardStatus ?? AndroidKeyboardStatus.unsupported();
    return LanguagePackDeviceProfile(
      androidSdk: status.deviceAndroidSdk,
      primaryAbi: status.devicePrimaryAbi,
      totalCapacityMb: status.deviceTotalCapacityMb,
      freeSpaceMb: status.deviceFreeSpaceMb,
      ramMb: status.deviceRamMb,
    );
  }

  String _activeLanguageTag() {
    final raw = _keyboardStatus?.voiceLanguageTag.trim();
    if (raw == null || raw.isEmpty || raw.toLowerCase() == 'und') {
      return 'fr-FR';
    }
    return raw;
  }

  bool _isLocalPackInstalled(
    LanguagePackCatalogState catalogState,
    LanguagePackCatalogEntry entry,
  ) {
    final installed = catalogState.installedStateFor(entry);
    return (installed.installState == InstalledLanguagePackState.installed ||
            installed.installState ==
                InstalledLanguagePackState.updateAvailable) &&
        installed.runtimeMode == LanguagePackRuntimeMode.local;
  }

  Future<void> _installRecommendedPack(
    LanguagePackCatalogEntry entry,
    LanguagePackCatalogState catalogState,
  ) async {
    final notifier = ref.read(languagePackCatalogProvider.notifier);
    final installStateBefore = catalogState
        .installedStateFor(entry)
        .installState;
    final installed =
        installStateBefore == InstalledLanguagePackState.failedDownload ||
            installStateBefore ==
                InstalledLanguagePackState.failedVerification ||
            installStateBefore ==
                InstalledLanguagePackState.blockedInsufficientStorage ||
            installStateBefore == InstalledLanguagePackState.corrupted
        ? await notifier.retryInstallWithPreflight(
            entry: entry,
            device: _deviceProfile(),
          )
        : await notifier.installPackWithPreflight(
            entry: entry,
            device: _deviceProfile(),
          );
    if (!mounted) {
      return;
    }
    setState(() {
      _message = installed
          ? 'Local pack installed for ${entry.languageTag}.'
          : 'Install failed or blocked for ${entry.languageTag}.';
    });
  }

  void _useExplicitFallback(String languageTag) {
    final notifier = ref.read(languagePackCatalogProvider.notifier);
    final applied = notifier.setExplicitFallbackForLanguage(languageTag);
    setState(() {
      _message = applied
          ? 'Explicit fallback enabled for $languageTag.'
          : 'No fallback path available for $languageTag.';
    });
  }

  Future<void> _startOverlay() async {
    setState(() => _overlayBusy = true);
    try {
      final status = await AndroidOverlayBridge.startRecording();
      if (!mounted) {
        return;
      }
      setState(() {
        _overlayStatus = status;
        _message = 'Overlay started from Voice.';
      });
      _refreshOverlayStatusSoon();
    } on AndroidOverlayBridgeException catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () =>
            _message = 'Overlay start failed (${error.code}): ${error.message}',
      );
    } finally {
      if (mounted) {
        setState(() => _overlayBusy = false);
      }
    }
  }

  Future<void> _stopOverlay() async {
    setState(() => _overlayBusy = true);
    try {
      final status = await AndroidOverlayBridge.stopRecording();
      if (!mounted) {
        return;
      }
      setState(() {
        _overlayStatus = status;
        _message = 'Overlay stopped from Voice.';
      });
      _refreshOverlayStatusSoon();
    } on AndroidOverlayBridgeException catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () =>
            _message = 'Overlay stop failed (${error.code}): ${error.message}',
      );
    } finally {
      if (mounted) {
        setState(() => _overlayBusy = false);
      }
    }
  }

  Future<void> _cancelOverlay() async {
    setState(() => _overlayBusy = true);
    try {
      final status = await AndroidOverlayBridge.cancelRecording();
      if (!mounted) {
        return;
      }
      setState(() {
        _overlayStatus = status;
        _message = 'Overlay canceled from Voice.';
      });
      _refreshOverlayStatusSoon();
    } on AndroidOverlayBridgeException catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () => _message =
            'Overlay cancel failed (${error.code}): ${error.message}',
      );
    } finally {
      if (mounted) {
        setState(() => _overlayBusy = false);
      }
    }
  }

  Future<void> _toggleOverlayRecording() async {
    if (_overlayStatus?.serviceState == 'recording') {
      await _stopOverlay();
    } else {
      await _startOverlay();
    }
  }

  void _refreshOverlayStatusSoon() {
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        _loadOverlayStatus();
      }
    });
  }

  Future<void> _delete(String id) async {
    final settings = await ref.read(settingsStoreProvider).load();
    if (!mounted) {
      return;
    }
    final confirmed = await showConfirmActionDialog(
      context: context,
      title: 'Delete transcription?',
      message:
          'This removes the transcription from the current history. This action cannot be undone from this screen.',
      confirmLabel: 'Delete',
      destructive: true,
      confirmationEnabled: settings.confirmDestructiveActions,
    );
    if (!mounted || !confirmed) {
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final store = ref.read(transcriptionStoreProvider);
      await store.softDelete(id);
      await _load();
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'Suppression impossible: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _quickEdit(TranscriptionRecord item) async {
    final controller = TextEditingController(text: item.cleanedText);
    final updated = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit cleaned text'),
          content: TextField(
            controller: controller,
            minLines: 2,
            maxLines: 6,
            decoration: const InputDecoration(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (updated == null) {
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final store = ref.read(transcriptionStoreProvider);
      await store.updateCleanedText(id: item.id, cleanedText: updated);
      await _load();
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'Mise à jour impossible: $error');
      }
    } finally {
      controller.dispose();
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppDiagnostics.record('screen_build', 'Voice');
    final catalogState = ref.watch(languagePackCatalogProvider);
    final activeLanguageTag = _activeLanguageTag();
    final recommendedEntry = catalogState.catalog.recommendedForLanguage(
      activeLanguageTag,
    );
    final shouldShowNoPackPrompt =
        recommendedEntry != null &&
        !_isLocalPackInstalled(catalogState, recommendedEntry);
    final overlayStatus = _overlayStatus;
    final overlayRecording = overlayStatus?.serviceState == 'recording';
    final latest = _items.isEmpty ? null : _items.first;
    return ListView(
      padding: AppInsets.screen,
      children: [
        const LocalModeNotice(surface: 'Voice'),
        const LocalModeNoticeGap(),
        if (shouldShowNoPackPrompt)
          _MicroWithoutPackPromptCard(
            languageTag: activeLanguageTag,
            allowCloudFallback: catalogState.allowCloudFallback,
            installedState: catalogState.installedStateFor(recommendedEntry),
            onInstall: _busy
                ? null
                : () => _installRecommendedPack(recommendedEntry, catalogState),
            onUseFallback: _busy
                ? null
                : () => _useExplicitFallback(activeLanguageTag),
          ),
        if (shouldShowNoPackPrompt) AppGaps.x2,
        AppSectionCard(
          title: 'Capture automatique',
          subtitle:
              'Les transcriptions apparaissent ici après une dictée depuis le clavier, l’overlay ou le mode vocal.',
          leading: Icon(
            Icons.auto_awesome_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: AppSpacing.x2,
              runSpacing: AppSpacing.x2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _busy ? null : _load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh history'),
                ),
                AppTag(
                  label: _items.isEmpty
                      ? 'Historique vide'
                      : '${_items.length} capture${_items.length == 1 ? '' : 's'}',
                ),
              ],
            ),
          ),
        ),
        AppGaps.x2,
        _VoiceOverviewCard(
          totalCount: _items.length,
          latest: latest,
          overlayStatus: overlayStatus,
          overlaySupported: PlatformCapabilities.overlaySupported,
        ),
        if (PlatformCapabilities.overlaySupported) AppGaps.x2,
        if (PlatformCapabilities.overlaySupported)
          _OverlayControlCard(
            status: overlayStatus,
            isRecording: overlayRecording,
            isBusy: _overlayBusy,
            onToggleRecording: _overlayBusy ? null : _toggleOverlayRecording,
            onStop: _overlayBusy ? null : _stopOverlay,
            onCancel: _overlayBusy ? null : _cancelOverlay,
            onRefresh: _overlayBusy ? null : _loadOverlayStatus,
          ),
        if (_busy)
          const Padding(
            padding: AppInsets.progress,
            child: LinearProgressIndicator(),
          ),
        if (_message != null)
          Padding(
            padding: AppInsets.message,
            child: _VoiceMessage(message: _message!),
          ),
        AppGaps.x4,
        const AppEntityListHeader(title: 'Historique vocal'),
        AppGaps.x2,
        if (_items.isEmpty) const _EmptyVoiceState(),
        for (final item in _items)
          _TranscriptionTile(
            item: item,
            onEdit: _busy ? null : () => _quickEdit(item),
            onDelete: _busy ? null : () => _delete(item.id),
          ),
      ],
    );
  }
}

class _MicroWithoutPackPromptCard extends StatelessWidget {
  const _MicroWithoutPackPromptCard({
    required this.languageTag,
    required this.allowCloudFallback,
    required this.installedState,
    required this.onInstall,
    required this.onUseFallback,
  });

  final String languageTag;
  final bool allowCloudFallback;
  final InstalledLanguagePack installedState;
  final VoidCallback? onInstall;
  final VoidCallback? onUseFallback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fallbackLabel = allowCloudFallback
        ? 'cloud_fallback (explicit)'
        : 'android_fallback / unavailable';
    return AppSectionCard(
      title: 'Keyboard mic: local pack missing',
      subtitle:
          'No local pack is installed for $languageTag. Choose install now or explicit fallback before dictation.',
      leading: Icon(
        Icons.priority_high_outlined,
        color: theme.colorScheme.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'state=${installedState.installState.wireName} | fallback=$fallbackLabel | retries_hint=3 max',
            style: theme.textTheme.bodySmall,
          ),
          AppGaps.x2,
          Wrap(
            spacing: AppSpacing.x2,
            runSpacing: AppSpacing.x2,
            children: [
              FilledButton.icon(
                onPressed: onInstall,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Install local pack'),
              ),
              OutlinedButton.icon(
                onPressed: onUseFallback,
                icon: const Icon(Icons.alt_route_outlined),
                label: const Text('Use explicit fallback'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _overlayStatusLabel(AndroidOverlayStatus? status) {
  if (status == null) {
    return 'Statut en cours';
  }
  if (status.serviceState == 'recording') {
    return 'Enregistrement';
  }
  if (status.running) {
    return 'Overlay actif';
  }
  if (status.enabled || status.requestedEnabled) {
    return 'Overlay prêt';
  }
  return 'Overlay désactivé';
}

String _overlayPermissionLabel(AndroidOverlayStatus? status) {
  if (status == null) {
    return 'Permissions inconnues';
  }
  if (!status.overlayPermissionGranted) {
    return 'Overlay à autoriser';
  }
  if (!status.recordAudioGranted) {
    return 'Micro à autoriser';
  }
  if (!status.accessibilityPermissionGranted) {
    return 'Clipboard seulement';
  }
  return 'Permissions prêtes';
}

String _overlayDeliveryLabel(AndroidOverlayStatus? status) {
  return switch (status?.deliveryMode) {
    OverlayDeliveryMode.injectionAndClipboard => 'Insertion + clipboard',
    OverlayDeliveryMode.clipboardOnly => 'Clipboard',
    null => 'Livraison inconnue',
  };
}

String _languageLabel(String value) {
  final normalized = value.trim().toLowerCase();
  return switch (normalized) {
    'fr' || 'fr-fr' => 'Français',
    'en' || 'en-us' || 'en-gb' => 'Anglais',
    '' => 'Langue inconnue',
    _ => normalized.toUpperCase(),
  };
}

String _sourceLabel(String value) {
  return switch (value.trim().toLowerCase()) {
    'keyboard' => 'Clavier',
    'overlay' => 'Overlay',
    'advanced' => 'Mode avancé',
    'free' => 'Mode libre',
    '' => 'Source inconnue',
    _ => value,
  };
}

String _formatDuration(int durationMs) {
  if (durationMs <= 0) {
    return 'Durée inconnue';
  }
  if (durationMs < 1000) {
    return '$durationMs ms';
  }
  final seconds = durationMs / 1000;
  if (seconds < 60) {
    return '${seconds.toStringAsFixed(seconds < 10 ? 1 : 0)} s';
  }
  final minutes = seconds ~/ 60;
  final remainingSeconds = (seconds % 60).round();
  return '$minutes min ${remainingSeconds.toString().padLeft(2, '0')} s';
}

String _formatShortDateTime(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month $hour:$minute';
}

class _VoiceOverviewCard extends StatelessWidget {
  const _VoiceOverviewCard({
    required this.totalCount,
    required this.latest,
    required this.overlayStatus,
    required this.overlaySupported,
  });

  final int totalCount;
  final TranscriptionRecord? latest;
  final AndroidOverlayStatus? overlayStatus;
  final bool overlaySupported;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRecording = overlayStatus?.serviceState == 'recording';
    final statusLabel = overlaySupported
        ? _overlayStatusLabel(overlayStatus)
        : 'Clavier vocal local';
    final latestLabel = latest == null
        ? 'Aucune capture'
        : _formatShortDateTime(latest!.createdAt);

    return Card(
      child: Padding(
        padding: AppInsets.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        (isRecording ? AppColors.danger : colorScheme.primary)
                            .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(
                    isRecording ? Icons.graphic_eq : Icons.mic_none,
                    color: isRecording ? AppColors.danger : colorScheme.primary,
                  ),
                ),
                AppGaps.horizontalX3,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRecording ? 'Dictée en cours' : 'Voice',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      AppGaps.x1,
                      Text(
                        'Capture, nettoie et retrouve les textes dictés depuis le clavier et l’overlay.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppGaps.x4,
            Wrap(
              spacing: AppSpacing.x2,
              runSpacing: AppSpacing.x2,
              children: [
                _MetricPill(
                  icon: Icons.history,
                  label: '$totalCount',
                  value: totalCount == 1 ? 'transcription' : 'transcriptions',
                ),
                _MetricPill(
                  icon: Icons.schedule,
                  label: latestLabel,
                  value: 'dernière capture',
                ),
                _MetricPill(
                  icon: isRecording
                      ? Icons.fiber_manual_record
                      : Icons.radio_button_unchecked,
                  label: statusLabel,
                  value: 'statut',
                  color: isRecording ? AppColors.danger : colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OverlayControlCard extends StatelessWidget {
  const _OverlayControlCard({
    required this.status,
    required this.isRecording,
    required this.isBusy,
    required this.onToggleRecording,
    required this.onStop,
    required this.onCancel,
    required this.onRefresh,
  });

  final AndroidOverlayStatus? status;
  final bool isRecording;
  final bool isBusy;
  final VoidCallback? onToggleRecording;
  final VoidCallback? onStop;
  final VoidCallback? onCancel;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      title: 'Contrôle overlay Android',
      subtitle:
          'Démarre une dictée flottante, puis récupère le texte dans l’historique vocal.',
      leading: Icon(
        isRecording ? Icons.graphic_eq : Icons.mic_external_on_outlined,
        color: isRecording ? AppColors.danger : colorScheme.primary,
      ),
      padding: AppInsets.compactCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSpacing.x2,
            runSpacing: AppSpacing.x2,
            children: [
              AppTag(
                label: _overlayStatusLabel(status),
                color: isRecording ? AppColors.danger : null,
                backgroundColor: isRecording
                    ? AppColors.danger.withValues(alpha: 0.1)
                    : null,
              ),
              AppTag(label: _overlayPermissionLabel(status)),
              AppTag(label: _overlayDeliveryLabel(status)),
              if ((status?.eventQueueSize ?? 0) > 0)
                AppTag(label: '${status!.eventQueueSize} événement(s)'),
            ],
          ),
          if (status?.accessibilityPermissionGranted == false) ...[
            AppGaps.x3,
            const _InlineNotice(
              icon: Icons.accessibility_new,
              text:
                  'Accessibilité désactivée: le texte reste copié dans le presse-papiers.',
            ),
          ],
          if (status?.recordAudioGranted == false) ...[
            AppGaps.x2,
            const _InlineNotice(
              icon: Icons.mic_off_outlined,
              text:
                  'Micro non autorisé: active la permission Android pour enregistrer.',
            ),
          ],
          AppGaps.x3,
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 520;
              final primary = _RecordingMicAction(
                isRecording: isRecording,
                isBusy: isBusy,
                onPressed: onToggleRecording,
              );
              final secondary = Wrap(
                spacing: AppSpacing.x2,
                runSpacing: AppSpacing.x2,
                children: [
                  OutlinedButton.icon(
                    onPressed: onStop,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('Stop'),
                  ),
                  TextButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                  ),
                  IconButton(
                    tooltip: 'Rafraîchir le statut overlay',
                    onPressed: onRefresh,
                    icon: const Icon(Icons.sync),
                  ),
                ],
              );

              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    primary,
                    AppGaps.x2,
                    Align(alignment: Alignment.centerLeft, child: secondary),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: primary),
                  AppGaps.horizontalX3,
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: secondary,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.primary;
    return Container(
      constraints: const BoxConstraints(minWidth: 156),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x3,
        vertical: AppSpacing.x2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: effectiveColor, size: 18),
          AppGaps.horizontalX2,
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceMessage extends StatelessWidget {
  const _VoiceMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isError =
        message.toLowerCase().contains('error') ||
        message.toLowerCase().contains('erreur') ||
        message.toLowerCase().contains('failed') ||
        message.toLowerCase().contains('impossible');
    final accent = isError ? colorScheme.error : colorScheme.primary;
    return Container(
      padding: AppInsets.compactCard,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: accent,
          ),
          AppGaps.horizontalX2,
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: AppInsets.compactCard,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary),
          AppGaps.horizontalX2,
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _EmptyVoiceState extends StatelessWidget {
  const _EmptyVoiceState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: AppInsets.card,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.mic_none, color: colorScheme.primary),
            AppGaps.horizontalX3,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No transcription yet.',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  AppGaps.x1,
                  Text(
                    'Lance une dictée depuis le clavier ou l’overlay Android. Les textes validés apparaîtront ici.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TranscriptionTile extends StatelessWidget {
  const _TranscriptionTile({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final TranscriptionRecord item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasRawDiff = item.rawText.trim() != item.cleanedText.trim();

    return Card(
      child: Padding(
        padding: AppInsets.compactCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.cleanedText,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                AppGaps.horizontalX2,
                Wrap(
                  spacing: AppIconMetrics.listActionSpacing,
                  children: [
                    IconButton(
                      tooltip: 'Edit cleaned',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ],
            ),
            AppGaps.x2,
            Wrap(
              spacing: AppSpacing.x2,
              runSpacing: AppSpacing.x1,
              children: [
                AppTag(label: _languageLabel(item.language)),
                AppTag(label: _sourceLabel(item.source)),
                AppTag(label: _formatDuration(item.durationMs)),
                AppTag(label: _formatShortDateTime(item.createdAt)),
              ],
            ),
            if (hasRawDiff) ...[
              AppGaps.x2,
              Text(
                'Brut: ${item.rawText}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecordingMicAction extends StatefulWidget {
  const _RecordingMicAction({
    required this.isRecording,
    required this.isBusy,
    required this.onPressed,
  });

  final bool isRecording;
  final bool isBusy;
  final VoidCallback? onPressed;

  @override
  State<_RecordingMicAction> createState() => _RecordingMicActionState();
}

class _RecordingMicActionState extends State<_RecordingMicAction>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant _RecordingMicAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRecording != widget.isRecording) {
      _syncAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    if (widget.isRecording) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = widget.isRecording
        ? AppColors.danger
        : colorScheme.primary;
    final foreground = widget.isRecording
        ? Colors.white
        : colorScheme.onPrimary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = widget.isRecording
            ? Curves.easeOut.transform(1 - _controller.value)
            : 0.0;
        final glowOpacity = 0.12 + (pulse * 0.22);
        final scale = widget.isRecording ? 1 + (pulse * 0.035) : 1.0;

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (widget.isRecording)
              Positioned.fill(
                child: Transform.scale(
                  scale: 1.06 + (pulse * 0.16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withValues(alpha: glowOpacity),
                          blurRadius: 22 + (pulse * 16),
                          spreadRadius: 2 + (pulse * 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Transform.scale(
              scale: scale,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: activeColor,
                  foregroundColor: foreground,
                  disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                  disabledForegroundColor: colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x4,
                    vertical: AppSpacing.x3,
                  ),
                ),
                onPressed: widget.onPressed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: widget.isBusy
                          ? SizedBox(
                              key: const ValueKey('busy'),
                              width: AppIconMetrics.sm,
                              height: AppIconMetrics.sm,
                              child: CircularProgressIndicator(
                                strokeWidth: AppIconMetrics.progressStroke,
                                color: foreground,
                              ),
                            )
                          : Icon(
                              widget.isRecording ? Icons.mic : Icons.mic_none,
                              key: ValueKey(widget.isRecording),
                            ),
                    ),
                    AppGaps.horizontalX2,
                    Flexible(
                      child: Text(
                        widget.isRecording ? 'Stop rec' : 'Start',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.isRecording) ...[
                      AppGaps.horizontalX2,
                      _RecordingBars(
                        progress: _controller.value,
                        color: foreground,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecordingBars extends StatelessWidget {
  const _RecordingBars({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(4, (index) {
          final wave = (progress + (index * 0.18)) % 1;
          final height = 6 + (Curves.easeInOut.transform(wave) * 10);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            width: 3,
            height: height,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}
