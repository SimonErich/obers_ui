import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/_chart_grid_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_chart_axis.dart';
import 'package:obers_ui_charts/src/composites/oi_box_plot_chart/oi_box_plot_data.dart';
import 'package:obers_ui_charts/src/composites/oi_box_plot_chart/oi_box_plot_painter.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';

/// A box plot (box-and-whisker) chart for visualising statistical distributions.
///
/// Renders a five-number summary (minimum, Q1, median, Q3, maximum) for each
/// category, with optional mean dots, confidence-interval notches, and outlier
/// scatter points.
///
/// Supports two data APIs via [OiBoxPlotSeries]:
/// - **Raw-values API** — supply `valuesMapper` to provide raw measurements;
///   statistics are computed automatically using [computeBoxPlotStats].
/// - **Pre-computed API** — supply individual stat mappers when the domain
///   model already stores Q1/median/Q3/etc.
///
/// ## Example
///
/// ```dart
/// OiBoxPlotChart<Department>(
///   label: 'Salary Distribution',
///   series: [
///     OiBoxPlotSeries<Department>(
///       id: 'salaries',
///       label: 'Salaries by Department',
///       data: departments,
///       categoryMapper: (d) => d.name,
///       valuesMapper: (d) => d.salaries,
///     ),
///   ],
///   showMean: true,
///   whiskerMode: OiWhiskerMode.iqr1_5,
/// )
/// ```
///
/// {@category Composites}
class OiBoxPlotChart<T> extends StatefulWidget {
  /// Creates an [OiBoxPlotChart].
  const OiBoxPlotChart({
    required this.label,
    required this.series,
    super.key,
    this.showMean = false,
    this.showNotch = false,
    this.whiskerMode = OiWhiskerMode.minMax,
    this.horizontal = false,
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
  final List<OiBoxPlotSeries<T>> series;

  /// Whether to draw a dot at the mean value inside each box.
  /// Defaults to `false`.
  final bool showMean;

  /// Whether to draw a confidence-interval notch at the median.
  /// Defaults to `false`.
  final bool showNotch;

  /// How whisker extents are computed. Defaults to [OiWhiskerMode.minMax].
  final OiWhiskerMode whiskerMode;

  /// When `true`, categories run along the y-axis and values along the x-axis.
  /// Defaults to `false` (vertical orientation).
  final bool horizontal;

  /// Whether to show grid lines. Defaults to `true`.
  final bool showGrid;

  /// Configuration for the value axis.
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
  State<OiBoxPlotChart<T>> createState() => _OiBoxPlotChartState<T>();
}

class _OiBoxPlotChartState<T> extends State<OiBoxPlotChart<T>> {
  static const double _compactThreshold = 400;
  static const double _minViableWidth = 120;
  static const double _minViableHeight = 80;

  bool get _isEmpty =>
      widget.series.isEmpty || widget.series.every((s) => s.data.isEmpty);

  String get _effectiveLabel =>
      widget.semanticLabel ??
      (widget.label.isNotEmpty ? widget.label : 'Box plot chart');

  List<OiResolvedBox> _buildBoxes(BuildContext context) {
    final palette = context.colors.chart;
    return resolveBoxes(widget.series, widget.whiskerMode, palette);
  }

  ({double minY, double maxY}) _computeRange(List<OiResolvedBox> boxes) {
    var minY = double.infinity;
    var maxY = double.negativeInfinity;

    for (final box in boxes) {
      final s = box.stats;
      minY = math.min(minY, s.min);
      maxY = math.max(maxY, s.max);
      for (final outlier in s.outliers) {
        minY = math.min(minY, outlier);
        maxY = math.max(maxY, outlier);
      }
    }

    // Ensure valid range.
    if (!minY.isFinite) minY = 0;
    if (!maxY.isFinite) maxY = 1;

    // 5 % padding.
    final padding = (maxY - minY) * 0.05;
    return (
      minY: widget.yAxis?.min ?? (minY - padding),
      maxY: widget.yAxis?.max ?? (maxY + padding),
    );
  }

  /// Collects category labels in the order they appear in the resolved boxes
  /// (unique, preserving first-occurrence order).
  List<String> _buildCategoryLabels(List<OiResolvedBox> boxes) {
    final seen = <String>{};
    final labels = <String>[];
    for (final box in boxes) {
      if (seen.add(box.category)) {
        labels.add(box.category);
      }
    }
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) {
      return widget.emptyState ??
          const SizedBox.shrink(key: Key('oi_box_plot_chart_empty'));
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
                key: const Key('oi_box_plot_chart_fallback'),
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
          final boxes = _buildBoxes(context);

          if (boxes.isEmpty) {
            return widget.emptyState ??
                const SizedBox.shrink(key: Key('oi_box_plot_chart_empty'));
          }

          final range = _computeRange(boxes);
          final categoryLabels = _buildCategoryLabels(boxes);
          final categoryCount = categoryLabels.length;

          final chartSize = Size(
            w,
            math.min(h, isCompact ? w * 0.6 : w * 0.75),
          );
          final chartRect = OiChartGrid.computeChartRect(
            chartSize,
            compact: isCompact,
          );

          // Build value-axis tick labels.
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
                  key: const Key('oi_box_plot_chart_canvas'),
                  width: chartSize.width,
                  height: chartSize.height,
                  child: CustomPaint(
                    key: const Key('oi_box_plot_chart_painter'),
                    size: chartSize,
                    painter: OiBoxPlotPainter(
                      boxes: boxes,
                      categoryCount: categoryCount,
                      chartRect: chartRect,
                      minY: range.minY,
                      maxY: range.maxY,
                      showMean: widget.showMean,
                      showNotch: widget.showNotch,
                      horizontal: widget.horizontal,
                      showGrid: widget.showGrid,
                      gridColor: colors.borderSubtle,
                      axisLabelColor: colors.textMuted,
                      highContrast: isHighContrast,
                      compact: isCompact,
                      categoryLabels: categoryLabels,
                      yLabels: yLabels,
                      yDivisions: yDiv,
                    ),
                  ),
                ),
              ),
              if (!isCompact && widget.series.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _BoxPlotLegend(
                    series: widget.series,
                    palette: colors.chart,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// A simple legend for multi-series box plots.
class _BoxPlotLegend<T> extends StatelessWidget {
  const _BoxPlotLegend({required this.series, required this.palette});

  final List<OiBoxPlotSeries<T>> series;
  final List<Color> palette;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      key: const Key('oi_box_plot_chart_legend'),
      spacing: 16,
      runSpacing: 4,
      children: [
        for (var i = 0; i < series.length; i++)
          if (series[i].visible)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: series[i].color ?? palette[i % palette.length],
                ),
                const SizedBox(width: 4),
                OiLabel.caption(series[i].label, color: colors.textMuted),
              ],
            ),
      ],
    );
  }
}
