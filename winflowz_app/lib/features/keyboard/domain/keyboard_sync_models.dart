import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:winflowz_app/features/keyboard/domain/keyboard_sync_policy.dart';

enum KeyboardSyncValidationVerdict {
  valid,
  invalidSchemaVersion,
  invalidPayload,
  invalidChecksum,
  oversizedPayload,
}

class KeyboardSyncValidationResult {
  const KeyboardSyncValidationResult({
    required this.verdict,
    required this.errors,
  });

  final KeyboardSyncValidationVerdict verdict;
  final List<String> errors;

  bool get isValid => verdict == KeyboardSyncValidationVerdict.valid;
}

class KeyboardSyncProfile {
  const KeyboardSyncProfile({
    required this.schemaVersion,
    required this.profileRevision,
    required this.baseCloudRevision,
    required this.updatedAt,
    required this.updatedByDeviceId,
    required this.sourcePlatform,
    required this.sanitizationPolicy,
    required this.checksum,
    required this.payload,
  });

  final int schemaVersion;
  final int profileRevision;
  final int baseCloudRevision;
  final String updatedAt;
  final String updatedByDeviceId;
  final String sourcePlatform;
  final String sanitizationPolicy;
  final String checksum;
  final Map<String, Object?> payload;

  factory KeyboardSyncProfile.sanitized({
    required int profileRevision,
    required int baseCloudRevision,
    required String updatedAt,
    required String updatedByDeviceId,
    required String sourcePlatform,
    required Map<String, Object?> rawPayload,
  }) {
    final sanitized = KeyboardSyncPolicyV1.sanitizePayload(rawPayload);
    final checksum = computeChecksum(
      schemaVersion: KeyboardSyncPolicyV1.schemaVersion,
      profileRevision: profileRevision,
      baseCloudRevision: baseCloudRevision,
      updatedAt: updatedAt,
      updatedByDeviceId: updatedByDeviceId,
      sourcePlatform: sourcePlatform,
      sanitizationPolicy: KeyboardSyncPolicyV1.id,
      payload: sanitized,
    );
    return KeyboardSyncProfile(
      schemaVersion: KeyboardSyncPolicyV1.schemaVersion,
      profileRevision: profileRevision,
      baseCloudRevision: baseCloudRevision,
      updatedAt: updatedAt,
      updatedByDeviceId: updatedByDeviceId,
      sourcePlatform: sourcePlatform,
      sanitizationPolicy: KeyboardSyncPolicyV1.id,
      checksum: checksum,
      payload: sanitized,
    );
  }

  static KeyboardSyncProfile fromMap(Map<String, Object?> map) {
    return KeyboardSyncProfile(
      schemaVersion: (map['schemaVersion'] as num?)?.toInt() ?? -1,
      profileRevision: (map['profileRevision'] as num?)?.toInt() ?? 0,
      baseCloudRevision: (map['baseCloudRevision'] as num?)?.toInt() ?? 0,
      updatedAt: map['updatedAt'] as String? ?? '',
      updatedByDeviceId: map['updatedByDeviceId'] as String? ?? '',
      sourcePlatform: map['sourcePlatform'] as String? ?? 'unknown',
      sanitizationPolicy:
          map['sanitizationPolicy'] as String? ?? KeyboardSyncPolicyV1.id,
      checksum: map['checksum'] as String? ?? '',
      payload: (map['payload'] is Map)
          ? Map<String, Object?>.from(map['payload'] as Map)
          : const <String, Object?>{},
    );
  }

  Map<String, Object?> toMap() {
    return {
      'schemaVersion': schemaVersion,
      'profileRevision': profileRevision,
      'baseCloudRevision': baseCloudRevision,
      'updatedAt': updatedAt,
      'updatedByDeviceId': updatedByDeviceId,
      'sourcePlatform': sourcePlatform,
      'sanitizationPolicy': sanitizationPolicy,
      'checksum': checksum,
      'payload': payload,
    };
  }

  KeyboardSyncProfile copyWith({
    int? schemaVersion,
    int? profileRevision,
    int? baseCloudRevision,
    String? updatedAt,
    String? updatedByDeviceId,
    String? sourcePlatform,
    String? sanitizationPolicy,
    String? checksum,
    Map<String, Object?>? payload,
    bool recomputeChecksum = false,
  }) {
    final nextSchemaVersion = schemaVersion ?? this.schemaVersion;
    final nextProfileRevision = profileRevision ?? this.profileRevision;
    final nextBaseCloudRevision = baseCloudRevision ?? this.baseCloudRevision;
    final nextUpdatedAt = updatedAt ?? this.updatedAt;
    final nextUpdatedByDeviceId = updatedByDeviceId ?? this.updatedByDeviceId;
    final nextSourcePlatform = sourcePlatform ?? this.sourcePlatform;
    final nextSanitizationPolicy =
        sanitizationPolicy ?? this.sanitizationPolicy;
    final nextPayload = payload ?? this.payload;
    final nextChecksum = recomputeChecksum
        ? computeChecksum(
            schemaVersion: nextSchemaVersion,
            profileRevision: nextProfileRevision,
            baseCloudRevision: nextBaseCloudRevision,
            updatedAt: nextUpdatedAt,
            updatedByDeviceId: nextUpdatedByDeviceId,
            sourcePlatform: nextSourcePlatform,
            sanitizationPolicy: nextSanitizationPolicy,
            payload: nextPayload,
          )
        : checksum ?? this.checksum;
    return KeyboardSyncProfile(
      schemaVersion: nextSchemaVersion,
      profileRevision: nextProfileRevision,
      baseCloudRevision: nextBaseCloudRevision,
      updatedAt: nextUpdatedAt,
      updatedByDeviceId: nextUpdatedByDeviceId,
      sourcePlatform: nextSourcePlatform,
      sanitizationPolicy: nextSanitizationPolicy,
      checksum: nextChecksum,
      payload: nextPayload,
    );
  }

  KeyboardSyncValidationResult validate() {
    if (schemaVersion != KeyboardSyncPolicyV1.schemaVersion) {
      return const KeyboardSyncValidationResult(
        verdict: KeyboardSyncValidationVerdict.invalidSchemaVersion,
        errors: ['Unsupported keyboard sync schemaVersion'],
      );
    }

    final sanitizedPayload = KeyboardSyncPolicyV1.sanitizePayload(payload);
    if (!_deepEquals(payload, sanitizedPayload)) {
      return const KeyboardSyncValidationResult(
        verdict: KeyboardSyncValidationVerdict.invalidPayload,
        errors: ['Payload contains unsafe or forbidden fields'],
      );
    }

    final payloadBytes = KeyboardSyncPolicyV1.estimatePayloadBytes(payload);
    if (payloadBytes > KeyboardSyncPolicyV1.maxProfileBytes) {
      return KeyboardSyncValidationResult(
        verdict: KeyboardSyncValidationVerdict.oversizedPayload,
        errors: [
          'Payload exceeds size budget ${KeyboardSyncPolicyV1.maxProfileBytes}',
        ],
      );
    }

    final expectedChecksum = computeChecksum(
      schemaVersion: schemaVersion,
      profileRevision: profileRevision,
      baseCloudRevision: baseCloudRevision,
      updatedAt: updatedAt,
      updatedByDeviceId: updatedByDeviceId,
      sourcePlatform: sourcePlatform,
      sanitizationPolicy: sanitizationPolicy,
      payload: payload,
    );
    if (expectedChecksum != checksum) {
      return const KeyboardSyncValidationResult(
        verdict: KeyboardSyncValidationVerdict.invalidChecksum,
        errors: ['Checksum mismatch'],
      );
    }

    return const KeyboardSyncValidationResult(
      verdict: KeyboardSyncValidationVerdict.valid,
      errors: <String>[],
    );
  }

  static String computeChecksum({
    required int schemaVersion,
    required int profileRevision,
    required int baseCloudRevision,
    required String updatedAt,
    required String updatedByDeviceId,
    required String sourcePlatform,
    required String sanitizationPolicy,
    required Map<String, Object?> payload,
  }) {
    final canonical = _canonicalJsonString({
      'schemaVersion': schemaVersion,
      'profileRevision': profileRevision,
      'baseCloudRevision': baseCloudRevision,
      'updatedAt': updatedAt,
      'updatedByDeviceId': updatedByDeviceId,
      'sourcePlatform': sourcePlatform,
      'sanitizationPolicy': sanitizationPolicy,
      'payload': payload,
    });
    return sha256.convert(utf8.encode(canonical)).toString();
  }

  static String _canonicalJsonString(Object? value) {
    return jsonEncode(_canonicalize(value));
  }

  static Object? _canonicalize(Object? value) {
    if (value is Map) {
      final entries = value.entries.toList()
        ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
      final map = <String, Object?>{};
      for (final entry in entries) {
        map[entry.key.toString()] = _canonicalize(entry.value);
      }
      return map;
    }
    if (value is List) {
      return value.map(_canonicalize).toList(growable: false);
    }
    return value;
  }

  static bool _deepEquals(Object? a, Object? b) {
    if (a == b) {
      return true;
    }
    if (a is Map && b is Map) {
      if (a.length != b.length) {
        return false;
      }
      for (final key in a.keys) {
        if (!b.containsKey(key) || !_deepEquals(a[key], b[key])) {
          return false;
        }
      }
      return true;
    }
    if (a is List && b is List) {
      if (a.length != b.length) {
        return false;
      }
      for (var i = 0; i < a.length; i++) {
        if (!_deepEquals(a[i], b[i])) {
          return false;
        }
      }
      return true;
    }
    return false;
  }
}
