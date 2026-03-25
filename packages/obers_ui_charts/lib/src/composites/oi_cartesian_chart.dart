import 'package:flutter/widgets.dart';

import 'package:obers_ui_charts/src/components/oi_chart_empty_state.dart';
import 'package:obers_ui_charts/src/components/oi_chart_error_state.dart';
import 'package:obers_ui_charts/src/components/oi_chart_loading_state.dart';
import 'package:obers_ui_charts/src/composites/oi_chart_axis.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_accessibility_config.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_animation_config.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_performance_config.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_sync_group.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_viewport.dart';
import 'package:obers_ui_charts/src/models/oi_cartesian_series.dart';

/// Base composite widget for all cartesian (x/y) chart types.
///
/// Orchestrates: viewport calculation, scale resolution, behavior dispatch,
/// accessibility tree, persistence integration, and sync group registration.
///
/// Concrete chart types (line, bar, area, scatter) provide a [seriesBuilder]
/// that paints series data within the computed chart area.
///
/// {@category Composites}
class OiCartesianChart<T> extends StatefulWidget {
  /// Creates a cartesian chart.
  const OiCartesianChart({
    super.key,
    required this.label,
    required this.series,
    this.xAxis,
    this.yAxes,
    this.seriesBuilder,
    this.behaviors = const [],
    this.controller,
    this.syncGroup,
    this.accessibility,
    this.animation,
    this.performance,
    this.emptyState,
    this.loadingState,
    this.errorState,
    this.semanticLabel,
  });

  /// Accessibility label for the chart.
  final String label;

  /// The data series to render.
  final List<OiCartesianSeries<T>> series;

  /// X-axis configuration.
  final OiChartAxis<dynamic>? xAxis;

  /// Y-axis configurations (supports multi-axis).
  final List<OiChartAxis<num>>? yAxes;

  /// Builder that renders series data within the chart area.
  ///
  /// Receives the current [OiChartViewport] and the resolved series list.
  /// If null, the chart renders only its frame (axes, grid, surface).
  final Widget Function(
    BuildContext context,
    OiChartViewport viewport,
    List<OiCartesianSeries<T>> visibleSeries,
  )?
  seriesBuilder;

  /// Composable interaction behaviors.
  final List<OiChartBehavior> behaviors;

  /// External chart controller. If null, an internal controller is created.
  final OiChartController? controller;

  /// Sync group for linking multiple charts.
  final OiChartSyncGroup? syncGroup;

  /// Accessibility configuration.
  final OiChartAccessibilityConfig? accessibility;

  /// Animation configuration.
  final OiChartAnimationConfig? animation;

  /// Performance configuration.
  final OiChartPerformanceConfig? performance;

  /// Custom empty state widget.
  final Widget? emptyState;

  /// Custom loading state widget.
  final Widget? loadingState;

  /// Custom error state widget.
  final Widget? errorState;

  /// Override for the semantic label.
  final String? semanticLabel;

  @override
  State<OiCartesianChart<T>> createState() => _OiCartesianChartState<T>();
}

class _OiCartesianChartState<T> extends State<OiCartesianChart<T>> {
  OiChartViewport _viewport = const OiChartViewport(size: Size.zero);

  List<OiCartesianSeries<T>> get _visibleSeries =>
      widget.series.where((s) => s.visible).toList();

  bool get _hasData =>
      _visibleSeries.any((s) => s.data != null && s.data!.isNotEmpty);

  String get _effectiveLabel {
    if (widget.semanticLabel != null) return widget.semanticLabel!;
    if (widget.label.isNotEmpty) return widget.label;
    final count = widget.series.length;
    return 'Cartesian chart with $count ${count == 1 ? 'series' : 'series'}';
  }

  OiAxisScaleType _inferScaleType(OiCartesianSeries<T> series) {
    if (series.data == null || series.data!.isEmpty) {
      return OiAxisScaleType.linear;
    }
    final sample = series.xMapper(series.data!.first);
    if (sample is DateTime) return OiAxisScaleType.time;
    if (sample is String) return OiAxisScaleType.category;
    return OiAxisScaleType.linear;
  }

  /// The resolved x-axis scale type, auto-inferred from data if not explicit.
  OiAxisScaleType get resolvedXScaleType {
    if (widget.xAxis?.scaleType != null) return widget.xAxis!.scaleType!;
    final visible = _visibleSeries;
    if (visible.isEmpty) return OiAxisScaleType.linear;
    return _inferScaleType(visible.first);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.controller?.isLoading ?? false;
    final error = widget.controller?.error;

    // Loading state
    if (isLoading) {
      return widget.loadingState ?? const OiChartLoadingState();
    }

    // Error state
    if (error != null) {
      return widget.errorState ?? OiChartErrorState(message: error);
    }

    // Empty state
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
          );

          final content =
              widget.seriesBuilder?.call(context, _viewport, _visibleSeries) ??
              SizedBox(width: w, height: h);

          return SizedBox(width: w, height: h, child: content);
        },
      ),
    );
  }
}
