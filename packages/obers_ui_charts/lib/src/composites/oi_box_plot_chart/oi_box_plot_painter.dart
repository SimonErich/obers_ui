import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:obers_ui_charts/src/composites/_chart_grid_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_box_plot_chart/oi_box_plot_data.dart';

/// Custom painter for box plot charts.
///
/// For each [OiResolvedBox] draws:
/// - A filled rectangle from Q1 to Q3 (the box body).
/// - A horizontal line at the median.
/// - Whisker lines from Q1 down to [OiBoxPlotStats.min] and from Q3 up to
///   [OiBoxPlotStats.max] with short horizontal caps.
/// - Individual dots for outlier values.
/// - An optional mean dot (when [showMean] is `true`).
/// - An optional notch at the median for confidence interval context (when
///   [showNotch] is `true`).
///
/// Supports both vertical (default) and horizontal ([horizontal]) layouts.
class OiBoxPlotPainter extends CustomPainter {
  /// Creates an [OiBoxPlotPainter].
  OiBoxPlotPainter({
    required this.boxes,
    required this.categoryCount,
    required this.chartRect,
    required this.minY,
    required this.maxY,
    required this.showMean,
    required this.showNotch,
    required this.horizontal,
    required this.showGrid,
    required this.gridColor,
    required this.axisLabelColor,
    required this.highContrast,
    required this.compact,
    required this.categoryLabels,
    required this.yLabels,
    required this.yDivisions,
  });

  /// The resolved boxes to paint.
  final List<OiResolvedBox> boxes;

  /// Total number of category slots on the category axis.
  final int categoryCount;

  /// The chart drawing area in canvas coordinates.
  final Rect chartRect;

  /// Minimum value on the value axis.
  final double minY;

  /// Maximum value on the value axis.
  final double maxY;

  /// Whether to draw a mean dot inside each box.
  final bool showMean;

  /// Whether to draw a confidence-interval notch at the median.
  final bool showNotch;

  /// When `true`, categories run along the y-axis and values along the x-axis.
  final bool horizontal;

  /// Whether to show grid lines.
  final bool showGrid;

  /// Grid line color.
  final Color gridColor;

  /// Axis label color.
  final Color axisLabelColor;

  /// High-contrast accessibility mode.
  final bool highContrast;

  /// Compact layout mode.
  final bool compact;

  /// Category-axis tick labels.
  final List<String> categoryLabels;

  /// Value-axis tick labels.
  final List<String> yLabels;

  /// Number of value-axis divisions.
  final int yDivisions;

  double get _rangeY {
    final r = maxY - minY;
    return r == 0 ? 1.0 : r;
  }

  /// Maps a data value to a canvas coordinate on the value axis.
  double _mapValue(double v) {
    if (horizontal) {
      return chartRect.left + chartRect.width * (v - minY) / _rangeY;
    }
    return chartRect.bottom - chartRect.height * (v - minY) / _rangeY;
  }

  /// Returns the center coordinate of category slot [index] on the category
  /// axis.
  double _categoryCenter(int index) {
    final count = math.max(categoryCount, 1);
    if (horizontal) {
      return chartRect.top + chartRect.height * (index + 0.5) / count;
    }
    return chartRect.left + chartRect.width * (index + 0.5) / count;
  }

  /// Half-width (or half-height in horizontal mode) of a single box.
  double _halfBoxWidth(int seriesCount) {
    final count = math.max(categoryCount, 1);
    final slotSize = horizontal
        ? chartRect.height / count
        : chartRect.width / count;
    // The box occupies 50 % of its slot (25 % gap each side).
    final fraction = seriesCount > 1 ? 0.35 : 0.40;
    return slotSize * fraction;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final divCount = math.max(yDivisions, 1);

    if (showGrid) {
      if (horizontal) {
        OiChartGrid.paintGrid(
          canvas,
          chartRect,
          gridColor: gridColor,
          highContrast: highContrast,
          horizontalDivisions: math.max(categoryCount, 1),
          verticalDivisions: divCount,
        );
      } else {
        OiChartGrid.paintGrid(
          canvas,
          chartRect,
          gridColor: gridColor,
          highContrast: highContrast,
          horizontalDivisions: divCount,
          verticalDivisions: 0,
        );
      }
    }

    OiChartGrid.paintAxes(
      canvas,
      chartRect,
      axisColor: gridColor,
      highContrast: highContrast,
    );

    // Paint axis labels.
    if (horizontal) {
      OiChartGrid.paintXLabels(
        canvas,
        chartRect,
        labels: yLabels,
        labelColor: axisLabelColor,
      );
      OiChartGrid.paintYLabels(
        canvas,
        chartRect,
        labels: categoryLabels,
        labelColor: axisLabelColor,
      );
    } else {
      OiChartGrid.paintYLabels(
        canvas,
        chartRect,
        labels: yLabels,
        labelColor: axisLabelColor,
      );
      OiChartGrid.paintXLabels(
        canvas,
        chartRect,
        labels: categoryLabels,
        labelColor: axisLabelColor,
      );
    }

    // Determine per-category series count for box width.
    final seriesCount = boxes.isEmpty
        ? 1
        : boxes.map((b) => b.seriesIndex).toSet().length;

    for (var i = 0; i < boxes.length; i++) {
      _paintBox(canvas, boxes[i], seriesCount);
    }
  }

  void _paintBox(Canvas canvas, OiResolvedBox box, int seriesCount) {
    final stats = box.stats;
    final color = box.color;
    final hw = _halfBoxWidth(seriesCount);

    final center = _categoryCenter(box.categoryIndex);

    // Map value-axis positions.
    final q1Pos = _mapValue(stats.q1);
    final q3Pos = _mapValue(stats.q3);
    final medianPos = _mapValue(stats.median);
    final minPos = _mapValue(stats.min);
    final maxPos = _mapValue(stats.max);

    final strokeWidth = highContrast ? 2.0 : 1.5;
    final fillPaint = Paint()
      ..color = color.withValues(alpha: highContrast ? 1.0 : 0.75)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // ── Box body ──────────────────────────────────────────────────────────────

    final Rect boxRect;
    if (horizontal) {
      final left = math.min(q1Pos, q3Pos);
      final right = math.max(q1Pos, q3Pos);
      boxRect = Rect.fromLTRB(
        left.clamp(chartRect.left, chartRect.right),
        (center - hw).clamp(chartRect.top, chartRect.bottom),
        right.clamp(chartRect.left, chartRect.right),
        (center + hw).clamp(chartRect.top, chartRect.bottom),
      );
    } else {
      final top = math.min(q1Pos, q3Pos);
      final bottom = math.max(q1Pos, q3Pos);
      boxRect = Rect.fromLTRB(
        (center - hw).clamp(chartRect.left, chartRect.right),
        top.clamp(chartRect.top, chartRect.bottom),
        (center + hw).clamp(chartRect.left, chartRect.right),
        bottom.clamp(chartRect.top, chartRect.bottom),
      );
    }

    if (showNotch) {
      _paintNotchedBox(
        canvas,
        boxRect,
        medianPos,
        center,
        hw,
        fillPaint,
        strokePaint,
      );
    } else {
      canvas
        ..drawRect(boxRect, fillPaint)
        ..drawRect(boxRect, strokePaint);
    }

    // ── Median line ───────────────────────────────────────────────────────────

    final medianPaint = Paint()
      ..color = color
      ..strokeWidth = highContrast ? 3.0 : 2.0
      ..style = PaintingStyle.stroke;

    if (horizontal) {
      final mx = medianPos.clamp(chartRect.left, chartRect.right);
      canvas.drawLine(
        Offset(mx, boxRect.top),
        Offset(mx, boxRect.bottom),
        medianPaint,
      );
    } else {
      final my = medianPos.clamp(chartRect.top, chartRect.bottom);
      canvas.drawLine(
        Offset(boxRect.left, my),
        Offset(boxRect.right, my),
        medianPaint,
      );
    }

    // ── Whiskers ──────────────────────────────────────────────────────────────

    final capHalf = hw * 0.4;

    if (horizontal) {
      // Lower whisker (left side).
      final q1x = math.min(q1Pos, q3Pos).clamp(chartRect.left, chartRect.right);
      final minx = minPos.clamp(chartRect.left, chartRect.right);
      canvas
        ..drawLine(Offset(minx, center), Offset(q1x, center), strokePaint)
        ..drawLine(
          Offset(minx, center - capHalf),
          Offset(minx, center + capHalf),
          strokePaint,
        );

      // Upper whisker (right side).
      final q3x = math.max(q1Pos, q3Pos).clamp(chartRect.left, chartRect.right);
      final maxx = maxPos.clamp(chartRect.left, chartRect.right);
      canvas
        ..drawLine(Offset(q3x, center), Offset(maxx, center), strokePaint)
        ..drawLine(
          Offset(maxx, center - capHalf),
          Offset(maxx, center + capHalf),
          strokePaint,
        );
    } else {
      // Lower whisker (downward).
      final q1y = math.max(q1Pos, q3Pos).clamp(chartRect.top, chartRect.bottom);
      final miny = minPos.clamp(chartRect.top, chartRect.bottom);
      canvas
        ..drawLine(Offset(center, q1y), Offset(center, miny), strokePaint)
        ..drawLine(
          Offset(center - capHalf, miny),
          Offset(center + capHalf, miny),
          strokePaint,
        );

      // Upper whisker (upward).
      final q3y = math.min(q1Pos, q3Pos).clamp(chartRect.top, chartRect.bottom);
      final maxy = maxPos.clamp(chartRect.top, chartRect.bottom);
      canvas
        ..drawLine(Offset(center, q3y), Offset(center, maxy), strokePaint)
        ..drawLine(
          Offset(center - capHalf, maxy),
          Offset(center + capHalf, maxy),
          strokePaint,
        );
    }

    // ── Outliers ──────────────────────────────────────────────────────────────

    final outlierPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = highContrast ? 1.5 : 1.0;

    final outlierRadius = compact ? 2.5 : 3.5;

    for (final outlier in stats.outliers) {
      final vPos = _mapValue(outlier);
      final Offset outlierCenter;
      if (horizontal) {
        outlierCenter = Offset(
          vPos.clamp(chartRect.left, chartRect.right),
          center,
        );
      } else {
        outlierCenter = Offset(
          center,
          vPos.clamp(chartRect.top, chartRect.bottom),
        );
      }
      canvas.drawCircle(outlierCenter, outlierRadius, outlierPaint);
    }

    // ── Mean dot ──────────────────────────────────────────────────────────────

    if (showMean && stats.mean != null) {
      final meanPos = _mapValue(stats.mean!);
      final meanCenter = horizontal
          ? Offset(meanPos.clamp(chartRect.left, chartRect.right), center)
          : Offset(center, meanPos.clamp(chartRect.top, chartRect.bottom));

      canvas
        ..drawCircle(meanCenter, compact ? 3.0 : 4.0, Paint()..color = color)
        ..drawCircle(
          meanCenter,
          compact ? 3.0 : 4.0,
          Paint()
            ..color = gridColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
    }
  }

  /// Paints a notched box shape for confidence-interval visualisation.
  ///
  /// The notch is drawn as an indentation at [medianPos] on the sides of the
  /// box. The notch depth is 20 % of [hw].
  void _paintNotchedBox(
    Canvas canvas,
    Rect boxRect,
    double medianPos,
    double center,
    double hw,
    Paint fillPaint,
    Paint strokePaint,
  ) {
    final notchDepth = hw * 0.20;

    final Path path;
    if (horizontal) {
      final notchY = medianPos.clamp(chartRect.left, chartRect.right);
      path = Path()
        ..moveTo(boxRect.left, boxRect.top)
        ..lineTo(notchY, boxRect.top + notchDepth)
        ..lineTo(notchY, boxRect.bottom - notchDepth)
        ..lineTo(boxRect.left, boxRect.bottom)
        ..lineTo(boxRect.right, boxRect.bottom)
        ..lineTo(notchY, boxRect.bottom - notchDepth)
        ..lineTo(notchY, boxRect.top + notchDepth)
        ..lineTo(boxRect.right, boxRect.top)
        ..close();
    } else {
      final notchX = medianPos.clamp(chartRect.top, chartRect.bottom);
      path = Path()
        ..moveTo(boxRect.left, boxRect.top)
        ..lineTo(boxRect.right, boxRect.top)
        ..lineTo(boxRect.right, notchX - notchDepth)
        ..lineTo(boxRect.right + notchDepth, notchX)
        ..lineTo(boxRect.right, notchX + notchDepth)
        ..lineTo(boxRect.right, boxRect.bottom)
        ..lineTo(boxRect.left, boxRect.bottom)
        ..lineTo(boxRect.left, notchX + notchDepth)
        ..lineTo(boxRect.left - notchDepth, notchX)
        ..lineTo(boxRect.left, notchX - notchDepth)
        ..close();
    }

    canvas
      ..drawPath(path, fillPaint)
      ..drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(OiBoxPlotPainter oldDelegate) =>
      oldDelegate.boxes != boxes ||
      oldDelegate.categoryCount != categoryCount ||
      oldDelegate.chartRect != chartRect ||
      oldDelegate.minY != minY ||
      oldDelegate.maxY != maxY ||
      oldDelegate.showMean != showMean ||
      oldDelegate.showNotch != showNotch ||
      oldDelegate.horizontal != horizontal ||
      oldDelegate.showGrid != showGrid ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.highContrast != highContrast ||
      oldDelegate.compact != compact;
}
