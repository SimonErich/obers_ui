import 'package:obers_ui_charts/src/models/oi_cartesian_series.dart';

/// A single data series for an area chart.
///
/// Extends [OiCartesianSeries] with area-specific properties such as fill
/// opacity, an optional line stroke, and stacking group assignment.
///
/// {@category Composites}
class OiAreaSeries<T> extends OiCartesianSeries<T> {
  /// Creates an [OiAreaSeries].
  OiAreaSeries({
    required super.id,
    required super.label,
    required List<T> data,
    required super.xMapper,
    required super.yMapper,
    super.visible,
    super.color,
    super.semanticLabel,
    this.fillOpacity = 0.3,
    this.showLine = true,
    this.stackGroup,
  }) : super(data: data);

  /// The opacity of the filled area below the line. Defaults to `0.3`.
  final double fillOpacity;

  /// Whether to draw a line stroke on top of the filled area. Defaults to
  /// `true`.
  final bool showLine;

  /// Optional stacking group identifier.
  ///
  /// Series that share the same [stackGroup] are stacked cumulatively on top
  /// of one another. When `null` the series is drawn independently.
  final String? stackGroup;
}
