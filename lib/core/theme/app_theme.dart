import 'package:flutter/material.dart';
import 'package:winflowz_app/core/theme/tubeflow_site_theme_tokens.dart';

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
  // Brand primitives.
  static const primary = TubeflowSiteThemeTokens.brandPrimary;
  static const primaryDark = TubeflowSiteThemeTokens.brandPrimaryDark;
  static const secondary = TubeflowSiteThemeTokens.brandSecondary;
  static const accent = secondary;

  // Neutral primitives (site theme base + app continuity).
  static const dark = TubeflowSiteThemeTokens.appLightText;
  static const gray = TubeflowSiteThemeTokens.siteMutedForeground;
  static const neutral = gray;
  static const slate = gray;
  static const lightGray = TubeflowSiteThemeTokens.lightGray;
  static const lightBlue = TubeflowSiteThemeTokens.brandSecondary;
  static const white = TubeflowSiteThemeTokens.white;
  static const black = TubeflowSiteThemeTokens.black;
  static const transparent = Colors.transparent;

  // Semantic surfaces and text.
  static const textPrimary = dark;
  static const siteBackground = TubeflowSiteThemeTokens.siteBackground;
  static const siteForeground = TubeflowSiteThemeTokens.siteForeground;
  static const textMuted = gray;
  static const surfaceBase = TubeflowSiteThemeTokens.appLightBackground;
  static const surfaceRaised = TubeflowSiteThemeTokens.appLightCard;
  static const surfaceOverlay = TubeflowSiteThemeTokens.appLightSurface;
  static const surfaceSunken = TubeflowSiteThemeTokens.surfaceSunken;
  static const surfaceSubtle = lightGray;
  static const surfaceTint = TubeflowSiteThemeTokens.appLightMuted;
  static const surfaceCard = surfaceRaised;
  static const surfaceBaseDark = siteBackground;
  static const surfaceRaisedDark = TubeflowSiteThemeTokens.surfaceRaisedDark;
  static const surfaceOverlayDark = TubeflowSiteThemeTokens.surfaceOverlayDark;
  static const surfaceSunkenDark = TubeflowSiteThemeTokens.surfaceSunkenDark;
  static const overlayDark = TubeflowSiteThemeTokens.siteWhiteSubtle;
  static const textOnDark = siteForeground;
  static const textOnDarkMuted = TubeflowSiteThemeTokens.siteTextOnDarkMuted;
  static const codeText = TubeflowSiteThemeTokens.siteCodeText;
  static const badgeBg = TubeflowSiteThemeTokens.siteBadgeBg;
  static const badgeText = TubeflowSiteThemeTokens.siteBadgeText;

  // Borders and overlays.
  static const borderSubtle = TubeflowSiteThemeTokens.appLightBorderSubtle;
  static const borderLight = TubeflowSiteThemeTokens.appLightBorder;
  static const borderDarkSubtle = TubeflowSiteThemeTokens.siteBorderDarkSubtle;
  static const overlayScrim = TubeflowSiteThemeTokens.siteScrim;

  // Support colors.
  static const success = TubeflowSiteThemeTokens.brandSuccess;
  static const warning = TubeflowSiteThemeTokens.brandWarning;
  static const danger = TubeflowSiteThemeTokens.brandDanger;
  static const dangerLight = TubeflowSiteThemeTokens.brandDangerLight;
  static const info = accent;

  // Keyboard preview surface-specific tokens (copied from pages de debug).
  static const keyboardPrivateFrame =
      TubeflowSiteThemeTokens.keyboardPrivateFrame;
  static const keyboardDefaultFrame =
      TubeflowSiteThemeTokens.keyboardDefaultFrame;
  static const keyboardStatusText = TubeflowSiteThemeTokens.keyboardStatusText;
  static const keyboardKeyActive = TubeflowSiteThemeTokens.keyboardKeyActive;
  static const keyboardKeySpecial = TubeflowSiteThemeTokens.keyboardKeySpecial;
  static const keyboardKeyDisabled =
      TubeflowSiteThemeTokens.keyboardKeyDisabled;
  static const keyboardKeyForeground =
      TubeflowSiteThemeTokens.keyboardKeyForeground;
  static const keyboardCornerLabel =
      TubeflowSiteThemeTokens.keyboardCornerLabel;
}

class AppTypography {
  static const fontFamily = TubeflowSiteThemeTokens.fontSans;
  static const fontFallback = TubeflowSiteThemeTokens.fontFallback;

  // WinFlowz scale (cohérente avec le thème site, bornée à un set court).
  static const xs = TubeflowSiteThemeTokens.typographyXs;
  static const sm = TubeflowSiteThemeTokens.typographySm;
  static const base = 15.0;
  static const lg = 18.0;
  static const h3 = 22.0;
  static const h2 = 28.0;
  static const h1 = 34.0;

  static const leadingTight = TubeflowSiteThemeTokens.lineHeightTight;
  static const leadingSnug = TubeflowSiteThemeTokens.lineHeightSnug;
  static const leadingNormal = TubeflowSiteThemeTokens.lineHeightNormal;
  static const leadingRelaxed = 1.8;

  static const trackingWide = TubeflowSiteThemeTokens.trackingWide;
  static const trackingWider = TubeflowSiteThemeTokens.trackingWider;
}

class AppFontWeights {
  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semiBold = FontWeight.w600;
  static const bold = FontWeight.w700;
  static const xBold = FontWeight.w800;
  static const heavy = FontWeight.w900;
}

class AppSpacing {
  static const x1 = TubeflowSiteThemeTokens.spacing1;
  static const x2 = TubeflowSiteThemeTokens.spacing2;
  static const x3 = TubeflowSiteThemeTokens.spacing3;
  static const x4 = TubeflowSiteThemeTokens.spacing4;
  static const x5 = TubeflowSiteThemeTokens.spacing5;
  static const x6 = TubeflowSiteThemeTokens.spacing6;
  static const x8 = TubeflowSiteThemeTokens.spacing8;
  static const x10 = TubeflowSiteThemeTokens.spacing10;
  static const x12 = TubeflowSiteThemeTokens.spacing12;
  static const x16 = TubeflowSiteThemeTokens.spacing16;
  static const x20 = TubeflowSiteThemeTokens.spacing20;
  static const x24 = TubeflowSiteThemeTokens.spacing24;
}

class AppInsets {
  static const none = EdgeInsets.zero;
  static const screen = EdgeInsets.all(AppSpacing.x4);
  static const card = EdgeInsets.all(AppSpacing.x3);
  static const compactCard = EdgeInsets.all(AppSpacing.x2);
  static const onboarding = EdgeInsets.fromLTRB(
    AppSpacing.x4,
    AppSpacing.x3,
    AppSpacing.x4,
    AppSpacing.x3,
  );
  static const progress = EdgeInsets.only(top: AppSpacing.x3);
  static const message = EdgeInsets.only(top: AppSpacing.x2);
  static const stack = EdgeInsets.only(top: AppSpacing.x2);
  static const keyboardControls = EdgeInsets.symmetric(
    horizontal: AppSpacing.x3,
  );
  static const keyboardPrivacy = EdgeInsets.fromLTRB(
    AppSpacing.x3,
    0,
    AppSpacing.x3,
    AppSpacing.x2,
  );
  static const overlayControls = EdgeInsets.fromLTRB(
    AppSpacing.x3,
    0,
    AppSpacing.x3,
    AppSpacing.x2,
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
  static const sm = AppSpacing.x4;
  static const progressStroke = AppSpacing.x1 / 2;
  static const stepAvatarRadius = AppSpacing.x3;
  static const minTarget = 44.0;
  static const listActionSpacing = AppSpacing.x1;
}

class AppLayoutMetrics {
  static const onboardingOverlayMaxWidth = 520.0;
  static const settingsTwoColumnBreakpoint = 1180.0;
}

class AppBreakpoints {
  static const double navigationRail =
      TubeflowSiteThemeTokens.navRailBreakpoint;
  static const double navigationRailExtended =
      TubeflowSiteThemeTokens.navRailExtendedBreakpoint;
}

class AppKeyboardPreview {
  static const double maxWidth =
      TubeflowSiteThemeTokens.keyboardPreviewFrameMaxWidth;
  static const double dropdownWidth = 188.0;
  static const double statusHeight =
      TubeflowSiteThemeTokens.keyboardPreviewStatusHeight;
  static const double rowHeightTiny =
      TubeflowSiteThemeTokens.keyboardPreviewRowHeightMini;
  static const double rowHeightMini = rowHeightTiny;
  static const double rowHeightCompact =
      TubeflowSiteThemeTokens.keyboardPreviewRowHeightCompact;
  static const double rowHeightRegular =
      TubeflowSiteThemeTokens.keyboardPreviewRowHeight;
  static const double rowHeightControl =
      TubeflowSiteThemeTokens.keyboardPreviewControlHeight;
  static const double keyBorderWidth =
      TubeflowSiteThemeTokens.keyboardKeyBorderWidth;
  static const double keyDebugBorderWidth =
      TubeflowSiteThemeTokens.keyboardKeyDebugBorderWidth;
  static const double cornerLabelPadding =
      TubeflowSiteThemeTokens.keyboardCornerLabelPadding;
  static const double keyWeightScale =
      TubeflowSiteThemeTokens.keyboardWeightScale;
}

class AppSliders {
  static const double overlayBubbleSizeMin =
      TubeflowSiteThemeTokens.overlayBubbleSizeMin;
  static const double overlayBubbleSizeMax =
      TubeflowSiteThemeTokens.overlayBubbleSizeMax;
  static const int overlaySizeDivisions =
      TubeflowSiteThemeTokens.overlaySizeDivisions;
  static const double overlayBubbleOpacityMin =
      TubeflowSiteThemeTokens.overlayBubbleOpacityMin;
  static const double overlayBubbleOpacityMax =
      TubeflowSiteThemeTokens.overlayBubbleOpacityMax;
  static const int overlayOpacityDivisions =
      TubeflowSiteThemeTokens.overlayOpacityDivisions;
  static const double overlayDefaultSize =
      TubeflowSiteThemeTokens.overlayBubbleDefaultSize;
  static const double overlayDefaultOpacity =
      TubeflowSiteThemeTokens.overlayBubbleDefaultOpacity;
}

class AppElevation {
  static const overlay = TubeflowSiteThemeTokens.elevationOverlay;
  static const cardLight = TubeflowSiteThemeTokens.cardElevationLight;
  static const cardDark = TubeflowSiteThemeTokens.cardElevationDark;
}

class AppGradients {
  static LinearGradient shell(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          TubeflowSiteThemeTokens.siteBackground,
          Color(0xFF1F1F1F),
          TubeflowSiteThemeTokens.siteCard,
        ],
        stops: [0, 0.48, 1],
      );
    }

    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        TubeflowSiteThemeTokens.appLightBackground,
        TubeflowSiteThemeTokens.appLightSurface,
        Color(0xFFEDEBE3),
      ],
      stops: [0, 0.52, 1],
    );
  }
}

class AppRadii {
  static const sm = TubeflowSiteThemeTokens.siteRadiusSm;
  static const md = TubeflowSiteThemeTokens.siteRadiusMd;
  static const lg = TubeflowSiteThemeTokens.siteRadiusLg;
  static const xl = TubeflowSiteThemeTokens.siteRadiusXl;
  static const x2l = TubeflowSiteThemeTokens.siteRadius2xl;
  static const pill = 9999.0;
}

class AppShadows {
  static const sm = [
    BoxShadow(
      color: TubeflowSiteThemeTokens.shadowSoft,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const card = [
    BoxShadow(
      color: TubeflowSiteThemeTokens.shadowCard,
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  static const cardHover = [
    BoxShadow(
      color: TubeflowSiteThemeTokens.shadowCardHover,
      blurRadius: 30,
      offset: Offset(0, 8),
    ),
  ];

  static const cardLarge = [
    BoxShadow(
      color: TubeflowSiteThemeTokens.shadowCardLarge,
      blurRadius: 40,
      offset: Offset(0, 12),
    ),
  ];

  static const primary = [
    BoxShadow(
      color: TubeflowSiteThemeTokens.shadowPrimary,
      blurRadius: 15,
      offset: Offset(0, 4),
    ),
  ];
}

class AppMotion {
  static const instant = TubeflowSiteThemeTokens.motionInstant;
  static const fast = TubeflowSiteThemeTokens.motionFast;
  static const base = TubeflowSiteThemeTokens.motionBase;
  static const slow = TubeflowSiteThemeTokens.motionSlow;
  static const standardCurve = TubeflowSiteThemeTokens.motionStandard;
  static const outCurve = Curves.easeOut;
  static const springCurve = TubeflowSiteThemeTokens.motionSpring;
}

class AppTheme {
  static ThemeData get light => _build(
    ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: TubeflowSiteThemeTokens.appActionOnLight,
      primaryContainer: TubeflowSiteThemeTokens.appLightMuted,
      onPrimaryContainer: AppColors.dark,
      secondary: TubeflowSiteThemeTokens.siteSecondary,
      onSecondary: AppColors.white,
      secondaryContainer: TubeflowSiteThemeTokens.appLightMuted,
      onSecondaryContainer: AppColors.dark,
      tertiary: TubeflowSiteThemeTokens.siteRing,
      onTertiary: AppColors.white,
      error: AppColors.danger,
      surface: AppColors.surfaceBase,
      onSurface: AppColors.textPrimary,
      surfaceContainerLowest: AppColors.surfaceSunken,
      surfaceContainerLow: AppColors.surfaceOverlay,
      surfaceContainer: AppColors.surfaceRaised,
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
      primary: AppColors.primaryDark,
      onPrimary: TubeflowSiteThemeTokens.appActionOnDark,
      primaryContainer: TubeflowSiteThemeTokens.siteSecondary,
      onPrimaryContainer: AppColors.textOnDark,
      secondary: TubeflowSiteThemeTokens.siteSecondary,
      onSecondary: AppColors.textOnDark,
      secondaryContainer: TubeflowSiteThemeTokens.siteMuted,
      onSecondaryContainer: AppColors.textOnDark,
      tertiary: TubeflowSiteThemeTokens.siteRing,
      onTertiary: AppColors.textOnDark,
      error: AppColors.dangerLight,
      surface: AppColors.surfaceBaseDark,
      onSurface: AppColors.textOnDark,
      surfaceContainerLowest: AppColors.surfaceSunkenDark,
      surfaceContainerLow: TubeflowSiteThemeTokens.surfaceSunkenDark,
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
      canvasColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: TubeflowSiteThemeTokens.appBarElevation,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.92),
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: AppColors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: AppFontWeights.bold,
        ),
      ),
      cardTheme: CardThemeData(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.x2),
        elevation: isDark ? AppElevation.cardDark : AppElevation.cardLight,
        shadowColor: AppColors.black.withValues(
          alpha: isDark
              ? TubeflowSiteThemeTokens.darkCardShadowAlpha
              : TubeflowSiteThemeTokens.cardShadowAlpha,
        ),
        color: isDark
            ? colorScheme.surfaceContainer
            : colorScheme.surfaceContainerLow,
        surfaceTintColor: AppColors.transparent,
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
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: TubeflowSiteThemeTokens.textFieldBorderWidth,
          ),
        ),
        filled: true,
        fillColor: isDark
            ? TubeflowSiteThemeTokens.siteInput.withValues(
                alpha: TubeflowSiteThemeTokens.textFieldFillAlpha,
              )
            : TubeflowSiteThemeTokens.appLightInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x1 + 2,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppIconMetrics.minTarget),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: isDark ? 0 : 2,
          shadowColor: AppColors.black.withValues(alpha: 0.24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle: const TextStyle(fontWeight: AppFontWeights.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppIconMetrics.minTarget),
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          backgroundColor: colorScheme.surfaceContainer.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle: const TextStyle(fontWeight: AppFontWeights.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, AppIconMetrics.minTarget),
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
        indicatorColor: colorScheme.primary.withValues(
          alpha: isDark ? 0.14 : 0.1,
        ),
        backgroundColor: isDark
            ? colorScheme.surfaceContainerLow
            : colorScheme.surfaceContainerLow,
        surfaceTintColor: AppColors.transparent,
        shadowColor: AppColors.black.withValues(alpha: 0.28),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: AppFontWeights.semiBold),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.82),
        indicatorColor: colorScheme.primary.withValues(
          alpha: isDark ? 0.14 : 0.1,
        ),
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.primary,
        ),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurface.withValues(alpha: 0.58),
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.58),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return isDark ? colorScheme.onSurface : colorScheme.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withValues(alpha: isDark ? 0.45 : 0.4);
          }
          return colorScheme.onSurface.withValues(alpha: isDark ? 0.28 : 0.24);
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withValues(alpha: isDark ? 0.7 : 0.5);
          }
          return colorScheme.outline;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: TubeflowSiteThemeTokens.dividerThickness,
        space: TubeflowSiteThemeTokens.dividerThickness,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: textTheme.labelMedium,
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurface.withValues(alpha: 0.72),
        textColor: colorScheme.onSurface,
        subtitleTextStyle: textTheme.bodySmall,
        minVerticalPadding: 2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: 0,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        surfaceTintColor: AppColors.transparent,
        elevation: AppElevation.overlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? TubeflowSiteThemeTokens.siteForeground
            : TubeflowSiteThemeTokens.siteBackground,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark
              ? TubeflowSiteThemeTokens.sitePrimaryForeground
              : TubeflowSiteThemeTokens.siteForeground,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStateProperty.all(
            textTheme.labelLarge?.copyWith(fontWeight: AppFontWeights.bold),
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
        fontWeight: AppFontWeights.heavy,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      headlineLarge: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontFamilyFallback: AppTypography.fontFallback,
        fontSize: AppTypography.h2,
        height: AppTypography.leadingTight,
        fontWeight: AppFontWeights.xBold,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontFamilyFallback: AppTypography.fontFallback,
        fontSize: AppTypography.h3,
        height: AppTypography.leadingSnug,
        fontWeight: AppFontWeights.bold,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontFamilyFallback: AppTypography.fontFallback,
        fontSize: AppTypography.lg,
        height: AppTypography.leadingSnug,
        fontWeight: AppFontWeights.bold,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontFamilyFallback: AppTypography.fontFallback,
        fontSize: AppTypography.base,
        height: AppTypography.leadingNormal,
        fontWeight: AppFontWeights.bold,
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
        color: colorScheme.onSurface.withValues(
          alpha: TubeflowSiteThemeTokens.surfaceSubtleAlpha,
        ),
      ),
      labelLarge: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontFamilyFallback: AppTypography.fontFallback,
        fontSize: AppTypography.sm,
        height: AppTypography.leadingSnug,
        fontWeight: AppFontWeights.bold,
        letterSpacing: 0,
        color: colorScheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontFamilyFallback: AppTypography.fontFallback,
        fontSize: AppTypography.xs,
        height: AppTypography.leadingSnug,
        fontWeight: AppFontWeights.bold,
        letterSpacing: AppTypography.trackingWide,
        color: colorScheme.onSurface,
      ),
    );
  }
}
