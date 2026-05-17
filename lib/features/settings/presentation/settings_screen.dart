import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../app/winflowz_app.dart';
import '../../../core/bootstrap/app_build_info.dart';
import '../../../core/bootstrap/firebase_bootstrap.dart';
import '../../../core/bootstrap/sentry_bootstrap.dart';
import '../../../core/diagnostics/app_diagnostics.dart';
import '../../../core/diagnostics/sensitive_redactor.dart';
import '../../../core/platform/android_keyboard_bridge.dart';
import '../../../core/platform/android_overlay_bridge.dart';
import '../../../core/platform/platform_capabilities.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_components.dart';
import '../../auth/application/auth_session_provider.dart';
import '../../auth/domain/auth_session_store.dart';
import '../../clipboard/application/clipboard_store_provider.dart';
import '../../dictionary/application/dictionary_store_provider.dart';
import '../../keyboard/domain/keyboard_models.dart';
import '../../keyboard/presentation/keyboard_corner_shortcuts_screen.dart';
import '../../keyboard/presentation/keyboard_theme_studio_screen.dart';
import '../../snippets/application/snippet_store_provider.dart';
import '../domain/onboarding_permission_contract.dart';
import '../domain/settings_store.dart';
import '../../voice/application/transcription_store_provider.dart';
import '../../voice/application/language_pack_catalog_provider.dart';
import '../../voice/domain/language_pack_catalog.dart';
import '../application/settings_platform_controllers.dart';
import '../application/settings_store_provider.dart';
import '../data/secure_secret_store.dart';

part 'settings_screen_sections.dart';

final _secretStoreProvider = Provider<SecureSecretStore>(
  (ref) => SecureSecretStore(),
);
final _storageStatusProvider = FutureProvider<SecretStorageStatus>(
  (ref) => ref.watch(_secretStoreProvider).status(),
);

typedef _KeyboardPreferenceChanged =
    Future<void> Function({
      bool? voiceEnabled,
      bool? clipboardSyncDesired,
      bool? mediaControlsEnabled,
      int? mediaVolumeStepPercent,
      int? mediaBrightnessStepPercent,
      KeyboardLayoutProfile? layoutProfile,
      bool? cornerModeEnabled,
      bool? debugTouchOverlayEnabled,
      bool? keyVibrationEnabled,
      bool? keySoundEnabled,
      bool? spellingSuggestionsEnabled,
      bool? specialKeyCornersEnabled,
      bool? frenchLanguageEnabled,
      bool? englishLanguageEnabled,
      bool? doubleSpacePeriodEnabled,
      bool? punctuationAutoSpacingEnabled,
      double? keyboardHeightScale,
      double? actionRowHeightScale,
      bool? compactModeEnabled,
      KeyboardPrivacyMode? privacyMode,
    });

typedef _OverlayAppearanceChanged =
    Future<void> Function({required double sizeScale, required double opacity});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({
    super.key,
    this.onResumeOnboarding,
    this.highlightOnboardingResume = false,
  });

  final VoidCallback? onResumeOnboarding;
  final bool highlightOnboardingResume;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _sectionGap = SizedBox(height: AppSpacing.x2);
  static const _sectionRunSpacing = AppSpacing.x2;
  static const _collapsibleSectionMargin = EdgeInsets.symmetric(
    vertical: AppSpacing.x1,
  );

  late final TextEditingController _openAiController;
  late final TextEditingController _anthropicController;
  late final ScrollController _scrollController;
  final _keyboardController = const SettingsKeyboardController();
  final _overlayController = const SettingsOverlayController();
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
    opacity: 0.9,
    eventQueueSize: 0,
    serviceState: 'unknown',
  );
  AndroidOverlayStatus? _overlayStatus;
  bool _overlayBusy = false;
  AndroidKeyboardStatus? _keyboardStatus;
  bool _keyboardBusy = false;
  UserSettingsSnapshot? _onboardingSettings;
  String? _message;
  final Map<String, bool> _expandedSections = {
    'appearance': true,
    'backend': false,
    'keys': true,
    'platform': false,
    'keyboard': false,
    'voice_packs': true,
    'overlay': false,
  };

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
      setState(() => _message = 'Unable to load onboarding progress: $error');
    } finally {
      if (mounted) {
        setState(() => _onboardingLoading = false);
      }
    }
  }

  Future<void> _setConfirmDestructiveActions(bool value) async {
    final store = ref.read(settingsStoreProvider);
    final current = _onboardingSettings ?? await store.load();
    final next = current.copyWith(confirmDestructiveActions: value);
    await store.save(next);
    if (!mounted) {
      return;
    }
    setState(() {
      _onboardingSettings = next;
      _message = value
          ? 'Delete confirmations enabled.'
          : 'Delete confirmations disabled.';
    });
  }

  OnboardingReadiness _onboardingReadiness() {
    final settings =
        _onboardingSettings ?? const UserSettingsSnapshot.defaults();
    return evaluateOnboardingReadiness(
      isPlatformSupported:
          PlatformCapabilities.isAndroid &&
          PlatformCapabilities.overlaySupported,
      overlayStatus: _overlayStatus ?? _onboardingOverlayFallback,
      keyboardStatus: _keyboardStatus ?? AndroidKeyboardStatus.unsupported(),
      persistedStep: settings.onboardingCurrentStep,
      onboardingCompleted: settings.onboardingCompleted,
      clipboardSkipped: settings.onboardingClipboardSkipped,
      accessibilitySkipped: settings.onboardingAccessibilitySkipped,
      microphoneSkipped: settings.onboardingMicrophoneSkipped,
      mediaAccessSkipped: settings.onboardingMediaAccessSkipped,
      brightnessSkipped: settings.onboardingBrightnessSkipped,
      overlaySkipped: settings.onboardingOverlaySkipped,
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
      final status = await _overlayController.loadStatus();
      if (!mounted) {
        return;
      }
      setState(() {
        _overlayStatus = status;
      });
      AppDiagnostics.record(
        'overlay_status_load',
        _overlayController.statusSummary(status),
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
      final status = await _keyboardController.loadStatus();
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
      await _keyboardController.openInputMethodSettings();
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
      await _keyboardController.showInputMethodPicker();
      await _loadKeyboardState();
      await _loadOnboardingSettings();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _message = 'Unable to show keyboard picker: $error');
    }
  }

  Future<void> _openCornerShortcuts() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const KeyboardCornerShortcutsScreen(),
      ),
    );
    if (mounted) {
      await _loadKeyboardState();
    }
  }

  Future<void> _openKeyboardThemeStudio() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const KeyboardThemeStudioScreen(),
      ),
    );
    if (mounted) {
      await _loadKeyboardState();
    }
  }

  Future<void> _setKeyboardPreferences({
    bool? voiceEnabled,
    bool? clipboardSyncDesired,
    bool? mediaControlsEnabled,
    int? mediaVolumeStepPercent,
    int? mediaBrightnessStepPercent,
    KeyboardLayoutProfile? layoutProfile,
    bool? cornerModeEnabled,
    bool? debugTouchOverlayEnabled,
    bool? keyVibrationEnabled,
    bool? keySoundEnabled,
    bool? spellingSuggestionsEnabled,
    bool? specialKeyCornersEnabled,
    bool? frenchLanguageEnabled,
    bool? englishLanguageEnabled,
    bool? doubleSpacePeriodEnabled,
    bool? punctuationAutoSpacingEnabled,
    double? keyboardHeightScale,
    double? actionRowHeightScale,
    bool? compactModeEnabled,
    KeyboardPrivacyMode? privacyMode,
  }) async {
    final current = _keyboardStatus ?? AndroidKeyboardStatus.unsupported();
    setState(() => _keyboardBusy = true);
    try {
      final status = await _keyboardController.setPreferences(
        current: current,
        voiceEnabled: voiceEnabled,
        clipboardSyncDesired: clipboardSyncDesired,
        mediaControlsEnabled: mediaControlsEnabled,
        mediaVolumeStepPercent: mediaVolumeStepPercent,
        mediaBrightnessStepPercent: mediaBrightnessStepPercent,
        layoutProfile: layoutProfile,
        cornerModeEnabled: cornerModeEnabled,
        debugTouchOverlayEnabled: debugTouchOverlayEnabled,
        keyVibrationEnabled: keyVibrationEnabled,
        keySoundEnabled: keySoundEnabled,
        spellingSuggestionsEnabled: spellingSuggestionsEnabled,
        specialKeyCornersEnabled: specialKeyCornersEnabled,
        frenchLanguageEnabled: frenchLanguageEnabled,
        englishLanguageEnabled: englishLanguageEnabled,
        doubleSpacePeriodEnabled: doubleSpacePeriodEnabled,
        punctuationAutoSpacingEnabled: punctuationAutoSpacingEnabled,
        keyboardHeightScale: keyboardHeightScale,
        actionRowHeightScale: actionRowHeightScale,
        compactModeEnabled: compactModeEnabled,
        privacyMode: privacyMode,
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

  Future<void> _setKeyboardThemeMode(String themeMode) async {
    setState(() => _keyboardBusy = true);
    try {
      final status = await AndroidKeyboardBridge.setThemeMode(themeMode);
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
            'Unable to update keyboard theme mode (${error.code}): ${error.message}',
      );
    } finally {
      if (mounted) {
        setState(() => _keyboardBusy = false);
      }
    }
  }

  Future<void> _setKeyboardThemePreset(String presetId) async {
    final currentMode = _keyboardStatus?.themeMode ?? 'system';
    final brightness = _keyboardThemeBrightnessFor(currentMode);
    setState(() => _keyboardBusy = true);
    try {
      await AndroidKeyboardBridge.setKeyboardThemeConfig(
        KeyboardThemePresetCatalog.configFor(presetId, brightness: brightness),
      );
      final status = await _keyboardController.loadStatus();
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
            'Unable to update keyboard theme (${error.code}): ${error.message}',
      );
    } finally {
      if (mounted) {
        setState(() => _keyboardBusy = false);
      }
    }
  }

  Brightness _keyboardThemeBrightnessFor(String themeMode) {
    return switch (themeMode) {
      'dark' => Brightness.dark,
      'light' => Brightness.light,
      _ => Theme.of(context).brightness,
    };
  }

  Future<void> _openOverlaySettings() async {
    try {
      AppDiagnostics.record('overlay_permission_settings', 'open');
      await _overlayController.openPermissionSettings();
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
      final status = await _overlayController.setEnabled(value);
      if (!mounted) {
        return;
      }
      setState(() {
        _overlayStatus = status;
      });
      AppDiagnostics.record(
        'overlay_toggle_result',
        _overlayController.statusSummary(status),
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
      final status = await _overlayController.setAppearance(
        sizeScale: sizeScale,
        opacity: opacity,
      );
      if (!mounted) {
        return;
      }
      setState(() => _overlayStatus = status);
      AppDiagnostics.record(
        'overlay_appearance_result',
        _overlayController.statusSummary(status),
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
      final status = await _overlayController.startRecording();
      if (!mounted) {
        return;
      }
      setState(() {
        _overlayStatus = status;
        _message = 'Overlay recording started.';
      });
      AppDiagnostics.record(
        'overlay_start_result',
        _overlayController.statusSummary(status),
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
      final status = await _overlayController.stopRecording();
      if (!mounted) {
        return;
      }
      setState(() {
        _overlayStatus = status;
        _message = 'Overlay recording stopped.';
      });
      AppDiagnostics.record(
        'overlay_stop_result',
        _overlayController.statusSummary(status),
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
      final status = await _overlayController.cancelRecording();
      if (!mounted) {
        return;
      }
      setState(() {
        _overlayStatus = status;
        _message = 'Overlay recording cancelled.';
      });
      AppDiagnostics.record(
        'overlay_cancel_result',
        _overlayController.statusSummary(status),
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
      await _overlayController.openAccessibilitySettings();
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
    ref.read(localAuthModeProvider.notifier).disable();
  }

  Future<void> _copyBackendDiagnostic() async {
    await Clipboard.setData(ClipboardData(text: _backendDiagnosticText()));
    if (!mounted) {
      return;
    }
    setState(() => _message = 'Backend diagnostic copied.');
  }

  Future<void> _clearDiagnosticLogs() async {
    AppDiagnostics.clear();
    AndroidKeyboardStatus? status;
    if (PlatformCapabilities.keyboardImeSupported) {
      try {
        status = await _keyboardController.clearDiagnostics();
      } on AndroidKeyboardBridgeException catch (error) {
        AppDiagnostics.record(
          'keyboard_diagnostics_clear_error',
          '${error.code}: ${error.message}',
        );
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      if (status != null) {
        _keyboardStatus = status;
      }
      _message = 'Diagnostic logs cleared.';
    });
  }

  String _backendDiagnosticText() {
    final authAsync = ref.read(authSessionProvider);
    final storageStatus = ref.read(_storageStatusProvider);
    final status = _backendStatus(authAsync);
    final lines = <String>[
      'WinFlowz backend diagnostic',
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
      'keyboard_last_error: ${_sanitizeDiagnostic(_keyboardStatus?.lastKeyboardError ?? 'none')}',
      'voice_catalog_status: ${_voiceCatalogDiagnostic(ref.read(languagePackCatalogProvider))}',
      'recent_events: ${_recentEventsDiagnostic()}',
      'settings_message: ${_sanitizeDiagnostic(_message ?? 'none')}',
    ];
    return lines.join('\n');
  }

  String _backendStatus(AsyncValue<AuthSessionSnapshot> authAsync) {
    if (!FirebaseBootstrap.isConfigured) {
      return 'local_mode';
    }
    final session = authAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    if (session == null) {
      return 'firebase_configured_session_pending';
    }
    if (session.isSignedIn && !session.isLocalFallback) {
      return 'firebase_remote';
    }
    if (session.isLocalFallback) {
      return 'firebase_configured_local_session';
    }
    return 'firebase_configured_signed_out';
  }

  String _appearanceSyncLabel(AsyncValue<AuthSessionSnapshot> authAsync) {
    if (!FirebaseBootstrap.isConfigured) {
      return 'Theme preference is saved on this device only.';
    }
    return authAsync.maybeWhen(
      data: (session) {
        if (session.isSignedIn && !session.isLocalFallback) {
          return 'Theme preference syncs with your signed-in account.';
        }
        if (session.isLocalFallback) {
          return 'Theme preference currently stays local (local fallback session).';
        }
        return 'Theme preference is local until you sign in.';
      },
      orElse: () => 'Theme sync status is loading.',
    );
  }

  String _appearanceSyncDetail(AsyncValue<AuthSessionSnapshot> authAsync) {
    if (!FirebaseBootstrap.isConfigured) {
      return 'Remote settings are not configured. This setting applies immediately and persists locally.';
    }
    return authAsync.when(
      data: (session) {
        if (session.isSignedIn && !session.isLocalFallback) {
          return 'Signed in with remote settings available. New appearance changes are written locally first, then synced to your account settings.';
        }
        if (session.isLocalFallback) {
          return 'Firebase is configured but this session is local fallback. Appearance changes are kept locally until remote auth recovers.';
        }
        return 'Firebase is configured but no signed-in account is active. Appearance changes are local until sign-in.';
      },
      loading: () =>
          'Checking authentication session before confirming remote sync state.',
      error: (error, stackTrace) =>
          'Authentication session is unavailable, so appearance sync is currently local only.',
    );
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
      'media_session_access=${status.mediaSessionAccessGranted}',
      'system_settings_write=${status.systemSettingsWriteGranted}',
      'theme=${status.themeMode}',
      'theme_preset=${status.themePresetId}',
      'theme_effect=${status.themePressEffect}',
      'theme_background=${status.themeBackgroundSource}',
      'theme_config_size=${status.themeConfigSize}',
      'theme_fallback=${status.themeFallbackStatus}',
      'layout=${status.layoutProfile.name}',
      'corner_mode=${status.cornerModeEnabled}',
      'corner_preset=${status.cornerPresetId}',
      'debug_touch=${status.debugTouchOverlayEnabled}',
      'double_space=${status.doubleSpacePeriodEnabled}',
      'punct_spacing=${status.punctuationAutoSpacingEnabled}',
      'privacy_mode=${status.privacyMode.name}',
      'recovery_count=${status.keyboardRecoveryCount}',
      'voice_runtime=${status.voiceRuntimeMode}',
      'voice_language=${status.voiceLanguageTag}',
      'voice_pack=${status.voicePackId}',
      'voice_engine=${status.voiceEngine}',
      'voice_fallback_reason=${status.voiceFallbackReason}',
      'voice_last_error_code=${status.voiceLastErrorCode}',
      'last_error_at=${status.lastKeyboardErrorAt ?? 'none'}',
      'last_error=${_sanitizeDiagnostic(status.lastKeyboardError ?? 'none')}',
      'busy=$_keyboardBusy',
    ].join('; ');
  }

  String _voiceCatalogDiagnostic(LanguagePackCatalogState state) {
    final installed = state.installedPacks.values
        .map(
          (pack) =>
              '${pack.packId}:${pack.installState.wireName}:${pack.runtimeMode.wireName}:${pack.fallbackReason.wireName}',
        )
        .join(',');
    return [
      'load_state=${state.loadState.name}',
      'entries=${state.catalog.entries.length}',
      'allow_cloud_fallback=${state.allowCloudFallback}',
      'installed=${installed.isEmpty ? 'none' : installed}',
      'retry_counts=${state.retryCounts.isEmpty ? 'none' : state.retryCounts}',
      'last_error=${_sanitizeDiagnostic(state.lastErrorCode ?? 'none')}',
    ].join('; ');
  }

  LanguagePackDeviceProfile _deviceProfileFromKeyboardStatus(
    AndroidKeyboardStatus status,
  ) {
    if (!status.supported) {
      return const LanguagePackDeviceProfile(
        androidSdk: 0,
        primaryAbi: 'unsupported',
        totalCapacityMb: 0,
        freeSpaceMb: 0,
        ramMb: 0,
      );
    }
    return LanguagePackDeviceProfile(
      androidSdk: status.deviceAndroidSdk,
      primaryAbi: status.devicePrimaryAbi,
      totalCapacityMb: status.deviceTotalCapacityMb,
      freeSpaceMb: status.deviceFreeSpaceMb,
      ramMb: status.deviceRamMb,
    );
  }

  String _sanitizeDiagnostic(Object? value) {
    return SensitiveRedactor.redact(value);
  }

  String _recentEventsDiagnostic() {
    final events = AppDiagnostics.recentEvents;
    if (events.isEmpty) {
      return 'none';
    }
    return events.map((event) => _sanitizeDiagnostic(event)).join(' || ');
  }

  Widget _settingsList({required List<Widget> sections}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns =
            constraints.maxWidth >=
            AppLayoutMetrics.settingsTwoColumnBreakpoint;
        if (!useTwoColumns) {
          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: ListView.separated(
              controller: _scrollController,
              padding: AppInsets.screen,
              itemCount: sections.length,
              separatorBuilder: (_, _) => _sectionGap,
              itemBuilder: (context, index) => sections[index],
            ),
          );
        }

        final totalHorizontalPadding = AppSpacing.x4 * 2;
        final columnSpacing = AppSpacing.x4;
        final itemWidth =
            (constraints.maxWidth - totalHorizontalPadding - columnSpacing) / 2;
        return Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: AppInsets.screen,
            child: Wrap(
              spacing: columnSpacing,
              runSpacing: _sectionRunSpacing,
              children: [
                for (final section in sections)
                  SizedBox(width: itemWidth, child: section),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _collapsibleSection({
    required String id,
    required String title,
    required Widget child,
  }) {
    final expanded = _expandedSections[id] ?? false;
    return Card(
      margin: _collapsibleSectionMargin,
      child: ExpansionTile(
        key: PageStorageKey<String>('settings_section_$id'),
        initiallyExpanded: expanded,
        onExpansionChanged: (value) {
          setState(() => _expandedSections[id] = value);
        },
        tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.x2,
          0,
          AppSpacing.x2,
          AppSpacing.x2,
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleSmall),
        children: [child],
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
        sections: [
          if (widget.onResumeOnboarding != null)
            _OnboardingSettingsTile(
              onResume: widget.onResumeOnboarding!,
              readiness: onboardingReadiness,
              highlightResume: widget.highlightOnboardingResume,
            ),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    final overlayStatus = _overlayStatus;
    final keyboardStatus = _keyboardStatus;
    final themeMode = ref.watch(appThemeModeProvider);
    final authAsync = ref.watch(authSessionProvider);
    final voiceCatalogState = ref.watch(languagePackCatalogProvider);
    return _settingsList(
      sections: [
        if (widget.onResumeOnboarding != null)
          _OnboardingSettingsTile(
            onResume: widget.onResumeOnboarding!,
            readiness: onboardingReadiness,
            highlightResume: widget.highlightOnboardingResume,
          ),
        _collapsibleSection(
          id: 'appearance',
          title: 'Appearance',
          child: _AppearanceSection(
            themeMode: themeMode,
            confirmDestructiveActions:
                (_onboardingSettings ?? const UserSettingsSnapshot.defaults())
                    .confirmDestructiveActions,
            syncStateLabel: _appearanceSyncLabel(authAsync),
            syncStateDetail: _appearanceSyncDetail(authAsync),
            onOpenKeyboardThemeStudio: _openKeyboardThemeStudio,
            onConfirmDestructiveActionsChanged: _setConfirmDestructiveActions,
            onChanged: (mode) {
              ref.read(appThemeModeProvider.notifier).setMode(mode);
            },
          ),
        ),
        _collapsibleSection(
          id: 'backend',
          title: 'Backend Provider',
          child: _BackendProviderSection(
            summary: FirebaseBootstrap.isConfigured
                ? 'Firebase is configured as the first backend adapter.'
                : 'Remote sync is not configured. WinFlowz runs in local mode.',
            detail: _appearanceSyncDetail(authAsync),
            diagnosticText: _backendDiagnosticText(),
            onCopyDiagnostic: _copyBackendDiagnostic,
            onClearDiagnosticLogs: _clearDiagnosticLogs,
          ),
        ),
        _collapsibleSection(
          id: 'keys',
          title: 'Local AI Keys',
          child: _SecretsSection(
            storageStatusAsync: storageStatusAsync,
            openAiController: _openAiController,
            anthropicController: _anthropicController,
            message: _message,
            saving: _saving,
            onSave: _saveSecrets,
            onSignOut: _signOut,
          ),
        ),
        _collapsibleSection(
          id: 'platform',
          title: 'Platform Capabilities',
          child: const _PlatformCapabilitiesSection(),
        ),
        if (PlatformCapabilities.keyboardImeSupported)
          _collapsibleSection(
            id: 'keyboard',
            title: 'WinFlowz Keyboard',
            child: _KeyboardSettingsSection(
              status: keyboardStatus,
              busy: _keyboardBusy,
              onRefresh: _loadKeyboardState,
              onOpenInputSettings: _openKeyboardSettings,
              onShowPicker: _showKeyboardPicker,
              onOpenCornerShortcuts: _openCornerShortcuts,
              onOpenKeyboardThemeStudio: _openKeyboardThemeStudio,
              onThemeModeChanged: _setKeyboardThemeMode,
              onThemePresetChanged: _setKeyboardThemePreset,
              onPreferenceChanged: _setKeyboardPreferences,
            ),
          ),
        _collapsibleSection(
          id: 'voice_packs',
          title: 'On-device Speech',
          child: _OnDeviceSpeechSection(
            state: voiceCatalogState,
            keyboardStatus: keyboardStatus,
            onRefresh: () =>
                ref.read(languagePackCatalogProvider.notifier).refresh(),
            onAllowCloudFallbackChanged: (value) => ref
                .read(languagePackCatalogProvider.notifier)
                .setAllowCloudFallback(value),
            onInstall: (entry) => ref
                .read(languagePackCatalogProvider.notifier)
                .installPackWithPreflight(
                  entry: entry,
                  device: _deviceProfileFromKeyboardStatus(
                    keyboardStatus ?? AndroidKeyboardStatus.unsupported(),
                  ),
                ),
            onRetryInstall: (entry) => ref
                .read(languagePackCatalogProvider.notifier)
                .retryInstallWithPreflight(
                  entry: entry,
                  device: _deviceProfileFromKeyboardStatus(
                    keyboardStatus ?? AndroidKeyboardStatus.unsupported(),
                  ),
                ),
            onMarkUpdateAvailable: (entry) => ref
                .read(languagePackCatalogProvider.notifier)
                .markUpdateAvailable(entry),
            onMarkCorrupted: (entry) => ref
                .read(languagePackCatalogProvider.notifier)
                .markCorrupted(entry),
            onRemove: (entry) =>
                ref.read(languagePackCatalogProvider.notifier).remove(entry),
          ),
        ),
        if (PlatformCapabilities.overlaySupported)
          _collapsibleSection(
            id: 'overlay',
            title: 'Android Overlay',
            child: _OverlaySettingsSection(
              status: overlayStatus,
              busy: _overlayBusy,
              onToggle: _toggleOverlay,
              onAppearanceChanged: _setOverlayAppearance,
              onOpenOverlaySettings: _openOverlaySettings,
              onOpenAccessibilitySettings: _openAccessibilitySettings,
              onStart: _startOverlay,
              onStop: _stopOverlay,
              onCancel: _cancelOverlay,
            ),
          ),
      ],
    );
  }
}

class _OnboardingSettingsTile extends StatefulWidget {
  const _OnboardingSettingsTile({
    required this.onResume,
    required this.readiness,
    required this.highlightResume,
  });

  final VoidCallback onResume;
  final OnboardingReadiness readiness;
  final bool highlightResume;

  @override
  State<_OnboardingSettingsTile> createState() =>
      _OnboardingSettingsTileState();
}

class _OnboardingSettingsTileState extends State<_OnboardingSettingsTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    if (widget.highlightResume) {
      _startGlow();
    }
  }

  @override
  void didUpdateWidget(covariant _OnboardingSettingsTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightResume && !oldWidget.highlightResume) {
      _startGlow();
    } else if (!widget.highlightResume && oldWidget.highlightResume) {
      _glowController.stop();
      _glowController.value = 0;
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _startGlow() {
    _glowController
      ..stop()
      ..value = 0
      ..repeat(reverse: true, count: 4);
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.readiness.steps
        .where((step) => step.satisfied)
        .length;
    final skipped = widget.readiness.steps.where((step) => step.skipped).length;
    final pending = widget.readiness.steps
        .where((step) => step.requiresAction)
        .length;
    final actionLabel = widget.readiness.shouldShowOnboarding
        ? 'Reprendre'
        : widget.readiness.onboardingCompleted
        ? 'Voir le récapitulatif'
        : 'Reprendre';

    final subtitle = !widget.readiness.platformSupported
        ? 'Non requis sur cette plateforme'
        : widget.readiness.shouldShowOnboarding
        ? 'Actifs: $active • Ignorés: $skipped • À configurer si utile: $pending'
        : 'Onboarding terminé';

    final tile = AppStatusCard(
      icon: Icons.flag_outlined,
      title: 'Onboarding permissions',
      subtitle: subtitle,
      trailing: TextButton(
        onPressed: widget.onResume,
        child: Text(actionLabel),
      ),
    );

    return AnimatedBuilder(
      animation: _glowController,
      child: tile,
      builder: (context, child) {
        final glow = widget.highlightResume ? _glowController.value : 0.0;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            boxShadow: glow > 0
                ? [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.38 * glow),
                      blurRadius: 10 + (18 * glow),
                      spreadRadius: 1 + (3 * glow),
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
    );
  }
}
