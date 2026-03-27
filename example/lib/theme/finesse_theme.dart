import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:obers_ui/obers_ui.dart';

// ── Finesse UI Design System Color Tokens ──────────────────────────────────
// Source: Figma "Finesse UI – Figma UI Kit and Design System" (Community)
// Brand: deep indigo/navy (#0D0A2C) with muted purple-grey body text
// Font: DM Sans

/// Brand indigo
const _indigo = Color(0xFF0D0A2C);
const _indigoLight = Color(0xFF1E1A4A);
const _indigoDark = Color(0xFF06041A);
const _indigoMuted = Color(0xFFB8B5D0);

/// Body text purple-grey
const _bodyText = Color(0xFF615E83);
const _mutedText = Color(0xFF9895B3);
const _subtleText = Color(0xFFC5C3D6);

/// Accent — warm violet for interactive elements
const _violet = Color(0xFF6C5CE7);
const _violetLight = Color(0xFF8B7FF0);
const _violetDark = Color(0xFF5041C8);
const _violetMuted = Color(0xFFD4CFFA);

/// Success
const _green = Color(0xFF00C48C);
const _greenLight = Color(0xFF4DD6AD);
const _greenMuted = Color(0xFFD5F5EC);

/// Warning
const _amber = Color(0xFFFFB800);
const _amberLight = Color(0xFFFFCE4A);
const _amberMuted = Color(0xFFFFF3D0);

/// Error / Danger
const _coral = Color(0xFFFF5C5C);
const _coralLight = Color(0xFFFF8B8B);
const _coralMuted = Color(0xFFFFE0E0);

/// Info
const _sky = Color(0xFF3B82F6);
const _skyLight = Color(0xFF6BA3F8);
const _skyMuted = Color(0xFFDBEAFE);

/// Neutrals — Finesse uses a cool grey scale with slight purple tint
const _neutral50 = Color(0xFFFAFAFC);
const _neutral100 = Color(0xFFF4F4F8);
const _neutral200 = Color(0xFFE8E8F0);
const _neutral300 = Color(0xFFD1D0DE);
const _neutral500 = Color(0xFF8E8BA8);

// ── Theme Definitions ──────────────────────────────────────────────────────

/// Finesse UI light theme — deep indigo brand with clean purple-tinted
/// neutrals, smooth rounded corners, and elegant shadows.
final finesseTheme = OiThemeData(
  brightness: Brightness.light,
  fontFamily: 'DM Sans',
  colors: const OiColorScheme(
    primary: OiColorSwatch(
      base: _indigo,
      light: _indigoLight,
      dark: _indigoDark,
      muted: _indigoMuted,
      foreground: Color(0xFFFFFFFF),
    ),
    accent: OiColorSwatch(
      base: _violet,
      light: _violetLight,
      dark: _violetDark,
      muted: _violetMuted,
      foreground: Color(0xFFFFFFFF),
    ),
    success: OiColorSwatch(
      base: _green,
      light: _greenLight,
      dark: Color(0xFF009E72),
      muted: _greenMuted,
      foreground: Color(0xFFFFFFFF),
    ),
    warning: OiColorSwatch(
      base: _amber,
      light: _amberLight,
      dark: Color(0xFFD99D00),
      muted: _amberMuted,
      foreground: Color(0xFF1A1A1A),
    ),
    error: OiColorSwatch(
      base: _coral,
      light: _coralLight,
      dark: Color(0xFFD93636),
      muted: _coralMuted,
      foreground: Color(0xFFFFFFFF),
    ),
    info: OiColorSwatch(
      base: _sky,
      light: _skyLight,
      dark: Color(0xFF2563EB),
      muted: _skyMuted,
      foreground: Color(0xFFFFFFFF),
    ),

    // Surfaces — Finesse uses white with subtle purple-tinted greys
    background: _neutral50,
    surface: Color(0xFFFFFFFF),
    surfaceHover: _neutral100,
    surfaceActive: _neutral200,
    surfaceSubtle: _neutral50,
    overlay: Color(0x66000000),

    // Text — Finesse's purple-grey hierarchy
    text: _indigo,
    textSubtle: _bodyText,
    textMuted: _mutedText,
    textInverse: Color(0xFFFFFFFF),
    textOnPrimary: Color(0xFFFFFFFF),

    // Borders — cool purple-tinted neutrals
    border: _neutral300,
    borderSubtle: _neutral200,
    borderFocus: _violet,
    borderError: _coral,

    // Glass
    glassBackground: Color(0x99FFFFFF),
    glassBorder: Color(0x33FFFFFF),

    // Chart palette
    chart: [
      Color(0xFF6C5CE7), // violet
      Color(0xFF00C48C), // green
      Color(0xFF3B82F6), // blue
      Color(0xFFFFB800), // amber
      Color(0xFFFF5C5C), // coral
      Color(0xFF0D0A2C), // indigo
      Color(0xFF8E8BA8), // neutral
      Color(0xFFD1D0DE), // light neutral
    ],
  ),
  textTheme: OiTextTheme.standard(fontFamily: 'DM Sans'),
  spacing: OiSpacingScale.standard(),
  // Finesse "Smooth Rectangle" style — rounded corners
  radius: OiRadiusScale.forPreference(OiRadiusPreference.rounded),
  // Elegant, soft shadows
  shadows: const OiShadowScale(
    none: [],
    xs: [
      BoxShadow(color: Color(0x0A0D0A2C), offset: Offset(0, 1), blurRadius: 3),
    ],
    sm: [
      BoxShadow(color: Color(0x0F0D0A2C), offset: Offset(0, 2), blurRadius: 8),
      BoxShadow(color: Color(0x050D0A2C), offset: Offset(0, 1), blurRadius: 3),
    ],
    md: [
      BoxShadow(color: Color(0x140D0A2C), offset: Offset(0, 4), blurRadius: 16),
      BoxShadow(color: Color(0x080D0A2C), offset: Offset(0, 2), blurRadius: 6),
    ],
    lg: [
      BoxShadow(color: Color(0x140D0A2C), offset: Offset(0, 8), blurRadius: 32),
      BoxShadow(color: Color(0x0A0D0A2C), offset: Offset(0, 4), blurRadius: 12),
    ],
    xl: [
      BoxShadow(
        color: Color(0x1F0D0A2C),
        offset: Offset(0, 16),
        blurRadius: 48,
      ),
      BoxShadow(color: Color(0x0F0D0A2C), offset: Offset(0, 8), blurRadius: 24),
    ],
    glass: [BoxShadow(color: Color(0x1A0D0A2C), blurRadius: 24)],
  ),
  animations: const OiAnimationConfig.standard(),
  effects: OiEffectsTheme.standard(primaryColor: _indigo, focusColor: _violet),
  decoration: OiDecorationTheme.standard(
    primaryColor: _indigo,
    errorColor: _coral,
  ),
  components: OiComponentThemes(
    button: OiButtonThemeData(
      borderRadius: BorderRadius.circular(10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      primaryStyle: const OiButtonVariantStyle(
        background: _violet,
        backgroundHover: _violetLight,
        backgroundPressed: _violetDark,
        foreground: Color(0xFFFFFFFF),
      ),
    ),
    textInput: OiTextInputThemeData(
      borderRadius: BorderRadius.circular(10),
      borderColor: _neutral300,
      focusBorderColor: _violet,
      validationErrorColor: _coral,
    ),
    card: OiCardThemeData(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(20),
      shadow: const [
        BoxShadow(
          color: Color(0x140D0A2C),
          offset: Offset(0, 4),
          blurRadius: 16,
        ),
        BoxShadow(
          color: Color(0x080D0A2C),
          offset: Offset(0, 2),
          blurRadius: 6,
        ),
      ],
    ),
    dialog: OiDialogThemeData(
      borderRadius: BorderRadius.circular(16),
      contentPadding: const EdgeInsets.all(24),
    ),
    toast: OiToastThemeData(
      borderRadius: BorderRadius.circular(10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
    tooltip: OiTooltipThemeData(
      borderRadius: BorderRadius.circular(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    badge: OiBadgeThemeData(borderRadius: BorderRadius.circular(6)),
    tabs: const OiTabsThemeData(
      indicatorColor: _violet,
      activeLabelColor: _violet,
      inactiveLabelColor: _mutedText,
    ),
    progress: OiProgressThemeData(
      height: 6,
      borderRadius: BorderRadius.circular(3),
    ),
    select: OiSelectThemeData(borderRadius: BorderRadius.circular(10)),
  ),
);

/// Finesse UI dark theme.
final finesseDarkTheme = OiThemeData(
  brightness: Brightness.dark,
  fontFamily: 'DM Sans',
  colors: const OiColorScheme(
    primary: OiColorSwatch(
      base: _indigoMuted,
      light: _subtleText,
      dark: Color(0xFFE0DEF0),
      muted: Color(0xFF2A274A),
      foreground: _indigo,
    ),
    accent: OiColorSwatch(
      base: _violetLight,
      light: Color(0xFFA99DF4),
      dark: _violet,
      muted: Color(0xFF241E58),
      foreground: Color(0xFFFFFFFF),
    ),
    success: OiColorSwatch(
      base: _greenLight,
      light: Color(0xFF7FE5C5),
      dark: _green,
      muted: Color(0xFF0A3D2B),
      foreground: Color(0xFFFFFFFF),
    ),
    warning: OiColorSwatch(
      base: _amberLight,
      light: Color(0xFFFFDA7A),
      dark: _amber,
      muted: Color(0xFF3D3010),
      foreground: Color(0xFF1A1A1A),
    ),
    error: OiColorSwatch(
      base: _coralLight,
      light: Color(0xFFFFB3B3),
      dark: _coral,
      muted: Color(0xFF4D1A1A),
      foreground: Color(0xFFFFFFFF),
    ),
    info: OiColorSwatch(
      base: _skyLight,
      light: Color(0xFF93BAFA),
      dark: _sky,
      muted: Color(0xFF132A4D),
      foreground: Color(0xFFFFFFFF),
    ),

    // Dark surfaces — deep indigo tones
    background: Color(0xFF0A0820),
    surface: Color(0xFF13102E),
    surfaceHover: Color(0xFF1C1940),
    surfaceActive: Color(0xFF26224E),
    surfaceSubtle: Color(0xFF0D0B26),
    overlay: Color(0x99000000),

    // Dark text
    text: Color(0xFFF4F4F8),
    textSubtle: Color(0xFFD1D0DE),
    textMuted: Color(0xFF8E8BA8),
    textInverse: _indigo,
    textOnPrimary: _indigo,

    // Dark borders
    border: Color(0xFF2E2B4A),
    borderSubtle: Color(0xFF1C1940),
    borderFocus: _violetLight,
    borderError: _coralLight,

    // Glass
    glassBackground: Color(0x33FFFFFF),
    glassBorder: Color(0x1AFFFFFF),

    // Dark chart palette
    chart: [
      Color(0xFF8B7FF0), // violet light
      Color(0xFF4DD6AD), // green light
      Color(0xFF6BA3F8), // blue light
      Color(0xFFFFCE4A), // amber light
      Color(0xFFFF8B8B), // coral light
      Color(0xFFB8B5D0), // indigo muted
      Color(0xFFD1D0DE), // neutral
      Color(0xFF8E8BA8), // neutral mid
    ],
  ),
  textTheme: OiTextTheme.standard(fontFamily: 'DM Sans'),
  spacing: OiSpacingScale.standard(),
  radius: OiRadiusScale.forPreference(OiRadiusPreference.rounded),
  shadows: const OiShadowScale(
    none: [],
    xs: [
      BoxShadow(color: Color(0x29000000), offset: Offset(0, 1), blurRadius: 3),
    ],
    sm: [
      BoxShadow(color: Color(0x29000000), offset: Offset(0, 2), blurRadius: 8),
      BoxShadow(color: Color(0x14000000), offset: Offset(0, 1), blurRadius: 3),
    ],
    md: [
      BoxShadow(color: Color(0x33000000), offset: Offset(0, 4), blurRadius: 16),
      BoxShadow(color: Color(0x1F000000), offset: Offset(0, 2), blurRadius: 6),
    ],
    lg: [
      BoxShadow(color: Color(0x33000000), offset: Offset(0, 8), blurRadius: 32),
      BoxShadow(color: Color(0x1F000000), offset: Offset(0, 4), blurRadius: 12),
    ],
    xl: [
      BoxShadow(
        color: Color(0x3D000000),
        offset: Offset(0, 16),
        blurRadius: 48,
      ),
      BoxShadow(color: Color(0x29000000), offset: Offset(0, 8), blurRadius: 24),
    ],
    glass: [BoxShadow(color: Color(0x33000000), blurRadius: 24)],
  ),
  animations: const OiAnimationConfig.standard(),
  effects: OiEffectsTheme.standard(
    primaryColor: _violetLight,
    focusColor: _violetLight,
  ),
  decoration: OiDecorationTheme.standard(
    primaryColor: _violetLight,
    errorColor: _coralLight,
  ),
  components: OiComponentThemes(
    button: OiButtonThemeData(
      borderRadius: BorderRadius.circular(10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      primaryStyle: const OiButtonVariantStyle(
        background: _violetLight,
        backgroundHover: Color(0xFFA99DF4),
        backgroundPressed: _violet,
        foreground: Color(0xFFFFFFFF),
      ),
    ),
    textInput: OiTextInputThemeData(
      borderRadius: BorderRadius.circular(10),
      borderColor: const Color(0xFF2E2B4A),
      focusBorderColor: _violetLight,
      validationErrorColor: _coralLight,
    ),
    card: OiCardThemeData(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(20),
      shadow: const [
        BoxShadow(
          color: Color(0x33000000),
          offset: Offset(0, 4),
          blurRadius: 16,
        ),
        BoxShadow(
          color: Color(0x1F000000),
          offset: Offset(0, 2),
          blurRadius: 6,
        ),
      ],
    ),
    dialog: OiDialogThemeData(
      borderRadius: BorderRadius.circular(16),
      contentPadding: const EdgeInsets.all(24),
    ),
    toast: OiToastThemeData(
      borderRadius: BorderRadius.circular(10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
    tooltip: OiTooltipThemeData(
      borderRadius: BorderRadius.circular(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    badge: OiBadgeThemeData(borderRadius: BorderRadius.circular(6)),
    tabs: const OiTabsThemeData(
      indicatorColor: _violetLight,
      activeLabelColor: _violetLight,
      inactiveLabelColor: _neutral500,
    ),
    progress: OiProgressThemeData(
      height: 6,
      borderRadius: BorderRadius.circular(3),
    ),
    select: OiSelectThemeData(borderRadius: BorderRadius.circular(10)),
  ),
);
