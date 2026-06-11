import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winflowz_app/features/custom_action_buttons/application/custom_action_button_runner.dart';
import 'package:winflowz_app/features/custom_action_buttons/domain/custom_action_buttons.dart';

const _windowsOverlayChannel = MethodChannel('winflowz_app/windows_overlay');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_windowsOverlayChannel, null);
  });

  test(
    'runner sends desktop key sequence through the desktop bridge',
    () async {
      final previousPlatform = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = previousPlatform);
      MethodCall? capturedCall;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_windowsOverlayChannel, (call) async {
            capturedCall = call;
            if (call.method == 'deliverWindowsOverlayKeySequence') {
              return {'status': 'delivered', 'sentSteps': 2};
            }
            return null;
          });

      final result = await const CustomActionButtonRunner().run(
        CustomActionButtonRecord(
          id: 'button-1',
          title: 'Fenêtre suivante',
          icon: CustomActionButtonIcon.window,
          action: const CustomActionButtonAction(
            type: CustomActionButtonType.desktopKeySequence,
            value: 'Ctrl+W, N',
          ),
          createdAt: DateTime.utc(2026, 6, 11, 11),
        ),
      );

      expect(result.success, isTrue);
      expect(result.message, 'Séquence envoyée.');
      expect(capturedCall?.method, 'deliverWindowsOverlayKeySequence');
      final arguments = capturedCall?.arguments as Map<Object?, Object?>?;
      final steps = arguments?['steps'] as List<Object?>?;
      expect(steps, hasLength(2));
      final firstStep = steps!.first as Map<Object?, Object?>;
      expect(firstStep['key'], 'W');
      expect(firstStep['modifiers'], contains('ctrl'));
    },
  );

  test('runner surfaces clipboard-only text delivery as success', () async {
    final previousPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = previousPlatform);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_windowsOverlayChannel, (call) async {
          if (call.method == 'deliverWindowsOverlayText') {
            return {
              'status': 'clipboard_only',
              'clipboardCopied': true,
              'pasteAttempted': true,
              'pasteSucceeded': false,
            };
          }
          return null;
        });

    final result = await const CustomActionButtonRunner().run(
      CustomActionButtonRecord(
        id: 'button-2',
        title: 'Réponse',
        icon: CustomActionButtonIcon.spark,
        action: const CustomActionButtonAction(
          type: CustomActionButtonType.textSnippet,
          value: 'Réponse prête',
        ),
        createdAt: DateTime.utc(2026, 6, 11, 11),
      ),
    );

    expect(result.success, isTrue);
    expect(result.message, 'Texte copié; collage direct indisponible.');
  });
}
