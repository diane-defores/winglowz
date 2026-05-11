import 'package:flutter/material.dart';

import '../../../core/sync/sync_status.dart';
import 'user_retention_policy.dart';

class UserSettingsSnapshot {
  const UserSettingsSnapshot({
    required this.themeMode,
    required this.retentionPolicy,
    required this.clipboardAutoSync,
    required this.transcriptionSync,
    required this.syncStatus,
    this.onboardingCompleted = false,
    this.onboardingCurrentStep = 0,
    this.onboardingLastSeenAt,
    this.onboardingAccessibilitySkipped = false,
    this.onboardingMicrophoneSkipped = false,
    this.updatedAt,
  });

  const UserSettingsSnapshot.defaults()
    : themeMode = ThemeMode.system,
      retentionPolicy = UserRetentionPolicy.sevenDays,
      clipboardAutoSync = true,
      transcriptionSync = true,
      syncStatus = const SyncStatus.localOnly(),
      onboardingCompleted = false,
      onboardingCurrentStep = 0,
      onboardingLastSeenAt = null,
      onboardingAccessibilitySkipped = false,
      onboardingMicrophoneSkipped = false,
      updatedAt = null;

  final ThemeMode themeMode;
  final UserRetentionPolicy retentionPolicy;
  final bool clipboardAutoSync;
  final bool transcriptionSync;
  final SyncStatus syncStatus;
  final bool onboardingCompleted;
  final int onboardingCurrentStep;
  final DateTime? onboardingLastSeenAt;
  final bool onboardingAccessibilitySkipped;
  final bool onboardingMicrophoneSkipped;
  final DateTime? updatedAt;

  UserSettingsSnapshot copyWith({
    ThemeMode? themeMode,
    UserRetentionPolicy? retentionPolicy,
    bool? clipboardAutoSync,
    bool? transcriptionSync,
    SyncStatus? syncStatus,
    bool? onboardingCompleted,
    int? onboardingCurrentStep,
    DateTime? onboardingLastSeenAt,
    bool? onboardingAccessibilitySkipped,
    bool? onboardingMicrophoneSkipped,
    DateTime? updatedAt,
  }) {
    return UserSettingsSnapshot(
      themeMode: themeMode ?? this.themeMode,
      retentionPolicy: retentionPolicy ?? this.retentionPolicy,
      clipboardAutoSync: clipboardAutoSync ?? this.clipboardAutoSync,
      transcriptionSync: transcriptionSync ?? this.transcriptionSync,
      syncStatus: syncStatus ?? this.syncStatus,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      onboardingCurrentStep: onboardingCurrentStep ?? this.onboardingCurrentStep,
      onboardingLastSeenAt: onboardingLastSeenAt ?? this.onboardingLastSeenAt,
      onboardingAccessibilitySkipped:
          onboardingAccessibilitySkipped ?? this.onboardingAccessibilitySkipped,
      onboardingMicrophoneSkipped:
          onboardingMicrophoneSkipped ?? this.onboardingMicrophoneSkipped,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

abstract class SettingsStore {
  Future<UserSettingsSnapshot> load();

  Future<void> save(UserSettingsSnapshot settings);

  Stream<UserSettingsSnapshot> watch();
}
