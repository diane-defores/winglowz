import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/settings_store.dart';
import '../domain/user_retention_policy.dart';

class LocalSettingsStore implements SettingsStore {
  LocalSettingsStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _themeModeKey = 'settings_theme_mode';
  static const _retentionPolicyKey = 'settings_retention_policy';
  static const _clipboardAutoSyncKey = 'settings_clipboard_auto_sync';
  static const _transcriptionSyncKey = 'settings_transcription_sync';
  static const _onboardingCompletedKey = 'settings_onboarding_completed';
  static const _onboardingCurrentStepKey = 'settings_onboarding_current_step';
  static const _onboardingLastSeenAtKey = 'settings_onboarding_last_seen_at';
  static const _onboardingAccessibilitySkippedKey =
      'settings_onboarding_accessibility_skipped';
  static const _onboardingMicrophoneSkippedKey =
      'settings_onboarding_microphone_skipped';

  final FlutterSecureStorage _storage;
  final _controller = StreamController<UserSettingsSnapshot>.broadcast();

  @override
  Future<UserSettingsSnapshot> load() async {
    final themeMode = _themeModeFromValue(await _read(_themeModeKey));
    final retentionPolicy = UserRetentionPolicy.fromValue(
      await _read(_retentionPolicyKey) ?? UserRetentionPolicy.sevenDays.value,
    );
    final clipboardAutoSync = _boolFromValue(
      await _read(_clipboardAutoSyncKey),
      fallback: true,
    );
    final transcriptionSync = _boolFromValue(
      await _read(_transcriptionSyncKey),
      fallback: true,
    );
    final onboardingCompleted = _boolFromValue(
      await _read(_onboardingCompletedKey),
      fallback: false,
    );
    final onboardingCurrentStep = _intFromValue(
      await _read(_onboardingCurrentStepKey),
      fallback: 0,
    );
    final onboardingLastSeenAt = _dateFromValue(await _read(_onboardingLastSeenAtKey));
    final onboardingAccessibilitySkipped = _boolFromValue(
      await _read(_onboardingAccessibilitySkippedKey),
      fallback: false,
    );
    final onboardingMicrophoneSkipped = _boolFromValue(
      await _read(_onboardingMicrophoneSkippedKey),
      fallback: false,
    );

    return UserSettingsSnapshot.defaults().copyWith(
      themeMode: themeMode,
      retentionPolicy: retentionPolicy,
      clipboardAutoSync: clipboardAutoSync,
      transcriptionSync: transcriptionSync,
      onboardingCompleted: onboardingCompleted,
      onboardingCurrentStep: onboardingCurrentStep,
      onboardingLastSeenAt: onboardingLastSeenAt,
      onboardingAccessibilitySkipped: onboardingAccessibilitySkipped,
      onboardingMicrophoneSkipped: onboardingMicrophoneSkipped,
    );
  }

  @override
  Future<void> save(UserSettingsSnapshot settings) async {
    await _write(_themeModeKey, settings.themeMode.name);
    await _write(_retentionPolicyKey, settings.retentionPolicy.value);
    await _write(_clipboardAutoSyncKey, settings.clipboardAutoSync.toString());
    await _write(_transcriptionSyncKey, settings.transcriptionSync.toString());
    await _write(_onboardingCompletedKey, settings.onboardingCompleted.toString());
    await _write(_onboardingCurrentStepKey, settings.onboardingCurrentStep.toString());
    await _write(
      _onboardingLastSeenAtKey,
      settings.onboardingLastSeenAt?.toUtc().toIso8601String(),
    );
    await _write(
      _onboardingAccessibilitySkippedKey,
      settings.onboardingAccessibilitySkipped.toString(),
    );
    await _write(
      _onboardingMicrophoneSkippedKey,
      settings.onboardingMicrophoneSkipped.toString(),
    );
    _controller.add(settings);
  }

  @override
  Stream<UserSettingsSnapshot> watch() async* {
    yield await load();
    yield* _controller.stream;
  }

  Future<String?> _read(String key) async {
    try {
      return _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  Future<void> _write(String key, String? value) async {
    try {
      if (value == null) {
        return;
      }
      await _storage.write(key: key, value: value);
    } catch (_) {
      // Local settings are best-effort so UI development never crashes when
      // platform secure storage is unavailable.
    }
  }

  static ThemeMode _themeModeFromValue(String? value) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  static bool _boolFromValue(String? value, {required bool fallback}) {
    if (value == null) {
      return fallback;
    }
    return value == 'true';
  }

  static int _intFromValue(String? value, {required int fallback}) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null) {
      return fallback;
    }
    return parsed < 0 ? 0 : parsed;
  }

  static DateTime? _dateFromValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value)?.toUtc();
  }
}
