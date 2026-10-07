import 'dart:math' as math;
import 'dart:ui' show ColorSpace;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// A D65 Oklab color, retaining out-of-gamut coordinates for color arithmetic.
///
/// [lightness] is conventionally 0–1; [a] and [b] are signed opponent axes.
/// This is a numeric value, not a CSS parser: intermediate values are not
/// clamped. Coordinates must be finite and [alpha] must be in 0–1.
/// Uses the [CSS Color 4 conversion matrices](https://www.w3.org/TR/css-color-4/#color-conversion-code).
///
/// {@category Foundation}
@immutable
class OiOklab {
  /// Creates Oklab from opponent [axisA]/[axisB], without gamut mapping.
  const OiOklab({
    required this.lightness,
    required double axisA,
    required double axisB,
    this.alpha = 1,
  }) : a = axisA,
       b = axisB,
       assert(
         lightness >= -double.maxFinite && lightness <= double.maxFinite,
         'Lightness must be finite',
       ),
       assert(
         axisA >= -double.maxFinite && axisA <= double.maxFinite,
         'The a axis must be finite',
       ),
       assert(
         axisB >= -double.maxFinite && axisB <= double.maxFinite,
         'The b axis must be finite',
       ),
       assert(alpha >= 0 && alpha <= 1, 'Alpha must be in 0–1');

  /// Converts a Flutter color without clipping its RGB coordinates.
  ///
  /// Uses each RGB space's D65 matrix and sign-preserving transfer functions
  /// from CSS Color 4, section 19, including direct Display P3 conversion.
  factory OiOklab.fromColor(Color color) {
    final r = _linear(color.r);
    final g = _linear(color.g);
    final b = _linear(color.b);
    if (color.colorSpace == ColorSpace.displayP3) {
      return OiOklab.fromXyzD65(
        x: 608311 / 1250200 * r + 189793 / 714400 * g + 198249 / 1000160 * b,
        y: 35783 / 156275 * r + 247089 / 357200 * g + 198249 / 2500400 * b,
        z: 32229 / 714400 * g + 5220557 / 5000800 * b,
        alpha: color.a,
      );
    }
    final x = 506752 / 1228815 * r + 87881 / 245763 * g + 12673 / 70218 * b;
    final y = 87098 / 409605 * r + 175762 / 245763 * g + 12673 / 175545 * b;
    final z = 7918 / 409605 * r + 87881 / 737289 * g + 1001167 / 1053270 * b;
    return OiOklab.fromXyzD65(x: x, y: y, z: z, alpha: color.a);
  }

  /// Converts unbounded finite XYZ-D65 coordinates with reference white Y=1.
  ///
  /// Signed coordinates are valid numeric intermediates and are not clipped.
  factory OiOklab.fromXyzD65({
    required double x,
    required double y,
    required double z,
    double alpha = 1,
  }) {
    final l = _cubeRoot(
      0.819022437996703 * x + 0.3619062600528904 * y - 0.1288737815209879 * z,
    );
    final m = _cubeRoot(
      0.0329836539323885 * x + 0.9292868615863434 * y + 0.0361446663506424 * z,
    );
    final s = _cubeRoot(
      0.0481771893596242 * x + 0.2642395317527308 * y + 0.6335478284694309 * z,
    );
    return OiOklab(
      lightness:
          0.210454268309314 * l +
          0.7936177747023054 * m -
          0.0040720430116193 * s,
      axisA:
          1.9779985324311684 * l - 2.42859224204858 * m + 0.450593709617411 * s,
      axisB:
          0.0259040424655478 * l +
          0.7827717124575296 * m -
          0.8086757549230774 * s,
      alpha: alpha,
    );
  }

  /// Perceptual lightness, conventionally 0–1.
  final double lightness;

  /// Green (negative) to red (positive) opponent coordinate.
  final double a;

  /// Blue (negative) to yellow (positive) opponent coordinate.
  final double b;

  /// Opacity in 0–1.
  final double alpha;

  /// Converts to sRGB and explicitly clips each channel to 0–1.
  ///
  /// This reproduces channel clipping, not CSS's perceptual gamut mapping
  /// algorithms. Use [toColor] when further color arithmetic is required.
  Color toSrgbClipped() => toColor().withValues(colorSpace: ColorSpace.sRGB);

  /// Converts to extended sRGB, retaining negative and greater-than-one channels.
  ///
  /// This performs conversion only, never display gamut mapping or clipping.
  Color toColor() {
    final xyz = toXyzD65();
    return Color.from(
      alpha: alpha,
      red: _encoded(
        12831 / 3959 * xyz.x - 329 / 214 * xyz.y - 1974 / 3959 * xyz.z,
      ),
      green: _encoded(
        -851781 / 878810 * xyz.x +
            1648619 / 878810 * xyz.y +
            36519 / 878810 * xyz.z,
      ),
      blue: _encoded(
        705 / 12673 * xyz.x - 2585 / 12673 * xyz.y + 705 / 667 * xyz.z,
      ),
      colorSpace: ColorSpace.extendedSRGB,
    );
  }

  /// Converts to XYZ-D65 with reference white Y=1, without compositing alpha.
  ///
  /// XYZ is unbounded; signed intermediate coordinates are retained.
  ({double x, double y, double z}) toXyzD65() {
    final l = _cube(
      lightness + 0.3963377773761749 * a + 0.2158037573099136 * b,
    );
    final m = _cube(
      lightness - 0.1055613458156586 * a - 0.0638541728258133 * b,
    );
    final s = _cube(
      lightness - 0.0894841775298119 * a - 1.2914855480194092 * b,
    );
    final x =
        1.2268798758459243 * l -
        0.5578149944602171 * m +
        0.2813910456659647 * s;
    final y =
        -0.0405757452148008 * l +
        1.112286803280317 * m -
        0.0717110580655164 * s;
    final z =
        -0.0763729366746601 * l -
        0.4214933324022432 * m +
        1.5869240198367816 * s;
    return (x: x, y: y, z: z);
  }

  /// Uncomposited CIE Y luminance with D65 reference white normalized to one.
  ///
  /// Alpha does not change a color's luminance; composite before assessing
  /// translucent display contrast. Out-of-gamut values are not clipped.
  double get relativeLuminance => toXyzD65().y;

  /// Scales XYZ by [factor], retaining opacity and hue for positive factors.
  ///
  /// Oklab is homogeneous: multiplying its axes by the cube root of [factor]
  /// exactly scales XYZ. No gamut mapping occurs. Throws [ArgumentError] for
  /// negative or nonfinite factors; zero returns black at the same opacity.
  OiOklab scaleLuminance(double factor) {
    if (!factor.isFinite || factor < 0) {
      throw ArgumentError.value(
        factor,
        'factor',
        'Must be finite and nonnegative',
      );
    }
    final scale = _cubeRoot(factor);
    return OiOklab(
      lightness: lightness * scale,
      axisA: a * scale,
      axisB: b * scale,
      alpha: alpha,
    );
  }

  static double _encoded(double value) => value.abs() <= 0.0031308
      ? 12.92 * value
      : value.sign * (1.055 * math.pow(value.abs(), 1 / 2.4) - 0.055);
  static double _cube(double value) => value * value * value;
  static double _linear(double value) => value.abs() <= 0.04045
      ? value / 12.92
      : value.sign * math.pow((value.abs() + 0.055) / 1.055, 2.4).toDouble();

  static double _cubeRoot(double value) =>
      value.sign * math.pow(value.abs(), 1 / 3).toDouble();
}
