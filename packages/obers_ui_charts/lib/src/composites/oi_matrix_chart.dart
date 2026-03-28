import 'package:flutter/widgets.dart';
import 'package:obers_ui_charts/src/components/oi_chart_empty_state.dart';
import 'package:obers_ui_charts/src/components/oi_chart_error_state.dart';
import 'package:obers_ui_charts/src/components/oi_chart_loading_state.dart';
import 'package:obers_ui_charts/src/composites/_chart_behavior_host.dart';
import 'package:obers_ui_charts/src/composites/_chart_streaming_host.dart';
import 'package:obers_ui_charts/src/composites/oi_chart_axis.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_accessibility_config.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_hit_tester.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_sync_group.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_viewport.dart';
// Imported for future annotation/threshold support on matrix charts.
// ignore: unused_import
import 'package:obers_ui_charts/src/models/oi_chart_annotation.dart';
import 'package:obers_ui_charts/src/models/oi_chart_series.dart';
import 'package:obers_ui_charts/src/models/oi_chart_settings.dart';
// Imported for future annotation/threshold support on matrix charts.
// ignore: unused_import
import 'package:obers_ui_charts/src/models/oi_chart_threshold.dart';
import 'package:obers_ui_charts/src/models/oi_color_scale.dart';
import 'package:obers_ui_charts/src/models/oi_matrix_series.dart';

/// Base composite widget for cell-grid chart types (heatmap, correlation).
///
/// Orchestrates: cell grid layout, color scale mapping, axis rendering,
/// and cell-level hit testing.
///
/// {@category Composites}
class OiMatrixChart<T> extends StatefulWidget {
  /// Creates a matrix chart.
  const OiMatrixChart({
    required this.label, required this.series, super.key,
    this.xAxis,
    this.yAxis,
    this.colorScale,
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

  /// The data series to render.
  final List<OiMatrixSeries<T>> series;

  /// X-axis configuration.
  final OiChartAxis<dynamic>? xAxis;

  /// Y-axis configuration.
  final OiChartAxis<dynamic>? yAxis;

  /// Color scale for mapping cell values to colors.
  final OiColorScale? colorScale;

  /// Builder that renders matrix series data.
  final Widget Function(
    BuildContext context,
    OiChartViewport viewport,
    List<OiMatrixSeries<T>> visibleSeries,
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
  State<OiMatrixChart<T>> createState() => _OiMatrixChartState<T>();
}

class _OiMatrixChartState<T> extends State<OiMatrixChart<T>>
    with
        ChartBehaviorHost<OiMatrixChart<T>>,
        ChartStreamingHost<OiMatrixChart<T>> {
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

  // ── ChartStreamingHost overrides ───────────────────────────────────

  @override
  List<OiChartSeries<dynamic>> get streamingSeries => widget.series;

  // ── Lifecycle ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    restoreSettings(widget.settings);
    attachStreamingAdapters();
    // Defer behavior attach to first build (needs context).
  }

  @override
  void didUpdateWidget(covariant OiMatrixChart<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.behaviors != widget.behaviors ||
        oldWidget.controller != widget.controller) {
      attachBehaviors();
    }
  }

  @override
  void dispose() {
    detachStreamingAdapters();
    disposeBehaviorHost();
    super.dispose();
  }

  // ── Series helpers ───────────────────────────────────────────────────

  List<OiMatrixSeries<T>> get _visibleSeries {
    final legend = effectiveController.legendState;
    return widget.series
        .where((s) => s.visible && legend.isVisible(s.id))
        .toList();
  }

  bool get _hasData =>
      _visibleSeries.any((s) => s.data != null && s.data!.isNotEmpty);

  bool get _allSeriesHidden =>
      widget.series.isNotEmpty &&
      widget.series.every(
        (s) => !s.visible || !effectiveController.legendState.isVisible(s.id),
      );

  String get _effectiveLabel {
    if (widget.semanticLabel != null) return widget.semanticLabel!;
    if (widget.label.isNotEmpty) return widget.label;
    return 'Matrix chart';
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
              widget.seriesBuilder?.call(context, _viewport, _visibleSeries) ??
              SizedBox(width: w, height: h);

          return wrapWithPointerListener(
            SizedBox(width: w, height: h, child: content),
          );
        },
      ),
    );
  }
}
