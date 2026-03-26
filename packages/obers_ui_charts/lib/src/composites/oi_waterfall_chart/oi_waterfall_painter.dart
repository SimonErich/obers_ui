import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:obers_ui_charts/src/composites/_chart_grid_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_waterfall_chart/oi_waterfall_data.dart';

/// Custom painter for waterfall charts.
///
/// Draws floating bars that start where the previous bar ended, uses
/// [positiveColor] for incremental gains, [negativeColor] for losses, and
/// [totalColor] for summary bars. Optionally draws connector lines between
/// consecutive bar tops.
class OiWaterfallPainter extends CustomPainter {
  /// Creates an [OiWaterfallPainter].
  OiWaterfallPainter({
    required this.bars,
    required this.chartRect,
    required this.minY,
    required this.maxY,
    required this.positiveColor,
    required this.negativeColor,
    required this.totalColor,
    required this.showConnectors,
    required this.showGrid,
    required this.gridColor,
    required this.axisLabelColor,
    required this.highContrast,
    required this.compact,
    required this.xLabels,
    required this.yLabels,
    required this.yDivisions,
  });

  /// The pre-computed waterfall bars.
  final List<OiWaterfallBar> bars;

  /// The chart drawing area.
  final Rect chartRect;

  /// Minimum y value (possibly negative for charts with losses).
  final double minY;

  /// Maximum y value.
  final double maxY;

  /// Color for positive incremental bars.
  final Color positiveColor;

  /// Color for negative incremental bars.
  final Color negativeColor;

  /// Color for total/summary bars.
  final Color totalColor;

  /// Whether to draw connector lines between bar tops.
  final bool showConnectors;

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

  /// X-axis category labels.
  final List<String> xLabels;

  /// Y-axis tick labels.
  final List<String> yLabels;

  /// Number of y-axis divisions.
  final int yDivisions;

  double get _rangeY {
    final r = maxY - minY;
    return r == 0 ? 1.0 : r;
  }

  /// Maps a y data value to a canvas y-coordinate.
  double _mapY(double v) =>
      chartRect.bottom - chartRect.height * (v - minY) / _rangeY;

  /// Returns the center x-coordinate for a bar at [index].
  double _barCenterX(int index) {
    if (bars.isEmpty) return chartRect.left;
    return chartRect.left + chartRect.width * (index + 0.5) / bars.length;
  }

  /// Returns the half-width of a bar.
  double get _barHalfWidth {
    if (bars.isEmpty) return 0;
    final slot = chartRect.width / bars.length;
    // Bars occupy 80 % of the slot (10 % gap each side).
    return slot * 0.4;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (showGrid) {
      OiChartGrid.paintGrid(
        canvas,
        chartRect,
        gridColor: gridColor,
        highContrast: highContrast,
        horizontalDivisions: yDivisions,
        verticalDivisions: 0,
      );
    }

    OiChartGrid.paintAxes(
      canvas,
      chartRect,
      axisColor: gridColor,
      highContrast: highContrast,
    );

    // Draw zero-line when the range includes negative values.
    if (minY < 0) {
      final zeroY = _mapY(0);
      canvas.drawLine(
        Offset(chartRect.left, zeroY),
        Offset(chartRect.right, zeroY),
        Paint()
          ..color = gridColor
          ..strokeWidth = highContrast ? 2.0 : 1.0,
      );
    }

    OiChartGrid.paintYLabels(
      canvas,
      chartRect,
      labels: yLabels,
      labelColor: axisLabelColor,
    );

    OiChartGrid.paintXLabels(
      canvas,
      chartRect,
      labels: xLabels,
      labelColor: axisLabelColor,
    );

    // Draw connectors first so bars render on top.
    if (showConnectors && bars.length > 1) {
      _paintConnectors(canvas);
    }

    // Draw bars.
    for (var i = 0; i < bars.length; i++) {
      _paintBar(canvas, i, bars[i]);
    }
  }

  void _paintBar(Canvas canvas, int index, OiWaterfallBar bar) {
    final cx = _barCenterX(index);
    final hw = _barHalfWidth;

    final y1 = _mapY(bar.barStart);
    final y2 = _mapY(bar.barEnd);
    final top = math.min(y1, y2);
    final bottom = math.max(y1, y2);

    final color = bar.isTotal
        ? totalColor
        : bar.isPositive
        ? positiveColor
        : negativeColor;

    final rect = Rect.fromLTRB(
      math.max(cx - hw, chartRect.left),
      math.max(top, chartRect.top),
      math.min(cx + hw, chartRect.right),
      math.min(bottom, chartRect.bottom),
    );

    canvas
      ..drawRect(
        rect,
        Paint()
          ..color = color.withValues(alpha: highContrast ? 1.0 : 0.85)
          ..style = PaintingStyle.fill,
      )
      ..drawRect(
        rect,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = highContrast ? 2.0 : 1.0,
      );
  }

  void _paintConnectors(Canvas canvas) {
    final connectorPaint = Paint()
      ..color = gridColor
      ..strokeWidth = highContrast ? 1.5 : 1.0
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < bars.length - 1; i++) {
      final current = bars[i];
      final next = bars[i + 1];

      // Connect the "end" of the current bar to the "start" of the next bar.
      // For positive incremental bars the end is the top; for negative it is
      // the bottom. Total bars connect from their top.
      final connectFromY = current.isTotal
          ? _mapY(current.barEnd)
          : current.isPositive
          ? _mapY(current.barEnd)
          : _mapY(current.barEnd);

      final connectToY = next.isTotal ? _mapY(0) : _mapY(next.barStart);

      final x1 = _barCenterX(i) + _barHalfWidth;
      final x2 = _barCenterX(i + 1) - _barHalfWidth;

      canvas.drawLine(
        Offset(x1, connectFromY),
        Offset(x2, connectToY),
        connectorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(OiWaterfallPainter oldDelegate) =>
      oldDelegate.bars != bars ||
      oldDelegate.chartRect != chartRect ||
      oldDelegate.minY != minY ||
      oldDelegate.maxY != maxY ||
      oldDelegate.positiveColor != positiveColor ||
      oldDelegate.negativeColor != negativeColor ||
      oldDelegate.totalColor != totalColor ||
      oldDelegate.showConnectors != showConnectors ||
      oldDelegate.showGrid != showGrid ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.highContrast != highContrast ||
      oldDelegate.compact != compact;
}
