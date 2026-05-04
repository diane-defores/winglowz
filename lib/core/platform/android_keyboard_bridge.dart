import 'package:flutter/services.dart';

import '../../features/keyboard/domain/keyboard_models.dart';
import 'platform_capabilities.dart';

class AndroidKeyboardBridgeException implements Exception {
  const AndroidKeyboardBridgeException({
    required this.code,
    required this.message,
    this.details,
  });

  final String code;
  final String message;
  final Object? details;

  @override
  String toString() => 'AndroidKeyboardBridgeException($code): $message';
}

class AndroidKeyboardBridge {
  AndroidKeyboardBridge._();

  static const MethodChannel _channel = MethodChannel('voiceflowz/keyboard');

  static Future<AndroidKeyboardStatus> getStatus() async {
    if (!PlatformCapabilities.keyboardImeSupported) {
      return AndroidKeyboardStatus.unsupported();
    }
    final raw = await _invoke<Map<Object?, Object?>>('getKeyboardStatus');
    return AndroidKeyboardStatus.fromMap(raw ?? const {});
  }

  static Future<void> openInputMethodSettings() async {
    if (!PlatformCapabilities.keyboardImeSupported) {
      throw const AndroidKeyboardBridgeException(
        code: 'KEYBOARD_UNSUPPORTED',
        message: 'Android keyboard IME is not supported on this platform.',
      );
    }
    await _invoke<void>('openInputMethodSettings');
  }

  static Future<void> showInputMethodPicker() async {
    if (!PlatformCapabilities.keyboardImeSupported) {
      throw const AndroidKeyboardBridgeException(
        code: 'KEYBOARD_UNSUPPORTED',
        message: 'Android keyboard IME is not supported on this platform.',
      );
    }
    await _invoke<void>('showInputMethodPicker');
  }

  static Future<AndroidKeyboardStatus> setPreferences({
    required bool voiceEnabled,
    required bool clipboardSyncDesired,
    required bool mediaControlsEnabled,
    required KeyboardPrivacyMode privacyMode,
  }) async {
    if (!PlatformCapabilities.keyboardImeSupported) {
      throw const AndroidKeyboardBridgeException(
        code: 'KEYBOARD_UNSUPPORTED',
        message: 'Android keyboard IME is not supported on this platform.',
      );
    }
    final raw = await _invoke<Map<Object?, Object?>>('setKeyboardPreferences', {
      'voiceEnabled': voiceEnabled,
      'clipboardSyncDesired': clipboardSyncDesired,
      'mediaControlsEnabled': mediaControlsEnabled,
      'privacyMode': privacyMode.name,
    });
    return AndroidKeyboardStatus.fromMap(raw ?? const {});
  }

  static Future<T?> _invoke<T>(String method, [Object? arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (error) {
      throw AndroidKeyboardBridgeException(
        code: error.code,
        message: error.message ?? 'Native keyboard operation failed.',
        details: error.details,
      );
    }
  }
}
