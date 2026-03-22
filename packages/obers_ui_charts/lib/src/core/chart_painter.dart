import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:obers_ui_charts/src/core/chart_data.dart';
import 'package:obers_ui_charts/src/core/chart_theme.dart';

/// Padding reserved for axis labels.
class OiChartPadding {
  const OiChartPadding({
    this.left = 48,
    this.top = 16,
    this.right = 16,
    this.bottom = 32,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;
}

/// Abstract base painter for all chart types.
///
/// Provides shared utilities for grid/axis rendering and data-to-pixel mapping.
abstract class OiChartPainter extends CustomPainter {
  OiChartPainter({
    required this.data,
    required this.theme,
    this.padding = const OiChartPadding(),
  });

  final OiChartData data;
  final OiChartTheme theme;
  final OiChartPadding padding;

  /// Number of horizontal grid lines to draw.
  int get horizontalGridLines => 5;

  /// Number of vertical grid lines to draw.
  int get verticalGridLines => 5;

  /// Returns the drawable area after subtracting axis padding.
  Rect chartArea(Size size) => Rect.fromLTRB(
    padding.left,
    padding.top,
    size.width - padding.right,
    size.height - padding.bottom,
  );

  /// Maps a data point to a pixel offset within the given [size].
  Offset mapDataToPixel(OiDataPoint point, Size size, OiChartBounds bounds) {
    final area = chartArea(size);
    final normalizedX = (point.x - bounds.minX) / bounds.xRange;
    final normalizedY = (point.y - bounds.minY) / bounds.yRange;

    return Offset(
      area.left + normalizedX * area.width,
      area.bottom - normalizedY * area.height,
    );
  }

  /// Paints horizontal and vertical grid lines.
  void paintGrid(
    Canvas canvas,
    Size size,
    OiChartBounds bounds,
    OiChartTheme theme,
  ) {
    final area = chartArea(size);
    final paint = Paint()
      ..color = theme.colors.gridColor
      ..strokeWidth = theme.gridLineWidth
      ..style = PaintingStyle.stroke;

    // Horizontal grid lines
    for (var i = 0; i <= horizontalGridLines; i++) {
      final fraction = i / horizontalGridLines;
      final y = area.bottom - fraction * area.height;
      canvas.drawLine(Offset(area.left, y), Offset(area.right, y), paint);
    }

    // Vertical grid lines
    for (var i = 0; i <= verticalGridLines; i++) {
      final fraction = i / verticalGridLines;
      final x = area.left + fraction * area.width;
      canvas.drawLine(Offset(x, area.top), Offset(x, area.bottom), paint);
    }
  }

  /// Paints the X and Y axes.
  void paintAxes(
    Canvas canvas,
    Size size,
    OiChartBounds bounds,
    OiChartTheme theme,
  ) {
    final area = chartArea(size);
    final paint = Paint()
      ..color = theme.colors.axisColor
      ..strokeWidth = theme.axisLineWidth
      ..style = PaintingStyle.stroke;

    // X axis (bottom), then Y axis (left).
    canvas
      ..drawLine(
        Offset(area.left, area.bottom),
        Offset(area.right, area.bottom),
        paint,
      )
      ..drawLine(
        Offset(area.left, area.top),
        Offset(area.left, area.bottom),
        paint,
      );

    _paintAxisLabels(canvas, size, bounds, theme);
  }

  void _paintAxisLabels(
    Canvas canvas,
    Size size,
    OiChartBounds bounds,
    OiChartTheme theme,
  ) {
    final area = chartArea(size);

    // Y axis labels
    for (var i = 0; i <= horizontalGridLines; i++) {
      final fraction = i / horizontalGridLines;
      final value = bounds.minY + fraction * bounds.yRange;
      final y = area.bottom - fraction * area.height;
      final label = _formatNumber(value);

      final painter = TextPainter(
        text: TextSpan(text: label, style: theme.textStyles.axisLabel),
        textDirection: ui.TextDirection.ltr,
      )..layout();

      painter.paint(
        canvas,
        Offset(area.left - painter.width - 4, y - painter.height / 2),
      );
    }

    // X axis labels
    for (var i = 0; i <= verticalGridLines; i++) {
      final fraction = i / verticalGridLines;
      final value = bounds.minX + fraction * bounds.xRange;
      final x = area.left + fraction * area.width;
      final label = _formatNumber(value);

      final painter = TextPainter(
        text: TextSpan(text: label, style: theme.textStyles.axisLabel),
        textDirection: ui.TextDirection.ltr,
      )..layout();

      painter.paint(canvas, Offset(x - painter.width / 2, area.bottom + 4));
    }
  }

  static String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  @override
  bool shouldRepaint(covariant OiChartPainter oldDelegate) =>
      data != oldDelegate.data || theme != oldDelegate.theme;
}
