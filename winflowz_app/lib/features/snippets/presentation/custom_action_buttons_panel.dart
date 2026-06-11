import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/platform_capabilities.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_components.dart';
import '../../../core/widgets/confirm_action_dialog.dart';
import '../../custom_action_buttons/application/custom_action_button_runner.dart';
import '../../custom_action_buttons/application/custom_action_button_store_provider.dart';
import '../../custom_action_buttons/domain/custom_action_buttons.dart';
import '../../settings/application/settings_store_provider.dart';

class CustomActionButtonsPanel extends ConsumerStatefulWidget {
  const CustomActionButtonsPanel({super.key, required this.surfaceSelector});

  final Widget surfaceSelector;

  @override
  ConsumerState<CustomActionButtonsPanel> createState() =>
      _CustomActionButtonsPanelState();
}

class _CustomActionButtonsPanelState
    extends ConsumerState<CustomActionButtonsPanel> {
  final _titleController = TextEditingController();
  final _valueController = TextEditingController();
  final _runner = const CustomActionButtonRunner();

  List<CustomActionButtonRecord> _items = const [];
  CustomActionButtonType _selectedType = CustomActionButtonType.textSnippet;
  CustomActionButtonIcon _selectedIcon = CustomActionButtonIcon.spark;
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final rows = await ref.read(customActionButtonStoreProvider).list();
      if (mounted) {
        setState(() => _items = rows);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'Chargement boutons impossible: $error');
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
      await ref
          .read(customActionButtonStoreProvider)
          .insert(
            title: _titleController.text,
            icon: _selectedIcon,
            action: CustomActionButtonAction(
              type: _selectedType,
              value: _valueController.text,
            ),
          );
      _titleController.clear();
      _valueController.clear();
      _selectedType = CustomActionButtonType.textSnippet;
      _selectedIcon = CustomActionButtonIcon.spark;
      await _load();
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'Création bouton impossible: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _edit(CustomActionButtonRecord item) async {
    final titleController = TextEditingController(text: item.title);
    final valueController = TextEditingController(text: item.action.value);
    var type = item.action.type;
    var icon = item.icon;
    final submit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Modifier le bouton'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Nom'),
                    ),
                    AppGaps.x2,
                    _TypeSelector(
                      selected: type,
                      onSelected: (next) => setLocalState(() => type = next),
                    ),
                    AppGaps.x2,
                    _ActionValueField(controller: valueController, type: type),
                    AppGaps.x2,
                    _IconSelector(
                      selected: icon,
                      onSelected: (next) => setLocalState(() => icon = next),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );

    if (submit != true) {
      titleController.dispose();
      valueController.dispose();
      return;
    }

    setState(() => _busy = true);
    try {
      await ref
          .read(customActionButtonStoreProvider)
          .update(
            id: item.id,
            title: titleController.text,
            icon: icon,
            action: CustomActionButtonAction(
              type: type,
              value: valueController.text,
            ),
          );
      await _load();
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'Mise à jour bouton impossible: $error');
      }
    } finally {
      titleController.dispose();
      valueController.dispose();
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _remove(CustomActionButtonRecord item) async {
    final settings = await ref.read(settingsStoreProvider).load();
    if (!mounted) {
      return;
    }
    final confirmed = await showConfirmActionDialog(
      context: context,
      title: 'Supprimer le bouton ?',
      message:
          'Cette action retire définitivement ce bouton personnalisé de ta bibliothèque.',
      confirmLabel: 'Supprimer',
      destructive: true,
      confirmationEnabled: settings.confirmDestructiveActions,
    );
    if (!mounted || !confirmed) {
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(customActionButtonStoreProvider).softDelete(item.id);
      await _load();
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'Suppression bouton impossible: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _run(CustomActionButtonRecord item) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    final result = await _runner.run(item);
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      _message = result.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppInsets.screen,
      children: [
        widget.surfaceSelector,
        AppGaps.x2,
        ProductSummaryStrip(
          children: [
            const AppLocalModeStatusPill(),
            AppMetricPill(
              icon: Icons.smart_button_outlined,
              label: '${_items.length}',
              value: _items.length > 1 ? 'boutons' : 'bouton',
            ),
            AppMetricPill(
              icon: Icons.desktop_windows_outlined,
              label: _desktopSupportLabel,
              value: 'exécution',
            ),
          ],
        ),
        AppGaps.x2,
        AppSectionCard(
          title: 'Nouveau bouton',
          subtitle:
              'Crée un bouton exécutable avec icône et action typée. Les séquences desktop acceptent par exemple `Ctrl+W, N`.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('custom-button-title-field'),
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Nom du bouton'),
              ),
              AppGaps.x2,
              _TypeSelector(
                selected: _selectedType,
                onSelected: (next) => setState(() => _selectedType = next),
              ),
              AppGaps.x2,
              _ActionValueField(
                controller: _valueController,
                type: _selectedType,
              ),
              AppGaps.x2,
              _IconSelector(
                selected: _selectedIcon,
                onSelected: (next) => setState(() => _selectedIcon = next),
              ),
              AppGaps.x2,
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  key: const Key('custom-button-create-button'),
                  onPressed: _busy ? null : _add,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Créer le bouton'),
                ),
              ),
            ],
          ),
        ),
        AppGaps.x2,
        if (_message != null)
          AppBannerCard(
            icon: _message!.contains('impossible') || _message!.contains('non')
                ? Icons.info_outline
                : Icons.check_circle_outline,
            title: 'Statut boutons',
            message: _message!,
          ),
        if (_message != null) AppGaps.x2,
        if (_items.isEmpty)
          const AppEmptyStateCard(
            title: 'Aucun bouton',
            message:
                'Crée ton premier bouton pour lancer un texte, une expression clavier ou une séquence desktop.',
          )
        else
          AppSectionCard(
            title: 'Boutons personnalisés',
            padding: AppInsets.compactCard,
            stretch: false,
            child: Column(
              children: [
                for (final item in _items) ...[
                  AppEntityCard(
                    leading: Icon(item.icon.iconData),
                    title: Text(item.title),
                    subtitle: Text(_subtitle(item)),
                    bodyMaxLines: 3,
                    actions: [
                      IconButton(
                        tooltip: 'Lancer',
                        onPressed: _busy ? null : () => _run(item),
                        icon: const Icon(Icons.play_arrow_outlined),
                      ),
                      IconButton(
                        tooltip: 'Modifier',
                        onPressed: _busy ? null : () => _edit(item),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Supprimer',
                        onPressed: _busy ? null : () => _remove(item),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  AppGaps.x1,
                ],
              ],
            ),
          ),
      ],
    );
  }

  String _subtitle(CustomActionButtonRecord item) {
    final typeLabel = switch (item.action.type) {
      CustomActionButtonType.textSnippet => 'Texte',
      CustomActionButtonType.keyboardExpression => 'Expression clavier',
      CustomActionButtonType.desktopKeySequence => 'Séquence desktop',
    };
    return '$typeLabel · ${item.action.value}';
  }

  String get _desktopSupportLabel {
    if (PlatformCapabilities.isWindows || PlatformCapabilities.isMacOS) {
      return 'desktop natif';
    }
    if (PlatformCapabilities.isLinux) {
      return 'linux limité';
    }
    return 'hors desktop';
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.selected, required this.onSelected});

  final CustomActionButtonType selected;
  final ValueChanged<CustomActionButtonType> onSelected;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<CustomActionButtonType>(
      segments: const [
        ButtonSegment(
          value: CustomActionButtonType.textSnippet,
          label: Text('Texte'),
          icon: Icon(Icons.text_snippet_outlined),
        ),
        ButtonSegment(
          value: CustomActionButtonType.desktopKeySequence,
          label: Text('Séquence'),
          icon: Icon(Icons.keyboard_command_key),
        ),
        ButtonSegment(
          value: CustomActionButtonType.keyboardExpression,
          label: Text('Expression'),
          icon: Icon(Icons.auto_fix_high_outlined),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (values) {
        final next = values.isEmpty ? selected : values.first;
        onSelected(next);
      },
    );
  }
}

class _ActionValueField extends StatelessWidget {
  const _ActionValueField({required this.controller, required this.type});

  final TextEditingController controller;
  final CustomActionButtonType type;

  @override
  Widget build(BuildContext context) {
    final (label, hint) = switch (type) {
      CustomActionButtonType.textSnippet => (
        'Texte ou snippet',
        'Réponse prête à coller',
      ),
      CustomActionButtonType.desktopKeySequence => (
        'Séquence clavier desktop',
        'Ctrl+W, N',
      ),
      CustomActionButtonType.keyboardExpression => (
        'Expression clavier WinFlowz',
        'action:Undo',
      ),
    };
    return TextField(
      key: const Key('custom-button-value-field'),
      controller: controller,
      minLines: 2,
      maxLines: 4,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}

class _IconSelector extends StatelessWidget {
  const _IconSelector({required this.selected, required this.onSelected});

  final CustomActionButtonIcon selected;
  final ValueChanged<CustomActionButtonIcon> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.x2,
      runSpacing: AppSpacing.x1,
      children: [
        for (final icon in CustomActionButtonIcon.values)
          ChoiceChip(
            label: Text(icon.label),
            avatar: Icon(icon.iconData, size: 18),
            selected: selected == icon,
            onSelected: (_) => onSelected(icon),
          ),
      ],
    );
  }
}
