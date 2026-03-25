import 'package:flutter/painting.dart';
import 'package:obers_ui/obers_ui.dart';

/// Shared grid and axis painting utilities for Cartesian charts.
///
/// Provides static methods for drawing grid lines, axis lines, and tick
/// labels that are reused by [OiLineChart], [OiBarChart], and
/// [OiScatterPlot].
abstract final class OiChartGrid {
  /// Default padding for non-compact charts.
  static const double defaultPadding = 40;

  /// Default padding for compact charts.
  static const double compactPadding = 24;

  /// Computes the chart drawing area from the canvas [size].
  static Rect computeChartRect(
    Size size, {
    bool compact = false,
    double? leftPadding,
    double? bottomPadding,
  }) {
    final p = compact ? compactPadding : defaultPadding;
    final left = leftPadding ?? p;
    final bottom = bottomPadding ?? p;
    return Rect.fromLTRB(left, p / 2, size.width - 8, size.height - bottom);
  }

  /// Draws axis lines along the left and bottom edges of [chartRect].
  static void paintAxes(
    Canvas canvas,
    Rect chartRect, {
    required Color axisColor,
    bool highContrast = false,
  }) {
    final paint = Paint()
      ..color = axisColor
      ..strokeWidth = highContrast ? 2.0 : 1.0;

    canvas
      // Left axis.
      ..drawLine(
        Offset(chartRect.left, chartRect.top),
        Offset(chartRect.left, chartRect.bottom),
        paint,
      )
      // Bottom axis.
      ..drawLine(
        Offset(chartRect.left, chartRect.bottom),
        Offset(chartRect.right, chartRect.bottom),
        paint,
      );
  }

  /// Draws horizontal and vertical grid lines inside [chartRect].
  static void paintGrid(
    Canvas canvas,
    Rect chartRect, {
    required Color gridColor,
    bool highContrast = false,
    int horizontalDivisions = 5,
    int verticalDivisions = 5,
  }) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = highContrast ? 1.0 : 0.5;

    // Horizontal grid lines.
    for (var i = 1; i < horizontalDivisions; i++) {
      final y = chartRect.top + chartRect.height * i / horizontalDivisions;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        paint,
      );
    }

    // Vertical grid lines.
    for (var i = 1; i < verticalDivisions; i++) {
      final x = chartRect.left + chartRect.width * i / verticalDivisions;
      canvas.drawLine(
        Offset(x, chartRect.top),
        Offset(x, chartRect.bottom),
        paint,
      );
    }
  }

  /// Paints tick labels along the x-axis below [chartRect].
  static void paintXLabels(
    Canvas canvas,
    Rect chartRect, {
    required List<String> labels,
    required Color labelColor,
    double fontSize = 10,
  }) {
    if (labels.isEmpty) return;
    for (var i = 0; i < labels.length; i++) {
      final x = labels.length == 1
          ? chartRect.center.dx
          : chartRect.left + chartRect.width * i / (labels.length - 1);
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(color: labelColor, fontSize: fontSize),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, chartRect.bottom + 4));
    }
  }

  /// Paints tick labels along the y-axis to the left of [chartRect].
  static void paintYLabels(
    Canvas canvas,
    Rect chartRect, {
    required List<String> labels,
    required Color labelColor,
    double fontSize = 10,
  }) {
    if (labels.isEmpty) return;
    for (var i = 0; i < labels.length; i++) {
      // Labels go from bottom (index 0) to top (last index).
      final y = chartRect.bottom - chartRect.height * i / (labels.length - 1);
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(color: labelColor, fontSize: fontSize),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(chartRect.left - tp.width - 4, y - tp.height / 2),
      );
    }
  }
}
