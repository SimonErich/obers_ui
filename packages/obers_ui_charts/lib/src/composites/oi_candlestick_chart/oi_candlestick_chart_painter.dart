import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:obers_ui_charts/src/composites/_chart_grid_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_candlestick_chart/oi_candlestick_chart.dart'
    show OiCandlestickChart;

/// A resolved candlestick data point ready for painting.
class ResolvedCandlestick {
  /// Creates a [ResolvedCandlestick].
  const ResolvedCandlestick({
    required this.x,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  /// The x-axis value (numeric; typically a timestamp or index).
  final double x;

  /// Opening price.
  final double open;

  /// High price.
  final double high;

  /// Low price.
  final double low;

  /// Closing price.
  final double close;

  /// Whether this candle is bullish (close >= open).
  bool get isBull => close >= open;
}

/// A resolved candlestick series ready for painting.
class ResolvedCandlestickSeries {
  /// Creates a [ResolvedCandlestickSeries].
  const ResolvedCandlestickSeries({
    required this.label,
    required this.candles,
    required this.bullColor,
    required this.bearColor,
  });

  /// Series display name.
  final String label;

  /// The resolved candle data.
  final List<ResolvedCandlestick> candles;

  /// Color used for bullish candles.
  final Color bullColor;

  /// Color used for bearish candles.
  final Color bearColor;
}

/// Custom painter for [OiCandlestickChart].
///
/// For each candle it draws:
/// - A thin vertical wick line from [ResolvedCandlestick.low] to
///   [ResolvedCandlestick.high].
/// - A filled rectangle (body) from [ResolvedCandlestick.open] to
///   [ResolvedCandlestick.close].
/// - Bullish candles (close >= open) are filled with `bullColor`.
/// - Bearish candles (close < open) are filled with `bearColor`.
class OiCandlestickChartPainter extends CustomPainter {
  /// Creates an [OiCandlestickChartPainter].
  OiCandlestickChartPainter({
    required this.resolvedSeries,
    required this.chartRect,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.showGrid,
    required this.gridColor,
    required this.axisLabelColor,
    required this.highContrast,
    required this.compact,
    required this.xLabels,
    required this.yLabels,
    required this.xDivisions,
    required this.yDivisions,
    this.hoveredSeriesIndex,
    this.hoveredCandleIndex,
  });

  /// The resolved series list (typically one series for financial charts).
  final List<ResolvedCandlestickSeries> resolvedSeries;

  /// The chart drawing area in the canvas.
  final Rect chartRect;

  /// Minimum x value.
  final double minX;

  /// Maximum x value.
  final double maxX;

  /// Minimum y value (typically min(low) across all candles).
  final double minY;

  /// Maximum y value (typically max(high) across all candles).
  final double maxY;

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

  /// X-axis tick labels.
  final List<String> xLabels;

  /// Y-axis tick labels.
  final List<String> yLabels;

  /// Number of x-axis divisions.
  final int xDivisions;

  /// Number of y-axis divisions.
  final int yDivisions;

  /// Index of the hovered series, or `null`.
  final int? hoveredSeriesIndex;

  /// Index of the hovered candle, or `null`.
  final int? hoveredCandleIndex;

  double get _rangeX {
    final r = maxX - minX;
    return r == 0 ? 1.0 : r;
  }

  double get _rangeY {
    final r = maxY - minY;
    return r == 0 ? 1.0 : r;
  }

  double _mapX(double x) =>
      chartRect.left + chartRect.width * (x - minX) / _rangeX;

  double _mapY(double y) =>
      chartRect.bottom - chartRect.height * (y - minY) / _rangeY;

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

    for (var si = 0; si < resolvedSeries.length; si++) {
      final series = resolvedSeries[si];
      if (series.candles.isEmpty) continue;

      // Compute candle slot width. Use even spacing across the chart.
      final n = series.candles.length;
      final slotPx = n > 1 ? chartRect.width / n : chartRect.width;
      // Candle body takes up 60% of the slot width.
      final bodyW = math.max(slotPx * 0.6, 2).toDouble();
      // Wick is 1-2 px wide.
      final wickW = highContrast ? 2.0 : 1.0;

      for (var ci = 0; ci < n; ci++) {
        final candle = series.candles[ci];
        final cx = _mapX(candle.x);

        final highPy = _mapY(candle.high);
        final lowPy = _mapY(candle.low);
        final openPy = _mapY(candle.open);
        final closePy = _mapY(candle.close);

        final isBull = candle.isBull;
        final fillColor = isBull ? series.bullColor : series.bearColor;

        // Draw wick (thin vertical line from low to high).
        canvas.drawLine(
          Offset(cx, highPy),
          Offset(cx, lowPy),
          Paint()
            ..color = fillColor
            ..strokeWidth = wickW
            ..strokeCap = StrokeCap.butt,
        );

        // Draw body (rectangle from open to close).
        final bodyTop = math.min(openPy, closePy);
        final bodyBottom = math.max(openPy, closePy);
        // Ensure minimum visible height of 1px.
        final bodyHeight = math.max(bodyBottom - bodyTop, 1).toDouble();

        final bodyRect = Rect.fromLTWH(
          cx - bodyW / 2,
          bodyTop,
          bodyW,
          bodyHeight,
        );

        canvas.drawRect(bodyRect, Paint()..color = fillColor);

        // Hover: draw border highlight.
        if (hoveredSeriesIndex == si && hoveredCandleIndex == ci) {
          canvas.drawRect(
            bodyRect,
            Paint()
              ..color = fillColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = highContrast ? 3.0 : 2.0,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(OiCandlestickChartPainter oldDelegate) =>
      oldDelegate.resolvedSeries != resolvedSeries ||
      oldDelegate.showGrid != showGrid ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.highContrast != highContrast ||
      oldDelegate.compact != compact ||
      oldDelegate.hoveredSeriesIndex != hoveredSeriesIndex ||
      oldDelegate.hoveredCandleIndex != hoveredCandleIndex;
}
