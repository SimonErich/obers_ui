import 'package:obers_ui_charts/src/models/oi_chart_series.dart';

/// A series for cartesian (x/y) chart types such as line, bar, area, and
/// scatter charts.
///
/// Uses mapper functions to extract x and y values from domain models.
///
/// ```dart
/// OiCartesianSeries<SalesRecord>(
///   id: 'revenue',
///   label: 'Revenue',
///   data: salesRecords,
///   xMapper: (r) => r.date,
///   yMapper: (r) => r.amount,
/// )
/// ```
///
/// {@category Models}
class OiCartesianSeries<T> extends OiChartSeries<T> {
  /// Creates a cartesian series with x/y mappers.
  OiCartesianSeries({
    required super.id,
    required super.label,
    required this.xMapper,
    required this.yMapper,
    super.data,
    super.streamingSource,
    super.visible,
    super.color,
    super.semanticLabel,
    this.pointLabel,
    this.isMissing,
    this.semanticValue,
    this.yAxisId,
  });

  /// Extracts the x-axis value from a domain object.
  final dynamic Function(T item) xMapper;

  /// Extracts the y-axis value from a domain object.
  final num Function(T item) yMapper;

  /// Optional: extracts a label for individual data points.
  final String Function(T item)? pointLabel;

  /// Optional: returns true if the data point is missing/null.
  final bool Function(T item)? isMissing;

  /// Optional: provides an accessible value description for a data point.
  final String Function(T item)? semanticValue;

  /// Optional: ID of the y-axis this series binds to (for multi-axis charts).
  final String? yAxisId;
}
