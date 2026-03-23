import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:obers_ui_charts/src/composites/cartesian/bar/bar_chart_data_processor.dart';
import 'package:obers_ui_charts/src/composites/cartesian/bar/bar_chart_orientation.dart';
import 'package:obers_ui_charts/src/composites/cartesian/oi_cartesian_painter.dart';

/// Custom painter for bar charts.
///
/// Extends [OiCartesianPainter] to share grid/axis rendering.
/// Draws rectangular bars for each data point in each series.
class OiBarChartPainter extends OiCartesianPainter {
  OiBarChartPainter({
    required super.data,
    required super.theme,
    super.padding,
    super.showGrid,
    super.xAxis,
    super.yAxis,
    this.barSpacing = 8,
    this.orientation = OiBarChartOrientation.vertical,
    this.barRadius = 2,
  });

  final double barSpacing;
  final OiBarChartOrientation orientation;
  final double barRadius;

  final OiBarChartDataProcessor _processor = const OiBarChartDataProcessor();

  @override
  void paintSeries(Canvas canvas, Size size) {
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
        _paintBar(canvas, rect, color);
      }
    }
  }

  void _paintBar(Canvas canvas, Rect rect, Color color) {
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
