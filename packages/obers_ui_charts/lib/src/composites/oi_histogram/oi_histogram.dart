import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/_chart_grid_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_chart_axis.dart';
import 'package:obers_ui_charts/src/composites/oi_histogram/oi_histogram_data.dart';
import 'package:obers_ui_charts/src/composites/oi_histogram/oi_histogram_painter.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';

/// A histogram chart for visualising frequency distributions.
///
/// Groups continuous numeric data into equal-width bins and renders each bin
/// as a filled rectangle. Multiple series are supported and rendered
/// side-by-side using the chart palette.
///
/// Use [OiHistogram.fromValues] for the simple single-series case where only a
/// flat `List<double>` is available.
///
/// ## Example
///
/// ```dart
/// OiHistogram<Person>(
///   label: 'Age Distribution',
///   series: [
///     OiHistogramSeries<Person>(
///       id: 'ages',
///       label: 'Ages',
///       data: people,
///       valueMapper: (p) => p.age,
///       binCount: 10,
///     ),
///   ],
///   cumulative: false,
///   normalized: false,
/// )
/// ```
///
/// {@category Composites}
class OiHistogram<T> extends StatefulWidget {
  /// Creates an [OiHistogram].
  const OiHistogram({
    required this.label,
    required this.series,
    super.key,
    this.xAxis,
    this.yAxis,
    this.showGrid = true,
    this.barGap = 0,
    this.cumulative = false,
    this.normalized = false,
    this.behaviors = const [],
    this.controller,
    this.compact,
    this.emptyState,
    this.semanticLabel,
  });

  /// Creates a histogram from a simple list of numeric values.
  ///
  /// A default [OiHistogramSeries] is created internally with a series
  /// identifier of `'values'` and [label] equal to the chart label.
  static OiHistogram<double> fromValues({
    required String label,
    required List<double> values,
    int? binCount,
    double? binWidth,
    Key? key,
    OiChartAxis<num>? xAxis,
    OiChartAxis<num>? yAxis,
    bool showGrid = true,
    bool cumulative = false,
    bool normalized = false,
    List<OiChartBehavior> behaviors = const [],
    OiChartController? controller,
    bool? compact,
    Widget? emptyState,
    String? semanticLabel,
  }) {
    return OiHistogram<double>(
      key: key,
      label: label,
      series: [
        OiHistogramSeries<double>(
          id: 'values',
          label: label,
          data: values,
          valueMapper: (v) => v,
          binCount: binCount,
          binWidth: binWidth,
        ),
      ],
      xAxis: xAxis,
      yAxis: yAxis,
      showGrid: showGrid,
      cumulative: cumulative,
      normalized: normalized,
      behaviors: behaviors,
      controller: controller,
      compact: compact,
      emptyState: emptyState,
      semanticLabel: semanticLabel,
    );
  }

  /// Accessibility label for the chart.
  final String label;

  /// The data series to render.
  final List<OiHistogramSeries<T>> series;

  /// Configuration for the x-axis (bin range).
  final OiChartAxis<num>? xAxis;

  /// Configuration for the y-axis (count or frequency).
  final OiChartAxis<num>? yAxis;

  /// Whether to show grid lines. Defaults to `true`.
  final bool showGrid;

  /// Gap between adjacent bins in logical pixels.
  ///
  /// Defaults to `0` (histogram convention — touching bars). Set to a positive
  /// value for a visual separation.
  final double barGap;

  /// Whether to draw a cumulative frequency line overlay. Defaults to `false`.
  final bool cumulative;

  /// When `true`, the y-axis shows relative frequency (0–1) instead of raw
  /// counts. Defaults to `false`.
  final bool normalized;

  /// Chart behaviors to attach (e.g. zoom/pan, tooltip).
  final List<OiChartBehavior> behaviors;

  /// Optional external controller for chart state.
  final OiChartController? controller;

  /// Whether to use compact layout. When `null`, determined by available width.
  final bool? compact;

  /// Widget shown when [series] is empty or all series have no data.
  final Widget? emptyState;

  /// Overrides the auto-generated accessibility label.
  final String? semanticLabel;

  @override
  State<OiHistogram<T>> createState() => _OiHistogramState<T>();
}

class _OiHistogramState<T> extends State<OiHistogram<T>> {
  static const double _compactThreshold = 400;
  static const double _minViableWidth = 120;
  static const double _minViableHeight = 80;

  bool get _isEmpty =>
      widget.series.isEmpty || widget.series.every((s) => s.data.isEmpty);

  String get _effectiveLabel =>
      widget.semanticLabel ??
      (widget.label.isNotEmpty ? widget.label : 'Histogram chart');

  /// Resolves the color for a series at [seriesIndex].
  Color _resolveColor(int seriesIndex, BuildContext context) {
    final seriesColor = widget.series[seriesIndex].color;
    if (seriesColor != null) return seriesColor;
    final palette = context.colors.chart;
    return palette[seriesIndex % palette.length];
  }

  /// Compute all bins for all visible series and return resolved series list
  /// alongside global min/max values.
  List<ResolvedHistogramSeries> _buildResolvedSeries(BuildContext context) {
    final resolved = <ResolvedHistogramSeries>[];
    for (var i = 0; i < widget.series.length; i++) {
      final s = widget.series[i];
      if (!s.visible || s.data.isEmpty) continue;

      final rawValues = s.data.map(s.valueMapper).toList();
      final rangeMin = s.binRange?.min;
      final rangeMax = s.binRange?.max;

      final bins = computeBins(
        rawValues,
        binCount: s.binCount,
        binWidth: s.binWidth,
        rangeMin: rangeMin,
        rangeMax: rangeMax,
      );

      resolved.add(
        ResolvedHistogramSeries(
          label: s.label,
          bins: bins,
          color: _resolveColor(i, context),
        ),
      );
    }
    return resolved;
  }

  ({double dataMin, double dataMax, double maxBarValue}) _computeRange(
    List<ResolvedHistogramSeries> resolved,
  ) {
    var dataMin = double.infinity;
    var dataMax = double.negativeInfinity;
    var maxBarValue = 0.0;

    for (final s in resolved) {
      for (final bin in s.bins) {
        dataMin = math.min(dataMin, bin.start);
        dataMax = math.max(dataMax, bin.end);
        final v = widget.normalized ? bin.frequency : bin.count.toDouble();
        maxBarValue = math.max(maxBarValue, v);
      }
    }

    return (
      dataMin: widget.xAxis?.min ?? (dataMin.isFinite ? dataMin : 0),
      dataMax: widget.xAxis?.max ?? (dataMax.isFinite ? dataMax : 1),
      maxBarValue: widget.yAxis?.max ?? (maxBarValue > 0 ? maxBarValue : 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) {
      return widget.emptyState ??
          const SizedBox.shrink(key: Key('oi_histogram_empty'));
    }

    final colors = context.colors;
    final isHighContrast = OiA11y.highContrast(context);

    return Semantics(
      label: _effectiveLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : 300.0;

          if (w < _minViableWidth || h < _minViableHeight) {
            return SizedBox(
              width: w,
              height: h,
              child: Center(
                key: const Key('oi_histogram_fallback'),
                child: FittedBox(
                  child: OiLabel.caption(
                    'Chart too small',
                    color: colors.textMuted,
                  ),
                ),
              ),
            );
          }

          final isCompact = widget.compact ?? (w < _compactThreshold);
          final resolved = _buildResolvedSeries(context);

          if (resolved.isEmpty) {
            return widget.emptyState ??
                const SizedBox.shrink(key: Key('oi_histogram_empty'));
          }

          final range = _computeRange(resolved);
          final chartSize = Size(
            w,
            math.min(h, isCompact ? w * 0.6 : w * 0.75),
          );
          final chartRect = OiChartGrid.computeChartRect(
            chartSize,
            compact: isCompact,
          );

          // Generate axis labels.
          final xDiv = widget.xAxis?.divisions ?? (isCompact ? 3 : 5);
          final yDiv = widget.yAxis?.divisions ?? (isCompact ? 3 : 5);
          final rX = range.dataMax - range.dataMin;
          final rY = range.maxBarValue;

          final xLabels =
              widget.xAxis?.labels ??
              List.generate(
                xDiv + 1,
                (i) => (widget.xAxis ?? const OiChartAxis()).formatValue(
                  range.dataMin + (rX == 0 ? 0 : rX * i / xDiv),
                ),
              );
          final yLabels =
              widget.yAxis?.labels ??
              List.generate(
                yDiv + 1,
                (i) => (widget.yAxis ?? const OiChartAxis()).formatValue(
                  rY == 0 ? 0 : rY * i / yDiv,
                ),
              );

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                key: const Key('oi_histogram_canvas'),
                width: chartSize.width,
                height: chartSize.height,
                child: CustomPaint(
                  key: const Key('oi_histogram_painter'),
                  size: chartSize,
                  painter: OiHistogramPainter(
                    resolvedSeries: resolved,
                    chartRect: chartRect,
                    dataMin: range.dataMin,
                    dataMax: range.dataMax,
                    maxBarValue: range.maxBarValue,
                    showGrid: widget.showGrid,
                    gridColor: colors.borderSubtle,
                    axisLabelColor: colors.textMuted,
                    highContrast: isHighContrast,
                    compact: isCompact,
                    normalized: widget.normalized,
                    cumulative: widget.cumulative,
                    xLabels: xLabels,
                    yLabels: yLabels,
                    xDivisions: xDiv,
                    yDivisions: yDiv,
                  ),
                ),
              ),
              if (resolved.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _HistogramLegend(series: resolved),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// A simple legend row for multi-series histograms.
class _HistogramLegend extends StatelessWidget {
  const _HistogramLegend({required this.series});

  final List<ResolvedHistogramSeries> series;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      key: const Key('oi_histogram_legend'),
      spacing: 16,
      runSpacing: 4,
      children: [
        for (final s in series)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 12, height: 12, color: s.color),
              const SizedBox(width: 4),
              OiLabel.caption(s.label, color: colors.textMuted),
            ],
          ),
      ],
    );
  }
}
