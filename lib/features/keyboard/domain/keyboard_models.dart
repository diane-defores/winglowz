import 'dart:ui';

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
  static const winflowz = 'winflowz';
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
      id: winflowz,
      name: 'WinFlowz',
      description: 'Clean WinFlowz keyboard controlled by light or dark mode.',
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

  static KeyboardThemeConfig configFor(
    String presetId, {
    Brightness brightness = Brightness.light,
  }) {
    final normalizedPresetId = switch (presetId) {
      winflowzLight || winflowzDark => winflowz,
      _ => presetId,
    };
    final base = KeyboardThemeConfig.defaults().copyWith(
      presetId: normalizedPresetId,
      useImage: false,
      backgroundImagePath: null,
      pressEffect: KeyboardThemePressEffect.none,
    );
    if (brightness == Brightness.dark) {
      return _darkConfigFor(normalizedPresetId, base);
    }
    return switch (normalizedPresetId) {
      system => KeyboardThemeConfig.defaults(),
      winflowz => base,
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

  static KeyboardThemeConfig _darkConfigFor(
    String presetId,
    KeyboardThemeConfig base,
  ) {
    return switch (presetId) {
      system => KeyboardThemeConfig.defaults(),
      winflowz => base.copyWith(
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
      neonTerminal => configFor(neonTerminal),
      glassMint => base.copyWith(
        backgroundStartColor: 0xFF10251F,
        backgroundEndColor: 0xFF1E4A3C,
        useGradient: true,
        keyColor: 0xCC1A2E28,
        specialKeyColor: 0xCC24463B,
        activeKeyColor: 0xFF7FF0C8,
        pressedKeyColor: 0xFF315F51,
        textColor: 0xFFE8FFF7,
        cornerTextColor: 0xFFA7D8C8,
        statusTextColor: 0xFFC8F5E6,
        borderColor: 0x6635E0AC,
        keyRadius: 14,
        shadowColor: 0x66000000,
        shadowBlur: 9,
      ),
      sunsetGradient => base.copyWith(
        backgroundStartColor: 0xFF351422,
        backgroundEndColor: 0xFF7A2636,
        useGradient: true,
        keyColor: 0xFF2C1B22,
        specialKeyColor: 0xFF4A2630,
        activeKeyColor: 0xFFFFB36E,
        pressedKeyColor: 0xFF6A3542,
        textColor: 0xFFFFF1E6,
        cornerTextColor: 0xFFFFC9B5,
        statusTextColor: 0xFFFFE0D2,
        borderColor: 0x44FFFFFF,
        shadowColor: 0x66000000,
        pressEffect: KeyboardThemePressEffect.pulse,
      ),
      midnightAurora => configFor(midnightAurora),
      paperInk => base.copyWith(
        backgroundStartColor: 0xFF181512,
        backgroundEndColor: 0xFF241F1A,
        keyColor: 0xFF2C2721,
        specialKeyColor: 0xFF3A332A,
        activeKeyColor: 0xFFE9D7B8,
        pressedKeyColor: 0xFF4A4034,
        textColor: 0xFFF7EFE3,
        cornerTextColor: 0xFFC9B99F,
        statusTextColor: 0xFFE6D8C1,
        borderColor: 0xFF756850,
        shadowColor: 0x66000000,
        shadowBlur: 3,
      ),
      pixelCandy => base.copyWith(
        backgroundStartColor: 0xFF27172A,
        backgroundEndColor: 0xFF102840,
        useGradient: true,
        keyColor: 0xFF23172F,
        specialKeyColor: 0xFF472047,
        activeKeyColor: 0xFF66D9FF,
        pressedKeyColor: 0xFF7A4B12,
        textColor: 0xFFFFF4FF,
        cornerTextColor: 0xFFFFBFE2,
        statusTextColor: 0xFFD4F1FF,
        borderColor: 0xFFFFBFE2,
        borderWidth: 1.5,
        keyRadius: 5,
        shadowColor: 0x66000000,
        shadowBlur: 1,
        pressEffect: KeyboardThemePressEffect.confettiLite,
      ),
      minimalContrast => base.copyWith(
        backgroundStartColor: 0xFF000000,
        backgroundEndColor: 0xFF000000,
        keyColor: 0xFF111111,
        specialKeyColor: 0xFF222222,
        activeKeyColor: 0xFFFFFF00,
        pressedKeyColor: 0xFF333333,
        textColor: 0xFFFFFFFF,
        cornerTextColor: 0xFFE0E0E0,
        statusTextColor: 0xFFFFFFFF,
        borderColor: 0xFFFFFFFF,
        borderWidth: 1,
        shadowBlur: 0,
      ),
      _ => KeyboardThemeConfig.defaults(),
    };
  }
}

enum KeyboardStatusBarMode {
  hidden,
  compact,
  standard,
  smart;

  static KeyboardStatusBarMode fromName(String value) {
    return KeyboardStatusBarMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => KeyboardStatusBarMode.smart,
    );
  }
}

enum KeyboardStatusBarModule {
  keyboardLabel,
  date,
  time,
  accountLabel,
  tips;

  static KeyboardStatusBarModule fromName(String value) {
    return KeyboardStatusBarModule.values.firstWhere(
      (module) => module.name == value,
      orElse: () => KeyboardStatusBarModule.keyboardLabel,
    );
  }
}

enum KeyboardStatusBarAccountLabelMode {
  none,
  masked,
  visible;

  static KeyboardStatusBarAccountLabelMode fromName(String value) {
    return KeyboardStatusBarAccountLabelMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => KeyboardStatusBarAccountLabelMode.none,
    );
  }
}

enum KeyboardTipLevel {
  off,
  minimal,
  standard,
  contextual;

  static KeyboardTipLevel fromName(String value) {
    return KeyboardTipLevel.values.firstWhere(
      (level) => level.name == value,
      orElse: () => KeyboardTipLevel.off,
    );
  }
}

class KeyboardStatusBarConfig {
  const KeyboardStatusBarConfig({
    required this.mode,
    required this.modules,
    required this.accountLabelMode,
    required this.tipLevel,
  });

  final KeyboardStatusBarMode mode;
  final List<KeyboardStatusBarModule> modules;
  final KeyboardStatusBarAccountLabelMode accountLabelMode;
  final KeyboardTipLevel tipLevel;

  factory KeyboardStatusBarConfig.defaults() {
    return const KeyboardStatusBarConfig(
      mode: KeyboardStatusBarMode.smart,
      modules: [
        KeyboardStatusBarModule.keyboardLabel,
        KeyboardStatusBarModule.date,
        KeyboardStatusBarModule.time,
        KeyboardStatusBarModule.accountLabel,
      ],
      accountLabelMode: KeyboardStatusBarAccountLabelMode.masked,
      tipLevel: KeyboardTipLevel.standard,
    );
  }

  factory KeyboardStatusBarConfig.fromMap(Map<Object?, Object?> map) {
    final defaults = KeyboardStatusBarConfig.defaults();

    final rawModules =
        (map['modules'] as List<dynamic>?) ??
        (map['module'] != null ? [map['module']] : []);
    final parsedModules = <KeyboardStatusBarModule>[];
    for (final item in rawModules) {
      if (item is String) {
        final module = KeyboardStatusBarModule.fromName(item);
        if (!parsedModules.contains(module)) {
          parsedModules.add(module);
        }
      }
    }

    return KeyboardStatusBarConfig(
      mode: KeyboardStatusBarMode.fromName(
        map['mode'] as String? ?? defaults.mode.name,
      ),
      modules: parsedModules.isEmpty ? defaults.modules : parsedModules,
      accountLabelMode: KeyboardStatusBarAccountLabelMode.fromName(
        map['accountLabelMode'] as String? ?? defaults.accountLabelMode.name,
      ),
      tipLevel: KeyboardTipLevel.fromName(
        map['tipLevel'] as String? ?? defaults.tipLevel.name,
      ),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'mode': mode.name,
      'modules': modules.map((module) => module.name).toList(growable: false),
      'accountLabelMode': accountLabelMode.name,
      'tipLevel': tipLevel.name,
    };
  }

  KeyboardStatusBarConfig copyWith({
    KeyboardStatusBarMode? mode,
    List<KeyboardStatusBarModule>? modules,
    KeyboardStatusBarAccountLabelMode? accountLabelMode,
    KeyboardTipLevel? tipLevel,
  }) {
    return KeyboardStatusBarConfig(
      mode: mode ?? this.mode,
      modules: modules ?? this.modules,
      accountLabelMode: accountLabelMode ?? this.accountLabelMode,
      tipLevel: tipLevel ?? this.tipLevel,
    );
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
    required this.keyHorizontalGap,
    required this.rowVerticalGap,
    required this.keyWidthScale,
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
  final double keyHorizontalGap;
  final double rowVerticalGap;
  final double keyWidthScale;
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
      keyHorizontalGap: 5,
      rowVerticalGap: 5,
      keyWidthScale: 1,
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
    final rawPresetId = map['presetId'] as String? ?? defaults.presetId;
    final presetId = switch (rawPresetId) {
      KeyboardThemePresetCatalog.winflowzLight ||
      KeyboardThemePresetCatalog.winflowzDark =>
        KeyboardThemePresetCatalog.winflowz,
      _ => rawPresetId,
    };
    return KeyboardThemeConfig(
      version: (map['version'] as num?)?.toInt() ?? 1,
      presetId: presetId,
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
      keyHorizontalGap:
          ((map['keyHorizontalGap'] as num?)?.toDouble() ??
                  defaults.keyHorizontalGap)
              .clamp(0.0, 14.0),
      rowVerticalGap:
          ((map['rowVerticalGap'] as num?)?.toDouble() ??
                  defaults.rowVerticalGap)
              .clamp(0.0, 16.0),
      keyWidthScale:
          ((map['keyWidthScale'] as num?)?.toDouble() ?? defaults.keyWidthScale)
              .clamp(0.75, 1.0),
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
      'keyHorizontalGap': keyHorizontalGap,
      'rowVerticalGap': rowVerticalGap,
      'keyWidthScale': keyWidthScale,
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
    double? keyHorizontalGap,
    double? rowVerticalGap,
    double? keyWidthScale,
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
      keyHorizontalGap: keyHorizontalGap ?? this.keyHorizontalGap,
      rowVerticalGap: rowVerticalGap ?? this.rowVerticalGap,
      keyWidthScale: keyWidthScale ?? this.keyWidthScale,
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
  up,
  right,
  down,
  left,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight;

  static KeyboardCornerSlot? tryFromName(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    for (final slot in KeyboardCornerSlot.values) {
      if (slot.name.toLowerCase() == normalized.toLowerCase()) {
        return slot;
      }
    }
    return null;
  }

  static KeyboardCornerSlot fromName(String value) {
    return tryFromName(value) ?? KeyboardCornerSlot.topLeft;
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
    this.disabled = false,
  });

  const AndroidKeyboardCornerShortcut.disabled({
    required this.keyId,
    required this.slot,
  }) : expression = '',
       label = null,
       sensitive = false,
       disabled = true;

  final String keyId;
  final KeyboardCornerSlot slot;
  final String expression;
  final String? label;
  final bool sensitive;
  final bool disabled;

  String get displayLabel {
    if (disabled) {
      return 'tap';
    }
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
    bool? disabled,
  }) {
    return AndroidKeyboardCornerShortcut(
      keyId: keyId ?? this.keyId,
      slot: slot ?? this.slot,
      expression: expression ?? this.expression,
      label: label ?? this.label,
      sensitive: sensitive ?? this.sensitive,
      disabled: disabled ?? this.disabled,
    );
  }

  factory AndroidKeyboardCornerShortcut.fromMap(
    Map<Object?, Object?> map, {
    KeyboardCornerSlot? slot,
  }) {
    return AndroidKeyboardCornerShortcut(
      keyId: map['keyId'] as String? ?? '',
      slot: slot ?? KeyboardCornerSlot.fromName(map['slot'] as String? ?? ''),
      expression: map['expression'] as String? ?? '',
      label: map['label'] as String?,
      sensitive: map['sensitive'] as bool? ?? false,
      disabled: map['disabled'] as bool? ?? false,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'keyId': keyId,
      'slot': slot.name,
      'expression': expression,
      'label': label,
      'sensitive': sensitive,
      'disabled': disabled,
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
          AndroidKeyboardCornerShortcut.disabled(keyId: keyId, slot: slot),
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
          for (final slot in KeyboardCornerSlot.values)
            AndroidKeyboardCornerShortcut.disabled(keyId: keyId, slot: slot),
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
      name: map['name'] as String? ?? 'Smart French',
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
                .map((map) {
                  final slot = KeyboardCornerSlot.tryFromName(
                    map['slot'] as String? ?? '',
                  );
                  if (slot == null) {
                    return null;
                  }
                  return AndroidKeyboardCornerShortcut.fromMap(map, slot: slot);
                })
                .whereType<AndroidKeyboardCornerShortcut>()
                .where(
                  (shortcut) =>
                      shortcut.keyId.trim().isNotEmpty &&
                      (shortcut.disabled ||
                          shortcut.expression.trim().isNotEmpty),
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
    AndroidKeyboardCornerPreset(id: frenchAccents, name: 'Smart French'),
    AndroidKeyboardCornerPreset(
      id: punctuation,
      name: 'Punctuation + navigation',
    ),
    AndroidKeyboardCornerPreset(
      id: frenchPunctuation,
      name: 'French accents + punctuation',
    ),
    AndroidKeyboardCornerPreset(
      id: developerSymbols,
      name: 'Developer symbols',
    ),
    AndroidKeyboardCornerPreset(id: none, name: 'No gestures'),
  ];

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
    for (final shortcut in config.overrides) {
      if (shortcut.keyId != keyId) {
        continue;
      }
      if (shortcut.disabled) {
        resolved.remove(shortcut.slot);
      } else if (_allowedInPreview(shortcut, privateMode)) {
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
}

class AndroidKeyboardStatus {
  const AndroidKeyboardStatus({
    required this.supported,
    required this.enabled,
    required this.active,
    required this.voiceEnabled,
    required this.clipboardSyncDesired,
    required this.mediaControlsEnabled,
    required this.mediaVolumeStepPercent,
    required this.mediaBrightnessStepPercent,
    required this.mediaSessionAccessGranted,
    required this.systemSettingsWriteGranted,
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
    required this.actionRowHeightScale,
    required this.compactModeEnabled,
    required this.autoCloseModesEnabled,
    required this.privacyMode,
    required this.statusBarConfig,
    required this.accountLabel,
    required this.accountLabelMode,
    required this.tipsLastResetAtMs,
    required this.lastKeyboardError,
    required this.lastKeyboardErrorAt,
    required this.keyboardRecoveryCount,
    required this.voiceRuntimeMode,
    required this.voiceLanguageTag,
    required this.voicePackId,
    required this.voiceEngine,
    required this.voiceFallbackReason,
    required this.voiceLastErrorCode,
    required this.deviceAndroidSdk,
    required this.devicePrimaryAbi,
    required this.deviceTotalCapacityMb,
    required this.deviceFreeSpaceMb,
    required this.deviceRamMb,
  });

  final bool supported;
  final bool enabled;
  final bool active;
  final bool voiceEnabled;
  final bool clipboardSyncDesired;
  final bool mediaControlsEnabled;
  final int mediaVolumeStepPercent;
  final int mediaBrightnessStepPercent;
  final bool mediaSessionAccessGranted;
  final bool systemSettingsWriteGranted;
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
  final double actionRowHeightScale;
  final bool compactModeEnabled;
  final bool autoCloseModesEnabled;
  final KeyboardPrivacyMode privacyMode;
  final KeyboardStatusBarConfig statusBarConfig;
  final String? accountLabel;
  final KeyboardStatusBarAccountLabelMode accountLabelMode;
  final int? tipsLastResetAtMs;
  final String? lastKeyboardError;
  final String? lastKeyboardErrorAt;
  final int keyboardRecoveryCount;
  final String voiceRuntimeMode;
  final String voiceLanguageTag;
  final String voicePackId;
  final String voiceEngine;
  final String voiceFallbackReason;
  final String voiceLastErrorCode;
  final int deviceAndroidSdk;
  final String devicePrimaryAbi;
  final int deviceTotalCapacityMb;
  final int deviceFreeSpaceMb;
  final int deviceRamMb;

  factory AndroidKeyboardStatus.unsupported() {
    return AndroidKeyboardStatus(
      supported: false,
      enabled: false,
      active: false,
      voiceEnabled: false,
      clipboardSyncDesired: false,
      mediaControlsEnabled: false,
      mediaVolumeStepPercent: 5,
      mediaBrightnessStepPercent: 10,
      mediaSessionAccessGranted: false,
      systemSettingsWriteGranted: false,
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
      actionRowHeightScale: 1,
      compactModeEnabled: false,
      autoCloseModesEnabled: true,
      privacyMode: KeyboardPrivacyMode.auto,
      statusBarConfig: KeyboardStatusBarConfig.defaults(),
      accountLabel: null,
      accountLabelMode: KeyboardStatusBarAccountLabelMode.none,
      tipsLastResetAtMs: null,
      lastKeyboardError: null,
      lastKeyboardErrorAt: null,
      keyboardRecoveryCount: 0,
      voiceRuntimeMode: 'unavailable',
      voiceLanguageTag: 'und',
      voicePackId: 'none',
      voiceEngine: 'unavailable',
      voiceFallbackReason: 'unsupported_language',
      voiceLastErrorCode: 'keyboard_unsupported',
      deviceAndroidSdk: 0,
      devicePrimaryAbi: 'unsupported',
      deviceTotalCapacityMb: 0,
      deviceFreeSpaceMb: 0,
      deviceRamMb: 0,
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
      mediaVolumeStepPercent:
          ((map['mediaVolumeStepPercent'] as num?)?.toInt() ?? 5)
              .clamp(5, 30)
              .toInt(),
      mediaBrightnessStepPercent:
          ((map['mediaBrightnessStepPercent'] as num?)?.toInt() ?? 10)
              .clamp(5, 30)
              .toInt(),
      mediaSessionAccessGranted:
          map['mediaSessionAccessGranted'] as bool? ?? false,
      systemSettingsWriteGranted:
          map['systemSettingsWriteGranted'] as bool? ?? false,
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
      actionRowHeightScale: _normalizeActionRowHeightScale(
        (map['actionRowHeightScale'] as num?)?.toDouble() ?? 1,
      ),
      compactModeEnabled: map['compactModeEnabled'] as bool? ?? false,
      autoCloseModesEnabled: map['autoCloseModesEnabled'] as bool? ?? true,
      privacyMode: KeyboardPrivacyMode.fromName(
        map['privacyMode'] as String? ?? KeyboardPrivacyMode.auto.name,
      ),
      statusBarConfig: KeyboardStatusBarConfig.fromMap(
        map['statusBarConfig'] is Map<Object?, Object?>
            ? map['statusBarConfig'] as Map<Object?, Object?>
            : const <Object?, Object?>{},
      ),
      accountLabel: _nonEmptyString(map['accountLabel']),
      accountLabelMode: KeyboardStatusBarAccountLabelMode.fromName(
        map['accountLabelMode'] as String? ??
            KeyboardStatusBarAccountLabelMode.none.name,
      ),
      tipsLastResetAtMs: (map['tipsLastResetAtMs'] as num?)?.toInt(),
      lastKeyboardError: _nonEmptyString(map['lastKeyboardError']),
      lastKeyboardErrorAt: _nonEmptyString(map['lastKeyboardErrorAt']),
      keyboardRecoveryCount:
          (map['keyboardRecoveryCount'] as num?)?.toInt() ?? 0,
      voiceRuntimeMode: map['voiceRuntimeMode'] as String? ?? 'unavailable',
      voiceLanguageTag: map['voiceLanguageTag'] as String? ?? 'und',
      voicePackId: map['voicePackId'] as String? ?? 'none',
      voiceEngine: map['voiceEngine'] as String? ?? 'unavailable',
      voiceFallbackReason:
          map['voiceFallbackReason'] as String? ?? 'unsupported_language',
      voiceLastErrorCode: map['voiceLastErrorCode'] as String? ?? 'none',
      deviceAndroidSdk: (map['deviceAndroidSdk'] as num?)?.toInt() ?? 0,
      devicePrimaryAbi: map['devicePrimaryAbi'] as String? ?? 'unknown',
      deviceTotalCapacityMb:
          ((map['deviceTotalCapacityMb'] as num?)?.toInt() ?? 0).clamp(
            0,
            1 << 30,
          ),
      deviceFreeSpaceMb: ((map['deviceFreeSpaceMb'] as num?)?.toInt() ?? 0)
          .clamp(0, 1 << 30),
      deviceRamMb: ((map['deviceRamMb'] as num?)?.toInt() ?? 0).clamp(
        0,
        1 << 30,
      ),
    );
  }

  static String? _nonEmptyString(Object? value) {
    final text = value is String ? value.trim() : '';
    return text.isEmpty ? null : text;
  }

  Map<String, Object?> toPreferencesMap({
    bool? voiceEnabled,
    bool? clipboardSyncDesired,
    bool? mediaControlsEnabled,
    int? mediaVolumeStepPercent,
    int? mediaBrightnessStepPercent,
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
    double? actionRowHeightScale,
    bool? autoCloseModesEnabled,
    KeyboardPrivacyMode? privacyMode,
    KeyboardStatusBarConfig? statusBarConfig,
  }) {
    return {
      'voiceEnabled': voiceEnabled ?? this.voiceEnabled,
      'clipboardSyncDesired': clipboardSyncDesired ?? this.clipboardSyncDesired,
      'mediaControlsEnabled': mediaControlsEnabled ?? this.mediaControlsEnabled,
      'mediaVolumeStepPercent':
          mediaVolumeStepPercent ?? this.mediaVolumeStepPercent,
      'mediaBrightnessStepPercent':
          mediaBrightnessStepPercent ?? this.mediaBrightnessStepPercent,
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
      'actionRowHeightScale': actionRowHeightScale ?? this.actionRowHeightScale,
      'autoCloseModesEnabled':
          autoCloseModesEnabled ?? this.autoCloseModesEnabled,
      'privacyMode': (privacyMode ?? this.privacyMode).name,
      'statusBarConfig': (statusBarConfig ?? this.statusBarConfig).toMap(),
    };
  }

  static double _normalizeActionRowHeightScale(double value) {
    if (value < 0.45) {
      return 0.30;
    }
    if (value < 0.80) {
      return 0.60;
    }
    return 1;
  }
}
