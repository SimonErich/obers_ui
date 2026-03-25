import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';

/// Maps numeric values to colors for matrix/heatmap charts.
///
/// {@category Models}
@immutable
class OiColorScale {
  /// Creates an [OiColorScale] with a custom resolver.
  const OiColorScale._({
    required this.min,
    required this.max,
    required Color Function(num value, double min, double max) resolver,
  }) : _resolver = resolver;

  /// Creates a linear color scale interpolating between [minColor] and
  /// [maxColor] over the range [min]–[max].
  factory OiColorScale.linear({
    required Color minColor,
    required Color maxColor,
    required double min,
    required double max,
  }) {
    return OiColorScale._(
      min: min,
      max: max,
      resolver: (value, lo, hi) {
        final t = hi == lo ? 0.5 : ((value - lo) / (hi - lo)).clamp(0.0, 1.0);
        return Color.lerp(minColor, maxColor, t)!;
      },
    );
  }

  /// Creates a gradient color scale with multiple [colors] and [stops]
  /// over the range [min]–[max].
  ///
  /// [stops] must have the same length as [colors] and be in ascending
  /// order from 0.0 to 1.0.
  factory OiColorScale.gradient({
    required List<Color> colors,
    required List<double> stops,
    required double min,
    required double max,
  }) {
    assert(
      colors.length == stops.length,
      'colors and stops must have the same length',
    );
    assert(colors.length >= 2, 'At least 2 colors are required');
    return OiColorScale._(
      min: min,
      max: max,
      resolver: (value, lo, hi) {
        final t = hi == lo ? 0.5 : ((value - lo) / (hi - lo)).clamp(0.0, 1.0);
        // Find the two stops that bracket t.
        for (var i = 0; i < stops.length - 1; i++) {
          if (t <= stops[i + 1]) {
            final segT = stops[i + 1] == stops[i]
                ? 0.0
                : (t - stops[i]) / (stops[i + 1] - stops[i]);
            return Color.lerp(colors[i], colors[i + 1], segT)!;
          }
        }
        return colors.last;
      },
    );
  }

  /// The minimum domain value.
  final double min;

  /// The maximum domain value.
  final double max;

  final Color Function(num value, double min, double max) _resolver;

  /// Resolves a domain [value] to a color.
  Color resolve(num value) => _resolver(value, min, max);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiColorScale && other.min == min && other.max == max;
  }

  @override
  int get hashCode => Object.hash(min, max);
}
