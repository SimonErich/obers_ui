import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:obers_ui/obers_ui.dart';

// ── TapTap Design System Color Tokens ──────────────────────────────────────

/// Primary palette (Teal/Cyan)
const _primary700 = Color(0xFF00ABB6);
const _primary600 = Color(0xFF15C5CE);
const _primary500 = Color(0xFF47CFD6);
const _primary400 = Color(0xFF7DDDE1);
const _primary300 = Color(0xFFB0EBEC);
// _primary200 = 0xFFDFF7F7, _primary100 = 0xFFEEFCFC, _primary50 = 0xFFF9FFFF
// kept as reference — used inline where needed

/// Auxiliary palette (Orange/Coral)
const _auxiliary700 = Color(0xFFFE632F);
const _auxiliary600 = Color(0xFFFF8156);
const _auxiliary500 = Color(0xFFFFA487);
const _auxiliary400 = Color(0xFFFFC8B6);
const _auxiliary300 = Color(0xFFFFE1D6);
// _auxiliary200 = 0xFFFFF2EE — kept as reference

/// Neutral palette
const _neutral700 = Color(0xFF1F1F1F);
const _neutral600 = Color(0xFF4B4B4B);
const _neutral500 = Color(0xFF8E8E8E);
// _neutral400 = 0xFFCACACa — kept as reference
const _neutral300 = Color(0xFFE1E1E1);
const _neutral200 = Color(0xFFEEEEEE);
const _neutral100 = Color(0xFFF5F5F5);
const _neutral50 = Color(0xFFFAFAFA);

/// Semantic colors
const _danger600 = Color(0xFFF64C4C);
const _info600 = Color(0xFF3B82F6);
const _success600 = Color(0xFF47B881);
const _warning600 = Color(0xFFFFAD0D);

// ── Theme Definitions ──────────────────────────────────────────────────────

/// Blue Danube light theme — TapTap Design System teal brand with
/// precise color mapping, sharp 4px radii, and clean neutral surfaces.
final blueDanubeTheme = OiThemeData(
  brightness: Brightness.light,
  colors: const OiColorScheme(
    // Semantic swatches — manually mapped to exact TapTap palette
    primary: OiColorSwatch(
      base: _primary600,
      light: _primary500,
      dark: _primary700,
      muted: _primary300,
      foreground: Color(0xFFFFFFFF),
    ),
    accent: OiColorSwatch(
      base: _auxiliary600,
      light: _auxiliary500,
      dark: _auxiliary700,
      muted: _auxiliary300,
      foreground: Color(0xFFFFFFFF),
    ),
    success: OiColorSwatch(
      base: _success600,
      light: Color(0xFF6FCF97),
      dark: Color(0xFF2D9F5A),
      muted: Color(0xFFB8E6C8),
      foreground: Color(0xFFFFFFFF),
    ),
    warning: OiColorSwatch(
      base: _warning600,
      light: Color(0xFFFFCA4E),
      dark: Color(0xFFE69500),
      muted: Color(0xFFFFE5A0),
      foreground: Color(0xFFFFFFFF),
    ),
    error: OiColorSwatch(
      base: _danger600,
      light: Color(0xFFFF7878),
      dark: Color(0xFFD63333),
      muted: Color(0xFFFFC0C0),
      foreground: Color(0xFFFFFFFF),
    ),
    info: OiColorSwatch(
      base: _info600,
      light: Color(0xFF6BA3F8),
      dark: Color(0xFF2563EB),
      muted: Color(0xFFB3D1FC),
      foreground: Color(0xFFFFFFFF),
    ),

    // Surfaces — TapTap uses clean whites and very subtle greys
    background: _neutral50,
    surface: Color(0xFFFFFFFF),
    surfaceHover: _neutral100,
    surfaceActive: _neutral300,
    surfaceSubtle: _neutral50,
    overlay: Color(0x66000000),

    // Text — TapTap's neutral scale
    text: _neutral700,
    textSubtle: _neutral600,
    textMuted: _neutral500,
    textInverse: Color(0xFFFFFFFF),
    textOnPrimary: Color(0xFFFFFFFF),

    // Borders — TapTap uses Neutral 300 for default, 200 for subtle
    border: _neutral300,
    borderSubtle: _neutral200,
    borderFocus: _primary600,
    borderError: _danger600,

    // Glass
    glassBackground: Color(0x99FFFFFF),
    glassBorder: Color(0x33FFFFFF),

    // Chart palette — TapTap standard chart colors
    chart: [
      Color(0xFF4887F6),
      Color(0xFF59C3CF),
      Color(0xFFE2635E),
      Color(0xFFF1CD49),
      Color(0xFF47B881),
      Color(0xFFFF8156),
      Color(0xFF8E8E8E),
      Color(0xFFCACACa),
    ],
  ),
  textTheme: OiTextTheme.standard(),
  spacing: OiSpacingScale.standard(),
  // TapTap uses sharp 4px radius — maps to OiRadiusPreference.sharp
  // which gives xs=2, sm=4, md=8, lg=12, xl=16
  // But TapTap buttons use explicit 4px so we use medium preference
  // and override component radii individually
  radius: OiRadiusScale.forPreference(OiRadiusPreference.medium),
  // Shadow scale mapped from TapTap Elevation 1-4
  shadows: const OiShadowScale(
    none: [],
    // Elevation 1: Y1 B1 @2% + Y2 B4 @4%
    xs: [
      BoxShadow(color: Color(0x05000000), offset: Offset(0, 1), blurRadius: 1),
      BoxShadow(color: Color(0x0A000000), offset: Offset(0, 2), blurRadius: 4),
    ],
    // Elevation 2: Y1 B4 @4% + Y4 B10 @8%
    sm: [
      BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 4),
      BoxShadow(color: Color(0x14000000), offset: Offset(0, 4), blurRadius: 10),
    ],
    // Elevation 3: Y2 B20 @4% + Y8 B32 @8%
    md: [
      BoxShadow(color: Color(0x0A000000), offset: Offset(0, 2), blurRadius: 20),
      BoxShadow(color: Color(0x14000000), offset: Offset(0, 8), blurRadius: 32),
    ],
    // Elevation 4: Y8 B20 @6% + Y24 B60 @12%
    lg: [
      BoxShadow(color: Color(0x0F000000), offset: Offset(0, 8), blurRadius: 20),
      BoxShadow(
        color: Color(0x1F000000),
        offset: Offset(0, 24),
        blurRadius: 60,
      ),
    ],
    // Large overlay shadow
    xl: [
      BoxShadow(
        color: Color(0x29000000),
        offset: Offset(0, 16),
        blurRadius: 48,
      ),
      BoxShadow(color: Color(0x14000000), offset: Offset(0, 8), blurRadius: 24),
    ],
    glass: [BoxShadow(color: Color(0x1A000000), blurRadius: 24)],
  ),
  animations: const OiAnimationConfig.standard(),
  effects: OiEffectsTheme.standard(
    primaryColor: _primary600,
    focusColor: _primary600,
  ),
  decoration: OiDecorationTheme.standard(
    primaryColor: _primary600,
    errorColor: _danger600,
  ),
  // Component-level overrides to match TapTap's exact styling
  components: OiComponentThemes(
    button: OiButtonThemeData(
      borderRadius: BorderRadius.circular(4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 40,
      primaryStyle: const OiButtonVariantStyle(
        background: _primary600,
        backgroundHover: _primary500,
        backgroundPressed: _primary700,
        foreground: Color(0xFFFFFFFF),
      ),
      outlineStyle: const OiButtonVariantStyle(
        border: _neutral300,
        borderHover: _primary600,
        foreground: _neutral700,
      ),
      ghostStyle: const OiButtonVariantStyle(
        backgroundHover: _neutral100,
        backgroundPressed: _neutral300,
        foreground: _neutral700,
      ),
    ),
    textInput: OiTextInputThemeData(
      borderRadius: BorderRadius.circular(4),
      borderColor: _neutral300,
      focusBorderColor: _primary600,
      validationErrorColor: _danger600,
    ),
    card: OiCardThemeData(
      borderRadius: BorderRadius.circular(8),
      padding: const EdgeInsets.all(16),
    ),
    dialog: OiDialogThemeData(borderRadius: BorderRadius.circular(8)),
    toast: OiToastThemeData(borderRadius: BorderRadius.circular(4)),
    tooltip: OiTooltipThemeData(
      borderRadius: BorderRadius.circular(4),
      padding: const EdgeInsets.all(8),
    ),
    badge: OiBadgeThemeData(borderRadius: BorderRadius.circular(4)),
    tabs: const OiTabsThemeData(indicatorColor: _primary600),
    progress: OiProgressThemeData(borderRadius: BorderRadius.circular(10)),
    select: OiSelectThemeData(borderRadius: BorderRadius.circular(4)),
  ),
);

/// Blue Danube dark theme — TapTap-inspired dark variant.
final blueDanubeDarkTheme = OiThemeData(
  brightness: Brightness.dark,
  colors: const OiColorScheme(
    primary: OiColorSwatch(
      base: _primary500,
      light: _primary400,
      dark: _primary600,
      muted: Color(0xFF1A3A3C),
      foreground: Color(0xFFFFFFFF),
    ),
    accent: OiColorSwatch(
      base: _auxiliary500,
      light: _auxiliary400,
      dark: _auxiliary600,
      muted: Color(0xFF3D2A1F),
      foreground: Color(0xFFFFFFFF),
    ),
    success: OiColorSwatch(
      base: Color(0xFF6FCF97),
      light: Color(0xFF8EDCAE),
      dark: _success600,
      muted: Color(0xFF1A3D28),
      foreground: Color(0xFFFFFFFF),
    ),
    warning: OiColorSwatch(
      base: Color(0xFFFFCA4E),
      light: Color(0xFFFFD97A),
      dark: _warning600,
      muted: Color(0xFF3D3118),
      foreground: Color(0xFF1F1F1F),
    ),
    error: OiColorSwatch(
      base: Color(0xFFFF7878),
      light: Color(0xFFFFA0A0),
      dark: _danger600,
      muted: Color(0xFF3D1A1A),
      foreground: Color(0xFFFFFFFF),
    ),
    info: OiColorSwatch(
      base: Color(0xFF6BA3F8),
      light: Color(0xFF8DBAFA),
      dark: _info600,
      muted: Color(0xFF1A2A3D),
      foreground: Color(0xFFFFFFFF),
    ),

    // Dark surfaces
    background: Color(0xFF0F0F12),
    surface: Color(0xFF18181C),
    surfaceHover: Color(0xFF222228),
    surfaceActive: Color(0xFF2C2C34),
    surfaceSubtle: Color(0xFF121216),
    overlay: Color(0x99000000),

    // Dark text
    text: Color(0xFFF5F5F5),
    textSubtle: Color(0xFFCACACa),
    textMuted: Color(0xFF8E8E8E),
    textInverse: _neutral700,
    textOnPrimary: Color(0xFFFFFFFF),

    // Dark borders
    border: Color(0xFF3A3A42),
    borderSubtle: Color(0xFF28282E),
    borderFocus: _primary500,
    borderError: _danger600,

    // Glass
    glassBackground: Color(0x33FFFFFF),
    glassBorder: Color(0x1AFFFFFF),

    // Dark chart palette — slightly brighter for dark backgrounds
    chart: [
      Color(0xFF6BA3F8),
      Color(0xFF7DDDE1),
      Color(0xFFFF7878),
      Color(0xFFFFCA4E),
      Color(0xFF6FCF97),
      Color(0xFFFFA487),
      Color(0xFFCACACa),
      Color(0xFF8E8E8E),
    ],
  ),
  textTheme: OiTextTheme.standard(),
  spacing: OiSpacingScale.standard(),
  radius: OiRadiusScale.forPreference(OiRadiusPreference.medium),
  shadows: const OiShadowScale(
    none: [],
    xs: [
      BoxShadow(color: Color(0x29000000), offset: Offset(0, 1), blurRadius: 2),
    ],
    sm: [
      BoxShadow(color: Color(0x1F000000), offset: Offset(0, 1), blurRadius: 4),
      BoxShadow(color: Color(0x29000000), offset: Offset(0, 4), blurRadius: 10),
    ],
    md: [
      BoxShadow(color: Color(0x1F000000), offset: Offset(0, 2), blurRadius: 20),
      BoxShadow(color: Color(0x29000000), offset: Offset(0, 8), blurRadius: 32),
    ],
    lg: [
      BoxShadow(color: Color(0x29000000), offset: Offset(0, 8), blurRadius: 20),
      BoxShadow(
        color: Color(0x33000000),
        offset: Offset(0, 24),
        blurRadius: 60,
      ),
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
    primaryColor: _primary500,
    focusColor: _primary500,
  ),
  decoration: OiDecorationTheme.standard(
    primaryColor: _primary500,
    errorColor: _danger600,
  ),
  components: OiComponentThemes(
    button: OiButtonThemeData(
      borderRadius: BorderRadius.circular(4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 40,
      primaryStyle: const OiButtonVariantStyle(
        background: _primary500,
        backgroundHover: _primary400,
        backgroundPressed: _primary600,
        foreground: Color(0xFFFFFFFF),
      ),
      outlineStyle: const OiButtonVariantStyle(
        border: Color(0xFF3A3A42),
        borderHover: _primary500,
        foreground: Color(0xFFF5F5F5),
      ),
      ghostStyle: const OiButtonVariantStyle(
        backgroundHover: Color(0xFF222228),
        backgroundPressed: Color(0xFF2C2C34),
        foreground: Color(0xFFF5F5F5),
      ),
    ),
    textInput: OiTextInputThemeData(
      borderRadius: BorderRadius.circular(4),
      borderColor: const Color(0xFF3A3A42),
      focusBorderColor: _primary500,
      validationErrorColor: _danger600,
    ),
    card: OiCardThemeData(
      borderRadius: BorderRadius.circular(8),
      padding: const EdgeInsets.all(16),
    ),
    dialog: OiDialogThemeData(borderRadius: BorderRadius.circular(8)),
    toast: OiToastThemeData(borderRadius: BorderRadius.circular(4)),
    tooltip: OiTooltipThemeData(
      borderRadius: BorderRadius.circular(4),
      padding: const EdgeInsets.all(8),
    ),
    badge: OiBadgeThemeData(borderRadius: BorderRadius.circular(4)),
    tabs: const OiTabsThemeData(indicatorColor: _primary500),
    progress: OiProgressThemeData(borderRadius: BorderRadius.circular(10)),
    select: OiSelectThemeData(borderRadius: BorderRadius.circular(4)),
  ),
);
