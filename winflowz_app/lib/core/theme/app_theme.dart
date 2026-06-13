import 'package:flutter/material.dart';
import 'package:winflowz_app/core/theme/winflowz_theme_tokens.dart';

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
  static const primary = WinFlowzThemeTokens.brandPrimary;
  static const primaryDark = WinFlowzThemeTokens.brandPrimaryDark;
  static const secondary = WinFlowzThemeTokens.brandSecondary;
  static const accent = secondary;

  // Neutral primitives (site theme base + app continuity).
  static const dark = WinFlowzThemeTokens.appLightText;
  static const gray = WinFlowzThemeTokens.siteMutedForeground;
  static const neutral = gray;
  static const slate = gray;
  static const lightGray = WinFlowzThemeTokens.lightGray;
  static const lightBlue = WinFlowzThemeTokens.brandSecondary;
  static const white = WinFlowzThemeTokens.white;
  static const black = WinFlowzThemeTokens.black;
  static const transparent = Colors.transparent;

  // Semantic surfaces and text.
  static const textPrimary = dark;
  static const siteBackground = WinFlowzThemeTokens.siteBackground;
  static const siteForeground = WinFlowzThemeTokens.siteForeground;
  static const textMuted = gray;
  static const surfaceBase = WinFlowzThemeTokens.appLightBackground;
  static const surfaceRaised = WinFlowzThemeTokens.appLightCard;
  static const surfaceOverlay = WinFlowzThemeTokens.appLightSurface;
  static const surfaceSunken = WinFlowzThemeTokens.surfaceSunken;
  static const surfaceSubtle = lightGray;
  static const surfaceTint = WinFlowzThemeTokens.appLightMuted;
  static const surfaceCard = surfaceRaised;
  static const surfaceBaseDark = siteBackground;
  static const surfaceRaisedDark = WinFlowzThemeTokens.surfaceRaisedDark;
  static const surfaceOverlayDark = WinFlowzThemeTokens.surfaceOverlayDark;
  static const surfaceSunkenDark = WinFlowzThemeTokens.surfaceSunkenDark;
  static const overlayDark = WinFlowzThemeTokens.siteWhiteSubtle;
  static const textOnDark = siteForeground;
  static const textOnDarkMuted = WinFlowzThemeTokens.siteTextOnDarkMuted;
  static const codeText = WinFlowzThemeTokens.siteCodeText;
  static const badgeBg = WinFlowzThemeTokens.siteBadgeBg;
  static const badgeText = WinFlowzThemeTokens.siteBadgeText;

  // Borders and overlays.
  static const borderSubtle = WinFlowzThemeTokens.appLightBorderSubtle;
  static const borderLight = WinFlowzThemeTokens.appLightBorder;
  static const borderDarkSubtle = WinFlowzThemeTokens.siteBorderDarkSubtle;
  static const overlayScrim = WinFlowzThemeTokens.siteScrim;

  // Support colors.
  static const success = WinFlowzThemeTokens.brandSuccess;
  static const warning = WinFlowzThemeTokens.brandWarning;
  static const danger = WinFlowzThemeTokens.brandDanger;
  static const dangerLight = WinFlowzThemeTokens.brandDangerLight;
  static const info = accent;

  // Keyboard preview surface-specific tokens (copied from pages de debug).
  static const keyboardPrivateFrame = WinFlowzThemeTokens.keyboardPrivateFrame;
  static const keyboardDefaultFrame = WinFlowzThemeTokens.keyboardDefaultFrame;
  static const keyboardStatusText = WinFlowzThemeTokens.keyboardStatusText;
  static const keyboardKeyActive = WinFlowzThemeTokens.keyboardKeyActive;
  static const keyboardKeySpecial = WinFlowzThemeTokens.keyboardKeySpecial;
  static const keyboardKeyDisabled = WinFlowzThemeTokens.keyboardKeyDisabled;
  static const keyboardKeyForeground =
      WinFlowzThemeTokens.keyboardKeyForeground;
  static const keyboardCornerLabel = WinFlowzThemeTokens.keyboardCornerLabel;
}

class AppTypography {
  static const fontFamily = WinFlowzThemeTokens.fontSans;
  static const fontFallback = WinFlowzThemeTokens.fontFallback;
  static const monospace = WinFlowzThemeTokens.fontMonospace;

  // WinFlowz scale (cohérente avec le thème site, bornée à un set court).
  static const xs = WinFlowzThemeTokens.typographyXs;
  static const sm = WinFlowzThemeTokens.typographySm;
  static const base = WinFlowzThemeTokens.typographySm;
  static const lg = WinFlowzThemeTokens.typographyLg;
  static const h3 = WinFlowzThemeTokens.typographyH3;
  static const h2 = WinFlowzThemeTokens.typographyH2;
  static const h1 = WinFlowzThemeTokens.typographyH1;

  static const leadingTight = WinFlowzThemeTokens.lineHeightTight;
  static const leadingSnug = WinFlowzThemeTokens.lineHeightSnug;
  static const leadingNormal = WinFlowzThemeTokens.lineHeightNormal;
  static const leadingCompact = WinFlowzThemeTokens.settingsDiagnosticLogLineHeight;
  static const leadingRelaxed = 1.8;

  static const trackingWide = WinFlowzThemeTokens.trackingWide;
  static const trackingWider = WinFlowzThemeTokens.trackingWider;
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
  static const x1 = WinFlowzThemeTokens.spacing1;
  static const x2 = WinFlowzThemeTokens.spacing2;
  static const x3 = WinFlowzThemeTokens.spacing3;
  static const x4 = WinFlowzThemeTokens.spacing4;
  static const x5 = WinFlowzThemeTokens.spacing5;
  static const x6 = WinFlowzThemeTokens.spacing6;
  static const x8 = WinFlowzThemeTokens.spacing8;
  static const x10 = WinFlowzThemeTokens.spacing10;
  static const x12 = WinFlowzThemeTokens.spacing12;
  static const x16 = WinFlowzThemeTokens.spacing16;
  static const x20 = WinFlowzThemeTokens.spacing20;
  static const x24 = WinFlowzThemeTokens.spacing24;
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
    horizontal: AppSpacing.x3,
    vertical: AppSpacing.x2,
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

class AppInputMetrics {
  static const minHeight = 48.0;
  static const iconMinSize = 48.0;
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
  static const bottomNavIconBoxSize =
      WinFlowzThemeTokens.appShellBottomNavIconBoxSize;
  static const bottomNavSparkBadgeTop =
      WinFlowzThemeTokens.appShellBottomNavSparkBadgeTop;
  static const bottomNavSparkBadgeRight =
      WinFlowzThemeTokens.appShellBottomNavSparkBadgeRight;
  static const bottomNavSparkBorderWidth =
      WinFlowzThemeTokens.appShellBottomNavSparkBorderWidth;
  static const utilityIconBoxSize =
      WinFlowzThemeTokens.appShellUtilityIconBoxSize;
  static const onboardingDotSize =
      WinFlowzThemeTokens.appShellOnboardingDotSize;
  static const onboardingDotIconSize =
      WinFlowzThemeTokens.appShellOnboardingDotIconSize;
  static const dividerThickness = WinFlowzThemeTokens.dividerThickness;
}

class AppLayoutMetrics {
  static const onboardingOverlayMaxWidth = 520.0;
  static const settingsTwoColumnBreakpoint = 1180.0;
  static const authFormMaxWidth = WinFlowzThemeTokens.authFormMaxWidth;
  static const authGateLoadingCardWidth =
      WinFlowzThemeTokens.authGateLoadingCardWidth;
  static const authGateErrorCardWidth =
      WinFlowzThemeTokens.authGateErrorCardWidth;
  static const authWebSignInButtonHeight =
      WinFlowzThemeTokens.authWebSignInButtonHeight;
  static const authWebSignInButtonMinWidth =
      WinFlowzThemeTokens.authWebSignInButtonMinWidth;
  static const authWebSignInButtonMaxWidth =
      WinFlowzThemeTokens.authWebSignInButtonMaxWidth;
  static const authWebSignInButtonDisabledOpacity =
      WinFlowzThemeTokens.authWebSignInButtonDisabledAlpha;
  static const customActionChipWidth =
      WinFlowzThemeTokens.customActionChipWidth;
  static const keyboardSyncDialogWidth =
      WinFlowzThemeTokens.keyboardSyncDialogWidth;
}

class AppBreakpoints {
  static const double navigationRail = WinFlowzThemeTokens.navRailBreakpoint;
  static const double navigationRailExtended =
      WinFlowzThemeTokens.navRailExtendedBreakpoint;
}

class AppKeyboardPreview {
  static const double maxWidth =
      WinFlowzThemeTokens.keyboardPreviewFrameMaxWidth;
  static const double dropdownWidth = 188.0;
  static const double pinnedBadgeInset =
      WinFlowzThemeTokens.keyboardPreviewPinnedBadgeInset;
  static const double statusHeight =
      WinFlowzThemeTokens.keyboardPreviewStatusHeight;
  static const double rowHeightTiny =
      WinFlowzThemeTokens.keyboardPreviewRowHeightMini;
  static const double rowHeightMini = rowHeightTiny;
  static const double rowHeightCompact =
      WinFlowzThemeTokens.keyboardPreviewRowHeightCompact;
  static const double rowHeightRegular =
      WinFlowzThemeTokens.keyboardPreviewRowHeight;
  static const double rowHeightControl =
      WinFlowzThemeTokens.keyboardPreviewControlHeight;
  static const double keyBorderWidth =
      WinFlowzThemeTokens.keyboardKeyBorderWidth;
  static const double keyDebugBorderWidth =
      WinFlowzThemeTokens.keyboardKeyDebugBorderWidth;
  static const double cornerLabelPadding =
      WinFlowzThemeTokens.keyboardCornerLabelPadding;
  static const double keyWeightScale = WinFlowzThemeTokens.keyboardWeightScale;
}

class AppSliders {
  static const double overlayBubbleSizeMin =
      WinFlowzThemeTokens.overlayBubbleSizeMin;
  static const double overlayBubbleSizeMax =
      WinFlowzThemeTokens.overlayBubbleSizeMax;
  static const int overlaySizeDivisions =
      WinFlowzThemeTokens.overlaySizeDivisions;
  static const double overlayBubbleOpacityMin =
      WinFlowzThemeTokens.overlayBubbleOpacityMin;
  static const double overlayBubbleOpacityMax =
      WinFlowzThemeTokens.overlayBubbleOpacityMax;
  static const int overlayOpacityDivisions =
      WinFlowzThemeTokens.overlayOpacityDivisions;
  static const double overlayDefaultSize =
      WinFlowzThemeTokens.overlayBubbleDefaultSize;
  static const double overlayDefaultOpacity =
      WinFlowzThemeTokens.overlayBubbleDefaultOpacity;
}

class AppKeyboardStudioMetrics {
  static const double sliderLabelWidth = 82.0;
  static const double sliderValueWidth = 62.0;
  static const double importExportDialogWidth = 420.0;
  static const double colorFieldPicker = 52.0;
  static const double colorFieldPickerIcon = 24.0;
  static const double previewPanelHeight = 74.0;
  static const double colorChannelWidth = 24.0;
  static const double colorValueWidth = 42.0;
  static const double fieldCornerRadius = 5.0;
  static const double presetDropdownWidth =
      WinFlowzThemeTokens.keyboardCornerPresetDropdownWidth;
  static const double previewLabelFontSize =
      WinFlowzThemeTokens.settingsThemePreviewLabelFontSize;
  static const double previewSwatchHeight =
      WinFlowzThemeTokens.settingsThemePreviewSwatchHeight;
  static const double previewSwatchRadius = 4.0;
}

class AppVoiceMetrics {
  static const double recordingSurfaceWidth =
      WinFlowzThemeTokens.voiceRecordingSurfaceWidth;
  static const double recordingSurfaceHeight =
      WinFlowzThemeTokens.voiceRecordingSurfaceHeight;
  static const double recordingBarWidth =
      WinFlowzThemeTokens.voiceRecordingBarWidth;
  static const double recordingBarHeightBase =
      WinFlowzThemeTokens.voiceRecordingBarHeightBase;
  static const double recordingBarHeightRange =
      WinFlowzThemeTokens.voiceRecordingBarHeightRange;
  static const double recordingSurfaceRadius =
      WinFlowzThemeTokens.voiceRecordingSurfaceRadius;
}

class AppElevation {
  static const overlay = WinFlowzThemeTokens.elevationOverlay;
  static const cardLight = WinFlowzThemeTokens.cardElevationLight;
  static const cardDark = WinFlowzThemeTokens.cardElevationDark;
}

class AppGradients {
  static LinearGradient shell(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          WinFlowzThemeTokens.siteBackground,
          WinFlowzThemeTokens.themeGradientDarkMid,
          WinFlowzThemeTokens.siteCard,
        ],
        stops: [0, 0.48, 1],
      );
    }

    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        WinFlowzThemeTokens.appLightBackground,
        WinFlowzThemeTokens.appLightSurface,
        WinFlowzThemeTokens.themeGradientLightMid,
      ],
      stops: [0, 0.52, 1],
    );
  }
}

class AppRadii {
  static const sm = WinFlowzThemeTokens.siteRadiusSm;
  static const md = WinFlowzThemeTokens.themeRadiusMd;
  static const lg = WinFlowzThemeTokens.siteRadiusLg;
  static const xl = WinFlowzThemeTokens.siteRadiusXl;
  static const x2l = WinFlowzThemeTokens.siteRadius2xl;
  static const xxl = WinFlowzThemeTokens.themeRadiusXxl;
  static const pill = WinFlowzThemeTokens.themeRadiusPill;
}

class AppShadows {
  static const sm = [
    BoxShadow(
      color: WinFlowzThemeTokens.shadowSoft,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const card = [
    BoxShadow(
      color: WinFlowzThemeTokens.shadowCard,
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  static const cardHover = [
    BoxShadow(
      color: WinFlowzThemeTokens.shadowCardHover,
      blurRadius: 30,
      offset: Offset(0, 8),
    ),
  ];

  static const cardLarge = [
    BoxShadow(
      color: WinFlowzThemeTokens.shadowCardLarge,
      blurRadius: 40,
      offset: Offset(0, 12),
    ),
  ];

  static const primary = [
    BoxShadow(
      color: WinFlowzThemeTokens.shadowPrimary,
      blurRadius: 15,
      offset: Offset(0, 4),
    ),
  ];
}

class AppMotion {
  static const instant = WinFlowzThemeTokens.motionInstant;
  static const fast = WinFlowzThemeTokens.motionFast;
  static const base = WinFlowzThemeTokens.motionBase;
  static const slow = WinFlowzThemeTokens.motionSlow;
  static const standardCurve = WinFlowzThemeTokens.motionStandard;
  static const outCurve = Curves.easeOut;
  static const springCurve = WinFlowzThemeTokens.motionSpring;
}

class AppTheme {
  static ThemeData get light => _build(
    ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: WinFlowzThemeTokens.themeLightPrimary,
      onPrimary: AppColors.white,
      primaryContainer: WinFlowzThemeTokens.themeLightPrimaryContainer,
      onPrimaryContainer: WinFlowzThemeTokens.themeLightOnPrimaryContainer,
      secondary: WinFlowzThemeTokens.themeLightSecondary,
      onSecondary: AppColors.white,
      secondaryContainer: WinFlowzThemeTokens.themeLightSecondaryContainer,
      onSecondaryContainer: WinFlowzThemeTokens.themeLightOnSecondaryContainer,
      tertiary: WinFlowzThemeTokens.siteRing,
      onTertiary: AppColors.white,
      error: AppColors.danger,
      surface: WinFlowzThemeTokens.themeLightSurface,
      onSurface: WinFlowzThemeTokens.themeLightOnSurface,
      surfaceContainerLowest:
          WinFlowzThemeTokens.themeLightSurfaceContainerLowest,
      surfaceContainerLow: WinFlowzThemeTokens.themeLightSurfaceContainerLow,
      surfaceContainer: WinFlowzThemeTokens.themeLightSurfaceContainer,
      surfaceContainerHighest:
          WinFlowzThemeTokens.themeLightSurfaceContainerHighest,
      outline: WinFlowzThemeTokens.themeLightOutline,
      outlineVariant: WinFlowzThemeTokens.themeLightOutlineVariant,
    ),
  );

  static ThemeData get dark => _build(
    ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: WinFlowzThemeTokens.themeDarkPrimary,
      onPrimary: WinFlowzThemeTokens.themeDarkOnPrimary,
      primaryContainer: WinFlowzThemeTokens.themeDarkPrimaryContainer,
      onPrimaryContainer: WinFlowzThemeTokens.themeDarkOnPrimaryContainer,
      secondary: WinFlowzThemeTokens.themeDarkSecondary,
      onSecondary: WinFlowzThemeTokens.themeDarkOnSecondary,
      secondaryContainer: WinFlowzThemeTokens.themeDarkSecondaryContainer,
      onSecondaryContainer: WinFlowzThemeTokens.themeDarkOnSecondaryContainer,
      tertiary: WinFlowzThemeTokens.siteRing,
      onTertiary: AppColors.white,
      error: AppColors.dangerLight,
      surface: WinFlowzThemeTokens.themeDarkSurface,
      onSurface: AppColors.textOnDark,
      surfaceContainerLowest:
          WinFlowzThemeTokens.themeDarkSurfaceContainerLowest,
      surfaceContainerLow: WinFlowzThemeTokens.themeDarkSurfaceContainerLow,
      surfaceContainer: WinFlowzThemeTokens.themeDarkSurfaceContainer,
      surfaceContainerHighest:
          WinFlowzThemeTokens.themeDarkSurfaceContainerHighest,
      outline: WinFlowzThemeTokens.themeDarkOutline,
      outlineVariant: WinFlowzThemeTokens.themeDarkOutlineVariant,
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
        scrolledUnderElevation: WinFlowzThemeTokens.appBarElevation,
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
        constraints: const BoxConstraints(minHeight: AppInputMetrics.minHeight),
        prefixIconConstraints: const BoxConstraints(
          minWidth: AppInputMetrics.iconMinSize,
          minHeight: AppInputMetrics.minHeight,
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: AppInputMetrics.iconMinSize,
          minHeight: AppInputMetrics.minHeight,
        ),
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
          isDense: true,
          constraints: const BoxConstraints(
            minHeight: AppInputMetrics.minHeight,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: AppInputMetrics.iconMinSize,
            minHeight: AppInputMetrics.minHeight,
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: AppInputMetrics.iconMinSize,
            minHeight: AppInputMetrics.minHeight,
          ),
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
            ? WinFlowzThemeTokens.siteForeground
            : WinFlowzThemeTokens.siteBackground,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark
              ? WinFlowzThemeTokens.sitePrimaryForeground
              : WinFlowzThemeTokens.siteForeground,
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
          alpha: WinFlowzThemeTokens.surfaceSubtleAlpha,
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
