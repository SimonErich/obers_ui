import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/_chart_grid_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_area_chart/oi_area_chart_data.dart';
import 'package:obers_ui_charts/src/composites/oi_area_chart/oi_area_chart_theme.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_interaction.dart';
import 'package:obers_ui_charts/src/composites/oi_chart_axis.dart';
import 'package:obers_ui_charts/src/composites/oi_line_chart/oi_line_chart_data.dart';
import 'package:obers_ui_charts/src/composites/oi_line_chart/oi_line_chart_theme.dart';
import 'package:obers_ui_charts/src/models/oi_cartesian_series.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Bar series type for OiComboChart
// ─────────────────────────────────────────────────────────────────────────────

/// A bar series for use within an [OiComboChart].
///
/// {@category Composites}
class OiComboBarSeries<T> extends OiCartesianSeries<T> {
  /// Creates an [OiComboBarSeries].
  OiComboBarSeries({
    required super.id,
    required super.label,
    required List<T> data,
    required super.xMapper,
    required super.yMapper,
    super.visible,
    super.color,
    this.barWidthFraction = 0.6,
  }) : super(data: data);

  /// The fraction of the slot width to use for the bar width. Defaults to
  /// `0.6`.
  final double barWidthFraction;
}

/// A scatter series for use within an [OiComboChart].
///
/// {@category Composites}
class OiComboScatterSeries<T> extends OiCartesianSeries<T> {
  /// Creates an [OiComboScatterSeries].
  OiComboScatterSeries({
    required super.id,
    required super.label,
    required List<T> data,
    required super.xMapper,
    required super.yMapper,
    super.visible,
    super.color,
    this.pointRadius = 5.0,
  }) : super(data: data);

  /// Radius of each point dot. Defaults to `5.0`.
  final double pointRadius;
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme
// ─────────────────────────────────────────────────────────────────────────────

/// Theme overrides for an [OiComboChart].
///
/// {@category Composites}
class OiComboChartTheme {
  /// Creates an [OiComboChartTheme].
  const OiComboChartTheme({
    this.seriesColors,
    this.gridColor,
    this.axisLabelColor,
    this.barRadius = 4.0,
  });

  /// Override colors for series. When `null`, the context chart palette is
  /// used.
  final List<Color>? seriesColors;

  /// Override color for grid lines.
  final Color? gridColor;

  /// Override color for axis labels.
  final Color? axisLabelColor;

  /// Corner radius for bar series. Defaults to `4.0`.
  final double barRadius;

  /// Resolves the color for a series at [seriesIndex].
  static Color resolveColor(
    int seriesIndex,
    Color? seriesColor,
    BuildContext context, {
    OiComboChartTheme? chartTheme,
  }) {
    if (seriesColor != null) return seriesColor;
    final themeColors = chartTheme?.seriesColors;
    if (themeColors != null && themeColors.isNotEmpty) {
      return themeColors[seriesIndex % themeColors.length];
    }
    final palette = context.colors.chart;
    return palette[seriesIndex % palette.length];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Resolved series (internal painting structures)
// ─────────────────────────────────────────────────────────────────────────────

/// Discriminated union tag for resolved combo series.
enum _ComboSeriesKind { line, area, bar, scatter }

class _ResolvedComboSeries {
  const _ResolvedComboSeries({
    required this.label,
    required this.color,
    required this.kind,
    required this.xValues,
    required this.yValues,
    this.strokeWidth = 2.0,
    this.fill = false,
    this.fillOpacity = 0.15,
    this.barWidthFraction = 0.6,
    this.pointRadius = 5.0,
  });

  final String label;
  final Color color;
  final _ComboSeriesKind kind;
  final List<double> xValues;
  final List<double> yValues;
  final double strokeWidth;
  final bool fill;
  final double fillOpacity;
  final double barWidthFraction;
  final double pointRadius;
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _OiComboChartPainter extends CustomPainter {
  const _OiComboChartPainter({
    required this.resolvedSeries,
    required this.chartRect,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.showGrid,
    required this.gridColor,
    required this.axisLabelColor,
    required this.highContrast,
    required this.compact,
    required this.xLabels,
    required this.yLabels,
    required this.xDivisions,
    required this.yDivisions,
    required this.barRadius,
    this.hoveredSeriesIndex,
    this.hoveredPointIndex,
  });

  final List<_ResolvedComboSeries> resolvedSeries;
  final Rect chartRect;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final bool showGrid;
  final Color gridColor;
  final Color axisLabelColor;
  final bool highContrast;
  final bool compact;
  final List<String> xLabels;
  final List<String> yLabels;
  final int xDivisions;
  final int yDivisions;
  final double barRadius;
  final int? hoveredSeriesIndex;
  final int? hoveredPointIndex;

  double get _rangeX {
    final r = maxX - minX;
    return r == 0 ? 1.0 : r;
  }

  double get _rangeY {
    final r = maxY - minY;
    return r == 0 ? 1.0 : r;
  }

  Offset _mapPoint(double x, double y) {
    final px = chartRect.left + chartRect.width * (x - minX) / _rangeX;
    final py = chartRect.bottom - chartRect.height * (y - minY) / _rangeY;
    return Offset(px, py);
  }

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

    // Compute slot width for bar series (based on number of x-values).
    // Use the series with the most data points as the reference.
    int maxPoints = 1;
    for (final s in resolvedSeries) {
      if (s.kind == _ComboSeriesKind.bar && s.xValues.length > maxPoints) {
        maxPoints = s.xValues.length;
      }
    }
    final slotWidth = maxPoints > 1
        ? chartRect.width / maxPoints
        : chartRect.width;

    // Draw area series first (fills should be behind lines).
    for (var si = 0; si < resolvedSeries.length; si++) {
      final s = resolvedSeries[si];
      if (s.kind == _ComboSeriesKind.area) {
        _paintAreaSeries(canvas, s, si);
      }
    }

    // Draw bar series.
    for (var si = 0; si < resolvedSeries.length; si++) {
      final s = resolvedSeries[si];
      if (s.kind == _ComboSeriesKind.bar) {
        _paintBarSeries(canvas, s, si, slotWidth);
      }
    }

    // Draw line series on top of areas/bars.
    for (var si = 0; si < resolvedSeries.length; si++) {
      final s = resolvedSeries[si];
      if (s.kind == _ComboSeriesKind.line) {
        _paintLineSeries(canvas, s, si);
      }
    }

    // Draw scatter series last (topmost layer).
    for (var si = 0; si < resolvedSeries.length; si++) {
      final s = resolvedSeries[si];
      if (s.kind == _ComboSeriesKind.scatter) {
        _paintScatterSeries(canvas, s, si);
      }
    }
  }

  void _paintLineSeries(Canvas canvas, _ResolvedComboSeries s, int si) {
    if (s.xValues.isEmpty) return;

    final count = math.min(s.xValues.length, s.yValues.length);
    final points = <Offset>[
      for (var i = 0; i < count; i++) _mapPoint(s.xValues[i], s.yValues[i]),
    ];

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Draw fill if requested.
    if (s.fill) {
      final fillPath = Path()
        ..addPath(path, Offset.zero)
        ..lineTo(points.last.dx, chartRect.bottom)
        ..lineTo(points.first.dx, chartRect.bottom);
      fillPath.close();
      canvas.drawPath(
        fillPath,
        Paint()
          ..color = s.color.withValues(alpha: s.fillOpacity)
          ..style = PaintingStyle.fill,
      );
    }

    final linePaint = Paint()
      ..color = s.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // Hover highlight.
    if (hoveredSeriesIndex == si && hoveredPointIndex != null) {
      final pi = hoveredPointIndex!;
      if (pi < points.length) {
        final hp = points[pi];
        canvas
          ..drawCircle(
            hp,
            s.strokeWidth * 3,
            Paint()
              ..color = s.color.withValues(alpha: 0.3)
              ..style = PaintingStyle.fill,
          )
          ..drawCircle(hp, s.strokeWidth * 2, Paint()..color = s.color);
      }
    }
  }

  void _paintAreaSeries(Canvas canvas, _ResolvedComboSeries s, int si) {
    if (s.xValues.isEmpty) return;

    final count = math.min(s.xValues.length, s.yValues.length);
    final topPoints = <Offset>[
      for (var i = 0; i < count; i++) _mapPoint(s.xValues[i], s.yValues[i]),
    ];

    // Filled area.
    final fillPath = Path()..moveTo(topPoints.first.dx, topPoints.first.dy);
    for (var i = 1; i < count; i++) {
      fillPath.lineTo(topPoints[i].dx, topPoints[i].dy);
    }
    fillPath
      ..lineTo(topPoints.last.dx, chartRect.bottom)
      ..lineTo(topPoints.first.dx, chartRect.bottom);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..color = s.color.withValues(alpha: s.fillOpacity)
        ..style = PaintingStyle.fill,
    );

    // Line stroke on top.
    if (s.fill) {
      final linePath = Path()..moveTo(topPoints.first.dx, topPoints.first.dy);
      for (var i = 1; i < count; i++) {
        linePath.lineTo(topPoints[i].dx, topPoints[i].dy);
      }
      canvas.drawPath(
        linePath,
        Paint()
          ..color = s.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = s.strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Hover highlight.
    if (hoveredSeriesIndex == si && hoveredPointIndex != null) {
      final pi = hoveredPointIndex!;
      if (pi < topPoints.length) {
        final hp = topPoints[pi];
        canvas
          ..drawCircle(
            hp,
            s.strokeWidth * 3,
            Paint()
              ..color = s.color.withValues(alpha: 0.3)
              ..style = PaintingStyle.fill,
          )
          ..drawCircle(hp, s.strokeWidth * 2, Paint()..color = s.color);
      }
    }
  }

  void _paintBarSeries(
    Canvas canvas,
    _ResolvedComboSeries s,
    int si,
    double slotWidth,
  ) {
    if (s.xValues.isEmpty) return;

    final barW = slotWidth * s.barWidthFraction;
    final isHovered = hoveredSeriesIndex == si;
    final count = math.min(s.xValues.length, s.yValues.length);

    for (var i = 0; i < count; i++) {
      final mapped = _mapPoint(s.xValues[i], s.yValues[i]);
      final barH = chartRect.bottom - mapped.dy;
      if (barH <= 0) continue;

      final x = mapped.dx - barW / 2;
      final rRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, mapped.dy, barW, barH),
        topLeft: Radius.circular(barRadius),
        topRight: Radius.circular(barRadius),
      );

      canvas.drawRRect(rRect, Paint()..color = s.color);

      if (isHovered && hoveredPointIndex == i) {
        canvas.drawRRect(
          rRect,
          Paint()
            ..color = s.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  void _paintScatterSeries(Canvas canvas, _ResolvedComboSeries s, int si) {
    if (s.xValues.isEmpty) return;

    final count = math.min(s.xValues.length, s.yValues.length);
    final dotPaint = Paint()..color = s.color;

    for (var i = 0; i < count; i++) {
      final mapped = _mapPoint(s.xValues[i], s.yValues[i]);
      canvas.drawCircle(mapped, s.pointRadius, dotPaint);
    }

    if (hoveredSeriesIndex == si && hoveredPointIndex != null) {
      final pi = hoveredPointIndex!;
      if (pi < count) {
        final hp = _mapPoint(s.xValues[pi], s.yValues[pi]);
        canvas
          ..drawCircle(
            hp,
            s.pointRadius * 2,
            Paint()
              ..color = s.color.withValues(alpha: 0.3)
              ..style = PaintingStyle.fill,
          )
          ..drawCircle(hp, s.pointRadius * 1.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_OiComboChartPainter oldDelegate) =>
      oldDelegate.resolvedSeries != resolvedSeries ||
      oldDelegate.showGrid != showGrid ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.highContrast != highContrast ||
      oldDelegate.compact != compact ||
      oldDelegate.hoveredSeriesIndex != hoveredSeriesIndex ||
      oldDelegate.hoveredPointIndex != hoveredPointIndex;
}

// ─────────────────────────────────────────────────────────────────────────────
// Legend
// ─────────────────────────────────────────────────────────────────────────────

class _OiComboChartLegend extends StatelessWidget {
  const _OiComboChartLegend({required this.resolvedSeries});

  final List<_ResolvedComboSeries> resolvedSeries;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      key: const Key('oi_combo_chart_legend'),
      spacing: 16,
      runSpacing: 4,
      children: [
        for (final s in resolvedSeries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSwatch(s),
              const SizedBox(width: 4),
              Text(
                s.label,
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSwatch(_ResolvedComboSeries s) {
    switch (s.kind) {
      case _ComboSeriesKind.bar:
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: s.color,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      case _ComboSeriesKind.scatter:
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
        );
      case _ComboSeriesKind.line:
      case _ComboSeriesKind.area:
        return CustomPaint(
          size: const Size(16, 10),
          painter: _LineSwatch(color: s.color),
        );
    }
  }
}

class _LineSwatch extends CustomPainter {
  const _LineSwatch({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_LineSwatch oldDelegate) => oldDelegate.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Main widget
// ─────────────────────────────────────────────────────────────────────────────

/// A chart that renders multiple series types (line, bar, scatter, area)
/// in the same Cartesian coordinate system.
///
/// The [series] list accepts mixed [OiCartesianSeries] subtypes:
/// - [OiLineSeries] data mapped via x/y → rendered as a polyline.
/// - [OiAreaSeries] → rendered as a filled area.
/// - [OiComboBarSeries] → rendered as vertical bars.
/// - [OiComboScatterSeries] → rendered as dot scatter points.
///
/// All series share a single x/y axis range computed from the union of all
/// data.
///
/// {@category Composites}
class OiComboChart<T> extends StatefulWidget {
  /// Creates an [OiComboChart].
  const OiComboChart({
    required this.label,
    required this.series,
    super.key,
    this.xAxis,
    this.yAxis,
    this.showGrid = true,
    this.showLegend = true,
    this.behaviors = const [],
    this.theme,
    this.emptyState,
    this.loadingState,
    this.errorState,
    this.semanticLabel,
    this.onPointTap,
    this.interactionMode,
    this.compact,
  });

  /// Accessibility label for the chart.
  final String label;

  /// Mixed-type series to render on the shared coordinate system.
  ///
  /// Each element may be an [OiLineSeries], [OiAreaSeries],
  /// [OiComboBarSeries], or [OiComboScatterSeries].
  final List<OiCartesianSeries<T>> series;

  /// Configuration for the x-axis.
  final OiChartAxis<dynamic>? xAxis;

  /// Configuration for the y-axis.
  final OiChartAxis<num>? yAxis;

  /// Whether to show grid lines. Defaults to `true`.
  final bool showGrid;

  /// Whether to show a legend when there are multiple series. Defaults to
  /// `true`.
  final bool showLegend;

  /// Chart behaviors (currently reserved for future extension).
  final List<Object> behaviors;

  /// Optional theme overrides.
  final OiComboChartTheme? theme;

  /// Widget shown when [series] is empty.
  final Widget? emptyState;

  /// Widget shown while data is loading.
  final Widget? loadingState;

  /// Widget shown when data loading has failed.
  final Widget? errorState;

  /// Overrides the auto-generated accessibility label.
  final String? semanticLabel;

  /// Callback when a data point is tapped.
  final void Function(int seriesIndex, int pointIndex)? onPointTap;

  /// Interaction mode. Defaults to [OiChartInteractionMode.auto].
  final OiChartInteractionMode? interactionMode;

  /// Whether to use compact layout. When `null`, determined by available width.
  final bool? compact;

  @override
  State<OiComboChart<T>> createState() => _OiComboChartState<T>();
}

class _OiComboChartState<T> extends State<OiComboChart<T>> {
  int? _hoveredSeriesIndex;
  int? _hoveredPointIndex;
  int? _selectedSeriesIndex;
  int? _selectedPointIndex;

  static const double _compactThreshold = 400;
  static const double _minViableWidth = 120;
  static const double _minViableHeight = 80;

  String get _effectiveLabel =>
      widget.semanticLabel ??
      (widget.label.isNotEmpty
          ? widget.label
          : 'Combo chart with ${widget.series.length} series');

  OiChartInteractionMode _resolveInteractionMode(BuildContext context) {
    if (widget.interactionMode != null &&
        widget.interactionMode != OiChartInteractionMode.auto) {
      return widget.interactionMode!;
    }
    final modality = OiPlatform.of(context).inputModality;
    return modality == OiInputModality.touch
        ? OiChartInteractionMode.touch
        : OiChartInteractionMode.pointer;
  }

  ({double minX, double maxX, double minY, double maxY}) _computeRange() {
    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    var minY = double.infinity;
    var maxY = double.negativeInfinity;

    for (final s in widget.series) {
      final data = s.data ?? const [];
      for (final item in data) {
        final x = (s.xMapper(item) as num).toDouble();
        final y = s.yMapper(item).toDouble();
        minX = math.min(minX, x);
        maxX = math.max(maxX, x);
        minY = math.min(minY, y);
        maxY = math.max(maxY, y);
      }
    }

    // Ensure bars start at zero.
    final hasBarSeries = widget.series.any((s) => s is OiComboBarSeries<T>);
    if (hasBarSeries) {
      minY = math.min(minY, 0);
    }

    if (minX == double.infinity) minX = 0;
    if (maxX == double.negativeInfinity) maxX = 1;
    if (minY == double.infinity) minY = 0;
    if (maxY == double.negativeInfinity) maxY = 1;

    return (
      minX: widget.xAxis?.min ?? minX,
      maxX: widget.xAxis?.max ?? maxX,
      minY: widget.yAxis?.min ?? minY,
      maxY: widget.yAxis?.max ?? maxY,
    );
  }

  ({int seriesIndex, int pointIndex})? _findNearestPoint(
    Offset position,
    Rect chartRect,
    double minX,
    double maxX,
    double minY,
    double maxY,
  ) {
    const hitRadius = 20.0;
    final rangeX = maxX - minX == 0 ? 1.0 : maxX - minX;
    final rangeY = maxY - minY == 0 ? 1.0 : maxY - minY;

    var bestDist = double.infinity;
    int? bestSi;
    int? bestPi;

    for (var si = 0; si < widget.series.length; si++) {
      final s = widget.series[si];
      final data = s.data ?? const [];
      for (var pi = 0; pi < data.length; pi++) {
        final item = data[pi];
        final x = (s.xMapper(item) as num).toDouble();
        final y = s.yMapper(item).toDouble();
        final px = chartRect.left + chartRect.width * (x - minX) / rangeX;
        final py = chartRect.bottom - chartRect.height * (y - minY) / rangeY;
        final dist = (Offset(px, py) - position).distance;
        if (dist < hitRadius && dist < bestDist) {
          bestDist = dist;
          bestSi = si;
          bestPi = pi;
        }
      }
    }

    if (bestSi != null) {
      return (seriesIndex: bestSi, pointIndex: bestPi!);
    }
    return null;
  }

  _ResolvedComboSeries _resolveSeries(int index, BuildContext context) {
    final s = widget.series[index];
    final data = s.data ?? const [];
    final xValues = <double>[];
    final yValues = <double>[];
    for (final item in data) {
      xValues.add((s.xMapper(item) as num).toDouble());
      yValues.add(s.yMapper(item).toDouble());
    }

    final color = OiComboChartTheme.resolveColor(
      index,
      s.color,
      context,
      chartTheme: widget.theme,
    );

    if (s is OiComboBarSeries<T>) {
      return _ResolvedComboSeries(
        label: s.label,
        color: color,
        kind: _ComboSeriesKind.bar,
        xValues: xValues,
        yValues: yValues,
        barWidthFraction: s.barWidthFraction,
      );
    }

    if (s is OiComboScatterSeries<T>) {
      return _ResolvedComboSeries(
        label: s.label,
        color: color,
        kind: _ComboSeriesKind.scatter,
        xValues: xValues,
        yValues: yValues,
        pointRadius: s.pointRadius,
      );
    }

    if (s is OiAreaSeries<T>) {
      return _ResolvedComboSeries(
        label: s.label,
        color: OiAreaChartTheme.resolveColor(index, s.color, context),
        kind: _ComboSeriesKind.area,
        xValues: xValues,
        yValues: yValues,
        fillOpacity: s.fillOpacity,
        fill: s.showLine,
        strokeWidth: s.style?.strokeWidth ?? 2.0,
      );
    }

    // Default: treat as line series (also covers OiCartesianSeries directly).
    return _ResolvedComboSeries(
      label: s.label,
      color: OiLineChartTheme.resolveColor(index, s.color, context),
      kind: _ComboSeriesKind.line,
      xValues: xValues,
      yValues: yValues,
      strokeWidth: s.style?.strokeWidth ?? 2.0,
    );
  }

  bool get _isEmpty =>
      widget.series.isEmpty ||
      widget.series.every((s) => s.data == null || s.data!.isEmpty);

  @override
  Widget build(BuildContext context) {
    if (widget.loadingState != null) return widget.loadingState!;
    if (widget.errorState != null) return widget.errorState!;
    if (_isEmpty) {
      return widget.emptyState ??
          const SizedBox.shrink(key: Key('oi_combo_chart_empty'));
    }

    final colors = context.colors;
    final isHighContrast = OiA11y.highContrast(context);
    final reducedMotion = OiA11y.reducedMotion(context);

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
                key: const Key('oi_combo_chart_fallback'),
                child: FittedBox(
                  child: Text(
                    'Chart too small',
                    style: TextStyle(fontSize: 10, color: colors.textMuted),
                  ),
                ),
              ),
            );
          }

          final isCompact = widget.compact ?? (w < _compactThreshold);
          final mode = _resolveInteractionMode(context);
          final range = _computeRange();
          final chartSize = Size(
            w,
            math.min(h, isCompact ? w * 0.6 : w * 0.75),
          );
          final chartRect = OiChartGrid.computeChartRect(
            chartSize,
            compact: isCompact,
          );

          final resolved = <_ResolvedComboSeries>[
            for (var i = 0; i < widget.series.length; i++)
              _resolveSeries(i, context),
          ];

          final hoverSi = reducedMotion ? null : _hoveredSeriesIndex;
          final hoverPi = reducedMotion ? null : _hoveredPointIndex;

          // Axis labels.
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

          final chartWidget = SizedBox(
            key: const Key('oi_combo_chart_canvas'),
            width: chartSize.width,
            height: chartSize.height,
            child: CustomPaint(
              key: const Key('oi_combo_chart_painter'),
              size: chartSize,
              painter: _OiComboChartPainter(
                resolvedSeries: resolved,
                chartRect: chartRect,
                minX: range.minX,
                maxX: range.maxX,
                minY: range.minY,
                maxY: range.maxY,
                showGrid: widget.showGrid,
                gridColor: widget.theme?.gridColor ?? colors.borderSubtle,
                axisLabelColor:
                    widget.theme?.axisLabelColor ?? colors.textMuted,
                highContrast: isHighContrast,
                compact: isCompact,
                xLabels: xLabels,
                yLabels: yLabels,
                xDivisions: xDiv,
                yDivisions: yDiv,
                barRadius: widget.theme?.barRadius ?? 4.0,
                hoveredSeriesIndex: hoverSi,
                hoveredPointIndex: hoverPi,
              ),
            ),
          );

          // Interaction wrapper.
          Widget interactiveChart;
          if (mode == OiChartInteractionMode.touch) {
            interactiveChart = GestureDetector(
              key: const Key('oi_combo_chart_touch'),
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) {
                final hit = _findNearestPoint(
                  d.localPosition,
                  chartRect,
                  range.minX,
                  range.maxX,
                  range.minY,
                  range.maxY,
                );
                if (hit != null) {
                  setState(() {
                    _selectedSeriesIndex = hit.seriesIndex;
                    _selectedPointIndex = hit.pointIndex;
                  });
                  widget.onPointTap?.call(hit.seriesIndex, hit.pointIndex);
                }
              },
              child: chartWidget,
            );
          } else {
            interactiveChart = MouseRegion(
              key: const Key('oi_combo_chart_pointer'),
              onHover: (e) {
                final hit = _findNearestPoint(
                  e.localPosition,
                  chartRect,
                  range.minX,
                  range.maxX,
                  range.minY,
                  range.maxY,
                );
                final si = hit?.seriesIndex;
                final pi = hit?.pointIndex;
                if (si != _hoveredSeriesIndex || pi != _hoveredPointIndex) {
                  setState(() {
                    _hoveredSeriesIndex = si;
                    _hoveredPointIndex = pi;
                  });
                }
              },
              onExit: (_) => setState(() {
                _hoveredSeriesIndex = null;
                _hoveredPointIndex = null;
              }),
              child: chartWidget,
            );
          }

          // Active point narration.
          final activeIdx = _selectedPointIndex ?? _hoveredPointIndex;
          final activeSi = _selectedSeriesIndex ?? _hoveredSeriesIndex;
          Widget narration = const SizedBox.shrink();
          if (activeIdx != null && activeSi != null) {
            final s = widget.series[activeSi];
            final data = s.data;
            if (data != null && activeIdx < data.length) {
              final item = data[activeIdx];
              final x = (s.xMapper(item) as num).toDouble();
              final y = s.yMapper(item).toDouble();
              narration = Semantics(
                key: const Key('oi_combo_chart_narration'),
                liveRegion: true,
                child: Text(
                  '${s.label}: x=${x.toStringAsFixed(1)}, '
                  'y=${y.toStringAsFixed(1)}',
                  style: TextStyle(fontSize: 11, color: colors.textSubtle),
                ),
              );
            }
          }

          // Legend.
          final showLegend = widget.showLegend && widget.series.length > 1;
          final legendWidget = showLegend
              ? _OiComboChartLegend(resolvedSeries: resolved)
              : null;

          if (isCompact) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                interactiveChart,
                narration,
                if (legendWidget != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: legendWidget,
                  ),
              ],
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: interactiveChart),
                  if (legendWidget != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: legendWidget,
                    ),
                ],
              ),
              narration,
            ],
          );
        },
      ),
    );
  }
}
