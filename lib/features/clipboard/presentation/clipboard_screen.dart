import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/diagnostics/app_diagnostics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_components.dart';
import '../../../core/widgets/confirm_action_dialog.dart';
import '../../../core/widgets/local_mode_notice.dart';
import '../application/clipboard_store_provider.dart';
import '../domain/clipboard_capture_event.dart';
import '../domain/clipboard_normalizer.dart';
import '../domain/clipboard_store.dart';

class ClipboardScreen extends ConsumerStatefulWidget {
  const ClipboardScreen({super.key});

  @override
  ConsumerState<ClipboardScreen> createState() => _ClipboardScreenState();
}

class _ClipboardScreenState extends ConsumerState<ClipboardScreen> {
  final _contentController = TextEditingController();
  ClipboardCanonicalSource _source = ClipboardCanonicalSource.manual;
  bool _busy = false;
  String? _message;
  List<ClipboardItemRecord> _items = const [];

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final api = ref.read(clipboardHistoryApiProvider);
      final importer = ref.read(keyboardClipboardEventImporterProvider);
      final importResult = await importer.drainFromAndroidKeyboard();
      final rows = await api.listItems();
      AppDiagnostics.record(
        'clipboard_load',
        'api=${api.runtimeType}; items=${rows.length}; imported=${importResult.imported}; failed=${importResult.failed}; rejected_sensitive=${importResult.rejectedSensitive}',
      );
      if (mounted) {
        setState(() {
          _items = rows;
          if (importResult.rejectedSensitive > 0) {
            _message =
                '${importResult.rejectedSensitive} capture clavier sensible ignoree.';
          } else if (importResult.failed > 0) {
            _message = '${importResult.failed} capture clavier non importee.';
          } else if (importResult.imported > 0) {
            _message = '${importResult.imported} capture clavier importee.';
          }
        });
      }
    } catch (error) {
      AppDiagnostics.record('clipboard_load_error', error);
      if (mounted) {
        setState(() => _message = 'Erreur chargement clipboard: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _add() async {
    var sensitiveConfirmed = false;
    final classification = classifySensitiveContent(_contentController.text);
    if (classification != ClipboardSensitiveClassification.none) {
      sensitiveConfirmed = await _confirmSensitiveSave(classification);
      if (!sensitiveConfirmed) {
        return;
      }
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final api = ref.read(clipboardHistoryApiProvider);
      await api.addManualItem(
        content: _contentController.text,
        source: _source,
        sensitiveConfirmed: sensitiveConfirmed,
      );
      _contentController.clear();
      await _load();
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'Insertion impossible: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<bool> _confirmSensitiveSave(
    ClipboardSensitiveClassification classification,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Contenu sensible'),
          content: Text(
            'Ce contenu ressemble a: ${classification.label}. Le sauvegarder dans le clipboard ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  Future<void> _togglePin(ClipboardItemRecord item) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final api = ref.read(clipboardHistoryApiProvider);
      await api.setPinned(id: item.id, pinned: !item.pinned);
      await _load();
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'Pin update impossible: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _remove(String id) async {
    final confirmed = await showConfirmActionDialog(
      context: context,
      title: 'Delete clipboard item?',
      message:
          'This removes the item from WinFlowz clipboard history. This action cannot be undone from this screen.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!mounted || !confirmed) {
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final api = ref.read(clipboardHistoryApiProvider);
      await api.removeItem(id);
      await _load();
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'Suppression impossible: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppDiagnostics.record('screen_build', 'Clipboard');
    return ListView(
      padding: AppInsets.screen,
      children: [
        const LocalModeNotice(surface: 'Clipboard'),
        const LocalModeNoticeGap(),
        AppSectionCard(
          title: 'Nouvel item clipboard',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _contentController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Clipboard content',
                ),
              ),
              AppGaps.x2,
              DropdownButtonFormField<ClipboardCanonicalSource>(
                initialValue: _source,
                items: const [
                  DropdownMenuItem(
                    value: ClipboardCanonicalSource.manual,
                    child: Text('manual'),
                  ),
                  DropdownMenuItem(
                    value: ClipboardCanonicalSource.voice,
                    child: Text('voice'),
                  ),
                  DropdownMenuItem(
                    value: ClipboardCanonicalSource.overlay,
                    child: Text('overlay'),
                  ),
                  DropdownMenuItem(
                    value: ClipboardCanonicalSource.system,
                    child: Text('system'),
                  ),
                  DropdownMenuItem(
                    value: ClipboardCanonicalSource.keyboard,
                    child: Text('keyboard'),
                  ),
                  DropdownMenuItem(
                    value: ClipboardCanonicalSource.keyboardVoice,
                    child: Text('keyboard voice'),
                  ),
                  DropdownMenuItem(
                    value: ClipboardCanonicalSource.keyboardClipboard,
                    child: Text('keyboard clipboard'),
                  ),
                ],
                onChanged: _busy
                    ? null
                    : (value) => setState(
                        () =>
                            _source = value ?? ClipboardCanonicalSource.manual,
                      ),
                decoration: const InputDecoration(labelText: 'Source'),
              ),
              AppGaps.x3,
              AppFormActions(
                primaryLabel: 'Add clipboard item',
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
        const AppEntityListHeader(title: 'Clipboard items'),
        AppGaps.x2,
        if (_items.isEmpty)
          const AppEmptyStateCard(message: 'No clipboard item yet.'),
        for (final item in _items)
          AppEntityListTile(
            title: Text(item.content),
            subtitle: Text('source: ${item.sourceLabel}'),
            actions: [
              IconButton(
                tooltip: item.pinned ? 'Unpin' : 'Pin',
                onPressed: _busy ? null : () => _togglePin(item),
                icon: Icon(
                  item.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                ),
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
