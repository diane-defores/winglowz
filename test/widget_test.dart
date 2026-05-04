import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:voiceflowz/core/platform/android_keyboard_bridge.dart';
import 'package:voiceflowz/data/supabase/clipboard_repository.dart';
import 'package:voiceflowz/features/keyboard/domain/keyboard_models.dart';
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

  test('clipboard normalized hash is stable across whitespace', () {
    final first = ClipboardRepository.normalizedClipboardHash(
      ' hello   world ',
    );
    final second = ClipboardRepository.normalizedClipboardHash('hello world');

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
}
