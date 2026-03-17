import 'dart:math';

import 'package:flutter/painting.dart';

/// Utility class for color manipulation and generation.
///
/// Provides static methods for creating, modifying, and analyzing colors.
///
/// {@category Utils}
class OiColorUtils {
  const OiColorUtils._();

  /// Generates a color from a string (e.g., user name to consistent color).
  ///
  /// The same input always produces the same color. Useful for assigning
  /// avatar colors to users based on their name.
  static Color fromString(String input) {
    var hash = 0;
    for (var i = 0; i < input.length; i++) {
      hash = input.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final hue = (hash % 360).abs().toDouble();
    return HSLColor.fromAHSL(1, hue, 0.65, 0.55).toColor();
  }

  /// Lightens a color by the given [amount] (0.0 to 1.0).
  ///
  /// An [amount] of 0.0 returns the original color; 1.0 returns white.
  static Color lighten(Color color, double amount) {
    assert(
      amount >= 0.0 && amount <= 1.0,
      'Amount must be between 0.0 and 1.0',
    );
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Darkens a color by the given [amount] (0.0 to 1.0).
  ///
  /// An [amount] of 0.0 returns the original color; 1.0 returns black.
  static Color darken(Color color, double amount) {
    assert(
      amount >= 0.0 && amount <= 1.0,
      'Amount must be between 0.0 and 1.0',
    );
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Returns whether the color is considered "light" (for text contrast).
  ///
  /// Uses the W3C relative luminance formula. A color with luminance
  /// above 0.5 is considered light.
  static bool isLight(Color color) {
    return _relativeLuminance(color) > 0.5;
  }

  /// Returns black or white text color based on [background] for contrast.
  ///
  /// Uses relative luminance to determine the best contrasting text color.
  static Color contrastText(Color background) {
    return isLight(background)
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
  }

  /// Blends two colors together with a [ratio].
  ///
  /// A [ratio] of 0.0 returns [first]; a [ratio] of 1.0 returns [second].
  static Color blend(Color first, Color second, double ratio) {
    assert(ratio >= 0.0 && ratio <= 1.0, 'Ratio must be between 0.0 and 1.0');
    final r = first.r + (second.r - first.r) * ratio;
    final g = first.g + (second.g - first.g) * ratio;
    final b = first.b + (second.b - first.b) * ratio;
    final a = first.a + (second.a - first.a) * ratio;
    return Color.from(alpha: a, red: r, green: g, blue: b);
  }

  /// Returns the [color] with adjusted [opacity].
  ///
  /// [opacity] ranges from 0.0 (fully transparent) to 1.0 (fully opaque).
  static Color withOpacity(Color color, double opacity) {
    assert(
      opacity >= 0.0 && opacity <= 1.0,
      'Opacity must be between 0.0 and 1.0',
    );
    return Color.from(
      alpha: opacity,
      red: color.r,
      green: color.g,
      blue: color.b,
    );
  }

  /// Converts a [Color] to hex string (e.g., "#FF5500").
  ///
  /// When [includeAlpha] is true, includes the alpha channel (e.g.,
  /// "#FFFF5500").
  static String toHex(Color color, {bool includeAlpha = false}) {
    final r = _to8Bit(color.r).toRadixString(16).padLeft(2, '0').toUpperCase();
    final g = _to8Bit(color.g).toRadixString(16).padLeft(2, '0').toUpperCase();
    final b = _to8Bit(color.b).toRadixString(16).padLeft(2, '0').toUpperCase();

    if (includeAlpha) {
      final a = _to8Bit(
        color.a,
      ).toRadixString(16).padLeft(2, '0').toUpperCase();
      return '#$a$r$g$b';
    }
    return '#$r$g$b';
  }

  /// Parses a hex string to [Color].
  ///
  /// Accepts formats: "#RGB", "#RRGGBB", "#AARRGGBB",
  /// "RGB", "RRGGBB", "AARRGGBB".
  static Color fromHex(String hex) {
    var cleaned = hex.replaceFirst('#', '');

    if (cleaned.length == 3) {
      cleaned = cleaned.split('').map((c) => '$c$c').join();
    }

    if (cleaned.length == 6) {
      cleaned = 'FF$cleaned';
    }

    final value = int.parse(cleaned, radix: 16);
    final a = (value >> 24) & 0xFF;
    final r = (value >> 16) & 0xFF;
    final g = (value >> 8) & 0xFF;
    final b = value & 0xFF;
    return Color.from(
      alpha: a / 255.0,
      red: r / 255.0,
      green: g / 255.0,
      blue: b / 255.0,
    );
  }

  /// Generates a list of [count] visually distinct colors for charts.
  ///
  /// Colors are evenly distributed around the hue wheel. An optional
  /// [seed] color sets the starting hue.
  static List<Color> generateChartColors(int count, {Color? seed}) {
    if (count <= 0) return [];

    final startHue = seed != null ? HSLColor.fromColor(seed).hue : 210.0;

    return List.generate(count, (i) {
      final hue = (startHue + (360.0 / count) * i) % 360;
      return HSLColor.fromAHSL(1, hue, 0.65, 0.55).toColor();
    });
  }

  /// Converts a normalized color channel (0.0-1.0) to an 8-bit value (0-255).
  static int _to8Bit(double channel) {
    return (channel * 255.0).round().clamp(0, 255);
  }

  /// Computes relative luminance of a [color] per W3C WCAG 2.0.
  static double _relativeLuminance(Color color) {
    double linearize(double channel) {
      return channel <= 0.03928
          ? channel / 12.92
          : pow((channel + 0.055) / 1.055, 2.4).toDouble();
    }

    return 0.2126 * linearize(color.r) +
        0.7152 * linearize(color.g) +
        0.0722 * linearize(color.b);
  }
}
