import 'package:obers_ui_charts/src/models/oi_chart_series.dart';

/// A series for matrix chart types such as heatmaps and correlation matrices.
///
/// Uses mapper functions to extract row, column, and value from domain models.
///
/// {@category Models}
class OiMatrixSeries<T> extends OiChartSeries<T> {
  /// Creates a matrix series with row/column/value mappers.
  OiMatrixSeries({
    required super.id,
    required super.label,
    required this.rowMapper,
    required this.columnMapper,
    required this.valueMapper,
    super.data,
    super.streamingSource,
    super.visible,
    super.color,
    super.semanticLabel,
  });

  /// Extracts the row identifier from a domain object.
  final dynamic Function(T item) rowMapper;

  /// Extracts the column identifier from a domain object.
  final dynamic Function(T item) columnMapper;

  /// Extracts the cell value from a domain object.
  final num Function(T item) valueMapper;
}
