import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/oi_sunburst_chart/oi_sunburst_painter.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Internal node model
// ─────────────────────────────────────────────────────────────────────────────

/// An internal node used during sunburst tree construction.
class _SbNode<T> {
  _SbNode({
    required this.id,
    required this.rawItem,
    required this.ownValue,
    required this.label,
    required this.depth,
    this.parent,
  });

  final String id;
  final T rawItem;
  final num ownValue;
  final String label;
  final int depth;
  _SbNode<T>? parent;
  List<_SbNode<T>> children = [];

  num get aggregatedValue => children.isEmpty
      ? ownValue
      : children.fold<num>(0, (s, c) => s + c.aggregatedValue);
}

// ─────────────────────────────────────────────────────────────────────────────
// OiSunburstChart
// ─────────────────────────────────────────────────────────────────────────────

/// A radial hierarchy chart that renders data as concentric rings.
///
/// Each ring corresponds to one depth level. Arcs within a ring are
/// proportional to each node's share of its parent's aggregated value.
/// Tapping an arc fires [onNodeTap] with the tapped domain item.
///
/// ## API
///
/// Pass a flat list of domain objects via [data]. Provide [nodeId], [parentId],
/// [value], and [nodeLabel] mappers so the chart can build the tree. The root
/// node(s) are items whose [parentId] returns `null` or returns an id that is
/// not present in [data].
///
/// ## Rendering
///
/// - Center circle = root. When [centerContent] is provided it is stacked on
///   top of the center circle.
/// - Depth 1 items form the first ring, depth 2 the second, and so on.
/// - [maxDepth] limits how many rings are drawn (unlimited when null).
/// - Arc colors are taken from the theme chart palette, cycling by depth and
///   sibling index.
///
/// ## Accessibility
///
/// Wrap the chart in a [Semantics] with [semanticLabel] describing the data.
/// Individual arcs announce their label via [SemanticsProperties].
///
/// {@category Composites}
class OiSunburstChart<TNode> extends StatefulWidget {
  /// Creates an [OiSunburstChart].
  const OiSunburstChart({
    required this.label,
    required this.data,
    required this.nodeId,
    required this.parentId,
    required this.value,
    required this.nodeLabel,
    super.key,
    this.maxDepth,
    this.centerContent,
    this.onNodeTap,
    this.behaviors = const [],
    this.controller,
    this.compact,
    this.semanticLabel,
  });

  /// Accessibility label for the chart.
  final String label;

  /// The flat list of domain objects from which the tree is built.
  final List<TNode> data;

  /// Extracts the unique identifier for a node.
  final String Function(TNode item) nodeId;

  /// Extracts the parent node identifier; return `null` for root nodes.
  final String? Function(TNode item) parentId;

  /// Extracts the numeric value for a leaf node.
  ///
  /// For branch nodes the value is summed from their children, so this
  /// mapper is only used when a node has no children.
  final num Function(TNode item) value;

  /// Extracts the display label for a node.
  final String Function(TNode item) nodeLabel;

  /// Maximum depth of rings to render; unlimited when `null`.
  final int? maxDepth;

  /// Optional widget displayed in the center circle.
  ///
  /// Common use: a summary metric or "root" label.
  final Widget? centerContent;

  /// Called when the user taps an arc.
  final void Function(TNode item)? onNodeTap;

  /// Composable interaction behaviors.
  final List<OiChartBehavior> behaviors;

  /// External chart controller.
  final OiChartController? controller;

  /// When `true`, labels inside arcs are suppressed for dense layouts.
  ///
  /// When `null`, compactness is derived from available width.
  final bool? compact;

  /// Override for the semantic label. Defaults to [label].
  final String? semanticLabel;

  @override
  State<OiSunburstChart<TNode>> createState() => _OiSunburstChartState<TNode>();
}

class _OiSunburstChartState<TNode> extends State<OiSunburstChart<TNode>> {
  static const double _minViableSize = 80;
  static const double _compactBreakpoint = 160;

  String? _hoveredNodeId;

  // ── Tree construction ─────────────────────────────────────────────────────

  /// Build a forest from the flat [widget.data] list.
  List<_SbNode<TNode>> _buildRoots() {
    final data = widget.data;
    if (data.isEmpty) return [];

    final itemById = <String, TNode>{};
    for (final item in data) {
      itemById[widget.nodeId(item)] = item;
    }

    final childrenMap = <String, List<String>>{};
    for (final item in data) {
      final pid = widget.parentId(item);
      if (pid != null && itemById.containsKey(pid)) {
        (childrenMap[pid] ??= []).add(widget.nodeId(item));
      }
    }

    _SbNode<TNode> buildNode(String id, int depth) {
      // itemById is guaranteed to have this id because buildNode is only called
      // with ids that came from the data list.
      final item = itemById[id] as TNode;
      final node = _SbNode<TNode>(
        id: id,
        rawItem: item,
        ownValue: widget.value(item),
        label: widget.nodeLabel(item),
        depth: depth,
      );
      final childIds = childrenMap[id] ?? [];
      node.children = [for (final cid in childIds) buildNode(cid, depth + 1)];
      for (final child in node.children) {
        child.parent = node;
      }
      return node;
    }

    final roots = <_SbNode<TNode>>[];
    for (final item in data) {
      final id = widget.nodeId(item);
      final pid = widget.parentId(item);
      if (pid == null || !itemById.containsKey(pid)) {
        roots.add(buildNode(id, 0));
      }
    }
    return roots;
  }

  // ── Arc geometry ──────────────────────────────────────────────────────────

  /// Converts the tree into a flat list of [OiSunburstArcDatum] objects
  /// ready for the painter.
  List<OiSunburstArcDatum> _buildArcs(
    List<_SbNode<TNode>> roots,
    List<Color> chartColors,
    int? maxDepth,
  ) {
    final arcs = <OiSunburstArcDatum>[];

    // The full circle sweep for the root level.
    void visit(
      _SbNode<TNode> node,
      double parentStartAngle,
      double parentSweep,
      num parentAggregated,
      int colorOffset,
    ) {
      if (maxDepth != null && node.depth > maxDepth) return;

      // Compute this arc's sweep.
      final nodeSweep = parentAggregated > 0
          ? (node.aggregatedValue / parentAggregated) * parentSweep
          : 0.0;

      if (node.depth > 0) {
        // Pick color: cycle through palette by (depth-1) offset + sibling index.
        final color = chartColors[colorOffset % chartColors.length];

        arcs.add(
          OiSunburstArcDatum(
            nodeId: node.id,
            label: node.label,
            depth: node.depth,
            startAngle: parentStartAngle,
            sweepAngle: nodeSweep,
            color: color,
          ),
        );
      }

      // Recurse into children.
      var childStart = parentStartAngle;
      final childAgg = node.aggregatedValue;
      for (var i = 0; i < node.children.length; i++) {
        final child = node.children[i];
        final childSweep = childAgg > 0
            ? (child.aggregatedValue / childAgg) * nodeSweep
            : 0.0;
        visit(child, childStart, childSweep, childAgg, colorOffset + i);
        childStart += childSweep;
      }
    }

    // Handle multiple roots (forest).
    final totalRootValue = roots.fold<num>(0, (s, r) => s + r.aggregatedValue);

    var rootStart = -math.pi / 2; // Start at top.
    for (var i = 0; i < roots.length; i++) {
      final root = roots[i];
      final rootSweep = totalRootValue > 0
          ? (root.aggregatedValue / totalRootValue) * (2 * math.pi)
          : 2 * math.pi / roots.length;

      // Depth-0 root: recurse into children.
      var childStart = rootStart;
      final childAgg = root.aggregatedValue;
      for (var j = 0; j < root.children.length; j++) {
        final child = root.children[j];
        final childSweep = childAgg > 0
            ? (child.aggregatedValue / childAgg) * rootSweep
            : 0.0;
        visit(child, childStart, childSweep, childAgg, i * 8 + j);
        childStart += childSweep;
      }
      rootStart += rootSweep;
    }

    return arcs;
  }

  // ── Hit testing ───────────────────────────────────────────────────────────

  String? _hitTest(
    Offset local,
    Size size,
    double innerRadius,
    double ringWidth,
  ) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = local.dx - center.dx;
    final dy = local.dy - center.dy;
    final dist = math.sqrt(dx * dx + dy * dy);

    if (dist < innerRadius) return null;

    // Which depth ring?
    final depth = ((dist - innerRadius) / ringWidth).floor() + 1;

    // Angle of hit, normalised to [0, 2π) from -π/2 start.
    final angle = math.atan2(dy, dx);
    // Normalise relative to start at -π/2.
    var normalised = angle + math.pi / 2;
    if (normalised < 0) normalised += 2 * math.pi;

    for (final arc in _cachedArcs) {
      if (arc.depth != depth) continue;
      // Normalise arc angles too.
      var arcStart = arc.startAngle - (-math.pi / 2);
      if (arcStart < 0) arcStart += 2 * math.pi;
      final arcEnd = arcStart + arc.sweepAngle;
      if (normalised >= arcStart && normalised <= arcEnd) {
        return arc.nodeId;
      }
    }
    return null;
  }

  // ── State ─────────────────────────────────────────────────────────────────

  List<OiSunburstArcDatum> _cachedArcs = [];
  List<_SbNode<TNode>> _cachedRoots = [];

  bool _isCompact(double w) => widget.compact ?? w < _compactBreakpoint;

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = widget.semanticLabel ?? widget.label;
    final colors = context.colors;
    final chartColors = colors.chart;

    if (widget.data.isEmpty) {
      return Semantics(
        label: effectiveLabel,
        child: const SizedBox.shrink(key: Key('oi_sunburst_chart_empty')),
      );
    }

    return Semantics(
      label: effectiveLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight.isFinite ? constraints.maxHeight : w;
          final dim = math.min(w, h);

          if (dim < _minViableSize) {
            return SizedBox(
              width: w,
              height: h,
              child: const Center(
                key: Key('oi_sunburst_chart_fallback'),
                child: OiLabel.caption('…'),
              ),
            );
          }

          final isCompact = _isCompact(dim);

          // Rebuild tree.
          _cachedRoots = _buildRoots();

          if (_cachedRoots.isEmpty) {
            return Semantics(
              label: effectiveLabel,
              child: const SizedBox.shrink(key: Key('oi_sunburst_chart_empty')),
            );
          }

          // Layout constants.
          const centerFraction = 0.20;
          final innerRadius = dim / 2 * centerFraction;

          // Determine number of depth levels.
          var computedMaxDepth = 0;
          void measureDepth(_SbNode<TNode> n) {
            if (n.depth > computedMaxDepth) computedMaxDepth = n.depth;
            for (final c in n.children) {
              measureDepth(c);
            }
          }

          for (final r in _cachedRoots) {
            measureDepth(r);
          }
          final effectiveMaxDepth = widget.maxDepth != null
              ? math.min(widget.maxDepth!, computedMaxDepth)
              : computedMaxDepth;

          final ringWidth = effectiveMaxDepth > 0
              ? (dim / 2 - innerRadius) / effectiveMaxDepth
              : dim / 2 - innerRadius;

          _cachedArcs = _buildArcs(_cachedRoots, chartColors, widget.maxDepth);

          final centerColor = chartColors.isNotEmpty
              ? chartColors[0].withValues(alpha: 0.15)
              : const Color(0x11000000);

          Widget chart = SizedBox(
            key: const Key('oi_sunburst_chart'),
            width: dim,
            height: dim,
            child: MouseRegion(
              onHover: (event) {
                final hit = _hitTest(
                  event.localPosition,
                  Size(dim, dim),
                  innerRadius,
                  ringWidth,
                );
                if (hit != _hoveredNodeId) {
                  setState(() => _hoveredNodeId = hit);
                }
              },
              onExit: (_) => setState(() => _hoveredNodeId = null),
              child: GestureDetector(
                onTapDown: (details) {
                  final nodeId = _hitTest(
                    details.localPosition,
                    Size(dim, dim),
                    innerRadius,
                    ringWidth,
                  );
                  if (nodeId != null && widget.onNodeTap != null) {
                    // Find the raw item by id.
                    for (final item in widget.data) {
                      if (widget.nodeId(item) == nodeId) {
                        widget.onNodeTap!(item);
                        break;
                      }
                    }
                  }
                },
                child: CustomPaint(
                  key: const Key('oi_sunburst_chart_painter'),
                  size: Size(dim, dim),
                  painter: OiSunburstPainter(
                    arcs: _cachedArcs,
                    centerColor: centerColor,
                    ringWidth: ringWidth,
                    innerRadius: innerRadius,
                    maxDepth: effectiveMaxDepth,
                    hoveredNodeId: _hoveredNodeId,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: innerRadius * 2,
                      height: innerRadius * 2,
                      child: Center(
                        child:
                            widget.centerContent ??
                            (isCompact
                                ? null
                                : OiLabel.caption(
                                    widget.label,
                                    color: colors.textMuted,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  )),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          return chart;
        },
      ),
    );
  }
}
