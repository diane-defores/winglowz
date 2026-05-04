import 'package:flutter/foundation.dart';

class PlatformCapabilities {
  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  static bool get isLinux =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
  static bool get isWeb => kIsWeb;

  static bool get localSpeechSupported => !isLinux;
  static bool get overlaySupported => isAndroid;
  static bool get keyboardImeSupported => isAndroid;
  static bool get secureStorageDegraded => isWeb || isLinux;
}
