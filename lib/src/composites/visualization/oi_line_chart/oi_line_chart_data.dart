import 'package:flutter/painting.dart';

/// A single data point in a line chart.
///
/// {@category Composites}
class OiLinePoint {
  /// Creates an [OiLinePoint].
  const OiLinePoint({required this.x, required this.y, this.label});

  /// The x-axis value.
  final double x;

  /// The y-axis value.
  final double y;

  /// An optional label for this point (used in accessibility narration).
  final String? label;
}

/// A named series of line data points.
///
/// Groups related [points] under a [label] that appears in the chart legend.
///
/// {@category Composites}
class OiLineSeries {
  /// Creates an [OiLineSeries].
  const OiLineSeries({
    required this.label,
    required this.points,
    this.color,
    this.strokeWidth = 2.0,
    this.dashed = false,
    this.fill = false,
    this.fillOpacity = 0.15,
  });

  /// The display name for this series (shown in legend).
  final String label;

  /// The data points in this series, ordered by x value.
  final List<OiLinePoint> points;

  /// An optional color override.
  final Color? color;

  /// The stroke width of the line.
  final double strokeWidth;

  /// Whether to draw the line with a dashed pattern.
  final bool dashed;

  /// Whether to fill the area below the line (area chart).
  final bool fill;

  /// The opacity of the area fill when [fill] is `true`.
  final double fillOpacity;
}
