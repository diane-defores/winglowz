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

enum KeyboardThemePressEffect {
  none,
  scale,
  pulse,
  shake,
  ripple,
  glow,
  confettiLite,
  fireworksLite;

  static KeyboardThemePressEffect fromName(String value) {
    return KeyboardThemePressEffect.values.firstWhere(
      (effect) => effect.name == value,
      orElse: () => KeyboardThemePressEffect.none,
    );
  }
}

enum KeyboardThemeGradientStyle {
  linear,
  radial;

  static KeyboardThemeGradientStyle fromName(String value) {
    return KeyboardThemeGradientStyle.values.firstWhere(
      (style) => style.name == value,
      orElse: () => KeyboardThemeGradientStyle.linear,
    );
  }
}

enum KeyboardThemeEffectEasing {
  easeOut,
  linear,
  spring;

  static KeyboardThemeEffectEasing fromName(String value) {
    return KeyboardThemeEffectEasing.values.firstWhere(
      (easing) => easing.name == value,
      orElse: () => KeyboardThemeEffectEasing.easeOut,
    );
  }
}

class KeyboardThemePreset {
  const KeyboardThemePreset({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;
}

class KeyboardThemePresetCatalog {
  const KeyboardThemePresetCatalog._();

  static const system = 'system';
  static const winflowzLight = 'winflowz_light';
  static const winflowzDark = 'winflowz_dark';
  static const neonTerminal = 'neon_terminal';
  static const glassMint = 'glass_mint';
  static const sunsetGradient = 'sunset_gradient';
  static const midnightAurora = 'midnight_aurora';
  static const paperInk = 'paper_ink';
  static const pixelCandy = 'pixel_candy';
  static const minimalContrast = 'minimal_contrast';

  static const presets = [
    KeyboardThemePreset(
      id: system,
      name: 'System',
      description: 'Follows the current app and Android theme.',
    ),
    KeyboardThemePreset(
      id: winflowzLight,
      name: 'WinFlowz Light',
      description: 'Clean light keyboard with green action keys.',
    ),
    KeyboardThemePreset(
      id: winflowzDark,
      name: 'WinFlowz Dark',
      description: 'Dark low-glare WinFlowz palette.',
    ),
    KeyboardThemePreset(
      id: neonTerminal,
      name: 'Neon Terminal',
      description: 'Deep terminal background with electric accents.',
    ),
    KeyboardThemePreset(
      id: glassMint,
      name: 'Glass Mint',
      description: 'Soft translucent mint with rounded glass keys.',
    ),
    KeyboardThemePreset(
      id: sunsetGradient,
      name: 'Sunset Gradient',
      description: 'Warm gradient with coral active keys.',
    ),
    KeyboardThemePreset(
      id: midnightAurora,
      name: 'Midnight Aurora',
      description: 'Radial aurora glow on a midnight base.',
    ),
    KeyboardThemePreset(
      id: paperInk,
      name: 'Paper Ink',
      description: 'Paper-like background and high-contrast ink keys.',
    ),
    KeyboardThemePreset(
      id: pixelCandy,
      name: 'Pixel Candy',
      description: 'Playful candy colors with crisp borders.',
    ),
    KeyboardThemePreset(
      id: minimalContrast,
      name: 'Minimal Contrast',
      description: 'Simple high-contrast palette for readability.',
    ),
  ];

  static KeyboardThemeConfig configFor(String presetId) {
    final base = KeyboardThemeConfig.defaults().copyWith(
      presetId: presetId,
      useImage: false,
      backgroundImagePath: null,
      pressEffect: KeyboardThemePressEffect.none,
    );
    return switch (presetId) {
      system => KeyboardThemeConfig.defaults(),
      winflowzLight => base,
      winflowzDark => base.copyWith(
        backgroundStartColor: 0xFF121815,
        backgroundEndColor: 0xFF121815,
        keyColor: 0xFF232B27,
        specialKeyColor: 0xFF2E3833,
        activeKeyColor: 0xFF36B384,
        pressedKeyColor: 0xFF43524B,
        textColor: 0xFFEBF2EE,
        cornerTextColor: 0xFFB7C8BF,
        statusTextColor: 0xFFCCD9D2,
        borderColor: 0xFF516158,
        shadowColor: 0x66000000,
      ),
      neonTerminal => base.copyWith(
        backgroundStartColor: 0xFF07120F,
        backgroundEndColor: 0xFF12241E,
        useGradient: true,
        keyColor: 0xFF0D1C18,
        specialKeyColor: 0xFF143127,
        activeKeyColor: 0xFF00F5A0,
        pressedKeyColor: 0xFF1D4D3C,
        textColor: 0xFFE9FFF6,
        cornerTextColor: 0xFF7CFFD3,
        statusTextColor: 0xFFB8FFE8,
        borderColor: 0xFF00A76E,
        shadowColor: 0x8800F5A0,
        shadowBlur: 7,
        pressEffect: KeyboardThemePressEffect.glow,
      ),
      glassMint => base.copyWith(
        backgroundStartColor: 0xFFDFFAF0,
        backgroundEndColor: 0xFFBEEBD9,
        useGradient: true,
        keyColor: 0xCCFFFFFF,
        specialKeyColor: 0xBFE5FFF6,
        activeKeyColor: 0xFF168765,
        pressedKeyColor: 0xFFD0EEE3,
        textColor: 0xFF17342B,
        cornerTextColor: 0xFF4F7C6C,
        statusTextColor: 0xFF254C3F,
        borderColor: 0x80FFFFFF,
        keyRadius: 14,
        shadowBlur: 9,
      ),
      sunsetGradient => base.copyWith(
        backgroundStartColor: 0xFFFFC371,
        backgroundEndColor: 0xFFFF5F6D,
        useGradient: true,
        keyColor: 0xFFFFF8EB,
        specialKeyColor: 0xFFFFDEB8,
        activeKeyColor: 0xFF8A1F3D,
        pressedKeyColor: 0xFFFFCFB0,
        textColor: 0xFF3B1820,
        cornerTextColor: 0xFF754252,
        statusTextColor: 0xFF471D28,
        borderColor: 0x33FFFFFF,
        pressEffect: KeyboardThemePressEffect.pulse,
      ),
      midnightAurora => base.copyWith(
        backgroundStartColor: 0xFF07111F,
        backgroundEndColor: 0xFF204B6D,
        useGradient: true,
        gradientStyle: KeyboardThemeGradientStyle.radial,
        keyColor: 0xFF111C2E,
        specialKeyColor: 0xFF1E2E48,
        activeKeyColor: 0xFF64D2FF,
        pressedKeyColor: 0xFF2D4667,
        textColor: 0xFFEAF7FF,
        cornerTextColor: 0xFFA7DFFF,
        statusTextColor: 0xFFD7F0FF,
        borderColor: 0xFF3B6D8D,
        shadowColor: 0x995BD6FF,
        pressEffect: KeyboardThemePressEffect.ripple,
      ),
      paperInk => base.copyWith(
        backgroundStartColor: 0xFFF5EFE2,
        backgroundEndColor: 0xFFF5EFE2,
        keyColor: 0xFFFFFCF4,
        specialKeyColor: 0xFFE9DDC9,
        activeKeyColor: 0xFF2D2A26,
        pressedKeyColor: 0xFFE1D2BB,
        textColor: 0xFF1D1A16,
        cornerTextColor: 0xFF6A5D4A,
        statusTextColor: 0xFF40382D,
        borderColor: 0xFFB9A98F,
        shadowColor: 0x33000000,
        shadowBlur: 3,
      ),
      pixelCandy => base.copyWith(
        backgroundStartColor: 0xFFFFE0F1,
        backgroundEndColor: 0xFFD4F1FF,
        useGradient: true,
        keyColor: 0xFFFFFFFF,
        specialKeyColor: 0xFFFFC6E2,
        activeKeyColor: 0xFF005A9C,
        pressedKeyColor: 0xFFFFD166,
        textColor: 0xFF15213A,
        cornerTextColor: 0xFF37527A,
        statusTextColor: 0xFF1A3150,
        borderColor: 0xFF15213A,
        borderWidth: 1.5,
        keyRadius: 5,
        shadowBlur: 1,
        pressEffect: KeyboardThemePressEffect.confettiLite,
      ),
      minimalContrast => base.copyWith(
        backgroundStartColor: 0xFF000000,
        backgroundEndColor: 0xFF000000,
        keyColor: 0xFFFFFFFF,
        specialKeyColor: 0xFFE8E8E8,
        activeKeyColor: 0xFFFFFF00,
        pressedKeyColor: 0xFFCFCFCF,
        textColor: 0xFF000000,
        cornerTextColor: 0xFF303030,
        statusTextColor: 0xFFFFFFFF,
        borderColor: 0xFFFFFFFF,
        borderWidth: 1,
        shadowBlur: 0,
      ),
      _ => KeyboardThemeConfig.defaults(),
    };
  }
}

class KeyboardThemeConfig {
  const KeyboardThemeConfig({
    required this.version,
    required this.presetId,
    required this.backgroundStartColor,
    required this.backgroundEndColor,
    required this.useGradient,
    required this.gradientStyle,
    required this.useImage,
    required this.backgroundImagePath,
    required this.keyColor,
    required this.specialKeyColor,
    required this.activeKeyColor,
    required this.pressedKeyColor,
    required this.textColor,
    required this.cornerTextColor,
    required this.statusTextColor,
    required this.borderColor,
    required this.borderWidth,
    required this.keyRadius,
    required this.shadowColor,
    required this.shadowBlur,
    required this.shadowOffsetY,
    required this.pressEffect,
    required this.effectIntensity,
    required this.effectDurationMs,
    required this.effectEasing,
  });

  final int version;
  final String presetId;
  final int backgroundStartColor;
  final int backgroundEndColor;
  final bool useGradient;
  final KeyboardThemeGradientStyle gradientStyle;
  final bool useImage;
  final String? backgroundImagePath;
  final int keyColor;
  final int specialKeyColor;
  final int activeKeyColor;
  final int pressedKeyColor;
  final int textColor;
  final int cornerTextColor;
  final int statusTextColor;
  final int borderColor;
  final double borderWidth;
  final double keyRadius;
  final int shadowColor;
  final double shadowBlur;
  final double shadowOffsetY;
  final KeyboardThemePressEffect pressEffect;
  final double effectIntensity;
  final int effectDurationMs;
  final KeyboardThemeEffectEasing effectEasing;

  factory KeyboardThemeConfig.defaults() {
    return const KeyboardThemeConfig(
      version: 1,
      presetId: KeyboardThemePresetCatalog.system,
      backgroundStartColor: 0xFFEEF1EE,
      backgroundEndColor: 0xFFEEF1EE,
      useGradient: false,
      gradientStyle: KeyboardThemeGradientStyle.linear,
      useImage: false,
      backgroundImagePath: null,
      keyColor: 0xFFFFFFFF,
      specialKeyColor: 0xFFE0E6E3,
      activeKeyColor: 0xFF17795D,
      pressedKeyColor: 0xFFCADAD3,
      textColor: 0xFF1D2320,
      cornerTextColor: 0xFF5C6762,
      statusTextColor: 0xFF333D38,
      borderColor: 0x00000000,
      borderWidth: 0,
      keyRadius: 8,
      shadowColor: 0x33000000,
      shadowBlur: 4,
      shadowOffsetY: 1,
      pressEffect: KeyboardThemePressEffect.none,
      effectIntensity: 0.35,
      effectDurationMs: 170,
      effectEasing: KeyboardThemeEffectEasing.easeOut,
    );
  }

  factory KeyboardThemeConfig.fromMap(Map<Object?, Object?> map) {
    int asColor(Object? value, int fallback) {
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        final normalized = value.replaceFirst('#', '');
        final parsed = int.tryParse(normalized, radix: 16);
        if (parsed != null) {
          return normalized.length <= 6 ? (0xFF000000 | parsed) : parsed;
        }
      }
      return fallback;
    }

    final defaults = KeyboardThemeConfig.defaults();
    return KeyboardThemeConfig(
      version: (map['version'] as num?)?.toInt() ?? 1,
      presetId: map['presetId'] as String? ?? defaults.presetId,
      backgroundStartColor: asColor(
        map['backgroundStartColor'],
        defaults.backgroundStartColor,
      ),
      backgroundEndColor: asColor(
        map['backgroundEndColor'],
        defaults.backgroundEndColor,
      ),
      useGradient: map['useGradient'] as bool? ?? defaults.useGradient,
      gradientStyle: KeyboardThemeGradientStyle.fromName(
        map['gradientStyle'] as String? ?? defaults.gradientStyle.name,
      ),
      useImage: map['useImage'] as bool? ?? defaults.useImage,
      backgroundImagePath: map['backgroundImagePath'] as String?,
      keyColor: asColor(map['keyColor'], defaults.keyColor),
      specialKeyColor: asColor(
        map['specialKeyColor'],
        defaults.specialKeyColor,
      ),
      activeKeyColor: asColor(map['activeKeyColor'], defaults.activeKeyColor),
      pressedKeyColor: asColor(
        map['pressedKeyColor'],
        defaults.pressedKeyColor,
      ),
      textColor: asColor(map['textColor'], defaults.textColor),
      cornerTextColor: asColor(
        map['cornerTextColor'],
        defaults.cornerTextColor,
      ),
      statusTextColor: asColor(
        map['statusTextColor'],
        defaults.statusTextColor,
      ),
      borderColor: asColor(map['borderColor'], defaults.borderColor),
      borderWidth:
          ((map['borderWidth'] as num?)?.toDouble() ?? defaults.borderWidth)
              .clamp(0.0, 4.0),
      keyRadius: ((map['keyRadius'] as num?)?.toDouble() ?? defaults.keyRadius)
          .clamp(0.0, 24.0),
      shadowColor: asColor(map['shadowColor'], defaults.shadowColor),
      shadowBlur:
          ((map['shadowBlur'] as num?)?.toDouble() ?? defaults.shadowBlur)
              .clamp(0.0, 18.0),
      shadowOffsetY:
          ((map['shadowOffsetY'] as num?)?.toDouble() ?? defaults.shadowOffsetY)
              .clamp(-4.0, 10.0),
      pressEffect: KeyboardThemePressEffect.fromName(
        map['pressEffect'] as String? ?? defaults.pressEffect.name,
      ),
      effectIntensity:
          ((map['effectIntensity'] as num?)?.toDouble() ??
                  defaults.effectIntensity)
              .clamp(0.0, 1.0),
      effectDurationMs:
          ((map['effectDurationMs'] as num?)?.toInt() ??
                  defaults.effectDurationMs)
              .clamp(80, 600),
      effectEasing: KeyboardThemeEffectEasing.fromName(
        map['effectEasing'] as String? ?? defaults.effectEasing.name,
      ),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'version': version,
      'presetId': presetId,
      'backgroundStartColor': backgroundStartColor,
      'backgroundEndColor': backgroundEndColor,
      'useGradient': useGradient,
      'gradientStyle': gradientStyle.name,
      'useImage': useImage,
      if (backgroundImagePath != null)
        'backgroundImagePath': backgroundImagePath,
      'keyColor': keyColor,
      'specialKeyColor': specialKeyColor,
      'activeKeyColor': activeKeyColor,
      'pressedKeyColor': pressedKeyColor,
      'textColor': textColor,
      'cornerTextColor': cornerTextColor,
      'statusTextColor': statusTextColor,
      'borderColor': borderColor,
      'borderWidth': borderWidth,
      'keyRadius': keyRadius,
      'shadowColor': shadowColor,
      'shadowBlur': shadowBlur,
      'shadowOffsetY': shadowOffsetY,
      'pressEffect': pressEffect.name,
      'effectIntensity': effectIntensity,
      'effectDurationMs': effectDurationMs,
      'effectEasing': effectEasing.name,
    };
  }

  KeyboardThemeConfig copyWith({
    int? version,
    String? presetId,
    int? backgroundStartColor,
    int? backgroundEndColor,
    bool? useGradient,
    KeyboardThemeGradientStyle? gradientStyle,
    bool? useImage,
    String? backgroundImagePath,
    int? keyColor,
    int? specialKeyColor,
    int? activeKeyColor,
    int? pressedKeyColor,
    int? textColor,
    int? cornerTextColor,
    int? statusTextColor,
    int? borderColor,
    double? borderWidth,
    double? keyRadius,
    int? shadowColor,
    double? shadowBlur,
    double? shadowOffsetY,
    KeyboardThemePressEffect? pressEffect,
    double? effectIntensity,
    int? effectDurationMs,
    KeyboardThemeEffectEasing? effectEasing,
  }) {
    return KeyboardThemeConfig(
      version: version ?? this.version,
      presetId: presetId ?? this.presetId,
      backgroundStartColor: backgroundStartColor ?? this.backgroundStartColor,
      backgroundEndColor: backgroundEndColor ?? this.backgroundEndColor,
      useGradient: useGradient ?? this.useGradient,
      gradientStyle: gradientStyle ?? this.gradientStyle,
      useImage: useImage ?? this.useImage,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      keyColor: keyColor ?? this.keyColor,
      specialKeyColor: specialKeyColor ?? this.specialKeyColor,
      activeKeyColor: activeKeyColor ?? this.activeKeyColor,
      pressedKeyColor: pressedKeyColor ?? this.pressedKeyColor,
      textColor: textColor ?? this.textColor,
      cornerTextColor: cornerTextColor ?? this.cornerTextColor,
      statusTextColor: statusTextColor ?? this.statusTextColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      keyRadius: keyRadius ?? this.keyRadius,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowBlur: shadowBlur ?? this.shadowBlur,
      shadowOffsetY: shadowOffsetY ?? this.shadowOffsetY,
      pressEffect: pressEffect ?? this.pressEffect,
      effectIntensity: effectIntensity ?? this.effectIntensity,
      effectDurationMs: effectDurationMs ?? this.effectDurationMs,
      effectEasing: effectEasing ?? this.effectEasing,
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
    KeyboardConfigurableKey(
      id: 'mode-ABC',
      label: 'ABC',
      row: -1,
      special: true,
      description: 'Letters mode action',
    ),
    KeyboardConfigurableKey(
      id: 'mode-123',
      label: '123',
      row: -1,
      special: true,
      description: 'Numbers mode action',
    ),
    KeyboardConfigurableKey(
      id: 'panel-Acc',
      label: 'Acc',
      row: -1,
      special: true,
      description: 'Accent panel action',
    ),
    KeyboardConfigurableKey(
      id: 'mode-#+=',
      label: '#+=',
      row: -1,
      special: true,
      description: 'Symbols mode action',
    ),
    KeyboardConfigurableKey(
      id: 'panel-Nav',
      label: 'Nav',
      row: -1,
      special: true,
      description: 'Navigation panel action',
    ),
    KeyboardConfigurableKey(
      id: 'panel-Emoji',
      label: 'Emoji',
      row: -1,
      special: true,
      description: 'Emoji panel action',
    ),
    KeyboardConfigurableKey(
      id: 'panel-Clip',
      label: 'Clip',
      row: -1,
      special: true,
      description: 'Clipboard panel action',
    ),
    KeyboardConfigurableKey(
      id: 'panel-Snip',
      label: 'Snip',
      row: -1,
      special: true,
      description: 'Snippets panel action',
    ),
    KeyboardConfigurableKey(
      id: 'panel-Media',
      label: 'Media',
      row: -1,
      special: true,
      description: 'Media panel action',
    ),
    KeyboardConfigurableKey(
      id: 'panel-Prefs',
      label: 'Prefs',
      row: -1,
      special: true,
      description: 'Keyboard preferences panel action',
    ),
    KeyboardConfigurableKey(
      id: 'voice',
      label: 'Mic',
      row: -1,
      special: true,
      description: 'Voice action',
    ),
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
    required this.themeMode,
    required this.themePresetId,
    required this.themePressEffect,
    required this.themeBackgroundSource,
    required this.themeConfigSize,
    required this.themeFallbackStatus,
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
    required this.keyboardHeightScale,
    required this.compactModeEnabled,
    required this.privacyMode,
  });

  final bool supported;
  final bool enabled;
  final bool active;
  final bool voiceEnabled;
  final bool clipboardSyncDesired;
  final bool mediaControlsEnabled;
  final String themeMode;
  final String themePresetId;
  final String themePressEffect;
  final String themeBackgroundSource;
  final int themeConfigSize;
  final String themeFallbackStatus;
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
  final double keyboardHeightScale;
  final bool compactModeEnabled;
  final KeyboardPrivacyMode privacyMode;

  factory AndroidKeyboardStatus.unsupported() {
    return const AndroidKeyboardStatus(
      supported: false,
      enabled: false,
      active: false,
      voiceEnabled: false,
      clipboardSyncDesired: false,
      mediaControlsEnabled: false,
      themeMode: 'system',
      themePresetId: 'system',
      themePressEffect: 'none',
      themeBackgroundSource: 'solid',
      themeConfigSize: 0,
      themeFallbackStatus: 'not_supported',
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
      keyboardHeightScale: 1,
      compactModeEnabled: false,
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
      themeMode: map['themeMode'] as String? ?? 'system',
      themePresetId: map['themePresetId'] as String? ?? 'system',
      themePressEffect: map['themePressEffect'] as String? ?? 'none',
      themeBackgroundSource: map['themeBackgroundSource'] as String? ?? 'solid',
      themeConfigSize: (map['themeConfigSize'] as num?)?.toInt() ?? 0,
      themeFallbackStatus: map['themeFallbackStatus'] as String? ?? 'unknown',
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
      keyboardHeightScale:
          ((map['keyboardHeightScale'] as num?)?.toDouble() ?? 1).clamp(
            0.85,
            1.2,
          ),
      compactModeEnabled: map['compactModeEnabled'] as bool? ?? false,
      privacyMode: KeyboardPrivacyMode.fromName(
        map['privacyMode'] as String? ?? KeyboardPrivacyMode.auto.name,
      ),
    );
  }

  Map<String, Object?> toPreferencesMap({
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
    return {
      'voiceEnabled': voiceEnabled ?? this.voiceEnabled,
      'clipboardSyncDesired': clipboardSyncDesired ?? this.clipboardSyncDesired,
      'mediaControlsEnabled': mediaControlsEnabled ?? this.mediaControlsEnabled,
      'themeMode': themeMode ?? this.themeMode,
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
