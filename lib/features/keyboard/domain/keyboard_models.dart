enum KeyboardPrivacyMode {
  auto,
  strict,
  standard;

  static KeyboardPrivacyMode fromName(String value) {
    return KeyboardPrivacyMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => KeyboardPrivacyMode.auto,
    );
  }
}

enum KeyboardLayoutProfile {
  qwerty,
  azerty;

  static KeyboardLayoutProfile fromName(String value) {
    return KeyboardLayoutProfile.values.firstWhere(
      (profile) => profile.name == value.toLowerCase(),
      orElse: () => KeyboardLayoutProfile.qwerty,
    );
  }
}

enum KeyboardCornerSlot {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight;

  static KeyboardCornerSlot fromName(String value) {
    return KeyboardCornerSlot.values.firstWhere(
      (slot) => slot.name == value,
      orElse: () => KeyboardCornerSlot.topLeft,
    );
  }
}

class KeyboardConfigurableKey {
  const KeyboardConfigurableKey({
    required this.id,
    required this.label,
    required this.row,
    this.special = false,
    this.description,
  });

  final String id;
  final String label;
  final int row;
  final bool special;
  final String? description;
}

class KeyboardConfigurableKeyCatalog {
  const KeyboardConfigurableKeyCatalog._();

  static const keys = [
    KeyboardConfigurableKey(id: 'letter-q', label: 'Q', row: 0),
    KeyboardConfigurableKey(id: 'letter-w', label: 'W', row: 0),
    KeyboardConfigurableKey(id: 'letter-e', label: 'E', row: 0),
    KeyboardConfigurableKey(id: 'letter-r', label: 'R', row: 0),
    KeyboardConfigurableKey(id: 'letter-t', label: 'T', row: 0),
    KeyboardConfigurableKey(id: 'letter-y', label: 'Y', row: 0),
    KeyboardConfigurableKey(id: 'letter-u', label: 'U', row: 0),
    KeyboardConfigurableKey(id: 'letter-i', label: 'I', row: 0),
    KeyboardConfigurableKey(id: 'letter-o', label: 'O', row: 0),
    KeyboardConfigurableKey(id: 'letter-p', label: 'P', row: 0),
    KeyboardConfigurableKey(id: 'letter-a', label: 'A', row: 1),
    KeyboardConfigurableKey(id: 'letter-s', label: 'S', row: 1),
    KeyboardConfigurableKey(id: 'letter-d', label: 'D', row: 1),
    KeyboardConfigurableKey(id: 'letter-f', label: 'F', row: 1),
    KeyboardConfigurableKey(id: 'letter-g', label: 'G', row: 1),
    KeyboardConfigurableKey(id: 'letter-h', label: 'H', row: 1),
    KeyboardConfigurableKey(id: 'letter-j', label: 'J', row: 1),
    KeyboardConfigurableKey(id: 'letter-k', label: 'K', row: 1),
    KeyboardConfigurableKey(id: 'letter-l', label: 'L', row: 1),
    KeyboardConfigurableKey(id: 'shift', label: 'Shift', row: 2, special: true),
    KeyboardConfigurableKey(id: 'letter-z', label: 'Z', row: 2),
    KeyboardConfigurableKey(id: 'letter-x', label: 'X', row: 2),
    KeyboardConfigurableKey(id: 'letter-c', label: 'C', row: 2),
    KeyboardConfigurableKey(id: 'letter-v', label: 'V', row: 2),
    KeyboardConfigurableKey(id: 'letter-b', label: 'B', row: 2),
    KeyboardConfigurableKey(id: 'letter-n', label: 'N', row: 2),
    KeyboardConfigurableKey(id: 'letter-m', label: 'M', row: 2),
    KeyboardConfigurableKey(
      id: 'del-letter-row',
      label: 'Back',
      row: 2,
      special: true,
      description: 'Backspace',
    ),
    KeyboardConfigurableKey(
      id: 'modifier-ctrl',
      label: 'Ctrl',
      row: 3,
      special: true,
    ),
    KeyboardConfigurableKey(
      id: 'modifier-alt',
      label: 'Alt',
      row: 3,
      special: true,
    ),
    KeyboardConfigurableKey(
      id: 'modifier-fn',
      label: 'Fn',
      row: 3,
      special: true,
    ),
    KeyboardConfigurableKey(
      id: 'text-comma',
      label: ',',
      row: 3,
      special: true,
    ),
    KeyboardConfigurableKey(id: 'space', label: 'Space', row: 3, special: true),
    KeyboardConfigurableKey(
      id: 'text-period',
      label: '.',
      row: 3,
      special: true,
    ),
    KeyboardConfigurableKey(id: 'enter', label: 'Enter', row: 3, special: true),
  ];

  static KeyboardConfigurableKey byId(String id) {
    return keys.firstWhere((key) => key.id == id, orElse: () => keys.first);
  }

  static bool contains(String id) => keys.any((key) => key.id == id);
}

class AndroidKeyboardCornerShortcut {
  const AndroidKeyboardCornerShortcut({
    required this.keyId,
    required this.slot,
    required this.expression,
    this.label,
    this.sensitive = false,
  });

  final String keyId;
  final KeyboardCornerSlot slot;
  final String expression;
  final String? label;
  final bool sensitive;

  String get displayLabel {
    final explicit = label?.trim();
    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }
    if (expression.startsWith("'") && expression.endsWith("'")) {
      return expression
          .substring(1, expression.length - 1)
          .replaceAll(r"\'", "'")
          .replaceAll(r'\\', r'\');
    }
    final separator = expression.indexOf(':');
    if (separator > 0) {
      return expression.substring(0, separator);
    }
    return expression;
  }

  AndroidKeyboardCornerShortcut copyWith({
    String? keyId,
    KeyboardCornerSlot? slot,
    String? expression,
    String? label,
    bool? sensitive,
  }) {
    return AndroidKeyboardCornerShortcut(
      keyId: keyId ?? this.keyId,
      slot: slot ?? this.slot,
      expression: expression ?? this.expression,
      label: label ?? this.label,
      sensitive: sensitive ?? this.sensitive,
    );
  }

  factory AndroidKeyboardCornerShortcut.fromMap(Map<Object?, Object?> map) {
    return AndroidKeyboardCornerShortcut(
      keyId: map['keyId'] as String? ?? '',
      slot: KeyboardCornerSlot.fromName(map['slot'] as String? ?? ''),
      expression: map['expression'] as String? ?? '',
      label: map['label'] as String?,
      sensitive: map['sensitive'] as bool? ?? false,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'keyId': keyId,
      'slot': slot.name,
      'expression': expression,
      'label': label,
      'sensitive': sensitive,
    };
  }
}

enum KeyboardGuidedActionCategory {
  accent('Accent'),
  punctuation('Punctuation'),
  snippet('Snippet'),
  action('Action'),
  macro('Macro'),
  advancedExpression('Advanced');

  const KeyboardGuidedActionCategory(this.label);

  final String label;
}

class KeyboardGuidedAction {
  const KeyboardGuidedAction({
    required this.category,
    required this.title,
    required this.expression,
    this.label,
    this.description,
    this.sensitive = false,
    this.nativeOnly = false,
    this.specialKeyGated = false,
  });

  final KeyboardGuidedActionCategory category;
  final String title;
  final String expression;
  final String? label;
  final String? description;
  final bool sensitive;
  final bool nativeOnly;
  final bool specialKeyGated;

  AndroidKeyboardCornerShortcut shortcutFor({
    required String keyId,
    required KeyboardCornerSlot slot,
  }) {
    return AndroidKeyboardCornerShortcut(
      keyId: keyId,
      slot: slot,
      expression: expression,
      label: label ?? _shortLabel(title),
      sensitive: sensitive,
    );
  }

  static String quotedTextExpression(String value) {
    final escaped = value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
    return "'$escaped'";
  }

  static String _shortLabel(String value) {
    final trimmed = value.trim();
    if (trimmed.length <= 8) {
      return trimmed;
    }
    return trimmed.substring(0, 8);
  }
}

class KeyboardGuidedActionCatalog {
  const KeyboardGuidedActionCatalog._();

  static const accents = [
    'à',
    'â',
    'ä',
    'æ',
    'é',
    'è',
    'ê',
    'ë',
    'î',
    'ï',
    'ô',
    'ö',
    'ù',
    'û',
    'ü',
    'ç',
    'ñ',
    'ß',
    'œ',
  ];

  static const punctuation = [
    ',',
    '.',
    '?',
    '!',
    "'",
    '"',
    '(',
    ')',
    ':',
    ';',
    '...',
    '--',
    '/',
    r'\',
    '|',
    '~',
    '{',
    '}',
    '[',
    ']',
    '<',
    '>',
    '=',
    '_',
  ];

  static const actions = [
    KeyboardGuidedAction(
      category: KeyboardGuidedActionCategory.action,
      title: 'Undo',
      expression: 'action:Undo',
      nativeOnly: true,
    ),
    KeyboardGuidedAction(
      category: KeyboardGuidedActionCategory.action,
      title: 'Redo',
      expression: 'action:Redo',
      nativeOnly: true,
    ),
    KeyboardGuidedAction(
      category: KeyboardGuidedActionCategory.action,
      title: 'Copy',
      expression: 'action:CopySelection',
      sensitive: true,
      nativeOnly: true,
    ),
    KeyboardGuidedAction(
      category: KeyboardGuidedActionCategory.action,
      title: 'Paste',
      expression: 'action:PasteClipboard',
      sensitive: true,
      nativeOnly: true,
    ),
    KeyboardGuidedAction(
      category: KeyboardGuidedActionCategory.action,
      title: 'Delete word',
      expression: 'action:DeleteWordBefore',
      nativeOnly: true,
    ),
    KeyboardGuidedAction(
      category: KeyboardGuidedActionCategory.action,
      title: 'Move left',
      expression: 'action:NavigateCharLeft',
      nativeOnly: true,
      specialKeyGated: true,
    ),
    KeyboardGuidedAction(
      category: KeyboardGuidedActionCategory.action,
      title: 'Move right',
      expression: 'action:NavigateCharRight',
      nativeOnly: true,
      specialKeyGated: true,
    ),
  ];

  static List<KeyboardGuidedAction> defaultActions() {
    return [
      for (final accent in accents)
        KeyboardGuidedAction(
          category: KeyboardGuidedActionCategory.accent,
          title: accent,
          expression: KeyboardGuidedAction.quotedTextExpression(accent),
          label: accent,
        ),
      for (final sign in punctuation)
        KeyboardGuidedAction(
          category: KeyboardGuidedActionCategory.punctuation,
          title: sign,
          expression: KeyboardGuidedAction.quotedTextExpression(sign),
          label: sign,
        ),
      ...actions,
      const KeyboardGuidedAction(
        category: KeyboardGuidedActionCategory.macro,
        title: 'Select all + copy',
        expression: 'action:SelectAll,action:CopySelection',
        label: 'Copy all',
        sensitive: true,
        nativeOnly: true,
      ),
    ];
  }
}

class KeyboardCornerDraft {
  const KeyboardCornerDraft({
    required this.savedConfig,
    required this.draftConfig,
    required this.selectedKeyId,
    required this.selectedSlot,
    this.validationMessage,
  });

  factory KeyboardCornerDraft.fromConfig(AndroidKeyboardCornerConfig config) {
    return KeyboardCornerDraft(
      savedConfig: config,
      draftConfig: config,
      selectedKeyId: KeyboardConfigurableKeyCatalog.keys.first.id,
      selectedSlot: KeyboardCornerSlot.topLeft,
    );
  }

  final AndroidKeyboardCornerConfig savedConfig;
  final AndroidKeyboardCornerConfig draftConfig;
  final String selectedKeyId;
  final KeyboardCornerSlot selectedSlot;
  final String? validationMessage;

  bool get dirty => !_sameConfig(savedConfig, draftConfig);

  KeyboardCornerDraft copyWith({
    AndroidKeyboardCornerConfig? savedConfig,
    AndroidKeyboardCornerConfig? draftConfig,
    String? selectedKeyId,
    KeyboardCornerSlot? selectedSlot,
    String? validationMessage,
  }) {
    return KeyboardCornerDraft(
      savedConfig: savedConfig ?? this.savedConfig,
      draftConfig: draftConfig ?? this.draftConfig,
      selectedKeyId: selectedKeyId ?? this.selectedKeyId,
      selectedSlot: selectedSlot ?? this.selectedSlot,
      validationMessage: validationMessage,
    );
  }

  KeyboardCornerDraft applyShortcut(AndroidKeyboardCornerShortcut shortcut) {
    return copyWith(
      draftConfig: draftConfig.copyWith(
        overrides: [
          for (final item in draftConfig.overrides)
            if (item.keyId != shortcut.keyId || item.slot != shortcut.slot)
              item,
          shortcut,
        ],
      ),
      validationMessage: null,
    );
  }

  KeyboardCornerDraft resetCorner(String keyId, KeyboardCornerSlot slot) {
    return copyWith(
      draftConfig: draftConfig.copyWith(
        overrides: [
          for (final item in draftConfig.overrides)
            if (item.keyId != keyId || item.slot != slot) item,
        ],
      ),
      validationMessage: null,
    );
  }

  KeyboardCornerDraft resetKey(String keyId) {
    return copyWith(
      draftConfig: draftConfig.copyWith(
        overrides: [
          for (final item in draftConfig.overrides)
            if (item.keyId != keyId) item,
        ],
      ),
      validationMessage: null,
    );
  }

  KeyboardCornerDraft discard() {
    return copyWith(draftConfig: savedConfig, validationMessage: null);
  }

  static bool _sameConfig(
    AndroidKeyboardCornerConfig left,
    AndroidKeyboardCornerConfig right,
  ) {
    if (left.presetId != right.presetId ||
        left.overrides.length != right.overrides.length) {
      return false;
    }
    final leftItems =
        left.overrides.map((item) => item.toMap().toString()).toList()..sort();
    final rightItems =
        right.overrides.map((item) => item.toMap().toString()).toList()..sort();
    for (var index = 0; index < leftItems.length; index++) {
      if (leftItems[index] != rightItems[index]) {
        return false;
      }
    }
    return true;
  }
}

class AndroidKeyboardCornerPreset {
  const AndroidKeyboardCornerPreset({required this.id, required this.name});

  final String id;
  final String name;

  factory AndroidKeyboardCornerPreset.fromMap(Map<Object?, Object?> map) {
    return AndroidKeyboardCornerPreset(
      id: map['id'] as String? ?? KeyboardCornerPresetCatalog.frenchAccents,
      name: map['name'] as String? ?? 'French accents',
    );
  }
}

class AndroidKeyboardCornerConfig {
  const AndroidKeyboardCornerConfig({
    required this.presetId,
    required this.overrides,
    required this.availablePresets,
  });

  final String presetId;
  final List<AndroidKeyboardCornerShortcut> overrides;
  final List<AndroidKeyboardCornerPreset> availablePresets;

  factory AndroidKeyboardCornerConfig.defaults() {
    return AndroidKeyboardCornerConfig(
      presetId: KeyboardCornerPresetCatalog.frenchAccents,
      overrides: const [],
      availablePresets: KeyboardCornerPresetCatalog.presets,
    );
  }

  factory AndroidKeyboardCornerConfig.fromMap(Map<Object?, Object?> map) {
    final rawOverrides = map['overrides'];
    final rawPresets = map['availablePresets'];
    return AndroidKeyboardCornerConfig(
      presetId:
          map['presetId'] as String? ??
          KeyboardCornerPresetCatalog.frenchAccents,
      overrides: rawOverrides is List<Object?>
          ? rawOverrides
                .whereType<Map<Object?, Object?>>()
                .map(AndroidKeyboardCornerShortcut.fromMap)
                .where(
                  (shortcut) =>
                      shortcut.keyId.trim().isNotEmpty &&
                      shortcut.expression.trim().isNotEmpty,
                )
                .toList(growable: false)
          : const [],
      availablePresets: rawPresets is List<Object?>
          ? rawPresets
                .whereType<Map<Object?, Object?>>()
                .map(AndroidKeyboardCornerPreset.fromMap)
                .toList(growable: false)
          : KeyboardCornerPresetCatalog.presets,
    );
  }

  AndroidKeyboardCornerConfig copyWith({
    String? presetId,
    List<AndroidKeyboardCornerShortcut>? overrides,
    List<AndroidKeyboardCornerPreset>? availablePresets,
  }) {
    return AndroidKeyboardCornerConfig(
      presetId: presetId ?? this.presetId,
      overrides: overrides ?? this.overrides,
      availablePresets: availablePresets ?? this.availablePresets,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'version': 1,
      'presetId': presetId,
      'overrides': overrides
          .map((shortcut) => shortcut.toMap())
          .toList(growable: false),
    };
  }
}

class KeyboardCornerPresetCatalog {
  const KeyboardCornerPresetCatalog._();

  static const frenchAccents = 'french_accents';
  static const punctuation = 'punctuation_corners';
  static const frenchPunctuation = 'french_accents_punctuation';
  static const developerSymbols = 'developer_symbols';
  static const none = 'none';

  static const presets = [
    AndroidKeyboardCornerPreset(id: frenchAccents, name: 'French accents'),
    AndroidKeyboardCornerPreset(id: punctuation, name: 'Punctuation corners'),
    AndroidKeyboardCornerPreset(
      id: frenchPunctuation,
      name: 'French accents + punctuation',
    ),
    AndroidKeyboardCornerPreset(
      id: developerSymbols,
      name: 'Developer symbols',
    ),
    AndroidKeyboardCornerPreset(id: none, name: 'No corners'),
  ];

  static List<AndroidKeyboardCornerShortcut> shortcutsFor(String presetId) {
    return switch (presetId) {
      frenchAccents => _frenchAccentShortcuts,
      punctuation => _punctuationShortcuts,
      frenchPunctuation => [
        ..._frenchAccentShortcuts,
        ..._punctuationShortcuts,
      ],
      developerSymbols => _developerShortcuts,
      none => const [],
      _ => _frenchAccentShortcuts,
    };
  }

  static Map<KeyboardCornerSlot, AndroidKeyboardCornerShortcut> resolvedForKey({
    required AndroidKeyboardCornerConfig config,
    required String keyId,
    required bool cornersEnabled,
    required bool specialKeyCornersEnabled,
    required bool privateMode,
    bool specialKey = false,
  }) {
    if (!cornersEnabled || (specialKey && !specialKeyCornersEnabled)) {
      return const {};
    }
    final resolved = <KeyboardCornerSlot, AndroidKeyboardCornerShortcut>{};
    for (final shortcut in shortcutsFor(config.presetId)) {
      if (shortcut.keyId == keyId && _allowedInPreview(shortcut, privateMode)) {
        resolved[shortcut.slot] = shortcut;
      }
    }
    for (final shortcut in config.overrides) {
      if (shortcut.keyId == keyId && _allowedInPreview(shortcut, privateMode)) {
        resolved[shortcut.slot] = shortcut;
      }
    }
    return resolved;
  }

  static bool _allowedInPreview(
    AndroidKeyboardCornerShortcut shortcut,
    bool privateMode,
  ) {
    if (!privateMode) {
      return true;
    }
    if (shortcut.sensitive) {
      return false;
    }
    final expression = shortcut.expression.toLowerCase();
    return !expression.contains('clipboard') &&
        !expression.contains('snippet') &&
        !expression.contains('voice');
  }

  static AndroidKeyboardCornerShortcut _shortcut(
    String keyId,
    KeyboardCornerSlot slot,
    String expression, {
    String? label,
    bool sensitive = false,
  }) {
    return AndroidKeyboardCornerShortcut(
      keyId: keyId,
      slot: slot,
      expression: expression,
      label: label,
      sensitive: sensitive,
    );
  }

  static final _frenchAccentShortcuts = [
    _shortcut('letter-a', KeyboardCornerSlot.topLeft, 'à'),
    _shortcut('letter-a', KeyboardCornerSlot.topRight, 'â'),
    _shortcut('letter-a', KeyboardCornerSlot.bottomLeft, 'ä'),
    _shortcut('letter-a', KeyboardCornerSlot.bottomRight, 'æ'),
    _shortcut('letter-e', KeyboardCornerSlot.topLeft, 'é'),
    _shortcut('letter-e', KeyboardCornerSlot.topRight, 'è'),
    _shortcut('letter-e', KeyboardCornerSlot.bottomLeft, 'ê'),
    _shortcut('letter-e', KeyboardCornerSlot.bottomRight, 'ë'),
    _shortcut('letter-i', KeyboardCornerSlot.topLeft, 'î'),
    _shortcut('letter-i', KeyboardCornerSlot.topRight, 'ï'),
    _shortcut('letter-o', KeyboardCornerSlot.topLeft, 'ô'),
    _shortcut('letter-o', KeyboardCornerSlot.topRight, 'ö'),
    _shortcut('letter-u', KeyboardCornerSlot.topLeft, 'ù'),
    _shortcut('letter-u', KeyboardCornerSlot.topRight, 'û'),
    _shortcut('letter-u', KeyboardCornerSlot.bottomLeft, 'ü'),
    _shortcut('letter-c', KeyboardCornerSlot.topLeft, 'ç'),
    _shortcut('letter-n', KeyboardCornerSlot.topLeft, 'ñ'),
    _shortcut('letter-s', KeyboardCornerSlot.topRight, 'ß'),
  ];

  static final _punctuationShortcuts = [
    _shortcut('letter-j', KeyboardCornerSlot.topLeft, ','),
    _shortcut('letter-j', KeyboardCornerSlot.topRight, '.'),
    _shortcut('letter-j', KeyboardCornerSlot.bottomLeft, '?'),
    _shortcut('letter-j', KeyboardCornerSlot.bottomRight, '!'),
    _shortcut('letter-k', KeyboardCornerSlot.topLeft, r"'\''", label: "'"),
    _shortcut('letter-k', KeyboardCornerSlot.topRight, '"'),
    _shortcut('letter-k', KeyboardCornerSlot.bottomLeft, '('),
    _shortcut('letter-k', KeyboardCornerSlot.bottomRight, ')'),
    _shortcut('letter-l', KeyboardCornerSlot.topLeft, ':'),
    _shortcut('letter-l', KeyboardCornerSlot.topRight, ';'),
    _shortcut('letter-l', KeyboardCornerSlot.bottomLeft, '...'),
    _shortcut('letter-l', KeyboardCornerSlot.bottomRight, '--'),
  ];

  static final _developerShortcuts = [
    _shortcut('letter-f', KeyboardCornerSlot.topLeft, '/'),
    _shortcut('letter-f', KeyboardCornerSlot.topRight, r'\'),
    _shortcut('letter-f', KeyboardCornerSlot.bottomLeft, '|'),
    _shortcut('letter-f', KeyboardCornerSlot.bottomRight, '~'),
    _shortcut('letter-g', KeyboardCornerSlot.topLeft, '{'),
    _shortcut('letter-g', KeyboardCornerSlot.topRight, '}'),
    _shortcut('letter-g', KeyboardCornerSlot.bottomLeft, '['),
    _shortcut('letter-g', KeyboardCornerSlot.bottomRight, ']'),
    _shortcut('letter-h', KeyboardCornerSlot.topLeft, '<'),
    _shortcut('letter-h', KeyboardCornerSlot.topRight, '>'),
    _shortcut('letter-h', KeyboardCornerSlot.bottomLeft, '='),
    _shortcut('letter-h', KeyboardCornerSlot.bottomRight, '_'),
  ];
}

class AndroidKeyboardStatus {
  const AndroidKeyboardStatus({
    required this.supported,
    required this.enabled,
    required this.active,
    required this.voiceEnabled,
    required this.clipboardSyncDesired,
    required this.mediaControlsEnabled,
    required this.layoutProfile,
    required this.cornerModeEnabled,
    required this.cornerPresetId,
    required this.debugTouchOverlayEnabled,
    required this.keyVibrationEnabled,
    required this.keySoundEnabled,
    required this.spellingSuggestionsEnabled,
    required this.specialKeyCornersEnabled,
    required this.frenchLanguageEnabled,
    required this.englishLanguageEnabled,
    required this.doubleSpacePeriodEnabled,
    required this.punctuationAutoSpacingEnabled,
    required this.privacyMode,
  });

  final bool supported;
  final bool enabled;
  final bool active;
  final bool voiceEnabled;
  final bool clipboardSyncDesired;
  final bool mediaControlsEnabled;
  final KeyboardLayoutProfile layoutProfile;
  final bool cornerModeEnabled;
  final String cornerPresetId;
  final bool debugTouchOverlayEnabled;
  final bool keyVibrationEnabled;
  final bool keySoundEnabled;
  final bool spellingSuggestionsEnabled;
  final bool specialKeyCornersEnabled;
  final bool frenchLanguageEnabled;
  final bool englishLanguageEnabled;
  final bool doubleSpacePeriodEnabled;
  final bool punctuationAutoSpacingEnabled;
  final KeyboardPrivacyMode privacyMode;

  factory AndroidKeyboardStatus.unsupported() {
    return const AndroidKeyboardStatus(
      supported: false,
      enabled: false,
      active: false,
      voiceEnabled: false,
      clipboardSyncDesired: false,
      mediaControlsEnabled: false,
      layoutProfile: KeyboardLayoutProfile.qwerty,
      cornerModeEnabled: false,
      cornerPresetId: KeyboardCornerPresetCatalog.frenchAccents,
      debugTouchOverlayEnabled: false,
      keyVibrationEnabled: true,
      keySoundEnabled: false,
      spellingSuggestionsEnabled: true,
      specialKeyCornersEnabled: false,
      frenchLanguageEnabled: true,
      englishLanguageEnabled: true,
      doubleSpacePeriodEnabled: true,
      punctuationAutoSpacingEnabled: false,
      privacyMode: KeyboardPrivacyMode.auto,
    );
  }

  factory AndroidKeyboardStatus.fromMap(Map<Object?, Object?> map) {
    return AndroidKeyboardStatus(
      supported: map['supported'] as bool? ?? false,
      enabled: map['enabled'] as bool? ?? false,
      active: map['active'] as bool? ?? false,
      voiceEnabled: map['voiceEnabled'] as bool? ?? true,
      clipboardSyncDesired: map['clipboardSyncDesired'] as bool? ?? false,
      mediaControlsEnabled: map['mediaControlsEnabled'] as bool? ?? true,
      layoutProfile: KeyboardLayoutProfile.fromName(
        map['layoutProfile'] as String? ?? KeyboardLayoutProfile.qwerty.name,
      ),
      cornerModeEnabled: map['cornerModeEnabled'] as bool? ?? false,
      cornerPresetId:
          map['cornerPresetId'] as String? ??
          KeyboardCornerPresetCatalog.frenchAccents,
      debugTouchOverlayEnabled:
          map['debugTouchOverlayEnabled'] as bool? ?? false,
      keyVibrationEnabled: map['keyVibrationEnabled'] as bool? ?? true,
      keySoundEnabled: map['keySoundEnabled'] as bool? ?? false,
      spellingSuggestionsEnabled:
          map['spellingSuggestionsEnabled'] as bool? ?? true,
      specialKeyCornersEnabled:
          map['specialKeyCornersEnabled'] as bool? ?? false,
      frenchLanguageEnabled: map['frenchLanguageEnabled'] as bool? ?? true,
      englishLanguageEnabled: map['englishLanguageEnabled'] as bool? ?? true,
      doubleSpacePeriodEnabled:
          map['doubleSpacePeriodEnabled'] as bool? ?? true,
      punctuationAutoSpacingEnabled:
          map['punctuationAutoSpacingEnabled'] as bool? ?? false,
      privacyMode: KeyboardPrivacyMode.fromName(
        map['privacyMode'] as String? ?? KeyboardPrivacyMode.auto.name,
      ),
    );
  }

  Map<String, Object?> toPreferencesMap({
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
  }) {
    return {
      'voiceEnabled': voiceEnabled ?? this.voiceEnabled,
      'clipboardSyncDesired': clipboardSyncDesired ?? this.clipboardSyncDesired,
      'mediaControlsEnabled': mediaControlsEnabled ?? this.mediaControlsEnabled,
      'layoutProfile': (layoutProfile ?? this.layoutProfile).name,
      'cornerModeEnabled': cornerModeEnabled ?? this.cornerModeEnabled,
      'debugTouchOverlayEnabled':
          debugTouchOverlayEnabled ?? this.debugTouchOverlayEnabled,
      'keyVibrationEnabled': keyVibrationEnabled ?? this.keyVibrationEnabled,
      'keySoundEnabled': keySoundEnabled ?? this.keySoundEnabled,
      'spellingSuggestionsEnabled':
          spellingSuggestionsEnabled ?? this.spellingSuggestionsEnabled,
      'specialKeyCornersEnabled':
          specialKeyCornersEnabled ?? this.specialKeyCornersEnabled,
      'frenchLanguageEnabled':
          frenchLanguageEnabled ?? this.frenchLanguageEnabled,
      'englishLanguageEnabled':
          englishLanguageEnabled ?? this.englishLanguageEnabled,
      'doubleSpacePeriodEnabled':
          doubleSpacePeriodEnabled ?? this.doubleSpacePeriodEnabled,
      'punctuationAutoSpacingEnabled':
          punctuationAutoSpacingEnabled ?? this.punctuationAutoSpacingEnabled,
      'privacyMode': (privacyMode ?? this.privacyMode).name,
    };
  }
}
