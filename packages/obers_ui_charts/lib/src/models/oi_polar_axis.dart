import 'package:flutter/foundation.dart';

/// Direction of angle increase in a polar chart.
///
/// {@category Models}
enum OiPolarDirection {
  /// Angles increase clockwise (default for most charts).
  clockwise,

  /// Angles increase counter-clockwise.
  counterClockwise,
}

/// Angle axis configuration for polar charts.
///
/// Controls the angular dimension: start angle, direction, labels, and ticks.
///
/// {@category Models}
@immutable
class OiPolarAngleAxis {
  /// Creates an [OiPolarAngleAxis].
  const OiPolarAngleAxis({
    this.label,
    this.startAngle = -90,
    this.direction = OiPolarDirection.clockwise,
    this.formatter,
    this.showLabels = true,
    this.showGrid = true,
  });

  /// Axis title label.
  final String? label;

  /// Start angle in degrees. -90 = top (12 o'clock position).
  final double startAngle;

  /// Direction of angle increase.
  final OiPolarDirection direction;

  /// Custom formatter for angle tick labels.
  final String Function(double angleDegrees)? formatter;

  /// Whether to show angle labels around the perimeter.
  final bool showLabels;

  /// Whether to show radial grid lines from center to edge.
  final bool showGrid;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiPolarAngleAxis &&
        other.label == label &&
        other.startAngle == startAngle &&
        other.direction == direction &&
        other.showLabels == showLabels &&
        other.showGrid == showGrid;
  }

  @override
  int get hashCode =>
      Object.hash(label, startAngle, direction, showLabels, showGrid);
}

/// Radius axis configuration for polar charts.
///
/// Controls the radial dimension: min/max values, ticks, and labels.
///
/// {@category Models}
@immutable
class OiPolarRadiusAxis {
  /// Creates an [OiPolarRadiusAxis].
  const OiPolarRadiusAxis({
    this.label,
    this.min,
    this.max,
    this.tickCount = 5,
    this.formatter,
    this.showLabels = true,
    this.showGrid = true,
  });

  /// Axis title label.
  final String? label;

  /// Minimum radius value. When null, derived from data.
  final double? min;

  /// Maximum radius value. When null, derived from data.
  final double? max;

  /// Number of concentric circle grid lines.
  final int tickCount;

  /// Custom formatter for radius tick labels.
  final String Function(double value)? formatter;

  /// Whether to show radius value labels along the axis.
  final bool showLabels;

  /// Whether to show concentric circle grid lines.
  final bool showGrid;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiPolarRadiusAxis &&
        other.label == label &&
        other.min == min &&
        other.max == max &&
        other.tickCount == tickCount &&
        other.showLabels == showLabels &&
        other.showGrid == showGrid;
  }

  @override
  int get hashCode =>
      Object.hash(label, min, max, tickCount, showLabels, showGrid);
}
