import 'package:flutter/widgets.dart';

import 'package:obers_ui_charts/src/components/oi_chart_empty_state.dart';
import 'package:obers_ui_charts/src/components/oi_chart_error_state.dart';
import 'package:obers_ui_charts/src/components/oi_chart_loading_state.dart';
import 'package:obers_ui_charts/src/composites/_chart_behavior_host.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_accessibility_config.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_hit_tester.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_viewport.dart';
// Imported for future annotation/threshold support on hierarchical charts.
// ignore: unused_import
import 'package:obers_ui_charts/src/models/oi_chart_annotation.dart';
// Imported for future annotation/threshold support on hierarchical charts.
// ignore: unused_import
import 'package:obers_ui_charts/src/models/oi_chart_threshold.dart';
import 'package:obers_ui_charts/src/models/oi_hierarchical_series.dart';

/// An internal node in the computed hierarchy tree.
///
/// {@category Composites}
class OiHierarchyNode<TNode> {
  /// Creates a hierarchy node.
  OiHierarchyNode({
    required this.id,
    required this.rawItem,
    required this.value,
    required this.label,
    required this.depth,
    this.parent,
    this.children = const [],
  });

  /// The node's unique identifier.
  final String id;

  /// The original domain item.
  final TNode rawItem;

  /// The value (aggregated from children if not a leaf).
  final num value;

  /// Display label.
  final String label;

  /// Depth in the tree (root = 0).
  final int depth;

  /// Parent node reference.
  OiHierarchyNode<TNode>? parent;

  /// Child nodes.
  List<OiHierarchyNode<TNode>> children;

  /// Whether this is a leaf node.
  bool get isLeaf => children.isEmpty;

  /// Aggregated value: own value for leaves, sum of children for branches.
  num get aggregatedValue => isLeaf
      ? value
      : children.fold<num>(0, (sum, c) => sum + c.aggregatedValue);
}

/// Base composite widget for hierarchical chart types (treemap, sunburst).
///
/// Builds a tree from a flat list using the series mappers, aggregates leaf
/// values to parent nodes, and supports drill navigation.
///
/// {@category Composites}
class OiHierarchicalChart<TNode> extends StatefulWidget {
  /// Creates a hierarchical chart.
  const OiHierarchicalChart({
    super.key,
    required this.label,
    required this.series,
    this.seriesBuilder,
    this.behaviors = const [],
    this.controller,
    this.accessibility,
    this.emptyState,
    this.loadingState,
    this.errorState,
    this.semanticLabel,
  });

  /// Accessibility label for the chart.
  final String label;

  /// The hierarchical data series.
  final OiHierarchicalSeries<TNode> series;

  /// Builder that renders the tree.
  final Widget Function(
    BuildContext context,
    OiChartViewport viewport,
    List<OiHierarchyNode<TNode>> roots,
  )?
  seriesBuilder;

  /// Composable interaction behaviors.
  final List<OiChartBehavior> behaviors;

  /// External chart controller.
  final OiChartController? controller;

  /// Accessibility configuration.
  final OiChartAccessibilityConfig? accessibility;

  /// Custom empty state widget.
  final Widget? emptyState;

  /// Custom loading state widget.
  final Widget? loadingState;

  /// Custom error state widget.
  final Widget? errorState;

  /// Override for the semantic label.
  final String? semanticLabel;

  @override
  State<OiHierarchicalChart<TNode>> createState() =>
      _OiHierarchicalChartState<TNode>();
}

class _OiHierarchicalChartState<TNode> extends State<OiHierarchicalChart<TNode>>
    with ChartBehaviorHost<OiHierarchicalChart<TNode>> {
  OiChartViewport _viewport = const OiChartViewport(size: Size.zero);

  // ── ChartBehaviorHost overrides ──────────────────────────────────────

  @override
  List<OiChartBehavior> get behaviors => widget.behaviors;

  @override
  OiChartController? get externalController => widget.controller;

  @override
  OiChartViewport get currentViewport => _viewport;

  @override
  OiChartHitTester get hitTester => _hitTester;

  final OiChartHitTester _hitTester = NoOpHitTester();

  // ── Lifecycle ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // Defer behavior attach to first build (needs context).
  }

  @override
  void didUpdateWidget(covariant OiHierarchicalChart<TNode> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.behaviors != widget.behaviors ||
        oldWidget.controller != widget.controller) {
      attachBehaviors();
    }
  }

  @override
  void dispose() {
    disposeBehaviorHost();
    super.dispose();
  }

  // ── Series helpers ───────────────────────────────────────────────────

  bool get _seriesVisible {
    final s = widget.series;
    return s.visible && effectiveController.legendState.isVisible(s.id);
  }

  bool get _hasData =>
      _seriesVisible &&
      widget.series.data != null &&
      widget.series.data!.isNotEmpty;

  bool get _allSeriesHidden => !_seriesVisible;

  String get _effectiveLabel {
    if (widget.semanticLabel != null) return widget.semanticLabel!;
    if (widget.label.isNotEmpty) return widget.label;
    return 'Hierarchical chart';
  }

  /// Builds a tree from the flat data list using the series mappers.
  List<OiHierarchyNode<TNode>> _buildTree() {
    final data = widget.series.data;
    if (data == null || data.isEmpty) return [];

    final s = widget.series;

    // First pass: create a temporary map of id → item for parent lookup.
    final itemById = <String, TNode>{};
    for (final item in data) {
      itemById[s.nodeIdMapper(item)] = item;
    }

    // Identify parent chains to compute depths, then build nodes.
    final nodeMap = <String, OiHierarchyNode<TNode>>{};
    final childrenMap = <String, List<String>>{};

    for (final item in data) {
      final id = s.nodeIdMapper(item);
      final parentId = s.parentIdMapper(item);
      if (parentId != null && itemById.containsKey(parentId)) {
        (childrenMap[parentId] ??= []).add(id);
      }
    }

    // Recursive builder that sets depth correctly at creation time.
    OiHierarchyNode<TNode> buildNode(String id, int depth) {
      final item = itemById[id]!;
      final node = OiHierarchyNode<TNode>(
        id: id,
        rawItem: item,
        value: s.valueMapper(item),
        label: s.nodeLabelMapper(item),
        depth: depth,
      );
      final childIds = childrenMap[id] ?? [];
      node.children = [
        for (final childId in childIds) buildNode(childId, depth + 1),
      ];
      for (final child in node.children) {
        child.parent = node;
      }
      nodeMap[id] = node;
      return node;
    }

    // Find roots: items with no parent or parent not in the data set.
    final roots = <OiHierarchyNode<TNode>>[];
    for (final item in data) {
      final id = s.nodeIdMapper(item);
      final parentId = s.parentIdMapper(item);
      if (parentId == null || !itemById.containsKey(parentId)) {
        roots.add(buildNode(id, 0));
      }
    }

    return roots;
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final ctrl = effectiveController;
    final isLoading = ctrl.isLoading;
    final error = ctrl.error;

    // Loading state.
    if (isLoading) {
      return widget.loadingState ?? const OiChartLoadingState();
    }

    // Error state.
    if (error != null) {
      return widget.errorState ?? OiChartErrorState(message: error);
    }

    // All series hidden.
    if (_allSeriesHidden) {
      return widget.emptyState ??
          const OiChartEmptyState(message: 'All series are hidden');
    }

    // Empty state.
    if (!_hasData) {
      return widget.emptyState ?? const OiChartEmptyState();
    }

    final roots = _buildTree();

    return Semantics(
      label: _effectiveLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : 300.0;

          _viewport = OiChartViewport(
            size: Size(w, h),
            devicePixelRatio:
                MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0,
            zoomLevel: ctrl.viewportState.zoomLevel,
            panOffset: ctrl.viewportState.panOffset,
          );

          // Attach behaviors now that we have a valid context.
          if (behaviors.isNotEmpty && behaviors.any((b) => !b.isAttached)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) attachBehaviors();
            });
          }

          final content =
              widget.seriesBuilder?.call(context, _viewport, roots) ??
              SizedBox(width: w, height: h);

          return wrapWithPointerListener(
            SizedBox(width: w, height: h, child: content),
          );
        },
      ),
    );
  }
}
