import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/_chart_grid_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_bar_chart/oi_bar_chart.dart'
    show OiBarChart;

/// Custom painter for [OiBarChart].
class OiBarChartPainter extends CustomPainter {
  /// Creates an [OiBarChartPainter].
  OiBarChartPainter({
    required this.categoryLabels,
    required this.values,
    required this.colors,
    required this.chartRect,
    required this.horizontal,
    required this.stacked,
    required this.showValues,
    required this.showGrid,
    required this.barRadius,
    required this.gridColor,
    required this.axisLabelColor,
    required this.textColor,
    required this.highContrast,
    required this.compact,
    required this.numSeries,
    required this.yLabels,
    required this.yDivisions,
    this.hoveredCategoryIndex,
    this.hoveredSeriesIndex,
  });

  /// Category labels for the axis.
  final List<String> categoryLabels;

  /// Values per category, each a list of series values.
  final List<List<double>> values;

  /// Resolved series colors.
  final List<Color> colors;

  /// The chart drawing area.
  final Rect chartRect;

  /// Whether bars are horizontal.
  final bool horizontal;

  /// Whether bars are stacked.
  final bool stacked;

  /// Whether to show value labels.
  final bool showValues;

  /// Whether to show grid.
  final bool showGrid;

  /// Corner radius for bars.
  final double barRadius;

  /// Grid line color.
  final Color gridColor;

  /// Axis label color.
  final Color axisLabelColor;

  /// Text color for value labels.
  final Color textColor;

  /// High-contrast mode.
  final bool highContrast;

  /// Compact mode.
  final bool compact;

  /// Number of series.
  final int numSeries;

  /// Y-axis tick labels.
  final List<String> yLabels;

  /// Y-axis divisions.
  final int yDivisions;

  /// Hovered category index.
  final int? hoveredCategoryIndex;

  /// Hovered series index.
  final int? hoveredSeriesIndex;

  double get _maxValue {
    var maxVal = 0.0;
    for (final catValues in values) {
      if (stacked) {
        var sum = 0.0;
        for (final v in catValues) {
          sum += v;
        }
        maxVal = math.max(maxVal, sum);
      } else {
        for (final v in catValues) {
          maxVal = math.max(maxVal, v);
        }
      }
    }
    return maxVal == 0 ? 1.0 : maxVal;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    if (horizontal) {
      _paintHorizontal(canvas, size);
    } else {
      _paintVertical(canvas, size);
    }
  }

  void _paintVertical(Canvas canvas, Size size) {
    // Grid.
    if (showGrid) {
      OiChartGrid.paintGrid(
        canvas,
        chartRect,
        gridColor: gridColor,
        highContrast: highContrast,
        horizontalDivisions: yDivisions,
        verticalDivisions: values.length,
      );
    }
    OiChartGrid.paintAxes(
      canvas,
      chartRect,
      axisColor: gridColor,
      highContrast: highContrast,
    );

    // Y-axis labels.
    OiChartGrid.paintYLabels(
      canvas,
      chartRect,
      labels: yLabels,
      labelColor: axisLabelColor,
    );

    final maxVal = _maxValue;
    final catWidth = chartRect.width / values.length;
    final catPadding = catWidth * 0.15;

    for (var ci = 0; ci < values.length; ci++) {
      final catX = chartRect.left + ci * catWidth;
      final catValues = values[ci];

      // Category label.
      final labelTp = TextPainter(
        text: TextSpan(
          text: categoryLabels[ci],
          style: TextStyle(color: axisLabelColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: catWidth);
      labelTp.paint(
        canvas,
        Offset(catX + catWidth / 2 - labelTp.width / 2, chartRect.bottom + 4),
      );

      if (stacked) {
        _paintStackedVertical(
          canvas,
          catX + catPadding,
          catWidth - catPadding * 2,
          catValues,
          maxVal,
          ci,
        );
      } else {
        _paintGroupedVertical(
          canvas,
          catX + catPadding,
          catWidth - catPadding * 2,
          catValues,
          maxVal,
          ci,
        );
      }
    }
  }

  void _paintGroupedVertical(
    Canvas canvas,
    double catX,
    double catW,
    List<double> catValues,
    double maxVal,
    int ci,
  ) {
    final barW = catW / numSeries;

    for (var si = 0; si < catValues.length && si < numSeries; si++) {
      final val = catValues[si];
      final barH = chartRect.height * val / maxVal;
      final x = catX + si * barW;
      final y = chartRect.bottom - barH;

      final isHovered = hoveredCategoryIndex == ci && hoveredSeriesIndex == si;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x + 1, y, barW - 2, barH),
        topLeft: Radius.circular(barRadius),
        topRight: Radius.circular(barRadius),
      );

      final paint = Paint()..color = colors[si % colors.length];
      canvas.drawRRect(rect, paint);

      if (isHovered) {
        final borderPaint = Paint()
          ..color = colors[si % colors.length]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawRRect(rect, borderPaint);
      }

      // Value label.
      if (showValues && barH > 16) {
        final valTp = TextPainter(
          text: TextSpan(
            text: val.toStringAsFixed(val == val.roundToDouble() ? 0 : 1),
            style: TextStyle(color: textColor, fontSize: 9),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        valTp.paint(
          canvas,
          Offset(x + barW / 2 - valTp.width / 2, y - valTp.height - 2),
        );
      }
    }
  }

  void _paintStackedVertical(
    Canvas canvas,
    double catX,
    double catW,
    List<double> catValues,
    double maxVal,
    int ci,
  ) {
    var cumH = 0.0;

    for (var si = 0; si < catValues.length && si < numSeries; si++) {
      final val = catValues[si];
      final barH = chartRect.height * val / maxVal;
      final y = chartRect.bottom - cumH - barH;

      final isLast = si == catValues.length - 1;
      final topRadius = isLast ? Radius.circular(barRadius) : Radius.zero;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(catX + 1, y, catW - 2, barH),
        topLeft: topRadius,
        topRight: topRadius,
      );

      canvas.drawRRect(rect, Paint()..color = colors[si % colors.length]);

      cumH += barH;
    }
  }

  void _paintHorizontal(Canvas canvas, Size size) {
    // Grid.
    if (showGrid) {
      OiChartGrid.paintGrid(
        canvas,
        chartRect,
        gridColor: gridColor,
        highContrast: highContrast,
        horizontalDivisions: values.length,
        verticalDivisions: yDivisions,
      );
    }
    OiChartGrid.paintAxes(
      canvas,
      chartRect,
      axisColor: gridColor,
      highContrast: highContrast,
    );

    final maxVal = _maxValue;
    final catHeight = chartRect.height / values.length;
    final catPadding = catHeight * 0.15;

    for (var ci = 0; ci < values.length; ci++) {
      final catY = chartRect.top + ci * catHeight;
      final catValues = values[ci];

      // Category label on left.
      final labelTp = TextPainter(
        text: TextSpan(
          text: categoryLabels[ci],
          style: TextStyle(color: axisLabelColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelTp.paint(
        canvas,
        Offset(
          chartRect.left - labelTp.width - 4,
          catY + catHeight / 2 - labelTp.height / 2,
        ),
      );

      if (stacked) {
        var cumW = 0.0;
        for (var si = 0; si < catValues.length && si < numSeries; si++) {
          final val = catValues[si];
          final barW = chartRect.width * val / maxVal;
          final x = chartRect.left + cumW;
          final barH = (catHeight - catPadding * 2) / 1;

          final isLast = si == catValues.length - 1;
          final endRadius = isLast ? Radius.circular(barRadius) : Radius.zero;

          final rect = RRect.fromRectAndCorners(
            Rect.fromLTWH(x, catY + catPadding + 1, barW, barH - 2),
            topRight: endRadius,
            bottomRight: endRadius,
          );
          canvas.drawRRect(rect, Paint()..color = colors[si % colors.length]);
          cumW += barW;
        }
      } else {
        final barH = (catHeight - catPadding * 2) / numSeries;
        for (var si = 0; si < catValues.length && si < numSeries; si++) {
          final val = catValues[si];
          final barW = chartRect.width * val / maxVal;
          final y = catY + catPadding + si * barH;

          final rect = RRect.fromRectAndCorners(
            Rect.fromLTWH(chartRect.left, y + 1, barW, barH - 2),
            topRight: Radius.circular(barRadius),
            bottomRight: Radius.circular(barRadius),
          );
          canvas.drawRRect(rect, Paint()..color = colors[si % colors.length]);

          // Value label.
          if (showValues && barW > 30) {
            final valTp = TextPainter(
              text: TextSpan(
                text: val.toStringAsFixed(val == val.roundToDouble() ? 0 : 1),
                style: TextStyle(color: textColor, fontSize: 9),
              ),
              textDirection: TextDirection.ltr,
            )..layout();
            valTp.paint(
              canvas,
              Offset(
                chartRect.left + barW + 4,
                y + barH / 2 - valTp.height / 2,
              ),
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(OiBarChartPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.colors != colors ||
      oldDelegate.horizontal != horizontal ||
      oldDelegate.stacked != stacked ||
      oldDelegate.showValues != showValues ||
      oldDelegate.showGrid != showGrid ||
      oldDelegate.barRadius != barRadius ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.highContrast != highContrast ||
      oldDelegate.compact != compact ||
      oldDelegate.hoveredCategoryIndex != hoveredCategoryIndex ||
      oldDelegate.hoveredSeriesIndex != hoveredSeriesIndex;
}
