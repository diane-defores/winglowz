import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClipboardItemRecord {
  const ClipboardItemRecord({
    required this.id,
    required this.content,
    required this.source,
    required this.pinned,
    required this.createdAt,
    required this.contentHash,
    required this.originSurface,
    required this.captureMethod,
    required this.syncState,
  });

  final String id;
  final String content;
  final String source;
  final bool pinned;
  final DateTime createdAt;
  final String? contentHash;
  final String originSurface;
  final String captureMethod;
  final String syncState;

  factory ClipboardItemRecord.fromMap(Map<String, dynamic> row) {
    final createdAtRaw = row['created_at'] as String?;
    return ClipboardItemRecord(
      id: row['id'] as String,
      content: (row['content'] as String?) ?? '',
      source: (row['source'] as String?) ?? 'manual',
      pinned: (row['pinned'] as bool?) ?? false,
      createdAt: createdAtRaw == null
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.tryParse(createdAtRaw)?.toLocal() ??
                DateTime.fromMillisecondsSinceEpoch(0),
      contentHash: row['content_hash'] as String?,
      originSurface: (row['origin_surface'] as String?) ?? 'app',
      captureMethod: (row['capture_method'] as String?) ?? 'manual',
      syncState: (row['sync_state'] as String?) ?? 'synced',
    );
  }
}

class ClipboardRepository {
  const ClipboardRepository(this._client);

  final SupabaseClient _client;

  Future<List<ClipboardItemRecord>> list() async {
    final rows = await _client
        .from('clipboard_items')
        .select()
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false)
        .limit(100);

    return rows
        .map<ClipboardItemRecord>(
          (row) => ClipboardItemRecord.fromMap(Map<String, dynamic>.from(row)),
        )
        .toList(growable: false);
  }

  Future<void> insert({
    required String content,
    required String source,
    String originSurface = 'app',
    String captureMethod = 'manual',
    String? originDeviceId,
    String syncState = 'synced',
  }) async {
    final normalized = content.trim();
    if (normalized.isEmpty) {
      throw const FormatException('Clipboard content cannot be empty.');
    }
    await _client.from('clipboard_items').insert({
      'content': normalized,
      'source': source.trim().isEmpty ? 'manual' : source.trim(),
      'content_hash': normalizedClipboardHash(normalized),
      'origin_surface': originSurface.trim().isEmpty
          ? 'app'
          : originSurface.trim(),
      'capture_method': captureMethod.trim().isEmpty
          ? 'manual'
          : captureMethod.trim(),
      if (originDeviceId != null && originDeviceId.trim().isNotEmpty)
        'origin_device_id': originDeviceId.trim(),
      'sync_state': syncState.trim().isEmpty ? 'synced' : syncState.trim(),
    });
  }

  Future<void> togglePin({required String id, required bool pinned}) async {
    await _client
        .from('clipboard_items')
        .update({'pinned': pinned})
        .eq('id', id);
  }

  Future<void> softDelete(String id) async {
    await _client
        .from('clipboard_items')
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id);
  }

  static String normalizedClipboardHash(String content) {
    final normalized = content.trim().replaceAll(RegExp(r'\s+'), ' ');
    return sha256.convert(utf8.encode(normalized)).toString();
  }
}
