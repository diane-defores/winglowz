import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../app/winflowz_app.dart';
import '../../../core/bootstrap/app_build_info.dart';
import '../../../core/bootstrap/firebase_bootstrap.dart';
import '../../../core/bootstrap/sentry_bootstrap.dart';
import '../../../core/diagnostics/app_diagnostics.dart';
import '../../../core/platform/android_keyboard_bridge.dart';
import '../../../core/platform/android_overlay_bridge.dart';
import '../../../core/platform/platform_capabilities.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/application/auth_session_provider.dart';
import '../../auth/domain/auth_session_store.dart';
import '../../clipboard/application/clipboard_store_provider.dart';
import '../../dictionary/application/dictionary_store_provider.dart';
import '../../keyboard/domain/keyboard_models.dart';
import '../../snippets/application/snippet_store_provider.dart';
import '../domain/onboarding_permission_contract.dart';
import '../domain/settings_store.dart';
import '../../voice/application/transcription_store_provider.dart';
import '../application/settings_store_provider.dart';
import '../data/secure_secret_store.dart';

final _secretStoreProvider = Provider<SecureSecretStore>(
  (ref) => SecureSecretStore(),
);
final _storageStatusProvider = FutureProvider<SecretStorageStatus>(
  (ref) => ref.watch(_secretStoreProvider).status(),
);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, this.onResumeOnboarding});

  final VoidCallback? onResumeOnboarding;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _openAiController;
  late final TextEditingController _anthropicController;
  late final ScrollController _scrollController;
  bool _loading = true;
  bool _onboardingLoading = true;
  bool _saving = false;
  static const _onboardingOverlayFallback = AndroidOverlayStatus(
    enabled: false,
    requestedEnabled: false,
    running: false,
    overlayPermissionGranted: false,
    accessibilityPermissionGranted: false,
    recordAudioGranted: false,
    deliveryMode: OverlayDeliveryMode.clipboardOnly,
    sizeScale: 1,
    opacity: 0.8,
    eventQueueSize: 0,
    serviceState: 'unknown',
  );
  AndroidOverlayStatus? _overlayStatus;
  bool _overlayBusy = false;
  AndroidKeyboardStatus? _keyboardStatus;
  bool _keyboardBusy = false;
  UserSettingsSnapshot? _onboardingSettings;
  String? _message;

  @override
  void initState() {
    super.initState();
    _openAiController = TextEditingController();
    _anthropicController = TextEditingController();
    _scrollController = ScrollController();
    _loadSecrets();
    _loadOverlayState();
    _loadKeyboardState();
    _loadOnboardingSettings();
  }

  @override
  void dispose() {
    _openAiController.dispose();
    _anthropicController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSecrets() async {
    final store = ref.read(_secretStoreProvider);
    final openAiKey = await store.readOpenAiKey() ?? '';
    final anthropicKey = await store.readAnthropicKey() ?? '';
    if (!mounted) {
      return;
    }
    setState(() {
      _openAiController.text = openAiKey;
      _anthropicController.text = anthropicKey;
      _loading = false;
    });
  }

  Future<void> _loadOnboardingSettings() async {
    final store = ref.read(settingsStoreProvider);
    try {
      final settings = await store.load();
      if (!mounted) {
        return;
      }
      setState(() {
        _onboardingSettings = settings;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _message = 'Impossible de charger la progression onboarding: $error');
    } finally {
      if (!mounted) {
        return;
      }
      setState(() => _onboardingLoading = false);
    }
  }

  OnboardingReadiness _onboardingReadiness() {
    final settings = _onboardingSettings ?? const UserSettingsSnapshot.defaults();
    return evaluateOnboardingReadiness(
      isPlatformSupported: PlatformCapabilities.isAndroid &&
          PlatformCapabilities.overlaySupported,
      overlayStatus: _overlayStatus ?? _onboardingOverlayFallback,
      keyboardStatus: _keyboardStatus ?? AndroidKeyboardStatus.unsupported(),
      persistedStep: settings.onboardingCurrentStep,
      onboardingCompleted: settings.onboardingCompleted,
      accessibilitySkipped: settings.onboardingAccessibilitySkipped,
      microphoneSkipped: settings.onboardingMicrophoneSkipped,
    );
  }

  Future<void> _saveSecrets() async {
    final store = ref.read(_secretStoreProvider);
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      await store.writeOpenAiKey(_openAiController.text);
      await store.writeAnthropicKey(_anthropicController.text);
      setState(() => _message = 'Keys saved locally.');
    } catch (error) {
      setState(() => _message = 'Unable to save keys: $error');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _loadOverlayState() async {
    if (!PlatformCapabilities.overlaySupported) {
      return;
    }
    AppDiagnostics.record('overlay_status_load', 'start');
    setState(() => _overlayBusy = true);
    try {
      final status = await AndroidOverlayBridge.getStatus();
      if (!mounted) {
        return;
      }
      setState(() {
        _overlayStatus = status;
      });
      AppDiagnostics.record(
        'overlay_status_load',
        _overlayStatusSummary(status),
      );
    } on AndroidOverlayBridgeException catch (error) {
      AppDiagnostics.record(
        'overlay_status_error',
        '${error.code}: ${error.message}',
      );
      if (!mounted) {
        return;
      }
      setState(
        () =>
            _message = 'Overlay status error (${error.code}): ${error.message}',
      );
    } finally {
      if (mounted) {
        setState(() => _overlayBusy = false);
      }
      _loadOnboardingSettings();
    }
  }

  Future<void> _loadKeyboardState() async {
    if (!PlatformCapabilities.keyboardImeSupported) {
      return;
    }
    setState(() => _keyboardBusy = true);
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
    } finally {
      if (mounted) {
        setState(() => _keyboardBusy = false);
      }
      _loadOnboardingSettings();
    }
  }

  Future<void> _openKeyboardSettings() async {
    try {
      await AndroidKeyboardBridge.openInputMethodSettings();
      await _loadKeyboardState();
      await _loadOnboardingSettings();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _message = 'Unable to open keyboard settings: $error');
    }
  }

  Future<void> _showKeyboardPicker() async {
    try {
      await AndroidKeyboardBridge.showInputMethodPicker();
      await _loadKeyboardState();
      await _loadOnboardingSettings();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _message = 'Unable to show keyboard picker: $error');
    }
  }

  Future<void> _setKeyboardPreferences({
    bool? voiceEnabled,
    bool? clipboardSyncDesired,
    bool? mediaControlsEnabled,
    KeyboardLayoutProfile? layoutProfile,
    bool? cornerModeEnabled,
    bool? debugTouchOverlayEnabled,
    bool? doubleSpacePeriodEnabled,
    bool? punctuationAutoSpacingEnabled,
    KeyboardPrivacyMode? privacyMode,
  }) async {
    final current = _keyboardStatus ?? AndroidKeyboardStatus.unsupported();
    setState(() => _keyboardBusy = true);
    try {
      final status = await AndroidKeyboardBridge.setPreferences(
        voiceEnabled: voiceEnabled ?? current.voiceEnabled,
        clipboardSyncDesired:
            clipboardSyncDesired ?? current.clipboardSyncDesired,
        mediaControlsEnabled:
            mediaControlsEnabled ?? current.mediaControlsEnabled,
        layoutProfile: layoutProfile ?? current.layoutProfile,
        cornerModeEnabled: cornerModeEnabled ?? current.cornerModeEnabled,
        debugTouchOverlayEnabled:
            debugTouchOverlayEnabled ?? current.debugTouchOverlayEnabled,
        doubleSpacePeriodEnabled:
            doubleSpacePeriodEnabled ?? current.doubleSpacePeriodEnabled,
        punctuationAutoSpacingEnabled:
            punctuationAutoSpacingEnabled ??
            current.punctuationAutoSpacingEnabled,
        privacyMode: privacyMode ?? current.privacyMode,
      );
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
            'Unable to update keyboard settings (${error.code}): ${error.message}',
      );
    } finally {
      if (mounted) {
        setState(() => _keyboardBusy = false);
      }
    }
  }

  Future<void> _openOverlaySettings() async {
    try {
      AppDiagnostics.record('overlay_permission_settings', 'open');
      await AndroidOverlayBridge.openPermissionSettings();
      await _loadOverlayState();
      await _loadOnboardingSettings();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _message = 'Unable to open overlay settings: $error');
    }
  }

  Future<void> _toggleOverlay(bool value) async {
    AppDiagnostics.record('overlay_toggle', 'requested=$value');
    setState(() => _overlayBusy = true);
    try {
      final status = await AndroidOverlayBridge.setOverlayEnabled(value);
      if (!mounted) {
        return;
      }
      setState(() {
        _overlayStatus = status;
      });
      AppDiagnostics.record(
        'overlay_toggle_result',
        _overlayStatusSummary(status),
      );
    } on AndroidOverlayBridgeException catch (error) {
      AppDiagnostics.record(
        'overlay_toggle_error',
        '${error.code}: ${error.message}',
      );
      if (!mounted) {
        return;
      }
      setState(
        () => _message =
            'Unable to toggle overlay (${error.code}): ${error.message}',
      );
    } finally {
      if (mounted) {
        setState(() => _overlayBusy = false);
      }
    }
  }

  Future<void> _setOverlayAppearance({
    required double sizeScale,
    required double opacity,
  }) async {
    AppDiagnostics.record(
      'overlay_appearance',
      'size=$sizeScale; opacity=$opacity',
    );
    setState(() => _overlayBusy = true);
    try {
      final status = await AndroidOverlayBridge.setAppearance(
        sizeScale: sizeScale,
        opacity: opacity,
      );
      if (!mounted) {
        return;
      }
      setState(() => _overlayStatus = status);
      AppDiagnostics.record(
        'overlay_appearance_result',
        _overlayStatusSummary(status),
      );
    } on AndroidOverlayBridgeException catch (error) {
      AppDiagnostics.record(
        'overlay_appearance_error',
        '${error.code}: ${error.message}',
      );
      if (!mounted) {
        return;
      }
      setState(
        () => _message =
            'Unable to update overlay appearance (${error.code}): ${error.message}',
      );
    } finally {
      if (mounted) {
        setState(() => _overlayBusy = false);
      }
    }
  }

  Future<void> _startOverlay() async {
    AppDiagnostics.record('overlay_start', 'requested');
    setState(() => _overlayBusy = true);
    try {
      final status = await AndroidOverlayBridge.startRecording();
      if (!mounted) {
        return;
      }
      setState(() {
        _overlayStatus = status;
        _message = 'Overlay recording started.';
      });
      AppDiagnostics.record(
        'overlay_start_result',
        _overlayStatusSummary(status),
      );
    } on AndroidOverlayBridgeException catch (error) {
      AppDiagnostics.record(
        'overlay_start_error',
        '${error.code}: ${error.message}',
      );
      if (!mounted) {
        return;
      }
      setState(
        () => _message =
            'Unable to start overlay (${error.code}): ${error.message}',
      );
    } finally {
      if (mounted) {
        setState(() => _overlayBusy = false);
      }
    }
  }

  Future<void> _stopOverlay() async {
    AppDiagnostics.record('overlay_stop', 'requested');
    setState(() => _overlayBusy = true);
    try {
      final status = await AndroidOverlayBridge.stopRecording();
      if (!mounted) {
        return;
      }
      setState(() {
        _overlayStatus = status;
        _message = 'Overlay recording stopped.';
      });
      AppDiagnostics.record(
        'overlay_stop_result',
        _overlayStatusSummary(status),
      );
    } on AndroidOverlayBridgeException catch (error) {
      AppDiagnostics.record(
        'overlay_stop_error',
        '${error.code}: ${error.message}',
      );
      if (!mounted) {
        return;
      }
      setState(
        () => _message =
            'Unable to stop overlay (${error.code}): ${error.message}',
      );
    } finally {
      if (mounted) {
        setState(() => _overlayBusy = false);
      }
    }
  }

  Future<void> _cancelOverlay() async {
    AppDiagnostics.record('overlay_cancel', 'requested');
    setState(() => _overlayBusy = true);
    try {
      final status = await AndroidOverlayBridge.cancelRecording();
      if (!mounted) {
        return;
      }
      setState(() {
        _overlayStatus = status;
        _message = 'Overlay recording canceled.';
      });
      AppDiagnostics.record(
        'overlay_cancel_result',
        _overlayStatusSummary(status),
      );
    } on AndroidOverlayBridgeException catch (error) {
      AppDiagnostics.record(
        'overlay_cancel_error',
        '${error.code}: ${error.message}',
      );
      if (!mounted) {
        return;
      }
      setState(
        () => _message =
            'Unable to cancel overlay (${error.code}): ${error.message}',
      );
    } finally {
      if (mounted) {
        setState(() => _overlayBusy = false);
      }
    }
  }

  Future<void> _openAccessibilitySettings() async {
    try {
      AppDiagnostics.record('overlay_accessibility_settings', 'open');
      await AndroidOverlayBridge.openAccessibilitySettings();
      await _loadOverlayState();
      await _loadOnboardingSettings();
    } on AndroidOverlayBridgeException catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () => _message =
            'Unable to open accessibility settings (${error.code}): ${error.message}',
      );
    }
  }

  Future<void> _signOut() async {
    await ref.read(authSessionStoreProvider).signOut();
  }

  Future<void> _copyBackendDiagnostic() async {
    await Clipboard.setData(ClipboardData(text: _backendDiagnosticText()));
    if (!mounted) {
      return;
    }
    setState(() => _message = 'Backend diagnostic copied.');
  }

  String _backendDiagnosticText() {
    final authAsync = ref.read(authSessionProvider);
    final storageStatus = ref.read(_storageStatusProvider);
    final status = FirebaseBootstrap.isConfigured
        ? 'firebase_remote'
        : 'local_mode';
    final lines = <String>[
      'WinFlowzApp backend diagnostic',
      'diagnostic_version: 5',
      'generated_at_utc: ${DateTime.now().toUtc().toIso8601String()}',
      'secret_values_redacted: true',
      'provider_contract: backend-agnostic',
      'status: $status',
      'build: ${AppBuildInfo.diagnosticSummary}',
      'platform_capabilities: ${_platformDiagnostic()}',
      'firebase_initialized: ${FirebaseBootstrap.isInitialized}',
      'firebase_configured: ${FirebaseBootstrap.isConfigured}',
      'firebase_detail: ${_sanitizeDiagnostic(FirebaseBootstrap.initError ?? 'configured_or_not_required')}',
      'sentry_configured: ${SentryBootstrap.isConfigured}',
      'sentry_initialized: ${SentryBootstrap.isInitialized}',
      'sentry_environment: ${SentryBootstrap.environment}',
      'sentry_release: ${SentryBootstrap.release ?? 'auto_or_unset'}',
      'sentry_dist: ${SentryBootstrap.dist ?? 'unset'}',
      'sentry_detail: ${_sanitizeDiagnostic(SentryBootstrap.initError ?? 'configured_or_not_required')}',
      'auth_store: ${ref.read(authSessionStoreProvider).runtimeType}',
      'auth_session: ${_authDiagnostic(authAsync)}',
      'settings_store: ${ref.read(settingsStoreProvider).runtimeType}',
      'transcription_store: ${ref.read(transcriptionStoreProvider).runtimeType}',
      'clipboard_store: ${ref.read(clipboardStoreProvider).runtimeType}',
      'snippet_store: ${ref.read(snippetStoreProvider).runtimeType}',
      'dictionary_store: ${ref.read(dictionaryStoreProvider).runtimeType}',
      'secure_storage: ${_storageDiagnostic(storageStatus)}',
      'openai_key_present: ${_openAiController.text.trim().isNotEmpty}',
      'anthropic_key_present: ${_anthropicController.text.trim().isNotEmpty}',
      'overlay_status: ${_overlayDiagnostic()}',
      'keyboard_status: ${_keyboardDiagnostic()}',
      'recent_events: ${_recentEventsDiagnostic()}',
      'settings_message: ${_sanitizeDiagnostic(_message ?? 'none')}',
    ];
    return lines.join('\n');
  }

  String _authDiagnostic(AsyncValue<AuthSessionSnapshot> authAsync) {
    return authAsync.when(
      data: (session) {
        final user = session.user;
        return [
          'state=data',
          'signed_in=${session.isSignedIn}',
          'local_fallback=${session.isLocalFallback}',
          'provider=${user?.provider.name ?? 'none'}',
          'anonymous=${user?.isAnonymous ?? false}',
          'email_present=${user?.email?.isNotEmpty ?? false}',
          'user_id_present=${user?.id.isNotEmpty ?? false}',
          'sync_health=${session.syncStatus.health.name}',
          'sync_issue=${session.syncStatus.issue?.code ?? 'none'}',
        ].join('; ');
      },
      loading: () => 'state=loading',
      error: (error, _) => 'state=error; error=${_sanitizeDiagnostic(error)}',
    );
  }

  String _storageDiagnostic(AsyncValue<SecretStorageStatus> status) {
    return status.when(
      data: (value) => value.name,
      loading: () => 'loading',
      error: (error, _) => 'error=${_sanitizeDiagnostic(error)}',
    );
  }

  String _platformDiagnostic() {
    return [
      'android=${PlatformCapabilities.isAndroid}',
      'linux=${PlatformCapabilities.isLinux}',
      'web=${PlatformCapabilities.isWeb}',
      'local_speech=${PlatformCapabilities.localSpeechSupported}',
      'overlay=${PlatformCapabilities.overlaySupported}',
      'keyboard_ime=${PlatformCapabilities.keyboardImeSupported}',
      'secure_storage_degraded=${PlatformCapabilities.secureStorageDegraded}',
    ].join('; ');
  }

  String _overlayDiagnostic() {
    if (!PlatformCapabilities.overlaySupported) {
      return 'unsupported';
    }
    final status = _overlayStatus;
    if (status == null) {
      return 'not_loaded; busy=$_overlayBusy';
    }
    return [
      'enabled=${status.enabled}',
      'requested=${status.requestedEnabled}',
      'running=${status.running}',
      'overlay_permission=${status.overlayPermissionGranted}',
      'accessibility_permission=${status.accessibilityPermissionGranted}',
      'delivery=${status.deliveryMode.name}',
      'size=${status.sizeScale}',
      'opacity=${status.opacity}',
      'service_state=${status.serviceState}',
      'event_queue_size=${status.eventQueueSize}',
      'last_native_event=${_sanitizeDiagnostic(status.lastNativeEvent ?? 'none')}',
      'busy=$_overlayBusy',
    ].join('; ');
  }

  String _overlayStatusSummary(AndroidOverlayStatus status) {
    return [
      'enabled=${status.enabled}',
      'requested=${status.requestedEnabled}',
      'running=${status.running}',
      'overlay_permission=${status.overlayPermissionGranted}',
      'accessibility_permission=${status.accessibilityPermissionGranted}',
      'service_state=${status.serviceState}',
      'event_queue_size=${status.eventQueueSize}',
      'last_native_event=${_sanitizeDiagnostic(status.lastNativeEvent ?? 'none')}',
    ].join('; ');
  }

  String _keyboardDiagnostic() {
    if (!PlatformCapabilities.keyboardImeSupported) {
      return 'unsupported';
    }
    final status = _keyboardStatus;
    if (status == null) {
      return 'not_loaded; busy=$_keyboardBusy';
    }
    return [
      'supported=${status.supported}',
      'enabled=${status.enabled}',
      'active=${status.active}',
      'voice_enabled=${status.voiceEnabled}',
      'clipboard_sync_desired=${status.clipboardSyncDesired}',
      'media_controls=${status.mediaControlsEnabled}',
      'layout=${status.layoutProfile.name}',
      'corner_mode=${status.cornerModeEnabled}',
      'debug_touch=${status.debugTouchOverlayEnabled}',
      'double_space=${status.doubleSpacePeriodEnabled}',
      'punct_spacing=${status.punctuationAutoSpacingEnabled}',
      'privacy_mode=${status.privacyMode.name}',
      'busy=$_keyboardBusy',
    ].join('; ');
  }

  String _sanitizeDiagnostic(Object? value) {
    var text = value?.toString() ?? 'none';
    final redactionPatterns = [
      RegExp(r'AIza[0-9A-Za-z_-]{20,}'),
      RegExp(r'sb_[0-9A-Za-z_-]{12,}'),
      RegExp(r'eyJ[0-9A-Za-z_.-]{20,}'),
      RegExp(r'sk-[0-9A-Za-z_-]{12,}'),
      RegExp(
        r'(api[_-]?key|anon[_-]?key|publishable[_-]?key|token|secret|password)\s*[:=]\s*[^,\s;]+',
        caseSensitive: false,
      ),
    ];
    for (final pattern in redactionPatterns) {
      text = text.replaceAll(pattern, '<redacted>');
    }
    return text.replaceAll('\n', ' | ');
  }

  String _recentEventsDiagnostic() {
    final events = AppDiagnostics.recentEvents;
    if (events.isEmpty) {
      return 'none';
    }
    return events.map((event) => _sanitizeDiagnostic(event)).join(' || ');
  }

  Widget _settingsList({required List<Widget> children}) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ListView(
        controller: _scrollController,
        padding: AppInsets.screen,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppDiagnostics.record('screen_build', 'Settings');
    final storageStatusAsync = ref.watch(_storageStatusProvider);
    final onboardingReadiness = _onboardingReadiness();
    if (_loading || _onboardingLoading) {
      return _settingsList(
        children: [
          if (widget.onResumeOnboarding != null)
            _OnboardingSettingsTile(
              onResume: widget.onResumeOnboarding!,
              readiness: onboardingReadiness,
            ),
          if (widget.onResumeOnboarding != null) AppGaps.x2,
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    final overlayStatus = _overlayStatus;
    final keyboardStatus = _keyboardStatus;
    final themeMode = ref.watch(appThemeModeProvider);
    return _settingsList(
      children: [
        if (widget.onResumeOnboarding != null)
          _OnboardingSettingsTile(
            onResume: widget.onResumeOnboarding!,
            readiness: onboardingReadiness,
          ),
        if (widget.onResumeOnboarding != null) AppGaps.x2,
        Card(
          child: Padding(
            padding: AppInsets.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                AppGaps.x2,
                Text(
                  'Uses the WinFlowzApp palette and shared Flowz interface tokens.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                AppGaps.x3,
                SegmentedButton<AppThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: AppThemeMode.system,
                      icon: Icon(Icons.brightness_auto_outlined),
                      label: Text('System'),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selection) {
                    ref
                        .read(appThemeModeProvider.notifier)
                        .setMode(selection.single);
                  },
                ),
              ],
            ),
          ),
        ),
        AppGaps.x4,
        Card(
          child: Padding(
            padding: AppInsets.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: AppInsets.none,
                  leading: const Icon(Icons.storage_outlined),
                  title: const Text('Backend provider'),
                  subtitle: Text(
                    FirebaseBootstrap.isConfigured
                        ? 'Firebase is the active backend adapter. Legacy Supabase may remain unconfigured.'
                        : 'Remote sync is not configured. WinFlowzApp stays in local mode.',
                  ),
                ),
                SelectableText(_backendDiagnosticText()),
                AppGaps.x3,
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _copyBackendDiagnostic,
                    icon: const Icon(Icons.copy_outlined),
                    label: const Text('Copy diagnostic'),
                  ),
                ),
              ],
            ),
          ),
        ),
        AppGaps.x4,
        storageStatusAsync.when(
          data: (status) {
            if (status == SecretStorageStatus.available) {
              return const ListTile(
                leading: Icon(Icons.verified_user_outlined),
                title: Text('Local secure storage available'),
              );
            }
            return const ListTile(
              leading: Icon(Icons.warning_amber_outlined),
              title: Text('Secure storage degraded'),
              subtitle: Text(
                'Web/Linux may not provide equivalent keystore/keychain guarantees. '
                'Treat cloud AI mode as degraded until explicitly accepted.',
              ),
            );
          },
          loading: () =>
              const ListTile(title: Text('Checking storage capabilities...')),
          error: (error, stack) =>
              ListTile(title: Text('Storage status error: $error')),
        ),
        AppGaps.x4,
        TextField(
          controller: _openAiController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'OpenAI API key'),
        ),
        AppGaps.x3,
        TextField(
          controller: _anthropicController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Anthropic API key'),
        ),
        AppGaps.x4,
        if (_message != null) Text(_message!),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: _saving ? null : _saveSecrets,
                child: const Text('Save local keys'),
              ),
            ),
            AppGaps.horizontalX3,
            Expanded(
              child: OutlinedButton(
                onPressed: _saving ? null : _signOut,
                child: const Text('Sign out'),
              ),
            ),
          ],
        ),
        AppGaps.x4,
        const Divider(),
        ListTile(
          leading: const Icon(Icons.mic_none),
          title: Text(
            PlatformCapabilities.localSpeechSupported
                ? 'Local speech available'
                : 'Local speech unavailable',
          ),
          subtitle: const Text(
            'Linux falls back to advanced recording + Whisper.',
          ),
        ),
        ListTile(
          leading: const Icon(Icons.bubble_chart_outlined),
          title: Text(
            PlatformCapabilities.overlaySupported
                ? 'Android overlay supported'
                : 'Android overlay unavailable on this platform',
          ),
        ),
        ListTile(
          leading: const Icon(Icons.keyboard_outlined),
          title: Text(
            PlatformCapabilities.keyboardImeSupported
                ? 'Android keyboard IME supported'
                : 'Android keyboard IME unavailable on this platform',
          ),
          subtitle: const Text(
            'WinFlowzApp Keyboard is Android-only and runs as a native input method.',
          ),
        ),
        if (PlatformCapabilities.keyboardImeSupported)
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('WinFlowzApp Keyboard status'),
                  subtitle: Text(
                    'enabled=${keyboardStatus?.enabled ?? false} | '
                    'active=${keyboardStatus?.active ?? false} | '
                    'layout=${keyboardStatus?.layoutProfile.name ?? 'qwerty'} | '
                    'corners=${keyboardStatus?.cornerModeEnabled ?? false} | '
                    'privacy=${keyboardStatus?.privacyMode.name ?? 'auto'}',
                  ),
                  trailing: _keyboardBusy
                      ? const SizedBox.square(
                          dimension: AppIconMetrics.sm,
                          child: CircularProgressIndicator(
                            strokeWidth: AppIconMetrics.progressStroke,
                          ),
                        )
                      : IconButton(
                          tooltip: 'Refresh keyboard status',
                          onPressed: _loadKeyboardState,
                          icon: const Icon(Icons.refresh),
                        ),
                ),
                if (keyboardStatus?.enabled == false)
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Keyboard not enabled'),
                    subtitle: Text(
                      'Enable WinFlowzApp in Android input method settings, then switch to it from any text field.',
                    ),
                  ),
                Padding(
                  padding: AppInsets.keyboardControls,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _keyboardBusy
                              ? null
                              : _openKeyboardSettings,
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Input settings'),
                        ),
                      ),
                      AppGaps.horizontalX2,
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _keyboardBusy ? null : _showKeyboardPicker,
                          icon: const Icon(Icons.keyboard),
                          label: const Text('Switch keyboard'),
                        ),
                      ),
                    ],
                  ),
                ),
                SwitchListTile(
                  value: keyboardStatus?.voiceEnabled ?? true,
                  onChanged: _keyboardBusy
                      ? null
                      : (value) => _setKeyboardPreferences(voiceEnabled: value),
                  title: const Text('Keyboard dictation'),
                  subtitle: const Text(
                    'Uses Android speech recognition from the IME when microphone permission is available.',
                  ),
                ),
                SwitchListTile(
                  value: keyboardStatus?.clipboardSyncDesired ?? false,
                  onChanged: _keyboardBusy
                      ? null
                      : (value) => _setKeyboardPreferences(
                          clipboardSyncDesired: value,
                        ),
                  title: const Text('Keyboard clipboard sync intent'),
                  subtitle: const Text(
                    'Opt-in flag for eligible keyboard clipboard items. Sensitive/private fields still disable capture.',
                  ),
                ),
                SwitchListTile(
                  value: keyboardStatus?.mediaControlsEnabled ?? true,
                  onChanged: _keyboardBusy
                      ? null
                      : (value) => _setKeyboardPreferences(
                          mediaControlsEnabled: value,
                        ),
                  title: const Text('Keyboard media play/pause'),
                  subtitle: const Text(
                    'Sends a generic Android media key without reading media metadata.',
                  ),
                ),
                Padding(
                  padding: AppInsets.keyboardPrivacy,
                  child: DropdownButtonFormField<KeyboardLayoutProfile>(
                    initialValue:
                        keyboardStatus?.layoutProfile ??
                        KeyboardLayoutProfile.qwerty,
                    decoration: const InputDecoration(
                      labelText: 'Keyboard letter layout',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: KeyboardLayoutProfile.qwerty,
                        child: Text('QWERTY'),
                      ),
                      DropdownMenuItem(
                        value: KeyboardLayoutProfile.azerty,
                        child: Text('AZERTY'),
                      ),
                    ],
                    onChanged: _keyboardBusy
                        ? null
                        : (value) => _setKeyboardPreferences(
                            layoutProfile:
                                value ?? KeyboardLayoutProfile.qwerty,
                          ),
                  ),
                ),
                SwitchListTile(
                  value: keyboardStatus?.cornerModeEnabled ?? false,
                  onChanged: _keyboardBusy
                      ? null
                      : (value) =>
                            _setKeyboardPreferences(cornerModeEnabled: value),
                  title: const Text('Swipe-corner mode'),
                  subtitle: const Text(
                    'When enabled, key swipes toward corners insert secondary characters.',
                  ),
                ),
                SwitchListTile(
                  value: keyboardStatus?.doubleSpacePeriodEnabled ?? true,
                  onChanged: _keyboardBusy
                      ? null
                      : (value) => _setKeyboardPreferences(
                          doubleSpacePeriodEnabled: value,
                        ),
                  title: const Text('Double-space to period'),
                  subtitle: const Text(
                    'Transforms double space into period-space in standard text fields.',
                  ),
                ),
                SwitchListTile(
                  value: keyboardStatus?.punctuationAutoSpacingEnabled ?? false,
                  onChanged: _keyboardBusy
                      ? null
                      : (value) => _setKeyboardPreferences(
                          punctuationAutoSpacingEnabled: value,
                        ),
                  title: const Text('Punctuation auto-spacing'),
                  subtitle: const Text(
                    'Adds basic spacing around punctuation for standard text fields.',
                  ),
                ),
                SwitchListTile(
                  value: keyboardStatus?.debugTouchOverlayEnabled ?? false,
                  onChanged: _keyboardBusy
                      ? null
                      : (value) => _setKeyboardPreferences(
                          debugTouchOverlayEnabled: value,
                        ),
                  title: const Text('Keyboard touch debug overlay'),
                  subtitle: const Text(
                    'Shows key bounds and gesture classifier diagnostics on the native keyboard.',
                  ),
                ),
                Padding(
                  padding: AppInsets.keyboardPrivacy,
                  child: DropdownButtonFormField<KeyboardPrivacyMode>(
                    initialValue:
                        keyboardStatus?.privacyMode ?? KeyboardPrivacyMode.auto,
                    decoration: const InputDecoration(
                      labelText: 'Keyboard privacy mode',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: KeyboardPrivacyMode.auto,
                        child: Text('Auto: detect sensitive fields'),
                      ),
                      DropdownMenuItem(
                        value: KeyboardPrivacyMode.strict,
                        child: Text('Strict: private mode everywhere'),
                      ),
                      DropdownMenuItem(
                        value: KeyboardPrivacyMode.standard,
                        child: Text('Standard: normal fields only'),
                      ),
                    ],
                    onChanged: _keyboardBusy
                        ? null
                        : (value) => _setKeyboardPreferences(
                            privacyMode: value ?? KeyboardPrivacyMode.auto,
                          ),
                  ),
                ),
              ],
            ),
          ),
        if (PlatformCapabilities.overlaySupported)
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: overlayStatus?.enabled ?? false,
                  onChanged:
                      (overlayStatus?.overlayPermissionGranted ?? false) &&
                          !_overlayBusy
                      ? _toggleOverlay
                      : null,
                  title: const Text('Enable Android overlay bridge'),
                  subtitle: Text(
                    (overlayStatus?.enabled ?? false)
                        ? 'Overlay bridge enabled. The floating Android bubble should be visible.'
                        : (overlayStatus?.overlayPermissionGranted ?? false)
                        ? 'Overlay permission granted. Turn this on to show the floating bubble.'
                        : 'Overlay permission required before enabling.',
                  ),
                ),
                ListTile(
                  title: const Text('Overlay runtime status'),
                  subtitle: Text(
                    'enabled=${overlayStatus?.enabled ?? false} | '
                    'requested=${overlayStatus?.requestedEnabled ?? false} | '
                    'running=${overlayStatus?.running ?? false} | '
                    'service=${overlayStatus?.serviceState ?? 'unknown'} | '
                    'delivery=${overlayStatus?.deliveryMode.name ?? 'clipboardOnly'}',
                  ),
                ),
                if ((overlayStatus?.lastNativeEvent ?? 'none') != 'none')
                  ListTile(
                    title: const Text('Last native overlay event'),
                    subtitle: Text(overlayStatus?.lastNativeEvent ?? 'none'),
                  ),
                if (overlayStatus?.accessibilityPermissionGranted == false)
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Accessibility disabled'),
                    subtitle: Text(
                      'Overlay dictation will deliver clipboard only until accessibility service is enabled.',
                    ),
                  ),
                Padding(
                  padding: AppInsets.keyboardPrivacy,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(child: Text('Bubble size')),
                          Text(
                            '${((overlayStatus?.sizeScale ?? 1) * 100).round()}%',
                          ),
                        ],
                      ),
                      Slider(
                        value:
                            overlayStatus?.sizeScale ??
                            AppSliders.overlayDefaultSize,
                        min: AppSliders.overlayBubbleSizeMin,
                        max: AppSliders.overlayBubbleSizeMax,
                        divisions: AppSliders.overlaySizeDivisions,
                        onChanged: _overlayBusy
                            ? null
                            : (value) => _setOverlayAppearance(
                                sizeScale: value,
                                opacity:
                                    overlayStatus?.opacity ??
                                    AppSliders.overlayDefaultOpacity,
                              ),
                      ),
                      Row(
                        children: [
                          const Expanded(child: Text('Bubble opacity')),
                          Text(
                            '${((overlayStatus?.opacity ?? AppSliders.overlayDefaultOpacity) * 100).round()}%',
                          ),
                        ],
                      ),
                      Slider(
                        value:
                            overlayStatus?.opacity ??
                            AppSliders.overlayDefaultOpacity,
                        min: AppSliders.overlayBubbleOpacityMin,
                        max: AppSliders.overlayBubbleOpacityMax,
                        divisions: AppSliders.overlayOpacityDivisions,
                        onChanged: _overlayBusy
                            ? null
                            : (value) => _setOverlayAppearance(
                                sizeScale:
                                    overlayStatus?.sizeScale ??
                                    AppSliders.overlayDefaultSize,
                                opacity: value,
                              ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: AppInsets.keyboardPrivacy,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openOverlaySettings,
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Overlay permission'),
                        ),
                      ),
                      AppGaps.horizontalX2,
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openAccessibilitySettings,
                          icon: const Icon(Icons.accessibility_new),
                          label: const Text('Accessibility settings'),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: AppInsets.overlayControls,
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _overlayBusy ? null : _startOverlay,
                          child: const Text('Start'),
                        ),
                      ),
                      AppGaps.horizontalX2,
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _overlayBusy ? null : _stopOverlay,
                          child: const Text('Stop'),
                        ),
                      ),
                      AppGaps.horizontalX2,
                      Expanded(
                        child: TextButton(
                          onPressed: _overlayBusy ? null : _cancelOverlay,
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _OnboardingSettingsTile extends StatelessWidget {
  const _OnboardingSettingsTile({
    required this.onResume,
    required this.readiness,
  });

  final VoidCallback onResume;
  final OnboardingReadiness readiness;

  @override
  Widget build(BuildContext context) {
    final mandatory = readiness.steps
        .where((step) => step.definition.category == OnboardingStepCategory.mandatory)
        .toList(growable: false);
    final recommended = readiness.steps
        .where((step) => step.definition.category == OnboardingStepCategory.recommended)
        .toList(growable: false);
    final mandatoryDone = mandatory.where((step) => step.completed).length;
    final recommendedDone = recommended.where((step) => step.completed).length;
    final actionLabel = readiness.shouldShowOnboarding
        ? 'Reprendre'
        : readiness.onboardingCompleted
            ? 'Voir le récapitulatif'
            : 'Reprendre';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.flag_outlined),
        title: const Text('Onboarding permissions'),
        subtitle: readiness.platformSupported
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    readiness.shouldShowOnboarding
                        ? 'Étapes complétées: ${mandatoryDone}/${mandatory.length} obligatoires, ${recommendedDone}/${recommended.length} recommandées'
                        : 'Onboarding terminé',
                  ),
                  if (recommended.isNotEmpty)
                    Text(
                      'Conseils restants: '
                      '${recommended.where((step) => !step.completed).length}',
                    ),
                ],
              )
            : const Text('Non requis sur cette plateforme'),
        trailing: TextButton(
          onPressed: onResume,
          child: Text(actionLabel),
        ),
      ),
    );
  }
}
