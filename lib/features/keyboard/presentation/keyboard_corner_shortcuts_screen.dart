import 'package:flutter/material.dart';

import '../../../core/platform/android_keyboard_bridge.dart';
import '../../../core/platform/platform_capabilities.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/keyboard_models.dart';

class KeyboardCornerShortcutsScreen extends StatefulWidget {
  const KeyboardCornerShortcutsScreen({super.key});

  @override
  State<KeyboardCornerShortcutsScreen> createState() =>
      _KeyboardCornerShortcutsScreenState();
}

class _KeyboardCornerShortcutsScreenState
    extends State<KeyboardCornerShortcutsScreen> {
  final _expressionController = TextEditingController();
  final _labelController = TextEditingController();
  AndroidKeyboardCornerConfig _config = AndroidKeyboardCornerConfig.defaults();
  bool _loading = true;
  bool _saving = false;
  bool _sensitive = false;
  String _selectedKeyId = _keyOptions.first.id;
  KeyboardCornerSlot _selectedSlot = KeyboardCornerSlot.topLeft;
  String? _message;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _expressionController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() => _loading = true);
    try {
      final config = await AndroidKeyboardBridge.getCornerConfig();
      if (!mounted) {
        return;
      }
      setState(() {
        _config = config;
        _message = PlatformCapabilities.keyboardImeSupported
            ? null
            : 'Simulation only on this platform. Android IME settings are not changed.';
      });
      _syncEditorsFromSelection();
    } on AndroidKeyboardBridgeException catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () => _message =
            'Unable to load corner shortcuts (${error.code}): ${error.message}',
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _setPreset(String presetId) async {
    setState(() => _saving = true);
    try {
      final next = PlatformCapabilities.keyboardImeSupported
          ? await AndroidKeyboardBridge.setCornerPreset(presetId)
          : _config.copyWith(presetId: presetId);
      if (!mounted) {
        return;
      }
      setState(() {
        _config = next;
        _message = 'Corner preset: ${_presetName(presetId)}.';
      });
      _syncEditorsFromSelection();
    } on AndroidKeyboardBridgeException catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () => _message =
            'Unable to save preset (${error.code}): ${error.message}',
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _saveOverride() async {
    final expression = _expressionController.text.trim();
    if (expression.isEmpty) {
      setState(() => _message = 'Expression is required.');
      return;
    }
    final label = _labelController.text.trim();
    final override = AndroidKeyboardCornerShortcut(
      keyId: _selectedKeyId,
      slot: _selectedSlot,
      expression: expression,
      label: label.isEmpty ? null : label,
      sensitive: _sensitive,
    );
    final nextOverrides = [
      for (final item in _config.overrides)
        if (item.keyId != _selectedKeyId || item.slot != _selectedSlot) item,
      override,
    ];
    await _persistConfig(
      _config.copyWith(overrides: nextOverrides),
      successMessage: 'Corner shortcut saved.',
    );
  }

  Future<void> _clearOverride() async {
    final nextOverrides = [
      for (final item in _config.overrides)
        if (item.keyId != _selectedKeyId || item.slot != _selectedSlot) item,
    ];
    await _persistConfig(
      _config.copyWith(overrides: nextOverrides),
      successMessage: 'Corner override cleared.',
    );
  }

  Future<void> _resetConfig() async {
    setState(() => _saving = true);
    try {
      final next = PlatformCapabilities.keyboardImeSupported
          ? await AndroidKeyboardBridge.resetCornerConfig()
          : AndroidKeyboardCornerConfig.defaults();
      if (!mounted) {
        return;
      }
      setState(() {
        _config = next;
        _message = 'Corner shortcuts reset to defaults.';
      });
      _syncEditorsFromSelection();
    } on AndroidKeyboardBridgeException catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () => _message =
            'Unable to reset shortcuts (${error.code}): ${error.message}',
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _persistConfig(
    AndroidKeyboardCornerConfig config, {
    required String successMessage,
  }) async {
    setState(() => _saving = true);
    try {
      final next = PlatformCapabilities.keyboardImeSupported
          ? await AndroidKeyboardBridge.setCornerConfig(config)
          : config;
      if (!mounted) {
        return;
      }
      setState(() {
        _config = next;
        _message = successMessage;
      });
      _syncEditorsFromSelection();
    } on AndroidKeyboardBridgeException catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () => _message =
            'Unable to save shortcut (${error.code}): ${error.message}',
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _selectKey(String value) {
    setState(() => _selectedKeyId = value);
    _syncEditorsFromSelection();
  }

  void _selectSlot(KeyboardCornerSlot value) {
    setState(() => _selectedSlot = value);
    _syncEditorsFromSelection();
  }

  void _syncEditorsFromSelection() {
    final shortcut = _overrideForSelection() ?? _presetForSelection();
    _expressionController.text = shortcut?.expression ?? '';
    _labelController.text = shortcut?.label ?? '';
    _sensitive = shortcut?.sensitive ?? false;
    if (mounted) {
      setState(() {});
    }
  }

  AndroidKeyboardCornerShortcut? _overrideForSelection() {
    for (final shortcut in _config.overrides.reversed) {
      if (shortcut.keyId == _selectedKeyId && shortcut.slot == _selectedSlot) {
        return shortcut;
      }
    }
    return null;
  }

  AndroidKeyboardCornerShortcut? _presetForSelection() {
    final resolved = KeyboardCornerPresetCatalog.resolvedForKey(
      config: _config.copyWith(overrides: const []),
      keyId: _selectedKeyId,
      cornersEnabled: true,
      specialKeyCornersEnabled: true,
      privateMode: false,
      specialKey: _selectedKey()?.special ?? false,
    );
    return resolved[_selectedSlot];
  }

  _KeyboardCornerKeyOption? _selectedKey() {
    return _keyOptions.firstWhere(
      (option) => option.id == _selectedKeyId,
      orElse: () => _keyOptions.first,
    );
  }

  String _presetName(String id) {
    return _config.availablePresets
        .firstWhere(
          (preset) => preset.id == id,
          orElse: () => const AndroidKeyboardCornerPreset(
            id: KeyboardCornerPresetCatalog.frenchAccents,
            name: 'French accents',
          ),
        )
        .name;
  }

  @override
  Widget build(BuildContext context) {
    final selectedKey = _selectedKey() ?? _keyOptions.first;
    final resolved = KeyboardCornerPresetCatalog.resolvedForKey(
      config: _config,
      keyId: _selectedKeyId,
      cornersEnabled: true,
      specialKeyCornersEnabled: true,
      privateMode: false,
      specialKey: selectedKey.special,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Corner shortcuts')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: AppInsets.screen,
              children: [
                Card(
                  child: Padding(
                    padding: AppInsets.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          key: ValueKey(_config.presetId),
                          initialValue: _config.presetId,
                          decoration: const InputDecoration(
                            labelText: 'Corner preset',
                          ),
                          items: [
                            for (final preset in _config.availablePresets)
                              DropdownMenuItem(
                                value: preset.id,
                                child: Text(preset.name),
                              ),
                          ],
                          onChanged: _saving || _config.availablePresets.isEmpty
                              ? null
                              : (value) {
                                  if (value != null) {
                                    _setPreset(value);
                                  }
                                },
                        ),
                        AppGaps.x2,
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: _saving ? null : _resetConfig,
                            icon: const Icon(Icons.restore),
                            label: const Text('Reset defaults'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AppGaps.x3,
                Card(
                  child: Padding(
                    padding: AppInsets.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: AppSpacing.x3,
                          runSpacing: AppSpacing.x3,
                          children: [
                            SizedBox(
                              width: 220,
                              child: DropdownButtonFormField<String>(
                                key: ValueKey(_selectedKeyId),
                                initialValue: _selectedKeyId,
                                decoration: const InputDecoration(
                                  labelText: 'Key',
                                ),
                                items: [
                                  for (final option in _keyOptions)
                                    DropdownMenuItem(
                                      value: option.id,
                                      child: Text(option.label),
                                    ),
                                ],
                                onChanged: _saving
                                    ? null
                                    : (value) {
                                        if (value != null) {
                                          _selectKey(value);
                                        }
                                      },
                              ),
                            ),
                            SizedBox(
                              width: 180,
                              child:
                                  DropdownButtonFormField<KeyboardCornerSlot>(
                                    key: ValueKey(_selectedSlot),
                                    initialValue: _selectedSlot,
                                    decoration: const InputDecoration(
                                      labelText: 'Corner',
                                    ),
                                    items: [
                                      for (final slot
                                          in KeyboardCornerSlot.values)
                                        DropdownMenuItem(
                                          value: slot,
                                          child: Text(_slotLabel(slot)),
                                        ),
                                    ],
                                    onChanged: _saving
                                        ? null
                                        : (value) {
                                            if (value != null) {
                                              _selectSlot(value);
                                            }
                                          },
                                  ),
                            ),
                          ],
                        ),
                        AppGaps.x3,
                        TextField(
                          controller: _expressionController,
                          enabled: !_saving,
                          decoration: const InputDecoration(
                            labelText: 'KeyboardKeyValue expression',
                            hintText: "à, label:'text', action:Undo",
                          ),
                        ),
                        AppGaps.x2,
                        TextField(
                          controller: _labelController,
                          enabled: !_saving,
                          decoration: const InputDecoration(
                            labelText: 'Corner label',
                            hintText: 'Optional short label',
                          ),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _sensitive,
                          onChanged: _saving
                              ? null
                              : (value) => setState(() => _sensitive = value),
                          title: const Text('Sensitive action'),
                          subtitle: const Text(
                            'Blocks this shortcut in private fields.',
                          ),
                        ),
                        Wrap(
                          spacing: AppSpacing.x2,
                          runSpacing: AppSpacing.x2,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _saving ? null : _clearOverride,
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear override'),
                            ),
                            FilledButton.icon(
                              onPressed: _saving ? null : _saveOverride,
                              icon: const Icon(Icons.save_outlined),
                              label: const Text('Save shortcut'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                AppGaps.x3,
                Card(
                  child: Padding(
                    padding: AppInsets.card,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedKey.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        AppGaps.x2,
                        for (final slot in KeyboardCornerSlot.values)
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(_slotLabel(slot)),
                            subtitle: Text(
                              resolved[slot]?.displayLabel ?? 'Default tap',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (_message != null) ...[
                  AppGaps.x3,
                  Text(
                    _message!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  String _slotLabel(KeyboardCornerSlot slot) {
    return switch (slot) {
      KeyboardCornerSlot.topLeft => 'Top left',
      KeyboardCornerSlot.topRight => 'Top right',
      KeyboardCornerSlot.bottomLeft => 'Bottom left',
      KeyboardCornerSlot.bottomRight => 'Bottom right',
    };
  }
}

class _KeyboardCornerKeyOption {
  const _KeyboardCornerKeyOption(this.id, this.label, {this.special = false});

  final String id;
  final String label;
  final bool special;
}

const _keyOptions = [
  _KeyboardCornerKeyOption('letter-a', 'A'),
  _KeyboardCornerKeyOption('letter-e', 'E'),
  _KeyboardCornerKeyOption('letter-i', 'I'),
  _KeyboardCornerKeyOption('letter-o', 'O'),
  _KeyboardCornerKeyOption('letter-u', 'U'),
  _KeyboardCornerKeyOption('letter-c', 'C'),
  _KeyboardCornerKeyOption('letter-n', 'N'),
  _KeyboardCornerKeyOption('letter-s', 'S'),
  _KeyboardCornerKeyOption('letter-j', 'J'),
  _KeyboardCornerKeyOption('letter-k', 'K'),
  _KeyboardCornerKeyOption('letter-l', 'L'),
  _KeyboardCornerKeyOption('letter-f', 'F'),
  _KeyboardCornerKeyOption('letter-g', 'G'),
  _KeyboardCornerKeyOption('letter-h', 'H'),
  _KeyboardCornerKeyOption('text-comma', 'Comma'),
  _KeyboardCornerKeyOption('text-period', 'Period'),
  _KeyboardCornerKeyOption('space', 'Space', special: true),
  _KeyboardCornerKeyOption('enter', 'Enter', special: true),
  _KeyboardCornerKeyOption('shift', 'Shift', special: true),
  _KeyboardCornerKeyOption('modifier-ctrl', 'Ctrl', special: true),
  _KeyboardCornerKeyOption('modifier-alt', 'Alt', special: true),
  _KeyboardCornerKeyOption('modifier-fn', 'Fn', special: true),
  _KeyboardCornerKeyOption('del-letter-row', 'Backspace', special: true),
];
