import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:voiceflowz/core/bootstrap/supabase_bootstrap.dart';
import 'package:voiceflowz/core/platform/android_keyboard_bridge.dart';
import 'package:voiceflowz/features/keyboard/domain/keyboard_models.dart';
import 'package:voiceflowz/features/clipboard/domain/clipboard_normalizer.dart';
import 'package:voiceflowz/features/voice/domain/transcription_draft.dart';

void main() {
  test('transcription draft validates non-empty payload and known source', () {
    const valid = TranscriptionDraft(
      rawText: 'hello',
      cleanedText: 'Hello.',
      language: 'en',
      source: 'advanced',
      durationMs: 1200,
    );
    const invalid = TranscriptionDraft(
      rawText: ' ',
      cleanedText: '',
      language: 'en',
      source: 'unknown',
      durationMs: -1,
    );

    expect(valid.isValid, isTrue);
    expect(invalid.isValid, isFalse);
  });

  test('keyboard transcription source is valid', () {
    const draft = TranscriptionDraft(
      rawText: 'keyboard text',
      cleanedText: 'Keyboard text.',
      language: 'en',
      source: 'keyboard',
      durationMs: 400,
    );

    expect(draft.isValid, isTrue);
  });

  test('android keyboard status parses native bridge maps', () {
    final status = AndroidKeyboardStatus.fromMap({
      'supported': true,
      'enabled': true,
      'active': false,
      'voiceEnabled': false,
      'clipboardSyncDesired': true,
      'mediaControlsEnabled': true,
      'privacyMode': 'strict',
    });

    expect(status.supported, isTrue);
    expect(status.enabled, isTrue);
    expect(status.active, isFalse);
    expect(status.voiceEnabled, isFalse);
    expect(status.clipboardSyncDesired, isTrue);
    expect(status.privacyMode, KeyboardPrivacyMode.strict);
    expect(
      status.toPreferencesMap(mediaControlsEnabled: false),
      containsPair('mediaControlsEnabled', false),
    );
  });

  test('android keyboard clipboard event parses native bridge maps', () {
    final event = AndroidKeyboardClipboardEvent.fromMap({
      'content': ' copied text ',
      'source': 'keyboard_clipboard',
      'deviceId': 'android:abc',
      'capturedAtEpochMillis': 1778263200000,
      'sourceMetadata': {'action': 'copy_selection', 'ignored': <String>[]},
    });

    expect(event, isNotNull);
    expect(event?.content, ' copied text ');
    expect(event?.source.databaseValue, 'keyboard_clipboard');
    expect(event?.deviceId, 'android:abc');
    expect(event?.capturedAtUtc.isUtc, isTrue);
    expect(event?.sourceMetadata, containsPair('action', 'copy_selection'));
    expect(event?.sourceMetadata, isNot(contains('ignored')));
  });

  test('clipboard normalized hash is stable across whitespace', () {
    final first = sha256Hex(normalizeClipboardText(' hello   world '));
    final second = sha256Hex(normalizeClipboardText('hello world'));

    expect(first, second);
    expect(first, hasLength(64));
  });

  test('keyboard bridge returns unsupported status off Android', () async {
    final previousPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = previousPlatform);

    final status = await AndroidKeyboardBridge.getStatus();

    expect(status.supported, isFalse);
    expect(status.enabled, isFalse);
  });

  test('supabase config prefers publishable key', () {
    final config = SupabaseBootstrap.resolveConfig(
      url: ' https://example.supabase.co ',
      publishableKey: ' sb_publishable_current ',
      legacyAnonKey: 'legacy-anon-key',
    );

    expect(config.isComplete, isTrue);
    expect(config.url, 'https://example.supabase.co');
    expect(config.publishableKey, 'sb_publishable_current');
    expect(config.missingEnvironmentNames, isEmpty);
  });

  test('supabase config accepts legacy anon key as compatibility fallback', () {
    final config = SupabaseBootstrap.resolveConfig(
      url: 'https://example.supabase.co',
      publishableKey: '',
      legacyAnonKey: 'legacy-anon-key',
    );

    expect(config.isComplete, isTrue);
    expect(config.publishableKey, 'legacy-anon-key');
  });

  test('supabase config reports current missing variable names', () {
    final config = SupabaseBootstrap.resolveConfig(
      url: '',
      publishableKey: '',
      legacyAnonKey: '',
    );

    expect(config.isComplete, isFalse);
    expect(config.missingEnvironmentNames, [
      SupabaseBootstrap.urlEnvironmentName,
      SupabaseBootstrap.publishableKeyEnvironmentName,
    ]);
  });
}
