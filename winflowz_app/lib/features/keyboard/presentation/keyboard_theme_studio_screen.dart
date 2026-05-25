import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/android_keyboard_bridge.dart';
import '../../../core/platform/platform_capabilities.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_components.dart';
import '../application/keyboard_sync_providers.dart';
import '../domain/keyboard_models.dart';
import '../domain/keyboard_theme_validation.dart';

class KeyboardThemeStudioScreen extends ConsumerStatefulWidget {
  const KeyboardThemeStudioScreen({super.key});

  @override
  ConsumerState<KeyboardThemeStudioScreen> createState() =>
      _KeyboardThemeStudioScreenState();
}

class _KeyboardThemeStudioScreenState
    extends ConsumerState<KeyboardThemeStudioScreen> {
  KeyboardThemeConfig _saved = KeyboardThemeConfig.defaults();
  KeyboardThemeConfig _draft = KeyboardThemeConfig.defaults();
  bool _loading = true;
  bool _saving = false;
  String? _message;
  String? _expandedStudioSectionId;

  bool get _dirty => _saved.toMap().toString() != _draft.toMap().toString();
  KeyboardThemeValidationResult get _validation =>
      KeyboardThemeValidator.validate(_draft);

  bool _isStudioSectionExpanded(String id) => _expandedStudioSectionId == id;

  void _setStudioSectionExpanded(String id, bool expanded) {
    setState(() => _expandedStudioSectionId = expanded ? id : null);
  }

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
            : 'Simulation sur ${PlatformCapabilities.currentPlatformLabel}: ${PlatformCapabilities.keyboardImeUnavailableReason}';
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
      ref
          .read(keyboardSyncChangeNotifierProvider.notifier)
          .markKeyboardProfileChanged();
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
      ref
          .read(keyboardSyncChangeNotifierProvider.notifier)
          .markKeyboardProfileChanged();
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
              dirty: _dirty,
              saving: _saving,
              validation: _validation,
              onPresetChanged: (value) {
                if (value == null) return;
                final brightness = Theme.of(context).brightness;
                setState(
                  () => _draft = KeyboardThemePresetCatalog.configFor(
                    value,
                    brightness: brightness,
                  ),
                );
              },
              onDiscard: _dirty ? () => setState(() => _draft = _saved) : null,
              onReset: _saving ? null : _reset,
              onSave: _saving || !_validation.canSave ? null : _save,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + safeBottomPadding),
            sliver: SliverList.list(
              children: [
                _StudioSection(
                  id: 'background',
                  title: 'Background',
                  subtitle: 'Use a flat background or gradient.',
                  expanded: _isStudioSectionExpanded('background'),
                  onExpansionChanged: _setStudioSectionExpanded,
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
                      _SliderField(
                        label: 'Opacity',
                        value: _draft.keyboardOpacity,
                        min: 0.25,
                        max: 1,
                        divisions: 15,
                        valueLabel:
                            '${(_draft.keyboardOpacity * 100).round()}%',
                        onChanged: (value) => setState(
                          () =>
                              _draft = _draft.copyWith(keyboardOpacity: value),
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
                SizedBox(height: AppSectionMetrics.sectionGap),
                _StudioSection(
                  id: 'keys',
                  title: 'Keys',
                  subtitle:
                      'Primary colors applied by the native keyboard renderer.',
                  expanded: _isStudioSectionExpanded('keys'),
                  onExpansionChanged: _setStudioSectionExpanded,
                  child: Column(
                    key: ValueKey(
                      'theme-keys-${_draft.keyColor}-${_draft.specialKeyColor}-${_draft.activeKeyColor}-${_draft.pressedKeyColor}-${_draft.textColor}-${_draft.cornerTextColor}-${_draft.cornerTextOpacity}-${_draft.statusTextColor}',
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
                      _SliderField(
                        label: 'Opacity',
                        value: _draft.cornerTextOpacity,
                        min: 0,
                        max: 0.85,
                        divisions: 17,
                        valueLabel:
                            '${(_draft.cornerTextOpacity * 100).round()}%',
                        onChanged: (value) => setState(
                          () => _draft = _draft.copyWith(
                            cornerTextOpacity: value,
                          ),
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
                SizedBox(height: AppSectionMetrics.sectionGap),
                _StudioSection(
                  id: 'spacing',
                  title: 'Spacing',
                  subtitle:
                      'Control touch density: no gap for larger targets, airy gap for visual style.',
                  expanded: _isStudioSectionExpanded('spacing'),
                  onExpansionChanged: _setStudioSectionExpanded,
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
                    ],
                  ),
                ),
                SizedBox(height: AppSectionMetrics.sectionGap),
                _StudioSection(
                  id: 'borders',
                  title: 'Borders & shadows',
                  subtitle: 'Rounded keys, thin borders and bounded shadows.',
                  expanded: _isStudioSectionExpanded('borders'),
                  onExpansionChanged: _setStudioSectionExpanded,
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
                SizedBox(height: AppSectionMetrics.sectionGap),
                _StudioSection(
                  id: 'effects',
                  title: 'Effects',
                  subtitle:
                      'Short native press effects, reduced in private fields.',
                  expanded: _isStudioSectionExpanded('effects'),
                  onExpansionChanged: _setStudioSectionExpanded,
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
                        label: 'Color hold',
                        value: _draft.pressHighlightDurationMs.toDouble(),
                        min: 0,
                        max: 1200,
                        divisions: 12,
                        valueLabel: '${_draft.pressHighlightDurationMs} ms',
                        onChanged: (value) => setState(
                          () => _draft = _draft.copyWith(
                            pressHighlightDurationMs: value.round(),
                          ),
                        ),
                      ),
                      _SliderField(
                        label: 'Effect time',
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
                SizedBox(height: AppSectionMetrics.sectionGap),
                _StudioSection(
                  id: 'import_export',
                  title: 'Import / export',
                  subtitle:
                      'Theme JSON excludes image bytes and stays local-only.',
                  expanded: _isStudioSectionExpanded('import_export'),
                  onExpansionChanged: _setStudioSectionExpanded,
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
                SizedBox(height: AppSectionMetrics.sectionGap),
                _ValidationPanel(validation: _validation),
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(_message!),
                ],
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
    required this.id,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.expanded,
    required this.onExpansionChanged,
  });

  final String id;
  final String title;
  final String subtitle;
  final Widget child;
  final bool expanded;
  final void Function(String id, bool expanded) onExpansionChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        key: ValueKey<String>('keyboard_theme_studio_section_${id}_$expanded'),
        initiallyExpanded: expanded,
        onExpansionChanged: (value) => onExpansionChanged(id, value),
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
  _StickyPreviewHeaderDelegate({
    required this.theme,
    required this.topPadding,
    required this.dirty,
    required this.saving,
    required this.validation,
    required this.onPresetChanged,
    required this.onDiscard,
    required this.onReset,
    required this.onSave,
  });

  final KeyboardThemeConfig theme;
  final double topPadding;
  final bool dirty;
  final bool saving;
  final KeyboardThemeValidationResult validation;
  final ValueChanged<String?> onPresetChanged;
  final VoidCallback? onDiscard;
  final VoidCallback? onReset;
  final VoidCallback? onSave;

  @override
  double get minExtent => maxExtent;

  @override
  double get maxExtent => topPadding + 364;

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
        child: _PreviewSectionCard(
          theme: theme,
          dirty: dirty,
          saving: saving,
          validation: validation,
          onPresetChanged: onPresetChanged,
          onDiscard: onDiscard,
          onReset: onReset,
          onSave: onSave,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyPreviewHeaderDelegate oldDelegate) {
    return oldDelegate.theme != theme ||
        oldDelegate.topPadding != topPadding ||
        oldDelegate.dirty != dirty ||
        oldDelegate.saving != saving ||
        oldDelegate.validation != validation;
  }
}

class _PreviewSectionCard extends StatelessWidget {
  const _PreviewSectionCard({
    required this.theme,
    required this.dirty,
    required this.saving,
    required this.validation,
    required this.onPresetChanged,
    required this.onDiscard,
    required this.onReset,
    required this.onSave,
  });

  final KeyboardThemeConfig theme;
  final bool dirty;
  final bool saving;
  final KeyboardThemeValidationResult validation;
  final ValueChanged<String?> onPresetChanged;
  final VoidCallback? onDiscard;
  final VoidCallback? onReset;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = Theme.of(context).textTheme.bodySmall;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Preview', style: Theme.of(context).textTheme.titleSmall),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: DropdownButtonFormField<String>(
                      key: ValueKey('theme-preset-${theme.presetId}'),
                      initialValue: theme.presetId,
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: 'Theme',
                      ),
                      items: KeyboardThemePresetCatalog.presets
                          .map(
                            (preset) => DropdownMenuItem<String>(
                              value: preset.id,
                              child: Text(preset.name),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: onPresetChanged,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              fit: FlexFit.loose,
              child: _ThemeDraftPreview(theme: theme),
            ),
            const SizedBox(height: 8),
            Text(
              'Draft-only simulation before native save.',
              textAlign: TextAlign.left,
              style: subtitleStyle,
            ),
            const SizedBox(height: 8),
            _PreviewActionRow(
              dirty: dirty,
              saving: saving,
              validation: validation,
              onDiscard: onDiscard,
              onReset: onReset,
              onSave: onSave,
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewActionRow extends StatelessWidget {
  const _PreviewActionRow({
    required this.dirty,
    required this.saving,
    required this.validation,
    required this.onDiscard,
    required this.onReset,
    required this.onSave,
  });

  final bool dirty;
  final bool saving;
  final KeyboardThemeValidationResult validation;
  final VoidCallback? onDiscard;
  final VoidCallback? onReset;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: dirty ? onDiscard : null,
            child: const Text('Discard'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: saving ? null : onReset,
            child: const Text('Reset'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton(
            onPressed: saving || !validation.canSave ? null : onSave,
            child: const Text('Save'),
          ),
        ),
      ],
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

class _ColorField extends StatefulWidget {
  const _ColorField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<_ColorField> createState() => _ColorFieldState();
}

class _ColorFieldState extends State<_ColorField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _hex(widget.value));
  }

  @override
  void didUpdateWidget(covariant _ColorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        _controller.text != _hex(widget.value)) {
      _controller.text = _hex(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openPicker() async {
    final picked = await showDialog<int>(
      context: context,
      builder: (context) =>
          _ColorPickerDialog(label: widget.label, initialValue: widget.value),
    );
    if (picked != null) {
      widget.onChanged(picked);
    }
  }

  void _applyHex(String raw) {
    final parsed = int.tryParse(raw.trim(), radix: 16);
    if (parsed != null) {
      widget.onChanged(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              key: ValueKey('keyboard-theme-color-${widget.label}'),
              controller: _controller,
              decoration: InputDecoration(
                labelText: '${widget.label} (AARRGGBB)',
              ),
              onChanged: _applyHex,
              onFieldSubmitted: _applyHex,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 52,
            height: 52,
            child: IconButton(
              key: ValueKey('keyboard-theme-color-picker-${widget.label}'),
              onPressed: _openPicker,
              tooltip: 'Pick color',
              icon: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(widget.value),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: const SizedBox(width: 24, height: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _hex(int value) =>
      (value & 0xFFFFFFFF).toRadixString(16).toUpperCase().padLeft(8, '0');
}

class _ColorPickerDialog extends StatefulWidget {
  const _ColorPickerDialog({required this.label, required this.initialValue});

  final String label;
  final int initialValue;

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late int _alpha;
  late int _red;
  late int _green;
  late int _blue;

  int get _value =>
      ((_alpha & 0xFF) << 24) |
      ((_red & 0xFF) << 16) |
      ((_green & 0xFF) << 8) |
      (_blue & 0xFF);

  @override
  void initState() {
    super.initState();
    final value = widget.initialValue & 0xFFFFFFFF;
    _alpha = (value >> 24) & 0xFF;
    _red = (value >> 16) & 0xFF;
    _green = (value >> 8) & 0xFF;
    _blue = value & 0xFF;
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(_value);
    return AlertDialog(
      title: Text('Pick ${widget.label}'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: const SizedBox(height: 74, width: double.infinity),
            ),
            const SizedBox(height: 12),
            _ColorChannelSlider(
              label: 'A',
              value: _alpha,
              onChanged: (value) => setState(() => _alpha = value),
            ),
            _ColorChannelSlider(
              label: 'R',
              value: _red,
              color: Colors.red,
              onChanged: (value) => setState(() => _red = value),
            ),
            _ColorChannelSlider(
              label: 'G',
              value: _green,
              color: Colors.green,
              onChanged: (value) => setState(() => _green = value),
            ),
            _ColorChannelSlider(
              label: 'B',
              value: _blue,
              color: Colors.blue,
              onChanged: (value) => setState(() => _blue = value),
            ),
            const SizedBox(height: 8),
            SelectableText(
              (_value & 0xFFFFFFFF)
                  .toRadixString(16)
                  .toUpperCase()
                  .padLeft(8, '0'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_value),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _ColorChannelSlider extends StatelessWidget {
  const _ColorChannelSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    this.color,
  });

  final String label;
  final int value;
  final Color? color;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 24, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 255,
            divisions: 255,
            activeColor: color,
            label: value.toString(),
            onChanged: (next) => onChanged(next.round()),
          ),
        ),
        SizedBox(width: 42, child: Text(value.toString().padLeft(3))),
      ],
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
    final token = (_pressTokens[key] ?? 0) + 1;
    setState(() => _pressedKeys.add(key));
    _pressTokens[key] = token;
  }

  void _release(String key) {
    final holdMs = widget.theme.pressHighlightDurationMs.clamp(0, 1200).toInt();
    final token = (_pressTokens[key] ?? 0) + 1;
    _pressTokens[key] = token;
    if (holdMs == 0) {
      setState(() => _pressedKeys.remove(key));
      return;
    }
    Future<void>.delayed(Duration(milliseconds: holdMs), () {
      if (!mounted) return;
      if (_pressTokens[key] != token) return;
      setState(() => _pressedKeys.remove(key));
    });
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
      color: _themeBackgroundColor(theme),
      gradient: theme.useGradient && !theme.useImage
          ? (theme.gradientStyle == KeyboardThemeGradientStyle.radial
                ? RadialGradient(
                    colors: gradientColors
                        .map((color) => _weightedThemeColor(color, theme))
                        .toList(growable: false),
                    center: Alignment.topLeft,
                    radius: 1.25,
                  )
                : LinearGradient(
                    colors: gradientColors
                        .map((color) => _weightedThemeColor(color, theme))
                        .toList(growable: false),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ))
          : null,
    );
    return DecoratedBox(
      key: const Key('keyboard-theme-studio-preview'),
      decoration: background,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            _previewActionRow(theme),
            SizedBox(height: theme.rowVerticalGap.clamp(3, 8).toDouble()),
            _previewRow(theme, const ['Q', 'W', 'E', 'R', 'T']),
            SizedBox(height: theme.rowVerticalGap.clamp(3, 8).toDouble()),
            _previewRow(theme, const [
              'A',
              'S',
              'D',
              'F',
              'G',
            ], pinnedLabel: 'D'),
            SizedBox(height: theme.rowVerticalGap.clamp(3, 8).toDouble()),
            _previewRow(theme, const ['Shift', 'Z', 'X', 'C', '⌫']),
            SizedBox(height: theme.rowVerticalGap.clamp(3, 8).toDouble()),
            Row(
              children: [
                Expanded(child: _previewKey(theme, ',', special: true)),
                SizedBox(width: theme.keyHorizontalGap),
                Expanded(flex: 2, child: _previewKey(theme, 'space')),
                SizedBox(width: theme.keyHorizontalGap),
                Expanded(
                  child: _previewKey(theme, '↵', special: true, active: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewRow(
    KeyboardThemeConfig theme,
    List<String> labels, {
    String? pinnedLabel,
  }) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          Expanded(
            child: _previewKey(
              theme,
              labels[i],
              special: labels[i] == 'Shift' || labels[i] == '⌫',
              pinned: labels[i] == pinnedLabel,
            ),
          ),
          if (i != labels.length - 1) SizedBox(width: theme.keyHorizontalGap),
        ],
      ],
    );
  }

  Widget _previewActionRow(KeyboardThemeConfig theme) {
    const labels = ['Prefs', 'Theme', 'Clip', 'Voice', 'Media'];
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          Expanded(
            child: _previewKey(
              theme,
              labels[i],
              special: true,
              pinned: labels[i] == 'Theme',
              compact: true,
            ),
          ),
          if (i != labels.length - 1)
            SizedBox(width: theme.keyHorizontalGap.clamp(3, 8).toDouble()),
        ],
      ],
    );
  }

  Widget _previewKey(
    KeyboardThemeConfig theme,
    String label, {
    bool special = false,
    bool active = false,
    bool pinned = false,
    bool compact = false,
  }) {
    final pressed = _pressedKeys.contains(label);
    final bg = active
        ? theme.activeKeyColor
        : (pressed
              ? theme.pressedKeyColor
              : (special ? theme.specialKeyColor : theme.keyColor));
    final labelColor = active
        ? _weightedThemeColor(
            _contrastTextColor(Color(bg)),
            theme,
            boost: _keyboardTextOpacityBoost,
          )
        : _weightedThemeColor(
            Color(theme.textColor),
            theme,
            boost: _keyboardTextOpacityBoost,
          );
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
                  color: _weightedThemeColor(Color(bg), theme),
                  borderRadius: BorderRadius.circular(theme.keyRadius),
                  border:
                      pressed &&
                          theme.pressEffect != KeyboardThemePressEffect.none
                      ? Border.all(
                          color: _weightedThemeColor(
                            Color(theme.activeKeyColor),
                            theme,
                            boost: _keyboardBorderOpacityBoost,
                          ),
                          width: 2,
                        )
                      : (theme.borderWidth > 0
                            ? Border.all(
                                color: _weightedThemeColor(
                                  Color(theme.borderColor),
                                  theme,
                                  boost: _keyboardBorderOpacityBoost,
                                ),
                                width: theme.borderWidth,
                              )
                            : null),
                  boxShadow:
                      pressed &&
                          theme.pressEffect != KeyboardThemePressEffect.none
                      ? [
                          BoxShadow(
                            color: Color(theme.activeKeyColor).withValues(
                              alpha:
                                  0.45 *
                                  _weightedKeyboardOpacity(
                                    theme,
                                    boost: _keyboardSurfaceOpacityBoost,
                                  ),
                            ),
                            blurRadius: 14 + theme.effectIntensity * 14,
                            spreadRadius: 2 + theme.effectIntensity * 4,
                          ),
                        ]
                      : (theme.shadowBlur > 0
                            ? [
                                BoxShadow(
                                  color: _weightedThemeColor(
                                    Color(theme.shadowColor),
                                    theme,
                                  ),
                                  blurRadius: theme.shadowBlur,
                                  offset: Offset(0, theme.shadowOffsetY),
                                ),
                              ]
                            : null),
                ),
                child: SizedBox(
                  height: compact ? 24 : 28,
                  child: Stack(
                    children: [
                      if (pinned)
                        _ThemePinnedBadge(theme: theme, keyColor: Color(bg)),
                      Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: labelColor,
                            fontSize: compact ? 11 : null,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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
              if (theme.presetId == KeyboardThemePresetCatalog.minimalContrast)
                const Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _HazardBorderPainter()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HazardBorderPainter extends CustomPainter {
  const _HazardBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final clip = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(4),
    );
    canvas.save();
    canvas.clipRRect(clip);
    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFFFFD400);
    canvas.drawRRect(clip.deflate(1.5), paint);
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.black;
    for (var x = -size.height; x < size.width + size.height; x += 14) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HazardBorderPainter oldDelegate) => false;
}

Color _contrastTextColor(Color background) {
  return _relativeLuminance(background) > .45 ? Colors.black : Colors.white;
}

const double _keyboardBackgroundOpacityBoost = 0;
const double _keyboardSurfaceOpacityBoost = 0;
const double _keyboardBorderOpacityBoost = 0.48;
const double _keyboardTextOpacityBoost = 0.58;

Color _themeBackgroundColor(KeyboardThemeConfig theme) {
  return _weightedThemeColor(
    Color(theme.backgroundStartColor),
    theme,
    boost: _keyboardBackgroundOpacityBoost,
  );
}

Color _weightedThemeColor(
  Color color,
  KeyboardThemeConfig theme, {
  double boost = _keyboardSurfaceOpacityBoost,
}) {
  final opacity = _weightedKeyboardOpacity(theme, boost: boost);
  return color.withValues(alpha: color.a * opacity);
}

double _weightedKeyboardOpacity(
  KeyboardThemeConfig theme, {
  required double boost,
}) {
  final opacity = theme.keyboardOpacity.clamp(0.25, 1.0).toDouble();
  return (opacity + (1 - opacity) * boost).clamp(0.0, 1.0).toDouble();
}

class _ThemePinnedBadge extends StatelessWidget {
  const _ThemePinnedBadge({required this.theme, required this.keyColor});

  final KeyboardThemeConfig theme;
  final Color keyColor;

  @override
  Widget build(BuildContext context) {
    final baseColor = _relativeLuminance(keyColor) > .55
        ? const Color(0xEB181C20)
        : const Color(0xEBFFFFFF);
    final borderColor = _relativeLuminance(keyColor) > .55
        ? Colors.white
        : Colors.black;
    return Positioned(
      top: 3,
      right: 3,
      child: CustomPaint(
        size: const Size(12, 12),
        painter: _PinnedBadgePainter(
          presetId: theme.presetId,
          baseColor: baseColor,
          accentColor: borderColor,
        ),
      ),
    );
  }
}

class _PinnedBadgePainter extends CustomPainter {
  const _PinnedBadgePainter({
    required this.presetId,
    required this.baseColor,
    required this.accentColor,
  });

  final String presetId;
  final Color baseColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;
    final center = Offset(size.width * .55, size.height * .45);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(_rotationForPreset());
    switch (presetId) {
      case KeyboardThemePresetCatalog.pixelCandy:
        _drawCandy(canvas, paint, size);
      case KeyboardThemePresetCatalog.sunsetGradient:
        _drawCloud(canvas, paint, size);
      case KeyboardThemePresetCatalog.glassMint:
        _drawDrop(canvas, paint, size);
      case KeyboardThemePresetCatalog.midnightAurora:
        _drawStar(canvas, paint, size);
      default:
        _drawLed(canvas, paint, size);
    }
    canvas.restore();
  }

  double _rotationForPreset() {
    return switch (presetId) {
      KeyboardThemePresetCatalog.glassMint => -math.pi / 4,
      KeyboardThemePresetCatalog.midnightAurora => 0,
      _ => math.pi / 4,
    };
  }

  Color _accentColorForPreset() {
    return presetId == KeyboardThemePresetCatalog.midnightAurora
        ? const Color(0xFFFFD84D)
        : accentColor;
  }

  void _drawCandy(Canvas canvas, Paint paint, Size size) {
    paint
      ..style = PaintingStyle.fill
      ..color = accentColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: size.width * .72,
          height: size.height * .46,
        ),
        const Radius.circular(2),
      ),
      paint,
    );
    paint.color = baseColor;
    canvas.drawCircle(Offset.zero, size.width * .17, paint);
    final left = Path()
      ..moveTo(-size.width * .36, 0)
      ..lineTo(-size.width * .67, -size.height * .25)
      ..lineTo(-size.width * .67, size.height * .25)
      ..close();
    final right = Path()
      ..moveTo(size.width * .36, 0)
      ..lineTo(size.width * .67, -size.height * .25)
      ..lineTo(size.width * .67, size.height * .25)
      ..close();
    canvas.drawPath(left, paint);
    canvas.drawPath(right, paint);
  }

  void _drawCloud(Canvas canvas, Paint paint, Size size) {
    paint
      ..style = PaintingStyle.fill
      ..color = baseColor;
    canvas.drawCircle(
      Offset(-size.width * .25, size.height * .08),
      size.width * .27,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * .08, -size.height * .08),
      size.width * .34,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * .42, size.height * .1),
      size.width * .25,
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * .08, size.height * .2),
          width: size.width * 1.12,
          height: size.height * .38,
        ),
        const Radius.circular(2),
      ),
      paint,
    );
  }

  void _drawLed(Canvas canvas, Paint paint, Size size) {
    paint
      ..style = PaintingStyle.fill
      ..color = baseColor;
    canvas.drawCircle(Offset.zero, size.width * .52, paint);
    paint.color = accentColor;
    canvas.drawCircle(Offset.zero, size.width * .28, paint);
  }

  void _drawDrop(Canvas canvas, Paint paint, Size size) {
    paint
      ..style = PaintingStyle.fill
      ..color = accentColor;
    final drop = Path()
      ..moveTo(0, -size.height * .5)
      ..cubicTo(
        size.width * .42,
        -size.height * .08,
        size.width * .33,
        size.height * .42,
        0,
        size.height * .42,
      )
      ..cubicTo(
        -size.width * .33,
        size.height * .42,
        -size.width * .42,
        -size.height * .08,
        0,
        -size.height * .5,
      )
      ..close();
    canvas.drawPath(drop, paint);
  }

  void _drawStar(Canvas canvas, Paint paint, Size size) {
    paint
      ..style = PaintingStyle.fill
      ..color = _accentColorForPreset();
    final star = Path()
      ..moveTo(0, -size.height * .5)
      ..lineTo(size.width * .15, -size.height * .15)
      ..lineTo(size.width * .5, 0)
      ..lineTo(size.width * .15, size.height * .15)
      ..lineTo(0, size.height * .5)
      ..lineTo(-size.width * .15, size.height * .15)
      ..lineTo(-size.width * .5, 0)
      ..lineTo(-size.width * .15, -size.height * .15)
      ..close();
    canvas.drawPath(star, paint);
  }

  @override
  bool shouldRepaint(covariant _PinnedBadgePainter oldDelegate) {
    return oldDelegate.presetId != presetId ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.accentColor != accentColor;
  }
}

double _relativeLuminance(Color color) {
  double channel(double value) {
    final normalized = value / 255;
    return normalized <= .03928
        ? normalized / 12.92
        : math.pow((normalized + .055) / 1.055, 2.4).toDouble();
  }

  return .2126 * channel((color.r * 255).roundToDouble()) +
      .7152 * channel((color.g * 255).roundToDouble()) +
      .0722 * channel((color.b * 255).roundToDouble());
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
