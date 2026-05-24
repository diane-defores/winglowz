import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/diagnostics/app_diagnostics.dart';
import '../../../core/platform/android_keyboard_bridge.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_components.dart';
import '../../../core/widgets/confirm_action_dialog.dart';
import '../../../core/widgets/local_mode_notice.dart';
import '../../settings/application/settings_store_provider.dart';
import '../application/snippet_store_provider.dart';
import '../domain/snippet_store.dart';

class SnippetsScreen extends ConsumerStatefulWidget {
  const SnippetsScreen({super.key});

  @override
  ConsumerState<SnippetsScreen> createState() => _SnippetsScreenState();
}

class _SnippetsScreenState extends ConsumerState<SnippetsScreen> {
  final _triggerController = TextEditingController();
  final _contentController = TextEditingController();
  final _labelController = TextEditingController();
  bool _busy = false;
  String? _message;
  List<SnippetRecord> _items = const [];

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    _triggerController.dispose();
    _contentController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final store = ref.read(snippetStoreProvider);
      final rows = await store.list();
      await _syncKeyboardRules(rows);
      AppDiagnostics.record(
        'snippet_load',
        'store=${store.runtimeType}; items=${rows.length}',
      );
      if (mounted) {
        setState(() => _items = rows);
      }
    } catch (error) {
      AppDiagnostics.record('snippet_load_error', error);
      if (mounted) {
        setState(() => _message = 'Erreur chargement snippets: $error');
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
      final store = ref.read(snippetStoreProvider);
      await store.insert(
        trigger: _triggerController.text,
        content: _contentController.text,
        label: _labelController.text,
      );
      _triggerController.clear();
      _contentController.clear();
      _labelController.clear();
      await _load();
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'Insertion snippet impossible: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _edit(SnippetRecord item) async {
    final trigger = TextEditingController(text: item.trigger);
    final content = TextEditingController(text: item.content);
    final label = TextEditingController(text: item.label ?? '');
    final submit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit snippet'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: trigger,
                  decoration: const InputDecoration(labelText: 'Trigger'),
                ),
                AppGaps.x2,
                TextField(
                  controller: content,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Content'),
                ),
                AppGaps.x2,
                TextField(
                  controller: label,
                  decoration: const InputDecoration(labelText: 'Label'),
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

    if (submit != true) {
      trigger.dispose();
      content.dispose();
      label.dispose();
      return;
    }

    setState(() => _busy = true);
    try {
      final store = ref.read(snippetStoreProvider);
      await store.update(
        id: item.id,
        trigger: trigger.text,
        content: content.text,
        label: label.text,
      );
      await _load();
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'Mise à jour snippet impossible: $error');
      }
    } finally {
      trigger.dispose();
      content.dispose();
      label.dispose();
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _remove(String id) async {
    final settings = await ref.read(settingsStoreProvider).load();
    if (!mounted) {
      return;
    }
    final confirmed = await showConfirmActionDialog(
      context: context,
      title: 'Delete snippet?',
      message:
          'This removes the snippet from your reusable text list. This action cannot be undone from this screen.',
      confirmLabel: 'Delete',
      destructive: true,
      confirmationEnabled: settings.confirmDestructiveActions,
    );
    if (!mounted || !confirmed) {
      return;
    }
    setState(() => _busy = true);
    try {
      final store = ref.read(snippetStoreProvider);
      await store.softDelete(id);
      await _load();
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'Suppression snippet impossible: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _syncKeyboardRules(List<SnippetRecord> rows) async {
    try {
      await AndroidKeyboardBridge.setSnippetRules(
        rows
            .map(
              (item) => AndroidKeyboardTextRule(
                trigger: item.trigger,
                replacement: item.content,
                caseSensitive: false,
              ),
            )
            .toList(growable: false),
      );
    } catch (error) {
      AppDiagnostics.record('snippet_keyboard_sync_error', error);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppDiagnostics.record('screen_build', 'Snippets');
    return ListView(
      padding: AppInsets.screen,
      children: [
        const LocalModeNotice(surface: 'Snippets'),
        const LocalModeNoticeGap(),
        AppSectionCard(
          title: 'Nouveau snippet',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _triggerController,
                decoration: const InputDecoration(labelText: 'Trigger'),
              ),
              AppGaps.x2,
              TextField(
                controller: _contentController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
              AppGaps.x2,
              TextField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Label (optional)',
                ),
              ),
              AppGaps.x3,
              AppFormActions(
                primaryLabel: 'Add snippet',
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
        const AppEntityListHeader(title: 'Snippets'),
        AppGaps.x2,
        if (_items.isEmpty) const AppEmptyStateCard(message: 'No snippet yet.'),
        for (final item in _items)
          AppEntityListTile(
            title: Text(item.trigger),
            subtitle: Text(
              '${item.label == null || item.label!.isEmpty ? '' : '[${item.label}] '}${item.content}',
            ),
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
