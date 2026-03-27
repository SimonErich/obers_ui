import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:obers_ui/obers_ui.dart';

// ── Arco Design System Color Tokens ────────────────────────────────────────
// Source: https://arco.design — ByteDance open-source design system
// Primary: Arco Blue (#165DFF), generated 10-shade palettes

/// Primary palette (Arco Blue) — shades 1-10, base = 6
const _arcoblue1 = Color(0xFFE8F3FF);
const _arcoblue2 = Color(0xFFBEDAFF);
const _arcoblue3 = Color(0xFF94BFFF);
const _arcoblue4 = Color(0xFF6AA1FF);
const _arcoblue5 = Color(0xFF4080FF);
const _arcoblue6 = Color(0xFF165DFF); // base primary
const _arcoblue7 = Color(0xFF0E42D2);
const _arcoblue8 = Color(0xFF072CA6);
const _arcoblue9 = Color(0xFF031A79);
const _arcoblue10 = Color(0xFF000D4D);

/// Success palette (Green)
const _green1 = Color(0xFFE8FFEA);
const _green3 = Color(0xFF7BE188);
const _green6 = Color(0xFF00B42A); // base success

/// Warning palette (Orange)
const _orange1 = Color(0xFFFFF7E8);
const _orange3 = Color(0xFFFFCF8B);
const _orange6 = Color(0xFFFF7D00); // base warning

/// Danger palette (Red)
const _red1 = Color(0xFFFFECE8);
const _red3 = Color(0xFFFBB0A7);
const _red6 = Color(0xFFF53F3F); // base danger

/// Link/Info palette (Blue — same family, slightly different from primary)
const _blue6 = Color(0xFF3491FA);

/// Neutral palette (Gray) — light theme
const _gray1 = Color(0xFFF7F8FA);
const _gray2 = Color(0xFFF2F3F5);
const _gray3 = Color(0xFFE5E6EB);
const _gray4 = Color(0xFFC9CDD4);
const _gray5 = Color(0xFFA9AEB8);
const _gray6 = Color(0xFF86909C);
const _gray7 = Color(0xFF6B7785);
const _gray8 = Color(0xFF4E5969);
const _gray9 = Color(0xFF272E3B);
const _gray10 = Color(0xFF1D2129);

/// Dark theme background colors
const _darkBg1 = Color(0xFF17171A);
const _darkBg2 = Color(0xFF232324);
const _darkBg3 = Color(0xFF2A2A2B);
const _darkBg4 = Color(0xFF313132);
const _darkBg5 = Color(0xFF373739);

// ── Theme Definitions ──────────────────────────────────────────────────────

/// Arco Design light theme — ByteDance's Arco Blue brand with clean
/// neutral surfaces, 4px medium radius, and crisp elevation.
final arcoTheme = OiThemeData(
  brightness: Brightness.light,
  componentSizes: const OiComponentSizeScale.arco(),
  colors: OiColorScheme(
    primary: OiColorSwatch(
      base: _arcoblue6,
      light: _arcoblue5,
      dark: _arcoblue7,
      muted: _arcoblue3,
      foreground: const Color(0xFFFFFFFF),
    ),
    accent: OiColorSwatch(
      base: const Color(0xFF722ED1), // Arco purple
      light: const Color(0xFF8D4EDA),
      dark: const Color(0xFF551DB0),
      muted: const Color(0xFFD4BCFB),
      foreground: const Color(0xFFFFFFFF),
    ),
    success: OiColorSwatch(
      base: _green6,
      light: _green3,
      dark: const Color(0xFF009A29),
      muted: _green1,
      foreground: const Color(0xFFFFFFFF),
    ),
    warning: OiColorSwatch(
      base: _orange6,
      light: _orange3,
      dark: const Color(0xFFD25F00),
      muted: _orange1,
      foreground: const Color(0xFFFFFFFF),
    ),
    error: OiColorSwatch(
      base: _red6,
      light: _red3,
      dark: const Color(0xFFCB2634),
      muted: _red1,
      foreground: const Color(0xFFFFFFFF),
    ),
    info: OiColorSwatch(
      base: _blue6,
      light: const Color(0xFF6BB5F8),
      dark: const Color(0xFF206CCF),
      muted: const Color(0xFFE8F7FF),
      foreground: const Color(0xFFFFFFFF),
    ),

    // Surfaces — Arco uses pure white backgrounds
    background: const Color(0xFFF2F3F5), // gray-2
    surface: const Color(0xFFFFFFFF),
    surfaceHover: _gray1,
    surfaceActive: _gray3,
    surfaceSubtle: _gray1,
    overlay: const Color(0x66000000),

    // Text — Arco text hierarchy uses gray-10 through gray-4
    text: _gray10, // color-text-1 (primary)
    textSubtle: _gray8, // color-text-2 (secondary)
    textMuted: _gray6, // color-text-3 (placeholder)
    textInverse: const Color(0xFFFFFFFF),
    textOnPrimary: const Color(0xFFFFFFFF),

    // Borders — Arco uses gray-3 as default border
    border: _gray3, // color-border
    borderSubtle: _gray2, // color-border-1
    borderFocus: _arcoblue6,
    borderError: _red6,

    // Glass
    glassBackground: const Color(0x99FFFFFF),
    glassBorder: const Color(0x33FFFFFF),

    // Chart palette
    chart: const [
      Color(0xFF165DFF), // arcoblue
      Color(0xFF0FC6C2), // cyan
      Color(0xFF722ED1), // purple
      Color(0xFFF7BA1E), // gold
      Color(0xFFEE4D38), // red
      Color(0xFF3491FA), // blue
      Color(0xFF00B42A), // green
      Color(0xFFFF7D00), // orange
    ],
  ),
  textTheme: OiTextTheme.standard(),
  spacing: OiSpacingScale.standard(),
  // Arco uses: small=2px, medium=4px, large=8px
  radius: OiRadiusScale.forPreference(OiRadiusPreference.medium),
  // Arco shadow scale
  shadows: OiShadowScale(
    none: const [],
    // shadow-1: subtle
    xs: const [
      BoxShadow(color: Color(0x14000000), offset: Offset(0, 2), blurRadius: 5),
    ],
    // shadow-1 full
    sm: const [
      BoxShadow(color: Color(0x14000000), offset: Offset(0, 4), blurRadius: 10),
    ],
    // shadow-2
    md: const [
      BoxShadow(color: Color(0x1F000000), offset: Offset(0, 4), blurRadius: 10),
    ],
    // shadow-3
    lg: const [
      BoxShadow(color: Color(0x14000000), offset: Offset(0, 4), blurRadius: 20),
      BoxShadow(color: Color(0x0A000000), offset: Offset(0, 2), blurRadius: 10),
    ],
    xl: const [
      BoxShadow(color: Color(0x1F000000), offset: Offset(0, 8), blurRadius: 40),
      BoxShadow(color: Color(0x14000000), offset: Offset(0, 4), blurRadius: 20),
    ],
    glass: const [BoxShadow(color: Color(0x1A000000), blurRadius: 24)],
  ),
  animations: const OiAnimationConfig.standard(),
  effects: OiEffectsTheme.standard(
    primaryColor: _arcoblue6,
    focusColor: _arcoblue6,
  ),
  decoration: OiDecorationTheme.standard(
    primaryColor: _arcoblue6,
    errorColor: _red6,
  ),
  components: OiComponentThemes(
    button: OiButtonThemeData(
      borderRadius: BorderRadius.circular(4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    textInput: OiTextInputThemeData(
      borderRadius: BorderRadius.circular(4),
      borderColor: _gray3,
      focusBorderColor: _arcoblue6,
      validationErrorColor: _red6,
    ),
    card: OiCardThemeData(
      borderRadius: BorderRadius.circular(4),
      padding: const EdgeInsets.all(16),
    ),
    dialog: OiDialogThemeData(borderRadius: BorderRadius.circular(8)),
    toast: OiToastThemeData(borderRadius: BorderRadius.circular(4)),
    tooltip: OiTooltipThemeData(
      borderRadius: BorderRadius.circular(4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    badge: OiBadgeThemeData(borderRadius: BorderRadius.circular(2)),
    tabs: OiTabsThemeData(
      indicatorColor: _arcoblue6,
      activeLabelColor: _arcoblue6,
      inactiveLabelColor: _gray6,
    ),
    progress: OiProgressThemeData(
      height: 4,
      borderRadius: BorderRadius.circular(2),
    ),
    select: OiSelectThemeData(borderRadius: BorderRadius.circular(4)),
    checkbox: const OiCheckboxThemeData(
      size: 16,
      borderRadius: BorderRadius.all(Radius.circular(2)),
      checkedColor: _arcoblue6,
      uncheckedBorderColor: _gray3,
    ),
    switchTheme: const OiSwitchThemeData(
      activeTrackColor: _arcoblue6,
      inactiveTrackColor: _gray3,
    ),
  ),
);

/// Arco Design dark theme.
final arcoDarkTheme = OiThemeData(
  brightness: Brightness.dark,
  componentSizes: const OiComponentSizeScale.arco(),
  colors: OiColorScheme(
    primary: OiColorSwatch(
      base: _arcoblue5, // lighter in dark mode
      light: _arcoblue4,
      dark: _arcoblue6,
      muted: const Color(0xFF0E2A5E),
      foreground: const Color(0xFFFFFFFF),
    ),
    accent: OiColorSwatch(
      base: const Color(0xFF8D4EDA),
      light: const Color(0xFFA871E3),
      dark: const Color(0xFF722ED1),
      muted: const Color(0xFF2A1158),
      foreground: const Color(0xFFFFFFFF),
    ),
    success: OiColorSwatch(
      base: const Color(0xFF27C346),
      light: const Color(0xFF59D97C),
      dark: _green6,
      muted: const Color(0xFF0A3A15),
      foreground: const Color(0xFFFFFFFF),
    ),
    warning: OiColorSwatch(
      base: const Color(0xFFFF9A2E),
      light: const Color(0xFFFFB65D),
      dark: _orange6,
      muted: const Color(0xFF3D2600),
      foreground: const Color(0xFFFFFFFF),
    ),
    error: OiColorSwatch(
      base: const Color(0xFFF76560),
      light: const Color(0xFFFA9088),
      dark: _red6,
      muted: const Color(0xFF4D1418),
      foreground: const Color(0xFFFFFFFF),
    ),
    info: OiColorSwatch(
      base: const Color(0xFF57A9FB),
      light: const Color(0xFF7CC0FC),
      dark: _blue6,
      muted: const Color(0xFF0E2B4D),
      foreground: const Color(0xFFFFFFFF),
    ),

    // Dark surfaces — Arco dark bg scale
    background: _darkBg1,
    surface: _darkBg2,
    surfaceHover: _darkBg3,
    surfaceActive: _darkBg4,
    surfaceSubtle: _darkBg1,
    overlay: const Color(0x99000000),

    // Dark text — Arco uses white at varying opacities
    text: const Color(0xE6FFFFFF), // 90%
    textSubtle: const Color(0xB3FFFFFF), // 70%
    textMuted: const Color(0x80FFFFFF), // 50%
    textInverse: _gray10,
    textOnPrimary: const Color(0xFFFFFFFF),

    // Dark borders
    border: const Color(0xFF333335),
    borderSubtle: const Color(0xFF2A2A2C),
    borderFocus: _arcoblue5,
    borderError: _red6,

    // Glass
    glassBackground: const Color(0x33FFFFFF),
    glassBorder: const Color(0x1AFFFFFF),

    // Dark chart palette — lighter variants
    chart: const [
      Color(0xFF4080FF),
      Color(0xFF33D1CC),
      Color(0xFF8D4EDA),
      Color(0xFFF9D060),
      Color(0xFFF76560),
      Color(0xFF57A9FB),
      Color(0xFF27C346),
      Color(0xFFFF9A2E),
    ],
  ),
  textTheme: OiTextTheme.standard(),
  spacing: OiSpacingScale.standard(),
  radius: OiRadiusScale.forPreference(OiRadiusPreference.medium),
  shadows: const OiShadowScale(
    none: [],
    xs: [
      BoxShadow(color: Color(0x29000000), offset: Offset(0, 2), blurRadius: 5),
    ],
    sm: [
      BoxShadow(color: Color(0x29000000), offset: Offset(0, 4), blurRadius: 10),
    ],
    md: [
      BoxShadow(color: Color(0x33000000), offset: Offset(0, 4), blurRadius: 10),
    ],
    lg: [
      BoxShadow(color: Color(0x29000000), offset: Offset(0, 4), blurRadius: 20),
      BoxShadow(color: Color(0x1F000000), offset: Offset(0, 2), blurRadius: 10),
    ],
    xl: [
      BoxShadow(color: Color(0x33000000), offset: Offset(0, 8), blurRadius: 40),
      BoxShadow(color: Color(0x29000000), offset: Offset(0, 4), blurRadius: 20),
    ],
    glass: [BoxShadow(color: Color(0x33000000), blurRadius: 24)],
  ),
  animations: const OiAnimationConfig.standard(),
  effects: OiEffectsTheme.standard(
    primaryColor: _arcoblue5,
    focusColor: _arcoblue5,
  ),
  decoration: OiDecorationTheme.standard(
    primaryColor: _arcoblue5,
    errorColor: _red6,
  ),
  components: OiComponentThemes(
    button: OiButtonThemeData(
      borderRadius: BorderRadius.circular(4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    textInput: OiTextInputThemeData(
      borderRadius: BorderRadius.circular(4),
      borderColor: const Color(0xFF333335),
      focusBorderColor: _arcoblue5,
      validationErrorColor: _red6,
    ),
    card: OiCardThemeData(
      borderRadius: BorderRadius.circular(4),
      padding: const EdgeInsets.all(16),
    ),
    dialog: OiDialogThemeData(borderRadius: BorderRadius.circular(8)),
    toast: OiToastThemeData(borderRadius: BorderRadius.circular(4)),
    tooltip: OiTooltipThemeData(
      borderRadius: BorderRadius.circular(4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    badge: OiBadgeThemeData(borderRadius: BorderRadius.circular(2)),
    tabs: OiTabsThemeData(
      indicatorColor: _arcoblue5,
      activeLabelColor: _arcoblue5,
      inactiveLabelColor: const Color(0x80FFFFFF),
    ),
    progress: OiProgressThemeData(
      height: 4,
      borderRadius: BorderRadius.circular(2),
    ),
    select: OiSelectThemeData(borderRadius: BorderRadius.circular(4)),
    checkbox: const OiCheckboxThemeData(
      size: 16,
      borderRadius: BorderRadius.all(Radius.circular(2)),
      checkedColor: _arcoblue5,
      uncheckedBorderColor: Color(0xFF333335),
    ),
    switchTheme: const OiSwitchThemeData(
      activeTrackColor: _arcoblue5,
      inactiveTrackColor: Color(0xFF333335),
    ),
  ),
);
