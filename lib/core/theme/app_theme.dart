import 'package:flutter/material.dart';

enum AppThemeMode {
  system(ThemeMode.system, 'System'),
  light(ThemeMode.light, 'Light'),
  dark(ThemeMode.dark, 'Dark');

  const AppThemeMode(this.materialMode, this.label);

  final ThemeMode materialMode;
  final String label;

  static AppThemeMode fromThemeMode(ThemeMode value) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.materialMode == value,
      orElse: () => AppThemeMode.system,
    );
  }
}

class AppColors {
  // VoiceFlowz brand primitives.
  static const primary = Color(0xFF6366F1);
  static const primaryDark = Color(0xFF4F46E5);
  static const secondary = Color(0xFF22D3EE);
  static const accent = secondary;

  // VoiceFlowz neutral primitives.
  static const dark = Color(0xFF0F172A);
  static const gray = Color(0xFF64748B);
  static const neutral = gray;
  static const slate = gray;
  static const lightGray = Color(0xFFF1F5F9);
  static const lightBlue = Color(0xFFE0E7FF);
  static const white = Color(0xFFFFFFFF);

  // Semantic surfaces and text.
  static const textPrimary = dark;
  static const textMuted = gray;
  static const surfaceBase = white;
  static const surfaceRaised = white;
  static const surfaceOverlay = white;
  static const surfaceSunken = Color(0xFFF8FAFC);
  static const surfaceSubtle = lightGray;
  static const surfaceTint = lightBlue;
  static const surfaceCard = surfaceRaised;
  static const surfaceBaseDark = dark;
  static const surfaceRaisedDark = Color(0xFF1E293B);
  static const surfaceOverlayDark = Color(0xFF334155);
  static const surfaceSunkenDark = Color(0xFF020617);
  static const textOnDark = white;
  static const textOnDarkMuted = Color(0xB3FFFFFF);
  static const codeText = Color(0xFFE2E8F0);
  static const badgeBg = Color(0xFFFEF3C7);
  static const badgeText = Color(0xFF92400E);

  // Borders and overlays.
  static const borderSubtle = Color(0x0D000000);
  static const borderLight = Color(0x14000000);
  static const borderDarkSubtle = Color(0x1AFFFFFF);
  static const overlayDark = Color(0x1AFFFFFF);
  static const overlayScrim = Color(0x660F172A);

  // Support colors.
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);
  static const danger = Color(0xFFDC2626);
  static const dangerLight = Color(0xFFF87171);
  static const info = accent;
}

class AppTypography {
  static const fontFamily = 'Inter';
  static const fontFallback = <String>[
    'Segoe UI',
    'Roboto',
    'Arial',
    'sans-serif',
  ];

  // VoiceFlowz scale: base 16px, ratio 1.25.
  static const xs = 12.0;
  static const sm = 14.0;
  static const base = 16.0;
  static const lg = 20.0;
  static const h3 = 24.0;
  static const h2 = 32.0;
  static const h1 = 40.0;

  static const leadingTight = 1.2;
  static const leadingSnug = 1.3;
  static const leadingNormal = 1.6;
  static const leadingRelaxed = 1.8;

  static const trackingWide = 0.04;
  static const trackingWider = 0.08;
}

class AppSpacing {
  static const x1 = 4.0;
  static const x2 = 8.0;
  static const x3 = 12.0;
  static const x4 = 16.0;
  static const x5 = 20.0;
  static const x6 = 24.0;
  static const x8 = 32.0;
  static const x10 = 40.0;
  static const x12 = 48.0;
  static const x16 = 64.0;
  static const x20 = 80.0;
  static const x24 = 96.0;
}

class AppInsets {
  static const none = EdgeInsets.zero;
  static const screen = EdgeInsets.all(AppSpacing.x5);
  static const card = EdgeInsets.all(AppSpacing.x4);
  static const compactCard = EdgeInsets.all(AppSpacing.x3);
  static const onboarding = EdgeInsets.fromLTRB(
    AppSpacing.x5,
    AppSpacing.x4 - AppSpacing.x1 / 2,
    AppSpacing.x5,
    AppSpacing.x4,
  );
  static const progress = EdgeInsets.only(top: AppSpacing.x3);
  static const message = EdgeInsets.only(top: AppSpacing.x2);
  static const stack = EdgeInsets.only(top: AppSpacing.x2);
  static const keyboardControls = EdgeInsets.symmetric(
    horizontal: AppSpacing.x4,
  );
  static const keyboardPrivacy = EdgeInsets.fromLTRB(
    AppSpacing.x4,
    0,
    AppSpacing.x4,
    AppSpacing.x3,
  );
  static const overlayControls = EdgeInsets.fromLTRB(
    AppSpacing.x4,
    0,
    AppSpacing.x4,
    AppSpacing.x3,
  );
}

class AppGaps {
  static const x1 = SizedBox(height: AppSpacing.x1);
  static const x2 = SizedBox(height: AppSpacing.x2);
  static const x3 = SizedBox(height: AppSpacing.x3);
  static const x4 = SizedBox(height: AppSpacing.x4);
  static const x5 = SizedBox(height: AppSpacing.x5);
  static const x6 = SizedBox(height: AppSpacing.x6);

  static const horizontalX2 = SizedBox(width: AppSpacing.x2);
  static const horizontalX3 = SizedBox(width: AppSpacing.x3);
}

class AppIconMetrics {
  static const sm = AppSpacing.x5;
  static const progressStroke = AppSpacing.x1 / 2;
  static const stepAvatarRadius = AppSpacing.x3;
  static const minTarget = AppSpacing.x10 + AppSpacing.x1;
  static const listActionSpacing = AppSpacing.x1;
}

class AppLayoutMetrics {
  static const onboardingOverlayMaxWidth = 520.0;
  static const onboardingOverlayMaxHeight =
      AppSpacing.x24 + AppSpacing.x24 + AppSpacing.x20 + AppSpacing.x2;
}

class AppElevation {
  static const overlay = 8.0;
}

class AppRadii {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const x2l = 28.0;
  static const pill = 9999.0;
}

class AppShadows {
  static const sm = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const card = [
    BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, 4)),
  ];

  static const cardHover = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 30, offset: Offset(0, 8)),
  ];

  static const cardLarge = [
    BoxShadow(color: Color(0x26000000), blurRadius: 40, offset: Offset(0, 12)),
  ];

  static const primary = [
    BoxShadow(color: Color(0x4D6366F1), blurRadius: 15, offset: Offset(0, 4)),
  ];
}

class AppMotion {
  static const instant = Duration(milliseconds: 120);
  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 200);
  static const slow = Duration(milliseconds: 300);
  static const standardCurve = Curves.ease;
  static const outCurve = Curves.easeOut;
  static const springCurve = Cubic(0.34, 1.56, 0.64, 1);
}

class AppTheme {
  static ThemeData get light => _build(
    ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.dark,
      tertiary: AppColors.accent,
      onTertiary: AppColors.dark,
      error: AppColors.danger,
      surface: AppColors.surfaceBase,
      onSurface: AppColors.textPrimary,
      surfaceContainerLowest: AppColors.surfaceSunken,
      surfaceContainerLow: AppColors.surfaceRaised,
      surfaceContainer: AppColors.surfaceSubtle,
      surfaceContainerHighest: AppColors.surfaceSubtle,
      outline: AppColors.borderLight,
      outlineVariant: AppColors.borderSubtle,
    ),
  );

  static ThemeData get dark => _build(
    ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      error: AppColors.dangerLight,
      surface: AppColors.surfaceBaseDark,
      onSurface: AppColors.textOnDark,
      surfaceContainerLowest: AppColors.surfaceSunkenDark,
      surfaceContainerLow: Color(0xFF0B1120),
      surfaceContainer: AppColors.surfaceRaisedDark,
      surfaceContainerHighest: AppColors.surfaceOverlayDark,
      outline: AppColors.borderDarkSubtle,
      outlineVariant: AppColors.borderDarkSubtle,
    ),
  );

  static ThemeData _build(ColorScheme colorScheme) {
    final textTheme = _textTheme(colorScheme);
    final isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      scaffoldBackgroundColor: colorScheme.surface,
      fontFamily: AppTypography.fontFamily,
      fontFamilyFallback: AppTypography.fontFallback,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.x2),
        elevation: isDark ? 0 : 1,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0 : 0.08),
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppIconMetrics.minTarget),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppIconMetrics.minTarget),
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            AppIconMetrics.minTarget,
            AppIconMetrics.minTarget,
          ),
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(
            AppIconMetrics.minTarget,
            AppIconMetrics.minTarget,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: colorScheme.primaryContainer,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return null;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(
            textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
          ),
        ),
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme colorScheme) {
    final base = Typography.material2021().black.apply(
      fontFamily: AppTypography.fontFamily,
      fontFamilyFallback: AppTypography.fontFallback,
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return base.copyWith(
      displayLarge: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontFamilyFallback: AppTypography.fontFallback,
        fontSize: AppTypography.h1,
        height: AppTypography.leadingTight,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      headlineLarge: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontFamilyFallback: AppTypography.fontFallback,
        fontSize: AppTypography.h2,
        height: AppTypography.leadingTight,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontFamilyFallback: AppTypography.fontFallback,
        fontSize: AppTypography.h3,
        height: AppTypography.leadingSnug,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontFamilyFallback: AppTypography.fontFallback,
        fontSize: AppTypography.lg,
        height: AppTypography.leadingSnug,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontFamilyFallback: AppTypography.fontFallback,
        fontSize: AppTypography.base,
        height: AppTypography.leadingNormal,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontFamilyFallback: AppTypography.fontFallback,
        fontSize: AppTypography.base,
        height: AppTypography.leadingNormal,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontFamilyFallback: AppTypography.fontFallback,
        fontSize: AppTypography.sm,
        height: AppTypography.leadingNormal,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontFamilyFallback: AppTypography.fontFallback,
        fontSize: AppTypography.xs,
        height: AppTypography.leadingNormal,
        letterSpacing: 0,
        color: colorScheme.onSurface.withValues(alpha: 0.72),
      ),
      labelLarge: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontFamilyFallback: AppTypography.fontFallback,
        fontSize: AppTypography.sm,
        height: AppTypography.leadingSnug,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontFamilyFallback: AppTypography.fontFallback,
        fontSize: AppTypography.xs,
        height: AppTypography.leadingSnug,
        fontWeight: FontWeight.w700,
        letterSpacing: AppTypography.trackingWide,
        color: colorScheme.onSurface,
      ),
    );
  }
}
