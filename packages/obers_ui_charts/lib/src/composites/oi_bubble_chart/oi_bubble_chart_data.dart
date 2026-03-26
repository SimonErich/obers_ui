import 'package:flutter/painting.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart.dart'
    show OiBubbleChart;
import 'package:obers_ui_charts/src/models/oi_cartesian_series.dart';

/// Visual style overrides for an individual bubble point.
///
/// When provided, these values take the highest priority in the
/// theme cascade: point style → series style → chart theme → context theme.
///
/// {@category Composites}
class OiBubblePointStyle {
  /// Creates an [OiBubblePointStyle].
  const OiBubblePointStyle({this.color, this.opacity});

  /// Override color for this single bubble.
  final Color? color;

  /// Override opacity for this single bubble.
  final double? opacity;
}

/// Visual style overrides for an entire series of bubbles.
///
/// These values override chart-theme defaults but are overridden by
/// point-level [OiBubblePointStyle] values.
///
/// {@category Composites}
class OiBubbleSeriesStyle {
  /// Creates an [OiBubbleSeriesStyle].
  const OiBubbleSeriesStyle({this.color, this.opacity, this.borderWidth});

  /// Override color for every bubble in this series.
  final Color? color;

  /// Override opacity for every bubble in this series.
  final double? opacity;

  /// Override border stroke width for every bubble in this series.
  final double? borderWidth;
}

/// A single data point in a bubble chart.
///
/// Each point has an [x] and [y] position plus a [size] value that
/// determines the bubble radius. An optional [label] is used for
/// accessibility narration, and [style] allows per-point color overrides.
///
/// {@category Composites}
class OiBubblePoint {
  /// Creates an [OiBubblePoint].
  const OiBubblePoint({
    required this.x,
    required this.y,
    required this.size,
    this.label,
    this.style,
  });

  /// The x-axis value.
  final double x;

  /// The y-axis value.
  final double y;

  /// The size dimension value, mapped to bubble radius.
  final double size;

  /// An optional human-readable label for this point.
  final String? label;

  /// Optional per-point visual style overrides.
  final OiBubblePointStyle? style;
}

/// A named series of bubble data points.
///
/// Groups related [points] under a [name] that appears in the chart legend.
/// An optional [style] overrides chart-theme colors for all points in
/// this series.
///
/// {@category Composites}
class OiBubbleSeries {
  /// Creates an [OiBubbleSeries].
  const OiBubbleSeries({required this.name, required this.points, this.style});

  /// The display name for this series (shown in legend).
  final String name;

  /// The data points in this series.
  final List<OiBubblePoint> points;

  /// Optional visual style overrides for this series.
  final OiBubbleSeriesStyle? style;
}

/// Configuration for how the size dimension maps to bubble radius.
///
/// {@category Composites}
class OiBubbleSizeConfig {
  /// Creates an [OiBubbleSizeConfig].
  const OiBubbleSizeConfig({
    required this.minRadius,
    required this.maxRadius,
    this.sizeLabel,
  });

  /// The minimum rendered bubble radius in logical pixels.
  final double minRadius;

  /// The maximum rendered bubble radius in logical pixels.
  final double maxRadius;

  /// An optional label describing the size dimension (e.g. "Population").
  final String? sizeLabel;
}

/// The complete data model for an [OiBubbleChart].
///
/// Holds one or more [series] and an optional [sizeConfig] that controls
/// how the size dimension maps to rendered bubble radii.
///
/// {@category Composites}
class OiBubbleChartData {
  /// Creates an [OiBubbleChartData].
  const OiBubbleChartData({required this.series, this.sizeConfig});

  /// The data series to render.
  final List<OiBubbleSeries> series;

  /// Optional configuration for the size dimension.
  final OiBubbleSizeConfig? sizeConfig;
}

// ─────────────────────────────────────────────────────────────────────────────
// Mapper-first series (concept-aligned)
// ─────────────────────────────────────────────────────────────────────────────

/// A mapper-first bubble series that extracts values from domain model `T`.
///
/// This is the concept-aligned series type. Use [OiBubbleSeries] and
/// [OiBubblePoint] for the simpler pre-mapped API.
///
/// {@category Composites}
class OiBubbleSeriesData<T> extends OiCartesianSeries<T> {
  /// Creates an [OiBubbleSeriesData].
  OiBubbleSeriesData({
    required super.id,
    required super.label,
    required super.data,
    required super.xMapper,
    required super.yMapper,
    required this.sizeMapper,
    super.visible,
    super.color,
    super.semanticLabel,
    super.pointLabel,
    super.isMissing,
    super.semanticValue,
    super.yAxisId,
    this.minRadius = 4,
    this.maxRadius = 40,
  });

  /// Extracts the size dimension value from a domain object.
  ///
  /// The returned value is linearly mapped to a rendered bubble radius in the
  /// range [[minRadius], [maxRadius]].
  final num Function(T item) sizeMapper;

  /// The minimum rendered bubble radius in logical pixels. Defaults to 4.
  final double minRadius;

  /// The maximum rendered bubble radius in logical pixels. Defaults to 40.
  final double maxRadius;
}
