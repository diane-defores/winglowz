import 'package:flutter_test/flutter_test.dart';
import 'package:winflowz_app/features/custom_action_buttons/data/in_memory_custom_action_button_store.dart';
import 'package:winflowz_app/features/custom_action_buttons/domain/custom_action_buttons.dart';

void main() {
  test('parses desktop key sequence into typed steps', () {
    final sequence = DesktopKeySequence.parse('Ctrl+W, N');

    expect(sequence.steps, hasLength(2));
    expect(sequence.steps.first.key, 'W');
    expect(sequence.steps.first.modifiers, contains(DesktopKeyModifier.ctrl));
    expect(sequence.steps.last.key, 'N');
    expect(sequence.steps.last.modifiers, isEmpty);
  });

  test('in-memory store persists normalized custom action buttons', () async {
    final store = InMemoryCustomActionButtonStore(
      clock: () => DateTime.utc(2026, 6, 11, 11),
    );

    await store.insert(
      title: '  Fenêtre suivante  ',
      icon: CustomActionButtonIcon.window,
      action: const CustomActionButtonAction(
        type: CustomActionButtonType.desktopKeySequence,
        value: ' Ctrl+W, N ',
      ),
    );

    final items = await store.list();
    expect(items, hasLength(1));
    expect(items.single.title, 'Fenêtre suivante');
    expect(items.single.icon, CustomActionButtonIcon.window);
    expect(items.single.action.value, 'Ctrl+W, N');
  });
}
