import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/keyboard_models.dart';

enum KeyboardPreviewFieldContext {
  text('Text', 'Enter'),
  email('Email', 'Done'),
  url('URL', 'Go'),
  phone('Phone', 'Done'),
  number('Number', 'Done'),
  search('Search', 'Search');

  const KeyboardPreviewFieldContext(this.label, this.enterLabel);

  final String label;
  final String enterLabel;

  bool get numeric => this == phone || this == number;
}

enum KeyboardPreviewPanel {
  none('Typing'),
  navigation('Navigation'),
  accents('Accents'),
  emoji('Emoji'),
  clipboard('Clipboard'),
  clipboardFull('Clip full'),
  snippets('Snippets'),
  media('Media'),
  settings('Settings');

  const KeyboardPreviewPanel(this.label);

  final String label;
}

enum KeyboardPreviewMode {
  letters('ABC'),
  numbers('123'),
  symbols('#+=');

  const KeyboardPreviewMode(this.label);

  final String label;
}

class KeyboardPreviewScreen extends StatefulWidget {
  const KeyboardPreviewScreen({super.key});

  @override
  State<KeyboardPreviewScreen> createState() => _KeyboardPreviewScreenState();
}

class _KeyboardPreviewScreenState extends State<KeyboardPreviewScreen> {
  KeyboardLayoutProfile _profile = KeyboardLayoutProfile.qwerty;
  KeyboardPreviewFieldContext _fieldContext = KeyboardPreviewFieldContext.text;
  KeyboardPreviewPanel _panel = KeyboardPreviewPanel.none;
  KeyboardPreviewMode _mode = KeyboardPreviewMode.letters;
  bool _privateMode = false;
  bool _corners = true;
  bool _debug = false;
  bool _vibration = true;
  bool _sound = false;
  bool _suggestions = true;
  bool _specialCorners = false;
  bool _french = true;
  bool _english = true;
  bool _shiftEnabled = false;
  AndroidKeyboardCornerConfig _cornerConfig =
      AndroidKeyboardCornerConfig.defaults();
  String? _mediaNowPlaying;
  String _buffer = '';
  int _cursor = 0;
  String _status =
      'Interactive sandbox: simulated output only, not native Android IME proof.';

  KeyboardPreviewMode get _effectiveMode =>
      _fieldContext.numeric ? KeyboardPreviewMode.numbers : _mode;

  void _setStatus(String value) {
    setState(() => _status = value);
  }

  void _setFieldContext(KeyboardPreviewFieldContext value) {
    setState(() {
      _fieldContext = value;
      if (value.numeric) {
        _mode = KeyboardPreviewMode.numbers;
      }
      _status = 'Field context: ${value.label}.';
    });
  }

  void _setPanel(KeyboardPreviewPanel value) {
    setState(() {
      _panel = value;
      _status = value == KeyboardPreviewPanel.none
          ? 'Panel closed.'
          : 'Panel: ${value.label}.';
    });
  }

  void _setMode(KeyboardPreviewMode value) {
    if (_fieldContext.numeric) {
      _setStatus('Mode locked to 123 in numeric context.');
      return;
    }
    setState(() {
      _mode = value;
      _status = 'Mode: ${value.label}.';
    });
  }

  void _clearBuffer() {
    setState(() {
      _buffer = '';
      _cursor = 0;
      _status = 'Buffer cleared.';
    });
  }

  void _resetSandbox() {
    setState(() {
      _buffer = '';
      _cursor = 0;
      _shiftEnabled = false;
      _mediaNowPlaying = null;
      _cornerConfig = AndroidKeyboardCornerConfig.defaults();
      _panel = KeyboardPreviewPanel.none;
      _mode = _fieldContext.numeric
          ? KeyboardPreviewMode.numbers
          : KeyboardPreviewMode.letters;
      _status = 'Sandbox reset.';
    });
  }

  void _insertText(String value, {String? status}) {
    final prefix = _buffer.substring(0, _cursor);
    final suffix = _buffer.substring(_cursor);
    setState(() {
      _buffer = '$prefix$value$suffix';
      _cursor += value.length;
      _status = status ?? 'Inserted "$value".';
    });
  }

  void _insertSuggestion(String value) {
    final suggestion = _shiftEnabled && value.isNotEmpty
        ? '${value[0].toUpperCase()}${value.substring(1)}'
        : value;
    final beforeCursor = _cursor > 0 ? _buffer[_cursor - 1] : '';
    final afterCursor = _cursor < _buffer.length ? _buffer[_cursor] : '';
    final leading = beforeCursor.isEmpty || beforeCursor.trim().isEmpty
        ? ''
        : ' ';
    final trailing = afterCursor.isEmpty || afterCursor.trim().isEmpty
        ? ''
        : ' ';
    _insertText(
      '$leading$suggestion$trailing',
      status: 'Suggestion "$value" inserted.',
    );
    setState(() => _shiftEnabled = false);
  }

  void _backspace() {
    if (_cursor == 0) {
      _setStatus('Backspace ignored: buffer already empty.');
      return;
    }
    final prefix = _buffer.substring(0, _cursor - 1);
    final suffix = _buffer.substring(_cursor);
    setState(() {
      _buffer = '$prefix$suffix';
      _cursor -= 1;
      _status = 'Backspace.';
    });
  }

  void _onKeyPressed(KeyboardPreviewKey key) {
    if (!key.enabled) {
      _setStatus('Action disabled in this context: ${key.label}.');
      return;
    }
    switch (key.action) {
      case KeyboardPreviewKeyAction.modeSwitch:
        if (key.modeTarget != null) {
          _setMode(key.modeTarget!);
        }
        break;
      case KeyboardPreviewKeyAction.panelSwitch:
        if (key.panelTarget == null) {
          break;
        }
        final target = key.panelTarget!;
        if (target == KeyboardPreviewPanel.clipboard &&
            (_panel == KeyboardPreviewPanel.clipboard ||
                _panel == KeyboardPreviewPanel.clipboardFull)) {
          _setPanel(KeyboardPreviewPanel.none);
          return;
        }
        if (_panel == target) {
          _setPanel(KeyboardPreviewPanel.none);
          return;
        }
        _setPanel(target);
        break;
      case KeyboardPreviewKeyAction.closePanel:
        _setPanel(KeyboardPreviewPanel.none);
        break;
      case KeyboardPreviewKeyAction.clipboardEntry:
        _insertText(
          key.output ?? key.label,
          status: 'Clipboard entry inserted.',
        );
        break;
      case KeyboardPreviewKeyAction.shift:
        setState(() {
          _shiftEnabled = !_shiftEnabled;
          _status = _shiftEnabled ? 'Shift enabled.' : 'Shift disabled.';
        });
        break;
      case KeyboardPreviewKeyAction.space:
        _insertText(' ', status: 'Space inserted.');
        break;
      case KeyboardPreviewKeyAction.backspace:
        _backspace();
        break;
      case KeyboardPreviewKeyAction.enter:
        _insertText('\n', status: 'Enter inserted.');
        break;
      case KeyboardPreviewKeyAction.mediaNowPlaying:
        setState(() {
          if (_mediaNowPlaying == null) {
            _mediaNowPlaying = 'Daft Punk - Digital Love';
            _status = _mediaNowPlaying!;
          } else {
            _mediaNowPlaying = null;
            _status = 'Now playing hidden.';
          }
        });
        break;
      case KeyboardPreviewKeyAction.keyboardPicker:
        _setStatus('Keyboard picker is Android-only.');
        break;
      case KeyboardPreviewKeyAction.openAppSettings:
        _setStatus('Would open WinFlowzApp settings on Android.');
        break;
      case KeyboardPreviewKeyAction.openThemeSettings:
        _setStatus('Would open WinFlowzApp Appearance settings on Android.');
        break;
      case KeyboardPreviewKeyAction.toggleVibration:
        setState(() {
          _vibration = !_vibration;
          _status = _vibration ? 'Key vibration on.' : 'Key vibration off.';
        });
        break;
      case KeyboardPreviewKeyAction.toggleSound:
        setState(() {
          _sound = !_sound;
          _status = _sound ? 'Key sound on.' : 'Key sound off.';
        });
        break;
      case KeyboardPreviewKeyAction.toggleSuggestions:
        setState(() {
          _suggestions = !_suggestions;
          _status = _suggestions ? 'Suggestions on.' : 'Suggestions off.';
        });
        break;
      case KeyboardPreviewKeyAction.toggleSpecialCorners:
        setState(() {
          _specialCorners = !_specialCorners;
          _status = _specialCorners
              ? 'Special key corners on.'
              : 'Special key corners off.';
        });
        break;
      case KeyboardPreviewKeyAction.toggleFrench:
        setState(() {
          _french = !_french;
          _status = _french ? 'French enabled.' : 'French disabled.';
        });
        break;
      case KeyboardPreviewKeyAction.toggleEnglish:
        setState(() {
          _english = !_english;
          _status = _english ? 'English enabled.' : 'English disabled.';
        });
        break;
      case KeyboardPreviewKeyAction.suggestion:
        _insertSuggestion(key.output ?? key.label);
        break;
      case KeyboardPreviewKeyAction.snippet:
        _insertText(key.output ?? key.label, status: 'Snippet inserted.');
        break;
      case KeyboardPreviewKeyAction.text:
        var value = key.output ?? key.label;
        if (_shiftEnabled && value.isNotEmpty) {
          value = value.length == 1
              ? value.toUpperCase()
              : '${value[0].toUpperCase()}${value.substring(1)}';
        }
        _insertText(value);
        if (_shiftEnabled) {
          setState(() => _shiftEnabled = false);
        }
        break;
      case KeyboardPreviewKeyAction.unsupported:
        _setStatus(
          'Action non simulated: ${key.unsupportedReason ?? key.label}.',
        );
        break;
    }
  }

  void _onKeyLongPressed(KeyboardPreviewKey key) {
    if (!key.enabled) {
      return;
    }
    if (key.action == KeyboardPreviewKeyAction.panelSwitch &&
        key.panelTarget == KeyboardPreviewPanel.clipboard) {
      _setPanel(KeyboardPreviewPanel.clipboardFull);
      return;
    }
    final corner = key.topLeftShortcut;
    if (corner != null) {
      _simulateCorner(corner);
      return;
    }
    _onKeyPressed(key);
  }

  void _simulateCorner(AndroidKeyboardCornerShortcut shortcut) {
    final expression = shortcut.expression.toLowerCase();
    if (expression.contains('action:') ||
        expression.startsWith('keyevent:') ||
        expression.startsWith('modifier:') ||
        expression.contains(',keyevent:') ||
        expression.contains(',action:') ||
        expression.contains(',modifier:')) {
      _setStatus('Native-only corner action: ${shortcut.displayLabel}.');
      return;
    }
    final text = _textFromCornerExpression(shortcut.expression);
    _insertText(text, status: 'Corner shortcut inserted "$text".');
  }

  String _textFromCornerExpression(String expression) {
    final separator = expression.indexOf(':');
    final payload = separator > 0
        ? expression.substring(separator + 1)
        : expression;
    final trimmed = payload.trim();
    if (trimmed.startsWith("'") &&
        trimmed.endsWith("'") &&
        trimmed.length > 1) {
      return trimmed
          .substring(1, trimmed.length - 1)
          .replaceAll(r"\'", "'")
          .replaceAll(r'\\', r'\');
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final preview = KeyboardPreviewSnapshot(
      profile: _profile,
      fieldContext: _fieldContext,
      panel: _panel,
      mode: _effectiveMode,
      privateMode: _privateMode,
      corners: _corners,
      debug: _debug,
      vibration: _vibration,
      sound: _sound,
      suggestionsEnabled: _suggestions,
      specialCorners: _specialCorners,
      frenchEnabled: _french,
      englishEnabled: _english,
      shiftEnabled: _shiftEnabled,
      mediaNowPlaying: _mediaNowPlaying,
      cornerConfig: _cornerConfig,
    );

    return ListView(
      padding: AppInsets.screen,
      children: [
        Text('Keyboard preview', style: Theme.of(context).textTheme.titleLarge),
        AppGaps.x2,
        Text(
          'Browser review surface for WinFlowzApp Keyboard layouts. Native IME behavior still needs Android device validation.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        AppGaps.x4,
        _PreviewControls(
          profile: _profile,
          fieldContext: _fieldContext,
          panel: _panel,
          mode: _mode,
          privateMode: _privateMode,
          corners: _corners,
          debug: _debug,
          cornerConfig: _cornerConfig,
          onProfileChanged: (value) => setState(() => _profile = value),
          onFieldContextChanged: _setFieldContext,
          onPanelChanged: _setPanel,
          onModeChanged: _setMode,
          onPrivateModeChanged: (value) => setState(() {
            _privateMode = value;
            _status = value
                ? 'Private mode on: clipboard/snippets disabled in preview.'
                : 'Private mode off.';
          }),
          onCornersChanged: (value) => setState(() {
            _corners = value;
            _status = value ? 'Corners enabled.' : 'Corners disabled.';
          }),
          onDebugChanged: (value) => setState(() {
            _debug = value;
            _status = value ? 'Debug overlay on.' : 'Debug overlay off.';
          }),
          onCornerPresetChanged: (value) => setState(() {
            _cornerConfig = _cornerConfig.copyWith(presetId: value);
            _status = 'Preview corner preset: $value.';
          }),
        ),
        AppGaps.x4,
        _KeyboardFrame(
          snapshot: preview,
          buffer: _buffer,
          cursor: _cursor,
          status: _status,
          onKeyPressed: _onKeyPressed,
          onKeyLongPressed: _onKeyLongPressed,
          onClear: _clearBuffer,
          onReset: _resetSandbox,
        ),
      ],
    );
  }
}

class _PreviewControls extends StatelessWidget {
  const _PreviewControls({
    required this.profile,
    required this.fieldContext,
    required this.panel,
    required this.mode,
    required this.privateMode,
    required this.corners,
    required this.debug,
    required this.cornerConfig,
    required this.onProfileChanged,
    required this.onFieldContextChanged,
    required this.onPanelChanged,
    required this.onModeChanged,
    required this.onPrivateModeChanged,
    required this.onCornersChanged,
    required this.onDebugChanged,
    required this.onCornerPresetChanged,
  });

  final KeyboardLayoutProfile profile;
  final KeyboardPreviewFieldContext fieldContext;
  final KeyboardPreviewPanel panel;
  final KeyboardPreviewMode mode;
  final bool privateMode;
  final bool corners;
  final bool debug;
  final AndroidKeyboardCornerConfig cornerConfig;
  final ValueChanged<KeyboardLayoutProfile> onProfileChanged;
  final ValueChanged<KeyboardPreviewFieldContext> onFieldContextChanged;
  final ValueChanged<KeyboardPreviewPanel> onPanelChanged;
  final ValueChanged<KeyboardPreviewMode> onModeChanged;
  final ValueChanged<bool> onPrivateModeChanged;
  final ValueChanged<bool> onCornersChanged;
  final ValueChanged<bool> onDebugChanged;
  final ValueChanged<String> onCornerPresetChanged;

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
                  value: profile,
                  values: KeyboardLayoutProfile.values,
                  labelFor: (value) => value.name.toUpperCase(),
                  onChanged: onProfileChanged,
                ),
                _Dropdown<KeyboardPreviewFieldContext>(
                  fieldKey: const Key('keyboard-preview-field-dropdown'),
                  label: 'Field',
                  value: fieldContext,
                  values: KeyboardPreviewFieldContext.values,
                  labelFor: (value) => value.label,
                  onChanged: onFieldContextChanged,
                ),
                _Dropdown<KeyboardPreviewPanel>(
                  fieldKey: const Key('keyboard-preview-panel-dropdown'),
                  label: 'Panel',
                  value: panel,
                  values: KeyboardPreviewPanel.values,
                  labelFor: (value) => value.label,
                  onChanged: onPanelChanged,
                ),
                _Dropdown<KeyboardPreviewMode>(
                  fieldKey: const Key('keyboard-preview-mode-dropdown'),
                  label: 'Mode',
                  value: mode,
                  values: KeyboardPreviewMode.values,
                  labelFor: (value) => value.label,
                  onChanged: fieldContext.numeric ? null : onModeChanged,
                ),
                _Dropdown<String>(
                  fieldKey: const Key(
                    'keyboard-preview-corner-preset-dropdown',
                  ),
                  label: 'Corners',
                  value: cornerConfig.presetId,
                  values: KeyboardCornerPresetCatalog.presets
                      .map((preset) => preset.id)
                      .toList(growable: false),
                  labelFor: (value) => KeyboardCornerPresetCatalog.presets
                      .firstWhere((preset) => preset.id == value)
                      .name,
                  onChanged: onCornerPresetChanged,
                ),
              ],
            ),
            AppGaps.x3,
            Wrap(
              spacing: AppSpacing.x2,
              runSpacing: AppSpacing.x2,
              children: [
                FilterChip(
                  selected: corners,
                  onSelected: onCornersChanged,
                  avatar: const Icon(Icons.open_in_full_outlined),
                  label: const Text('Corners'),
                ),
                FilterChip(
                  selected: privateMode,
                  onSelected: onPrivateModeChanged,
                  avatar: const Icon(Icons.lock_outline),
                  label: const Text('Private'),
                ),
                FilterChip(
                  selected: debug,
                  onSelected: onDebugChanged,
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
                for (final row in snapshot.rows) ...[
                  _KeyboardRow(
                    row: row,
                    debug: snapshot.debug,
                    onKeyPressed: onKeyPressed,
                    onKeyLongPressed: onKeyLongPressed,
                  ),
                  AppGaps.x2,
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
        ? 'WinFlowzApp - private input'
        : 'WinFlowzApp - ${snapshot.fieldContext.label}';
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
        _modeKey('ABC', KeyboardPreviewMode.letters),
        _modeKey('123', KeyboardPreviewMode.numbers),
        _panelKey('Acc', KeyboardPreviewPanel.accents),
        _modeKey('#+=', KeyboardPreviewMode.symbols),
        _panelKey('Nav', KeyboardPreviewPanel.navigation),
        _panelKey('Emoji', KeyboardPreviewPanel.emoji),
        _panelKey(
          'Clip',
          KeyboardPreviewPanel.clipboard,
          enabled: !privateMode,
          activeOverride:
              panel == KeyboardPreviewPanel.clipboard ||
              panel == KeyboardPreviewPanel.clipboardFull,
        ),
        _panelKey('Snip', KeyboardPreviewPanel.snippets, enabled: !privateMode),
        _panelKey('Media', KeyboardPreviewPanel.media),
        _panelKey('Prefs', KeyboardPreviewPanel.settings),
        const KeyboardPreviewKey(
          label: 'Mic',
          special: true,
          action: KeyboardPreviewKeyAction.unsupported,
          unsupportedReason: 'Voice dictation simulation is not wired here',
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
              _unsupportedKey('Cut'),
              _unsupportedKey('Paste'),
              _unsupportedKey('Undo'),
              _unsupportedKey('Redo'),
              const KeyboardPreviewKey(
                label: 'Back',
                special: true,
                weight: 1.2,
                action: KeyboardPreviewKeyAction.closePanel,
              ),
            ],
          ),
          KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightRegular,
            keys: [
              _unsupportedKey('Para↑', weight: 1.3),
              _unsupportedKey('Line↑', weight: 1.3),
            ],
            leadingWeight: 1.5,
            trailingWeight: 1.5,
          ),
          KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightRegular,
            keys: [
              _unsupportedKey('Word←', weight: 1.3),
              _unsupportedKey('←', weight: 1.1),
              _unsupportedKey('→', weight: 1.1),
              _unsupportedKey('Word→', weight: 1.3),
            ],
            leadingWeight: .6,
            trailingWeight: .6,
          ),
          KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightRegular,
            keys: [
              _unsupportedKey('Line↓', weight: 1.3),
              _unsupportedKey('Para↓', weight: 1.3),
            ],
            leadingWeight: 1.5,
            trailingWeight: 1.5,
          ),
          KeyboardPreviewRow(
            height: AppKeyboardPreview.rowHeightCompact,
            keys: [
              KeyboardPreviewKey(
                label: 'Del←',
                special: true,
                action: KeyboardPreviewKeyAction.backspace,
              ),
              _unsupportedKey('DelW←', weight: 1.2),
              _unsupportedKey('Del→', weight: 1.1),
              _unsupportedKey('DelW→', weight: 1.2),
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
              _unsupportedKey('Rec'),
              _unsupportedKey(':-)'),
              _unsupportedKey('Hands'),
              _unsupportedKey('Sym'),
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
              KeyboardPreviewKey(label: ':)', output: ':)'),
              KeyboardPreviewKey(label: ':D', output: ':D'),
              KeyboardPreviewKey(label: '<3', output: '<3'),
              KeyboardPreviewKey(label: 'OK', output: 'OK'),
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
                label: 'Close',
                special: true,
                action: KeyboardPreviewKeyAction.closePanel,
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
            keyId: 'modifier-fn',
            specialKey: true,
            key: const KeyboardPreviewKey(
              label: 'Fn',
              special: true,
              weight: .9,
              action: KeyboardPreviewKeyAction.unsupported,
              unsupportedReason: 'Modifier keys are native-only in preview',
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
  }) {
    return KeyboardPreviewKey(
      label: label,
      active: activeOverride ?? panel == target,
      enabled: enabled,
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
