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
import 'package:winflowz_app/features/keyboard/presentation/keyboard_preview_screen.dart';
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
          'keyVibrationEnabled': true,
          'keySoundEnabled': false,
          'spellingSuggestionsEnabled': true,
          'specialKeyCornersEnabled': false,
          'frenchLanguageEnabled': true,
          'englishLanguageEnabled': true,
        };
      case 'drainKeyboardClipboardEvents':
        return <Object?>[];
      case 'drainKeyboardVoiceEvents':
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

Widget _keyboardPreviewTestWidget() {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const Scaffold(body: KeyboardPreviewScreen()),
    ),
  );
}

String _simulatedBufferText(WidgetTester tester) {
  final selectable = tester.widget<SelectableText>(
    find.byKey(const Key('keyboard-preview-simulated-buffer')),
  );
  return selectable.data ?? selectable.textSpan?.toPlainText() ?? '';
}

String _simulatedStatusText(WidgetTester tester) {
  final status = tester.widget<Text>(
    find.byKey(const Key('keyboard-preview-simulated-status')),
  );
  return status.data ?? '';
}

Future<void> _pumpNavigationFrame(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _selectDropdownOption(
  WidgetTester tester,
  Key dropdownKey,
  String optionText,
) async {
  await tester.ensureVisible(find.byKey(dropdownKey));
  await tester.tap(find.byKey(dropdownKey));
  await tester.pumpAndSettle();
  await tester.tap(find.text(optionText).last);
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void _useLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1440, 2200);
  tester.view.devicePixelRatio = 1.0;
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
      'mediaVolumeStepPercent': 25,
      'mediaBrightnessStepPercent': 15,
      'actionRowHeightScale': 0.3,
      'privacyMode': 'strict',
      'cornerPresetId': 'developer_symbols',
    });

    expect(status.supported, isTrue);
    expect(status.enabled, isTrue);
    expect(status.active, isFalse);
    expect(status.voiceEnabled, isFalse);
    expect(status.clipboardSyncDesired, isTrue);
    expect(status.mediaVolumeStepPercent, 25);
    expect(status.mediaBrightnessStepPercent, 15);
    expect(status.actionRowHeightScale, 0.3);
    expect(status.privacyMode, KeyboardPrivacyMode.strict);
    expect(status.cornerPresetId, 'developer_symbols');
    expect(
      status.toPreferencesMap(mediaControlsEnabled: false),
      containsPair('mediaControlsEnabled', false),
    );
  });

  test('android keyboard corner config parses presets and overrides', () {
    final config = AndroidKeyboardCornerConfig.fromMap({
      'presetId': 'punctuation_corners',
      'overrides': [
        {
          'keyId': 'letter-a',
          'slot': 'topLeft',
          'expression': "JA:'j\\'arrive'",
          'label': 'JA',
          'sensitive': true,
        },
      ],
      'availablePresets': [
        {'id': 'punctuation_corners', 'name': 'Punctuation corners'},
      ],
    });

    final resolved = KeyboardCornerPresetCatalog.resolvedForKey(
      config: config,
      keyId: 'letter-a',
      cornersEnabled: true,
      specialKeyCornersEnabled: false,
      privateMode: false,
    );
    final privateResolved = KeyboardCornerPresetCatalog.resolvedForKey(
      config: config,
      keyId: 'letter-a',
      cornersEnabled: true,
      specialKeyCornersEnabled: false,
      privateMode: true,
    );

    expect(config.presetId, 'punctuation_corners');
    expect(config.availablePresets.single.name, 'Punctuation corners');
    expect(resolved[KeyboardCornerSlot.topLeft]?.displayLabel, 'JA');
    expect(privateResolved[KeyboardCornerSlot.topLeft], isNull);
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

  test('android keyboard voice event parses native bridge maps', () {
    final event = AndroidKeyboardVoiceEvent.fromMap({
      'rawText': ' hello voice ',
      'cleanedText': 'hello voice',
      'language': 'en-US',
      'source': 'keyboard',
      'durationMs': 1200,
      'capturedAtEpochMillis': 1778263200000,
    });

    expect(event, isNotNull);
    expect(event?.rawText, 'hello voice');
    expect(event?.cleanedText, 'hello voice');
    expect(event?.language, 'en-US');
    expect(event?.source, 'keyboard');
    expect(event?.durationMs, 1200);
    expect(event?.capturedAtUtc.isUtc, isTrue);
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
    expect(find.text('Capture automatique'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.text_snippet_outlined).last);
    await _pumpNavigationFrame(tester);
    expect(find.text('WinFlowz • Snippets'), findsOneWidget);
    expect(find.text('Trigger'), findsOneWidget);
    expect(find.text('Snippets'), findsWidgets);

    final handled = await tester.binding.handlePopRoute();
    await _pumpNavigationFrame(tester);

    expect(handled, isTrue);
    expect(find.text('WinFlowz • Voice'), findsOneWidget);
  });

  testWidgets('settings can resume onboarding overlay', (tester) async {
    final previousPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    _useLargeViewport(tester);
    _installAndroidBridgeMocks();

    try {
      await tester.pumpWidget(_appShellTestWidget());
      await _pumpNavigationFrame(tester);

      expect(find.text('Capture automatique'), findsOneWidget);
      expect(find.text('Configuration WinFlowz'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Plus tard').last);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      expect(find.text('Configuration WinFlowz'), findsOneWidget);
      expect(find.text('Onboarding mis en pause'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Plus tard'), findsNothing);
      expect(
        find.text(
          "Tu peux reprendre la suite de l'onboarding quand tu veux à partir des paramètres.",
        ),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'OK'));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      expect(find.text('Configuration WinFlowz'), findsNothing);
      expect(find.text('WinFlowz • Settings'), findsOneWidget);
      expect(find.text('Onboarding mis en pause'), findsNothing);

      final resumeButton = find.widgetWithText(TextButton, 'Reprendre');
      await tester.scrollUntilVisible(
        resumeButton,
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(resumeButton);
      await tester.tap(resumeButton, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      expect(find.text('Configuration WinFlowz'), findsOneWidget);
      expect(
        find.text('Choisis les usages que tu veux activer'),
        findsOneWidget,
      );
      expect(find.text('Micro et voice'), findsOneWidget);
      expect(find.text('Clavier'), findsNothing);

      final nextButton = find.text('Suivant');
      await tester.ensureVisible(nextButton);
      await tester.tap(nextButton);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      expect(find.text('Service Accessibilité'), findsWidgets);
      expect(find.text('Clavier'), findsNothing);

      await tester.ensureVisible(nextButton);
      await tester.tap(nextButton);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      expect(find.text('Clavier'), findsOneWidget);
      expect(
        find.text('Historique et synchronisation du clipboard clavier.'),
        findsNothing,
      );

      await tester.tap(find.widgetWithText(OutlinedButton, 'Paramètres'));
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      expect(find.text('Configuration WinFlowz'), findsNothing);
      expect(find.text('WinFlowz • Settings'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = previousPlatform;
      _clearAndroidBridgeMocks();
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });

  testWidgets('tapping outside onboarding overlay closes it', (tester) async {
    final previousPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    _useLargeViewport(tester);
    _installAndroidBridgeMocks();

    try {
      await tester.pumpWidget(_appShellTestWidget());
      await _pumpNavigationFrame(tester);

      expect(find.text('Configuration WinFlowz'), findsOneWidget);
      final overlayCardTopLeft = tester.getTopLeft(
        find.byKey(const Key('onboarding-overlay-card-frame')),
      );
      final overlayCardCenter = tester.getCenter(
        find.byKey(const Key('onboarding-overlay-card-frame')),
      );
      await tester.tapAt(
        Offset(overlayCardTopLeft.dx - 8, overlayCardCenter.dy),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      expect(find.text('Configuration WinFlowz'), findsNothing);
      expect(find.text('WinFlowz • Voice'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = previousPlatform;
      _clearAndroidBridgeMocks();
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
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

    final closeOnboarding = find.byTooltip('Fermer (reprendre plus tard)');
    if (closeOnboarding.evaluate().isNotEmpty) {
      await tester.tap(closeOnboarding);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
    }

    expect(find.text('WinFlowz • Voice'), findsOneWidget);
    expect(find.text('Capture automatique'), findsOneWidget);
    expect(find.text('Refresh history'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.content_paste_outlined).last);
    await _pumpNavigationFrame(tester);
    expect(find.text('WinFlowz • Clipboard'), findsOneWidget);
    expect(find.text('Clipboard content'), findsOneWidget);
    expect(find.text('Add clipboard item'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.text_snippet_outlined).last);
    await _pumpNavigationFrame(tester);
    expect(find.text('WinFlowz • Snippets'), findsOneWidget);
    expect(find.text('Trigger'), findsOneWidget);
    expect(find.text('Add snippet'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.auto_fix_high_outlined).last);
    await _pumpNavigationFrame(tester);
    expect(find.text('WinFlowz • Dictionary'), findsOneWidget);
    expect(find.text('Term'), findsOneWidget);
    expect(find.text('Add term'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined).last);
    await _pumpNavigationFrame(tester);
    expect(find.text('WinFlowz • Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsWidgets);

    debugDefaultTargetPlatformOverride = previousPlatform;
    _clearAndroidBridgeMocks();
  });

  testWidgets('settings backend diagnostics panel opens without layout error', (
    tester,
  ) async {
    final previousPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    _useLargeViewport(tester);
    _installAndroidBridgeMocks();

    try {
      await tester.pumpWidget(_appShellTestWidget());
      await _pumpNavigationFrame(tester);

      final closeOnboarding = find.byTooltip('Fermer (reprendre plus tard)');
      if (closeOnboarding.evaluate().isNotEmpty) {
        await tester.tap(closeOnboarding);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
      }

      await tester.tap(find.byIcon(Icons.settings_outlined).last);
      await _pumpNavigationFrame(tester);

      final backendSection = find.text('Backend Provider').first;
      await tester.scrollUntilVisible(
        backendSection,
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(backendSection, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      expect(
        find.byKey(const Key('backend-diagnostic-log-text')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = previousPlatform;
      _clearAndroidBridgeMocks();
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });

  testWidgets(
    'keyboard preview sandbox types letters and handles Space Back Enter Shift suggestion',
    (tester) async {
      _useLargeViewport(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_keyboardPreviewTestWidget());
      await tester.pumpAndSettle();

      expect(_simulatedBufferText(tester), '|');

      await _tapVisible(tester, find.text('h'));
      expect(_simulatedBufferText(tester), 'h|');

      await _tapVisible(tester, find.text('Space'));
      expect(_simulatedBufferText(tester), 'h |');

      await _tapVisible(tester, find.text('Back'));
      expect(_simulatedBufferText(tester), 'h|');

      await _tapVisible(tester, find.text('Enter'));
      expect(_simulatedBufferText(tester), 'h\n|');

      await _tapVisible(tester, find.text('Shift'));
      expect(_simulatedStatusText(tester), contains('Shift enabled'));

      await _tapVisible(tester, find.text('a'));
      expect(_simulatedBufferText(tester), 'h\nA|');

      await _tapVisible(tester, find.text('bonjour'));
      expect(_simulatedBufferText(tester), 'h\nA bonjour|');
      expect(_simulatedStatusText(tester), contains('Suggestion'));
    },
  );

  testWidgets(
    'keyboard preview sandbox updates email context and reports disabled/non simulated actions',
    (tester) async {
      _useLargeViewport(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_keyboardPreviewTestWidget());
      await tester.pumpAndSettle();

      await _selectDropdownOption(
        tester,
        const Key('keyboard-preview-field-dropdown'),
        'Email',
      );
      expect(_simulatedStatusText(tester), contains('Field context: Email'));

      await _tapVisible(tester, find.text('@'));
      expect(_simulatedBufferText(tester), '@|');

      await _tapVisible(tester, find.widgetWithText(FilterChip, 'Private'));
      expect(_simulatedStatusText(tester), contains('Private mode on'));

      await _tapVisible(tester, find.text('Clip'));
      expect(_simulatedBufferText(tester), '@|');
      expect(_simulatedStatusText(tester), contains('disabled'));

      await _tapVisible(tester, find.text('Mic'));
      expect(_simulatedBufferText(tester), '@|');
      expect(_simulatedStatusText(tester), contains('non simulated'));
    },
  );

  testWidgets(
    'keyboard preview navigation panel adds controls while typing keys remain available',
    (tester) async {
      _useLargeViewport(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_keyboardPreviewTestWidget());
      await tester.pumpAndSettle();

      await _selectDropdownOption(
        tester,
        const Key('keyboard-preview-panel-dropdown'),
        'Navigation',
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Cut'), findsOneWidget);
      expect(find.text('Paste'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
      expect(find.text('Redo'), findsOneWidget);
      expect(find.text('⏫'), findsOneWidget);
      expect(find.text('↑'), findsOneWidget);
      expect(find.text('Word←'), findsOneWidget);
      expect(find.text('⬅'), findsOneWidget);
      expect(find.text('➡'), findsOneWidget);
      expect(find.text('Word→'), findsOneWidget);
      expect(find.text('↓'), findsOneWidget);
      expect(find.text('⏬'), findsOneWidget);
      expect(find.text('Del←'), findsOneWidget);
      expect(find.text('DelW←'), findsOneWidget);
      expect(find.text('Del→'), findsOneWidget);
      expect(find.text('DelW→'), findsOneWidget);
      expect(find.text('Clip'), findsOneWidget);
      expect(find.text('q'), findsOneWidget);
      expect(find.text('Space'), findsOneWidget);
      expect(find.text('Ctrl'), findsOneWidget);
      expect(find.text('Shift'), findsOneWidget);
    },
  );

  testWidgets(
    'keyboard preview accent panel adds french accents without replacing letters',
    (tester) async {
      _useLargeViewport(tester);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_keyboardPreviewTestWidget());
      await tester.pumpAndSettle();

      await _tapVisible(tester, find.text('Acc'));

      expect(find.text('œ'), findsOneWidget);
      expect(find.text('Shift'), findsOneWidget);
      expect(find.text('Ctrl'), findsOneWidget);
      expect(find.text('q'), findsOneWidget);

      await _tapVisible(tester, find.text('œ'));
      expect(_simulatedBufferText(tester), 'œ|');
    },
  );

  testWidgets('keyboard preview resolves configurable corner presets', (
    tester,
  ) async {
    _useLargeViewport(tester);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(_keyboardPreviewTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('à'), findsOneWidget);

    await tester.longPress(find.text('a').first);
    await tester.pumpAndSettle();
    expect(_simulatedBufferText(tester), 'à|');
    expect(_simulatedStatusText(tester), contains('Corner shortcut'));

    await _selectDropdownOption(
      tester,
      const Key('keyboard-preview-corner-preset-dropdown'),
      'Punctuation corners',
    );

    expect(find.text('?'), findsOneWidget);
    expect(find.text('à'), findsNothing);
  });

  testWidgets('keyboard preview media panel can show now playing line', (
    tester,
  ) async {
    _useLargeViewport(tester);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(_keyboardPreviewTestWidget());
    await tester.pumpAndSettle();

    await _tapVisible(tester, find.text('Media'));

    expect(find.text('Now'), findsOneWidget);
    expect(find.text('Now playing: tap Now'), findsNothing);

    await _tapVisible(tester, find.text('Now'));
    expect(find.text('Daft Punk - Digital Love'), findsWidgets);

    await _tapVisible(tester, find.text('Now'));
    expect(find.text('Daft Punk - Digital Love'), findsNothing);
  });

  testWidgets('keyboard preview snippets panel scrolls current snippets', (
    tester,
  ) async {
    _useLargeViewport(tester);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(_keyboardPreviewTestWidget());
    await tester.pumpAndSettle();

    await _tapVisible(tester, find.text('Snip'));

    expect(find.text('j\'arrive'), findsWidgets);
    expect(find.text('D\'accord'), findsOneWidget);
    expect(find.text('Signature'), findsOneWidget);

    await _tapVisible(tester, find.text('D\'accord'));

    expect(_simulatedBufferText(tester), contains('D\'accord'));
    expect(_simulatedStatusText(tester), 'Snippet inserted.');
  });

  testWidgets('keyboard preview clipboard shows entries and full history', (
    tester,
  ) async {
    _useLargeViewport(tester);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(_keyboardPreviewTestWidget());
    await tester.pumpAndSettle();

    await _tapVisible(tester, find.text('Clip'));

    expect(find.text('Latest copied text'), findsOneWidget);
    expect(find.text('Copy'), findsNothing);

    await _tapVisible(tester, find.text('Latest copied text'));
    expect(_simulatedBufferText(tester), contains('Latest copied text'));

    await _tapVisible(tester, find.text('Clip'));
    await tester.longPress(find.text('Clip'));
    await tester.pumpAndSettle();

    expect(find.text('Pin Pinned account id'), findsOneWidget);
    expect(find.text('q'), findsNothing);
    expect(find.text('Space'), findsNothing);
  });

  testWidgets('keyboard preview settings panel exposes important shortcuts', (
    tester,
  ) async {
    _useLargeViewport(tester);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(_keyboardPreviewTestWidget());
    await tester.pumpAndSettle();

    await _tapVisible(tester, find.text('Prefs'));

    expect(find.text('Keyboard'), findsOneWidget);
    expect(find.text('App'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('QWERTY'), findsWidgets);
    expect(find.text('Vibe on'), findsOneWidget);
    expect(find.text('Sound off'), findsOneWidget);
    expect(find.text('Suggest on'), findsOneWidget);
    expect(find.text('FR on'), findsOneWidget);
    expect(find.text('EN on'), findsOneWidget);
    expect(find.text('Special off'), findsOneWidget);
    expect(find.text('Corners on'), findsOneWidget);
    expect(find.text('2sp on'), findsOneWidget);
    expect(find.text('Punc on'), findsOneWidget);
    expect(find.text('Debug off'), findsOneWidget);
    expect(find.text('q'), findsNothing);
    expect(find.text('Space'), findsNothing);
  });

  testWidgets('keyboard preview number mode uses three by three keypad rows', (
    tester,
  ) async {
    _useLargeViewport(tester);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(_keyboardPreviewTestWidget());
    await tester.pumpAndSettle();

    await _tapVisible(tester, find.text('123'));

    expect(find.text('+'), findsOneWidget);
    expect(find.text('-'), findsOneWidget);
    expect(find.text('*'), findsOneWidget);
    expect(find.text('/'), findsOneWidget);
    expect(find.text('.'), findsOneWidget);
    expect(find.text(','), findsOneWidget);
    expect(find.text('@'), findsOneWidget);
    expect(find.text('#'), findsOneWidget);
    expect(find.text('?'), findsOneWidget);
    expect(find.text('!'), findsOneWidget);
    expect(find.text(':'), findsOneWidget);
    expect(find.text(';'), findsOneWidget);
    for (final digit in ['1', '2', '3', '4', '5', '6', '7', '8', '9']) {
      expect(find.text(digit), findsOneWidget);
    }
    expect(find.text('0'), findsNothing);
  });
}
