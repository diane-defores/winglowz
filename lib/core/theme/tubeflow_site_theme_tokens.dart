import 'package:flutter/material.dart';

/// Tokens centralisés inspirés du thème du site
/// `tubeflow_site/src/styles/global.css` et des fichiers liés copiés en
/// `assets/theme_reference/tubeflow_site`.
class TubeflowSiteThemeTokens {
  // Typography
  static const fontSans = 'Manrope';
  static const fontDisplay = 'Cal Sans';
  static const fontMonospace = 'ui-monospace';
  static const List<String> fontFallback = <String>[
    'Manrope',
    'Instrument Sans',
    'Segoe UI',
    'Roboto',
    'Arial',
    'sans-serif',
  ];

  // Palette principale issue des tokens CSS du site (valeurs Oklch converties).
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color siteBackground = Color(0xFF262626);
  static const Color siteForeground = Color(0xFFFCFCFC);
  static const Color siteCard = Color(0xFF2D2D2D);
  static const Color siteCardForeground = Color(0xFFFCFCFC);
  static const Color sitePopover = Color(0xFF262626);
  static const Color sitePopoverForeground = Color(0xFFFCFCFC);
  static const Color sitePrimary = Color(0xFFFCFCFC);
  static const Color sitePrimaryForeground = Color(0xFF343A40);
  static const Color siteSecondary = Color(0xFF444444);
  static const Color siteSecondaryForeground = Color(0xFFFCFCFC);
  static const Color siteMuted = Color(0xFF444444);
  static const Color siteMutedForeground = Color(0xFFB4B4B4);
  static const Color siteAccent = Color(0xFF444444);
  static const Color siteAccentForeground = Color(0xFFFCFCFC);
  static const Color siteDestructive = Color(0xFFB91C1C);
  static const Color siteDestructiveForeground = Color(0xFFFFE8E6);
  static const Color siteText = Color(0xFF0F172A);
  static const Color siteBorder = Color(0xFF3D3D3D);
  static const Color siteInput = Color(0xFF444444);
  static const Color siteRing = Color(0xFF6F747F);
  static const Color siteScrim = Color(0x66000000);
  static const Color siteCodeText = Color(0xFFE2E8F0);
  static const Color siteBadgeBg = Color(0xFF27272A);
  static const Color siteBadgeText = Color(0xFFF4F4F5);
  static const Color siteTextOnDarkMuted = Color(0xB3FFFFFF);
  static const Color siteBorderSubtle = Color(0x0D000000);
  static const Color siteBorderDarkSubtle = Color(0x1AFFFFFF);
  static const Color siteWhiteSubtle = Color(0x1AFFFFFF);

  // Light companion palette for app screens that still support Light/System.
  static const Color appLightBackground = Color(0xFFF4F3EE);
  static const Color appLightSurface = Color(0xFFFAFAF7);
  static const Color appLightCard = Color(0xFFFFFFFF);
  static const Color appLightMuted = Color(0xFFE7E5DE);
  static const Color appLightMutedForeground = Color(0xFF5F5F5A);
  static const Color appLightBorder = Color(0xFFD8D5CC);
  static const Color appLightBorderSubtle = Color(0x1A262626);
  static const Color appLightText = Color(0xFF171717);
  static const Color appLightInput = Color(0xFFFFFFFF);

  // App action palette: TubeFlow keeps primary actions monochrome.
  static const Color appActionLight = Color(0xFF262626);
  static const Color appActionOnLight = Color(0xFFFCFCFC);
  static const Color appActionDark = Color(0xFFFCFCFC);
  static const Color appActionOnDark = Color(0xFF343A40);

  // Raysons (root radius + variants).
  static const double siteRadius = 16.0;
  static const double siteRadiusSm = siteRadius - 4.0;
  static const double siteRadiusMd = siteRadius - 2.0;
  static const double siteRadiusLg = siteRadius;
  static const double siteRadiusXl = siteRadius + 4.0;
  static const double siteRadius2xl = siteRadius + 8.0;

  // Typographie.
  static const double typographyXs = 12.0;
  static const double typographySm = 14.0;
  static const double typographyBase = 16.0;
  static const double typographyMd = 20.0;
  static const double typographyLg = 24.0;
  static const double typographyXl = 32.0;
  static const double typographyXxl = 40.0;
  static const double lineHeightTight = 1.2;
  static const double lineHeightSnug = 1.3;
  static const double lineHeightNormal = 1.6;
  static const double trackingWide = 0.04;
  static const double trackingWider = 0.08;

  // Espacement.
  static const double spacing1 = 4.0;
  static const double spacing2 = 8.0;
  static const double spacing3 = 12.0;
  static const double spacing4 = 16.0;
  static const double spacing5 = 20.0;
  static const double spacing6 = 24.0;
  static const double spacing8 = 32.0;
  static const double spacing10 = 40.0;
  static const double spacing12 = 48.0;
  static const double spacing16 = 64.0;
  static const double spacing20 = 80.0;
  static const double spacing24 = 96.0;

  // Layout tokens (shared across Flutter pages).
  static const double navRailBreakpoint = 720.0;
  static const double navRailExtendedBreakpoint = 980.0;
  static const double keyboardPreviewFrameMaxWidth = 760.0;
  static const double keyboardPreviewDropdownWidth = 220.0;
  static const double keyboardPreviewStatusHeight = 30.0;
  static const double keyboardPreviewControlHeight = 48.0;
  static const double keyboardPreviewRowHeightTall = 48.0;
  static const double keyboardPreviewRowHeight = 46.0;
  static const double keyboardPreviewRowHeightCompact = 42.0;
  static const double keyboardPreviewRowHeightMini = 40.0;
  static const double keyboardKeyBorderWidth = 1.0;
  static const double keyboardKeyDebugBorderWidth = 1.3;
  static const double keyboardCornerLabelPadding = 4.0;
  static const double keyboardWeightScale = 100.0;

  // Motion / settings slider tokens.
  static const double appAnimationFast = 0.22;
  static const double appAnimationBase = 1.0;
  static const int overlaySizeDivisions = 6;
  static const int overlayOpacityDivisions = 5;
  static const double overlayBubbleSizeMin = 0.8;
  static const double overlayBubbleSizeMax = 1.4;
  static const double overlayBubbleOpacityMin = 0.5;
  static const double overlayBubbleOpacityMax = 1.0;
  static const double overlayBubbleDefaultSize = 1.0;
  static const double overlayBubbleDefaultOpacity = 0.9;

  // Surfaces and state token values used in Flutter theme composition.
  static const double surfaceSubtleAlpha = 0.72;
  static const double textFieldFillAlpha = 0.72;
  static const double cardShadowAlpha = 0.18;
  static const double darkCardShadowAlpha = 0.42;
  static const double textFieldBorderWidth = 1.5;
  static const double cardElevationLight = 2.0;
  static const double cardElevationDark = 8.0;
  static const double appBarElevation = 0.0;
  static const double dividerThickness = 1.0;
  static const double elevationOverlay = 18.0;

  // Motion.
  static const Duration motionInstant = Duration(milliseconds: 120);
  static const Duration motionFast = Duration(milliseconds: 150);
  static const Duration motionBase = Duration(milliseconds: 200);
  static const Duration motionSlow = Duration(milliseconds: 300);
  static const Duration motionLong = Duration(milliseconds: 800);
  static const Cubic motionStandard = Cubic(0.22, 1, 0.36, 1);
  static const Cubic motionSpring = Cubic(0.34, 1.56, 0.64, 1);

  // Composants d'app UI conservés pour la continuité de l'app Flutter.
  static const Color brandPrimary = appActionLight;
  static const Color brandPrimaryDark = appActionDark;
  static const Color brandSecondary = siteSecondary;
  static const Color brandSuccess = Color(0xFF16A34A);
  static const Color brandWarning = Color(0xFFD97706);
  static const Color brandDanger = Color(0xFFDC2626);
  static const Color brandDangerLight = Color(0xFFF87171);
  static const Color lightGray = appLightMuted;
  static const Color surfaceSunken = appLightBackground;
  static const Color surfaceRaised = appLightCard;
  static const Color surfaceSunkenDark = siteBackground;
  static const Color surfaceRaisedDark = siteCard;
  static const Color surfaceOverlayDark = siteSecondary;

  // Ombres plus proches du rendu TubeFlow: profondes mais neutres.
  static const Color shadowSoft = Color(0x18000000);
  static const Color shadowCard = Color(0x26000000);
  static const Color shadowCardHover = Color(0x33000000);
  static const Color shadowCardLarge = Color(0x40000000);
  static const Color shadowPrimary = Color(0x33000000);

  // Surfaces/typographies de rappel de la page clavier (existant app).
  static const Color keyboardPrivateFrame = Color(0xFFF6E8E2);
  static const Color keyboardDefaultFrame = Color(0xFFEEF1EE);
  static const Color keyboardStatusText = Color(0xFF333D38);
  static const Color keyboardKeyActive = Color(0xFF17795D);
  static const Color keyboardKeySpecial = Color(0xFFE0E6E3);
  static const Color keyboardKeyDisabled = Color(0xFFD6D9D7);
  static const Color keyboardKeyForeground = Color(0xFF1D2320);
  static const Color keyboardCornerLabel = Color(0xFF5C6762);
}
