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
  // Brand primitives exposés pour WinFlowz.
  // Mapping: seed tokens historiques (TubeFlow) -> sémantique app WinFlowz.
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
  static const base = 14.0;
  static const lg = 17.0;
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
  static const screen = EdgeInsets.symmetric(
    horizontal: AppSpacing.x2,
    vertical: AppSpacing.x3,
  );
  static const card = EdgeInsets.all(AppSpacing.x2 + AppSpacing.x1 / 4);
  static const compactCard = EdgeInsets.all(AppSpacing.x2);
  static const button = EdgeInsets.symmetric(
    horizontal: AppSpacing.x3,
    vertical: AppSpacing.x1,
  );
  static const textButton = EdgeInsets.symmetric(
    horizontal: AppSpacing.x2,
    vertical: AppSpacing.x1,
  );
  static const input = EdgeInsets.symmetric(
    horizontal: AppSpacing.x2,
    vertical: AppSpacing.x1 / 2,
  );
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

class AppSectionMetrics {
  static const double sectionGap = AppSpacing.x1;
  static const double sectionRunSpacing = sectionGap;
  static const double sectionColumnGap = AppSpacing.x2;
  static const double headerContentGap = AppSpacing.x1;
  static const EdgeInsets cardMargin = EdgeInsets.zero;
  static const EdgeInsets collapsibleSectionMargin = EdgeInsets.zero;
  static const EdgeInsets collapsibleTilePadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.x2,
  );
  static const EdgeInsets collapsibleChildrenPadding = EdgeInsets.fromLTRB(
    AppSpacing.x2,
    0,
    AppSpacing.x2,
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
  static const minTarget = 48.0;
  static const listActionSpacing = AppSpacing.x1;
}

class AppButtonMetrics {
  static const minHeight = 48.0;
  static const compactMinHeight = 40.0;
}

class AppNavigationMetrics {
  static const bottomBarHeight = 58.0;
  static const bottomBarShadowBlur = 14.0;
  static const bottomBarShadowOffset = Offset(0, 4);
  static const bottomBarLightAlpha = 0.98;
  static const bottomBarDarkAlpha = 0.94;
  static const bottomBarLightShadowAlpha = 0.06;
  static const bottomBarDarkShadowAlpha = 0.2;
  static const bottomIndicatorLightAlpha = 0.1;
  static const bottomIndicatorDarkAlpha = 0.18;
  static const bottomIconSize = 23.0;
  static const bottomSelectedIconSize = 24.0;
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
  static const md = 10.0;
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
      primary: const Color(0xFF2FAE75),
      onPrimary: AppColors.white,
      primaryContainer: const Color(0xFFE8F3EC),
      onPrimaryContainer: const Color(0xFF1C3929),
      secondary: const Color(0xFF4F5B55),
      onSecondary: AppColors.white,
      secondaryContainer: const Color(0xFFE7E4DA),
      onSecondaryContainer: const Color(0xFF2A342E),
      tertiary: TubeflowSiteThemeTokens.siteRing,
      onTertiary: AppColors.white,
      error: AppColors.danger,
      surface: const Color(0xFFF2F1EC),
      onSurface: const Color(0xFF20211F),
      surfaceContainerLowest: const Color(0xFFE9E5D8),
      surfaceContainerLow: const Color(0xFFF8F7F3),
      surfaceContainer: const Color(0xFFFFFFFF),
      surfaceContainerHighest: const Color(0xFFD9D4CA),
      outline: const Color(0xFFC6C0B2),
      outlineVariant: const Color(0xFFDDD6C8),
    ),
  );

  static ThemeData get dark => _build(
    ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF36B384),
      onPrimary: const Color(0xFF09130F),
      primaryContainer: const Color(0xFF24312A),
      onPrimaryContainer: const Color(0xFFD4F7E5),
      secondary: const Color(0xFF5B6A60),
      onSecondary: const Color(0xFFE7F3EB),
      secondaryContainer: const Color(0xFF1F2924),
      onSecondaryContainer: const Color(0xFFDBF4E3),
      tertiary: TubeflowSiteThemeTokens.siteRing,
      onTertiary: const Color(0xFFF4F4F2),
      error: AppColors.dangerLight,
      surface: const Color(0xFF121815),
      onSurface: AppColors.textOnDark,
      surfaceContainerLowest: const Color(0xFF0A0F0C),
      surfaceContainerLow: const Color(0xFF151B18),
      surfaceContainer: const Color(0xFF1E2724),
      surfaceContainerHighest: const Color(0xFF2A3330),
      outline: const Color(0xFF52635A),
      outlineVariant: const Color(0xFF3A4840),
    ),
  );

  static ThemeData _build(ColorScheme colorScheme) {
    final textTheme = _textTheme(colorScheme);
    final isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      visualDensity: VisualDensity.compact,
      scaffoldBackgroundColor: colorScheme.surface,
      fontFamily: AppTypography.fontFamily,
      fontFamilyFallback: AppTypography.fontFallback,
      textTheme: textTheme,
      canvasColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: TubeflowSiteThemeTokens.appBarElevation,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.98),
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: AppColors.transparent,
        shape: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: AppFontWeights.xBold,
        ),
      ),
      cardTheme: CardThemeData(
        margin: AppSectionMetrics.cardMargin,
        elevation: 0,
        shadowColor: AppColors.black.withValues(alpha: isDark ? 0.22 : 0.12),
        color: isDark
            ? colorScheme.surfaceContainer
            : colorScheme.surfaceContainerLow,
        surfaceTintColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: colorScheme.outline, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        constraints: const BoxConstraints(minHeight: 40),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.25),
        ),
        filled: true,
        fillColor: isDark
            ? colorScheme.surfaceContainerLowest
            : colorScheme.surfaceContainerLow,
        contentPadding: AppInsets.input,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppButtonMetrics.minHeight),
          padding: AppInsets.button,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shadowColor: AppColors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle: const TextStyle(fontWeight: AppFontWeights.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppButtonMetrics.minHeight),
          padding: AppInsets.button,
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
          minimumSize: const Size(0, AppButtonMetrics.minHeight),
          padding: AppInsets.textButton,
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
        height: AppNavigationMetrics.bottomBarHeight,
        elevation: 0,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.16),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        backgroundColor: colorScheme.surfaceContainerLow.withValues(
          alpha: 0.94,
        ),
        surfaceTintColor: AppColors.transparent,
        shadowColor: AppColors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            size: selected
                ? AppNavigationMetrics.bottomSelectedIconSize
                : AppNavigationMetrics.bottomIconSize,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            fontWeight: selected ? AppFontWeights.bold : AppFontWeights.medium,
          );
        }),
        overlayColor: WidgetStateProperty.all(
          colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.75),
        thickness: 1,
        space: 0,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all(
            colorScheme.surfaceContainer,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
              side: BorderSide(color: colorScheme.outline),
            ),
          ),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyMedium,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(
            colorScheme.surfaceContainer,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
          ),
          side: WidgetStateProperty.all(BorderSide(color: colorScheme.outline)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: AppInsets.input,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
        ),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: colorScheme.outline),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: colorScheme.outline),
        ),
        iconColor: colorScheme.primary,
        textColor: colorScheme.onSurface,
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
            return isDark
                ? colorScheme.primary
                : colorScheme.onPrimaryContainer;
          }
          return isDark ? colorScheme.onSurface : colorScheme.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return isDark
                ? colorScheme.primary.withValues(alpha: 0.45)
                : colorScheme.primaryContainer;
          }
          return colorScheme.onSurface.withValues(alpha: isDark ? 0.28 : 0.24);
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return isDark
                ? colorScheme.primary.withValues(alpha: 0.7)
                : colorScheme.onPrimaryContainer.withValues(alpha: 0.45);
          }
          return colorScheme.outline;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
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
        dense: true,
        iconColor: colorScheme.onSurface.withValues(alpha: 0.72),
        textColor: colorScheme.onSurface,
        subtitleTextStyle: textTheme.bodySmall,
        minVerticalPadding: 0,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x2,
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
