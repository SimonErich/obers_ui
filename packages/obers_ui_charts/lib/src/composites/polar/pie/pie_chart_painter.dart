import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:obers_ui_charts/src/composites/polar/oi_polar_data.dart';
import 'package:obers_ui_charts/src/composites/polar/oi_polar_painter.dart';
import 'package:obers_ui_charts/src/composites/polar/pie/pie_chart_data_processor.dart';
import 'package:obers_ui_charts/src/foundation/data/chart_data.dart';

/// Custom painter for pie (and donut) charts.
///
/// Extends [OiPolarPainter] to share radial coordinate system.
/// Renders slices from either [OiPolarData] or legacy [OiChartData].
class OiPieChartPainter extends OiPolarPainter {
  OiPieChartPainter({
    required OiPolarData super.data,
    required super.theme,
    this.holeRadius = 0,
    this.legacyData,
  });

  /// Inner hole radius for donut charts (0.0 = full pie, 0.5 = half-hole).
  final double holeRadius;

  /// Legacy data support for backward compatibility.
  final OiChartData? legacyData;

  final OiPieChartDataProcessor _processor = const OiPieChartDataProcessor();

  @override
  void paintSegments(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    if (radius <= 0) return;

    final slices = data.isEmpty && legacyData != null && !legacyData!.isEmpty
        ? _processor.computeSlices(legacyData!.series.first)
        : _processor.computeSlicesFromPolarData(data);

    for (var i = 0; i < slices.length; i++) {
      final slice = slices[i];
      final color = i < data.segments.length && data.segments[i].color != null
          ? data.segments[i].color!
          : theme.colors.colorForSeries(i);
      _paintSlice(canvas, center, radius, slice.startAngle, slice.sweepAngle, color);
    }

    // Draw hole for donut chart.
    if (holeRadius > 0) {
      final holePaint = Paint()
        ..color = theme.colors.backgroundColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius * holeRadius, holePaint);
    }
  }

  void _paintSlice(
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
