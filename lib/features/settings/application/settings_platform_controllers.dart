import '../../../core/diagnostics/sensitive_redactor.dart';
import '../../../core/platform/android_keyboard_bridge.dart';
import '../../../core/platform/android_overlay_bridge.dart';
import '../../keyboard/domain/keyboard_models.dart';

class SettingsKeyboardController {
  const SettingsKeyboardController();

  Future<AndroidKeyboardStatus> loadStatus() {
    return AndroidKeyboardBridge.getStatus();
  }

  Future<void> openInputMethodSettings() {
    return AndroidKeyboardBridge.openInputMethodSettings();
  }

  Future<void> showInputMethodPicker() {
    return AndroidKeyboardBridge.showInputMethodPicker();
  }

  Future<AndroidKeyboardStatus> setPreferences({
    required AndroidKeyboardStatus current,
    bool? voiceEnabled,
    bool? clipboardSyncDesired,
    bool? mediaControlsEnabled,
    String? themeMode,
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
  }) {
    return AndroidKeyboardBridge.setPreferences(
      voiceEnabled: voiceEnabled ?? current.voiceEnabled,
      clipboardSyncDesired:
          clipboardSyncDesired ?? current.clipboardSyncDesired,
      mediaControlsEnabled:
          mediaControlsEnabled ?? current.mediaControlsEnabled,
      themeMode: themeMode ?? current.themeMode,
      layoutProfile: layoutProfile ?? current.layoutProfile,
      cornerModeEnabled: cornerModeEnabled ?? current.cornerModeEnabled,
      debugTouchOverlayEnabled:
          debugTouchOverlayEnabled ?? current.debugTouchOverlayEnabled,
      keyVibrationEnabled: keyVibrationEnabled ?? current.keyVibrationEnabled,
      keySoundEnabled: keySoundEnabled ?? current.keySoundEnabled,
      spellingSuggestionsEnabled:
          spellingSuggestionsEnabled ?? current.spellingSuggestionsEnabled,
      specialKeyCornersEnabled:
          specialKeyCornersEnabled ?? current.specialKeyCornersEnabled,
      frenchLanguageEnabled:
          frenchLanguageEnabled ?? current.frenchLanguageEnabled,
      englishLanguageEnabled:
          englishLanguageEnabled ?? current.englishLanguageEnabled,
      doubleSpacePeriodEnabled:
          doubleSpacePeriodEnabled ?? current.doubleSpacePeriodEnabled,
      punctuationAutoSpacingEnabled:
          punctuationAutoSpacingEnabled ??
          current.punctuationAutoSpacingEnabled,
      privacyMode: privacyMode ?? current.privacyMode,
    );
  }
}

class SettingsOverlayController {
  const SettingsOverlayController();

  Future<AndroidOverlayStatus> loadStatus() {
    return AndroidOverlayBridge.getStatus();
  }

  Future<void> openPermissionSettings() {
    return AndroidOverlayBridge.openPermissionSettings();
  }

  Future<void> openAccessibilitySettings() {
    return AndroidOverlayBridge.openAccessibilitySettings();
  }

  Future<AndroidOverlayStatus> setEnabled(bool enabled) {
    return AndroidOverlayBridge.setOverlayEnabled(enabled);
  }

  Future<AndroidOverlayStatus> setAppearance({
    required double sizeScale,
    required double opacity,
  }) {
    return AndroidOverlayBridge.setAppearance(
      sizeScale: sizeScale,
      opacity: opacity,
    );
  }

  Future<AndroidOverlayStatus> startRecording() {
    return AndroidOverlayBridge.startRecording();
  }

  Future<AndroidOverlayStatus> stopRecording() {
    return AndroidOverlayBridge.stopRecording();
  }

  Future<AndroidOverlayStatus> cancelRecording() {
    return AndroidOverlayBridge.cancelRecording();
  }

  String statusSummary(AndroidOverlayStatus status) {
    return [
      'enabled=${status.enabled}',
      'requested=${status.requestedEnabled}',
      'running=${status.running}',
      'overlay_permission=${status.overlayPermissionGranted}',
      'accessibility_permission=${status.accessibilityPermissionGranted}',
      'service_state=${status.serviceState}',
      'event_queue_size=${status.eventQueueSize}',
      'last_native_event=${SensitiveRedactor.redact(status.lastNativeEvent ?? 'none')}',
    ].join('; ');
  }
}
