import '../../../core/platform/android_overlay_bridge.dart';
import '../../keyboard/domain/keyboard_models.dart';

enum OnboardingStepCategory { mandatory, recommended }

enum OnboardingStepId {
  overlay,
  keyboardIme,
  accessibility,
  microphoneForDictation,
}

class OnboardingStepDefinition {
  const OnboardingStepDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.why,
    required this.category,
    required this.openActionLabel,
    required this.whereToFind,
    this.secondaryActionLabel,
  });

  final OnboardingStepId id;
  final String title;
  final String description;
  final String why;
  final OnboardingStepCategory category;
  final String openActionLabel;
  final String whereToFind;
  final String? secondaryActionLabel;
}

class OnboardingStepProgress {
  const OnboardingStepProgress({
    required this.definition,
    required this.satisfied,
    required this.supported,
    required this.skipped,
    this.blockerReason,
  });

  final OnboardingStepDefinition definition;
  final bool satisfied;
  final bool supported;
  final bool skipped;
  final String? blockerReason;

  bool get completed => satisfied || skipped || !supported;

  bool get isMandatory =>
      definition.category == OnboardingStepCategory.mandatory;

  bool get isRecommended =>
      definition.category == OnboardingStepCategory.recommended;

  bool get requiresAction => supported && !completed && isMandatory;
}

class OnboardingReadiness {
  const OnboardingReadiness({
    required this.platformSupported,
    required this.steps,
    required this.currentStep,
    required this.onboardingCompleted,
  });

  final bool platformSupported;
  final List<OnboardingStepProgress> steps;
  final int currentStep;
  final bool onboardingCompleted;

  bool get hasPendingMandatory {
    return steps
        .where((step) => step.isMandatory)
        .any((step) => !step.completed);
  }

  bool get hasPendingRecommended {
    return steps
        .where((step) => step.isRecommended)
        .any((step) => !step.completed);
  }

  bool get allMandatoryCompleted {
    return steps
        .where((step) => step.isMandatory)
        .every((step) => step.completed);
  }

  bool get allStepsCompleted {
    return steps.every((step) => step.completed);
  }

  bool get shouldShowCompletion {
    return platformSupported && allMandatoryCompleted && allStepsCompleted;
  }

  bool get shouldShowOnboarding {
    return platformSupported && !onboardingCompleted;
  }

  OnboardingStepProgress? get activeStep {
    if (currentStep < 0 || currentStep >= steps.length) {
      return null;
    }
    return steps[currentStep];
  }
}

const _stepDefinitions = <OnboardingStepDefinition>[
  OnboardingStepDefinition(
    id: OnboardingStepId.overlay,
    title: 'Autorisation Overlay',
    description: 'Active la bulle flottante WinFlowz.',
    why:
        'La bulle flottante permet de démarrer et arrêter la dictée sans repasser par les menus.',
    category: OnboardingStepCategory.mandatory,
    openActionLabel: 'Activer l’overlay',
    whereToFind:
        'Réglages Android → Applications → WinFlowz → Autorisations → Afficher les fenêtres',
  ),
  OnboardingStepDefinition(
    id: OnboardingStepId.keyboardIme,
    title: 'Clavier WinFlowz keyboard',
    description: 'Active et sélectionne WinFlowz keyboard comme clavier Android.',
    why:
        'Sans clavier natif actif, la dictée ne peut pas écrire directement dans les champs.',
    category: OnboardingStepCategory.mandatory,
    openActionLabel: 'Ouvrir les paramètres Clavier',
    secondaryActionLabel: 'Choisir le clavier',
    whereToFind:
        'Réglages Android → Système → Langues et clavier → Claviers virtuels',
  ),
  OnboardingStepDefinition(
    id: OnboardingStepId.accessibility,
    title: 'Service Accessibilité',
    description: 'Active le service d’accessibilité WinFlowz.',
    why:
        'Ce service améliore la précision de l’injection directe et évite certains blocages.',
    category: OnboardingStepCategory.recommended,
    openActionLabel: 'Ouvrir Accessibilité',
    whereToFind: 'Réglages Android → Accessibilité → Service WinFlowz',
  ),
  OnboardingStepDefinition(
    id: OnboardingStepId.microphoneForDictation,
    title: 'Microphone',
    description: 'Autorise l’accès micro pour la dictée.',
    why:
        'Sans micro, la dictée vocale est indisponible; la saisie clavier reste active.',
    category: OnboardingStepCategory.recommended,
    openActionLabel: 'Ouvrir les permissions App',
    whereToFind:
        'Réglages Android → Applications → WinFlowz → Autorisations → Microphone',
  ),
];

OnboardingReadiness evaluateOnboardingReadiness({
  required bool isPlatformSupported,
  required AndroidOverlayStatus overlayStatus,
  required AndroidKeyboardStatus keyboardStatus,
  required int persistedStep,
  required bool onboardingCompleted,
  bool accessibilitySkipped = false,
  bool microphoneSkipped = false,
}) {
  if (!isPlatformSupported) {
    return const OnboardingReadiness(
      platformSupported: false,
      steps: <OnboardingStepProgress>[],
      currentStep: 0,
      onboardingCompleted: false,
    );
  }

  final steps = <OnboardingStepProgress>[];
  for (final definition in _stepDefinitions) {
    final supported = _isStepSupported(
      definition: definition,
      keyboardStatus: keyboardStatus,
    );
    final skipped = _isStepSkipped(
      definition: definition,
      accessibilitySkipped: accessibilitySkipped,
      microphoneSkipped: microphoneSkipped,
    );
    final satisfied = skipped
        ? true
        : _isStepSatisfied(
            definition: definition,
            overlayStatus: overlayStatus,
            keyboardStatus: keyboardStatus,
          );

    steps.add(
      OnboardingStepProgress(
        definition: definition,
        satisfied: satisfied,
        supported: supported,
        skipped: skipped,
        blockerReason: supported && !satisfied
            ? _stepBlockerReason(
                definition: definition,
                overlayStatus: overlayStatus,
                keyboardStatus: keyboardStatus,
              )
            : null,
      ),
    );
  }

  var firstIncomplete = steps.indexWhere((step) => !step.completed);
  if (firstIncomplete < 0) {
    firstIncomplete = steps.length;
  }
  if (persistedStep >= 0 && persistedStep < steps.length) {
    final persistedFallback = steps
        .sublist(persistedStep)
        .indexWhere((step) => !step.completed);
    if (persistedFallback >= 0) {
      firstIncomplete = persistedStep + persistedFallback;
    }
  }

  return OnboardingReadiness(
    platformSupported: true,
    steps: steps,
    currentStep: firstIncomplete,
    onboardingCompleted: onboardingCompleted,
  );
}

bool _isStepSkipped({
  required OnboardingStepDefinition definition,
  required bool accessibilitySkipped,
  required bool microphoneSkipped,
}) {
  if (definition.id == OnboardingStepId.accessibility) {
    return accessibilitySkipped;
  }
  if (definition.id == OnboardingStepId.microphoneForDictation) {
    return microphoneSkipped;
  }
  return false;
}

bool _isStepSupported({
  required OnboardingStepDefinition definition,
  required AndroidKeyboardStatus keyboardStatus,
}) {
  if (definition.id == OnboardingStepId.keyboardIme) {
    return keyboardStatus.supported;
  }
  return true;
}

bool _isStepSatisfied({
  required OnboardingStepDefinition definition,
  required AndroidOverlayStatus overlayStatus,
  required AndroidKeyboardStatus keyboardStatus,
}) {
  switch (definition.id) {
    case OnboardingStepId.overlay:
      return overlayStatus.overlayPermissionGranted && overlayStatus.enabled;
    case OnboardingStepId.accessibility:
      return overlayStatus.accessibilityPermissionGranted;
    case OnboardingStepId.keyboardIme:
      return keyboardStatus.enabled && keyboardStatus.active;
    case OnboardingStepId.microphoneForDictation:
      return overlayStatus.recordAudioGranted;
  }
}

String? _stepBlockerReason({
  required OnboardingStepDefinition definition,
  required AndroidOverlayStatus overlayStatus,
  required AndroidKeyboardStatus keyboardStatus,
}) {
  if (definition.id == OnboardingStepId.overlay) {
    if (!overlayStatus.overlayPermissionGranted) {
      return 'Permission Overlay refusée: la bulle est bloquée.';
    }
    if (!overlayStatus.enabled) {
      return 'Overlay autorisé mais désactivé: active la bulle WinFlowz.';
    }
    return null;
  }
  if (definition.id == OnboardingStepId.accessibility) {
    return overlayStatus.accessibilityPermissionGranted
        ? null
        : 'Service Accessibilité désactivé: dictée en mode compatibilité.';
  }
    if (definition.id == OnboardingStepId.keyboardIme) {
      if (!keyboardStatus.supported) {
      return 'IME WinFlowz keyboard non disponible sur cet appareil.';
    }
    if (!keyboardStatus.enabled) {
      return 'Clavier WinFlowz keyboard non activé.';
    }
    if (!keyboardStatus.active) {
      return 'Le clavier WinFlowz keyboard n’est pas sélectionné actuellement.';
    }
    return null;
  }
  if (definition.id == OnboardingStepId.microphoneForDictation) {
    return overlayStatus.recordAudioGranted
        ? null
        : 'Microphone refusé: la dictée vocale est indisponible.';
  }
  return null;
}

extension OnboardingStepDefinitionList on List<OnboardingStepDefinition> {
  OnboardingStepDefinition getById(OnboardingStepId id) {
    return firstWhere((item) => item.id == id);
  }
}
