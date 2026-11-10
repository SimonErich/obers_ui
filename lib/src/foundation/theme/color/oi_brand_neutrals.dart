import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_oklch.dart';
import 'package:obers_ui/src/foundation/theme/oi_ink_colors.dart';
import 'package:obers_ui/src/foundation/theme/oi_surface_colors.dart';

/// Internal neutral recipes; relative colors retain tint hue and alpha.
@internal
abstract final class OiBrandNeutrals {
  /// Derives neutral text and icon inks.
  static OiInkColors inks(OiOklch tint, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return OiInkColors(
      primary: _neutral(tint, dark ? 0.955 : 0.235, dark ? 0.004 : 0.016),
      muted: _neutral(tint, dark ? 0.775 : 0.47, dark ? 0.01 : 0.014),
      subtle: _neutral(tint, dark ? 0.615 : 0.6, 0.01),
      onInverse: _neutral(tint, dark ? 0.215 : 0.975, dark ? 0.012 : 0.004),
      inverseMuted: _neutral(tint, dark ? 0.455 : 0.765, dark ? 0.012 : 0.01),
    );
  }

  /// Derives the info fill, not an entire status family.
  static Color info(OiOklch tint, Brightness brightness) =>
      _neutral(tint, brightness == Brightness.dark ? 0.62 : 0.6, 0.012);

  /// Derives the neutral-tinted info soft surface.
  static Color infoSoft(OiOklch tint, Brightness brightness) => _neutral(
    tint,
    brightness == Brightness.dark ? 0.252 : 0.958,
    brightness == Brightness.dark ? 0.008 : 0.005,
  );

  static Color _neutral(OiOklch tint, double lightness, double chroma) =>
      OiOklch(
        lightness: lightness,
        chroma: chroma,
        hue: tint.hue,
        alpha: tint.alpha,
      ).toColor();

  /// Derives surfaces without clipping or compositing translucent washes.
  static OiSurfaceColors surfaces(OiOklch tint, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    Color neutral(double lightness, double chroma, [double? alpha]) => OiOklch(
      lightness: lightness,
      chroma: chroma,
      hue: tint.hue,
      alpha: alpha ?? tint.alpha,
    ).toColor();
    return OiSurfaceColors(
      canvas: neutral(dark ? 0.148 : 0.965, dark ? 0.006 : 0.005),
      sheet: neutral(dark ? 0.192 : 0.997, dark ? 0.007 : 0.0015),
      well: neutral(dark ? 0.168 : 0.976, dark ? 0.007 : 0.004),
      overlaySurface: neutral(dark ? 0.228 : 0.999, dark ? 0.008 : 0.001),
      line: neutral(dark ? 0.262 : 0.924, dark ? 0.008 : 0.006),
      lineStrong: neutral(dark ? 0.322 : 0.868, dark ? 0.01 : 0.008),
      border: neutral(dark ? 0.575 : 0.63, dark ? 0.012 : 0.01),
      hoverWash: neutral(
        dark ? 0.96 : 0.3,
        dark ? 0.01 : 0.03,
        dark ? 0.06 : 0.05,
      ),
      pressedWash: neutral(
        dark ? 0.96 : 0.3,
        dark ? 0.01 : 0.03,
        dark ? 0.1 : 0.085,
      ),
      scrim: neutral(dark ? 0.08 : 0.2, dark ? 0.01 : 0.02, dark ? 0.62 : 0.32),
      inverse: neutral(dark ? 0.925 : 0.25, dark ? 0.005 : 0.014),
    );
  }
}
