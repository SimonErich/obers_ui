import 'dart:math' show Point;

import 'package:flutter/widgets.dart';

import 'package:obers_ui_charts/src/components/oi_chart_empty_state.dart';
import 'package:obers_ui_charts/src/components/oi_chart_error_state.dart';
import 'package:obers_ui_charts/src/components/oi_chart_loading_state.dart';
import 'package:obers_ui_charts/src/composites/_chart_behavior_host.dart';
import 'package:obers_ui_charts/src/composites/_chart_streaming_host.dart';
import 'package:obers_ui_charts/src/composites/oi_chart_axis.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_accessibility_config.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_animation_config.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_hit_tester.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_performance_config.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_sync_group.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_viewport.dart';
import 'package:obers_ui/obers_ui.dart' show OiChartThemeData, OiResponsive;

import 'package:obers_ui_charts/src/models/oi_chart_complexity.dart';

import 'package:obers_ui_charts/src/foundation/oi_decimation.dart';
import 'package:obers_ui_charts/src/utils/chart_math.dart';

import 'package:obers_ui_charts/src/models/oi_cartesian_series.dart';
import 'package:obers_ui_charts/src/models/oi_chart_datum.dart';
import 'package:obers_ui_charts/src/models/oi_chart_series.dart';
import 'package:obers_ui_charts/src/models/oi_chart_annotation.dart';
import 'package:obers_ui_charts/src/models/oi_chart_legend_config.dart';
import 'package:obers_ui_charts/src/models/oi_chart_settings.dart';
import 'package:obers_ui_charts/src/models/oi_chart_threshold.dart';

/// Base composite widget for all cartesian (x/y) chart types.
///
/// This is the **power API** for cartesian charts. It provides full access to:
/// - Mapper-first data binding via [OiCartesianSeries] subclasses
/// - Composable [behaviors] (tooltip, crosshair, zoom, selection, etc.)
/// - Chart [controller] for programmatic state management
/// - [annotations] and [thresholds] for reference lines
/// - [performance] config with automatic decimation
/// - [settings] persistence via OiSettingsDriver
/// - [syncGroup] for multi-chart synchronization
/// - Data normalization pipeline producing [OiChartDatum] lists
///
/// For simpler usage with pre-mapped data, use the convenience wrappers:
/// [OiLineChart], [OiBarChart], [OiBubbleChart], etc.
///
/// Concrete chart types provide a [seriesBuilder] that paints series data
/// within the computed chart area.
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
    this.annotations = const [],
    this.thresholds = const [],
    this.legend,
    this.settings,
    this.theme,
    this.complexity,
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

  /// Annotation overlays (lines, regions, points, labels).
  final List<OiChartAnnotation> annotations;

  /// Threshold lines.
  final List<OiChartThreshold> thresholds;

  /// Legend configuration.
  final OiChartLegendConfig? legend;

  /// Persistence settings.
  final OiChartSettings? settings;

  /// Chart theme override. Falls back to context.components.chart.
  final OiChartThemeData? theme;

  /// Responsive complexity level for visual detail adaptation.
  final OiResponsive<OiChartComplexity>? complexity;

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

class _OiCartesianChartState<T> extends State<OiCartesianChart<T>>
    with
        ChartBehaviorHost<OiCartesianChart<T>>,
        ChartStreamingHost<OiCartesianChart<T>> {
  OiChartViewport _viewport = const OiChartViewport(size: Size.zero);

  /// Cached normalized data from the last build, keyed by series id.
  // Cached for future use by seriesBuilder once the API is exposed.
  // ignore: unused_field
  Map<String, List<OiChartDatum>> _lastNormalizedData = const {};

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

  // ── ChartStreamingHost overrides ───────────────────────────────────

  @override
  List<OiChartSeries<dynamic>> get streamingSeries => widget.series;

  // ── Sync override ──────────────────────────────────────────────────

  @override
  OiChartSyncGroup? get syncGroup => widget.syncGroup;

  // ── Lifecycle ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    attachStreamingAdapters();
    restoreSettings(widget.settings);
  }

  @override
  void didUpdateWidget(covariant OiCartesianChart<T> oldWidget) {
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

  List<OiCartesianSeries<T>> get _visibleSeries {
    final legend = effectiveController.legendState;
    return widget.series
        .where((s) => s.visible && legend.isVisible(s.id))
        .toList();
  }

  bool get _hasData =>
      _visibleSeries.any((s) => s.data != null && s.data!.isNotEmpty);

  /// Normalizes visible series into OiChartDatum lists.
  ///
  /// Returns a map of seriesId → normalized datums.
  Map<String, List<OiChartDatum>> _normalizeVisibleSeries() {
    final result = <String, List<OiChartDatum>>{};
    for (final s in _visibleSeries) {
      if (s.data == null || s.data!.isEmpty) continue;
      result[s.id] = normalizeSeries(
        seriesId: s.id,
        data: s.data!,
        xMapper: s.xMapper,
        yMapper: s.yMapper,
        pointLabel: s.pointLabel,
        isMissing: s.isMissing,
      );
    }
    return result;
  }

  /// Applies decimation to normalized data when performance config requires it.
  Map<String, List<OiChartDatum>> _applyDecimation(
    Map<String, List<OiChartDatum>> data,
  ) {
    final perf = widget.performance;
    if (perf == null) return data;
    if (perf.decimationStrategy == OiChartDecimationStrategy.none) return data;

    final maxPoints = perf.maxInteractivePoints;
    final result = <String, List<OiChartDatum>>{};

    for (final entry in data.entries) {
      final datums = entry.value;
      if (datums.length <= maxPoints) {
        result[entry.key] = datums;
        continue;
      }

      // Convert to Point<double> for decimation.
      final points = <Point<double>>[
        for (final d in datums)
          Point(
            (d.xRaw is num) ? (d.xRaw! as num).toDouble() : d.index.toDouble(),
            (d.yRaw is num) ? (d.yRaw! as num).toDouble() : 0,
          ),
      ];

      final List<Point<double>> decimated;
      if (perf.decimationStrategy == OiChartDecimationStrategy.lttb) {
        decimated = decimateLttb(points, targetCount: maxPoints);
      } else {
        decimated = decimateMinMax(points, targetCount: maxPoints);
      }

      // Map back to datums by index matching.
      final decimatedSet = decimated.toSet();
      result[entry.key] = [
        for (var i = 0; i < datums.length; i++)
          if (decimatedSet.contains(points[i])) datums[i],
      ];
    }

    return result;
  }

  /// Total data point count across all visible series.
  int get _totalPointCount {
    var count = 0;
    for (final s in _visibleSeries) {
      count += s.data?.length ?? 0;
    }
    return count;
  }

  /// Whether the chart has exactly one data point total (needs padding).
  bool get _isSinglePoint => _totalPointCount == 1;

  bool get _allSeriesHidden =>
      widget.series.isNotEmpty &&
      widget.series.every(
        (s) => !s.visible || !effectiveController.legendState.isVisible(s.id),
      );

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

          // Build visible domain for single-point padding.
          Rect? visibleDomain;
          if (_isSinglePoint) {
            // Find the single data point's x-value for domain padding.
            for (final s in _visibleSeries) {
              if (s.data != null && s.data!.isNotEmpty) {
                final xVal = s.xMapper(s.data!.first);
                if (xVal is num) {
                  final pad = domainPaddingForSinglePoint(xVal.toDouble());
                  visibleDomain = Rect.fromLTRB(xVal - pad, 0, xVal + pad, 0);
                }
                break;
              }
            }
          }

          _viewport = OiChartViewport(
            size: Size(w, h),
            devicePixelRatio:
                MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0,
            zoomLevel: ctrl.viewportState.zoomLevel,
            panOffset: ctrl.viewportState.panOffset,
            visibleDomain: visibleDomain,
          );

          // Normalize series data through the foundation pipeline.
          _lastNormalizedData = _applyDecimation(_normalizeVisibleSeries());

          // Attach behaviors and sync now that we have a valid context.
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
