import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';

/// A node in the treemap.
///
/// Each node has a [label], a [value] determining its area, and optional
/// [children] for hierarchical data. The [key] uniquely identifies the node.
class OiTreemapNode {
  /// Creates an [OiTreemapNode].
  const OiTreemapNode({
    required this.key,
    required this.label,
    required this.value,
    this.color,
    this.children,
  });

  /// A unique key identifying this node.
  final Object key;

  /// The human-readable label for this node.
  final String label;

  /// The numeric value determining this node's area.
  final double value;

  /// An optional override color. When null, a color from the theme's
  /// chart palette is used.
  final Color? color;

  /// Optional child nodes for hierarchical treemaps.
  final List<OiTreemapNode>? children;
}

/// A treemap visualization showing hierarchical data as nested rectangles.
///
/// Each [OiTreemapNode] is rendered as a rectangle whose area is
/// proportional to its [OiTreemapNode.value]. Labels and values
/// can optionally be shown inside each rectangle.
///
/// {@category Composites}
class OiTreemap extends StatelessWidget {
  /// Creates an [OiTreemap].
  const OiTreemap({
    required this.nodes,
    required this.label,
    super.key,
    this.showLabels = true,
    this.showValues = false,
    this.onNodeTap,
    this.behaviors = const [],
    this.controller,
  });

  /// The top-level nodes to display.
  final List<OiTreemapNode> nodes;

  /// The accessibility label for the treemap.
  final String label;

  /// Whether to show labels inside each node rectangle.
  final bool showLabels;

  /// Whether to show numeric values inside each node rectangle.
  final bool showValues;

  /// Called when a node is tapped.
  final ValueChanged<OiTreemapNode>? onNodeTap;

  /// Composable interaction behaviors.
  final List<OiChartBehavior> behaviors;

  /// External chart controller.
  final OiChartController? controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final chartColors = colors.chart;

    if (nodes.isEmpty) {
      return Semantics(
        label: label,
        child: const SizedBox.shrink(key: Key('oi_treemap_empty')),
      );
    }

    return Semantics(
      label: label,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : width * 0.6;

          final rects = _squarify(
            nodes: nodes,
            rect: Rect.fromLTWH(0, 0, width, height),
          );

          return SizedBox(
            key: const Key('oi_treemap'),
            width: width,
            height: height,
            child: Stack(
              children: [
                for (var i = 0; i < rects.length; i++)
                  Positioned(
                    left: rects[i].left,
                    top: rects[i].top,
                    width: rects[i].width,
                    height: rects[i].height,
                    child: _buildNodeWidget(
                      node: nodes[i],
                      color:
                          nodes[i].color ?? chartColors[i % chartColors.length],
                      textColor: colors.textOnPrimary,
                      rect: rects[i],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNodeWidget({
    required OiTreemapNode node,
    required Color color,
    required Color textColor,
    required Rect rect,
  }) {
    return GestureDetector(
      onTap: onNodeTap != null ? () => onNodeTap!(node) : null,
      child: Container(
        key: Key('oi_treemap_node_${node.key}'),
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
        child: (showLabels || showValues) && rect.width > 20 && rect.height > 16
            ? Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showLabels)
                      OiLabel.caption(
                        node.label,
                        color: textColor,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    if (showValues)
                      OiLabel.small(
                        node.value.toStringAsFixed(0),
                        color: textColor.withValues(alpha: 0.8),
                      ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  /// A simplified squarified treemap layout algorithm.
  ///
  /// Lays out [nodes] within [rect] using a slice-and-dice approach
  /// that alternates between horizontal and vertical slicing.
  static List<Rect> _squarify({
    required List<OiTreemapNode> nodes,
    required Rect rect,
  }) {
    if (nodes.isEmpty) return [];

    final totalValue = nodes.fold<double>(0, (sum, n) => sum + n.value);
    if (totalValue <= 0) {
      return List.filled(nodes.length, Rect.zero);
    }

    final rects = <Rect>[];
    var remaining = rect;

    for (var i = 0; i < nodes.length; i++) {
      final ratio = nodes[i].value / totalValue;
      final isLast = i == nodes.length - 1;

      if (isLast) {
        rects.add(remaining);
      } else if (remaining.width >= remaining.height) {
        // Slice vertically.
        final w =
            remaining.width * ratio / _remainingRatio(nodes, i, totalValue);
        rects.add(
          Rect.fromLTWH(remaining.left, remaining.top, w, remaining.height),
        );
        remaining = Rect.fromLTWH(
          remaining.left + w,
          remaining.top,
          remaining.width - w,
          remaining.height,
        );
      } else {
        // Slice horizontally.
        final h =
            remaining.height * ratio / _remainingRatio(nodes, i, totalValue);
        rects.add(
          Rect.fromLTWH(remaining.left, remaining.top, remaining.width, h),
        );
        remaining = Rect.fromLTWH(
          remaining.left,
          remaining.top + h,
          remaining.width,
          remaining.height - h,
        );
      }
    }

    return rects;
  }

  /// Returns the ratio of remaining values starting from index [from].
  static double _remainingRatio(
    List<OiTreemapNode> nodes,
    int from,
    double total,
  ) {
    var sum = 0.0;
    for (var i = from; i < nodes.length; i++) {
      sum += nodes[i].value;
    }
    return sum / total;
  }
}
