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

class AndroidKeyboardStatus {
  const AndroidKeyboardStatus({
    required this.supported,
    required this.enabled,
    required this.active,
    required this.voiceEnabled,
    required this.clipboardSyncDesired,
    required this.mediaControlsEnabled,
    required this.privacyMode,
  });

  final bool supported;
  final bool enabled;
  final bool active;
  final bool voiceEnabled;
  final bool clipboardSyncDesired;
  final bool mediaControlsEnabled;
  final KeyboardPrivacyMode privacyMode;

  factory AndroidKeyboardStatus.unsupported() {
    return const AndroidKeyboardStatus(
      supported: false,
      enabled: false,
      active: false,
      voiceEnabled: false,
      clipboardSyncDesired: false,
      mediaControlsEnabled: false,
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
      privacyMode: KeyboardPrivacyMode.fromName(
        map['privacyMode'] as String? ?? KeyboardPrivacyMode.auto.name,
      ),
    );
  }

  Map<String, Object?> toPreferencesMap({
    bool? voiceEnabled,
    bool? clipboardSyncDesired,
    bool? mediaControlsEnabled,
    KeyboardPrivacyMode? privacyMode,
  }) {
    return {
      'voiceEnabled': voiceEnabled ?? this.voiceEnabled,
      'clipboardSyncDesired': clipboardSyncDesired ?? this.clipboardSyncDesired,
      'mediaControlsEnabled': mediaControlsEnabled ?? this.mediaControlsEnabled,
      'privacyMode': (privacyMode ?? this.privacyMode).name,
    };
  }
}
