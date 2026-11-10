import 'dart:ui' show ColorSpace;

import 'package:flutter/painting.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_hue_interpolation.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_oklab.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_oklch.dart';

/// CSS-compatible interpolation of two numeric colors without gamut mapping.
///
/// Values remain in their interpolation space. Hue defaults to the shorter arc;
/// lightness and chroma, but not hue, are premultiplied by alpha.
/// See [CSS Color 4 interpolation](https://www.w3.org/TR/css-color-4/#interpolation)
/// and [CSS Color 5 percentages](https://www.w3.org/TR/css-color-5/#color-mix).
///
/// {@category Foundation}
abstract final class OiColorMix {
  /// Mixes gamma-encoded sRGB with CSS premultiplied alpha and percentages.
  ///
  /// Returns extended sRGB without clipping; Display P3 inputs are converted
  /// before mixing. Percentage semantics and validation match [oklch].
  static Color srgb(
    Color first,
    Color second, {
    double? firstPercent,
    double? secondPercent,
  }) {
    final weights = _weights(firstPercent, secondPercent);
    final blend = _premultiplied(
      first.a,
      second.a,
      weights.first,
      weights.second,
    );
    final rgb1 = first.withValues(colorSpace: ColorSpace.extendedSRGB);
    final rgb2 = second.withValues(colorSpace: ColorSpace.extendedSRGB);
    return Color.from(
      alpha: blend.alpha * weights.opacity,
      red: rgb1.r * blend.first + rgb2.r * blend.second,
      green: rgb1.g * blend.first + rgb2.g * blend.second,
      blue: rgb1.b * blend.first + rgb2.b * blend.second,
      colorSpace: ColorSpace.extendedSRGB,
    );
  }

  /// Mixes Oklab coordinates using CSS premultiplied alpha and percentages.
  ///
  /// Percentage semantics and validation match [oklch]; no gamut mapping occurs.
  static OiOklab oklab(
    OiOklab first,
    OiOklab second, {
    double? firstPercent,
    double? secondPercent,
  }) {
    final weights = _weights(firstPercent, secondPercent);
    final blend = _premultiplied(
      first.alpha,
      second.alpha,
      weights.first,
      weights.second,
    );
    return OiOklab(
      lightness:
          first.lightness * blend.first + second.lightness * blend.second,
      axisA: first.a * blend.first + second.a * blend.second,
      axisB: first.b * blend.first + second.b * blend.second,
      alpha: blend.alpha * weights.opacity,
    );
  }

  /// Mixes OKLCH colors, carrying forward a missing hue.
  ///
  /// Omitted percentages default to 50/50, or complement the supplied value.
  /// A total below 100 reduces opacity; a larger total is normalized.
  /// Throws [ArgumentError] for percentages outside 0–100 or nonfinite values.
  /// A zero total returns a transparent midpoint, as CSS Color 5 specifies.
  static OiOklch oklch(
    OiOklch first,
    OiOklch second, {
    double? firstPercent,
    double? secondPercent,
    OiHueInterpolation hueInterpolation = OiHueInterpolation.shorter,
  }) {
    final weights = _weights(firstPercent, secondPercent);
    final blend = _premultiplied(
      first.alpha,
      second.alpha,
      weights.first,
      weights.second,
    );
    return OiOklch(
      lightness:
          first.lightness * blend.first + second.lightness * blend.second,
      chroma: first.chroma * blend.first + second.chroma * blend.second,
      hue: first.hue == null && second.hue == null
          ? null
          : hueInterpolation.interpolate(
              first.hue ?? second.hue!,
              second.hue ?? first.hue!,
              weights.second,
            ),
      alpha: blend.alpha * weights.opacity,
    );
  }

  static ({double first, double second, double opacity}) _weights(
    double? firstPercent,
    double? secondPercent,
  ) {
    for (final percent in [firstPercent, secondPercent]) {
      if (percent != null &&
          (!percent.isFinite || percent < 0 || percent > 100)) {
        throw ArgumentError.value(
          percent,
          'percent',
          'Must be finite and in 0–100',
        );
      }
    }
    final first =
        firstPercent ?? (secondPercent == null ? 50 : 100 - secondPercent);
    final second = secondPercent ?? (100 - first);
    final total = first + second;
    if (total == 0) return (first: 0.5, second: 0.5, opacity: 0);
    final firstWeight = first / total;
    return (
      first: firstWeight,
      second: 1 - firstWeight,
      opacity: (total / 100).clamp(0, 1),
    );
  }

  static ({double first, double second, double alpha}) _premultiplied(
    double firstAlpha,
    double secondAlpha,
    double firstWeight,
    double secondWeight,
  ) {
    final alpha = firstAlpha * firstWeight + secondAlpha * secondWeight;
    final divisor = alpha == 0 ? 1.0 : alpha;
    return (
      first: firstAlpha * firstWeight / divisor,
      second: secondAlpha * secondWeight / divisor,
      alpha: alpha,
    );
  }
}
