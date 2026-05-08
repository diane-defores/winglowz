import 'package:flutter/services.dart';

import '../../features/clipboard/domain/clipboard_capture_event.dart';
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

  static Future<List<AndroidKeyboardClipboardEvent>>
  drainKeyboardClipboardEvents() async {
    if (!PlatformCapabilities.keyboardImeSupported) {
      return const <AndroidKeyboardClipboardEvent>[];
    }
    final raw = await _invoke<List<Object?>>('drainKeyboardClipboardEvents');
    return (raw ?? const <Object?>[])
        .whereType<Map<Object?, Object?>>()
        .map(AndroidKeyboardClipboardEvent.fromMap)
        .where((event) => event != null)
        .cast<AndroidKeyboardClipboardEvent>()
        .toList(growable: false);
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

class AndroidKeyboardClipboardEvent {
  const AndroidKeyboardClipboardEvent({
    required this.content,
    required this.source,
    required this.deviceId,
    required this.capturedAtUtc,
    required this.sourceMetadata,
  });

  final String content;
  final ClipboardCanonicalSource source;
  final String deviceId;
  final DateTime capturedAtUtc;
  final Map<String, Object?> sourceMetadata;

  static AndroidKeyboardClipboardEvent? fromMap(Map<Object?, Object?> map) {
    final content = map['content'];
    final deviceId = map['deviceId'];
    final capturedAtEpochMillis = map['capturedAtEpochMillis'];
    if (content is! String ||
        content.trim().isEmpty ||
        deviceId is! String ||
        deviceId.trim().isEmpty ||
        capturedAtEpochMillis is! num) {
      return null;
    }
    final metadata = <String, Object?>{};
    final rawMetadata = map['sourceMetadata'];
    if (rawMetadata is Map<Object?, Object?>) {
      for (final entry in rawMetadata.entries) {
        final key = entry.key;
        final value = entry.value;
        if (key is String &&
            (value == null ||
                value is String ||
                value is num ||
                value is bool)) {
          metadata[key] = value;
        }
      }
    }
    return AndroidKeyboardClipboardEvent(
      content: content,
      source: ClipboardCanonicalSource.fromDatabase(map['source'] as String?),
      deviceId: deviceId,
      capturedAtUtc: DateTime.fromMillisecondsSinceEpoch(
        capturedAtEpochMillis.toInt(),
        isUtc: true,
      ),
      sourceMetadata: metadata,
    );
  }
}
