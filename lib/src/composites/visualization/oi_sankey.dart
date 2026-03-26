import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A node in the Sankey diagram.
///
/// Each node has a unique [key] and a [label]. An optional [color]
/// overrides the default from the theme chart palette.
class OiSankeyNode {
  /// Creates an [OiSankeyNode].
  const OiSankeyNode({required this.key, required this.label, this.color});

  /// A unique key identifying this node.
  final Object key;

  /// The human-readable label for this node.
  final String label;

  /// An optional override color for this node.
  final Color? color;
}

/// A link in the Sankey diagram.
///
/// Connects a [source] node key to a [target] node key with a flow
/// of the given [value]. An optional [color] overrides the default.
class OiSankeyLink {
  /// Creates an [OiSankeyLink].
  const OiSankeyLink({
    required this.source,
    required this.target,
    required this.value,
    this.color,
  });

  /// The key of the source node.
  final Object source;

  /// The key of the target node.
  final Object target;

  /// The flow value represented by this link's width.
  final double value;

  /// An optional override color for this link.
  final Color? color;
}

/// A Sankey diagram showing flow between nodes.
///
/// Nodes are laid out in columns based on their depth in the link graph.
/// Links are rendered as curved bands whose width is proportional to
/// their [OiSankeyLink.value].
///
/// {@category Composites}
class OiSankey extends StatelessWidget {
  /// Creates an [OiSankey].
  const OiSankey({
    required this.nodes,
    required this.links,
    required this.label,
    super.key,
    this.showLabels = true,
    this.showValues = false,
    this.onNodeTap,
    this.onLinkTap,
  });

  /// The nodes in the diagram.
  final List<OiSankeyNode> nodes;

  /// The links connecting nodes.
  final List<OiSankeyLink> links;

  /// The accessibility label for the diagram.
  final String label;

  /// Whether to show labels next to each node.
  final bool showLabels;

  /// Whether to show numeric values on each node.
  final bool showValues;

  /// Called when a node is tapped.
  final ValueChanged<OiSankeyNode>? onNodeTap;

  /// Called when a link is tapped.
  final ValueChanged<OiSankeyLink>? onLinkTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final chartColors = colors.chart;

    if (nodes.isEmpty) {
      return Semantics(
        label: label,
        child: const SizedBox.shrink(key: Key('oi_sankey_empty')),
      );
    }

    // Resolve node colors.
    final nodeColorMap = <Object, Color>{};
    for (var i = 0; i < nodes.length; i++) {
      nodeColorMap[nodes[i].key] =
          nodes[i].color ?? chartColors[i % chartColors.length];
    }

    return Semantics(
      label: label,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : width * 0.5;

          final layout = _computeLayout(
            nodes: nodes,
            links: links,
            width: width,
            height: height,
          );

          return SizedBox(
            key: const Key('oi_sankey'),
            width: width,
            height: height,
            child: Stack(
              children: [
                // Paint links.
                CustomPaint(
                  key: const Key('oi_sankey_links'),
                  size: Size(width, height),
                  painter: _OiSankeyLinkPainter(
                    layoutLinks: layout.links,
                    nodeColorMap: nodeColorMap,
                    defaultLinkColor: colors.borderSubtle,
                  ),
                ),
                // Render nodes with labels positioned outside.
                for (final ln in layout.nodes)
                  Positioned(
                    left: ln.rect.left,
                    top: ln.rect.top,
                    width: ln.rect.width,
                    height: ln.rect.height,
                    child: GestureDetector(
                      onTap: onNodeTap != null
                          ? () => onNodeTap!(ln.node)
                          : null,
                      child: Container(
                        key: Key('oi_sankey_node_${ln.node.key}'),
                        decoration: BoxDecoration(
                          color: nodeColorMap[ln.node.key],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                // Render node labels outside the node bars.
                if (showLabels || showValues)
                  for (final ln in layout.nodes)
                    Positioned(
                      // Place label to the right of the node, or left for
                      // the last column.
                      left: ln.rect.right + 4,
                      top: ln.rect.top,
                      height: ln.rect.height,
                      child: IgnorePointer(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showLabels)
                              Text(
                                ln.node.label,
                                style: TextStyle(
                                  color: colors.text,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            if (showValues)
                              Text(
                                ln.totalValue.toStringAsFixed(0),
                                style: TextStyle(
                                  color: colors.textMuted,
                                  fontSize: 9,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                // Render invisible link tap targets.
                for (final ll in layout.links)
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: onLinkTap != null
                          ? () => onLinkTap!(ll.link)
                          : null,
                      child: SizedBox.shrink(
                        key: Key(
                          'oi_sankey_link_${ll.link.source}_${ll.link.target}',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Computes layout positions for all nodes and links.
  static _SankeyLayout _computeLayout({
    required List<OiSankeyNode> nodes,
    required List<OiSankeyLink> links,
    required double width,
    required double height,
  }) {
    if (nodes.isEmpty) {
      return const _SankeyLayout(nodes: [], links: []);
    }

    // Build adjacency and compute node depths.
    final nodeMap = <Object, OiSankeyNode>{};
    for (final n in nodes) {
      nodeMap[n.key] = n;
    }

    final outLinks = <Object, List<OiSankeyLink>>{};
    final inLinks = <Object, List<OiSankeyLink>>{};
    for (final link in links) {
      outLinks.putIfAbsent(link.source, () => []).add(link);
      inLinks.putIfAbsent(link.target, () => []).add(link);
    }

    // Assign columns via topological depth.
    final depth = <Object, int>{};
    for (final n in nodes) {
      depth[n.key] = 0;
    }

    // Iterate until stable.
    var changed = true;
    var iterations = 0;
    while (changed && iterations < 100) {
      changed = false;
      iterations++;
      for (final link in links) {
        final newDepth = (depth[link.source] ?? 0) + 1;
        if (newDepth > (depth[link.target] ?? 0)) {
          depth[link.target] = newDepth;
          changed = true;
        }
      }
    }

    final maxDepth = depth.values.fold<int>(0, math.max);
    final numColumns = maxDepth + 1;

    // Group nodes by column.
    final columns = <int, List<OiSankeyNode>>{};
    for (final n in nodes) {
      final col = depth[n.key] ?? 0;
      columns.putIfAbsent(col, () => []).add(n);
    }

    // Layout dimensions.
    const nodeWidth = 20.0;
    const nodePadding = 8.0;
    final colSpacing = numColumns > 1
        ? (width - nodeWidth) / (numColumns - 1)
        : width / 2;

    // Compute node values (sum of links).
    final nodeValue = <Object, double>{};
    for (final n in nodes) {
      final outVal = (outLinks[n.key] ?? []).fold<double>(
        0,
        (s, l) => s + l.value,
      );
      final inVal = (inLinks[n.key] ?? []).fold<double>(
        0,
        (s, l) => s + l.value,
      );
      nodeValue[n.key] = math.max(outVal, inVal);
    }

    // Position nodes within each column.
    final nodeRects = <Object, Rect>{};
    for (var col = 0; col < numColumns; col++) {
      final colNodes = columns[col] ?? [];
      if (colNodes.isEmpty) continue;

      final totalValue = colNodes.fold<double>(
        0,
        (s, n) => s + (nodeValue[n.key] ?? 1),
      );
      final totalPadding = (colNodes.length - 1) * nodePadding;
      final availHeight = height - totalPadding;
      final x = numColumns > 1 ? col * colSpacing : (width - nodeWidth) / 2;

      // First pass: compute proportional heights with minimum.
      const minNodeHeight = 12.0;
      final rawHeights = <double>[];
      for (final n in colNodes) {
        final nv = nodeValue[n.key] ?? 1;
        final h = totalValue > 0
            ? availHeight * nv / totalValue
            : availHeight / colNodes.length;
        rawHeights.add(math.max(h, minNodeHeight));
      }

      // Scale to fit within available height if minimums pushed total over.
      final rawTotal = rawHeights.fold<double>(0, (s, h) => s + h);
      final scale = rawTotal > availHeight ? availHeight / rawTotal : 1.0;

      var y = 0.0;
      for (var i = 0; i < colNodes.length; i++) {
        final h = rawHeights[i] * scale;
        nodeRects[colNodes[i].key] = Rect.fromLTWH(x, y, nodeWidth, h);
        y += h + nodePadding;
      }
    }

    // Build layout node list.
    final layoutNodes = <_LayoutNode>[];
    for (final n in nodes) {
      layoutNodes.add(
        _LayoutNode(
          node: n,
          rect: nodeRects[n.key] ?? Rect.zero,
          totalValue: nodeValue[n.key] ?? 0,
        ),
      );
    }

    // Build layout link list with source/target Y offsets.
    final sourceOffsets = <Object, double>{};
    final targetOffsets = <Object, double>{};
    for (final n in nodes) {
      sourceOffsets[n.key] = nodeRects[n.key]?.top ?? 0;
      targetOffsets[n.key] = nodeRects[n.key]?.top ?? 0;
    }

    final layoutLinks = <_LayoutLink>[];
    for (final link in links) {
      final srcRect = nodeRects[link.source];
      final tgtRect = nodeRects[link.target];
      if (srcRect == null || tgtRect == null) continue;

      final srcValue = nodeValue[link.source] ?? 1;
      final tgtValue = nodeValue[link.target] ?? 1;
      final srcHeight = srcValue > 0
          ? srcRect.height * link.value / srcValue
          : link.value;
      final tgtHeight = tgtValue > 0
          ? tgtRect.height * link.value / tgtValue
          : link.value;

      final sy = sourceOffsets[link.source] ?? srcRect.top;
      final ty = targetOffsets[link.target] ?? tgtRect.top;

      layoutLinks.add(
        _LayoutLink(
          link: link,
          sourceX: srcRect.right,
          sourceY: sy,
          sourceHeight: srcHeight,
          targetX: tgtRect.left,
          targetY: ty,
          targetHeight: tgtHeight,
        ),
      );

      sourceOffsets[link.source] = sy + srcHeight;
      targetOffsets[link.target] = ty + tgtHeight;
    }

    return _SankeyLayout(nodes: layoutNodes, links: layoutLinks);
  }
}

/// Internal layout result.
class _SankeyLayout {
  const _SankeyLayout({required this.nodes, required this.links});

  /// Positioned nodes.
  final List<_LayoutNode> nodes;

  /// Positioned links.
  final List<_LayoutLink> links;
}

/// A node with its computed position.
class _LayoutNode {
  const _LayoutNode({
    required this.node,
    required this.rect,
    required this.totalValue,
  });

  /// The original node.
  final OiSankeyNode node;

  /// The computed rectangle.
  final Rect rect;

  /// The total flow through this node.
  final double totalValue;
}

/// A link with source and target positions.
class _LayoutLink {
  const _LayoutLink({
    required this.link,
    required this.sourceX,
    required this.sourceY,
    required this.sourceHeight,
    required this.targetX,
    required this.targetY,
    required this.targetHeight,
  });

  /// The original link.
  final OiSankeyLink link;

  /// The X coordinate of the source node's right edge.
  final double sourceX;

  /// The Y coordinate of the source band start.
  final double sourceY;

  /// The height of the source band.
  final double sourceHeight;

  /// The X coordinate of the target node's left edge.
  final double targetX;

  /// The Y coordinate of the target band start.
  final double targetY;

  /// The height of the target band.
  final double targetHeight;
}

/// Paints Sankey link bands as bezier curves.
class _OiSankeyLinkPainter extends CustomPainter {
  const _OiSankeyLinkPainter({
    required this.layoutLinks,
    required this.nodeColorMap,
    required this.defaultLinkColor,
  });

  /// The positioned links to paint.
  final List<_LayoutLink> layoutLinks;

  /// Color map for nodes.
  final Map<Object, Color> nodeColorMap;

  /// Fallback color for links.
  final Color defaultLinkColor;

  @override
  void paint(Canvas canvas, Size size) {
    for (final ll in layoutLinks) {
      final color =
          ll.link.color ??
          nodeColorMap[ll.link.source]?.withValues(alpha: 0.3) ??
          defaultLinkColor;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final midX = (ll.sourceX + ll.targetX) / 2;

      final path = Path()
        ..moveTo(ll.sourceX, ll.sourceY)
        ..cubicTo(midX, ll.sourceY, midX, ll.targetY, ll.targetX, ll.targetY)
        ..lineTo(ll.targetX, ll.targetY + ll.targetHeight)
        ..cubicTo(
          midX,
          ll.targetY + ll.targetHeight,
          midX,
          ll.sourceY + ll.sourceHeight,
          ll.sourceX,
          ll.sourceY + ll.sourceHeight,
        )
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_OiSankeyLinkPainter oldDelegate) =>
      oldDelegate.layoutLinks != layoutLinks ||
      oldDelegate.nodeColorMap != nodeColorMap;
}
