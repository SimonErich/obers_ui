import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/_chart_grid_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_chart_axis.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Series
// ─────────────────────────────────────────────────────────────────────────────

/// A data series for a range area chart.
///
/// Each item `T` contributes one x-position and a vertical range defined by
/// [yMinMapper] (lower bound) and [yMaxMapper] (upper bound). An optional
/// [midLineMapper] adds a center line (e.g. average or median) inside the
/// shaded band.
///
/// {@category Composites}
class OiRangeAreaSeries<T> {
  /// Creates an [OiRangeAreaSeries].
  const OiRangeAreaSeries({
    required this.id,
    required this.label,
    required this.data,
    required this.xMapper,
    required this.yMinMapper,
    required this.yMaxMapper,
    this.midLineMapper,
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

  /// Extracts the x-axis value (e.g. a timestamp index) from a data item.
  final num Function(T item) xMapper;

  /// Extracts the lower bound of the range for a data item.
  final num Function(T item) yMinMapper;

  /// Extracts the upper bound of the range for a data item.
  final num Function(T item) yMaxMapper;

  /// Extracts the optional mid-line value (e.g. average) for a data item.
  ///
  /// When non-null and [OiRangeAreaChart.showMidLine] is `true`, a stroke line
  /// is drawn through the center of the band.
  final num Function(T item)? midLineMapper;

  /// Optional series color override. When null, the chart palette is used.
  final Color? color;

  /// Whether this series is visible.
  final bool visible;

  /// Accessibility label for screen readers.
  final String? semanticLabel;
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────────────────────────

/// A range area chart that visualises min/max envelopes, confidence bands, or
/// any continuous range over an ordered x-domain.
///
/// The filled area spans vertically between [OiRangeAreaSeries.yMinMapper] and
/// [OiRangeAreaSeries.yMaxMapper] values. When [showMidLine] is `true` and a
/// [OiRangeAreaSeries.midLineMapper] is provided, a stroke line is drawn
/// through the midpoint of the band.
///
/// ## Example
///
/// ```dart
/// OiRangeAreaChart<Reading>(
///   label: 'Temperature Range',
///   series: [
///     OiRangeAreaSeries<Reading>(
///       id: 'temp',
///       label: 'Temperature',
///       data: readings,
///       xMapper: (r) => r.dayIndex,
///       yMinMapper: (r) => r.low,
///       yMaxMapper: (r) => r.high,
///       midLineMapper: (r) => r.avg,
///     ),
///   ],
///   showMidLine: true,
///   fillOpacity: 0.25,
/// )
/// ```
///
/// {@category Composites}
class OiRangeAreaChart<T> extends StatefulWidget {
  /// Creates an [OiRangeAreaChart].
  const OiRangeAreaChart({
    required this.label,
    required this.series,
    super.key,
    this.showMidLine = true,
    this.fillOpacity = 0.2,
    this.showGrid = true,
    this.xAxis,
    this.yAxis,
    this.behaviors = const [],
    this.controller,
    this.compact,
    this.emptyState,
    this.semanticLabel,
  }) : assert(
         fillOpacity >= 0.0 && fillOpacity <= 1.0,
         'fillOpacity must be between 0.0 and 1.0',
       );

  /// Accessibility label for the chart.
  final String label;

  /// The data series to render.
  final List<OiRangeAreaSeries<T>> series;

  /// Whether to draw a mid-line through the center of each band.
  ///
  /// Only rendered when the series provides a [OiRangeAreaSeries.midLineMapper].
  /// Defaults to `true`.
  final bool showMidLine;

  /// Opacity for the filled area (0.0 = transparent, 1.0 = opaque).
  ///
  /// Defaults to `0.2`.
  final double fillOpacity;

  /// Whether to show grid lines. Defaults to `true`.
  final bool showGrid;

  /// Configuration for the x-axis.
  final OiChartAxis<num>? xAxis;

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
  State<OiRangeAreaChart<T>> createState() => _OiRangeAreaChartState<T>();
}

class _OiRangeAreaChartState<T> extends State<OiRangeAreaChart<T>> {
  static const double _compactThreshold = 400;
  static const double _minViableWidth = 120;
  static const double _minViableHeight = 80;

  bool get _isEmpty =>
      widget.series.isEmpty || widget.series.every((s) => s.data.isEmpty);

  String get _effectiveLabel =>
      widget.semanticLabel ??
      (widget.label.isNotEmpty ? widget.label : 'Range area chart');

  ({double minX, double maxX, double minY, double maxY}) _computeRange() {
    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    var minY = double.infinity;
    var maxY = double.negativeInfinity;

    for (final s in widget.series) {
      if (!s.visible || s.data.isEmpty) continue;
      for (final item in s.data) {
        final x = s.xMapper(item).toDouble();
        final yMin = s.yMinMapper(item).toDouble();
        final yMax = s.yMaxMapper(item).toDouble();
        minX = math.min(minX, x);
        maxX = math.max(maxX, x);
        minY = math.min(minY, yMin);
        maxY = math.max(maxY, yMax);
        if (s.midLineMapper != null) {
          final mid = s.midLineMapper!(item).toDouble();
          minY = math.min(minY, mid);
          maxY = math.max(maxY, mid);
        }
      }
    }

    if (!minX.isFinite) minX = 0;
    if (!maxX.isFinite) maxX = 1;
    if (!minY.isFinite) minY = 0;
    if (!maxY.isFinite) maxY = 1;

    final paddingY = (maxY - minY) * 0.05;
    return (
      minX: widget.xAxis?.min ?? minX,
      maxX: widget.xAxis?.max ?? maxX,
      minY: widget.yAxis?.min ?? (minY - paddingY),
      maxY: widget.yAxis?.max ?? (maxY + paddingY),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) {
      return widget.emptyState ??
          const SizedBox.shrink(key: Key('oi_range_area_chart_empty'));
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
                key: const Key('oi_range_area_chart_fallback'),
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
          final range = _computeRange();
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
          final xDiv = widget.xAxis?.divisions ?? (isCompact ? 3 : 5);
          final yDiv = widget.yAxis?.divisions ?? (isCompact ? 3 : 5);
          final rX = range.maxX - range.minX;
          final rY = range.maxY - range.minY;

          final xLabels =
              widget.xAxis?.labels ??
              List.generate(
                xDiv + 1,
                (i) => (widget.xAxis ?? const OiChartAxis()).formatValue(
                  range.minX + (rX == 0 ? 0 : rX * i / xDiv),
                ),
              );
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
                  key: const Key('oi_range_area_chart_canvas'),
                  width: chartSize.width,
                  height: chartSize.height,
                  child: CustomPaint(
                    key: const Key('oi_range_area_chart_painter'),
                    size: chartSize,
                    painter: _OiRangeAreaPainter<T>(
                      series: widget.series,
                      colors: resolvedColors,
                      minX: range.minX,
                      maxX: range.maxX,
                      minY: range.minY,
                      maxY: range.maxY,
                      chartRect: chartRect,
                      showMidLine: widget.showMidLine,
                      fillOpacity: widget.fillOpacity,
                      showGrid: widget.showGrid,
                      gridColor: colors.borderSubtle,
                      axisLabelColor: colors.textMuted,
                      highContrast: isHighContrast,
                      compact: isCompact,
                      xLabels: xLabels,
                      yLabels: yLabels,
                      xDivisions: xDiv,
                      yDivisions: yDiv,
                    ),
                  ),
                ),
              ),
              if (!isCompact && widget.series.length > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _RangeAreaLegend(
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

class _OiRangeAreaPainter<T> extends CustomPainter {
  _OiRangeAreaPainter({
    required this.series,
    required this.colors,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.chartRect,
    required this.showMidLine,
    required this.fillOpacity,
    required this.showGrid,
    required this.gridColor,
    required this.axisLabelColor,
    required this.highContrast,
    required this.compact,
    required this.xLabels,
    required this.yLabels,
    required this.xDivisions,
    required this.yDivisions,
  });

  final List<OiRangeAreaSeries<T>> series;
  final List<Color> colors;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final Rect chartRect;
  final bool showMidLine;
  final double fillOpacity;
  final bool showGrid;
  final Color gridColor;
  final Color axisLabelColor;
  final bool highContrast;
  final bool compact;
  final List<String> xLabels;
  final List<String> yLabels;
  final int xDivisions;
  final int yDivisions;

  double get _rangeX {
    final r = maxX - minX;
    return r == 0 ? 1.0 : r;
  }

  double get _rangeY {
    final r = maxY - minY;
    return r == 0 ? 1.0 : r;
  }

  double _mapX(double v) =>
      chartRect.left + chartRect.width * (v - minX) / _rangeX;

  double _mapY(double v) =>
      chartRect.bottom - chartRect.height * (v - minY) / _rangeY;

  @override
  void paint(Canvas canvas, Size size) {
    if (showGrid) {
      OiChartGrid.paintGrid(
        canvas,
        chartRect,
        gridColor: gridColor,
        highContrast: highContrast,
        horizontalDivisions: yDivisions,
        verticalDivisions: xDivisions,
      );
    }

    OiChartGrid.paintAxes(
      canvas,
      chartRect,
      axisColor: gridColor,
      highContrast: highContrast,
    );

    OiChartGrid.paintXLabels(
      canvas,
      chartRect,
      labels: xLabels,
      labelColor: axisLabelColor,
    );
    OiChartGrid.paintYLabels(
      canvas,
      chartRect,
      labels: yLabels,
      labelColor: axisLabelColor,
    );

    for (var si = 0; si < series.length; si++) {
      final s = series[si];
      if (!s.visible || s.data.isEmpty) continue;
      final color = colors[si];
      _paintSeries(canvas, s, color);
    }
  }

  void _paintSeries(Canvas canvas, OiRangeAreaSeries<T> s, Color color) {
    final data = s.data;
    if (data.length < 2) {
      // Single data point — draw a vertical line segment.
      if (data.isEmpty) return;
      final item = data.first;
      final x = _mapX(s.xMapper(item).toDouble());
      final yMin = _mapY(s.yMinMapper(item).toDouble());
      final yMax = _mapY(s.yMaxMapper(item).toDouble());
      canvas.drawLine(
        Offset(x, yMin),
        Offset(x, yMax),
        Paint()
          ..color = color
          ..strokeWidth = highContrast ? 2.5 : 1.5,
      );
      return;
    }

    // ── Filled area ───────────────────────────────────────────────────────────

    // Build the closed path: upper boundary forward, lower boundary backward.
    final upperPoints = <Offset>[];
    final lowerPoints = <Offset>[];

    for (final item in data) {
      final x = _mapX(s.xMapper(item).toDouble());
      upperPoints.add(Offset(x, _mapY(s.yMaxMapper(item).toDouble())));
      lowerPoints.add(Offset(x, _mapY(s.yMinMapper(item).toDouble())));
    }

    final areaPath = Path()..moveTo(upperPoints.first.dx, upperPoints.first.dy);
    for (final p in upperPoints.skip(1)) {
      areaPath.lineTo(p.dx, p.dy);
    }
    // Trace lower boundary in reverse.
    for (final p in lowerPoints.reversed) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath.close();

    final effectiveOpacity = highContrast
        ? math.min<double>(fillOpacity + 0.2, 1)
        : fillOpacity;

    canvas.drawPath(
      areaPath,
      Paint()
        ..color = color.withValues(alpha: effectiveOpacity)
        ..style = ui.PaintingStyle.fill,
    );

    // ── Border strokes (upper and lower edges) ────────────────────────────────

    final edgePaint = Paint()
      ..color = color.withValues(alpha: highContrast ? 1.0 : 0.6)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = highContrast ? 2.0 : 1.0
      ..strokeJoin = StrokeJoin.round;

    _paintPolyline(canvas, upperPoints, edgePaint);
    _paintPolyline(canvas, lowerPoints, edgePaint);

    // ── Mid-line ──────────────────────────────────────────────────────────────

    if (showMidLine && s.midLineMapper != null) {
      final midPoints = <Offset>[
        for (final item in data)
          Offset(
            _mapX(s.xMapper(item).toDouble()),
            _mapY(s.midLineMapper!(item).toDouble()),
          ),
      ];

      _paintPolyline(
        canvas,
        midPoints,
        Paint()
          ..color = color
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = highContrast ? 2.5 : 1.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  void _paintPolyline(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_OiRangeAreaPainter<T> oldDelegate) =>
      oldDelegate.series != series ||
      oldDelegate.colors != colors ||
      oldDelegate.minX != minX ||
      oldDelegate.maxX != maxX ||
      oldDelegate.minY != minY ||
      oldDelegate.maxY != maxY ||
      oldDelegate.chartRect != chartRect ||
      oldDelegate.showMidLine != showMidLine ||
      oldDelegate.fillOpacity != fillOpacity ||
      oldDelegate.showGrid != showGrid ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.highContrast != highContrast ||
      oldDelegate.compact != compact;
}

// ─────────────────────────────────────────────────────────────────────────────
// Legend
// ─────────────────────────────────────────────────────────────────────────────

class _RangeAreaLegend<T> extends StatelessWidget {
  const _RangeAreaLegend({required this.series, required this.colors});

  final List<OiRangeAreaSeries<T>> series;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final textColors = context.colors;
    return Wrap(
      key: const Key('oi_range_area_chart_legend'),
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
