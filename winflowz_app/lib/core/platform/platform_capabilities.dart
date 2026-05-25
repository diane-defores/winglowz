import 'package:flutter/foundation.dart';

class PlatformCapabilities {
  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  static bool get isLinux =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
  static bool get isWeb => kIsWeb;

  static String get currentPlatformLabel {
    if (isWeb) {
      return 'version web';
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'Android',
      TargetPlatform.iOS => 'iOS',
      TargetPlatform.macOS => 'macOS',
      TargetPlatform.windows => 'Windows',
      TargetPlatform.linux => 'Linux',
      TargetPlatform.fuchsia => 'Fuchsia',
    };
  }

  static String get localSpeechUnavailableReason {
    if (isWeb) {
      return 'La version web s’exécute dans le navigateur: elle ne peut pas utiliser le moteur de dictée local du téléphone.';
    }
    if (isLinux) {
      return 'Linux n’expose pas encore le moteur de dictée locale attendu par WinFlowz.';
    }
    return 'Cette fonctionnalité dépend du moteur de dictée local de la plateforme.';
  }

  static String get overlayUnavailableReason {
    if (isWeb) {
      return 'La version web s’exécute dans le navigateur: elle ne peut pas afficher une bulle système au-dessus des autres apps.';
    }
    return 'L’overlay WinFlowz dépend des APIs natives Android pour afficher une bulle au-dessus des autres apps.';
  }

  static String get keyboardImeUnavailableReason {
    if (isWeb) {
      return 'La version web s’exécute dans le navigateur: elle ne peut pas installer ni sélectionner un clavier système.';
    }
    return 'Le clavier WinFlowz est une IME native Android et ne peut pas être installé sur $currentPlatformLabel.';
  }

  static bool get localSpeechSupported => !isWeb && !isLinux;
  static bool get overlaySupported => isAndroid;
  static bool get keyboardImeSupported => isAndroid;
  static bool get secureStorageDegraded => isWeb || isLinux;
}
