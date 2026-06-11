import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winflowz_app/core/theme/app_theme.dart';
import 'package:winflowz_app/features/custom_action_buttons/application/custom_action_button_store_provider.dart';
import 'package:winflowz_app/features/custom_action_buttons/data/in_memory_custom_action_button_store.dart';
import 'package:winflowz_app/features/snippets/presentation/custom_action_buttons_panel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('custom action buttons can be created from the panel', (
    tester,
  ) async {
    final store = InMemoryCustomActionButtonStore();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localCustomActionButtonStoreProvider.overrideWithValue(store),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: CustomActionButtonsPanel(
              surfaceSelector: const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    await tester.enterText(
      find.byKey(const Key('custom-button-title-field')),
      'Fenêtre suivante',
    );
    await tester.tap(find.text('Séquence'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.enterText(
      find.byKey(const Key('custom-button-value-field')),
      'Ctrl+W, N',
    );
    await tester.tap(find.byKey(const Key('custom-button-create-button')));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Fenêtre suivante'), findsWidgets);
  });
}
