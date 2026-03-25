import 'package:obers_ui_charts/src/models/oi_chart_series.dart';

/// A series for polar chart types such as pie, donut, and radar charts.
///
/// Uses mapper functions to extract value and label from domain models.
///
/// {@category Models}
class OiPolarSeries<T> extends OiChartSeries<T> {
  /// Creates a polar series with value/label mappers.
  OiPolarSeries({
    required super.id,
    required super.label,
    required this.valueMapper,
    required this.labelMapper,
    super.data,
    super.streamingSource,
    super.visible,
    super.color,
    super.semanticLabel,
  });

  /// Extracts the numeric value from a domain object.
  final num Function(T item) valueMapper;

  /// Extracts the display label from a domain object.
  final String Function(T item) labelMapper;
}
