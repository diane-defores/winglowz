import 'package:flutter_test/flutter_test.dart';
import 'package:winflowz_app/features/keyboard/domain/keyboard_models.dart';
import 'package:winflowz_app/features/keyboard/domain/keyboard_theme_validation.dart';

void main() {
  test('ships the full v1 preset catalog', () {
    expect(KeyboardThemePresetCatalog.presets, hasLength(10));
    expect(
      KeyboardThemePresetCatalog.presets.map((preset) => preset.name),
      containsAll([
        'Glass Mint',
        'Midnight Aurora',
        'Paper Ink',
        'Pixel Candy',
        'Minimal Contrast',
      ]),
    );
  });

  test('round-trips advanced theme fields', () {
    final config = KeyboardThemeConfig.defaults().copyWith(
      presetId: KeyboardThemePresetCatalog.midnightAurora,
      useGradient: true,
      gradientStyle: KeyboardThemeGradientStyle.radial,
      borderWidth: 1.5,
      keyRadius: 14,
      shadowBlur: 9,
      shadowOffsetY: 2,
      effectEasing: KeyboardThemeEffectEasing.spring,
    );

    final parsed = KeyboardThemeConfig.fromMap(config.toMap());

    expect(parsed.gradientStyle, KeyboardThemeGradientStyle.radial);
    expect(parsed.borderWidth, 1.5);
    expect(parsed.keyRadius, 14);
    expect(parsed.shadowBlur, 9);
    expect(parsed.effectEasing, KeyboardThemeEffectEasing.spring);
  });

  test('accepts default theme contrast', () {
    final result = KeyboardThemeValidator.validate(
      KeyboardThemeConfig.defaults(),
    );

    expect(result.canSave, isTrue);
    expect(result.errors, isEmpty);
  });

  test('blocks unreadable key labels', () {
    final result = KeyboardThemeValidator.validate(
      KeyboardThemeConfig.defaults().copyWith(
        presetId: KeyboardThemePresetCatalog.winflowzLight,
        keyColor: 0xFF111111,
        specialKeyColor: 0xFF111111,
        pressedKeyColor: 0xFF111111,
        textColor: 0xFF111111,
      ),
    );

    expect(result.canSave, isFalse);
    expect(result.errors.join('\n'), contains('Key label contrast'));
  });

  test('blocks image background without imported image', () {
    final result = KeyboardThemeValidator.validate(
      KeyboardThemeConfig.defaults().copyWith(useImage: true),
    );

    expect(result.canSave, isFalse);
    expect(result.errors.join('\n'), contains('imported local image'));
  });
}
