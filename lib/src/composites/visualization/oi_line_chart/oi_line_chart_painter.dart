import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:obers_ui/src/composites/visualization/_chart_grid_painter.dart';
import 'package:obers_ui/src/composites/visualization/oi_line_chart/oi_line_chart_data.dart'
    show OiLineChartMode, OiLinePoint;

/// Resolved line series with concrete colors ready for painting.
class ResolvedLineSeries {
  /// Creates a [ResolvedLineSeries].
  const ResolvedLineSeries({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.dashed,
    required this.fill,
    required this.fillOpacity,
    required this.label,
  });

  /// The data points.
  final List<OiLinePoint> points;

  /// The resolved color.
  final Color color;

  /// Stroke width.
  final double strokeWidth;

  /// Whether dashed.
  final bool dashed;

  /// Whether to fill.
  final bool fill;

  /// Fill opacity.
  final double fillOpacity;

  /// Series label.
  final String label;
}

/// Custom painter for [OiLineChart].
class OiLineChartPainter extends CustomPainter {
  /// Creates an [OiLineChartPainter].
  OiLineChartPainter({
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
    required this.mode,
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
  final List<ResolvedLineSeries> resolvedSeries;

  /// The chart drawing area.
  final Rect chartRect;

  /// Data range.
  final double minX;

  /// Data range.
  final double maxX;

  /// Data range.
  final double minY;

  /// Data range.
  final double maxY;

  /// Whether to show grid.
  final bool showGrid;

  /// Grid line color.
  final Color gridColor;

  /// Axis label color.
  final Color axisLabelColor;

  /// High-contrast mode.
  final bool highContrast;

  /// Compact mode.
  final bool compact;

  /// The line interpolation mode.
  final OiLineChartMode mode;

  /// Whether to show point dots.
  final bool showPoints;

  /// Whether series are stacked.
  final bool stacked;

  /// X-axis tick labels.
  final List<String> xLabels;

  /// Y-axis tick labels.
  final List<String> yLabels;

  /// X-axis divisions.
  final int xDivisions;

  /// Y-axis divisions.
  final int yDivisions;

  /// Hovered series index.
  final int? hoveredSeriesIndex;

  /// Hovered point index.
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
    // Grid.
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

    // Track cumulative Y offsets for stacked mode.
    // Map from x-value to cumulative y-value.
    final stackOffsets = <double, double>{};

    for (var si = 0; si < resolvedSeries.length; si++) {
      final series = resolvedSeries[si];
      if (series.points.isEmpty) continue;

      // Compute mapped points, applying stack offsets if needed.
      final mappedPoints = <Offset>[];
      for (final point in series.points) {
        var effectiveY = point.y;
        if (stacked) {
          final base = stackOffsets[point.x] ?? 0;
          effectiveY += base;
          stackOffsets[point.x] = effectiveY;
        }
        mappedPoints.add(_mapPoint(point.x, effectiveY));
      }

      // Build path.
      final Path path;
      switch (mode) {
        case OiLineChartMode.smooth:
          path = mappedPoints.length > 2
              ? _buildSmoothPath(mappedPoints)
              : _buildLinearPath(mappedPoints);
        case OiLineChartMode.stepped:
          path = _buildSteppedPath(mappedPoints);
        case OiLineChartMode.straight:
          path = _buildLinearPath(mappedPoints);
      }

      // Draw fill.
      if (series.fill) {
        final fillPath = Path()..addPath(path, Offset.zero);

        if (stacked && si > 0) {
          // Close to the previous series baseline.
          final prevSeries = resolvedSeries[si - 1];
          for (var i = prevSeries.points.length - 1; i >= 0; i--) {
            final p = prevSeries.points[i];
            final base = (stackOffsets[p.x] ?? p.y) - series.points[math.min(i, series.points.length - 1)].y;
            fillPath.lineTo(_mapPoint(p.x, base).dx, _mapPoint(p.x, base).dy);
          }
        } else {
          // Close to bottom axis.
          fillPath
            ..lineTo(mappedPoints.last.dx, chartRect.bottom)
            ..lineTo(mappedPoints.first.dx, chartRect.bottom);
        }
        fillPath.close();

        canvas.drawPath(
          fillPath,
          Paint()
            ..color = series.color.withValues(alpha: series.fillOpacity)
            ..style = PaintingStyle.fill,
        );
      }

      // Draw line.
      final linePaint = Paint()
        ..color = series.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = series.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      if (series.dashed) {
        _drawDashedPath(canvas, path, linePaint);
      } else {
        canvas.drawPath(path, linePaint);
      }

      // Draw point dots.
      if (showPoints) {
        final dotPaint = Paint()..color = series.color;
        for (final p in mappedPoints) {
          canvas.drawCircle(p, series.strokeWidth * 1.5, dotPaint);
        }
      }

      // Draw hover highlight.
      if (hoveredSeriesIndex == si && hoveredPointIndex != null) {
        final pi = hoveredPointIndex!;
        if (pi < mappedPoints.length) {
          final hp = mappedPoints[pi];
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

  Path _buildLinearPath(List<Offset> points) {
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    return path;
  }

  Path _buildSteppedPath(List<Offset> points) {
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      // Horizontal segment to the next point's x, then vertical to its y.
      path
        ..lineTo(points[i].dx, points[i - 1].dy)
        ..lineTo(points[i].dx, points[i].dy);
    }
    return path;
  }

  Path _buildSmoothPath(List<Offset> points) {
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i < points.length - 2 ? points[i + 2] : points[i + 1];

      // Catmull-Rom to cubic bezier control points.
      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLen = 6.0;
    const gapLen = 4.0;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dashLen, metric.length);
        final segment = metric.extractPath(distance, end);
        canvas.drawPath(segment, paint);
        distance += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(OiLineChartPainter oldDelegate) =>
      oldDelegate.resolvedSeries != resolvedSeries ||
      oldDelegate.showGrid != showGrid ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.highContrast != highContrast ||
      oldDelegate.compact != compact ||
      oldDelegate.mode != mode ||
      oldDelegate.showPoints != showPoints ||
      oldDelegate.stacked != stacked ||
      oldDelegate.hoveredSeriesIndex != hoveredSeriesIndex ||
      oldDelegate.hoveredPointIndex != hoveredPointIndex;
}
