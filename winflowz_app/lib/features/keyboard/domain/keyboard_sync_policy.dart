import 'dart:convert';

class KeyboardSyncPolicyV1 {
  const KeyboardSyncPolicyV1._();

  static const String id = 'keyboard_sync_v1';
  static const int schemaVersion = 1;
  static const int maxProfileBytes = 96 * 1024;

  static const Set<String> _allowedTopLevelKeys = {
    'preferences',
    'themeConfig',
    'cornerConfig',
    'statusBarConfig',
    'metadata',
  };

  static const Set<String> _blockedTopLevelKeys = {
    'recents',
    'clipboard',
    'clipboardHistory',
    'diagnostics',
    'rawVoiceArtifacts',
    'voiceArtifacts',
    'voiceRaw',
    'imageBytes',
    'imagePath',
    'localImagePath',
    'privatePaths',
    'token',
    'tokens',
    'secret',
    'secrets',
    'jwt',
    'accessToken',
    'refreshToken',
  };

  static const Set<String> _blockedAnyDepthKeyFragments = {
    'token',
    'secret',
    'clipboard',
    'diagnostic',
    'recent',
    'rawvoice',
    'voiceartifact',
    'privatepath',
    'imagebytes',
    'jwt',
  };

  static Map<String, Object?> sanitizePayload(Map<String, Object?> source) {
    final output = <String, Object?>{};
    for (final entry in source.entries) {
      if (!_allowedTopLevelKeys.contains(entry.key) ||
          _blockedTopLevelKeys.contains(entry.key)) {
        continue;
      }
      final sanitized = _sanitizeValue(entry.value, keyHint: entry.key);
      if (sanitized != null) {
        output[entry.key] = sanitized;
      }
    }
    return output;
  }

  static Object? _sanitizeValue(Object? value, {String keyHint = ''}) {
    if (value == null) {
      return null;
    }
    if (value is bool || value is num) {
      return value;
    }
    if (value is String) {
      return _sanitizeString(value, keyHint: keyHint);
    }
    if (value is List) {
      final list = <Object?>[];
      for (final item in value) {
        final sanitized = _sanitizeValue(item, keyHint: keyHint);
        if (sanitized != null) {
          list.add(sanitized);
        }
      }
      return list;
    }
    if (value is Map) {
      final normalized = <String, Object?>{};
      for (final entry in value.entries) {
        final key = entry.key.toString();
        if (_isForbiddenKey(key)) {
          continue;
        }
        final sanitized = _sanitizeValue(entry.value, keyHint: key);
        if (sanitized != null) {
          normalized[key] = sanitized;
        }
      }
      if (keyHint == 'cornerConfig') {
        return _sanitizeCornerConfig(normalized);
      }
      if (keyHint == 'themeConfig') {
        return _sanitizeThemeConfig(normalized);
      }
      return normalized;
    }
    return null;
  }

  static bool _isForbiddenKey(String key) {
    final lowered = key.toLowerCase();
    for (final fragment in _blockedAnyDepthKeyFragments) {
      if (lowered.contains(fragment)) {
        return true;
      }
    }
    return false;
  }

  static String? _sanitizeString(String value, {required String keyHint}) {
    final loweredKey = keyHint.toLowerCase();
    final loweredValue = value.toLowerCase();
    if (loweredKey.contains('path') ||
        loweredValue.startsWith('/storage/') ||
        loweredValue.startsWith('/data/') ||
        loweredValue.startsWith('file://') ||
        loweredValue.startsWith('/sdcard/')) {
      return null;
    }
    return value;
  }

  static Map<String, Object?> _sanitizeThemeConfig(Map<String, Object?> input) {
    final output = Map<String, Object?>.from(input);
    output.remove('imagePath');
    output.remove('localImagePath');
    output.remove('backgroundImagePath');
    output.remove('imageBytes');
    output.remove('backgroundImageBytes');
    output.remove('imageBase64');
    if (output.containsKey('useImage')) {
      output['useImage'] = false;
    }
    if (output.containsKey('themeBackgroundSource')) {
      output['themeBackgroundSource'] = 'solid';
    }
    return output;
  }

  static Map<String, Object?> _sanitizeCornerConfig(
    Map<String, Object?> input,
  ) {
    final output = Map<String, Object?>.from(input);
    final overrides = output['overrides'];
    if (overrides is! List) {
      return output;
    }
    final sanitizedOverrides = <Object?>[];
    for (final entry in overrides) {
      if (entry is! Map) {
        continue;
      }
      final shortcut = <String, Object?>{};
      final keyId = entry['keyId']?.toString();
      final slot = entry['slot']?.toString();
      final disabled = entry['disabled'] == true;
      final sensitive = entry['sensitive'] == true;
      final expression = entry['expression']?.toString() ?? '';
      final hasSensitiveExpression = _looksSensitiveExpression(expression);
      if (keyId != null && keyId.isNotEmpty) {
        shortcut['keyId'] = keyId;
      }
      if (slot != null && slot.isNotEmpty) {
        shortcut['slot'] = slot;
      }
      if (sensitive || hasSensitiveExpression) {
        shortcut['disabled'] = true;
        shortcut['sensitive'] = true;
        shortcut['redacted'] = true;
      } else {
        shortcut['disabled'] = disabled;
        shortcut['sensitive'] = false;
        if (!disabled && expression.isNotEmpty) {
          shortcut['expression'] = expression;
        }
        final label = entry['label']?.toString().trim();
        if (label != null && label.isNotEmpty) {
          shortcut['label'] = label;
        }
      }
      sanitizedOverrides.add(shortcut);
    }
    output['overrides'] = sanitizedOverrides;
    return output;
  }

  static bool _looksSensitiveExpression(String expression) {
    final lowered = expression.toLowerCase();
    return lowered.contains('clipboard') ||
        lowered.contains('snippet') ||
        lowered.contains('voice') ||
        lowered.contains('token') ||
        lowered.contains('secret') ||
        lowered.contains('/storage/') ||
        lowered.contains('/data/') ||
        lowered.contains('file://');
  }

  static int estimatePayloadBytes(Map<String, Object?> payload) {
    return utf8.encode(jsonEncode(payload)).length;
  }
}
