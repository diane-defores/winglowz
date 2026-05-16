part of "keyboard_preview_screen.dart";

class _PreviewControlsValue {
  const _PreviewControlsValue({
    required this.profile,
    required this.fieldContext,
    required this.panel,
    required this.mode,
    required this.privateMode,
    required this.corners,
    required this.debug,
    required this.cornerConfig,
  });

  final KeyboardLayoutProfile profile;
  final KeyboardPreviewFieldContext fieldContext;
  final KeyboardPreviewPanel panel;
  final KeyboardPreviewMode mode;
  final bool privateMode;
  final bool corners;
  final bool debug;
  final AndroidKeyboardCornerConfig cornerConfig;
}

class _PreviewControlsActions {
  const _PreviewControlsActions({
    required this.onProfileChanged,
    required this.onFieldContextChanged,
    required this.onPanelChanged,
    required this.onModeChanged,
    required this.onPrivateModeChanged,
    required this.onCornersChanged,
    required this.onDebugChanged,
    required this.onCornerPresetChanged,
  });

  final ValueChanged<KeyboardLayoutProfile> onProfileChanged;
  final ValueChanged<KeyboardPreviewFieldContext> onFieldContextChanged;
  final ValueChanged<KeyboardPreviewPanel> onPanelChanged;
  final ValueChanged<KeyboardPreviewMode> onModeChanged;
  final ValueChanged<bool> onPrivateModeChanged;
  final ValueChanged<bool> onCornersChanged;
  final ValueChanged<bool> onDebugChanged;
  final ValueChanged<String> onCornerPresetChanged;
}

class _PreviewControls extends StatelessWidget {
  const _PreviewControls({required this.value, required this.actions});

  final _PreviewControlsValue value;
  final _PreviewControlsActions actions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppInsets.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.x3,
              runSpacing: AppSpacing.x3,
              children: [
                _Dropdown<KeyboardLayoutProfile>(
                  fieldKey: const Key('keyboard-preview-profile-dropdown'),
                  label: 'Profile',
                  value: value.profile,
                  values: KeyboardLayoutProfile.values,
                  labelFor: (value) => value.name.toUpperCase(),
                  onChanged: actions.onProfileChanged,
                ),
                _Dropdown<KeyboardPreviewFieldContext>(
                  fieldKey: const Key('keyboard-preview-field-dropdown'),
                  label: 'Field',
                  value: value.fieldContext,
                  values: KeyboardPreviewFieldContext.values,
                  labelFor: (value) => value.label,
                  onChanged: actions.onFieldContextChanged,
                ),
                _Dropdown<KeyboardPreviewPanel>(
                  fieldKey: const Key('keyboard-preview-panel-dropdown'),
                  label: 'Panel',
                  value: value.panel,
                  values: KeyboardPreviewPanel.values,
                  labelFor: (value) => value.label,
                  onChanged: actions.onPanelChanged,
                ),
                _Dropdown<KeyboardPreviewMode>(
                  fieldKey: const Key('keyboard-preview-mode-dropdown'),
                  label: 'Mode',
                  value: value.mode,
                  values: KeyboardPreviewMode.values,
                  labelFor: (value) => value.label,
                  onChanged: value.fieldContext.numeric
                      ? null
                      : actions.onModeChanged,
                ),
                _Dropdown<String>(
                  fieldKey: const Key(
                    'keyboard-preview-corner-preset-dropdown',
                  ),
                  label: 'Corners',
                  value: value.cornerConfig.presetId,
                  values: KeyboardCornerPresetCatalog.presets
                      .map((preset) => preset.id)
                      .toList(growable: false),
                  labelFor: (value) => KeyboardCornerPresetCatalog.presets
                      .firstWhere((preset) => preset.id == value)
                      .name,
                  onChanged: actions.onCornerPresetChanged,
                ),
              ],
            ),
            AppGaps.x3,
            Wrap(
              spacing: AppSpacing.x2,
              runSpacing: AppSpacing.x2,
              children: [
                FilterChip(
                  selected: value.corners,
                  onSelected: actions.onCornersChanged,
                  avatar: const Icon(Icons.open_in_full_outlined),
                  label: const Text('Corners'),
                ),
                FilterChip(
                  selected: value.privateMode,
                  onSelected: actions.onPrivateModeChanged,
                  avatar: const Icon(Icons.lock_outline),
                  label: const Text('Private'),
                ),
                FilterChip(
                  selected: value.debug,
                  onSelected: actions.onDebugChanged,
                  avatar: const Icon(Icons.bug_report_outlined),
                  label: const Text('Debug'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    this.fieldKey,
    required this.label,
    required this.value,
    required this.values,
    required this.labelFor,
    required this.onChanged,
  });

  final Key? fieldKey;
  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppKeyboardPreview.dropdownWidth,
      child: DropdownButtonFormField<T>(
        key: fieldKey,
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final item in values)
            DropdownMenuItem(
              value: item,
              child: Text(
                labelFor(item),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: onChanged == null
            ? null
            : (value) {
                if (value != null) {
                  onChanged!(value);
                }
              },
      ),
    );
  }
}

class _KeyboardFrame extends StatelessWidget {
  const _KeyboardFrame({
    required this.snapshot,
    required this.buffer,
    required this.cursor,
    required this.status,
    required this.onKeyPressed,
    required this.onKeyLongPressed,
    required this.onClear,
    required this.onReset,
  });

  final KeyboardPreviewSnapshot snapshot;
  final String buffer;
  final int cursor;
  final String status;
  final ValueChanged<KeyboardPreviewKey> onKeyPressed;
  final ValueChanged<KeyboardPreviewKey> onKeyLongPressed;
  final VoidCallback onClear;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final rows = snapshot.rows;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppKeyboardPreview.maxWidth,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: snapshot.privateMode
                ? AppColors.keyboardPrivateFrame
                : AppColors.keyboardDefaultFrame,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.x2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _KeyboardStatus(snapshot: snapshot),
                AppGaps.x2,
                _KeyboardInputSurface(
                  buffer: buffer,
                  cursor: cursor,
                  status: status,
                  onClear: onClear,
                  onReset: onReset,
                ),
                AppGaps.x2,
                for (final row in rows.indexed) ...[
                  _KeyboardRow(
                    row: row.$2,
                    debug: snapshot.debug,
                    onKeyPressed: onKeyPressed,
                    onKeyLongPressed: onKeyLongPressed,
                  ),
                  if (row.$1 != rows.length - 1) AppGaps.x2,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyboardStatus extends StatelessWidget {
  const _KeyboardStatus({required this.snapshot});

  final KeyboardPreviewSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final text = snapshot.privateMode
        ? 'WinFlowz keyboard - private input'
        : 'WinFlowz keyboard - ${snapshot.fieldContext.label}';
    return SizedBox(
      height: AppKeyboardPreview.statusHeight,
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.keyboardStatusText,
            fontWeight: AppFontWeights.bold,
          ),
        ),
      ),
    );
  }
}

class _KeyboardRow extends StatelessWidget {
  const _KeyboardRow({
    required this.row,
    required this.debug,
    required this.onKeyPressed,
    required this.onKeyLongPressed,
  });

  final KeyboardPreviewRow row;
  final bool debug;
  final ValueChanged<KeyboardPreviewKey> onKeyPressed;
  final ValueChanged<KeyboardPreviewKey> onKeyLongPressed;

  @override
  Widget build(BuildContext context) {
    if (row.horizontalScrollable) {
      return SizedBox(
        height: row.height,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final key in row.keys) ...[
                SizedBox(
                  width: (key.weight * 84).clamp(72, 180).toDouble(),
                  child: _KeyCap(
                    keySpec: key,
                    debug: debug,
                    onPressed: () => onKeyPressed(key),
                    onLongPressed: () => onKeyLongPressed(key),
                  ),
                ),
                if (key != row.keys.last) AppGaps.horizontalX2,
              ],
            ],
          ),
        ),
      );
    }
    return SizedBox(
      height: row.height,
      child: Row(
        children: [
          if (row.leadingWeight > 0)
            Spacer(flex: (row.leadingWeight * 100).round()),
          for (final key in row.keys) ...[
            Expanded(
              flex: (key.weight * AppKeyboardPreview.keyWeightScale).round(),
              child: _KeyCap(
                keySpec: key,
                debug: debug,
                onPressed: () => onKeyPressed(key),
                onLongPressed: () => onKeyLongPressed(key),
              ),
            ),
            if (key != row.keys.last) AppGaps.horizontalX2,
          ],
          if (row.trailingWeight > 0)
            Spacer(
              flex: (row.trailingWeight * AppKeyboardPreview.keyWeightScale)
                  .round(),
            ),
        ],
      ),
    );
  }
}

class _KeyCap extends StatelessWidget {
  const _KeyCap({
    required this.keySpec,
    required this.debug,
    required this.onPressed,
    required this.onLongPressed,
  });

  final KeyboardPreviewKey keySpec;
  final bool debug;
  final VoidCallback onPressed;
  final VoidCallback onLongPressed;

  @override
  Widget build(BuildContext context) {
    final background = keySpec.active
        ? AppColors.keyboardKeyActive
        : keySpec.special
        ? AppColors.keyboardKeySpecial
        : AppColors.white;
    final foreground = keySpec.active
        ? AppColors.white
        : AppColors.keyboardKeyForeground;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        onTap: onPressed,
        onLongPress: onLongPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: keySpec.enabled ? background : AppColors.keyboardKeyDisabled,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(
              color: debug ? AppColors.danger : AppColors.borderLight,
              width: debug
                  ? AppKeyboardPreview.keyDebugBorderWidth
                  : AppKeyboardPreview.keyBorderWidth,
            ),
          ),
          child: Stack(
            children: [
              if (keySpec.topLeftShortcut != null)
                _CornerLabel(
                  text: keySpec.topLeftShortcut!.displayLabel,
                  alignment: Alignment.topLeft,
                ),
              if (keySpec.topRightShortcut != null)
                _CornerLabel(
                  text: keySpec.topRightShortcut!.displayLabel,
                  alignment: Alignment.topRight,
                ),
              if (keySpec.bottomLeftShortcut != null)
                _CornerLabel(
                  text: keySpec.bottomLeftShortcut!.displayLabel,
                  alignment: Alignment.bottomLeft,
                ),
              if (keySpec.bottomRightShortcut != null)
                _CornerLabel(
                  text: keySpec.bottomRightShortcut!.displayLabel,
                  alignment: Alignment.bottomRight,
                ),
              if (keySpec.pinned) const _PinnedBadge(),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.x1,
                    ),
                    child: Text(
                      keySpec.label,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: foreground,
                        fontWeight: AppFontWeights.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinnedBadge extends StatelessWidget {
  const _PinnedBadge();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 5,
      right: 5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: .92),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.keyboardKeyForeground, width: 1),
        ),
        child: const SizedBox(width: 8, height: 8),
      ),
    );
  }
}

class _KeyboardInputSurface extends StatelessWidget {
  const _KeyboardInputSurface({
    required this.buffer,
    required this.cursor,
    required this.status,
    required this.onClear,
    required this.onReset,
  });

  final String buffer;
  final int cursor;
  final String status;
  final VoidCallback onClear;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final clamped = cursor.clamp(0, buffer.length);
    final withCursor =
        '${buffer.substring(0, clamped)}|${buffer.substring(clamped)}';
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: AppInsets.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Simulated input',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: AppFontWeights.bold),
            ),
            AppGaps.x1,
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: AppSpacing.x8),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x2,
                vertical: AppSpacing.x1,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: SelectableText(
                withCursor,
                key: const Key('keyboard-preview-simulated-buffer'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            AppGaps.x1,
            Text(
              status,
              key: const Key('keyboard-preview-simulated-status'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            AppGaps.x2,
            Wrap(
              spacing: AppSpacing.x2,
              runSpacing: AppSpacing.x2,
              children: [
                OutlinedButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: const Text('Clear'),
                ),
                OutlinedButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.restart_alt_outlined),
                  label: const Text('Reset sandbox'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerLabel extends StatelessWidget {
  const _CornerLabel({required this.text, required this.alignment});

  final String text;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(AppKeyboardPreview.cornerLabelPadding),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.keyboardCornerLabel,
            fontWeight: AppFontWeights.bold,
          ),
        ),
      ),
    );
  }
}

class KeyboardCornerSelectablePreview extends StatelessWidget {
  const KeyboardCornerSelectablePreview({
    super.key,
    required this.config,
    required this.selectedKeyId,
    required this.selectedSlot,
    required this.privateMode,
    required this.specialKeyCornersEnabled,
    required this.onKeySelected,
    required this.onSlotSelected,
  });

  final AndroidKeyboardCornerConfig config;
  final String selectedKeyId;
  final KeyboardCornerSlot selectedSlot;
  final bool privateMode;
  final bool specialKeyCornersEnabled;
  final ValueChanged<String> onKeySelected;
  final ValueChanged<KeyboardCornerSlot> onSlotSelected;

  @override
  Widget build(BuildContext context) {
    final rows = <int, List<KeyboardConfigurableKey>>{};
    for (final key in KeyboardConfigurableKeyCatalog.keys) {
      rows.putIfAbsent(key.row, () => <KeyboardConfigurableKey>[]).add(key);
    }
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppKeyboardPreview.maxWidth,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: privateMode
                  ? AppColors.keyboardPrivateFrame
                  : AppColors.keyboardDefaultFrame,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.x2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final row in rows.entries) ...[
                    SizedBox(
                      height: row.key == 3
                          ? AppKeyboardPreview.rowHeightControl
                          : AppKeyboardPreview.rowHeightRegular,
                      child: Row(
                        children: [
                          for (final keySpec in row.value) ...[
                            Expanded(
                              flex: _previewFlex(keySpec),
                              child: _SelectableCornerKeyCap(
                                keySpec: keySpec,
                                focusOrder:
                                    (row.key * 100) +
                                    row.value.indexOf(keySpec).toDouble(),
                                shortcuts:
                                    KeyboardCornerPresetCatalog.resolvedForKey(
                                      config: config,
                                      keyId: keySpec.id,
                                      cornersEnabled: true,
                                      specialKeyCornersEnabled:
                                          specialKeyCornersEnabled,
                                      privateMode: privateMode,
                                      specialKey: keySpec.special,
                                    ),
                                selectedKeyId: selectedKeyId,
                                selectedSlot: selectedSlot,
                                onKeySelected: onKeySelected,
                                onSlotSelected: onSlotSelected,
                              ),
                            ),
                            if (keySpec != row.value.last) AppGaps.horizontalX2,
                          ],
                        ],
                      ),
                    ),
                    if (row.key != rows.keys.last) AppGaps.x2,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _previewFlex(KeyboardConfigurableKey keySpec) {
    if (keySpec.id == 'space') {
      return 360;
    }
    if (keySpec.special) {
      return 120;
    }
    return 100;
  }
}

class _SelectableCornerKeyCap extends StatelessWidget {
  const _SelectableCornerKeyCap({
    required this.keySpec,
    required this.focusOrder,
    required this.shortcuts,
    required this.selectedKeyId,
    required this.selectedSlot,
    required this.onKeySelected,
    required this.onSlotSelected,
  });

  final KeyboardConfigurableKey keySpec;
  final double focusOrder;
  final Map<KeyboardCornerSlot, AndroidKeyboardCornerShortcut> shortcuts;
  final String selectedKeyId;
  final KeyboardCornerSlot selectedSlot;
  final ValueChanged<String> onKeySelected;
  final ValueChanged<KeyboardCornerSlot> onSlotSelected;

  @override
  Widget build(BuildContext context) {
    final selected = keySpec.id == selectedKeyId;
    final colorScheme = Theme.of(context).colorScheme;
    final background = selected
        ? colorScheme.primaryContainer
        : keySpec.special
        ? AppColors.keyboardKeySpecial
        : AppColors.white;
    return FocusTraversalOrder(
      order: NumericFocusOrder(focusOrder),
      child: Semantics(
        button: true,
        selected: selected,
        label: 'Keyboard key ${keySpec.label}',
        hint: 'Selects this key for corner shortcut editing',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: Key('corner-preview-key-${keySpec.id}'),
            borderRadius: BorderRadius.circular(AppRadii.sm),
            onTap: () => onKeySelected(keySpec.id),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(
                  color: selected ? colorScheme.primary : AppColors.borderLight,
                  width: selected ? 2 : AppKeyboardPreview.keyBorderWidth,
                ),
              ),
              child: Stack(
                children: [
                  _CornerTapTarget(
                    slot: KeyboardCornerSlot.topLeft,
                    selected:
                        selected && selectedSlot == KeyboardCornerSlot.topLeft,
                    shortcut: shortcuts[KeyboardCornerSlot.topLeft],
                    keyLabel: keySpec.label,
                    focusOrder: focusOrder + .1,
                    alignment: Alignment.topLeft,
                    onTap: () {
                      onKeySelected(keySpec.id);
                      onSlotSelected(KeyboardCornerSlot.topLeft);
                    },
                  ),
                  _CornerTapTarget(
                    slot: KeyboardCornerSlot.topRight,
                    selected:
                        selected && selectedSlot == KeyboardCornerSlot.topRight,
                    shortcut: shortcuts[KeyboardCornerSlot.topRight],
                    keyLabel: keySpec.label,
                    focusOrder: focusOrder + .2,
                    alignment: Alignment.topRight,
                    onTap: () {
                      onKeySelected(keySpec.id);
                      onSlotSelected(KeyboardCornerSlot.topRight);
                    },
                  ),
                  _CornerTapTarget(
                    slot: KeyboardCornerSlot.bottomLeft,
                    selected:
                        selected &&
                        selectedSlot == KeyboardCornerSlot.bottomLeft,
                    shortcut: shortcuts[KeyboardCornerSlot.bottomLeft],
                    keyLabel: keySpec.label,
                    focusOrder: focusOrder + .3,
                    alignment: Alignment.bottomLeft,
                    onTap: () {
                      onKeySelected(keySpec.id);
                      onSlotSelected(KeyboardCornerSlot.bottomLeft);
                    },
                  ),
                  _CornerTapTarget(
                    slot: KeyboardCornerSlot.bottomRight,
                    selected:
                        selected &&
                        selectedSlot == KeyboardCornerSlot.bottomRight,
                    shortcut: shortcuts[KeyboardCornerSlot.bottomRight],
                    keyLabel: keySpec.label,
                    focusOrder: focusOrder + .4,
                    alignment: Alignment.bottomRight,
                    onTap: () {
                      onKeySelected(keySpec.id);
                      onSlotSelected(KeyboardCornerSlot.bottomRight);
                    },
                  ),
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.x1,
                        ),
                        child: Text(
                          keySpec.label,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AppColors.keyboardKeyForeground,
                                fontWeight: AppFontWeights.bold,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CornerTapTarget extends StatelessWidget {
  const _CornerTapTarget({
    required this.slot,
    required this.selected,
    required this.shortcut,
    required this.keyLabel,
    required this.focusOrder,
    required this.alignment,
    required this.onTap,
  });

  final KeyboardCornerSlot slot;
  final bool selected;
  final AndroidKeyboardCornerShortcut? shortcut;
  final String keyLabel;
  final double focusOrder;
  final Alignment alignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final slotLabel = _cornerSlotLabel(slot);
    return FocusTraversalOrder(
      order: NumericFocusOrder(focusOrder),
      child: Semantics(
        button: true,
        selected: selected,
        label: '$slotLabel corner on $keyLabel',
        value: shortcut?.displayLabel ?? 'Default tap',
        hint: 'Selects this corner shortcut for editing',
        child: FocusableActionDetector(
          mouseCursor: SystemMouseCursors.click,
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          },
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                onTap();
                return null;
              },
            ),
          },
          child: Align(
            alignment: alignment,
            child: InkResponse(
              key: Key('corner-preview-slot-${slot.name}-$keyLabel'),
              radius: 18,
              onTap: onTap,
              child: Container(
                width: 34,
                height: 24,
                alignment: alignment,
                padding: const EdgeInsets.all(
                  AppKeyboardPreview.cornerLabelPadding,
                ),
                decoration: selected
                    ? BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      )
                    : null,
                child: Text(
                  shortcut?.displayLabel ?? ' ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected
                        ? colorScheme.primary
                        : AppColors.keyboardCornerLabel,
                    fontWeight: AppFontWeights.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _cornerSlotLabel(KeyboardCornerSlot slot) {
  return switch (slot) {
    KeyboardCornerSlot.topLeft => 'Top left',
    KeyboardCornerSlot.topRight => 'Top right',
    KeyboardCornerSlot.bottomLeft => 'Bottom left',
    KeyboardCornerSlot.bottomRight => 'Bottom right',
  };
}

class KeyboardPreviewSnapshot {
  KeyboardPreviewSnapshot({
    required this.profile,
    required this.fieldContext,
    required this.panel,
    required this.mode,
    required this.privateMode,
    required this.corners,
    required this.debug,
    required this.vibration,
    required this.sound,
    required this.suggestionsEnabled,
    required this.specialCorners,
    required this.frenchEnabled,
    required this.englishEnabled,
    required this.shiftEnabled,
    required this.mediaNowPlaying,
    required this.cornerConfig,
  });

  final KeyboardLayoutProfile profile;
  final KeyboardPreviewFieldContext fieldContext;
  final KeyboardPreviewPanel panel;
  final KeyboardPreviewMode mode;
  final bool privateMode;
  final bool corners;
  final bool debug;
  final bool vibration;
  final bool sound;
  final bool suggestionsEnabled;
  final bool specialCorners;
  final bool frenchEnabled;
  final bool englishEnabled;
  final bool shiftEnabled;
  final String? mediaNowPlaying;
  final AndroidKeyboardCornerConfig cornerConfig;

  List<KeyboardPreviewRow> get rows {
    final rows = <KeyboardPreviewRow>[_actionRow()];
    if (panel == KeyboardPreviewPanel.settings ||
        panel == KeyboardPreviewPanel.clipboardFull) {
      rows.addAll(_panelRows());
    } else {
      rows.addAll(_suggestionRows());
      rows.addAll(_panelRows());
      rows.addAll(_typingRows());
      rows.add(_controlRow());
    }
    return rows;
  }

  KeyboardPreviewRow _actionRow() {
    return KeyboardPreviewRow(
      height: AppKeyboardPreview.rowHeightMini,
      keys: [
        _withCorners(
          keyId: 'mode-ABC',
          specialKey: true,
          key: _modeKey('ABC', KeyboardPreviewMode.letters),
        ),
        _withCorners(
          keyId: 'mode-123',
          specialKey: true,
          key: _modeKey('123', KeyboardPreviewMode.numbers),
        ),
        _withCorners(
          keyId: 'panel-Acc',
          specialKey: true,
          key: _panelKey('Acc', KeyboardPreviewPanel.accents),
        ),
        _withCorners(
          keyId: 'mode-#+=',
          specialKey: true,
          key: _modeKey('#+=', KeyboardPreviewMode.symbols),
        ),
        _withCorners(
          keyId: 'panel-Nav',
          specialKey: true,
          key: _panelKey('Nav', KeyboardPreviewPanel.navigation),
        ),
        _withCorners(
          keyId: 'panel-Emoji',
          specialKey: true,
          key: _panelKey('Emoji', KeyboardPreviewPanel.emoji),
        ),
        _withCorners(
          keyId: 'panel-Clip',
          specialKey: true,
          key: _panelKey(
            'Clip',
            KeyboardPreviewPanel.clipboard,
            enabled: !privateMode,
            pinned: true,
            activeOverride:
                panel == KeyboardPreviewPanel.clipboard ||
                panel == KeyboardPreviewPanel.clipboardFull,
          ),
        ),
        _withCorners(
          keyId: 'panel-Snip',
          specialKey: true,
          key: _panelKey(
            'Snip',
            KeyboardPreviewPanel.snippets,
            enabled: !privateMode,
          ),
        ),
        _withCorners(
          keyId: 'panel-Media',
          specialKey: true,
          key: _panelKey('Media', KeyboardPreviewPanel.media, pinned: true),
        ),
        _withCorners(
          keyId: 'panel-Prefs',
          specialKey: true,
          key: _panelKey('Prefs', KeyboardPreviewPanel.settings),
        ),
        _withCorners(
          keyId: 'voice',
          specialKey: true,
          key: const KeyboardPreviewKey(
            label: 'Mic',
            special: true,
            action: KeyboardPreviewKeyAction.unsupported,
            unsupportedReason: 'Voice dictation simulation is not wired here',
          ),
        ),
      ],
    );
  }

  List<KeyboardPreviewRow> _suggestionRows() {
    if (privateMode ||
        fieldContext != KeyboardPreviewFieldContext.text ||
        mode != KeyboardPreviewMode.letters ||
        !suggestionsEnabled) {
      return const [];
    }
    return const [
      KeyboardPreviewRow(
        height: AppKeyboardPreview.rowHeightCompact,
        keys: [
          KeyboardPreviewKey(
            label: "j'arrive",
            special: true,
            weight: 1.4,
            action: KeyboardPreviewKeyAction.suggestion,
            output: "j'arrive",
          ),
          KeyboardPreviewKey(
            label: 'bonjour',
            special: true,
            weight: 1.4,
            action: KeyboardPreviewKeyAction.suggestion,
            output: 'bonjour',
          ),
          KeyboardPreviewKey(
            label: 'merci',
            special: true,
            weight: 1.4,
            action: KeyboardPreviewKeyAction.suggestion,
            output: 'merci',
          ),
        ],
      ),
    ];
  }

  List<KeyboardPreviewRow> _panelRows() {
    switch (panel) {
      case KeyboardPreviewPanel.none:
        return const [];
      case KeyboardPreviewPanel.navigation:
        return [
          KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightCompact,
            keys: [
              _unsupportedKey('All'),
              _unsupportedKey('Copy'),
              _unsupportedKey('DelW←'),
              _unsupportedKey('DelW→'),
              _unsupportedKey('⏫'),
              _unsupportedKey('↑'),
            ],
          ),
          KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightCompact,
            keys: [
              _unsupportedKey('Cut'),
              _unsupportedKey('Paste'),
              _unsupportedKey('Word←'),
              _unsupportedKey('Word→'),
              _unsupportedKey('⏬'),
              _unsupportedKey('↓'),
            ],
          ),
          KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightCompact,
            keys: [
              _unsupportedKey('Undo'),
              _unsupportedKey('Redo'),
              const KeyboardPreviewKey(
                label: 'Del←',
                special: true,
                action: KeyboardPreviewKeyAction.backspace,
              ),
              _unsupportedKey('Del→'),
              _unsupportedKey('⬅'),
              _unsupportedKey('➡'),
            ],
          ),
        ];
      case KeyboardPreviewPanel.accents:
        return [
          const KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightCompact,
            keys: [
              KeyboardPreviewKey(label: 'é', special: true),
              KeyboardPreviewKey(label: 'è', special: true),
              KeyboardPreviewKey(label: 'ê', special: true),
              KeyboardPreviewKey(label: 'ë', special: true),
              KeyboardPreviewKey(label: 'à', special: true),
              KeyboardPreviewKey(label: 'â', special: true),
              KeyboardPreviewKey(label: 'ç', special: true),
            ],
            leadingWeight: .35,
            trailingWeight: .35,
          ),
          const KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightCompact,
            keys: [
              KeyboardPreviewKey(label: 'ù', special: true),
              KeyboardPreviewKey(label: 'û', special: true),
              KeyboardPreviewKey(label: 'ü', special: true),
              KeyboardPreviewKey(label: 'î', special: true),
              KeyboardPreviewKey(label: 'ï', special: true),
              KeyboardPreviewKey(label: 'ô', special: true),
              KeyboardPreviewKey(label: 'œ', special: true),
              KeyboardPreviewKey(label: 'æ', special: true),
            ],
            leadingWeight: .2,
            trailingWeight: .2,
          ),
        ];
      case KeyboardPreviewPanel.emoji:
        return [
          KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightCompact,
            keys: [
              _unsupportedKey('🕘'),
              _unsupportedKey(':-)'),
              _unsupportedKey('👏'),
              _unsupportedKey('✨'),
              _unsupportedKey('🌿'),
              _unsupportedKey('🍔'),
              _unsupportedKey('💡'),
              const KeyboardPreviewKey(
                label: '×',
                special: true,
                action: KeyboardPreviewKeyAction.closePanel,
              ),
            ],
          ),
          KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightCompact,
            keys: [
              KeyboardPreviewKey(label: '😀', output: '😀'),
              KeyboardPreviewKey(label: '😂', output: '😂'),
              KeyboardPreviewKey(label: '😊', output: '😊'),
              KeyboardPreviewKey(label: '😍', output: '😍'),
              KeyboardPreviewKey(label: '🔥', output: '🔥'),
              KeyboardPreviewKey(label: '✨', output: '✨'),
              KeyboardPreviewKey(label: '👏', output: '👏'),
              KeyboardPreviewKey(label: '💡', output: '💡'),
            ],
          ),
        ];
      case KeyboardPreviewPanel.clipboard:
        return [
          KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightCompact,
            keys: _clipboardPreviewKeys(take: 6),
            horizontalScrollable: true,
          ),
        ];
      case KeyboardPreviewPanel.clipboardFull:
        return _clipboardFullRows();
      case KeyboardPreviewPanel.snippets:
        return [
          KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightCompact,
            keys: [
              const KeyboardPreviewKey(
                label: 'j\'arrive',
                output: 'j\'arrive',
                special: true,
                weight: 1.7,
                action: KeyboardPreviewKeyAction.snippet,
              ),
              const KeyboardPreviewKey(
                label: 'D\'accord',
                output: 'D\'accord',
                special: true,
                weight: 1.7,
                action: KeyboardPreviewKeyAction.snippet,
              ),
              const KeyboardPreviewKey(
                label: 'Merci beaucoup',
                output: 'Merci beaucoup',
                special: true,
                weight: 1.9,
                action: KeyboardPreviewKeyAction.snippet,
              ),
              const KeyboardPreviewKey(
                label: 'Je te rappelle',
                output: 'Je te rappelle',
                special: true,
                weight: 1.9,
                action: KeyboardPreviewKeyAction.snippet,
              ),
              const KeyboardPreviewKey(
                label: 'Adresse',
                output: 'Mon adresse est ',
                special: true,
                weight: 1.5,
                action: KeyboardPreviewKeyAction.snippet,
              ),
              const KeyboardPreviewKey(
                label: 'Signature',
                output: 'Bien cordialement,',
                special: true,
                weight: 1.7,
                action: KeyboardPreviewKeyAction.snippet,
              ),
              const KeyboardPreviewKey(
                label: 'App',
                special: true,
                weight: 1.2,
                action: KeyboardPreviewKeyAction.openAppSettings,
              ),
              const KeyboardPreviewKey(
                label: 'Close',
                special: true,
                action: KeyboardPreviewKeyAction.closePanel,
              ),
            ],
            horizontalScrollable: true,
          ),
        ];
      case KeyboardPreviewPanel.media:
        return [
          KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightCompact,
            keys: [
              _unsupportedKey('Prev'),
              _unsupportedKey('>||', weight: 1.2),
              _unsupportedKey('Next'),
              const KeyboardPreviewKey(
                label: 'Now',
                special: true,
                action: KeyboardPreviewKeyAction.mediaNowPlaying,
              ),
              const KeyboardPreviewKey(
                label: 'App',
                special: true,
                action: KeyboardPreviewKeyAction.openMediaApp,
              ),
            ],
          ),
          if (mediaNowPlaying != null)
            KeyboardPreviewRow(
              height: AppKeyboardPreview.rowHeightCompact,
              keys: [
                KeyboardPreviewKey(
                  label: mediaNowPlaying!,
                  special: true,
                  weight: 5,
                  action: KeyboardPreviewKeyAction.mediaNowPlaying,
                ),
              ],
            ),
        ];
      case KeyboardPreviewPanel.settings:
        return [
          KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightCompact,
            keys: [
              const KeyboardPreviewKey(
                label: 'Keyboard',
                special: true,
                weight: 1.3,
                action: KeyboardPreviewKeyAction.keyboardPicker,
              ),
              const KeyboardPreviewKey(
                label: 'App',
                special: true,
                action: KeyboardPreviewKeyAction.openAppSettings,
              ),
              const KeyboardPreviewKey(
                label: 'Theme',
                special: true,
                action: KeyboardPreviewKeyAction.openThemeSettings,
              ),
              KeyboardPreviewKey(
                label: profile.name.toUpperCase(),
                special: true,
                weight: 1.1,
                action: KeyboardPreviewKeyAction.unsupported,
                unsupportedReason: 'Use Profile dropdown above',
              ),
              const KeyboardPreviewKey(
                label: 'Close',
                special: true,
                action: KeyboardPreviewKeyAction.closePanel,
              ),
            ],
          ),
          KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightCompact,
            keys: [
              KeyboardPreviewKey(
                label: vibration ? 'Vibe on' : 'Vibe off',
                special: true,
                active: vibration,
                action: KeyboardPreviewKeyAction.toggleVibration,
              ),
              KeyboardPreviewKey(
                label: sound ? 'Sound on' : 'Sound off',
                special: true,
                active: sound,
                action: KeyboardPreviewKeyAction.toggleSound,
              ),
              KeyboardPreviewKey(
                label: debug ? 'Debug on' : 'Debug off',
                special: true,
                active: debug,
                action: KeyboardPreviewKeyAction.unsupported,
                unsupportedReason: 'Use the Debug chip above',
              ),
              KeyboardPreviewKey(
                label: suggestionsEnabled ? 'Suggest on' : 'Suggest off',
                special: true,
                active: suggestionsEnabled,
                weight: 1.2,
                action: KeyboardPreviewKeyAction.toggleSuggestions,
              ),
            ],
          ),
          KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightCompact,
            keys: [
              KeyboardPreviewKey(
                label: frenchEnabled ? 'FR on' : 'FR off',
                special: true,
                active: frenchEnabled,
                action: KeyboardPreviewKeyAction.toggleFrench,
              ),
              KeyboardPreviewKey(
                label: englishEnabled ? 'EN on' : 'EN off',
                special: true,
                active: englishEnabled,
                action: KeyboardPreviewKeyAction.toggleEnglish,
              ),
            ],
            leadingWeight: 1,
            trailingWeight: 1,
          ),
          KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightCompact,
            keys: [
              KeyboardPreviewKey(
                label: corners ? 'Corners on' : 'Corners off',
                special: true,
                active: corners,
                weight: 1.2,
                action: KeyboardPreviewKeyAction.unsupported,
                unsupportedReason:
                    'Use the Corners chip above for simulation toggles',
              ),
              const KeyboardPreviewKey(
                label: '2sp on',
                special: true,
                active: true,
                action: KeyboardPreviewKeyAction.unsupported,
                unsupportedReason: 'Native double-space period toggle',
              ),
              const KeyboardPreviewKey(
                label: 'Punc on',
                special: true,
                active: true,
                action: KeyboardPreviewKeyAction.unsupported,
                unsupportedReason: 'Native punctuation spacing toggle',
              ),
              KeyboardPreviewKey(
                label: specialCorners ? 'Special on' : 'Special off',
                special: true,
                active: specialCorners,
                weight: 1.2,
                action: KeyboardPreviewKeyAction.toggleSpecialCorners,
              ),
            ],
          ),
        ];
    }
  }

  List<KeyboardPreviewRow> _typingRows() {
    switch (mode) {
      case KeyboardPreviewMode.letters:
        return _letterRows();
      case KeyboardPreviewMode.numbers:
        return [
          KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightRegular,
            keys: [
              KeyboardPreviewKey(label: '@', special: true, weight: .9),
              KeyboardPreviewKey(label: '+', special: true, weight: .9),
              KeyboardPreviewKey(label: '1', weight: 1.1),
              KeyboardPreviewKey(label: '2', weight: 1.1),
              KeyboardPreviewKey(label: '3', weight: 1.1),
              KeyboardPreviewKey(label: '-', special: true, weight: .9),
              KeyboardPreviewKey(label: '#', special: true, weight: .9),
            ],
          ),
          KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightRegular,
            keys: [
              KeyboardPreviewKey(label: '?', special: true, weight: .9),
              KeyboardPreviewKey(label: '*', special: true, weight: .9),
              KeyboardPreviewKey(label: '4', weight: 1.1),
              KeyboardPreviewKey(label: '5', weight: 1.1),
              KeyboardPreviewKey(label: '6', weight: 1.1),
              KeyboardPreviewKey(label: '/', special: true, weight: .9),
              KeyboardPreviewKey(label: '!', special: true, weight: .9),
            ],
          ),
          KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightRegular,
            keys: [
              KeyboardPreviewKey(label: ':', special: true, weight: .9),
              KeyboardPreviewKey(label: '.', special: true, weight: .9),
              KeyboardPreviewKey(label: '7', weight: 1.1),
              KeyboardPreviewKey(label: '8', weight: 1.1),
              KeyboardPreviewKey(label: '9', weight: 1.1),
              KeyboardPreviewKey(label: ',', special: true, weight: .9),
              KeyboardPreviewKey(label: ';', special: true, weight: .9),
            ],
          ),
        ];
      case KeyboardPreviewMode.symbols:
        return [
          KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightRegular,
            keys: [
              KeyboardPreviewKey(label: '!'),
              KeyboardPreviewKey(label: '?'),
              KeyboardPreviewKey(label: ':'),
              KeyboardPreviewKey(label: ';'),
              KeyboardPreviewKey(label: '"'),
              KeyboardPreviewKey(label: "'"),
              KeyboardPreviewKey(label: '('),
              KeyboardPreviewKey(label: ')'),
            ],
          ),
          KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightRegular,
            keys: [
              KeyboardPreviewKey(label: '#'),
              KeyboardPreviewKey(label: '@'),
              KeyboardPreviewKey(label: '&'),
              KeyboardPreviewKey(label: '_'),
              KeyboardPreviewKey(label: '|'),
              KeyboardPreviewKey(label: '\\'),
            ],
            leadingWeight: .8,
            trailingWeight: .8,
          ),
        ];
    }
  }

  List<KeyboardPreviewRow> _letterRows() {
    final top = profile == KeyboardLayoutProfile.azerty
        ? 'azertyuiop'
        : 'qwertyuiop';
    final middle = profile == KeyboardLayoutProfile.azerty
        ? 'qsdfghjklm'
        : 'asdfghjkl';
    final bottom = profile == KeyboardLayoutProfile.azerty
        ? 'wxcvbn'
        : 'zxcvbnm';
    return [
      KeyboardPreviewRow(
        height: AppKeyboardPreview.rowHeightRegular,
        keys: _letterKeys(top),
      ),
      KeyboardPreviewRow(
        height: AppKeyboardPreview.rowHeightRegular,
        leadingWeight: .45,
        trailingWeight: .45,
        keys: _letterKeys(middle),
      ),
      KeyboardPreviewRow(
        height: AppKeyboardPreview.rowHeightRegular,
        keys: [
          _withCorners(
            keyId: 'shift',
            specialKey: true,
            key: KeyboardPreviewKey(
              label: 'Shift',
              special: true,
              active: shiftEnabled,
              weight: 1.2,
              action: KeyboardPreviewKeyAction.shift,
            ),
          ),
          ..._letterKeys(bottom),
          _withCorners(
            keyId: 'del-letter-row',
            specialKey: true,
            key: const KeyboardPreviewKey(
              label: 'Back',
              special: true,
              weight: 1.2,
              action: KeyboardPreviewKeyAction.backspace,
            ),
          ),
        ],
      ),
    ];
  }

  KeyboardPreviewRow _controlRow() {
    final left = fieldContext.numeric ? '+' : 'Shift';
    final right = switch (fieldContext) {
      KeyboardPreviewFieldContext.email => '@',
      KeyboardPreviewFieldContext.url => '/',
      KeyboardPreviewFieldContext.phone => '#',
      KeyboardPreviewFieldContext.number => '-',
      KeyboardPreviewFieldContext.search ||
      KeyboardPreviewFieldContext.text => 'Back',
    };
    if (mode == KeyboardPreviewMode.letters) {
      final leftSymbol = switch (fieldContext) {
        KeyboardPreviewFieldContext.email => '@',
        KeyboardPreviewFieldContext.url => '/',
        KeyboardPreviewFieldContext.phone ||
        KeyboardPreviewFieldContext.number => '+',
        KeyboardPreviewFieldContext.search ||
        KeyboardPreviewFieldContext.text => ',',
      };
      final rightSymbol = switch (fieldContext) {
        KeyboardPreviewFieldContext.email ||
        KeyboardPreviewFieldContext.url => '.com',
        KeyboardPreviewFieldContext.phone => '#',
        KeyboardPreviewFieldContext.number => '-',
        KeyboardPreviewFieldContext.search ||
        KeyboardPreviewFieldContext.text => '.',
      };
      return KeyboardPreviewRow(
        height: AppKeyboardPreview.rowHeightControl,
        keys: [
          _withCorners(
            keyId: 'modifier-ctrl',
            specialKey: true,
            key: const KeyboardPreviewKey(
              label: 'Ctrl',
              special: true,
              weight: .9,
              action: KeyboardPreviewKeyAction.unsupported,
              unsupportedReason: 'Modifier keys are native-only in preview',
            ),
          ),
          _withCorners(
            keyId: 'modifier-alt',
            specialKey: true,
            key: const KeyboardPreviewKey(
              label: 'Alt',
              special: true,
              weight: .9,
              action: KeyboardPreviewKeyAction.unsupported,
              unsupportedReason: 'Modifier keys are native-only in preview',
            ),
          ),
          _withCorners(
            keyId: 'tab-letter-control',
            specialKey: true,
            key: const KeyboardPreviewKey(
              label: 'Tab',
              special: true,
              weight: .9,
              action: KeyboardPreviewKeyAction.unsupported,
              unsupportedReason: 'Tab is native-only in preview',
            ),
          ),
          _withCorners(
            keyId: 'escape-letter-control',
            specialKey: true,
            key: const KeyboardPreviewKey(
              label: 'Échap',
              special: true,
              weight: .9,
              action: KeyboardPreviewKeyAction.unsupported,
              unsupportedReason: 'Escape is native-only in preview',
            ),
          ),
          KeyboardPreviewKey(label: leftSymbol, special: true),
          _withCorners(
            keyId: 'space',
            specialKey: true,
            key: const KeyboardPreviewKey(
              label: 'Space',
              special: true,
              weight: 3,
              action: KeyboardPreviewKeyAction.space,
              output: ' ',
            ),
          ),
          KeyboardPreviewKey(label: rightSymbol, special: true),
          _withCorners(
            keyId: 'enter',
            specialKey: true,
            key: KeyboardPreviewKey(
              label: fieldContext.enterLabel,
              special: true,
              weight: 1.3,
              action: KeyboardPreviewKeyAction.enter,
            ),
          ),
        ],
      );
    }
    return KeyboardPreviewRow(
      height: AppKeyboardPreview.rowHeightControl,
      keys: [
        KeyboardPreviewKey(
          label: left,
          special: true,
          active: left == 'Shift' && shiftEnabled,
          weight: 1.2,
          action: left == 'Shift'
              ? KeyboardPreviewKeyAction.shift
              : KeyboardPreviewKeyAction.text,
          output: left == 'Shift' ? null : left,
        ),
        _withCorners(
          keyId: 'space',
          specialKey: true,
          key: const KeyboardPreviewKey(
            label: 'Space',
            special: true,
            weight: 4,
            action: KeyboardPreviewKeyAction.space,
            output: ' ',
          ),
        ),
        KeyboardPreviewKey(
          label: right,
          special: true,
          weight: 1.2,
          action: right == 'Back'
              ? KeyboardPreviewKeyAction.backspace
              : KeyboardPreviewKeyAction.text,
          output: right == 'Back' ? null : right,
        ),
        _withCorners(
          keyId: 'enter',
          specialKey: true,
          key: KeyboardPreviewKey(
            label: fieldContext.enterLabel,
            special: true,
            weight: 1.4,
            action: KeyboardPreviewKeyAction.enter,
          ),
        ),
      ],
    );
  }

  KeyboardPreviewKey _modeKey(String label, KeyboardPreviewMode target) {
    return KeyboardPreviewKey(
      label: label,
      active: mode == target,
      special: true,
      action: KeyboardPreviewKeyAction.modeSwitch,
      modeTarget: target,
    );
  }

  KeyboardPreviewKey _panelKey(
    String label,
    KeyboardPreviewPanel target, {
    bool enabled = true,
    bool? activeOverride,
    bool pinned = false,
  }) {
    return KeyboardPreviewKey(
      label: label,
      active: activeOverride ?? panel == target,
      enabled: enabled,
      pinned: pinned,
      special: true,
      action: KeyboardPreviewKeyAction.panelSwitch,
      panelTarget: target,
    );
  }

  List<KeyboardPreviewRow> _clipboardFullRows() {
    final keys = _clipboardPreviewKeys(take: 12);
    final rows = <KeyboardPreviewRow>[];
    for (var index = 0; index < keys.length; index += 3) {
      final end = index + 3 > keys.length ? keys.length : index + 3;
      rows.add(
        KeyboardPreviewRow(
          height: AppKeyboardPreview.rowHeightCompact,
          keys: keys.sublist(index, end),
        ),
      );
    }
    return rows;
  }

  List<KeyboardPreviewKey> _clipboardPreviewKeys({required int take}) {
    const entries = [
      ('Pinned account id', 'Pinned account id', true),
      ('Latest copied text', 'Latest copied text', false),
      ('Meeting notes', 'Meeting notes ready to paste', false),
      ('Support reply', 'Thanks, I will look into it.', false),
      ('Address', 'Mon adresse est ', false),
      ('Invoice ref', 'INV-2026-042', false),
      ('Email intro', 'Bonjour,', false),
      ('Signature', 'Bien cordialement,', false),
    ];
    return entries.take(take).map((entry) {
      return KeyboardPreviewKey(
        label: entry.$3 ? 'Pin ${entry.$1}' : entry.$1,
        output: entry.$2,
        active: entry.$3,
        special: true,
        weight: 1.8,
        action: KeyboardPreviewKeyAction.clipboardEntry,
      );
    }).toList();
  }

  KeyboardPreviewKey _unsupportedKey(String label, {double weight = 1}) {
    return KeyboardPreviewKey(
      label: label,
      weight: weight,
      special: true,
      action: KeyboardPreviewKeyAction.unsupported,
    );
  }

  List<KeyboardPreviewKey> _letterKeys(String letters) {
    return [
      for (var index = 0; index < letters.length; index++)
        _withCorners(
          keyId: 'letter-${letters[index]}',
          key: KeyboardPreviewKey(label: letters[index]),
        ),
    ];
  }

  KeyboardPreviewKey _withCorners({
    required String keyId,
    required KeyboardPreviewKey key,
    bool specialKey = false,
  }) {
    final resolved = KeyboardCornerPresetCatalog.resolvedForKey(
      config: cornerConfig,
      keyId: keyId,
      cornersEnabled: corners,
      specialKeyCornersEnabled: specialCorners,
      privateMode: privateMode,
      specialKey: specialKey,
    );
    return key.copyWith(
      topLeftShortcut: resolved[KeyboardCornerSlot.topLeft],
      topRightShortcut: resolved[KeyboardCornerSlot.topRight],
      bottomLeftShortcut: resolved[KeyboardCornerSlot.bottomLeft],
      bottomRightShortcut: resolved[KeyboardCornerSlot.bottomRight],
    );
  }
}

enum KeyboardPreviewKeyAction {
  text,
  suggestion,
  clipboardEntry,
  snippet,
  space,
  backspace,
  enter,
  shift,
  mediaNowPlaying,
  openMediaApp,
  keyboardPicker,
  openAppSettings,
  openThemeSettings,
  toggleVibration,
  toggleSound,
  toggleSuggestions,
  toggleSpecialCorners,
  toggleFrench,
  toggleEnglish,
  modeSwitch,
  panelSwitch,
  closePanel,
  unsupported,
}

class KeyboardPreviewRow {
  const KeyboardPreviewRow({
    required this.height,
    required this.keys,
    this.leadingWeight = 0,
    this.trailingWeight = 0,
    this.horizontalScrollable = false,
  });

  final double height;
  final List<KeyboardPreviewKey> keys;
  final double leadingWeight;
  final double trailingWeight;
  final bool horizontalScrollable;
}

class KeyboardPreviewKey {
  const KeyboardPreviewKey({
    required this.label,
    this.weight = 1,
    this.enabled = true,
    this.active = false,
    this.pinned = false,
    this.special = false,
    this.action = KeyboardPreviewKeyAction.text,
    this.output,
    this.modeTarget,
    this.panelTarget,
    this.unsupportedReason,
    this.topLeftShortcut,
    this.topRightShortcut,
    this.bottomLeftShortcut,
    this.bottomRightShortcut,
  });

  final String label;
  final double weight;
  final bool enabled;
  final bool active;
  final bool pinned;
  final bool special;
  final KeyboardPreviewKeyAction action;
  final String? output;
  final KeyboardPreviewMode? modeTarget;
  final KeyboardPreviewPanel? panelTarget;
  final String? unsupportedReason;
  final AndroidKeyboardCornerShortcut? topLeftShortcut;
  final AndroidKeyboardCornerShortcut? topRightShortcut;
  final AndroidKeyboardCornerShortcut? bottomLeftShortcut;
  final AndroidKeyboardCornerShortcut? bottomRightShortcut;

  KeyboardPreviewKey copyWith({
    AndroidKeyboardCornerShortcut? topLeftShortcut,
    AndroidKeyboardCornerShortcut? topRightShortcut,
    AndroidKeyboardCornerShortcut? bottomLeftShortcut,
    AndroidKeyboardCornerShortcut? bottomRightShortcut,
  }) {
    return KeyboardPreviewKey(
      label: label,
      weight: weight,
      enabled: enabled,
      active: active,
      pinned: pinned,
      special: special,
      action: action,
      output: output,
      modeTarget: modeTarget,
      panelTarget: panelTarget,
      unsupportedReason: unsupportedReason,
      topLeftShortcut: topLeftShortcut ?? this.topLeftShortcut,
      topRightShortcut: topRightShortcut ?? this.topRightShortcut,
      bottomLeftShortcut: bottomLeftShortcut ?? this.bottomLeftShortcut,
      bottomRightShortcut: bottomRightShortcut ?? this.bottomRightShortcut,
    );
  }
}
