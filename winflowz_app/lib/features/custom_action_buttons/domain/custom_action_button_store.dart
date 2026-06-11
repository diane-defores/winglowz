import 'custom_action_buttons.dart';

abstract class CustomActionButtonStore {
  Future<List<CustomActionButtonRecord>> list();

  Future<void> insert({
    required String title,
    required CustomActionButtonIcon icon,
    required CustomActionButtonAction action,
  });

  Future<void> update({
    required String id,
    required String title,
    required CustomActionButtonIcon icon,
    required CustomActionButtonAction action,
  });

  Future<void> softDelete(String id);
}
