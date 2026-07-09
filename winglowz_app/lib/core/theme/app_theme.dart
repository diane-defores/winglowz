import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:winglowz_app/core/theme/winglowz_theme_tokens.dart';

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
  // Brand primitives exposés pour WinGlowz.
  static const primary = WinGlowzThemeTokens.brandPrimary;
  static const primaryDark = WinGlowzThemeTokens.brandPrimaryDark;
  static const secondary = WinGlowzThemeTokens.brandSecondary;
  static const accent = secondary;

  // Neutral primitives (site theme base + app continuity).
  static const dark = WinGlowzThemeTokens.appLightText;
  static const gray = WinGlowzThemeTokens.siteMutedForeground;
  static const neutral = gray;
  static const slate = gray;
  static const lightGray = WinGlowzThemeTokens.lightGray;
  static const lightBlue = WinGlowzThemeTokens.brandSecondary;
  static const white = WinGlowzThemeTokens.white;
  static const black = WinGlowzThemeTokens.black;
  static const transparent = Colors.transparent;

  // Semantic surfaces and text.
  static const textPrimary = dark;
  static const siteBackground = WinGlowzThemeTokens.siteBackground;
  static const siteForeground = WinGlowzThemeTokens.siteForeground;
  static const textMuted = gray;
  static const surfaceBase = WinGlowzThemeTokens.appLightBackground;
  static const surfaceRaised = WinGlowzThemeTokens.appLightCard;
  static const surfaceOverlay = WinGlowzThemeTokens.appLightSurface;
  static const surfaceSunken = WinGlowzThemeTokens.surfaceSunken;
  static const surfaceSubtle = lightGray;
  static const surfaceTint = WinGlowzThemeTokens.appLightMuted;
  static const surfaceCard = surfaceRaised;
  static const surfaceBaseDark = siteBackground;
  static const surfaceRaisedDark = WinGlowzThemeTokens.surfaceRaisedDark;
  static const surfaceOverlayDark = WinGlowzThemeTokens.surfaceOverlayDark;
  static const surfaceSunkenDark = WinGlowzThemeTokens.surfaceSunkenDark;
  static const overlayDark = WinGlowzThemeTokens.siteWhiteSubtle;
  static const textOnDark = siteForeground;
  static const textOnDarkMuted = WinGlowzThemeTokens.siteTextOnDarkMuted;
  static const codeText = WinGlowzThemeTokens.siteCodeText;
  static const badgeBg = WinGlowzThemeTokens.siteBadgeBg;
  static const badgeText = WinGlowzThemeTokens.siteBadgeText;

  // Borders and overlays.
  static const borderSubtle = WinGlowzThemeTokens.appLightBorderSubtle;
  static const borderLight = WinGlowzThemeTokens.appLightBorder;
  static const borderDarkSubtle = WinGlowzThemeTokens.siteBorderDarkSubtle;
  static const overlayScrim = WinGlowzThemeTokens.siteScrim;

  // Support colors.
  static const success = WinGlowzThemeTokens.brandSuccess;
  static const warning = WinGlowzThemeTokens.brandWarning;
  static const danger = WinGlowzThemeTokens.brandDanger;
  static const dangerLight = WinGlowzThemeTokens.brandDangerLight;
  static const info = accent;

  // Keyboard preview surface-specific tokens (copied from pages de debug).
  static const keyboardPrivateFrame = WinGlowzThemeTokens.keyboardPrivateFrame;
  static const keyboardDefaultFrame = WinGlowzThemeTokens.keyboardDefaultFrame;
  static const keyboardStatusText = WinGlowzThemeTokens.keyboardStatusText;
  static const keyboardKeyActive = WinGlowzThemeTokens.keyboardKeyActive;
  static const keyboardKeySpecial = WinGlowzThemeTokens.keyboardKeySpecial;
  static const keyboardKeyDisabled = WinGlowzThemeTokens.keyboardKeyDisabled;
  static const keyboardKeyForeground =
      WinGlowzThemeTokens.keyboardKeyForeground;
  static const keyboardCornerLabel = WinGlowzThemeTokens.keyboardCornerLabel;
}

class AppTypography {
  static const fontFamily = WinGlowzThemeTokens.fontSans;
  static const fontFallback = WinGlowzThemeTokens.fontFallback;
  static const monospace = WinGlowzThemeTokens.fontMonospace;

  // WinGlowz scale (cohérente avec le thème site, bornée à un set court).
  static const xs = WinGlowzThemeTokens.typographyXs;
  static const sm = WinGlowzThemeTokens.typographySm;
  static const base = WinGlowzThemeTokens.typographySm;
  static const lg = WinGlowzThemeTokens.typographyLg;
  static const h3 = WinGlowzThemeTokens.typographyH3;
  static const h2 = WinGlowzThemeTokens.typographyH2;
  static const h1 = WinGlowzThemeTokens.typographyH1;

  static const leadingTight = WinGlowzThemeTokens.lineHeightTight;
  static const leadingSnug = WinGlowzThemeTokens.lineHeightSnug;
  static const leadingNormal = WinGlowzThemeTokens.lineHeightNormal;
  static const leadingCompact =
      WinGlowzThemeTokens.settingsDiagnosticLogLineHeight;
  static const leadingRelaxed = 1.8;

  static const trackingWide = WinGlowzThemeTokens.trackingWide;
  static const trackingWider = WinGlowzThemeTokens.trackingWider;
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
  static const x1 = WinGlowzThemeTokens.spacing1;
  static const x2 = WinGlowzThemeTokens.spacing2;
  static const x3 = WinGlowzThemeTokens.spacing3;
  static const x4 = WinGlowzThemeTokens.spacing4;
  static const x5 = WinGlowzThemeTokens.spacing5;
  static const x6 = WinGlowzThemeTokens.spacing6;
  static const x8 = WinGlowzThemeTokens.spacing8;
  static const x10 = WinGlowzThemeTokens.spacing10;
  static const x12 = WinGlowzThemeTokens.spacing12;
  static const x16 = WinGlowzThemeTokens.spacing16;
  static const x20 = WinGlowzThemeTokens.spacing20;
  static const x24 = WinGlowzThemeTokens.spacing24;
}

class AppInsets {
  static const none = EdgeInsets.zero;
  static const screen = EdgeInsets.symmetric(
    horizontal: AppSpacing.x2,
    vertical: AppSpacing.x3,
  );
  static const card = EdgeInsets.all(AppSpacing.x3);
  static const compactCard = EdgeInsets.all(AppSpacing.x2 + AppSpacing.x1 / 2);
  static const button = EdgeInsets.symmetric(
    horizontal: AppSpacing.x3,
    vertical: AppSpacing.x2,
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
  static const double sectionGap = AppSpacing.x2;
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
      WinGlowzThemeTokens.appShellBottomNavIconBoxSize;
  static const bottomNavSparkBadgeTop =
      WinGlowzThemeTokens.appShellBottomNavSparkBadgeTop;
  static const bottomNavSparkBadgeRight =
      WinGlowzThemeTokens.appShellBottomNavSparkBadgeRight;
  static const bottomNavSparkBorderWidth =
      WinGlowzThemeTokens.appShellBottomNavSparkBorderWidth;
  static const utilityIconBoxSize =
      WinGlowzThemeTokens.appShellUtilityIconBoxSize;
  static const onboardingDotSize =
      WinGlowzThemeTokens.appShellOnboardingDotSize;
  static const onboardingDotIconSize =
      WinGlowzThemeTokens.appShellOnboardingDotIconSize;
  static const dividerThickness = WinGlowzThemeTokens.dividerThickness;
}

class AppLayoutMetrics {
  static const onboardingOverlayMaxWidth = 520.0;
  static const settingsTwoColumnBreakpoint = 1180.0;
  static const settingsFeatureCardWidth =
      WinGlowzThemeTokens.settingsFeatureCardWidth;
  static const actionRailMinWidthLarge =
      WinGlowzThemeTokens.actionRailMinWidthLarge;
  static const actionRailMinWidthSmall =
      WinGlowzThemeTokens.actionRailMinWidthSmall;
  static const authFormMaxWidth = WinGlowzThemeTokens.authFormMaxWidth;
  static const authGateLoadingCardWidth =
      WinGlowzThemeTokens.authGateLoadingCardWidth;
  static const authGateErrorCardWidth =
      WinGlowzThemeTokens.authGateErrorCardWidth;
  static const authWebSignInButtonHeight =
      WinGlowzThemeTokens.authWebSignInButtonHeight;
  static const authWebSignInButtonMinWidth =
      WinGlowzThemeTokens.authWebSignInButtonMinWidth;
  static const authWebSignInButtonMaxWidth =
      WinGlowzThemeTokens.authWebSignInButtonMaxWidth;
  static const authWebSignInButtonDisabledOpacity =
      WinGlowzThemeTokens.authWebSignInButtonDisabledAlpha;
  static const customActionChipWidth =
      WinGlowzThemeTokens.customActionChipWidth;
  static const keyboardSyncDialogWidth =
      WinGlowzThemeTokens.keyboardSyncDialogWidth;
}

class AppBreakpoints {
  static const double navigationRail = WinGlowzThemeTokens.navRailBreakpoint;
  static const double navigationRailExtended =
      WinGlowzThemeTokens.navRailExtendedBreakpoint;
}

class AppKeyboardPreview {
  static const double maxWidth =
      WinGlowzThemeTokens.keyboardPreviewFrameMaxWidth;
  static const double dropdownWidth = 188.0;
  static const double pinnedBadgeInset =
      WinGlowzThemeTokens.keyboardPreviewPinnedBadgeInset;
  static const double statusHeight =
      WinGlowzThemeTokens.keyboardPreviewStatusHeight;
  static const double rowHeightTiny =
      WinGlowzThemeTokens.keyboardPreviewRowHeightMini;
  static const double rowHeightMini = rowHeightTiny;
  static const double rowHeightCompact =
      WinGlowzThemeTokens.keyboardPreviewRowHeightCompact;
  static const double rowHeightRegular =
      WinGlowzThemeTokens.keyboardPreviewRowHeight;
  static const double rowHeightControl =
      WinGlowzThemeTokens.keyboardPreviewControlHeight;
  static const double keyBorderWidth =
      WinGlowzThemeTokens.keyboardKeyBorderWidth;
  static const double keyDebugBorderWidth =
      WinGlowzThemeTokens.keyboardKeyDebugBorderWidth;
  static const double cornerLabelPadding =
      WinGlowzThemeTokens.keyboardCornerLabelPadding;
  static const double keyWeightScale = WinGlowzThemeTokens.keyboardWeightScale;
}

class AppSliders {
  static const double overlayBubbleSizeMin =
      WinGlowzThemeTokens.overlayBubbleSizeMin;
  static const double overlayBubbleSizeMax =
      WinGlowzThemeTokens.overlayBubbleSizeMax;
  static const int overlaySizeDivisions =
      WinGlowzThemeTokens.overlaySizeDivisions;
  static const double overlayBubbleOpacityMin =
      WinGlowzThemeTokens.overlayBubbleOpacityMin;
  static const double overlayBubbleOpacityMax =
      WinGlowzThemeTokens.overlayBubbleOpacityMax;
  static const int overlayOpacityDivisions =
      WinGlowzThemeTokens.overlayOpacityDivisions;
  static const double overlayDefaultSize =
      WinGlowzThemeTokens.overlayBubbleDefaultSize;
  static const double overlayDefaultOpacity =
      WinGlowzThemeTokens.overlayBubbleDefaultOpacity;
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
      WinGlowzThemeTokens.keyboardCornerPresetDropdownWidth;
  static const double previewLabelFontSize =
      WinGlowzThemeTokens.settingsThemePreviewLabelFontSize;
  static const double previewSwatchHeight =
      WinGlowzThemeTokens.settingsThemePreviewSwatchHeight;
  static const double previewSwatchRadius = 4.0;
}

class AppVoiceMetrics {
  static const double recordingSurfaceWidth =
      WinGlowzThemeTokens.voiceRecordingSurfaceWidth;
  static const double recordingSurfaceHeight =
      WinGlowzThemeTokens.voiceRecordingSurfaceHeight;
  static const double recordingBarWidth =
      WinGlowzThemeTokens.voiceRecordingBarWidth;
  static const double recordingBarHeightBase =
      WinGlowzThemeTokens.voiceRecordingBarHeightBase;
  static const double recordingBarHeightRange =
      WinGlowzThemeTokens.voiceRecordingBarHeightRange;
  static const double recordingSurfaceRadius =
      WinGlowzThemeTokens.voiceRecordingSurfaceRadius;
}

class AppElevation {
  static const overlay = WinGlowzThemeTokens.elevationOverlay;
  static const cardLight = WinGlowzThemeTokens.cardElevationLight;
  static const cardDark = WinGlowzThemeTokens.cardElevationDark;
}

class AppGradients {
  static LinearGradient shell(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          WinGlowzThemeTokens.siteBackground,
          WinGlowzThemeTokens.themeGradientDarkMid,
          WinGlowzThemeTokens.siteCard,
        ],
        stops: [0, 0.48, 1],
      );
    }

    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        WinGlowzThemeTokens.appLightBackground,
        WinGlowzThemeTokens.appLightSurface,
        WinGlowzThemeTokens.themeGradientLightMid,
      ],
      stops: [0, 0.52, 1],
    );
  }
}

class AppRadii {
  static const sm = WinGlowzThemeTokens.siteRadiusSm;
  static const md = WinGlowzThemeTokens.themeRadiusMd;
  static const lg = WinGlowzThemeTokens.siteRadiusLg;
  static const xl = WinGlowzThemeTokens.siteRadiusXl;
  static const x2l = WinGlowzThemeTokens.siteRadius2xl;
  static const xxl = WinGlowzThemeTokens.themeRadiusXxl;
  static const pill = WinGlowzThemeTokens.themeRadiusPill;
}

class AppShadows {
  static const sm = [
    BoxShadow(
      color: WinGlowzThemeTokens.shadowSoft,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const card = [
    BoxShadow(
      color: WinGlowzThemeTokens.shadowCard,
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  static const cardHover = [
    BoxShadow(
      color: WinGlowzThemeTokens.shadowCardHover,
      blurRadius: 30,
      offset: Offset(0, 8),
    ),
  ];

  static const cardLarge = [
    BoxShadow(
      color: WinGlowzThemeTokens.shadowCardLarge,
      blurRadius: 40,
      offset: Offset(0, 12),
    ),
  ];

  static const primary = [
    BoxShadow(
      color: WinGlowzThemeTokens.shadowPrimary,
      blurRadius: 15,
      offset: Offset(0, 4),
    ),
  ];
}

class AppMotion {
  static const instant = WinGlowzThemeTokens.motionInstant;
  static const micro = WinGlowzThemeTokens.motionMicro;
  static const fast = WinGlowzThemeTokens.motionFast;
  static const base = WinGlowzThemeTokens.motionBase;
  static const slow = WinGlowzThemeTokens.motionSlow;
  static const long = WinGlowzThemeTokens.motionLong;
  static const navSelected = WinGlowzThemeTokens.motionNavSelected;
  static const navUnselected = WinGlowzThemeTokens.motionNavUnselected;
  static const voiceAction = WinGlowzThemeTokens.motionVoiceAction;
  static const voiceBar = WinGlowzThemeTokens.motionVoiceBar;
  static const onboardingPulse = WinGlowzThemeTokens.motionOnboardingPulse;
  static const standardCurve = WinGlowzThemeTokens.motionStandard;
  static const outCurve = Curves.easeOut;
  static const springCurve = WinGlowzThemeTokens.motionSpring;
}

class AppTheme {
  static ThemeData get light => _build(
    ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: WinGlowzThemeTokens.themeLightPrimary,
      onPrimary: AppColors.white,
      primaryContainer: WinGlowzThemeTokens.themeLightPrimaryContainer,
      onPrimaryContainer: WinGlowzThemeTokens.themeLightOnPrimaryContainer,
      secondary: WinGlowzThemeTokens.themeLightSecondary,
      onSecondary: AppColors.white,
      secondaryContainer: WinGlowzThemeTokens.themeLightSecondaryContainer,
      onSecondaryContainer: WinGlowzThemeTokens.themeLightOnSecondaryContainer,
      tertiary: WinGlowzThemeTokens.siteRing,
      onTertiary: AppColors.white,
      error: AppColors.danger,
      surface: WinGlowzThemeTokens.themeLightSurface,
      onSurface: WinGlowzThemeTokens.themeLightOnSurface,
      surfaceContainerLowest:
          WinGlowzThemeTokens.themeLightSurfaceContainerLowest,
      surfaceContainerLow: WinGlowzThemeTokens.themeLightSurfaceContainerLow,
      surfaceContainer: WinGlowzThemeTokens.themeLightSurfaceContainer,
      surfaceContainerHighest:
          WinGlowzThemeTokens.themeLightSurfaceContainerHighest,
      outline: WinGlowzThemeTokens.themeLightOutline,
      outlineVariant: WinGlowzThemeTokens.themeLightOutlineVariant,
    ),
  );

  static ThemeData get dark => _build(
    ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: WinGlowzThemeTokens.themeDarkPrimary,
      onPrimary: WinGlowzThemeTokens.themeDarkOnPrimary,
      primaryContainer: WinGlowzThemeTokens.themeDarkPrimaryContainer,
      onPrimaryContainer: WinGlowzThemeTokens.themeDarkOnPrimaryContainer,
      secondary: WinGlowzThemeTokens.themeDarkSecondary,
      onSecondary: WinGlowzThemeTokens.themeDarkOnSecondary,
      secondaryContainer: WinGlowzThemeTokens.themeDarkSecondaryContainer,
      onSecondaryContainer: WinGlowzThemeTokens.themeDarkOnSecondaryContainer,
      tertiary: WinGlowzThemeTokens.siteRing,
      onTertiary: AppColors.white,
      error: AppColors.dangerLight,
      surface: WinGlowzThemeTokens.themeDarkSurface,
      onSurface: AppColors.textOnDark,
      surfaceContainerLowest:
          WinGlowzThemeTokens.themeDarkSurfaceContainerLowest,
      surfaceContainerLow: WinGlowzThemeTokens.themeDarkSurfaceContainerLow,
      surfaceContainer: WinGlowzThemeTokens.themeDarkSurfaceContainer,
      surfaceContainerHighest:
          WinGlowzThemeTokens.themeDarkSurfaceContainerHighest,
      outline: WinGlowzThemeTokens.themeDarkOutline,
      outlineVariant: WinGlowzThemeTokens.themeDarkOutlineVariant,
    ),
  );

  static ThemeData _build(ColorScheme colorScheme) {
    final textTheme = _textTheme(colorScheme);
    final iconTheme = IconThemeData(
      size: kIsWeb ? AppIconMetrics.sm * 1.3 : AppIconMetrics.sm,
      color: colorScheme.onSurfaceVariant,
    );
    final isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      visualDensity: VisualDensity.compact,
      scaffoldBackgroundColor: colorScheme.surface,
      fontFamily: AppTypography.fontFamily,
      fontFamilyFallback: AppTypography.fontFallback,
      textTheme: textTheme,
      iconTheme: iconTheme,
      canvasColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: WinGlowzThemeTokens.appBarElevation,
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
            size: kIsWeb
                ? (selected
                      ? AppNavigationMetrics.bottomSelectedIconSize * 1.3
                      : AppNavigationMetrics.bottomIconSize * 1.3)
                : (selected
                      ? AppNavigationMetrics.bottomSelectedIconSize
                      : AppNavigationMetrics.bottomIconSize),
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
            ? WinGlowzThemeTokens.siteForeground
            : WinGlowzThemeTokens.siteBackground,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark
              ? WinGlowzThemeTokens.sitePrimaryForeground
              : WinGlowzThemeTokens.siteForeground,
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
          alpha: WinGlowzThemeTokens.surfaceSubtleAlpha,
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
