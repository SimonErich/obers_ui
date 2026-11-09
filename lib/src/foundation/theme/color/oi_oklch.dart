import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_oklab.dart';

/// A polar Oklab color with lightness, chroma and a hue in degrees.
///
/// [hue] may be null to represent CSS's missing hue. An explicitly authored hue
/// is retained even when chroma is zero; conversion from achromatic RGB instead
/// produces a missing hue. No intermediate lightness or gamut clipping occurs.
///
/// {@category Foundation}
@immutable
class OiOklch {
  /// Creates an authored polar value without gamut mapping.
  const OiOklch({
    required this.lightness,
    required this.chroma,
    required this.hue,
    this.alpha = 1,
  }) : assert(
         lightness >= -double.maxFinite && lightness <= double.maxFinite,
         'Lightness must be finite',
       ),
       assert(
         chroma >= 0 && chroma <= double.maxFinite,
         'Chroma must be finite and nonnegative',
       ),
       assert(
         hue == null || (hue >= -double.maxFinite && hue <= double.maxFinite),
         'Hue must be finite or missing',
       ),
       assert(alpha >= 0 && alpha <= 1, 'Alpha must be in 0–1');

  /// Converts RGB without clipping, marking achromatic hue as missing.
  factory OiOklch.fromColor(Color color) => OiOklab.fromColor(color).toOklch();

  /// Perceptual lightness, conventionally 0–1.
  final double lightness;

  /// Nonnegative chroma; no upper bound is imposed by the color space.
  final double chroma;

  /// Hue in degrees, or null for a missing hue.
  final double? hue;

  /// Opacity in 0–1.
  final double alpha;

  /// Converts to rectangular Oklab, treating a missing hue as zero.
  OiOklab toOklab() {
    final radians = ((hue ?? 0) % 360) * math.pi / 180;
    return OiOklab(
      lightness: lightness,
      axisA: chroma * math.cos(radians),
      axisB: chroma * math.sin(radians),
      alpha: alpha,
    );
  }

  /// Converts to extended sRGB without display gamut mapping or clipping.
  Color toColor() => toOklab().toColor();

  /// Converts to sRGB with explicit channel clipping, not perceptual mapping.
  ///
  /// See [OiOklab.toSrgbClipped]. Raw [toColor] retains out-of-gamut values.
  Color toSrgbClipped() => toOklab().toSrgbClipped();
}

/// Polar coordinates of an Oklab value.
extension OiOklabPolar on OiOklab {
  /// Converts to polar coordinates with CSS's 0.000004 powerless-hue epsilon.
  OiOklch toOklch() {
    final chroma = math.sqrt(a * a + b * b);
    return OiOklch(
      lightness: lightness,
      chroma: chroma,
      hue: chroma <= 0.000004 ? null : (math.atan2(b, a) * 180 / math.pi) % 360,
      alpha: alpha,
    );
  }
}
