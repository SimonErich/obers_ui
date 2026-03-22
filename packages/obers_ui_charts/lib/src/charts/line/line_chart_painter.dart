import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:obers_ui_charts/src/core/chart_data.dart';
import 'package:obers_ui_charts/src/core/chart_painter.dart';

/// Custom painter for line charts.
///
/// Draws grid, axes, and one line per series with optional data-point dots.
class OiLineChartPainter extends OiChartPainter {
  OiLineChartPainter({
    required super.data,
    required super.theme,
    super.padding,
    this.strokeWidth = 2,
    this.pointRadius = 4,
    this.showPoints = true,
  });

  final double strokeWidth;
  final double pointRadius;
  final bool showPoints;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final bounds = data.bounds;

    canvas
      ..save()
      ..clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    paintGrid(canvas, size, bounds, theme);
    paintAxes(canvas, size, bounds, theme);

    for (var i = 0; i < data.series.length; i++) {
      final series = data.series[i];
      final color = series.color ?? theme.colors.colorForSeries(i);
      paintSeries(canvas, size, series, bounds, color);
    }

    canvas.restore();
  }

  /// Paints a single series as a connected line with optional dots.
  void paintSeries(
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
