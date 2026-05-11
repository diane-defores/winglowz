import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winflowz_app/core/theme/app_theme.dart';
import 'package:winflowz_app/core/bootstrap/supabase_bootstrap.dart';
import 'package:winflowz_app/core/platform/android_keyboard_bridge.dart';
import 'package:winflowz_app/core/platform/android_overlay_bridge.dart';
import 'package:winflowz_app/core/platform/platform_capabilities.dart';
import 'package:winflowz_app/features/keyboard/domain/keyboard_models.dart';
import 'package:winflowz_app/features/clipboard/domain/clipboard_normalizer.dart';
import 'package:winflowz_app/features/shell/presentation/app_shell_screen.dart';
import 'package:winflowz_app/features/voice/domain/transcription_draft.dart';

const _overlayChannel = MethodChannel('winflowz_app/overlay');
const _keyboardChannel = MethodChannel('winflowz_app/keyboard');
const _secureStorageChannel = MethodChannel(
  'plugins.it_nomads.com/flutter_secure_storage',
);

void _installAndroidBridgeMocks() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(_overlayChannel, (call) async {
    switch (call.method) {
      case 'getOverlayStatus':
        return <String, Object?>{
          'enabled': false,
          'requestedEnabled': false,
          'running': false,
          'overlayPermissionGranted': false,
          'accessibilityPermissionGranted': false,
          'deliveryMode': 'clipboard_only',
          'sizeScale': 1.0,
          'opacity': 0.8,
        };
      case 'drainOverlayEvents':
        return <Object?>[];
    }
    return null;
  });
  messenger.setMockMethodCallHandler(_keyboardChannel, (call) async {
    switch (call.method) {
      case 'getKeyboardStatus':
        return <String, Object?>{
          'supported': true,
          'enabled': false,
          'active': false,
          'voiceEnabled': true,
          'clipboardSyncDesired': false,
          'mediaControlsEnabled': true,
          'privacyMode': 'auto',
        };
      case 'drainKeyboardClipboardEvents':
        return <Object?>[];
      case 'setKeyboardSnippetRules':
      case 'setKeyboardDictionaryRules':
        return true;
    }
    return null;
  });
  messenger.setMockMethodCallHandler(_secureStorageChannel, (call) async {
    switch (call.method) {
      case 'containsKey':
        return false;
      case 'read':
        return null;
      case 'readAll':
        return <String, String>{};
      case 'write':
      case 'delete':
      case 'deleteAll':
        return null;
    }
    return null;
  });
}

void _clearAndroidBridgeMocks() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(_overlayChannel, null);
  messenger.setMockMethodCallHandler(_keyboardChannel, null);
  messenger.setMockMethodCallHandler(_secureStorageChannel, null);
}

Widget _appShellTestWidget() {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const AppShellScreen(),
    ),
  );
}

Future<void> _pumpNavigationFrame(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  test('app theme mode maps Material theme modes with system fallback', () {
    expect(AppThemeMode.fromThemeMode(ThemeMode.system), AppThemeMode.system);
    expect(AppThemeMode.fromThemeMode(ThemeMode.light), AppThemeMode.light);
    expect(AppThemeMode.fromThemeMode(ThemeMode.dark), AppThemeMode.dark);
  });

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

  test('android overlay event parses native bridge maps', () {
    final event = AndroidOverlayEvent.fromMap({
      'type': 'serviceError',
      'capturedAtEpochMillis': 1778263200000,
      'payload': {'code': 'OVERLAY_PERMISSION_REVOKED', 'ignored': <String>[]},
    });

    expect(event, isNotNull);
    expect(event?.type, AndroidOverlayEventType.serviceError);
    expect(event?.capturedAtUtc.isUtc, isTrue);
    expect(event?.payload, containsPair('code', 'OVERLAY_PERMISSION_REVOKED'));
    expect(event?.payload, isNot(contains('ignored')));
  });

  test('android overlay delivery result parses native bridge maps', () {
    final result = AndroidOverlayDeliveryResult.fromMap({
      'injected': true,
      'clipboardCopied': true,
      'sensitiveField': false,
    });

    expect(result.injected, isTrue);
    expect(result.clipboardCopied, isTrue);
    expect(result.sensitiveField, isFalse);
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

  test(
    'platform capability limits keep Linux speech and Android-only surfaces unavailable',
    () {
      final previousPlatform = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() => debugDefaultTargetPlatformOverride = previousPlatform);

      expect(PlatformCapabilities.localSpeechSupported, isFalse);
      expect(PlatformCapabilities.overlaySupported, isFalse);
      expect(PlatformCapabilities.keyboardImeSupported, isFalse);
      expect(PlatformCapabilities.secureStorageDegraded, isTrue);
    },
  );

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

  testWidgets('app shell shows onboarding and back returns to previous tab', (
    tester,
  ) async {
    await tester.pumpWidget(_appShellTestWidget());
    await tester.pump();

    expect(find.text('Start here'), findsNothing);
    expect(find.textContaining('Missing Supabase config'), findsNothing);
    expect(find.textContaining('Cloud sync is disabled'), findsNothing);
    expect(find.text('Raw text'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.text_snippet_outlined).last);
    await _pumpNavigationFrame(tester);
    expect(find.text('WinFlowzApp • Snippets'), findsOneWidget);
    expect(find.text('Trigger'), findsOneWidget);
    expect(find.text('Snippets'), findsWidgets);

    final handled = await tester.binding.handlePopRoute();
    await _pumpNavigationFrame(tester);

    expect(handled, isTrue);
    expect(find.text('WinFlowzApp • Voice'), findsOneWidget);
  });

  testWidgets('settings can resume onboarding overlay', (tester) async {
    await tester.pumpWidget(_appShellTestWidget());
    await tester.pump();

    expect(find.text('Start here'), findsNothing);
    expect(find.text('Raw text'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined).last);
    await tester.pump();
    await tester.tap(find.text('Resume'));
    await tester.pump();

    expect(find.text('Start here'), findsOneWidget);
    expect(
      find.text('Enable WinFlowzApp Keyboard in Settings.'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Close onboarding'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Start here'), findsNothing);
    expect(find.text('WinFlowzApp • Settings'), findsOneWidget);
  });

  testWidgets('android shell renders every main tab body', (tester) async {
    final previousPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    _installAndroidBridgeMocks();
    addTearDown(() {
      debugDefaultTargetPlatformOverride = previousPlatform;
      _clearAndroidBridgeMocks();
    });

    await tester.pumpWidget(_appShellTestWidget());
    await _pumpNavigationFrame(tester);

    expect(find.text('WinFlowzApp • Voice'), findsOneWidget);
    expect(find.text('Raw text'), findsOneWidget);
    final addTranscriptionButton = find.widgetWithText(
      FilledButton,
      'Add transcription',
    );
    await tester.scrollUntilVisible(
      addTranscriptionButton,
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(addTranscriptionButton, findsOneWidget);

    await tester.tap(find.byIcon(Icons.content_paste_outlined).last);
    await _pumpNavigationFrame(tester);
    expect(find.text('WinFlowzApp • Clipboard'), findsOneWidget);
    expect(find.text('Clipboard content'), findsOneWidget);
    expect(find.text('Add clipboard item'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.keyboard_outlined).last);
    await _pumpNavigationFrame(tester);
    expect(find.text('WinFlowzApp • Keyboard'), findsOneWidget);
    expect(find.text('Keyboard preview'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.text_snippet_outlined).last);
    await _pumpNavigationFrame(tester);
    expect(find.text('WinFlowzApp • Snippets'), findsOneWidget);
    expect(find.text('Trigger'), findsOneWidget);
    expect(find.text('Add snippet'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.auto_fix_high_outlined).last);
    await _pumpNavigationFrame(tester);
    expect(find.text('WinFlowzApp • Dictionary'), findsOneWidget);
    expect(find.text('Term'), findsOneWidget);
    expect(find.text('Add term'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined).last);
    await _pumpNavigationFrame(tester);
    expect(find.text('WinFlowzApp • Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('WinFlowzApp Keyboard status'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('WinFlowzApp Keyboard status'), findsOneWidget);

    debugDefaultTargetPlatformOverride = previousPlatform;
    _clearAndroidBridgeMocks();
  });
}
