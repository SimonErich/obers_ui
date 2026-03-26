import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:obers_ui_charts/src/composites/_chart_grid_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_histogram/oi_histogram_data.dart';

/// A resolved histogram series ready for painting, with concrete colors and
/// pre-computed bins.
class ResolvedHistogramSeries {
  /// Creates a [ResolvedHistogramSeries].
  const ResolvedHistogramSeries({
    required this.label,
    required this.bins,
    required this.color,
  });

  /// Series label.
  final String label;

  /// Pre-computed histogram bins.
  final List<OiHistogramBin> bins;

  /// Resolved series color.
  final Color color;
}

/// Custom painter for histogram charts.
///
/// Draws filled rectangles for each bin (no gap between bars — histogram
/// convention) with optional grid lines, axis tick labels, and a cumulative
/// frequency line overlay.
class OiHistogramPainter extends CustomPainter {
  /// Creates an [OiHistogramPainter].
  OiHistogramPainter({
    required this.resolvedSeries,
    required this.chartRect,
    required this.dataMin,
    required this.dataMax,
    required this.maxBarValue,
    required this.showGrid,
    required this.gridColor,
    required this.axisLabelColor,
    required this.highContrast,
    required this.compact,
    required this.normalized,
    required this.cumulative,
    required this.xLabels,
    required this.yLabels,
    required this.xDivisions,
    required this.yDivisions,
  });

  /// The resolved series data.
  final List<ResolvedHistogramSeries> resolvedSeries;

  /// The chart drawing area.
  final Rect chartRect;

  /// Minimum data value across all series (left edge of x-axis).
  final double dataMin;

  /// Maximum data value across all series (right edge of x-axis).
  final double dataMax;

  /// Maximum bar height value (count or frequency) used for y-axis scaling.
  final double maxBarValue;

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

  /// When true, y-axis values represent relative frequencies (0–1) rather
  /// than raw counts.
  final bool normalized;

  /// When true, draws a cumulative frequency line overlay.
  final bool cumulative;

  /// X-axis tick labels.
  final List<String> xLabels;

  /// Y-axis tick labels.
  final List<String> yLabels;

  /// Number of x-axis divisions.
  final int xDivisions;

  /// Number of y-axis divisions.
  final int yDivisions;

  double get _rangeX {
    final r = dataMax - dataMin;
    return r == 0 ? 1.0 : r;
  }

  double get _rangeY => maxBarValue == 0 ? 1.0 : maxBarValue;

  double _mapX(double v) =>
      chartRect.left + chartRect.width * (v - dataMin) / _rangeX;

  double _mapY(double v) => chartRect.bottom - chartRect.height * v / _rangeY;

  @override
  void paint(Canvas canvas, Size size) {
    if (showGrid) {
      OiChartGrid.paintGrid(
        canvas,
        chartRect,
        gridColor: gridColor,
        highContrast: highContrast,
        horizontalDivisions: yDivisions,
        verticalDivisions: xDivisions,
      );
    }

    OiChartGrid.paintAxes(
      canvas,
      chartRect,
      axisColor: gridColor,
      highContrast: highContrast,
    );

    OiChartGrid.paintXLabels(
      canvas,
      chartRect,
      labels: xLabels,
      labelColor: axisLabelColor,
    );
    OiChartGrid.paintYLabels(
      canvas,
      chartRect,
      labels: yLabels,
      labelColor: axisLabelColor,
    );

    for (final series in resolvedSeries) {
      if (series.bins.isEmpty) continue;

      _paintBars(canvas, series);

      if (cumulative) {
        _paintCumulativeLine(canvas, series);
      }
    }
  }

  void _paintBars(Canvas canvas, ResolvedHistogramSeries series) {
    final barPaint = Paint()
      ..color = series.color.withValues(alpha: highContrast ? 1.0 : 0.75)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = series.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = highContrast ? 2.0 : 1.0;

    for (final bin in series.bins) {
      final barValue = normalized ? bin.frequency : bin.count.toDouble();

      final left = _mapX(bin.start);
      final right = _mapX(bin.end);
      final top = _mapY(barValue);
      final bottom = chartRect.bottom;

      if (top >= bottom) continue;

      final rect = Rect.fromLTRB(
        math.max(left, chartRect.left),
        top,
        math.min(right, chartRect.right),
        bottom,
      );

      canvas
        ..drawRect(rect, barPaint)
        ..drawRect(rect, strokePaint);
    }
  }

  void _paintCumulativeLine(Canvas canvas, ResolvedHistogramSeries series) {
    if (series.bins.isEmpty) return;

    // Compute cumulative totals.
    final total = normalized
        ? 1.0
        : series.bins.fold<double>(0, (s, b) => s + b.count);

    if (total == 0) return;

    var cumulative = 0.0;
    final points = <Offset>[];

    for (final bin in series.bins) {
      final binValue = normalized ? bin.frequency : bin.count.toDouble();
      cumulative += binValue;

      final x = _mapX(bin.end);
      final fraction = cumulative / total;
      // The cumulative line is always drawn relative to the full scale height.
      final y = chartRect.bottom - chartRect.height * fraction;
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    // Starting point at the left edge of the first bin at y=0.
    final startX = _mapX(series.bins.first.start);
    final path = Path()..moveTo(startX, chartRect.bottom);
    for (final p in points) {
      path.lineTo(p.dx, p.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = series.color
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = highContrast ? 2.5 : 1.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots at each cumulative point.
    final dotPaint = Paint()..color = series.color;
    for (final p in points) {
      canvas.drawCircle(p, compact ? 2.0 : 3.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(OiHistogramPainter oldDelegate) =>
      oldDelegate.resolvedSeries != resolvedSeries ||
      oldDelegate.chartRect != chartRect ||
      oldDelegate.dataMin != dataMin ||
      oldDelegate.dataMax != dataMax ||
      oldDelegate.maxBarValue != maxBarValue ||
      oldDelegate.showGrid != showGrid ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.highContrast != highContrast ||
      oldDelegate.compact != compact ||
      oldDelegate.normalized != normalized ||
      oldDelegate.cumulative != cumulative;
}
