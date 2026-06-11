import '../domain/custom_action_button_store.dart';
import '../domain/custom_action_buttons.dart';

class InMemoryCustomActionButtonStore implements CustomActionButtonStore {
  InMemoryCustomActionButtonStore({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final List<CustomActionButtonRecord> _items = <CustomActionButtonRecord>[];
  var _nextId = 1;

  @override
  Future<List<CustomActionButtonRecord>> list() async {
    final items = List<CustomActionButtonRecord>.from(_items);
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<void> insert({
    required String title,
    required CustomActionButtonIcon icon,
    required CustomActionButtonAction action,
  }) async {
    final normalized = _normalize(title: title, action: action);
    _items.add(
      CustomActionButtonRecord(
        id: 'button-${_nextId++}',
        title: normalized.$1,
        icon: icon,
        action: normalized.$2,
        createdAt: _clock().toUtc(),
      ),
    );
  }

  @override
  Future<void> update({
    required String id,
    required String title,
    required CustomActionButtonIcon icon,
    required CustomActionButtonAction action,
  }) async {
    final index = _indexOf(id);
    final existing = _items[index];
    final normalized = _normalize(title: title, action: action);
    _items[index] = CustomActionButtonRecord(
      id: existing.id,
      title: normalized.$1,
      icon: icon,
      action: normalized.$2,
      createdAt: existing.createdAt,
    );
  }

  @override
  Future<void> softDelete(String id) async {
    _items.removeAt(_indexOf(id));
  }

  int _indexOf(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) {
      throw StateError('Custom action button not found.');
    }
    return index;
  }

  (String, CustomActionButtonAction) _normalize({
    required String title,
    required CustomActionButtonAction action,
  }) {
    final normalizedTitle = title.trim();
    final normalizedAction = CustomActionButtonAction(
      type: action.type,
      value: action.trimmedValue,
    );
    if (normalizedTitle.isEmpty || normalizedAction.value.isEmpty) {
      throw const FormatException(
        'Le nom du bouton et son action sont obligatoires.',
      );
    }
    if (normalizedAction.type == CustomActionButtonType.desktopKeySequence) {
      DesktopKeySequence.parse(normalizedAction.value);
    }
    return (normalizedTitle, normalizedAction);
  }
}
