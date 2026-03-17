import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A node in the flow graph.
///
/// Each node has a unique [key], a display [label], a [position] on the
/// canvas, and lists of named [inputs] and [outputs] ports that edges can
/// connect to.
class OiFlowNode {
  /// Creates an [OiFlowNode].
  const OiFlowNode({
    required this.key,
    required this.position,
    required this.label,
    this.icon,
    this.color,
    this.inputs = const [],
    this.outputs = const [],
    this.data,
  });

  /// A unique key used to identify this node.
  final Object key;

  /// The position of the node on the graph canvas.
  final Offset position;

  /// The display label for this node.
  final String label;

  /// An optional icon displayed alongside the label.
  final IconData? icon;

  /// An optional color override for the node background.
  final Color? color;

  /// Named input ports on this node.
  final List<String> inputs;

  /// Named output ports on this node.
  final List<String> outputs;

  /// Optional arbitrary data associated with this node.
  final Map<String, dynamic>? data;
}

/// An edge connecting two nodes in the flow graph.
///
/// Connects from [sourcePort] on [sourceNode] to [targetPort] on
/// [targetNode].
class OiFlowEdge {
  /// Creates an [OiFlowEdge].
  const OiFlowEdge({
    required this.sourceNode,
    required this.sourcePort,
    required this.targetNode,
    required this.targetPort,
    this.label,
    this.animated = false,
  });

  /// The key of the source [OiFlowNode].
  final Object sourceNode;

  /// The name of the output port on the source node.
  final String sourcePort;

  /// The key of the target [OiFlowNode].
  final Object targetNode;

  /// The name of the input port on the target node.
  final String targetPort;

  /// An optional label displayed alongside the edge.
  final String? label;

  /// Whether to animate the edge (e.g. dashed flow animation).
  final bool animated;
}

/// A node-and-edge graph editor for visual workflows.
///
/// Supports rendering nodes at positions, connecting ports with edges,
/// tapping nodes, custom node builders, grid snapping, and accessibility
/// labelling.
///
/// {@category Composites}
class OiFlowGraph extends StatefulWidget {
  /// Creates an [OiFlowGraph].
  const OiFlowGraph({
    required this.nodes,
    required this.edges,
    required this.label,
    this.nodeBuilder,
    this.onNodeTap,
    this.onNodeMove,
    this.onEdgeCreate,
    this.onEdgeDelete,
    this.editable = true,
    this.zoomable = true,
    this.pannable = true,
    this.snapToGrid = true,
    this.gridSize = 20,
    this.width,
    this.height,
    super.key,
  });

  /// The list of nodes to render.
  final List<OiFlowNode> nodes;

  /// The list of edges connecting node ports.
  final List<OiFlowEdge> edges;

  /// Accessibility label for the flow graph.
  final String label;

  /// An optional custom builder for rendering nodes.
  ///
  /// When null a default card representation is used.
  final Widget Function(OiFlowNode)? nodeBuilder;

  /// Called when a node is tapped.
  final ValueChanged<OiFlowNode>? onNodeTap;

  /// Called when a node is moved to a new position.
  final void Function(OiFlowNode, Offset)? onNodeMove;

  /// Called when a new edge is created between two ports.
  final void Function(String sourcePort, String targetPort)? onEdgeCreate;

  /// Called when an edge is deleted.
  final ValueChanged<OiFlowEdge>? onEdgeDelete;

  /// Whether the graph supports interactive editing (moving nodes, etc.).
  final bool editable;

  /// Whether the graph supports zooming.
  final bool zoomable;

  /// Whether the graph supports panning.
  final bool pannable;

  /// Whether nodes snap to the grid when moved.
  final bool snapToGrid;

  /// The grid cell size in logical pixels.
  final double gridSize;

  /// The width of the graph canvas.
  final double? width;

  /// The height of the graph canvas.
  final double? height;

  @override
  State<OiFlowGraph> createState() => _OiFlowGraphState();
}

class _OiFlowGraphState extends State<OiFlowGraph> {
  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const double _defaultNodeWidth = 140;
  static const double _defaultNodeHeight = 60;
  static const double _portRadius = 5;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolvedWidth = widget.width ?? 600;
    final resolvedHeight = widget.height ?? 400;

    // Map node keys for quick lookup.
    final nodeMap = <Object, OiFlowNode>{};
    for (final node in widget.nodes) {
      nodeMap[node.key] = node;
    }

    return Semantics(
      label: widget.label,
      child: SizedBox(
        width: resolvedWidth,
        height: resolvedHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Grid background.
            if (widget.snapToGrid)
              Positioned.fill(
                child: CustomPaint(
                  key: const ValueKey('oi_flow_graph_grid'),
                  painter: _GridPainter(
                    gridSize: widget.gridSize,
                    color: colors.borderSubtle,
                  ),
                ),
              ),
            // Edges layer.
            Positioned.fill(
              child: CustomPaint(
                painter: _EdgePainter(
                  edges: widget.edges,
                  nodeMap: nodeMap,
                  nodeWidth: _defaultNodeWidth,
                  nodeHeight: _defaultNodeHeight,
                  defaultColor: colors.border,
                  textColor: colors.textMuted,
                ),
              ),
            ),
            // Node layer.
            for (final node in widget.nodes)
              Positioned(
                left: node.position.dx,
                top: node.position.dy,
                child: _buildNode(context, node, colors),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNode(
    BuildContext context,
    OiFlowNode node,
    OiColorScheme colors,
  ) {
    Widget content;

    if (widget.nodeBuilder != null) {
      content = widget.nodeBuilder!(node);
    } else {
      content = Container(
        width: _defaultNodeWidth,
        height: _defaultNodeHeight,
        decoration: BoxDecoration(
          color: node.color ?? colors.surface,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (node.icon != null) ...[
                Icon(node.icon, size: 16, color: colors.text),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  node.label,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Port indicators.
    final portIndicators = <Widget>[];
    for (var i = 0; i < node.inputs.length; i++) {
      portIndicators.add(
        Positioned(
          left: -_portRadius,
          top: _defaultNodeHeight * (i + 1) / (node.inputs.length + 1) -
              _portRadius,
          child: _PortDot(
            key: ValueKey('oi_flow_port_in_${node.key}_${node.inputs[i]}'),
            color: colors.primary.base,
          ),
        ),
      );
    }
    for (var i = 0; i < node.outputs.length; i++) {
      portIndicators.add(
        Positioned(
          right: -_portRadius,
          top: _defaultNodeHeight * (i + 1) / (node.outputs.length + 1) -
              _portRadius,
          child: _PortDot(
            key: ValueKey('oi_flow_port_out_${node.key}_${node.outputs[i]}'),
            color: colors.primary.base,
          ),
        ),
      );
    }

    Widget nodeWidget = SizedBox(
      key: ValueKey('oi_flow_node_${node.key}'),
      width: _defaultNodeWidth,
      height: _defaultNodeHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          content,
          ...portIndicators,
        ],
      ),
    );

    if (widget.onNodeTap != null) {
      nodeWidget = GestureDetector(
        onTap: () => widget.onNodeTap!(node),
        child: nodeWidget,
      );
    }

    if (widget.editable && widget.onNodeMove != null) {
      nodeWidget = GestureDetector(
        onPanUpdate: (details) {
          var newPos = node.position + details.delta;
          if (widget.snapToGrid) {
            newPos = Offset(
              (newPos.dx / widget.gridSize).round() * widget.gridSize,
              (newPos.dy / widget.gridSize).round() * widget.gridSize,
            );
          }
          widget.onNodeMove!(node, newPos);
        },
        child: nodeWidget,
      );
    }

    return nodeWidget;
  }
}

// ---------------------------------------------------------------------------
// Port dot widget
// ---------------------------------------------------------------------------

/// A small circular indicator for a node port.
class _PortDot extends StatelessWidget {
  const _PortDot({
    required this.color,
    super.key,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grid painter
// ---------------------------------------------------------------------------

/// Paints a dot grid background for the flow graph canvas.
class _GridPainter extends CustomPainter {
  const _GridPainter({
    required this.gridSize,
    required this.color,
  });

  /// The distance between grid dots.
  final double gridSize;

  /// The color of grid dots.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (var x = 0.0; x < size.width; x += gridSize) {
      for (var y = 0.0; y < size.height; y += gridSize) {
        canvas.drawCircle(Offset(x, y), 0.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) =>
      oldDelegate.gridSize != gridSize || oldDelegate.color != color;
}

// ---------------------------------------------------------------------------
// Edge painter
// ---------------------------------------------------------------------------

/// Paints edges between node ports as bezier curves with arrowheads.
class _EdgePainter extends CustomPainter {
  const _EdgePainter({
    required this.edges,
    required this.nodeMap,
    required this.nodeWidth,
    required this.nodeHeight,
    required this.defaultColor,
    required this.textColor,
  });

  /// The list of edges to paint.
  final List<OiFlowEdge> edges;

  /// A map from node key to [OiFlowNode].
  final Map<Object, OiFlowNode> nodeMap;

  /// The default node width.
  final double nodeWidth;

  /// The default node height.
  final double nodeHeight;

  /// The default edge color.
  final Color defaultColor;

  /// The color for edge labels.
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    for (final edge in edges) {
      final source = nodeMap[edge.sourceNode];
      final target = nodeMap[edge.targetNode];
      if (source == null || target == null) continue;

      // Find the port index for positioning.
      final sourcePortIdx = source.outputs.indexOf(edge.sourcePort);
      final targetPortIdx = target.inputs.indexOf(edge.targetPort);
      if (sourcePortIdx < 0 || targetPortIdx < 0) continue;

      // Source port exits from the right side of the node.
      final sourceY = source.position.dy +
          nodeHeight * (sourcePortIdx + 1) / (source.outputs.length + 1);
      final sourceX = source.position.dx + nodeWidth;

      // Target port enters from the left side of the node.
      final targetY = target.position.dy +
          nodeHeight * (targetPortIdx + 1) / (target.inputs.length + 1);
      final targetX = target.position.dx;

      final start = Offset(sourceX, sourceY);
      final end = Offset(targetX, targetY);

      final paint = Paint()
        ..color = defaultColor
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      // Draw a cubic bezier curve.
      final controlOffset = (end.dx - start.dx).abs() / 2;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          start.dx + controlOffset,
          start.dy,
          end.dx - controlOffset,
          end.dy,
          end.dx,
          end.dy,
        );
      canvas.drawPath(path, paint);

      // Draw arrowhead.
      const arrowLength = 8.0;
      const arrowAngle = math.pi / 6;
      final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);

      final headPaint = Paint()
        ..color = defaultColor
        ..style = PaintingStyle.fill;

      final arrowPath = Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(
          end.dx - arrowLength * math.cos(angle - arrowAngle),
          end.dy - arrowLength * math.sin(angle - arrowAngle),
        )
        ..lineTo(
          end.dx - arrowLength * math.cos(angle + arrowAngle),
          end.dy - arrowLength * math.sin(angle + arrowAngle),
        )
        ..close();
      canvas.drawPath(arrowPath, headPaint);

      // Draw edge label if present.
      if (edge.label != null) {
        final midPoint = Offset(
          (start.dx + end.dx) / 2,
          (start.dy + end.dy) / 2 - 10,
        );
        final textPainter = TextPainter(
          text: TextSpan(
            text: edge.label,
            style: TextStyle(color: textColor, fontSize: 11),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          midPoint - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_EdgePainter oldDelegate) => true;
}
