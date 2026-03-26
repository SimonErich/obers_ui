import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:obers_ui_charts/src/composites/_chart_grid_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_area_chart/oi_area_chart.dart'
    show OiAreaChart;

/// A resolved area series ready for painting, with concrete colors and
/// pre-mapped x/y values.
class ResolvedAreaSeries {
  /// Creates a [ResolvedAreaSeries].
  const ResolvedAreaSeries({
    required this.label,
    required this.xValues,
    required this.yValues,
    required this.color,
    required this.fillOpacity,
    required this.showLine,
    required this.strokeWidth,
    required this.stackGroup,
  });

  /// Series label.
  final String label;

  /// Raw x-axis values, parallel to [yValues].
  final List<double> xValues;

  /// Raw y-axis values, parallel to [xValues].
  final List<double> yValues;

  /// Resolved series color.
  final Color color;

  /// Fill opacity for the area.
  final double fillOpacity;

  /// Whether to draw a line stroke on top of the fill.
  final bool showLine;

  /// Stroke width for the line.
  final double strokeWidth;

  /// Optional stack group identifier.
  final String? stackGroup;
}

/// Custom painter for [OiAreaChart].
class OiAreaChartPainter extends CustomPainter {
  /// Creates an [OiAreaChartPainter].
  OiAreaChartPainter({
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
    required this.showPoints,
    required this.stacked,
    required this.xLabels,
    required this.yLabels,
    required this.xDivisions,
    required this.yDivisions,
    this.hoveredSeriesIndex,
    this.hoveredPointIndex,
  });

  /// The resolved series data.
  final List<ResolvedAreaSeries> resolvedSeries;

  /// The chart drawing area in the canvas.
  final Rect chartRect;

  /// Minimum x value in the data range.
  final double minX;

  /// Maximum x value in the data range.
  final double maxX;

  /// Minimum y value in the data range.
  final double minY;

  /// Maximum y value in the data range.
  final double maxY;

  /// Whether to show grid lines.
  final bool showGrid;

  /// Grid line color.
  final Color gridColor;

  /// Axis label color.
  final Color axisLabelColor;

  /// High-contrast accessibility mode.
  final bool highContrast;

  /// Compact layout mode.
  final bool compact;

  /// Whether to show dots at each data point.
  final bool showPoints;

  /// Whether series are stacked.
  final bool stacked;

  /// X-axis tick labels.
  final List<String> xLabels;

  /// Y-axis tick labels.
  final List<String> yLabels;

  /// Number of x-axis divisions.
  final int xDivisions;

  /// Number of y-axis divisions.
  final int yDivisions;

  /// Index of the hovered series, or `null`.
  final int? hoveredSeriesIndex;

  /// Index of the hovered point within the hovered series, or `null`.
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

    // Cumulative stack baselines: maps x-value → top-of-stack y.
    // Used for both stacked rendering and stack-group sub-stacking.
    final stackBaselines = <String, Map<double, double>>{};

    for (var si = 0; si < resolvedSeries.length; si++) {
      final series = resolvedSeries[si];
      if (series.xValues.isEmpty) continue;

      final count = math.min(series.xValues.length, series.yValues.length);

      // Determine baseline y values per point (bottom of the area fill).
      final baseY = <double>[];
      final topY = <double>[];

      for (var i = 0; i < count; i++) {
        final x = series.xValues[i];
        final y = series.yValues[i];

        double base = 0;
        if (stacked && series.stackGroup != null) {
          final groupMap = stackBaselines.putIfAbsent(
            series.stackGroup!,
            () => {},
          );
          base = groupMap[x] ?? 0;
          groupMap[x] = base + y;
        } else if (stacked) {
          // All series share a single default group.
          final groupMap = stackBaselines.putIfAbsent('__default__', () => {});
          base = groupMap[x] ?? 0;
          groupMap[x] = base + y;
        }

        baseY.add(base);
        topY.add(stacked ? base + y : y);
      }

      // Map to canvas coordinates.
      final topPoints = <Offset>[
        for (var i = 0; i < count; i++) _mapPoint(series.xValues[i], topY[i]),
      ];
      final basePoints = <Offset>[
        for (var i = 0; i < count; i++) _mapPoint(series.xValues[i], baseY[i]),
      ];

      // Build the filled area path.
      final fillPath = Path()..moveTo(topPoints.first.dx, topPoints.first.dy);
      for (var i = 1; i < count; i++) {
        fillPath.lineTo(topPoints[i].dx, topPoints[i].dy);
      }
      // Close along the baseline (right to left).
      for (var i = count - 1; i >= 0; i--) {
        fillPath.lineTo(basePoints[i].dx, basePoints[i].dy);
      }
      fillPath.close();

      canvas.drawPath(
        fillPath,
        Paint()
          ..color = series.color.withValues(alpha: series.fillOpacity)
          ..style = PaintingStyle.fill,
      );

      // Draw line stroke on top.
      if (series.showLine) {
        final linePath = Path()..moveTo(topPoints.first.dx, topPoints.first.dy);
        for (var i = 1; i < count; i++) {
          linePath.lineTo(topPoints[i].dx, topPoints[i].dy);
        }

        canvas.drawPath(
          linePath,
          Paint()
            ..color = series.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = series.strokeWidth
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }

      // Draw point dots.
      if (showPoints) {
        final dotPaint = Paint()..color = series.color;
        for (final p in topPoints) {
          canvas.drawCircle(p, series.strokeWidth * 1.5, dotPaint);
        }
      }

      // Draw hover highlight.
      if (hoveredSeriesIndex == si && hoveredPointIndex != null) {
        final pi = hoveredPointIndex!;
        if (pi < topPoints.length) {
          final hp = topPoints[pi];
          canvas
            ..drawCircle(
              hp,
              series.strokeWidth * 3,
              Paint()
                ..color = series.color.withValues(alpha: 0.3)
                ..style = PaintingStyle.fill,
            )
            ..drawCircle(
              hp,
              series.strokeWidth * 2,
              Paint()..color = series.color,
            );
        }
      }
    }
  }

  @override
  bool shouldRepaint(OiAreaChartPainter oldDelegate) =>
      oldDelegate.resolvedSeries != resolvedSeries ||
      oldDelegate.showGrid != showGrid ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.highContrast != highContrast ||
      oldDelegate.compact != compact ||
      oldDelegate.showPoints != showPoints ||
      oldDelegate.stacked != stacked ||
      oldDelegate.hoveredSeriesIndex != hoveredSeriesIndex ||
      oldDelegate.hoveredPointIndex != hoveredPointIndex;
}
