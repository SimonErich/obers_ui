import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/_chart_grid_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_chart_axis.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Series
// ─────────────────────────────────────────────────────────────────────────────

/// A data series for a range bar chart.
///
/// Each item `T` contributes one bar that spans from a [startMapper] value to
/// an [endMapper] value along the value axis, positioned at a category on the
/// category axis.
///
/// Typical use cases: project timelines, Gantt-style views, numeric min–max
/// ranges per category.
///
/// {@category Composites}
class OiRangeBarSeries<T> {
  /// Creates an [OiRangeBarSeries].
  const OiRangeBarSeries({
    required this.id,
    required this.label,
    required this.data,
    required this.categoryMapper,
    required this.startMapper,
    required this.endMapper,
    this.colorMapper,
    this.color,
    this.visible = true,
    this.semanticLabel,
  });

  /// Unique identifier for this series.
  final String id;

  /// Human-readable label for legends and accessibility.
  final String label;

  /// The raw data items.
  final List<T> data;

  /// Extracts the category (y-axis label in horizontal mode) for each bar.
  final String Function(T item) categoryMapper;

  /// Extracts the start value of the bar along the value axis.
  final num Function(T item) startMapper;

  /// Extracts the end value of the bar along the value axis.
  final num Function(T item) endMapper;

  /// Optional per-item color override. When null, [color] is used for all
  /// bars in the series.
  final Color? Function(T item)? colorMapper;

  /// Default series color override. When null, the chart palette is used.
  final Color? color;

  /// Whether this series is visible.
  final bool visible;

  /// Accessibility label for screen readers.
  final String? semanticLabel;
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────────────────────────

/// A range bar chart that renders each bar spanning from a start to an end
/// value per category.
///
/// Particularly suited for Gantt-style timeline visualisations when
/// [horizontal] is `true` (the default). In vertical mode the chart functions
/// as a floating bar chart where bars can start at arbitrary non-zero
/// baselines.
///
/// Multiple [series] can be overlaid on the same category axis.
///
/// ## Example
///
/// ```dart
/// OiRangeBarChart<Project>(
///   label: 'Project Timeline',
///   series: [
///     OiRangeBarSeries<Project>(
///       id: 'projects',
///       label: 'Projects',
///       data: projects,
///       categoryMapper: (p) => p.name,
///       startMapper: (p) => p.startWeek,
///       endMapper: (p) => p.endWeek,
///     ),
///   ],
///   horizontal: true,
/// )
/// ```
///
/// {@category Composites}
class OiRangeBarChart<T> extends StatefulWidget {
  /// Creates an [OiRangeBarChart].
  const OiRangeBarChart({
    required this.label,
    required this.series,
    super.key,
    this.horizontal = true,
    this.showGrid = true,
    this.xAxis,
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
  final List<OiRangeBarSeries<T>> series;

  /// When `true` (default), categories run along the y-axis and the value
  /// axis is horizontal — Gantt-style.
  ///
  /// When `false`, categories run along the x-axis and bars extend vertically.
  final bool horizontal;

  /// Whether to show grid lines. Defaults to `true`.
  final bool showGrid;

  /// Configuration for the x-axis (value axis in horizontal mode, category
  /// axis in vertical mode).
  final OiChartAxis<num>? xAxis;

  /// Configuration for the y-axis (category axis in horizontal mode, value
  /// axis in vertical mode).
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
  State<OiRangeBarChart<T>> createState() => _OiRangeBarChartState<T>();
}

class _OiRangeBarChartState<T> extends State<OiRangeBarChart<T>> {
  static const double _compactThreshold = 400;
  static const double _minViableWidth = 120;
  static const double _minViableHeight = 80;

  bool get _isEmpty =>
      widget.series.isEmpty || widget.series.every((s) => s.data.isEmpty);

  String get _effectiveLabel =>
      widget.semanticLabel ??
      (widget.label.isNotEmpty ? widget.label : 'Range bar chart');

  /// Collects all unique category labels across visible series, preserving
  /// order of first occurrence.
  List<String> _buildCategories() {
    final seen = <String>{};
    final categories = <String>[];
    for (final s in widget.series) {
      if (!s.visible || s.data.isEmpty) continue;
      for (final item in s.data) {
        final cat = s.categoryMapper(item);
        if (seen.add(cat)) categories.add(cat);
      }
    }
    return categories;
  }

  ({double minV, double maxV}) _computeValueRange() {
    var minV = double.infinity;
    var maxV = double.negativeInfinity;
    for (final s in widget.series) {
      if (!s.visible || s.data.isEmpty) continue;
      for (final item in s.data) {
        minV = math.min(minV, s.startMapper(item).toDouble());
        maxV = math.max(maxV, s.endMapper(item).toDouble());
      }
    }
    if (!minV.isFinite) minV = 0;
    if (!maxV.isFinite) maxV = 1;
    // 3 % padding on the far end.
    final padding = (maxV - minV) * 0.03;
    final axisRef = widget.horizontal ? widget.xAxis : widget.yAxis;
    return (
      minV: axisRef?.min ?? (minV - padding),
      maxV: axisRef?.max ?? (maxV + padding),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) {
      return widget.emptyState ??
          const SizedBox.shrink(key: Key('oi_range_bar_chart_empty'));
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
                key: const Key('oi_range_bar_chart_fallback'),
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
          final categories = _buildCategories();
          final valueRange = _computeValueRange();

          if (categories.isEmpty) {
            return widget.emptyState ??
                const SizedBox.shrink(key: Key('oi_range_bar_chart_empty'));
          }

          final chartSize = Size(
            w,
            math.min(h, isCompact ? w * 0.6 : w * 0.75),
          );
          final chartRect = OiChartGrid.computeChartRect(
            chartSize,
            compact: isCompact,
          );

          // Resolve series colors.
          final palette = colors.chart;
          final resolvedColors = <Color>[
            for (var i = 0; i < widget.series.length; i++)
              widget.series[i].color ?? palette[i % palette.length],
          ];

          // Build axis labels.
          final valueDiv = isCompact ? 3 : 5;
          final rV = valueRange.maxV - valueRange.minV;

          final valueAxisRef = widget.horizontal ? widget.xAxis : widget.yAxis;
          final valueLabels =
              valueAxisRef?.labels ??
              List.generate(
                valueDiv + 1,
                (i) => (valueAxisRef ?? const OiChartAxis()).formatValue(
                  valueRange.minV + (rV == 0 ? 0 : rV * i / valueDiv),
                ),
              );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  key: const Key('oi_range_bar_chart_canvas'),
                  width: chartSize.width,
                  height: chartSize.height,
                  child: CustomPaint(
                    key: const Key('oi_range_bar_chart_painter'),
                    size: chartSize,
                    painter: _OiRangeBarPainter<T>(
                      series: widget.series,
                      categories: categories,
                      resolvedColors: resolvedColors,
                      minV: valueRange.minV,
                      maxV: valueRange.maxV,
                      chartRect: chartRect,
                      horizontal: widget.horizontal,
                      showGrid: widget.showGrid,
                      gridColor: colors.borderSubtle,
                      axisLabelColor: colors.textMuted,
                      highContrast: isHighContrast,
                      compact: isCompact,
                      valueLabels: valueLabels,
                      valueDiv: valueDiv,
                    ),
                  ),
                ),
              ),
              if (!isCompact && widget.series.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _RangeBarLegend(
                    series: widget.series,
                    colors: resolvedColors,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _OiRangeBarPainter<T> extends CustomPainter {
  _OiRangeBarPainter({
    required this.series,
    required this.categories,
    required this.resolvedColors,
    required this.minV,
    required this.maxV,
    required this.chartRect,
    required this.horizontal,
    required this.showGrid,
    required this.gridColor,
    required this.axisLabelColor,
    required this.highContrast,
    required this.compact,
    required this.valueLabels,
    required this.valueDiv,
  });

  final List<OiRangeBarSeries<T>> series;
  final List<String> categories;
  final List<Color> resolvedColors;
  final double minV;
  final double maxV;
  final Rect chartRect;
  final bool horizontal;
  final bool showGrid;
  final Color gridColor;
  final Color axisLabelColor;
  final bool highContrast;
  final bool compact;
  final List<String> valueLabels;
  final int valueDiv;

  double get _rangeV {
    final r = maxV - minV;
    return r == 0 ? 1.0 : r;
  }

  /// Maps a value-axis data value to a canvas coordinate.
  double _mapValue(double v) {
    if (horizontal) {
      return chartRect.left + chartRect.width * (v - minV) / _rangeV;
    }
    return chartRect.bottom - chartRect.height * (v - minV) / _rangeV;
  }

  /// Returns the center coordinate of category [index] on the category axis.
  double _categoryCenter(int index) {
    final count = math.max(categories.length, 1);
    if (horizontal) {
      return chartRect.top + chartRect.height * (index + 0.5) / count;
    }
    return chartRect.left + chartRect.width * (index + 0.5) / count;
  }

  /// Half-thickness of a bar in the category direction.
  double _halfBarThickness(int seriesCount) {
    final count = math.max(categories.length, 1);
    final slotSize = horizontal
        ? chartRect.height / count
        : chartRect.width / count;
    // Each bar occupies roughly 70 % of its category slot divided by series
    // count, providing slight spacing between overlapping series.
    return (slotSize * 0.7) / (2 * math.max(seriesCount, 1));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (showGrid) {
      if (horizontal) {
        OiChartGrid.paintGrid(
          canvas,
          chartRect,
          gridColor: gridColor,
          highContrast: highContrast,
          horizontalDivisions: math.max(categories.length, 1),
          verticalDivisions: valueDiv,
        );
      } else {
        OiChartGrid.paintGrid(
          canvas,
          chartRect,
          gridColor: gridColor,
          highContrast: highContrast,
          horizontalDivisions: valueDiv,
          verticalDivisions: math.max(categories.length, 1),
        );
      }
    }

    OiChartGrid.paintAxes(
      canvas,
      chartRect,
      axisColor: gridColor,
      highContrast: highContrast,
    );

    // Paint axis labels — value axis vs category axis.
    if (horizontal) {
      OiChartGrid.paintXLabels(
        canvas,
        chartRect,
        labels: valueLabels,
        labelColor: axisLabelColor,
      );
      OiChartGrid.paintYLabels(
        canvas,
        chartRect,
        labels: categories,
        labelColor: axisLabelColor,
      );
    } else {
      OiChartGrid.paintYLabels(
        canvas,
        chartRect,
        labels: valueLabels,
        labelColor: axisLabelColor,
      );
      OiChartGrid.paintXLabels(
        canvas,
        chartRect,
        labels: categories,
        labelColor: axisLabelColor,
      );
    }

    // Build a category-to-index map for fast lookup.
    final categoryIndex = <String, int>{
      for (var i = 0; i < categories.length; i++) categories[i]: i,
    };

    // Visible series count for bar thickness calculation.
    final visibleCount = series.where((s) => s.visible).length;
    final halfThickness = _halfBarThickness(visibleCount);

    // Offset each series slightly in the category direction when overlapping,
    // so multi-series bars remain distinguishable.
    var visibleSeriesIdx = 0;
    for (var si = 0; si < series.length; si++) {
      final s = series[si];
      if (!s.visible || s.data.isEmpty) continue;

      final seriesColor = resolvedColors[si];
      // Stack offset: shift bar within category slot.
      final stackOffset = visibleCount > 1
          ? (visibleSeriesIdx - (visibleCount - 1) / 2) * halfThickness * 2
          : 0.0;

      for (final item in s.data) {
        final cat = s.categoryMapper(item);
        final idx = categoryIndex[cat];
        if (idx == null) continue;

        final startPos = _mapValue(s.startMapper(item).toDouble());
        final endPos = _mapValue(s.endMapper(item).toDouble());
        final center = _categoryCenter(idx) + stackOffset;

        final barColor = s.colorMapper?.call(item) ?? seriesColor;
        _paintBar(canvas, startPos, endPos, center, halfThickness, barColor);
      }

      visibleSeriesIdx++;
    }
  }

  void _paintBar(
    Canvas canvas,
    double startPos,
    double endPos,
    double center,
    double halfThick,
    Color color,
  ) {
    final Rect rect;
    if (horizontal) {
      final left = math
          .min(startPos, endPos)
          .clamp(chartRect.left, chartRect.right);
      final right = math
          .max(startPos, endPos)
          .clamp(chartRect.left, chartRect.right);
      rect = Rect.fromLTRB(
        left,
        (center - halfThick).clamp(chartRect.top, chartRect.bottom),
        right,
        (center + halfThick).clamp(chartRect.top, chartRect.bottom),
      );
    } else {
      final top = math
          .min(startPos, endPos)
          .clamp(chartRect.top, chartRect.bottom);
      final bottom = math
          .max(startPos, endPos)
          .clamp(chartRect.top, chartRect.bottom);
      rect = Rect.fromLTRB(
        (center - halfThick).clamp(chartRect.left, chartRect.right),
        top,
        (center + halfThick).clamp(chartRect.left, chartRect.right),
        bottom,
      );
    }

    canvas
      ..drawRect(
        rect,
        Paint()
          ..color = color.withValues(alpha: highContrast ? 1.0 : 0.85)
          ..style = PaintingStyle.fill,
      )
      ..drawRect(
        rect,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = highContrast ? 2.0 : 1.0,
      );
  }

  @override
  bool shouldRepaint(_OiRangeBarPainter<T> oldDelegate) =>
      oldDelegate.series != series ||
      oldDelegate.categories != categories ||
      oldDelegate.resolvedColors != resolvedColors ||
      oldDelegate.minV != minV ||
      oldDelegate.maxV != maxV ||
      oldDelegate.chartRect != chartRect ||
      oldDelegate.horizontal != horizontal ||
      oldDelegate.showGrid != showGrid ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.highContrast != highContrast ||
      oldDelegate.compact != compact;
}

// ─────────────────────────────────────────────────────────────────────────────
// Legend
// ─────────────────────────────────────────────────────────────────────────────

class _RangeBarLegend<T> extends StatelessWidget {
  const _RangeBarLegend({required this.series, required this.colors});

  final List<OiRangeBarSeries<T>> series;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final textColors = context.colors;
    return Wrap(
      key: const Key('oi_range_bar_chart_legend'),
      spacing: 16,
      runSpacing: 4,
      children: [
        for (var i = 0; i < series.length; i++)
          if (series[i].visible)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 12, height: 12, color: colors[i]),
                const SizedBox(width: 4),
                OiLabel.caption(series[i].label, color: textColors.textMuted),
              ],
            ),
      ],
    );
  }
}
