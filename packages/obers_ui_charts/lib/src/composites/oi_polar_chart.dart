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
// Imported for future annotation/threshold support on polar charts.
// ignore: unused_import
import 'package:obers_ui_charts/src/models/oi_chart_annotation.dart';
// Imported for future annotation/threshold support on polar charts.
// ignore: unused_import
import 'package:obers_ui_charts/src/models/oi_chart_threshold.dart';
import 'package:obers_ui_charts/src/models/oi_polar_series.dart';

/// Base composite widget for radial/polar chart types (pie, donut, radar).
///
/// Orchestrates arc layout, radial label placement, center content,
/// angular hit testing, and behavior dispatch.
///
/// {@category Composites}
class OiPolarChart<T> extends StatefulWidget {
  /// Creates a polar chart.
  const OiPolarChart({
    super.key,
    required this.label,
    required this.series,
    this.seriesBuilder,
    this.centerContent,
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

  /// The data series to render.
  final List<OiPolarSeries<T>> series;

  /// Builder that renders polar series data.
  final Widget Function(
    BuildContext context,
    OiChartViewport viewport,
    List<OiPolarSeries<T>> visibleSeries,
  )?
  seriesBuilder;

  /// Optional content to display in the center (e.g., donut label).
  final Widget? centerContent;

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
  State<OiPolarChart<T>> createState() => _OiPolarChartState<T>();
}

class _OiPolarChartState<T> extends State<OiPolarChart<T>>
    with ChartBehaviorHost<OiPolarChart<T>> {
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
  void didUpdateWidget(covariant OiPolarChart<T> oldWidget) {
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

  List<OiPolarSeries<T>> get _visibleSeries {
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
    final count = widget.series.length;
    return 'Polar chart with $count ${count == 1 ? 'series' : 'series'}';
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
          final h = constraints.maxHeight.isFinite ? constraints.maxHeight : w;

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
