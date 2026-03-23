import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

/// Concrete test implementation of the abstract OiChartPainter.
class _TestChartPainter extends OiChartPainter {
  _TestChartPainter({required super.data, required super.theme, super.padding});

  bool paintCalled = false;

  @override
  void paint(Canvas canvas, Size size) {
    paintCalled = true;
  }
}

void main() {
  late OiChartTheme theme;

  setUp(() {
    theme = OiChartTheme.light();
  });

  group('OiChartPainter.mapDataToPixel', () {
    test('maps origin point to bottom-left of chart area', () {
      const data = OiChartData(
        series: [
          OiChartSeries(
            name: 'A',
            dataPoints: [OiDataPoint(x: 0, y: 0), OiDataPoint(x: 10, y: 10)],
          ),
        ],
      );

      final painter = _TestChartPainter(data: data, theme: theme);
      const size = Size(400, 300);
      final bounds = data.bounds;

      final pixel = painter.mapDataToPixel(
        const OiDataPoint(x: 0, y: 0),
        size,
        bounds,
      );

      final area = painter.chartArea(size);
      expect(pixel.dx, closeTo(area.left, 0.01));
      expect(pixel.dy, closeTo(area.bottom, 0.01));
    });

    test('maps max point to top-right of chart area', () {
      const data = OiChartData(
        series: [
          OiChartSeries(
            name: 'A',
            dataPoints: [OiDataPoint(x: 0, y: 0), OiDataPoint(x: 10, y: 10)],
          ),
        ],
      );

      final painter = _TestChartPainter(data: data, theme: theme);
      const size = Size(400, 300);
      final bounds = data.bounds;

      final pixel = painter.mapDataToPixel(
        const OiDataPoint(x: 10, y: 10),
        size,
        bounds,
      );

      final area = painter.chartArea(size);
      expect(pixel.dx, closeTo(area.right, 0.01));
      expect(pixel.dy, closeTo(area.top, 0.01));
    });

    test('maps midpoint correctly', () {
      const data = OiChartData(
        series: [
          OiChartSeries(
            name: 'A',
            dataPoints: [OiDataPoint(x: 0, y: 0), OiDataPoint(x: 10, y: 10)],
          ),
        ],
      );

      final painter = _TestChartPainter(data: data, theme: theme);
      const size = Size(400, 300);
      final bounds = data.bounds;

      final pixel = painter.mapDataToPixel(
        const OiDataPoint(x: 5, y: 5),
        size,
        bounds,
      );

      final area = painter.chartArea(size);
      expect(pixel.dx, closeTo(area.left + area.width / 2, 0.01));
      expect(pixel.dy, closeTo(area.top + area.height / 2, 0.01));
    });

    test('handles negative bounds correctly', () {
      const data = OiChartData(
        series: [
          OiChartSeries(
            name: 'A',
            dataPoints: [
              OiDataPoint(x: -10, y: -10),
              OiDataPoint(x: 10, y: 10),
            ],
          ),
        ],
      );

      final painter = _TestChartPainter(data: data, theme: theme);
      const size = Size(400, 300);
      final bounds = data.bounds;

      // Origin (0,0) should map to center.
      final pixel = painter.mapDataToPixel(
        const OiDataPoint(x: 0, y: 0),
        size,
        bounds,
      );

      final area = painter.chartArea(size);
      expect(pixel.dx, closeTo(area.left + area.width / 2, 0.01));
      expect(pixel.dy, closeTo(area.top + area.height / 2, 0.01));
    });
  });

  group('OiChartPainter.chartArea', () {
    test('respects default padding', () {
      final painter = _TestChartPainter(data: OiChartData.empty, theme: theme);

      const size = Size(400, 300);
      final area = painter.chartArea(size);

      expect(area.left, 48);
      expect(area.top, 16);
      expect(area.right, 384); // 400 - 16
      expect(area.bottom, 268); // 300 - 32
    });

    test('respects custom padding', () {
      final painter = _TestChartPainter(
        data: OiChartData.empty,
        theme: theme,
        padding: const OiChartPadding(left: 10, top: 10, right: 10, bottom: 10),
      );

      const size = Size(200, 200);
      final area = painter.chartArea(size);

      expect(area.left, 10);
      expect(area.top, 10);
      expect(area.right, 190);
      expect(area.bottom, 190);
    });
  });

  group('OiChartPainter.shouldRepaint', () {
    test('returns true when data changes', () {
      final painter1 = _TestChartPainter(data: OiChartData.empty, theme: theme);
      final painter2 = _TestChartPainter(
        data: const OiChartData(
          series: [
            OiChartSeries(name: 'A', dataPoints: [OiDataPoint(x: 0, y: 1)]),
          ],
        ),
        theme: theme,
      );

      expect(painter2.shouldRepaint(painter1), isTrue);
    });

    test('returns false when data and theme are same', () {
      final painter1 = _TestChartPainter(data: OiChartData.empty, theme: theme);
      final painter2 = _TestChartPainter(data: OiChartData.empty, theme: theme);

      expect(painter2.shouldRepaint(painter1), isFalse);
    });
  });

  group('OiChartPainter grid lines', () {
    test('has correct default grid line counts', () {
      final painter = _TestChartPainter(data: OiChartData.empty, theme: theme);

      expect(painter.horizontalGridLines, 5);
      expect(painter.verticalGridLines, 5);
    });
  });
}
