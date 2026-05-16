import 'package:flutter_test/flutter_test.dart';
import 'package:winflowz_app/core/platform/android_overlay_bridge.dart';
import 'package:winflowz_app/features/keyboard/domain/keyboard_models.dart';
import 'package:winflowz_app/features/settings/domain/onboarding_permission_contract.dart';

void main() {
  const overlayStatus = AndroidOverlayStatus(
    enabled: false,
    requestedEnabled: false,
    running: false,
    overlayPermissionGranted: false,
    accessibilityPermissionGranted: false,
    recordAudioGranted: false,
    deliveryMode: OverlayDeliveryMode.clipboardOnly,
    sizeScale: 1,
    opacity: 0.8,
  );

  AndroidKeyboardStatus keyboardStatus({
    bool enabled = false,
    bool active = false,
    bool clipboardSyncDesired = false,
  }) {
    return AndroidKeyboardStatus.fromMap({
      'supported': true,
      'enabled': enabled,
      'active': active,
      'voiceEnabled': true,
      'clipboardSyncDesired': clipboardSyncDesired,
      'mediaControlsEnabled': true,
      'privacyMode': 'auto',
    });
  }

  test('exposes voice keyboard and clipboard as optional modules', () {
    final readiness = evaluateOnboardingReadiness(
      isPlatformSupported: true,
      overlayStatus: overlayStatus,
      keyboardStatus: keyboardStatus(),
      persistedStep: 0,
      onboardingCompleted: false,
    );

    expect(readiness.hasPendingMandatory, isFalse);
    expect(readiness.steps.every((step) => !step.isMandatory), isTrue);
    expect(readiness.steps.map((step) => step.definition.id), [
      OnboardingStepId.keyboardIme,
      OnboardingStepId.keyboardClipboard,
      OnboardingStepId.microphoneForDictation,
      OnboardingStepId.accessibility,
      OnboardingStepId.mediaSessionAccess,
      OnboardingStepId.brightnessSystemSettings,
      OnboardingStepId.overlay,
    ]);
    expect(
      readiness.steps
          .where((step) => step.definition.group == OnboardingStepGroup.voice)
          .map((step) => step.definition.id),
      [OnboardingStepId.microphoneForDictation, OnboardingStepId.accessibility],
    );
    expect(
      readiness.steps
          .where(
            (step) => step.definition.group == OnboardingStepGroup.clipboard,
          )
          .map((step) => step.definition.id),
      [OnboardingStepId.keyboardClipboard],
    );
  });

  test('keeps overlay optional and last after selected setup', () {
    final readiness = evaluateOnboardingReadiness(
      isPlatformSupported: true,
      overlayStatus: overlayStatus,
      keyboardStatus: keyboardStatus(enabled: true, active: true),
      persistedStep: 0,
      onboardingCompleted: false,
      clipboardSkipped: true,
      microphoneSkipped: true,
      accessibilitySkipped: true,
      mediaAccessSkipped: true,
      brightnessSkipped: true,
    );

    expect(readiness.activeStep?.definition.id, OnboardingStepId.overlay);
    expect(readiness.activeStep?.isMandatory, isFalse);
    expect(readiness.shouldShowCompletion, isFalse);

    final completed = evaluateOnboardingReadiness(
      isPlatformSupported: true,
      overlayStatus: overlayStatus,
      keyboardStatus: keyboardStatus(enabled: true, active: true),
      persistedStep: 0,
      onboardingCompleted: false,
      clipboardSkipped: true,
      microphoneSkipped: true,
      accessibilitySkipped: true,
      mediaAccessSkipped: true,
      brightnessSkipped: true,
      overlaySkipped: true,
    );

    expect(completed.shouldShowCompletion, isTrue);
  });
}
