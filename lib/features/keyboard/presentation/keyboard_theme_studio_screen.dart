import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/platform/android_keyboard_bridge.dart';
import '../../../core/platform/platform_capabilities.dart';
import '../../../core/widgets/app_components.dart';
import '../domain/keyboard_models.dart';
import '../domain/keyboard_theme_validation.dart';

class KeyboardThemeStudioScreen extends StatefulWidget {
  const KeyboardThemeStudioScreen({super.key});

  @override
  State<KeyboardThemeStudioScreen> createState() =>
      _KeyboardThemeStudioScreenState();
}

class _KeyboardThemeStudioScreenState extends State<KeyboardThemeStudioScreen> {
  KeyboardThemeConfig _saved = KeyboardThemeConfig.defaults();
  KeyboardThemeConfig _draft = KeyboardThemeConfig.defaults();
  bool _loading = true;
  bool _saving = false;
  String? _message;

  bool get _dirty => _saved.toMap().toString() != _draft.toMap().toString();
  KeyboardThemeValidationResult get _validation =>
      KeyboardThemeValidator.validate(_draft);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final config = await AndroidKeyboardBridge.getKeyboardThemeConfig();
      if (!mounted) return;
      setState(() {
        _saved = config;
        _draft = config;
        _message = PlatformCapabilities.keyboardImeSupported
            ? 'Theme loaded. Changes remain in draft until Save.'
            : 'Simulation only on this platform.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _message = 'Unable to load keyboard theme: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final validation = _validation;
    if (!validation.canSave) {
      setState(() => _message = validation.errors.first);
      return;
    }
    if (!PlatformCapabilities.keyboardImeSupported) {
      setState(
        () => _message = 'Save is Android-only for native keyboard theme.',
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final saved = await AndroidKeyboardBridge.setKeyboardThemeConfig(_draft);
      if (!mounted) return;
      setState(() {
        _saved = saved;
        _draft = saved;
        _message = 'Keyboard theme saved.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _message = 'Unable to save keyboard theme: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _reset() async {
    if (!PlatformCapabilities.keyboardImeSupported) {
      setState(() {
        _draft = KeyboardThemeConfig.defaults();
        _message = 'Draft reset to defaults (simulation).';
      });
      return;
    }
    try {
      final reset = await AndroidKeyboardBridge.resetKeyboardThemeConfig();
      if (!mounted) return;
      setState(() {
        _saved = reset;
        _draft = reset;
        _message = 'Keyboard theme reset to defaults.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _message = 'Unable to reset keyboard theme: $error');
    }
  }

  Future<void> _importImage() async {
    try {
      final result = await AndroidKeyboardBridge.importKeyboardThemeImage();
      final path = result['path'] as String?;
      if (!mounted) {
        return;
      }
      if (path == null || path.trim().isEmpty) {
        setState(() => _message = 'Image import failed: empty path.');
        return;
      }
      setState(() {
        _draft = _draft.copyWith(useImage: true, backgroundImagePath: path);
        _message = 'Image imported for keyboard background.';
      });
    } on AndroidKeyboardBridgeException catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () =>
            _message = 'Image import failed (${error.code}): ${error.message}',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _message = 'Image import failed: $error');
    }
  }

  Future<void> _exportJson() async {
    final jsonText = const JsonEncoder.withIndent('  ').convert(_draft.toMap());
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export theme JSON'),
        content: SizedBox(
          width: 520,
          child: SelectableText(jsonText, key: const Key('theme-export-json')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _importJson() async {
    final controller = TextEditingController();
    final raw = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import theme JSON'),
        content: SizedBox(
          width: 520,
          child: TextField(
            key: const Key('theme-import-json-field'),
            controller: controller,
            minLines: 8,
            maxLines: 12,
            decoration: const InputDecoration(
              hintText: '{"version":1,"presetId":"..."}',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Preview import'),
          ),
        ],
      ),
    );
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        setState(
          () => _message = 'Theme import failed: JSON must be an object.',
        );
        return;
      }
      final imported = KeyboardThemeConfig.fromMap(
        Map<Object?, Object?>.from(decoded),
      );
      final validation = KeyboardThemeValidator.validate(imported);
      if (!validation.canSave) {
        setState(
          () => _message = 'Theme import blocked: ${validation.errors.first}',
        );
        return;
      }
      setState(() {
        _draft = imported;
        _message = 'Theme JSON imported into draft. Press Save to apply.';
      });
    } catch (error) {
      setState(() => _message = 'Theme import failed: invalid JSON.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final mediaQuery = MediaQuery.of(context);
    final safeBottomPadding = mediaQuery.viewPadding.bottom;
    return Scaffold(
      appBar: AppBar(title: const Text('Keyboard Theme Studio')),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyPreviewHeaderDelegate(
              theme: _draft,
              topPadding: 8,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + safeBottomPadding),
            sliver: SliverList.list(
              children: [
                _StudioSection(
                  title: 'Preset',
                  subtitle: 'Set a base then adjust gradient and key colors.',
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('theme-preset-${_draft.presetId}'),
                    initialValue: _draft.presetId,
                    items: KeyboardThemePresetCatalog.presets
                        .map(
                          (preset) => DropdownMenuItem<String>(
                            value: preset.id,
                            child: Text(preset.name),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(
                        () => _draft = KeyboardThemePresetCatalog.configFor(
                          value,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _StudioSection(
                  title: 'Background',
                  subtitle: 'Use a flat background or gradient.',
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Gradient background'),
                        value: _draft.useGradient,
                        onChanged: (value) => setState(
                          () => _draft = _draft.copyWith(useGradient: value),
                        ),
                      ),
                      DropdownButtonFormField<KeyboardThemeGradientStyle>(
                        key: ValueKey(
                          'theme-gradient-${_draft.gradientStyle.name}',
                        ),
                        initialValue: _draft.gradientStyle,
                        decoration: const InputDecoration(
                          labelText: 'Gradient style',
                        ),
                        items: KeyboardThemeGradientStyle.values
                            .map(
                              (style) => DropdownMenuItem(
                                value: style,
                                child: Text(_gradientLabel(style)),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: _draft.useGradient
                            ? (style) {
                                if (style == null) return;
                                setState(
                                  () => _draft = _draft.copyWith(
                                    gradientStyle: style,
                                  ),
                                );
                              }
                            : null,
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Image background'),
                        value: _draft.useImage,
                        onChanged: (value) => setState(
                          () => _draft = _draft.copyWith(useImage: value),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: _importImage,
                          icon: const Icon(Icons.image_outlined),
                          label: const Text('Import image'),
                        ),
                      ),
                      if (_draft.backgroundImagePath != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Image: ${_draft.backgroundImagePath}',
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      _ColorField(
                        label: 'Background start',
                        value: _draft.backgroundStartColor,
                        onChanged: (color) => setState(
                          () => _draft = _draft.copyWith(
                            backgroundStartColor: color,
                          ),
                        ),
                      ),
                      _ColorField(
                        label: 'Background end',
                        value: _draft.backgroundEndColor,
                        onChanged: (color) => setState(
                          () => _draft = _draft.copyWith(
                            backgroundEndColor: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _StudioSection(
                  title: 'Keys',
                  subtitle:
                      'Primary colors applied by the native keyboard renderer.',
                  child: Column(
                    key: ValueKey(
                      'theme-keys-${_draft.keyColor}-${_draft.specialKeyColor}-${_draft.activeKeyColor}-${_draft.pressedKeyColor}-${_draft.textColor}-${_draft.cornerTextColor}-${_draft.statusTextColor}',
                    ),
                    children: [
                      _ColorField(
                        label: 'Key color',
                        value: _draft.keyColor,
                        onChanged: (c) => setState(
                          () => _draft = _draft.copyWith(keyColor: c),
                        ),
                      ),
                      _ColorField(
                        label: 'Special key',
                        value: _draft.specialKeyColor,
                        onChanged: (c) => setState(
                          () => _draft = _draft.copyWith(specialKeyColor: c),
                        ),
                      ),
                      _ColorField(
                        label: 'Active key',
                        value: _draft.activeKeyColor,
                        onChanged: (c) => setState(
                          () => _draft = _draft.copyWith(activeKeyColor: c),
                        ),
                      ),
                      _ColorField(
                        label: 'Pressed key',
                        value: _draft.pressedKeyColor,
                        onChanged: (c) => setState(
                          () => _draft = _draft.copyWith(pressedKeyColor: c),
                        ),
                      ),
                      _ColorField(
                        label: 'Text',
                        value: _draft.textColor,
                        onChanged: (c) => setState(
                          () => _draft = _draft.copyWith(textColor: c),
                        ),
                      ),
                      _ColorField(
                        label: 'Corner text',
                        value: _draft.cornerTextColor,
                        onChanged: (c) => setState(
                          () => _draft = _draft.copyWith(cornerTextColor: c),
                        ),
                      ),
                      _ColorField(
                        label: 'Status text',
                        value: _draft.statusTextColor,
                        onChanged: (c) => setState(
                          () => _draft = _draft.copyWith(statusTextColor: c),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _StudioSection(
                  title: 'Spacing',
                  subtitle:
                      'Control touch density: no gap for larger targets, airy gap for visual style.',
                  initiallyExpanded: false,
                  child: Column(
                    children: [
                      _SliderField(
                        label: 'Key gap',
                        value: _draft.keyHorizontalGap,
                        min: 0,
                        max: 14,
                        divisions: 14,
                        valueLabel: '${_draft.keyHorizontalGap.round()} px',
                        onChanged: (value) => setState(
                          () =>
                              _draft = _draft.copyWith(keyHorizontalGap: value),
                        ),
                      ),
                      _SliderField(
                        label: 'Row gap',
                        value: _draft.rowVerticalGap,
                        min: 0,
                        max: 16,
                        divisions: 16,
                        valueLabel: '${_draft.rowVerticalGap.round()} px',
                        onChanged: (value) => setState(
                          () => _draft = _draft.copyWith(rowVerticalGap: value),
                        ),
                      ),
                      _SliderField(
                        label: 'Key width',
                        value: _draft.keyWidthScale,
                        min: 0.75,
                        max: 1,
                        divisions: 25,
                        valueLabel: '${(_draft.keyWidthScale * 100).round()}%',
                        onChanged: (value) => setState(
                          () => _draft = _draft.copyWith(keyWidthScale: value),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _StudioSection(
                  title: 'Borders & shadows',
                  subtitle: 'Rounded keys, thin borders and bounded shadows.',
                  initiallyExpanded: false,
                  child: Column(
                    children: [
                      _ColorField(
                        label: 'Border',
                        value: _draft.borderColor,
                        onChanged: (c) => setState(
                          () => _draft = _draft.copyWith(borderColor: c),
                        ),
                      ),
                      _ColorField(
                        label: 'Shadow',
                        value: _draft.shadowColor,
                        onChanged: (c) => setState(
                          () => _draft = _draft.copyWith(shadowColor: c),
                        ),
                      ),
                      _SliderField(
                        label: 'Border',
                        value: _draft.borderWidth,
                        min: 0,
                        max: 4,
                        divisions: 8,
                        valueLabel:
                            '${_draft.borderWidth.toStringAsFixed(1)} px',
                        onChanged: (value) => setState(
                          () => _draft = _draft.copyWith(borderWidth: value),
                        ),
                      ),
                      _SliderField(
                        label: 'Radius',
                        value: _draft.keyRadius,
                        min: 0,
                        max: 24,
                        divisions: 12,
                        valueLabel: '${_draft.keyRadius.round()} px',
                        onChanged: (value) => setState(
                          () => _draft = _draft.copyWith(keyRadius: value),
                        ),
                      ),
                      _SliderField(
                        label: 'Blur',
                        value: _draft.shadowBlur,
                        min: 0,
                        max: 18,
                        divisions: 9,
                        valueLabel: '${_draft.shadowBlur.round()} px',
                        onChanged: (value) => setState(
                          () => _draft = _draft.copyWith(shadowBlur: value),
                        ),
                      ),
                      _SliderField(
                        label: 'Offset',
                        value: _draft.shadowOffsetY,
                        min: -4,
                        max: 10,
                        divisions: 14,
                        valueLabel: '${_draft.shadowOffsetY.round()} px',
                        onChanged: (value) => setState(
                          () => _draft = _draft.copyWith(shadowOffsetY: value),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _StudioSection(
                  title: 'Effects',
                  subtitle:
                      'Short native press effects, reduced in private fields.',
                  child: Column(
                    children: [
                      DropdownButtonFormField<KeyboardThemePressEffect>(
                        key: ValueKey(
                          'theme-effect-${_draft.pressEffect.name}',
                        ),
                        initialValue: _draft.pressEffect,
                        decoration: const InputDecoration(
                          labelText: 'Press effect',
                        ),
                        items: KeyboardThemePressEffect.values
                            .map(
                              (effect) => DropdownMenuItem(
                                value: effect,
                                child: Text(_effectLabel(effect)),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (effect) {
                          if (effect == null) return;
                          setState(
                            () => _draft = _draft.copyWith(pressEffect: effect),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<KeyboardThemeEffectEasing>(
                        key: ValueKey(
                          'theme-easing-${_draft.effectEasing.name}',
                        ),
                        initialValue: _draft.effectEasing,
                        decoration: const InputDecoration(labelText: 'Easing'),
                        items: KeyboardThemeEffectEasing.values
                            .map(
                              (easing) => DropdownMenuItem(
                                value: easing,
                                child: Text(_easingLabel(easing)),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (easing) {
                          if (easing == null) return;
                          setState(
                            () =>
                                _draft = _draft.copyWith(effectEasing: easing),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _SliderField(
                        label: 'Intensity',
                        value: _draft.effectIntensity,
                        min: 0,
                        max: 1,
                        divisions: 10,
                        valueLabel: _draft.effectIntensity.toStringAsFixed(1),
                        onChanged: (value) => setState(
                          () =>
                              _draft = _draft.copyWith(effectIntensity: value),
                        ),
                      ),
                      _SliderField(
                        label: 'Duration',
                        value: _draft.effectDurationMs.toDouble(),
                        min: 80,
                        max: 600,
                        divisions: 13,
                        valueLabel: '${_draft.effectDurationMs} ms',
                        onChanged: (value) => setState(
                          () => _draft = _draft.copyWith(
                            effectDurationMs: value.round(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _StudioSection(
                  title: 'Import / export',
                  subtitle:
                      'Theme JSON excludes image bytes and stays local-only.',
                  initiallyExpanded: false,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        key: const Key('theme-import-json'),
                        onPressed: _importJson,
                        icon: const Icon(Icons.upload_file_outlined),
                        label: const Text('Import JSON'),
                      ),
                      OutlinedButton.icon(
                        key: const Key('theme-export-json-button'),
                        onPressed: _exportJson,
                        icon: const Icon(Icons.data_object_outlined),
                        label: const Text('Export JSON'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _ValidationPanel(validation: _validation),
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(_message!),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _dirty
                            ? () => setState(() => _draft = _saved)
                            : null,
                        child: const Text('Discard'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : _reset,
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving || !_validation.canSave
                            ? null
                            : _save,
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _effectLabel(KeyboardThemePressEffect effect) {
  return switch (effect) {
    KeyboardThemePressEffect.none => 'None',
    KeyboardThemePressEffect.scale => 'Scale',
    KeyboardThemePressEffect.pulse => 'Pulse',
    KeyboardThemePressEffect.shake => 'Shake',
    KeyboardThemePressEffect.ripple => 'Ripple',
    KeyboardThemePressEffect.glow => 'Glow',
    KeyboardThemePressEffect.confettiLite => 'Confetti lite',
    KeyboardThemePressEffect.fireworksLite => 'Fireworks lite',
  };
}

String _gradientLabel(KeyboardThemeGradientStyle style) {
  return switch (style) {
    KeyboardThemeGradientStyle.linear => 'Linear',
    KeyboardThemeGradientStyle.radial => 'Radial',
  };
}

String _easingLabel(KeyboardThemeEffectEasing easing) {
  return switch (easing) {
    KeyboardThemeEffectEasing.easeOut => 'Ease out',
    KeyboardThemeEffectEasing.linear => 'Linear',
    KeyboardThemeEffectEasing.spring => 'Spring',
  };
}

class _StudioSection extends StatelessWidget {
  const _StudioSection({
    required this.title,
    required this.subtitle,
    required this.child,
    this.initiallyExpanded = true,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        title: Text(title),
        subtitle: Text(subtitle),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [child],
      ),
    );
  }
}

class _ValidationPanel extends StatelessWidget {
  const _ValidationPanel({required this.validation});

  final KeyboardThemeValidationResult validation;

  @override
  Widget build(BuildContext context) {
    if (validation.errors.isEmpty && validation.warnings.isEmpty) {
      return const AppStatusCard(
        title: 'Theme is readable',
        subtitle: 'Contrast and performance bounds are acceptable.',
        icon: Icons.check_circle_outline,
      );
    }
    return AppStatusCard(
      title: validation.canSave ? 'Theme warnings' : 'Theme needs fixes',
      subtitle: [...validation.errors, ...validation.warnings].join('\n'),
      icon: validation.canSave ? Icons.info_outline : Icons.error_outline,
    );
  }
}

class _StickyPreviewHeaderDelegate extends SliverPersistentHeaderDelegate {
  _StickyPreviewHeaderDelegate({required this.theme, required this.topPadding});

  final KeyboardThemeConfig theme;
  final double topPadding;

  @override
  double get minExtent => maxExtent;

  @override
  double get maxExtent => topPadding + 260;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, topPadding, 16, 6),
        child: _PreviewSectionCard(theme: theme),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyPreviewHeaderDelegate oldDelegate) {
    return oldDelegate.theme != theme || oldDelegate.topPadding != topPadding;
  }
}

class _PreviewSectionCard extends StatelessWidget {
  const _PreviewSectionCard({required this.theme});

  final KeyboardThemeConfig theme;

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = Theme.of(context).textTheme.bodySmall;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Preview', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Draft-only simulation before native save.',
                    textAlign: TextAlign.end,
                    style: subtitleStyle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(child: _ThemeDraftPreview(theme: theme)),
          ],
        ),
      ),
    );
  }
}

class _SliderField extends StatelessWidget {
  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.valueLabel,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String valueLabel;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 82, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            label: valueLabel,
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 62, child: Text(valueLabel, textAlign: TextAlign.end)),
      ],
    );
  }
}

class _ColorField extends StatelessWidget {
  const _ColorField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        key: ValueKey('keyboard-theme-color-$label'),
        initialValue: value.toRadixString(16).toUpperCase().padLeft(8, '0'),
        decoration: InputDecoration(
          labelText: '$label (AARRGGBB)',
          suffixIcon: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(value),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
          ),
        ),
        onChanged: (raw) {
          final parsed = int.tryParse(raw.trim(), radix: 16);
          if (parsed != null) {
            onChanged(parsed);
          }
        },
        onFieldSubmitted: (raw) {
          final parsed = int.tryParse(raw.trim(), radix: 16);
          if (parsed != null) {
            onChanged(parsed);
          }
        },
      ),
    );
  }
}

class _ThemeDraftPreview extends StatefulWidget {
  const _ThemeDraftPreview({required this.theme});

  final KeyboardThemeConfig theme;

  @override
  State<_ThemeDraftPreview> createState() => _ThemeDraftPreviewState();
}

class _ThemeDraftPreviewState extends State<_ThemeDraftPreview> {
  final Set<String> _pressedKeys = <String>{};
  final Map<String, int> _pressTokens = <String, int>{};

  void _press(String key) {
    if (widget.theme.pressEffect == KeyboardThemePressEffect.none) {
      return;
    }
    final token = (_pressTokens[key] ?? 0) + 1;
    setState(() => _pressedKeys.add(key));
    _pressTokens[key] = token;
    final holdMs = widget.theme.effectDurationMs.clamp(80, 600);
    Future<void>.delayed(Duration(milliseconds: holdMs), () {
      if (!mounted) return;
      if (_pressTokens[key] != token) return;
      setState(() => _pressedKeys.remove(key));
    });
  }

  void _release(String key) {
    // Let the configured effect duration complete so quick taps remain visible.
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final gradientColors = [
      Color(theme.backgroundStartColor),
      Color(theme.backgroundEndColor),
    ];
    final background = BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Theme.of(context).colorScheme.outline),
      color: Color(theme.backgroundStartColor),
      gradient: theme.useGradient && !theme.useImage
          ? (theme.gradientStyle == KeyboardThemeGradientStyle.radial
                ? RadialGradient(
                    colors: gradientColors,
                    center: Alignment.topLeft,
                    radius: 1.25,
                  )
                : LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ))
          : null,
    );
    return DecoratedBox(
      key: const Key('keyboard-theme-studio-preview'),
      decoration: background,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _previewRow(theme, const ['Q', 'W', 'E', 'R', 'T']),
            SizedBox(height: theme.rowVerticalGap),
            _previewRow(theme, const ['A', 'S', 'D', 'F', 'G']),
            SizedBox(height: theme.rowVerticalGap),
            _previewRow(theme, const ['Shift', 'Z', 'X', 'C', '⌫']),
            SizedBox(height: theme.rowVerticalGap),
            Row(
              children: [
                _previewKey(theme, ',', special: true),
                SizedBox(width: theme.keyHorizontalGap),
                Expanded(
                  child: FractionallySizedBox(
                    widthFactor: theme.keyWidthScale,
                    child: _previewKey(theme, 'space'),
                  ),
                ),
                SizedBox(width: theme.keyHorizontalGap),
                _previewKey(theme, '↵', special: true, active: true),
              ],
            ),
            if (theme.pressEffect != KeyboardThemePressEffect.none) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_effectLabel(theme.pressEffect)} preview',
                  style: TextStyle(
                    color: Color(theme.statusTextColor),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _previewRow(KeyboardThemeConfig theme, List<String> labels) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          Expanded(
            child: FractionallySizedBox(
              widthFactor: theme.keyWidthScale,
              child: _previewKey(
                theme,
                labels[i],
                special: labels[i] == 'Shift' || labels[i] == '⌫',
              ),
            ),
          ),
          if (i != labels.length - 1) SizedBox(width: theme.keyHorizontalGap),
        ],
      ],
    );
  }

  Widget _previewKey(
    KeyboardThemeConfig theme,
    String label, {
    bool special = false,
    bool active = false,
  }) {
    final pressed = _pressedKeys.contains(label);
    final bg = active
        ? theme.activeKeyColor
        : (pressed
              ? theme.pressedKeyColor
              : (special ? theme.specialKeyColor : theme.keyColor));
    final double animatedScale = switch (theme.pressEffect) {
      KeyboardThemePressEffect.scale =>
        pressed ? 1 + 0.16 * theme.effectIntensity.clamp(0.25, 1) : 1,
      KeyboardThemePressEffect.pulse =>
        pressed ? 1 + 0.12 * theme.effectIntensity.clamp(0.25, 1) : 1,
      KeyboardThemePressEffect.shake => pressed ? 1.04 : 1,
      KeyboardThemePressEffect.none ||
      KeyboardThemePressEffect.ripple ||
      KeyboardThemePressEffect.glow ||
      KeyboardThemePressEffect.confettiLite ||
      KeyboardThemePressEffect.fireworksLite => 1,
    };
    final animatedOffsetX =
        theme.pressEffect == KeyboardThemePressEffect.shake && pressed
        ? 8.0 * theme.effectIntensity.clamp(0.35, 1)
        : 0.0;
    return GestureDetector(
      onTapDown: (_) => _press(label),
      onTapUp: (_) => _release(label),
      onTapCancel: () => _release(label),
      child: AnimatedContainer(
        duration: Duration(
          milliseconds: (theme.effectDurationMs * 0.45).round().clamp(60, 220),
        ),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(animatedOffsetX, 0, 0),
        child: AnimatedScale(
          scale: animatedScale,
          duration: Duration(
            milliseconds: (theme.effectDurationMs * 0.4).round().clamp(60, 200),
          ),
          curve: Curves.easeOut,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(bg),
                  borderRadius: BorderRadius.circular(theme.keyRadius),
                  border:
                      pressed &&
                          theme.pressEffect != KeyboardThemePressEffect.none
                      ? Border.all(color: Color(theme.activeKeyColor), width: 2)
                      : (theme.borderWidth > 0
                            ? Border.all(
                                color: Color(theme.borderColor),
                                width: theme.borderWidth,
                              )
                            : null),
                  boxShadow:
                      pressed &&
                          theme.pressEffect != KeyboardThemePressEffect.none
                      ? [
                          BoxShadow(
                            color: Color(
                              theme.activeKeyColor,
                            ).withValues(alpha: 0.45),
                            blurRadius: 14 + theme.effectIntensity * 14,
                            spreadRadius: 2 + theme.effectIntensity * 4,
                          ),
                        ]
                      : (theme.shadowBlur > 0
                            ? [
                                BoxShadow(
                                  color: Color(theme.shadowColor),
                                  blurRadius: theme.shadowBlur,
                                  offset: Offset(0, theme.shadowOffsetY),
                                ),
                              ]
                            : null),
                ),
                child: SizedBox(
                  height: 30,
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: Color(theme.textColor),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              if (pressed)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _PreviewPressEffectPainter(theme: theme),
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

class _PreviewPressEffectPainter extends CustomPainter {
  const _PreviewPressEffectPainter({required this.theme});

  final KeyboardThemeConfig theme;

  @override
  void paint(Canvas canvas, Size size) {
    final accent = Color(theme.activeKeyColor);
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..isAntiAlias = true;
    switch (theme.pressEffect) {
      case KeyboardThemePressEffect.ripple:
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = accent.withValues(alpha: 0.75);
        canvas.drawCircle(
          center,
          math.max(size.width, size.height) * 0.42,
          paint,
        );
      case KeyboardThemePressEffect.glow:
        paint
          ..style = PaintingStyle.fill
          ..color = accent.withValues(alpha: 0.24);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-5, -5, size.width + 10, size.height + 10),
            Radius.circular(theme.keyRadius + 5),
          ),
          paint,
        );
      case KeyboardThemePressEffect.confettiLite:
      case KeyboardThemePressEffect.fireworksLite:
        final count =
            theme.pressEffect == KeyboardThemePressEffect.fireworksLite
            ? 16
            : 10;
        final colors = <Color>[
          const Color(0xFF36B384),
          const Color(0xFFFFD166),
          const Color(0xFFEF476F),
          const Color(0xFF4CC9F0),
        ];
        for (var i = 0; i < count; i++) {
          final angle = math.pi * 2 * i / count;
          final distance = 18 + (i % 4) * 5 + theme.effectIntensity * 16;
          paint
            ..style = PaintingStyle.fill
            ..color = colors[i % colors.length];
          canvas.drawCircle(
            center +
                Offset(math.cos(angle) * distance, math.sin(angle) * distance),
            2.8,
            paint,
          );
        }
      case KeyboardThemePressEffect.none:
      case KeyboardThemePressEffect.scale:
      case KeyboardThemePressEffect.pulse:
      case KeyboardThemePressEffect.shake:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _PreviewPressEffectPainter oldDelegate) {
    return oldDelegate.theme != theme;
  }
}
