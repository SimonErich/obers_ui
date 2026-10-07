import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_oklch.dart';
import 'package:obers_ui/src/foundation/theme/oi_rail_colors.dart';

/// Internal rail recipes with independent neutral, primary and highlight hue.
@internal
abstract final class OiBrandRail {
  /// Derives the dark rail used in both content themes.
  static OiRailColors derive(
    OiOklch primary,
    OiOklch highlight,
    OiOklch tint,
    Brightness brightness,
  ) {
    final dark = brightness == Brightness.dark;
    return OiRailColors(
      surface: OiOklch(
        lightness: dark ? 0.104 : 0.235,
        chroma: dark ? 0.008 : 0.02,
        hue: tint.hue,
        alpha: tint.alpha,
      ).toColor(),
      ink: OiOklch(
        lightness: dark ? 0.705 : 0.785,
        chroma: dark ? 0.01 : 0.012,
        hue: tint.hue,
        alpha: tint.alpha,
      ).toColor(),
      hoverWash: OiOklch(
        lightness: 0.99,
        chroma: 0,
        hue: 0,
        alpha: dark ? 0.06 : 0.08,
      ).toColor(),
      line: const OiOklch(
        lightness: 0.99,
        chroma: 0,
        hue: 0,
        alpha: 0.07,
      ).toColor(),
      active: OiOklch(
        lightness: dark ? 0.745 : 0.805,
        chroma: (primary.chroma * (dark ? 0.8 : 0.6)).clamp(0.02, 0.07),
        hue: primary.hue,
        alpha: primary.alpha,
      ).toColor(),
      onActive: OiOklch(
        lightness: dark ? 0.18 : 0.215,
        chroma: math.min(primary.chroma, dark ? 0.03 : 0.035),
        hue: primary.hue,
        alpha: primary.alpha,
      ).toColor(),
      badge: OiOklch(
        lightness: math.max(highlight.lightness, 0.74),
        chroma: highlight.chroma,
        hue: highlight.hue,
        alpha: highlight.alpha,
      ).toColor(),
      onBadge: OiOklch(
        lightness: 0.24,
        chroma: math.min(highlight.chroma, 0.04),
        hue: highlight.hue,
        alpha: highlight.alpha,
      ).toColor(),
    );
  }
}
