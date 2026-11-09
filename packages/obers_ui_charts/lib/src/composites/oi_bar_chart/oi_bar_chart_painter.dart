import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:obers_ui_charts/src/composites/_chart_grid_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_bar_chart/oi_bar_chart.dart'
    show OiBarChart;
import 'package:obers_ui_charts/src/composites/oi_bar_chart/oi_bar_chart_data.dart';
import 'package:obers_ui_charts/src/composites/oi_bar_chart/oi_bar_chart_layout.dart';

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
    this.categoryLayout,
    this.axisLabelGap = 4,
    this.numericLabelGap = 4,
    this.valueLabelGap = 2,
    this.domainMin = 0,
    this.domainMax,
    this.patterns = const [],
    this.categoryColors = const [],
    this.categoryGroups = const [],
    this.emphasizedCategories = const [],
    this.gridDashPattern,
    this.gridWidth,
    this.labelStyle,
    this.hoveredCategoryIndex,
    this.hoveredSeriesIndex,
  });

  /// Distance from plot to category labels.
  final double axisLabelGap;

  /// Distance from plot to numeric tick labels.
  final double numericLabelGap;

  /// Distance from bar to emphasized values.
  final double valueLabelGap;

  /// Shared category geometry, also used for pointer hit testing.
  final BarCategoryLayout? categoryLayout;

  /// Optional per-category emphasis, independent of the global value toggle.
  final List<bool> emphasizedCategories;

  /// Theme-provided grid dash pattern.
  final List<double>? gridDashPattern;

  /// Theme-provided grid stroke width.
  final double? gridWidth;

  bool _emphasized(int index) =>
      index < emphasizedCategories.length && emphasizedCategories[index];

  /// Lower bound of the numeric axis.
  final double domainMin;

  /// Optional explicit upper bound, shared with the axis label calculation.
  final double? domainMax;

  double _fraction(double value, double max) =>
      ((value - domainMin) / (max - domainMin)).clamp(0.0, 1.0);

  /// Resolved fill patterns per category/series.
  final List<List<OiBarPattern>> patterns;

  /// Per-category color overrides.
  final List<List<Color>> categoryColors;

  /// Optional grouping labels for the category axis.
  final List<String?> categoryGroups;

  /// Theme-derived axis typography.
  final TextStyle? labelStyle;

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
    if (domainMax != null) return domainMax!;
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
      _paintCategoryGroups(canvas);
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
        verticalDivisions: gridDashPattern == null ? values.length : 0,
        dashPattern: gridDashPattern,
        strokeWidth: gridWidth,
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
      labelStyle: labelStyle,
      labelGap: numericLabelGap,
    );

    final maxVal = _maxValue;
    final catWidth = chartRect.width / values.length;
    final catPadding = catWidth * 0.15;

    for (var ci = 0; ci < values.length; ci++) {
      final bounds = categoryLayout?.bars[ci];
      final catX = bounds == null
          ? chartRect.left + ci * catWidth
          : bounds.center.dx - catWidth / 2;
      final catValues = values[ci];

      // Category label.
      final labelTp = TextPainter(
        text: TextSpan(
          text: categoryLabels[ci],
          style: (labelStyle ?? const TextStyle(fontSize: 10)).copyWith(
            color: _emphasized(ci) ? textColor : axisLabelColor,
            fontWeight: _emphasized(ci)
                ? FontWeight.w600
                : labelStyle?.fontWeight,
            fontVariations: _emphasized(ci)
                ? const []
                : labelStyle?.fontVariations,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: catWidth);
      labelTp.paint(
        canvas,
        Offset(
          catX + catWidth / 2 - labelTp.width / 2,
          chartRect.bottom + axisLabelGap,
        ),
      );

      if (stacked) {
        _paintStackedVertical(
          canvas,
          bounds?.left ?? catX + catPadding,
          bounds?.width ?? catWidth - catPadding * 2,
          catValues,
          maxVal,
          ci,
        );
      } else {
        _paintGroupedVertical(
          canvas,
          bounds?.left ?? catX + catPadding,
          bounds?.width ?? catWidth - catPadding * 2,
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
      final barH = chartRect.height * _fraction(val, maxVal);
      final x = catX + si * barW;
      final y = chartRect.bottom - barH;

      final isHovered = hoveredCategoryIndex == ci && hoveredSeriesIndex == si;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(
          categoryLayout == null ? x + 1 : x,
          y,
          categoryLayout == null ? barW - 2 : barW,
          barH,
        ),
        topLeft: Radius.circular(barRadius),
        topRight: Radius.circular(barRadius),
      );

      _paintBar(canvas, rect, ci, si);

      if (isHovered) {
        final borderPaint = Paint()
          ..color = colors[si % colors.length]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawRRect(rect, borderPaint);
      }

      // Value label.
      if ((showValues || _emphasized(ci)) && barH > 16) {
        final valTp = TextPainter(
          text: TextSpan(
            text: val.toStringAsFixed(val == val.roundToDouble() ? 0 : 1),
            style: (labelStyle ?? const TextStyle(fontSize: 9)).copyWith(
              color: textColor,
              fontWeight: _emphasized(ci)
                  ? FontWeight.w600
                  : labelStyle?.fontWeight,
              fontVariations: _emphasized(ci)
                  ? const []
                  : labelStyle?.fontVariations,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        valTp.paint(
          canvas,
          Offset(
            x + barW / 2 - valTp.width / 2,
            y - valTp.height - valueLabelGap,
          ),
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
    var cumulative = 0.0;

    for (var si = 0; si < catValues.length && si < numSeries; si++) {
      final val = catValues[si];
      final start = _fraction(cumulative, maxVal);
      cumulative += val;
      final end = _fraction(cumulative, maxVal);
      final barH = chartRect.height * math.max(0, end - start);
      final y = chartRect.bottom - chartRect.height * end;

      final isLast = si == catValues.length - 1;
      final topRadius = isLast ? Radius.circular(barRadius) : Radius.zero;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(
          categoryLayout == null ? catX + 1 : catX,
          y,
          categoryLayout == null ? catW - 2 : catW,
          barH,
        ),
        topLeft: topRadius,
        topRight: topRadius,
      );

      _paintBar(canvas, rect, ci, si);
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
          style: (labelStyle ?? const TextStyle(fontSize: 10)).copyWith(
            color: axisLabelColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelTp.paint(
        canvas,
        Offset(
          chartRect.left - labelTp.width - numericLabelGap,
          catY + catHeight / 2 - labelTp.height / 2,
        ),
      );

      if (stacked) {
        var cumulative = 0.0;
        for (var si = 0; si < catValues.length && si < numSeries; si++) {
          final val = catValues[si];
          final start = _fraction(cumulative, maxVal);
          cumulative += val;
          final end = _fraction(cumulative, maxVal);
          final barW = chartRect.width * math.max(0, end - start);
          final x = chartRect.left + chartRect.width * start;
          final barH = (catHeight - catPadding * 2) / 1;

          final isLast = si == catValues.length - 1;
          final endRadius = isLast ? Radius.circular(barRadius) : Radius.zero;

          final rect = RRect.fromRectAndCorners(
            Rect.fromLTWH(x, catY + catPadding + 1, barW, barH - 2),
            topRight: endRadius,
            bottomRight: endRadius,
          );
          _paintBar(canvas, rect, ci, si);
        }
      } else {
        final barH = (catHeight - catPadding * 2) / numSeries;
        for (var si = 0; si < catValues.length && si < numSeries; si++) {
          final val = catValues[si];
          final barW = chartRect.width * _fraction(val, maxVal);
          final y = catY + catPadding + si * barH;

          final rect = RRect.fromRectAndCorners(
            Rect.fromLTWH(chartRect.left, y + 1, barW, barH - 2),
            topRight: Radius.circular(barRadius),
            bottomRight: Radius.circular(barRadius),
          );
          _paintBar(canvas, rect, ci, si);

          // Value label.
          if (showValues && barW > 30) {
            final valTp = TextPainter(
              text: TextSpan(
                text: val.toStringAsFixed(val == val.roundToDouble() ? 0 : 1),
                style: (labelStyle ?? const TextStyle(fontSize: 9)).copyWith(
                  color: textColor,
                ),
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

  void _paintBar(Canvas canvas, RRect rect, int category, int series) {
    final color =
        category < categoryColors.length &&
            series < categoryColors[category].length
        ? categoryColors[category][series]
        : colors[series % colors.length];
    final pattern =
        category < patterns.length && series < patterns[category].length
        ? patterns[category][series]
        : OiBarPattern.solid;
    canvas.drawRRect(
      rect,
      Paint()
        ..color = pattern == OiBarPattern.solid
            ? color
            : color.withValues(alpha: .16),
    );
    if (pattern != OiBarPattern.diagonal ||
        rect.width <= 0 ||
        rect.height <= 0) {
      return;
    }
    canvas
      ..save()
      ..clipRRect(rect);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var x = rect.left - rect.height; x <= rect.right; x += 5) {
      canvas.drawLine(
        Offset(x, rect.bottom),
        Offset(x + rect.height, rect.top),
        paint,
      );
    }
    canvas.restore();
  }

  void _paintCategoryGroups(Canvas canvas) {
    if (horizontal || categoryGroups.isEmpty || values.isEmpty) return;
    if (categoryLayout != null) {
      for (final section in categoryLayout!.sections) {
        final text = TextPainter(
          text: TextSpan(
            text: section.label,
            style: (labelStyle ?? const TextStyle(fontSize: 10)).copyWith(
              color: axisLabelColor,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: section.bounds.width);
        final ruleY = chartRect.bottom + 28;
        canvas.drawLine(
          Offset(section.bounds.left, ruleY),
          Offset(section.bounds.right, ruleY),
          Paint()
            ..color = gridColor
            ..strokeWidth = 1,
        );
        text.paint(
          canvas,
          Offset(section.bounds.center.dx - text.width / 2, ruleY + 4),
        );
      }
      return;
    }
    final categoryWidth = chartRect.width / values.length;
    var start = 0;
    while (start < categoryGroups.length) {
      final label = categoryGroups[start];
      var end = start + 1;
      while (end < categoryGroups.length && categoryGroups[end] == label) {
        end++;
      }
      if (label != null) {
        final text = TextPainter(
          text: TextSpan(
            text: label,
            style: (labelStyle ?? const TextStyle(fontSize: 10)).copyWith(
              color: axisLabelColor,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: categoryWidth * (end - start));
        text.paint(
          canvas,
          Offset(
            chartRect.left + categoryWidth * (start + end) / 2 - text.width / 2,
            chartRect.bottom + 20,
          ),
        );
      }
      start = end;
    }
  }

  @override
  bool shouldRepaint(OiBarChartPainter oldDelegate) =>
      oldDelegate.axisLabelGap != axisLabelGap ||
      oldDelegate.numericLabelGap != numericLabelGap ||
      oldDelegate.valueLabelGap != valueLabelGap ||
      oldDelegate.categoryLayout != categoryLayout ||
      oldDelegate.emphasizedCategories != emphasizedCategories ||
      oldDelegate.gridDashPattern != gridDashPattern ||
      oldDelegate.gridWidth != gridWidth ||
      oldDelegate.domainMin != domainMin ||
      oldDelegate.domainMax != domainMax ||
      oldDelegate.patterns != patterns ||
      oldDelegate.categoryColors != categoryColors ||
      oldDelegate.categoryGroups != categoryGroups ||
      oldDelegate.labelStyle != labelStyle ||
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
