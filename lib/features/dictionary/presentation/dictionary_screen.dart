import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/diagnostics/app_diagnostics.dart';
import '../../../core/platform/android_keyboard_bridge.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_components.dart';
import '../../../core/widgets/confirm_action_dialog.dart';
import '../../../core/widgets/local_mode_notice.dart';
import '../application/dictionary_store_provider.dart';
import '../domain/dictionary_store.dart';

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  final _termController = TextEditingController();
  final _replacementController = TextEditingController();
  bool _caseSensitive = false;
  bool _busy = false;
  String? _message;
  List<DictionaryTermRecord> _items = const [];

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    _termController.dispose();
    _replacementController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final store = ref.read(dictionaryStoreProvider);
      final rows = await store.list();
      await _syncKeyboardRules(rows);
      AppDiagnostics.record(
        'dictionary_load',
        'store=${store.runtimeType}; items=${rows.length}',
      );
      if (mounted) {
        setState(() => _items = rows);
      }
    } catch (error) {
      AppDiagnostics.record('dictionary_load_error', error);
      if (mounted) {
        setState(() => _message = 'Erreur chargement dictionary: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _add() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final store = ref.read(dictionaryStoreProvider);
      await store.insert(
        term: _termController.text,
        replacement: _replacementController.text,
        caseSensitive: _caseSensitive,
      );
      _termController.clear();
      _replacementController.clear();
      setState(() => _caseSensitive = false);
      await _load();
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'Insertion dictionnaire impossible: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _edit(DictionaryTermRecord item) async {
    final term = TextEditingController(text: item.term);
    final replacement = TextEditingController(text: item.replacement);
    bool caseSensitive = item.caseSensitive;
    final submit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Edit dictionary term'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: term,
                      decoration: const InputDecoration(labelText: 'Term'),
                    ),
                    AppGaps.x2,
                    TextField(
                      controller: replacement,
                      decoration: const InputDecoration(
                        labelText: 'Replacement',
                      ),
                    ),
                    AppGaps.x2,
                    SwitchListTile(
                      dense: true,
                      contentPadding: AppInsets.none,
                      value: caseSensitive,
                      onChanged: (value) =>
                          setLocalState(() => caseSensitive = value),
                      title: const Text('Case sensitive'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (submit != true) {
      term.dispose();
      replacement.dispose();
      return;
    }

    setState(() => _busy = true);
    try {
      final store = ref.read(dictionaryStoreProvider);
      await store.update(
        id: item.id,
        term: term.text,
        replacement: replacement.text,
        caseSensitive: caseSensitive,
      );
      await _load();
    } catch (error) {
      if (mounted) {
        setState(
          () => _message = 'Mise à jour dictionnaire impossible: $error',
        );
      }
    } finally {
      term.dispose();
      replacement.dispose();
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _remove(String id) async {
    final confirmed = await showConfirmActionDialog(
      context: context,
      title: 'Delete dictionary term?',
      message:
          'This removes the personal dictionary rule. This action cannot be undone from this screen.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!mounted || !confirmed) {
      return;
    }
    setState(() => _busy = true);
    try {
      final store = ref.read(dictionaryStoreProvider);
      await store.softDelete(id);
      await _load();
    } catch (error) {
      if (mounted) {
        setState(
          () => _message = 'Suppression terme dictionnaire impossible: $error',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _syncKeyboardRules(List<DictionaryTermRecord> rows) async {
    try {
      await AndroidKeyboardBridge.setDictionaryRules(
        rows
            .map(
              (item) => AndroidKeyboardTextRule(
                trigger: item.term,
                replacement: item.replacement,
                caseSensitive: item.caseSensitive,
              ),
            )
            .toList(growable: false),
      );
    } catch (error) {
      AppDiagnostics.record('dictionary_keyboard_sync_error', error);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppDiagnostics.record('screen_build', 'Dictionary');
    return ListView(
      padding: AppInsets.screen,
      children: [
        const LocalModeNotice(surface: 'Dictionary'),
        const LocalModeNoticeGap(),
        AppSectionCard(
          title: 'Nouveau terme',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _termController,
                decoration: const InputDecoration(labelText: 'Term'),
              ),
              AppGaps.x2,
              TextField(
                controller: _replacementController,
                decoration: const InputDecoration(labelText: 'Replacement'),
              ),
              SwitchListTile(
                contentPadding: AppInsets.none,
                value: _caseSensitive,
                onChanged: _busy
                    ? null
                    : (value) => setState(() => _caseSensitive = value),
                title: const Text('Case sensitive'),
              ),
              AppFormActions(
                primaryLabel: 'Add term',
                onPrimary: _busy ? null : _add,
                onSecondary: _busy ? null : _load,
              ),
            ],
          ),
        ),
        if (_busy)
          const Padding(
            padding: AppInsets.progress,
            child: LinearProgressIndicator(),
          ),
        if (_message != null)
          Padding(padding: AppInsets.message, child: Text(_message!)),
        AppGaps.x4,
        const AppEntityListHeader(title: 'Dictionary terms'),
        AppGaps.x2,
        if (_items.isEmpty)
          const AppEmptyStateCard(message: 'No dictionary term yet.'),
        for (final item in _items)
          AppEntityListTile(
            title: Text(item.term),
            subtitle: Text(
              '${item.replacement}\ncaseSensitive: ${item.caseSensitive}',
            ),
            isThreeLine: true,
            actions: [
              IconButton(
                tooltip: 'Edit',
                onPressed: _busy ? null : () => _edit(item),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: _busy ? null : () => _remove(item.id),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
      ],
    );
  }
}
