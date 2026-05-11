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
  emoji('Emoji'),
  clipboard('Clipboard'),
  snippets('Snippets'),
  media('Media'),
  settings('Settings');

  const KeyboardPreviewPanel(this.label);

  final String label;
}

enum KeyboardPreviewMode {
  letters('ABC'),
  numbers('123'),
  accents('Acc'),
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

  @override
  Widget build(BuildContext context) {
    final preview = KeyboardPreviewSnapshot(
      profile: _profile,
      fieldContext: _fieldContext,
      panel: _panel,
      mode: _fieldContext.numeric ? KeyboardPreviewMode.numbers : _mode,
      privateMode: _privateMode,
      corners: _corners,
      debug: _debug,
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
          onProfileChanged: (value) => setState(() => _profile = value),
          onFieldContextChanged: (value) {
            setState(() {
              _fieldContext = value;
              if (value.numeric) {
                _mode = KeyboardPreviewMode.numbers;
              }
            });
          },
          onPanelChanged: (value) => setState(() => _panel = value),
          onModeChanged: (value) => setState(() => _mode = value),
          onPrivateModeChanged: (value) => setState(() => _privateMode = value),
          onCornersChanged: (value) => setState(() => _corners = value),
          onDebugChanged: (value) => setState(() => _debug = value),
        ),
        AppGaps.x4,
        _KeyboardFrame(snapshot: preview),
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
    required this.onProfileChanged,
    required this.onFieldContextChanged,
    required this.onPanelChanged,
    required this.onModeChanged,
    required this.onPrivateModeChanged,
    required this.onCornersChanged,
    required this.onDebugChanged,
  });

  final KeyboardLayoutProfile profile;
  final KeyboardPreviewFieldContext fieldContext;
  final KeyboardPreviewPanel panel;
  final KeyboardPreviewMode mode;
  final bool privateMode;
  final bool corners;
  final bool debug;
  final ValueChanged<KeyboardLayoutProfile> onProfileChanged;
  final ValueChanged<KeyboardPreviewFieldContext> onFieldContextChanged;
  final ValueChanged<KeyboardPreviewPanel> onPanelChanged;
  final ValueChanged<KeyboardPreviewMode> onModeChanged;
  final ValueChanged<bool> onPrivateModeChanged;
  final ValueChanged<bool> onCornersChanged;
  final ValueChanged<bool> onDebugChanged;

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
                  label: 'Profile',
                  value: profile,
                  values: KeyboardLayoutProfile.values,
                  labelFor: (value) => value.name.toUpperCase(),
                  onChanged: onProfileChanged,
                ),
                _Dropdown<KeyboardPreviewFieldContext>(
                  label: 'Field',
                  value: fieldContext,
                  values: KeyboardPreviewFieldContext.values,
                  labelFor: (value) => value.label,
                  onChanged: onFieldContextChanged,
                ),
                _Dropdown<KeyboardPreviewPanel>(
                  label: 'Panel',
                  value: panel,
                  values: KeyboardPreviewPanel.values,
                  labelFor: (value) => value.label,
                  onChanged: onPanelChanged,
                ),
                _Dropdown<KeyboardPreviewMode>(
                  label: 'Mode',
                  value: mode,
                  values: KeyboardPreviewMode.values,
                  labelFor: (value) => value.label,
                  onChanged: fieldContext.numeric ? null : onModeChanged,
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
    required this.label,
    required this.value,
    required this.values,
    required this.labelFor,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: [
          for (final item in values)
            DropdownMenuItem(value: item, child: Text(labelFor(item))),
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
  const _KeyboardFrame({required this.snapshot});

  final KeyboardPreviewSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: snapshot.privateMode
                ? const Color(0xFFF6E8E2)
                : const Color(0xFFEEF1EE),
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
                for (final row in snapshot.rows) ...[
                  _KeyboardRow(row: row, debug: snapshot.debug),
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
      height: 30,
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: const Color(0xFF333D38),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _KeyboardRow extends StatelessWidget {
  const _KeyboardRow({required this.row, required this.debug});

  final KeyboardPreviewRow row;
  final bool debug;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: row.height,
      child: Row(
        children: [
          if (row.leadingWeight > 0)
            Spacer(flex: (row.leadingWeight * 100).round()),
          for (final key in row.keys) ...[
            Expanded(
              flex: (key.weight * 100).round(),
              child: _KeyCap(keySpec: key, debug: debug),
            ),
            if (key != row.keys.last) AppGaps.horizontalX2,
          ],
          if (row.trailingWeight > 0)
            Spacer(flex: (row.trailingWeight * 100).round()),
        ],
      ),
    );
  }
}

class _KeyCap extends StatelessWidget {
  const _KeyCap({required this.keySpec, required this.debug});

  final KeyboardPreviewKey keySpec;
  final bool debug;

  @override
  Widget build(BuildContext context) {
    final background = keySpec.active
        ? const Color(0xFF17795D)
        : keySpec.special
        ? const Color(0xFFE0E6E3)
        : Colors.white;
    final foreground = keySpec.active ? Colors.white : const Color(0xFF1D2320);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: keySpec.enabled ? background : const Color(0xFFD6D9D7),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(
          color: debug ? AppColors.danger : AppColors.borderLight,
          width: debug ? 1.3 : 1,
        ),
      ),
      child: Stack(
        children: [
          if (keySpec.topLeft != null)
            _CornerLabel(text: keySpec.topLeft!, alignment: Alignment.topLeft),
          if (keySpec.topRight != null)
            _CornerLabel(
              text: keySpec.topRight!,
              alignment: Alignment.topRight,
            ),
          if (keySpec.bottomLeft != null)
            _CornerLabel(
              text: keySpec.bottomLeft!,
              alignment: Alignment.bottomLeft,
            ),
          if (keySpec.bottomRight != null)
            _CornerLabel(
              text: keySpec.bottomRight!,
              alignment: Alignment.bottomRight,
            ),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x1),
                child: Text(
                  keySpec.label,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
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
        padding: const EdgeInsets.all(4),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFF5C6762),
            fontWeight: FontWeight.w700,
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
  });

  final KeyboardLayoutProfile profile;
  final KeyboardPreviewFieldContext fieldContext;
  final KeyboardPreviewPanel panel;
  final KeyboardPreviewMode mode;
  final bool privateMode;
  final bool corners;
  final bool debug;

  List<KeyboardPreviewRow> get rows {
    final rows = <KeyboardPreviewRow>[_actionRow()];
    rows.addAll(_suggestionRows());
    rows.addAll(_panelRows());
    rows.addAll(_typingRows());
    rows.add(_controlRow());
    return rows;
  }

  KeyboardPreviewRow _actionRow() {
    return KeyboardPreviewRow(
      height: 40,
      keys: [
        _modeKey('ABC', KeyboardPreviewMode.letters),
        _modeKey('123', KeyboardPreviewMode.numbers),
        _modeKey('Acc', KeyboardPreviewMode.accents),
        _modeKey('#+=', KeyboardPreviewMode.symbols),
        _panelKey('Nav', KeyboardPreviewPanel.navigation),
        _panelKey('Emoji', KeyboardPreviewPanel.emoji),
        _panelKey(
          'Clip',
          KeyboardPreviewPanel.clipboard,
          enabled: !privateMode,
        ),
        _panelKey('Snip', KeyboardPreviewPanel.snippets, enabled: !privateMode),
        _panelKey('Media', KeyboardPreviewPanel.media),
        _panelKey('Prefs', KeyboardPreviewPanel.settings),
        const KeyboardPreviewKey(label: 'Mic', special: true),
      ],
    );
  }

  List<KeyboardPreviewRow> _suggestionRows() {
    if (privateMode ||
        fieldContext != KeyboardPreviewFieldContext.text ||
        mode != KeyboardPreviewMode.letters) {
      return const [];
    }
    return const [
      KeyboardPreviewRow(
        height: 42,
        keys: [
          KeyboardPreviewKey(label: "j'arrive", special: true, weight: 1.4),
          KeyboardPreviewKey(label: 'bonjour', special: true, weight: 1.4),
          KeyboardPreviewKey(label: 'merci', special: true, weight: 1.4),
        ],
      ),
    ];
  }

  List<KeyboardPreviewRow> _panelRows() {
    switch (panel) {
      case KeyboardPreviewPanel.none:
        return const [];
      case KeyboardPreviewPanel.navigation:
        return const [
          KeyboardPreviewRow(
            height: 42,
            keys: [
              KeyboardPreviewKey(label: 'Start', special: true),
              KeyboardPreviewKey(label: 'Word<', special: true),
              KeyboardPreviewKey(label: '<', special: true),
              KeyboardPreviewKey(label: '>', special: true),
              KeyboardPreviewKey(label: 'Word>', special: true),
              KeyboardPreviewKey(label: 'End', special: true),
            ],
          ),
          KeyboardPreviewRow(
            height: 42,
            keys: [
              KeyboardPreviewKey(label: 'Del', special: true),
              KeyboardPreviewKey(label: 'DelW<', special: true),
              KeyboardPreviewKey(label: 'FDel', special: true),
              KeyboardPreviewKey(label: 'DelW>', special: true),
              KeyboardPreviewKey(label: 'Esc', special: true),
              KeyboardPreviewKey(label: 'Back', special: true, weight: 1.2),
            ],
          ),
        ];
      case KeyboardPreviewPanel.emoji:
        return const [
          KeyboardPreviewRow(
            height: 42,
            keys: [
              KeyboardPreviewKey(label: 'Rec', special: true),
              KeyboardPreviewKey(label: ':-)', special: true),
              KeyboardPreviewKey(label: 'Hands', special: true),
              KeyboardPreviewKey(label: 'Sym', special: true),
              KeyboardPreviewKey(label: 'Close', special: true),
            ],
          ),
          KeyboardPreviewRow(
            height: 42,
            keys: [
              KeyboardPreviewKey(label: ':)'),
              KeyboardPreviewKey(label: ':D'),
              KeyboardPreviewKey(label: '<3'),
              KeyboardPreviewKey(label: 'OK'),
            ],
          ),
        ];
      case KeyboardPreviewPanel.clipboard:
        return const [
          KeyboardPreviewRow(
            height: 42,
            keys: [
              KeyboardPreviewKey(label: 'Copy', special: true, weight: 1.2),
              KeyboardPreviewKey(label: 'Cut', special: true),
              KeyboardPreviewKey(label: 'Paste', special: true, weight: 1.2),
              KeyboardPreviewKey(label: 'Plain', special: true),
              KeyboardPreviewKey(label: 'All', special: true),
              KeyboardPreviewKey(label: 'Undo', special: true),
              KeyboardPreviewKey(label: 'Redo', special: true),
              KeyboardPreviewKey(label: 'Pins app', special: true),
              KeyboardPreviewKey(label: 'Close', special: true),
            ],
          ),
        ];
      case KeyboardPreviewPanel.snippets:
        return const [
          KeyboardPreviewRow(
            height: 42,
            keys: [
              KeyboardPreviewKey(label: 'Snippet', special: true, weight: 1.8),
              KeyboardPreviewKey(label: 'App', special: true, weight: 1.2),
              KeyboardPreviewKey(label: 'Close', special: true),
            ],
          ),
        ];
      case KeyboardPreviewPanel.media:
        return const [
          KeyboardPreviewRow(
            height: 42,
            keys: [
              KeyboardPreviewKey(label: 'Prev', special: true),
              KeyboardPreviewKey(label: '>||', special: true, weight: 1.2),
              KeyboardPreviewKey(label: 'Next', special: true),
              KeyboardPreviewKey(label: 'Close', special: true),
            ],
          ),
        ];
      case KeyboardPreviewPanel.settings:
        return [
          KeyboardPreviewRow(
            height: 42,
            keys: [
              KeyboardPreviewKey(
                label: corners ? 'Corners on' : 'Corners off',
                special: true,
                active: corners,
                weight: 1.2,
              ),
              KeyboardPreviewKey(
                label: profile.name.toUpperCase(),
                special: true,
                weight: 1.1,
              ),
              KeyboardPreviewKey(
                label: debug ? 'Debug on' : 'Debug off',
                special: true,
                active: debug,
              ),
              const KeyboardPreviewKey(label: 'Close', special: true),
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
        return const [
          KeyboardPreviewRow(
            height: 46,
            keys: [
              KeyboardPreviewKey(label: '1'),
              KeyboardPreviewKey(label: '2'),
              KeyboardPreviewKey(label: '3'),
              KeyboardPreviewKey(label: '4'),
              KeyboardPreviewKey(label: '5'),
              KeyboardPreviewKey(label: '6'),
              KeyboardPreviewKey(label: '7'),
              KeyboardPreviewKey(label: '8'),
              KeyboardPreviewKey(label: '9'),
              KeyboardPreviewKey(label: '0'),
            ],
          ),
          KeyboardPreviewRow(
            height: 46,
            keys: [
              KeyboardPreviewKey(label: '+'),
              KeyboardPreviewKey(label: '-'),
              KeyboardPreviewKey(label: '*'),
              KeyboardPreviewKey(label: '/'),
              KeyboardPreviewKey(label: '='),
              KeyboardPreviewKey(label: '%'),
              KeyboardPreviewKey(label: '.'),
              KeyboardPreviewKey(label: ','),
            ],
            leadingWeight: .6,
            trailingWeight: .6,
          ),
        ];
      case KeyboardPreviewMode.accents:
        return const [
          KeyboardPreviewRow(
            height: 46,
            keys: [
              KeyboardPreviewKey(label: 'à'),
              KeyboardPreviewKey(label: 'â'),
              KeyboardPreviewKey(label: 'ä'),
              KeyboardPreviewKey(label: 'é'),
              KeyboardPreviewKey(label: 'è'),
              KeyboardPreviewKey(label: 'ê'),
              KeyboardPreviewKey(label: 'ë'),
              KeyboardPreviewKey(label: 'ç'),
            ],
          ),
          KeyboardPreviewRow(
            height: 46,
            keys: [
              KeyboardPreviewKey(label: 'î'),
              KeyboardPreviewKey(label: 'ï'),
              KeyboardPreviewKey(label: 'ô'),
              KeyboardPreviewKey(label: 'ö'),
              KeyboardPreviewKey(label: 'ù'),
              KeyboardPreviewKey(label: 'û'),
              KeyboardPreviewKey(label: 'ü'),
            ],
            leadingWeight: .5,
            trailingWeight: .5,
          ),
        ];
      case KeyboardPreviewMode.symbols:
        return const [
          KeyboardPreviewRow(
            height: 46,
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
            height: 46,
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
      KeyboardPreviewRow(height: 46, keys: _letterKeys(top)),
      KeyboardPreviewRow(
        height: 46,
        leadingWeight: .45,
        trailingWeight: .45,
        keys: _letterKeys(middle),
      ),
      KeyboardPreviewRow(
        height: 46,
        leadingWeight: 1,
        trailingWeight: 1,
        keys: _letterKeys(bottom),
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
    return KeyboardPreviewRow(
      height: 48,
      keys: [
        KeyboardPreviewKey(label: left, special: true, weight: 1.2),
        const KeyboardPreviewKey(label: 'Space', special: true, weight: 4),
        KeyboardPreviewKey(label: right, special: true, weight: 1.2),
        KeyboardPreviewKey(
          label: fieldContext.enterLabel,
          special: true,
          weight: 1.4,
        ),
      ],
    );
  }

  KeyboardPreviewKey _modeKey(String label, KeyboardPreviewMode target) {
    return KeyboardPreviewKey(
      label: label,
      active: mode == target,
      special: true,
    );
  }

  KeyboardPreviewKey _panelKey(
    String label,
    KeyboardPreviewPanel target, {
    bool enabled = true,
  }) {
    return KeyboardPreviewKey(
      label: label,
      active: panel == target,
      enabled: enabled,
      special: true,
    );
  }

  List<KeyboardPreviewKey> _letterKeys(String letters) {
    return [
      for (var index = 0; index < letters.length; index++)
        KeyboardPreviewKey(
          label: letters[index],
          topLeft: corners ? _cornerFor(letters[index], 0) : null,
          topRight: corners ? _cornerFor(letters[index], 1) : null,
        ),
    ];
  }

  String? _cornerFor(String letter, int slot) {
    const corners = {
      'a': ['à', 'â'],
      'e': ['é', 'è'],
      'i': ['î', 'ï'],
      'o': ['ô', 'ö'],
      'u': ['ù', 'û'],
      'c': ['ç', null],
      'n': ['ñ', null],
    };
    return corners[letter]?[slot];
  }
}

class KeyboardPreviewRow {
  const KeyboardPreviewRow({
    required this.height,
    required this.keys,
    this.leadingWeight = 0,
    this.trailingWeight = 0,
  });

  final double height;
  final List<KeyboardPreviewKey> keys;
  final double leadingWeight;
  final double trailingWeight;
}

class KeyboardPreviewKey {
  const KeyboardPreviewKey({
    required this.label,
    this.weight = 1,
    this.enabled = true,
    this.active = false,
    this.special = false,
    this.topLeft,
    this.topRight,
    this.bottomLeft,
    this.bottomRight,
  });

  final String label;
  final double weight;
  final bool enabled;
  final bool active;
  final bool special;
  final String? topLeft;
  final String? topRight;
  final String? bottomLeft;
  final String? bottomRight;
}
