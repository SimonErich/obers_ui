import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:obers_ui_charts/src/composites/cartesian/oi_cartesian_painter.dart';
import 'package:obers_ui_charts/src/foundation/data/chart_data.dart';

/// Custom painter for line charts.
///
/// Extends [OiCartesianPainter] to share grid/axis rendering.
/// Draws one line per series with optional data-point dots.
class OiLineChartPainter extends OiCartesianPainter {
  OiLineChartPainter({
    required super.data,
    required super.theme,
    super.padding,
    super.showGrid,
    super.xAxis,
    super.yAxis,
    this.strokeWidth = 2,
    this.pointRadius = 4,
    this.showPoints = true,
  });

  final double strokeWidth;
  final double pointRadius;
  final bool showPoints;

  @override
  void paintSeries(Canvas canvas, Size size) {
    final bounds = data.bounds;
    for (var i = 0; i < data.series.length; i++) {
      final series = data.series[i];
      final color = series.color ?? theme.colors.colorForSeries(i);
      _paintLine(canvas, size, series, bounds, color);
    }
  }

  void _paintLine(
    Canvas canvas,
    Size size,
    OiChartSeries series,
    OiChartBounds bounds,
    Color color,
  ) {
    if (series.dataPoints.isEmpty) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final points = series.dataPoints;

    final firstPixel = mapDataToPixel(points.first, size, bounds);
    path.moveTo(firstPixel.dx, firstPixel.dy);

    for (var i = 1; i < points.length; i++) {
      final pixel = mapDataToPixel(points[i], size, bounds);
      path.lineTo(pixel.dx, pixel.dy);
    }

    canvas.drawPath(path, linePaint);

    if (showPoints) {
      for (final point in points) {
        final pixel = mapDataToPixel(point, size, bounds);
        canvas.drawCircle(pixel, pointRadius, pointPaint);
      }
    }
  }
}
