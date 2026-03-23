import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:obers_ui_charts/src/charts/bar/bar_chart_data_processor.dart';
import 'package:obers_ui_charts/src/charts/bar/bar_chart_orientation.dart';
import 'package:obers_ui_charts/src/core/chart_painter.dart';

/// Custom painter for bar charts.
///
/// Draws grid, axes, and rectangular bars for each data point in each series.
class OiBarChartPainter extends OiChartPainter {
  OiBarChartPainter({
    required super.data,
    required super.theme,
    super.padding,
    this.barSpacing = 8,
    this.orientation = OiBarChartOrientation.vertical,
    this.barRadius = 2,
  });

  final double barSpacing;
  final OiBarChartOrientation orientation;
  final double barRadius;

  final OiBarChartDataProcessor _processor = const OiBarChartDataProcessor();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final bounds = data.bounds;

    canvas
      ..save()
      ..clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    paintGrid(canvas, size, bounds, theme);
    paintAxes(canvas, size, bounds, theme);

    final allRects = _processor.computeBarRects(
      data,
      size,
      spacing: barSpacing,
      padding: padding,
      orientation: orientation,
    );

    for (var si = 0; si < allRects.length; si++) {
      final color = data.series[si].color ?? theme.colors.colorForSeries(si);
      for (final rect in allRects[si]) {
        paintBar(canvas, rect, color);
      }
    }

    canvas.restore();
  }

  /// Paints a single bar with optional rounded top corners.
  void paintBar(Canvas canvas, Rect rect, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (barRadius > 0) {
      final rrect = RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular(barRadius),
        topRight: Radius.circular(barRadius),
      );
      canvas.drawRRect(rrect, paint);
    } else {
      canvas.drawRect(rect, paint);
    }
  }
}
