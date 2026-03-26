import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/_chart_grid_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_chart_axis.dart';
import 'package:obers_ui_charts/src/composites/oi_waterfall_chart/oi_waterfall_data.dart';
import 'package:obers_ui_charts/src/composites/oi_waterfall_chart/oi_waterfall_painter.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';

/// A waterfall chart that visualises how individual positive and negative
/// values contribute to a cumulative total.
///
/// Each bar "floats" at the position where the previous bar ended, making
/// cumulative build-up or break-down immediately visible. A subset of bars
/// can be marked as totals — these always start at the baseline and show the
/// full running total.
///
/// ## Example
///
/// ```dart
/// OiWaterfallChart<RevenueItem>(
///   label: 'Revenue Breakdown',
///   series: [
///     OiWaterfallSeries<RevenueItem>(
///       id: 'breakdown',
///       label: 'Revenue',
///       data: items,
///       categoryMapper: (item) => item.name,
///       valueMapper: (item) => item.amount,
///       isTotal: (item) => item.isTotal,
///     ),
///   ],
///   showConnectors: true,
/// )
/// ```
///
/// {@category Composites}
class OiWaterfallChart<T> extends StatefulWidget {
  /// Creates an [OiWaterfallChart].
  const OiWaterfallChart({
    required this.label,
    required this.series,
    super.key,
    this.showConnectors = true,
    this.positiveColor,
    this.negativeColor,
    this.totalColor,
    this.showGrid = true,
    this.yAxis,
    this.behaviors = const [],
    this.controller,
    this.compact,
    this.emptyState,
    this.semanticLabel,
  });

  /// Accessibility label for the chart.
  final String label;

  /// The data series to render.
  final List<OiWaterfallSeries<T>> series;

  /// Whether to draw connector lines between consecutive bar tops.
  /// Defaults to `true`.
  final bool showConnectors;

  /// Color for positive incremental bars.
  /// When null, derived from `context.colors.chartPalette.positive`.
  final Color? positiveColor;

  /// Color for negative incremental bars.
  /// When null, derived from `context.colors.chartPalette.negative`.
  final Color? negativeColor;

  /// Color for total/summary bars.
  /// When null, derived from `context.colors.chartPalette.neutral`.
  final Color? totalColor;

  /// Whether to show grid lines. Defaults to `true`.
  final bool showGrid;

  /// Configuration for the y-axis.
  final OiChartAxis<num>? yAxis;

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
  State<OiWaterfallChart<T>> createState() => _OiWaterfallChartState<T>();
}

class _OiWaterfallChartState<T> extends State<OiWaterfallChart<T>> {
  static const double _compactThreshold = 400;
  static const double _minViableWidth = 120;
  static const double _minViableHeight = 80;

  bool get _isEmpty =>
      widget.series.isEmpty || widget.series.every((s) => s.data.isEmpty);

  String get _effectiveLabel =>
      widget.semanticLabel ??
      (widget.label.isNotEmpty ? widget.label : 'Waterfall chart');

  /// Computes bars for all visible series, returning a flat list.
  ///
  /// Only the first visible series is rendered for simplicity; multi-series
  /// waterfall charts would require overlapping or grouped layout.
  List<OiWaterfallBar> _computeBars() {
    for (final s in widget.series) {
      if (!s.visible || s.data.isEmpty) continue;
      return computeWaterfallBars(s);
    }
    return const [];
  }

  ({double minY, double maxY}) _computeRange(List<OiWaterfallBar> bars) {
    var minY = double.infinity;
    var maxY = double.negativeInfinity;

    for (final bar in bars) {
      minY = math.min(minY, math.min(bar.barStart, bar.barEnd));
      maxY = math.max(maxY, math.max(bar.barStart, bar.barEnd));
    }

    // Always include zero so bars with only positive values anchor to baseline.
    minY = math.min(minY, 0);
    maxY = math.max(maxY, 0);

    // Apply 5 % padding on the max end.
    final padding = (maxY - minY) * 0.05;

    return (
      minY: widget.yAxis?.min ?? (minY.isFinite ? minY - padding : -1),
      maxY: widget.yAxis?.max ?? (maxY.isFinite ? maxY + padding : 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) {
      return widget.emptyState ??
          const SizedBox.shrink(key: Key('oi_waterfall_chart_empty'));
    }

    final colors = context.colors;
    final isHighContrast = OiA11y.highContrast(context);
    final palette = OiChartPalette.colors(colors);

    final positiveColor = widget.positiveColor ?? palette.positive;
    final negativeColor = widget.negativeColor ?? palette.negative;
    final totalColor = widget.totalColor ?? palette.neutral;

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
                key: const Key('oi_waterfall_chart_fallback'),
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
          final bars = _computeBars();

          if (bars.isEmpty) {
            return widget.emptyState ??
                const SizedBox.shrink(key: Key('oi_waterfall_chart_empty'));
          }

          final range = _computeRange(bars);
          final chartSize = Size(
            w,
            math.min(h, isCompact ? w * 0.6 : w * 0.75),
          );
          final chartRect = OiChartGrid.computeChartRect(
            chartSize,
            compact: isCompact,
          );

          // Build category x-axis labels from bar categories.
          final xLabels = bars.map((b) => b.category).toList();

          // Build y-axis tick labels.
          final yDiv = widget.yAxis?.divisions ?? (isCompact ? 3 : 5);
          final rY = range.maxY - range.minY;
          final yLabels =
              widget.yAxis?.labels ??
              List.generate(
                yDiv + 1,
                (i) => (widget.yAxis ?? const OiChartAxis()).formatValue(
                  range.minY + (rY == 0 ? 0 : rY * i / yDiv),
                ),
              );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  key: const Key('oi_waterfall_chart_canvas'),
                  width: chartSize.width,
                  height: chartSize.height,
                  child: CustomPaint(
                    key: const Key('oi_waterfall_chart_painter'),
                    size: chartSize,
                    painter: OiWaterfallPainter(
                      bars: bars,
                      chartRect: chartRect,
                      minY: range.minY,
                      maxY: range.maxY,
                      positiveColor: positiveColor,
                      negativeColor: negativeColor,
                      totalColor: totalColor,
                      showConnectors: widget.showConnectors,
                      showGrid: widget.showGrid,
                      gridColor: colors.borderSubtle,
                      axisLabelColor: colors.textMuted,
                      highContrast: isHighContrast,
                      compact: isCompact,
                      xLabels: xLabels,
                      yLabels: yLabels,
                      yDivisions: yDiv,
                    ),
                  ),
                ),
              ),
              if (!isCompact)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _WaterfallLegend(
                    positiveColor: positiveColor,
                    negativeColor: negativeColor,
                    totalColor: totalColor,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// A compact legend strip showing positive / negative / total color meanings.
class _WaterfallLegend extends StatelessWidget {
  const _WaterfallLegend({
    required this.positiveColor,
    required this.negativeColor,
    required this.totalColor,
  });

  final Color positiveColor;
  final Color negativeColor;
  final Color totalColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      key: const Key('oi_waterfall_chart_legend'),
      spacing: 16,
      runSpacing: 4,
      children: [
        _LegendItem(
          color: positiveColor,
          label: 'Increase',
          textColor: colors.textMuted,
        ),
        _LegendItem(
          color: negativeColor,
          label: 'Decrease',
          textColor: colors.textMuted,
        ),
        _LegendItem(
          color: totalColor,
          label: 'Total',
          textColor: colors.textMuted,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.textColor,
  });

  final Color color;
  final String label;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        OiLabel.caption(label, color: textColor),
      ],
    );
  }
}
