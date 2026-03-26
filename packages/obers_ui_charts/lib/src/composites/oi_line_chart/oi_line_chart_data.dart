import 'package:flutter/painting.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_formatters.dart';
import 'package:obers_ui_charts/src/models/oi_cartesian_series.dart';
import 'package:obers_ui_charts/src/composites/oi_line_chart/oi_line_chart.dart'
    show OiLineChart;

/// The interpolation mode of an [OiLineChart].
///
/// Controls how data points are connected.
///
/// {@category Composites}
enum OiLineChartMode {
  /// Data points are connected with straight line segments.
  straight,

  /// Data points are connected with horizontal-then-vertical step segments,
  /// producing a staircase shape.
  stepped,

  /// Data points are connected with smooth Catmull-Rom curve interpolation.
  smooth,
}

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

// ─────────────────────────────────────────────────────────────────────────────
// Mapper-first series (concept-aligned)
// ─────────────────────────────────────────────────────────────────────────────

/// How missing data points are rendered in a line chart.
///
/// {@category Composites}
enum OiLineMissingValueBehavior {
  /// Break the line at missing values, creating a visual gap.
  gap,

  /// Skip missing values and connect neighboring valid points.
  connect,

  /// Render missing y-values as zero.
  zero,

  /// Linearly interpolate between neighboring valid values.
  interpolate,
}

/// A mapper-first line series that extracts values from domain model `T`.
///
/// This is the concept-aligned series type. Use [OiLineSeries] for the
/// simpler pre-mapped API.
///
/// {@category Composites}
class OiLineSeriesData<T> extends OiCartesianSeries<T> {
  /// Creates an [OiLineSeriesData].
  OiLineSeriesData({
    required super.id,
    required super.label,
    required super.data,
    required super.xMapper,
    required super.yMapper,
    super.visible,
    super.color,
    super.semanticLabel,
    super.pointLabel,
    super.isMissing,
    super.semanticValue,
    super.yAxisId,
    this.interpolation = OiLineChartMode.straight,
    this.missingValueBehavior = OiLineMissingValueBehavior.gap,
    this.showLine = true,
    this.showMarkers = false,
    this.showDataLabels = false,
    this.fillBelow = false,
    this.fillOpacity = 0.15,
    this.smoothing,
    this.pointColor,
    this.valueFormatter,
    this.xFormatter,
  });

  /// Interpolation mode for connecting data points.
  final OiLineChartMode interpolation;

  /// How missing values are handled visually.
  final OiLineMissingValueBehavior missingValueBehavior;

  /// Whether to draw the line stroke.
  final bool showLine;

  /// Whether to show point markers.
  final bool showMarkers;

  /// Whether to show value labels at each data point.
  final bool showDataLabels;

  /// Whether to fill the area below the line.
  final bool fillBelow;

  /// Opacity of the area fill when [fillBelow] is true.
  final double fillOpacity;

  /// Spline tension (0.0–1.0) for smooth interpolation.
  final double? smoothing;

  /// Dynamic color callback for individual points.
  final Color? Function(T item)? pointColor;

  /// Custom formatter for tooltip values.
  final OiTooltipValueFormatter? valueFormatter;

  /// Custom formatter for x-axis labels.
  final OiAxisFormatter<Object>? xFormatter;
}
