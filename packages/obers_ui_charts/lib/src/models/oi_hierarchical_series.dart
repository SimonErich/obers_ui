import 'package:obers_ui_charts/src/models/oi_chart_series.dart';

/// A series for hierarchical chart types such as treemaps and sunbursts.
///
/// Uses mapper functions to extract node identity, parent relationship,
/// value, and label from domain models.
///
/// {@category Models}
class OiHierarchicalSeries<T> extends OiChartSeries<T> {
  /// Creates a hierarchical series with node/parent/value/label mappers.
  OiHierarchicalSeries({
    required super.id,
    required super.label,
    required this.nodeIdMapper,
    required this.parentIdMapper,
    required this.valueMapper,
    required this.nodeLabelMapper,
    super.data,
    super.streamingSource,
    super.visible,
    super.color,
    super.semanticLabel,
  });

  /// Extracts the unique node identifier from a domain object.
  final String Function(T item) nodeIdMapper;

  /// Extracts the parent node identifier (null for root nodes).
  final String? Function(T item) parentIdMapper;

  /// Extracts the numeric value from a domain object.
  final num Function(T item) valueMapper;

  /// Extracts the display label for a node.
  final String Function(T item) nodeLabelMapper;
}
