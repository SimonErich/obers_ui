// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/composites/oi_area_chart/oi_area_chart_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_candlestick_chart/oi_candlestick_chart_painter.dart';

// Each group builds a baseline painter from fresh lists and one variant per
// field the painter reads. An equal painter must not repaint; every variant
// must. A field that is read in paint() but missing from shouldRepaint makes
// its variant fail.

const _rect = Rect.fromLTWH(40, 20, 400, 300);
const _otherRect = Rect.fromLTWH(40, 20, 401, 300);
const _red = Color(0xFFFF0000);
const _green = Color(0xFF00FF00);
const _grey = Color(0xFF888888);

void _expectRepaints<T extends CustomPainter>(
  T Function() baseline,
  Map<String, T Function()> variants,
) {
  test('is false for equal input built from fresh lists', () {
    expect(baseline().shouldRepaint(baseline()), isFalse);
  });

  for (final entry in variants.entries) {
    test('is true when ${entry.key} changes', () {
      expect(entry.value().shouldRepaint(baseline()), isTrue);
    });
  }
}

// ── Area ──────────────────────────────────────────────────────────────────────

ResolvedAreaSeries _areaSeries({
  double lastX = 10,
  double lastY = 3,
  Color color = _red,
  double fillOpacity = 0.2,
  bool showLine = true,
  double strokeWidth = 2,
  String? stackGroup,
}) {
  return ResolvedAreaSeries(
    label: 'a',
    xValues: [0, lastX],
    yValues: [1, lastY],
    color: color,
    fillOpacity: fillOpacity,
    showLine: showLine,
    strokeWidth: strokeWidth,
    stackGroup: stackGroup,
  );
}

OiAreaChartPainter _area({
  List<ResolvedAreaSeries>? resolvedSeries,
  Rect chartRect = _rect,
  double minX = 0,
  double maxX = 10,
  double minY = 0,
  double maxY = 100,
  bool showGrid = true,
  Color gridColor = _grey,
  Color axisLabelColor = _grey,
  bool highContrast = false,
  bool showPoints = false,
  bool stacked = false,
  List<String>? xLabels,
  List<String>? yLabels,
  int xDivisions = 5,
  int yDivisions = 5,
  int? hoveredSeriesIndex,
  int? hoveredPointIndex,
}) {
  return OiAreaChartPainter(
    resolvedSeries: resolvedSeries ?? [_areaSeries()],
    chartRect: chartRect,
    minX: minX,
    maxX: maxX,
    minY: minY,
    maxY: maxY,
    showGrid: showGrid,
    gridColor: gridColor,
    axisLabelColor: axisLabelColor,
    highContrast: highContrast,
    compact: false,
    showPoints: showPoints,
    stacked: stacked,
    xLabels: xLabels ?? ['0', '10'],
    yLabels: yLabels ?? ['0', '100'],
    xDivisions: xDivisions,
    yDivisions: yDivisions,
    hoveredSeriesIndex: hoveredSeriesIndex,
    hoveredPointIndex: hoveredPointIndex,
  );
}

// ── Candlestick ───────────────────────────────────────────────────────────────

ResolvedCandlestickSeries _candleSeries({
  double x = 1,
  double open = 10,
  double high = 15,
  double low = 5,
  double close = 12,
  Color bullColor = _green,
  Color bearColor = _red,
}) {
  return ResolvedCandlestickSeries(
    label: 'a',
    candles: [
      ResolvedCandlestick(x: x, open: open, high: high, low: low, close: close),
    ],
    bullColor: bullColor,
    bearColor: bearColor,
  );
}

OiCandlestickChartPainter _candlestick({
  List<ResolvedCandlestickSeries>? resolvedSeries,
  Rect chartRect = _rect,
  double minX = 0,
  double maxX = 10,
  double minY = 0,
  double maxY = 100,
  bool showGrid = true,
  Color gridColor = _grey,
  Color axisLabelColor = _grey,
  bool highContrast = false,
  List<String>? xLabels,
  List<String>? yLabels,
  int xDivisions = 5,
  int yDivisions = 5,
  int? hoveredSeriesIndex,
  int? hoveredCandleIndex,
}) {
  return OiCandlestickChartPainter(
    resolvedSeries: resolvedSeries ?? [_candleSeries()],
    chartRect: chartRect,
    minX: minX,
    maxX: maxX,
    minY: minY,
    maxY: maxY,
    showGrid: showGrid,
    gridColor: gridColor,
    axisLabelColor: axisLabelColor,
    highContrast: highContrast,
    compact: false,
    xLabels: xLabels ?? ['0', '10'],
    yLabels: yLabels ?? ['0', '100'],
    xDivisions: xDivisions,
    yDivisions: yDivisions,
    hoveredSeriesIndex: hoveredSeriesIndex,
    hoveredCandleIndex: hoveredCandleIndex,
  );
}

// ── Bubble ────────────────────────────────────────────────────────────────────

ResolvedBubble _bubble({
  double x = 0.5,
  double y = 0.5,
  double radius = 10,
  Color color = _red,
  double opacity = 0.6,
  double borderWidth = 1,
  Color borderColor = _red,
}) {
  return ResolvedBubble(
    x: x,
    y: y,
    radius: radius,
    color: color,
    opacity: opacity,
    borderWidth: borderWidth,
    borderColor: borderColor,
    seriesIndex: 0,
    pointIndex: 0,
  );
}

OiBubbleChartPainter _bubbles({
  List<ResolvedBubble>? bubbles,
  Color gridColor = _grey,
  bool highContrast = false,
  bool compact = false,
  int? hoveredIndex,
}) {
  return OiBubbleChartPainter(
    bubbles: bubbles ?? [_bubble()],
    gridColor: gridColor,
    axisLabelColor: _grey,
    textColor: _grey,
    highContrast: highContrast,
    compact: compact,
    hoveredIndex: hoveredIndex,
  );
}

void main() {
  group('OiAreaChartPainter.shouldRepaint', () {
    _expectRepaints(_area, {
      'chartRect': () => _area(chartRect: _otherRect),
      'minX': () => _area(minX: 1),
      'maxX': () => _area(maxX: 11),
      'minY': () => _area(minY: 1),
      'maxY': () => _area(maxY: 101),
      'showGrid': () => _area(showGrid: false),
      'gridColor': () => _area(gridColor: _green),
      'axisLabelColor': () => _area(axisLabelColor: _green),
      'highContrast': () => _area(highContrast: true),
      'showPoints': () => _area(showPoints: true),
      'stacked': () => _area(stacked: true),
      'xLabels': () => _area(xLabels: ['0', '11']),
      'yLabels': () => _area(yLabels: ['0', '101']),
      'xDivisions': () => _area(xDivisions: 4),
      'yDivisions': () => _area(yDivisions: 4),
      'hoveredSeriesIndex': () => _area(hoveredSeriesIndex: 0),
      'hoveredPointIndex': () => _area(hoveredPointIndex: 0),
      'series count': () =>
          _area(resolvedSeries: [_areaSeries(), _areaSeries()]),
      'series x value': () => _area(resolvedSeries: [_areaSeries(lastX: 9)]),
      'series y value': () => _area(resolvedSeries: [_areaSeries(lastY: 4)]),
      'series color': () => _area(resolvedSeries: [_areaSeries(color: _green)]),
      'series fillOpacity': () =>
          _area(resolvedSeries: [_areaSeries(fillOpacity: 0.5)]),
      'series showLine': () =>
          _area(resolvedSeries: [_areaSeries(showLine: false)]),
      'series strokeWidth': () =>
          _area(resolvedSeries: [_areaSeries(strokeWidth: 3)]),
      'series stackGroup': () =>
          _area(resolvedSeries: [_areaSeries(stackGroup: 'g')]),
    });
  });

  group('OiCandlestickChartPainter.shouldRepaint', () {
    _expectRepaints(_candlestick, {
      'chartRect': () => _candlestick(chartRect: _otherRect),
      'minX': () => _candlestick(minX: 1),
      'maxX': () => _candlestick(maxX: 11),
      'minY': () => _candlestick(minY: 1),
      'maxY': () => _candlestick(maxY: 101),
      'showGrid': () => _candlestick(showGrid: false),
      'gridColor': () => _candlestick(gridColor: _green),
      'axisLabelColor': () => _candlestick(axisLabelColor: _green),
      'highContrast': () => _candlestick(highContrast: true),
      'xLabels': () => _candlestick(xLabels: ['0', '11']),
      'yLabels': () => _candlestick(yLabels: ['0', '101']),
      'xDivisions': () => _candlestick(xDivisions: 4),
      'yDivisions': () => _candlestick(yDivisions: 4),
      'hoveredSeriesIndex': () => _candlestick(hoveredSeriesIndex: 0),
      'hoveredCandleIndex': () => _candlestick(hoveredCandleIndex: 0),
      'series count': () =>
          _candlestick(resolvedSeries: [_candleSeries(), _candleSeries()]),
      'candle x': () => _candlestick(resolvedSeries: [_candleSeries(x: 2)]),
      'candle open': () =>
          _candlestick(resolvedSeries: [_candleSeries(open: 11)]),
      'candle high': () =>
          _candlestick(resolvedSeries: [_candleSeries(high: 16)]),
      'candle low': () => _candlestick(resolvedSeries: [_candleSeries(low: 4)]),
      'candle close': () =>
          _candlestick(resolvedSeries: [_candleSeries(close: 13)]),
      'series bullColor': () =>
          _candlestick(resolvedSeries: [_candleSeries(bullColor: _grey)]),
      'series bearColor': () =>
          _candlestick(resolvedSeries: [_candleSeries(bearColor: _grey)]),
    });
  });

  group('OiBubbleChartPainter.shouldRepaint', () {
    _expectRepaints(_bubbles, {
      'gridColor': () => _bubbles(gridColor: _green),
      'highContrast': () => _bubbles(highContrast: true),
      'compact': () => _bubbles(compact: true),
      'hoveredIndex': () => _bubbles(hoveredIndex: 0),
      'bubble count': () => _bubbles(bubbles: [_bubble(), _bubble()]),
      'bubble x': () => _bubbles(bubbles: [_bubble(x: 0.6)]),
      'bubble y': () => _bubbles(bubbles: [_bubble(y: 0.6)]),
      'bubble radius': () => _bubbles(bubbles: [_bubble(radius: 11)]),
      'bubble color': () => _bubbles(bubbles: [_bubble(color: _green)]),
      'bubble opacity': () => _bubbles(bubbles: [_bubble(opacity: 0.7)]),
      'bubble borderWidth': () => _bubbles(bubbles: [_bubble(borderWidth: 2)]),
      'bubble borderColor': () =>
          _bubbles(bubbles: [_bubble(borderColor: _green)]),
    });
  });
}
