import 'package:flutter/widgets.dart';

// ---------------------------------------------------------------------------
// Size constants — context-free spacing values on a 4dp grid
//
// Use these when you need compile-time constants without a BuildContext.
// For theme-aware spacing that respects per-theme overrides, prefer
// context.spacing (OiSpacingScale) instead.
//
// Mapping to OiSpacingScale tokens:
//   s4 = xs | s8 = sm | s16 = md | s24 = lg | s32 = xl | s48 = xxl
// ---------------------------------------------------------------------------

/// 0dp — no spacing.
const double s0 = 0;

/// 1dp — hairline / border spacing.
const double s1 = 1;

/// 2dp — sub-grid spacing.
const double s2 = 2;

/// 4dp — matches OiSpacingScale.xs.
const double s4 = 4;

/// 6dp — between xs and sm.
const double s6 = 6;

/// 8dp — maps to OiSpacingScale.sm.
const double s8 = 8;

/// 10dp — compact component spacing.
const double s10 = 10;

/// 12dp — between sm and md.
const double s12 = 12;

/// 14dp — fine-grained spacing.
const double s14 = 14;

/// 16dp — maps to OiSpacingScale.md.
const double s16 = 16;

/// 20dp — between md and lg.
const double s20 = 20;

/// 24dp — maps to OiSpacingScale.lg.
const double s24 = 24;

/// 28dp — between lg and xl.
const double s28 = 28;

/// 32dp — maps to OiSpacingScale.xl.
const double s32 = 32;

/// 36dp — between xl and xxl.
const double s36 = 36;

/// 40dp — generous spacing.
const double s40 = 40;

/// 44dp — touch target intermediate.
const double s44 = 44;

/// 48dp — maps to OiSpacingScale.xxl.
const double s48 = 48;

/// 56dp — large section spacing.
const double s56 = 56;

/// 64dp — major section spacing.
const double s64 = 64;

/// 72dp — hero spacing.
const double s72 = 72;

/// 80dp — extra-large section spacing.
const double s80 = 80;

/// 96dp — page-level spacing.
const double s96 = 96;

/// 128dp — maximum spacing.
const double s128 = 128;

// ---------------------------------------------------------------------------
// Vertical gap widgets (SizedBox with height) — use between column children
// ---------------------------------------------------------------------------

/// A zero-size widget. Alias for SizedBox.shrink.
const SizedBox shrink = SizedBox.shrink();

/// No vertical gap.
const SizedBox gapH0 = SizedBox.shrink();

/// 2dp vertical gap.
const SizedBox gapH2 = SizedBox(height: s2);

/// 4dp vertical gap — maps to OiSpacingScale.xs.
const SizedBox gapH4 = SizedBox(height: s4);

/// 8dp vertical gap — maps to OiSpacingScale.sm.
const SizedBox gapH8 = SizedBox(height: s8);

/// 12dp vertical gap.
const SizedBox gapH12 = SizedBox(height: s12);

/// 16dp vertical gap — maps to OiSpacingScale.md.
const SizedBox gapH16 = SizedBox(height: s16);

/// 20dp vertical gap.
const SizedBox gapH20 = SizedBox(height: s20);

/// 24dp vertical gap — maps to OiSpacingScale.lg.
const SizedBox gapH24 = SizedBox(height: s24);

/// 32dp vertical gap — maps to OiSpacingScale.xl.
const SizedBox gapH32 = SizedBox(height: s32);

/// 48dp vertical gap — maps to OiSpacingScale.xxl.
const SizedBox gapH48 = SizedBox(height: s48);

/// 64dp vertical gap.
const SizedBox gapH64 = SizedBox(height: s64);

// ---------------------------------------------------------------------------
// Horizontal gap widgets (SizedBox with width) — use between row children
// ---------------------------------------------------------------------------

/// No horizontal gap.
const SizedBox gapW0 = SizedBox.shrink();

/// 2dp horizontal gap.
const SizedBox gapW2 = SizedBox(width: s2);

/// 4dp horizontal gap — maps to OiSpacingScale.xs.
const SizedBox gapW4 = SizedBox(width: s4);

/// 8dp horizontal gap — maps to OiSpacingScale.sm.
const SizedBox gapW8 = SizedBox(width: s8);

/// 12dp horizontal gap.
const SizedBox gapW12 = SizedBox(width: s12);

/// 16dp horizontal gap — maps to OiSpacingScale.md.
const SizedBox gapW16 = SizedBox(width: s16);

/// 20dp horizontal gap.
const SizedBox gapW20 = SizedBox(width: s20);

/// 24dp horizontal gap — maps to OiSpacingScale.lg.
const SizedBox gapW24 = SizedBox(width: s24);

/// 32dp horizontal gap — maps to OiSpacingScale.xl.
const SizedBox gapW32 = SizedBox(width: s32);

/// 48dp horizontal gap — maps to OiSpacingScale.xxl.
const SizedBox gapW48 = SizedBox(width: s48);

/// 64dp horizontal gap.
const SizedBox gapW64 = SizedBox(width: s64);

// ---------------------------------------------------------------------------
// EdgeInsets presets — all sides
// ---------------------------------------------------------------------------

/// 4dp padding on all sides.
const EdgeInsets pad4 = EdgeInsets.all(s4);

/// 8dp padding on all sides.
const EdgeInsets pad8 = EdgeInsets.all(s8);

/// 12dp padding on all sides.
const EdgeInsets pad12 = EdgeInsets.all(s12);

/// 16dp padding on all sides.
const EdgeInsets pad16 = EdgeInsets.all(s16);

/// 20dp padding on all sides.
const EdgeInsets pad20 = EdgeInsets.all(s20);

/// 24dp padding on all sides.
const EdgeInsets pad24 = EdgeInsets.all(s24);

/// 32dp padding on all sides.
const EdgeInsets pad32 = EdgeInsets.all(s32);

/// 48dp padding on all sides.
const EdgeInsets pad48 = EdgeInsets.all(s48);

// ---------------------------------------------------------------------------
// EdgeInsets presets — symmetric horizontal
// ---------------------------------------------------------------------------

/// 4dp horizontal padding.
const EdgeInsets padX4 = EdgeInsets.symmetric(horizontal: s4);

/// 8dp horizontal padding.
const EdgeInsets padX8 = EdgeInsets.symmetric(horizontal: s8);

/// 12dp horizontal padding.
const EdgeInsets padX12 = EdgeInsets.symmetric(horizontal: s12);

/// 16dp horizontal padding.
const EdgeInsets padX16 = EdgeInsets.symmetric(horizontal: s16);

/// 24dp horizontal padding.
const EdgeInsets padX24 = EdgeInsets.symmetric(horizontal: s24);

/// 32dp horizontal padding.
const EdgeInsets padX32 = EdgeInsets.symmetric(horizontal: s32);

// ---------------------------------------------------------------------------
// EdgeInsets presets — symmetric vertical
// ---------------------------------------------------------------------------

/// 4dp vertical padding.
const EdgeInsets padY4 = EdgeInsets.symmetric(vertical: s4);

/// 8dp vertical padding.
const EdgeInsets padY8 = EdgeInsets.symmetric(vertical: s8);

/// 12dp vertical padding.
const EdgeInsets padY12 = EdgeInsets.symmetric(vertical: s12);

/// 16dp vertical padding.
const EdgeInsets padY16 = EdgeInsets.symmetric(vertical: s16);

/// 24dp vertical padding.
const EdgeInsets padY24 = EdgeInsets.symmetric(vertical: s24);

/// 32dp vertical padding.
const EdgeInsets padY32 = EdgeInsets.symmetric(vertical: s32);
