import 'package:obers_ui_charts/src/models/oi_chart_series.dart';

/// A series for flow chart types such as Sankey diagrams and alluvial charts.
///
/// Unlike other series types, flow series have separate node and link
/// collections with their own mapper functions.
///
/// {@category Models}
class OiFlowSeries<TNode, TLink> extends OiChartSeries<TNode> {
  /// Creates a flow series with node and link mappers.
  OiFlowSeries({
    required super.id,
    required super.label,
    required super.data,
    required this.links,
    required this.nodeIdMapper,
    required this.nodeLabelMapper,
    required this.sourceIdMapper,
    required this.targetIdMapper,
    required this.linkValueMapper,
    super.visible,
    super.color,
    super.semanticLabel,
  });

  /// The link data connecting nodes.
  final List<TLink> links;

  /// Extracts the unique node identifier.
  final String Function(TNode item) nodeIdMapper;

  /// Extracts the node display label.
  final String Function(TNode item) nodeLabelMapper;

  /// Extracts the source node ID from a link.
  final String Function(TLink link) sourceIdMapper;

  /// Extracts the target node ID from a link.
  final String Function(TLink link) targetIdMapper;

  /// Extracts the flow value from a link.
  final num Function(TLink link) linkValueMapper;
}
