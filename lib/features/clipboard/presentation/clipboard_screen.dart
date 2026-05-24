import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../core/diagnostics/app_diagnostics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_components.dart';
import '../../../core/widgets/confirm_action_dialog.dart';
import '../../../core/widgets/local_mode_notice.dart';
import '../../settings/application/settings_store_provider.dart';
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
  final _searchController = TextEditingController();
  ClipboardCanonicalSource _source = ClipboardCanonicalSource.manual;
  bool _busy = false;
  String? _message;
  List<ClipboardItemRecord> _items = const [];

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_handleContentChanged);
    _searchController.addListener(_handleContentChanged);
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    _contentController.removeListener(_handleContentChanged);
    _searchController.removeListener(_handleContentChanged);
    _contentController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleContentChanged() {
    if (mounted) {
      setState(() {});
    }
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

  Future<void> _edit(ClipboardItemRecord item) async {
    final nextContent = await _showEditClipboardItemDialog(item);
    if (nextContent == null || nextContent == item.content) {
      return;
    }
    var sensitiveConfirmed = false;
    final classification = classifySensitiveContent(nextContent);
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
      await api.updateItemContent(
        id: item.id,
        content: nextContent,
        sensitiveConfirmed: sensitiveConfirmed,
      );
      await _load();
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'Modification impossible: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<String?> _showEditClipboardItemDialog(ClipboardItemRecord item) async {
    final controller = TextEditingController(text: item.content);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier le clipboard'),
          content: TextField(
            controller: controller,
            autofocus: true,
            minLines: 4,
            maxLines: 8,
            decoration: const InputDecoration(labelText: 'Clipboard content'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result?.trim();
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

  Future<void> _copyToSystemClipboard(ClipboardItemRecord item) async {
    await Clipboard.setData(ClipboardData(text: item.content));
    if (mounted) {
      setState(() => _message = 'Item clipboard copié.');
    }
  }

  Future<void> _remove(String id) async {
    final settings = await ref.read(settingsStoreProvider).load();
    if (!mounted) {
      return;
    }
    final confirmed = await showConfirmActionDialog(
      context: context,
      title: 'Delete clipboard item?',
      message:
          'This removes the item from WinFlowz clipboard history. This action cannot be undone from this screen.',
      confirmLabel: 'Delete',
      destructive: true,
      confirmationEnabled: settings.confirmDestructiveActions,
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
    final draftContent = _contentController.text.trim();
    final draftClassification = classifySensitiveContent(draftContent);
    final pinnedCount = _items.where((item) => item.pinned).length;
    final pendingCount = _items
        .where((item) => item.syncState == ClipboardSyncState.pending)
        .length;
    final latest = _items.isEmpty ? null : _items.first;
    final visibleItems = _filteredItems();
    return ListView(
      padding: AppInsets.screen,
      children: [
        const LocalModeNotice(surface: 'Clipboard'),
        const LocalModeNoticeGap(),
        _ClipboardOverviewCard(
          totalCount: _items.length,
          pinnedCount: pinnedCount,
          pendingCount: pendingCount,
          latest: latest,
        ),
        AppGaps.x2,
        AppSectionCard(
          title: 'Nouvel item clipboard',
          subtitle:
              'Ajoute un texte utile à retrouver depuis le clavier, ou importe les captures automatiques.',
          leading: Icon(
            Icons.content_paste_go_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _contentController,
                minLines: 2,
                maxLines: 6,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: 'Clipboard content',
                  hintText: 'Colle un message, un lien ou une commande...',
                ),
              ),
              AppGaps.x2,
              DropdownButtonFormField<ClipboardCanonicalSource>(
                initialValue: _source,
                items: ClipboardCanonicalSource.values
                    .where(
                      (source) =>
                          source == ClipboardCanonicalSource.manual ||
                          source == ClipboardCanonicalSource.system ||
                          source == ClipboardCanonicalSource.keyboard ||
                          source == ClipboardCanonicalSource.keyboardClipboard,
                    )
                    .map(
                      (source) => DropdownMenuItem(
                        value: source,
                        child: _SourceOption(source: source),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _busy
                    ? null
                    : (value) => setState(
                        () =>
                            _source = value ?? ClipboardCanonicalSource.manual,
                      ),
                decoration: const InputDecoration(labelText: 'Source'),
              ),
              if (draftClassification != ClipboardSensitiveClassification.none)
                Padding(
                  padding: AppInsets.stack,
                  child: _ClipboardInlineNotice(
                    icon: Icons.privacy_tip_outlined,
                    text:
                        'Contenu sensible détecté: ${draftClassification.label}. Une confirmation sera demandée avant sauvegarde.',
                    destructive: true,
                  ),
                ),
              AppGaps.x2,
              _DraftStatsRow(content: draftContent, source: _source),
              AppGaps.x3,
              AppFormActions(
                primaryLabel: 'Add clipboard item',
                primaryIcon: Icons.add_link,
                onPrimary: _busy || draftContent.isEmpty ? null : _add,
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
          Padding(
            padding: AppInsets.message,
            child: _ClipboardMessage(message: _message!),
          ),
        AppGaps.x4,
        const AppEntityListHeader(title: 'Clipboard items'),
        AppGaps.x2,
        TextField(
          controller: _searchController,
          enabled: _items.isNotEmpty,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Search history',
            hintText: 'Texte, source, sync...',
          ),
        ),
        AppGaps.x2,
        if (_items.isEmpty) const _EmptyClipboardState(),
        if (_items.isNotEmpty && visibleItems.isEmpty)
          const _EmptyClipboardSearchState(),
        for (final item in visibleItems)
          _ClipboardItemTile(
            item: item,
            onCopy: _busy ? null : () => _copyToSystemClipboard(item),
            onEdit: _busy ? null : () => _edit(item),
            onTogglePin: _busy ? null : () => _togglePin(item),
            onDelete: _busy ? null : () => _remove(item.id),
          ),
      ],
    );
  }

  List<ClipboardItemRecord> _filteredItems() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _items;
    }
    return _items
        .where((item) {
          final source = _sourceLabel(_sourceFrom(item)).toLowerCase();
          final sync = _syncLabel(item.syncState).toLowerCase();
          return item.content.toLowerCase().contains(query) ||
              source.contains(query) ||
              sync.contains(query);
        })
        .toList(growable: false);
  }
}

class _ClipboardOverviewCard extends StatelessWidget {
  const _ClipboardOverviewCard({
    required this.totalCount,
    required this.pinnedCount,
    required this.pendingCount,
    required this.latest,
  });

  final int totalCount;
  final int pinnedCount;
  final int pendingCount;
  final ClipboardItemRecord? latest;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final latestLabel = latest == null
        ? 'Aucune capture'
        : _formatShortDateTime(latest!.lastSeenAt);
    return Card(
      child: Padding(
        padding: AppInsets.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(
                    Icons.content_paste_search_outlined,
                    color: colorScheme.primary,
                  ),
                ),
                AppGaps.horizontalX3,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clipboard',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      AppGaps.x1,
                      Text(
                        'Historique local, captures clavier et éléments épinglés pour retrouver vite ce qui compte.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppGaps.x4,
            Wrap(
              spacing: AppSpacing.x2,
              runSpacing: AppSpacing.x2,
              children: [
                _ClipboardMetricPill(
                  icon: Icons.inventory_2_outlined,
                  label: '$totalCount',
                  value: totalCount == 1 ? 'item' : 'items',
                ),
                _ClipboardMetricPill(
                  icon: Icons.push_pin_outlined,
                  label: '$pinnedCount',
                  value: pinnedCount == 1 ? 'épinglé' : 'épinglés',
                ),
                _ClipboardMetricPill(
                  icon: pendingCount > 0
                      ? Icons.sync_problem_outlined
                      : Icons.verified_outlined,
                  label: pendingCount > 0
                      ? '$pendingCount en attente'
                      : 'À jour',
                  value: 'sync',
                  color: pendingCount > 0
                      ? AppColors.warning
                      : AppColors.success,
                ),
                _ClipboardMetricPill(
                  icon: Icons.schedule,
                  label: latestLabel,
                  value: 'dernier vu',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  const _SourceOption({required this.source});

  final ClipboardCanonicalSource source;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_sourceIcon(source), size: 18),
        AppGaps.horizontalX2,
        Flexible(child: Text(_sourceLabel(source))),
      ],
    );
  }
}

class _DraftStatsRow extends StatelessWidget {
  const _DraftStatsRow({required this.content, required this.source});

  final String content;
  final ClipboardCanonicalSource source;

  @override
  Widget build(BuildContext context) {
    final length = content.length;
    final normalizedWords = content.isEmpty
        ? 0
        : content.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
    return Wrap(
      spacing: AppSpacing.x2,
      runSpacing: AppSpacing.x2,
      children: [
        AppTag(label: length == 0 ? 'Vide' : '$length caractère(s)'),
        AppTag(label: '$normalizedWords mot(s)'),
        AppTag(label: _sourceLabel(source)),
      ],
    );
  }
}

class _ClipboardMetricPill extends StatelessWidget {
  const _ClipboardMetricPill({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.primary;
    return Container(
      constraints: const BoxConstraints(minWidth: 148),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x3,
        vertical: AppSpacing.x2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: effectiveColor, size: 18),
          AppGaps.horizontalX2,
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClipboardMessage extends StatelessWidget {
  const _ClipboardMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lower = message.toLowerCase();
    final isError =
        lower.contains('error') ||
        lower.contains('erreur') ||
        lower.contains('impossible') ||
        lower.contains('non importee');
    final accent = isError ? colorScheme.error : colorScheme.primary;
    return Container(
      padding: AppInsets.compactCard,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: accent,
          ),
          AppGaps.horizontalX2,
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _ClipboardInlineNotice extends StatelessWidget {
  const _ClipboardInlineNotice({
    required this.icon,
    required this.text,
    this.destructive = false,
  });

  final IconData icon;
  final String text;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = destructive ? colorScheme.error : colorScheme.primary;
    return Container(
      padding: AppInsets.compactCard,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent),
          AppGaps.horizontalX2,
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _EmptyClipboardState extends StatelessWidget {
  const _EmptyClipboardState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: AppInsets.card,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.content_paste_off_outlined, color: colorScheme.primary),
            AppGaps.horizontalX3,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No clipboard item yet.',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  AppGaps.x1,
                  Text(
                    'Ajoute un item manuel ou rafraîchis pour importer les captures clavier Android.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyClipboardSearchState extends StatelessWidget {
  const _EmptyClipboardSearchState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: AppInsets.card,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.search_off, color: colorScheme.primary),
            AppGaps.horizontalX3,
            Expanded(
              child: Text(
                'Aucun item ne correspond à cette recherche.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClipboardItemTile extends StatelessWidget {
  const _ClipboardItemTile({
    required this.item,
    required this.onCopy,
    required this.onEdit,
    required this.onTogglePin,
    required this.onDelete,
  });

  final ClipboardItemRecord item;
  final VoidCallback? onCopy;
  final VoidCallback? onEdit;
  final VoidCallback? onTogglePin;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isError = item.syncState == ClipboardSyncState.error;
    return Card(
      child: Padding(
        padding: AppInsets.compactCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  item.pinned ? Icons.push_pin : _sourceIcon(_sourceFrom(item)),
                  color: item.pinned ? colorScheme.primary : null,
                ),
                AppGaps.horizontalX2,
                Expanded(
                  child: Text(
                    item.content,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                AppGaps.horizontalX2,
                Wrap(
                  spacing: AppIconMetrics.listActionSpacing,
                  children: [
                    IconButton(
                      tooltip: 'Copier',
                      onPressed: onCopy,
                      icon: const Icon(Icons.content_copy),
                    ),
                    IconButton(
                      tooltip: 'Modifier',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: item.pinned ? 'Unpin' : 'Pin',
                      onPressed: onTogglePin,
                      icon: Icon(
                        item.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ],
            ),
            AppGaps.x2,
            Wrap(
              spacing: AppSpacing.x2,
              runSpacing: AppSpacing.x1,
              children: [
                AppTag(label: item.sourceLabel),
                AppTag(label: _syncLabel(item.syncState)),
                AppTag(label: 'vu ${_formatShortDateTime(item.lastSeenAt)}'),
                if (item.captureCount > 1)
                  AppTag(label: '${item.captureCount} captures'),
                if (item.pinned)
                  AppTag(
                    label: 'Épinglé',
                    color: colorScheme.primary,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  ),
              ],
            ),
            if (isError && item.syncError != null) ...[
              AppGaps.x2,
              _ClipboardInlineNotice(
                icon: Icons.sync_problem_outlined,
                text: item.syncError!,
                destructive: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

ClipboardCanonicalSource _sourceFrom(ClipboardItemRecord item) {
  return ClipboardCanonicalSource.fromDatabase(item.source);
}

IconData _sourceIcon(ClipboardCanonicalSource source) {
  return switch (source) {
    ClipboardCanonicalSource.manual => Icons.edit_note,
    ClipboardCanonicalSource.voice => Icons.mic_none,
    ClipboardCanonicalSource.overlay => Icons.open_in_new,
    ClipboardCanonicalSource.system => Icons.content_paste,
    ClipboardCanonicalSource.keyboard => Icons.keyboard_alt_outlined,
    ClipboardCanonicalSource.keyboardVoice => Icons.keyboard_voice_outlined,
    ClipboardCanonicalSource.keyboardClipboard => Icons.keyboard_command_key,
  };
}

String _sourceLabel(ClipboardCanonicalSource source) {
  return switch (source) {
    ClipboardCanonicalSource.manual => 'Manual',
    ClipboardCanonicalSource.voice => 'Voice',
    ClipboardCanonicalSource.overlay => 'Overlay',
    ClipboardCanonicalSource.system => 'System clipboard',
    ClipboardCanonicalSource.keyboard => 'Keyboard',
    ClipboardCanonicalSource.keyboardVoice => 'Keyboard voice',
    ClipboardCanonicalSource.keyboardClipboard => 'Keyboard clipboard',
  };
}

String _syncLabel(ClipboardSyncState state) {
  return switch (state) {
    ClipboardSyncState.local => 'Local',
    ClipboardSyncState.pending => 'Sync pending',
    ClipboardSyncState.synced => 'Synced',
    ClipboardSyncState.error => 'Sync error',
    ClipboardSyncState.deleted => 'Deleted',
  };
}

String _formatShortDateTime(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month $hour:$minute';
}
