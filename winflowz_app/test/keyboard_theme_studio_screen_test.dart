import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winflowz_app/features/keyboard/domain/keyboard_models.dart';
import 'package:winflowz_app/features/keyboard/presentation/keyboard_theme_studio_screen.dart';

void main() {
  const channel = MethodChannel('winflowz_app/keyboard');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getKeyboardThemeConfig' ||
              call.method == 'setKeyboardThemeConfig' ||
              call.method == 'resetKeyboardThemeConfig') {
            return <String, Object?>{
              'version': 1,
              'presetId': 'system',
              'backgroundStartColor': 0xFFEEF1EE,
              'backgroundEndColor': 0xFFEEF1EE,
              'useGradient': false,
              'gradientStyle': 'linear',
              'keyboardOpacity': 1.0,
              'keyColor': 0xFFFFFFFF,
              'specialKeyColor': 0xFFE0E6E3,
              'activeKeyColor': 0xFF17795D,
              'pressedKeyColor': 0xFFCADAD3,
              'pressHighlightDurationMs': 170,
              'textColor': 0xFF1D2320,
              'cornerTextColor': 0xFF5C6762,
              'cornerTextOpacity': 0.85,
              'statusTextColor': 0xFF333D38,
              'borderColor': 0x00000000,
              'borderWidth': 0.0,
              'keyRadius': 8.0,
              'keyHorizontalGap': 5.0,
              'rowVerticalGap': 5.0,
              'keyWidthScale': 1.0,
              'shadowColor': 0x33000000,
              'shadowBlur': 4.0,
              'shadowOffsetY': 1.0,
              'pressEffect': 'none',
              'effectIntensity': 0.35,
              'effectDurationMs': 170,
              'effectEasing': 'easeOut',
            };
          }
          return null;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Future<void> openStudioSection(WidgetTester tester, String title) async {
    final section = find.text(title);
    await tester.scrollUntilVisible(
      section,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < 6; i++) {
      final centerY = tester.getCenter(section).dy;
      if (centerY < 440) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, 120));
      } else if (centerY > 560) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -120));
      } else {
        break;
      }
      await tester.pumpAndSettle();
    }

    await tester.tap(section);
    await tester.pumpAndSettle();
  }

  testWidgets('shows preview and updates draft background color', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: KeyboardThemeStudioScreen()),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.byKey(const Key('keyboard-theme-studio-preview')),
      findsOneWidget,
    );

    await openStudioSection(tester, 'Background');

    final firstField = find.byType(TextFormField).first;
    await tester.enterText(firstField, 'FF0000FF');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(milliseconds: 200));

    final preview = tester.widget<DecoratedBox>(
      find.byKey(const Key('keyboard-theme-studio-preview')),
    );
    final decoration = preview.decoration as BoxDecoration;
    expect(decoration.color, const Color(0xFF0000FF));
  });

  testWidgets('blocks save when theme contrast is unreadable', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: KeyboardThemeStudioScreen()),
    );
    await tester.pump(const Duration(milliseconds: 200));

    final keyColorField = find.byKey(
      const ValueKey('keyboard-theme-color-Key color'),
    );
    final textColorField = find.byKey(
      const ValueKey('keyboard-theme-color-Text'),
    );

    await openStudioSection(tester, 'Keys');

    await tester.scrollUntilVisible(
      keyColorField,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(keyColorField, 'FF111111');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.scrollUntilVisible(
      textColorField,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(textColorField, 'FF111111');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(milliseconds: 200));

    final saveFinder = find.widgetWithText(FilledButton, 'Save');
    await tester.scrollUntilVisible(
      saveFinder,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    final save = tester.widget<FilledButton>(saveFinder);
    expect(save.onPressed, isNull);
  });

  testWidgets('selecting a preset applies its draft colors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: KeyboardThemeStudioScreen()),
    );
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('System').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Neon Terminal').last);
    await tester.pump(const Duration(milliseconds: 200));

    final preview = tester.widget<DecoratedBox>(
      find.byKey(const Key('keyboard-theme-studio-preview')),
    );
    final decoration = preview.decoration as BoxDecoration;
    expect(decoration.gradient, isA<LinearGradient>());
    expect(
      (decoration.gradient! as LinearGradient).colors.first,
      Color(
        KeyboardThemePresetCatalog.configFor(
          KeyboardThemePresetCatalog.neonTerminal,
        ).backgroundStartColor,
      ),
    );
  });

  testWidgets('shows a separate pressed color hold control', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: KeyboardThemeStudioScreen()),
    );
    await tester.pump(const Duration(milliseconds: 200));

    await openStudioSection(tester, 'Effects');

    expect(find.text('Color hold'), findsOneWidget);
    expect(find.text('Effect time'), findsOneWidget);
  });

  testWidgets('shows capped swipe glyph opacity control', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: KeyboardThemeStudioScreen()),
    );
    await tester.pump(const Duration(milliseconds: 200));

    await openStudioSection(tester, 'Keys');

    expect(find.text('Opacity'), findsOneWidget);
    expect(find.text('85%'), findsOneWidget);
  });

  testWidgets('opens one studio section at a time', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: KeyboardThemeStudioScreen()),
    );
    await tester.pump(const Duration(milliseconds: 200));

    await openStudioSection(tester, 'Background');
    expect(find.text('Gradient background'), findsOneWidget);

    await openStudioSection(tester, 'Spacing');

    expect(find.text('Key gap'), findsOneWidget);
    expect(find.text('Gradient background'), findsNothing);
  });

  testWidgets('shows keyboard opacity control near image background', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: KeyboardThemeStudioScreen()),
    );
    await tester.pump(const Duration(milliseconds: 200));

    await openStudioSection(tester, 'Background');

    expect(find.text('Image background'), findsOneWidget);
    expect(find.text('Opacity'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('keeps spacing controls focused on gaps only', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: KeyboardThemeStudioScreen()),
    );
    await tester.pump(const Duration(milliseconds: 200));

    await openStudioSection(tester, 'Spacing');

    expect(find.text('Key gap'), findsOneWidget);
    expect(find.text('Row gap'), findsOneWidget);
    expect(find.text('Key width'), findsNothing);
  });

  testWidgets('imports JSON into draft without saving natively', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: KeyboardThemeStudioScreen()),
    );
    await tester.pump(const Duration(milliseconds: 200));

    await openStudioSection(tester, 'Import / export');
    final importButton = find.byKey(const Key('theme-import-json'));
    await tester.tap(importButton);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('theme-import-json-field')),
      '{"version":1,"presetId":"paper_ink","backgroundStartColor":4294303458,"backgroundEndColor":4294303458,"keyColor":4294966260,"specialKeyColor":4293512649,"activeKeyColor":4281154086,"pressedKeyColor":4292993723,"textColor":4279917078,"cornerTextColor":4285160778,"statusTextColor":4282394669,"borderColor":4281960847,"borderWidth":1,"keyRadius":10,"shadowColor":855638016,"shadowBlur":3,"shadowOffsetY":1,"useGradient":false,"gradientStyle":"linear","useImage":false,"pressEffect":"none","effectIntensity":0.35,"effectDurationMs":170,"effectEasing":"easeOut"}',
    );
    await tester.tap(find.text('Preview import'));
    await tester.pump(const Duration(milliseconds: 200));

    final importedMessage = find.text(
      'Theme JSON imported into draft. Press Save to apply.',
    );
    await tester.scrollUntilVisible(
      importedMessage,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(importedMessage, findsOneWidget);
  });
}
