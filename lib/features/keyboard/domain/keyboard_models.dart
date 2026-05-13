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
