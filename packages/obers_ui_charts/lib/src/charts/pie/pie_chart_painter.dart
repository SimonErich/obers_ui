import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:obers_ui_charts/src/charts/pie/pie_chart_data_processor.dart';
import 'package:obers_ui_charts/src/core/chart_painter.dart';

/// Custom painter for pie (and donut) charts.
///
/// Renders slices from the first series in [data].
class OiPieChartPainter extends OiChartPainter {
  OiPieChartPainter({
    required super.data,
    required super.theme,
    this.holeRadius = 0,
  }) : super(padding: const OiChartPadding(left: 16, bottom: 16));

  /// Inner hole radius for donut charts (0.0 = full pie, 0.5 = half-hole).
  final double holeRadius;

  final OiPieChartDataProcessor _processor = const OiPieChartDataProcessor();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    if (data.isEmpty) return;

    final area = chartArea(size);
    final center = area.center;
    final radius = math.min(area.width, area.height) / 2;

    if (radius <= 0) return;

    canvas
      ..save()
      ..clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final series = data.series.first;
    final slices = _processor.computeSlices(series);

    for (var i = 0; i < slices.length; i++) {
      final slice = slices[i];
      final color = series.color ?? theme.colors.colorForSeries(i);
      paintSlice(
        canvas,
        center,
        radius,
        slice.startAngle,
        slice.sweepAngle,
        color,
      );
    }

    // Draw hole for donut chart.
    if (holeRadius > 0) {
      final holePaint = Paint()
        ..color = theme.colors.backgroundColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius * holeRadius, holePaint);
    }

    canvas.restore();
  }

  /// Paints a single pie slice as an arc segment.
  void paintSlice(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
      )
      ..close();

    canvas.drawPath(path, paint);
  }
}
