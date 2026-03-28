import 'package:flutter/widgets.dart';
import 'package:obers_ui_charts/src/components/oi_chart_empty_state.dart';
import 'package:obers_ui_charts/src/components/oi_chart_error_state.dart';
import 'package:obers_ui_charts/src/components/oi_chart_loading_state.dart';
import 'package:obers_ui_charts/src/composites/_chart_behavior_host.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_accessibility_config.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_hit_tester.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_sync_group.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_viewport.dart';
// Imported for future annotation/threshold support on flow charts.
// ignore: unused_import
import 'package:obers_ui_charts/src/models/oi_chart_annotation.dart';
import 'package:obers_ui_charts/src/models/oi_chart_settings.dart';
// Imported for future annotation/threshold support on flow charts.
// ignore: unused_import
import 'package:obers_ui_charts/src/models/oi_chart_threshold.dart';
import 'package:obers_ui_charts/src/models/oi_flow_series.dart';

/// Base composite widget for flow/network chart types (Sankey, alluvial).
///
/// Handles node/link layout, flow width scaling, and path routing.
///
/// {@category Composites}
class OiFlowChart<TNode, TLink> extends StatefulWidget {
  /// Creates a flow chart.
  const OiFlowChart({
    required this.label, required this.series, super.key,
    this.seriesBuilder,
    this.behaviors = const [],
    this.controller,
    this.accessibility,
    this.emptyState,
    this.loadingState,
    this.errorState,
    this.semanticLabel,
    this.syncGroup,
    this.settings,
  });

  /// Accessibility label for the chart.
  final String label;

  /// The flow data series with nodes and links.
  final OiFlowSeries<TNode, TLink> series;

  /// Builder that renders the flow layout.
  final Widget Function(
    BuildContext context,
    OiChartViewport viewport,
    OiFlowSeries<TNode, TLink> series,
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

  /// Sync group for coordinating interactions with sibling charts.
  final OiChartSyncGroup? syncGroup;

  /// Persisted settings to restore on mount.
  final OiChartSettings? settings;

  @override
  State<OiFlowChart<TNode, TLink>> createState() =>
      _OiFlowChartState<TNode, TLink>();
}

class _OiFlowChartState<TNode, TLink> extends State<OiFlowChart<TNode, TLink>>
    with ChartBehaviorHost<OiFlowChart<TNode, TLink>> {
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

  @override
  OiChartSyncGroup? get syncGroup => widget.syncGroup;

  final OiChartHitTester _hitTester = NoOpHitTester();

  // ── Lifecycle ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    restoreSettings(widget.settings);
    // Defer behavior attach to first build (needs context).
  }

  @override
  void didUpdateWidget(covariant OiFlowChart<TNode, TLink> oldWidget) {
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
    return 'Flow chart';
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
              if (mounted) {
                attachBehaviors();
                registerSync();
              }
            });
          }

          final content =
              widget.seriesBuilder?.call(context, _viewport, widget.series) ??
              SizedBox(width: w, height: h);

          return wrapWithPointerListener(
            SizedBox(width: w, height: h, child: content),
          );
        },
      ),
    );
  }
}
