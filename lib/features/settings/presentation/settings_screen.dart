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
import '../../snippets/application/snippet_store_provider.dart';
import '../domain/onboarding_permission_contract.dart';
import '../domain/settings_store.dart';
import '../../voice/application/transcription_store_provider.dart';
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
      KeyboardPrivacyMode? privacyMode,
    });

typedef _OverlayAppearanceChanged =
    Future<void> Function({required double sizeScale, required double opacity});

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
      setState(
        () => _message =
            'Impossible de charger la progression onboarding: $error',
      );
    } finally {
      if (mounted) {
        setState(() => _onboardingLoading = false);
      }
    }
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

  Future<void> _setKeyboardPreferences({
    bool? voiceEnabled,
    bool? clipboardSyncDesired,
    bool? mediaControlsEnabled,
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
        _message = 'Overlay recording canceled.';
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
      'layout=${status.layoutProfile.name}',
      'corner_mode=${status.cornerModeEnabled}',
      'corner_preset=${status.cornerPresetId}',
      'debug_touch=${status.debugTouchOverlayEnabled}',
      'double_space=${status.doubleSpacePeriodEnabled}',
      'punct_spacing=${status.punctuationAutoSpacingEnabled}',
      'privacy_mode=${status.privacyMode.name}',
      'busy=$_keyboardBusy',
    ].join('; ');
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
        _AppearanceSection(
          themeMode: themeMode,
          onChanged: (mode) {
            ref.read(appThemeModeProvider.notifier).setMode(mode);
          },
        ),
        AppGaps.x4,
        _BackendProviderSection(
          configured: FirebaseBootstrap.isConfigured,
          diagnosticText: _backendDiagnosticText(),
          onCopyDiagnostic: _copyBackendDiagnostic,
        ),
        AppGaps.x4,
        _SecretsSection(
          storageStatusAsync: storageStatusAsync,
          openAiController: _openAiController,
          anthropicController: _anthropicController,
          message: _message,
          saving: _saving,
          onSave: _saveSecrets,
          onSignOut: _signOut,
        ),
        AppGaps.x4,
        const _PlatformCapabilitiesSection(),
        AppGaps.x4,
        if (PlatformCapabilities.keyboardImeSupported)
          _KeyboardSettingsSection(
            status: keyboardStatus,
            busy: _keyboardBusy,
            onRefresh: _loadKeyboardState,
            onOpenInputSettings: _openKeyboardSettings,
            onShowPicker: _showKeyboardPicker,
            onOpenCornerShortcuts: _openCornerShortcuts,
            onPreferenceChanged: _setKeyboardPreferences,
          ),
        if (PlatformCapabilities.overlaySupported)
          _OverlaySettingsSection(
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
        .where(
          (step) =>
              step.definition.category == OnboardingStepCategory.mandatory,
        )
        .toList(growable: false);
    final recommended = readiness.steps
        .where(
          (step) =>
              step.definition.category == OnboardingStepCategory.recommended,
        )
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
                        ? 'Étapes complétées: $mandatoryDone/${mandatory.length} obligatoires, $recommendedDone/${recommended.length} recommandées'
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
        trailing: TextButton(onPressed: onResume, child: Text(actionLabel)),
      ),
    );
  }
}
