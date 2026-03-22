import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

void main() {
  group('OiChartHitResult', () {
    test('stores series index, point index, and data point', () {
      const result = OiChartHitResult(
        seriesIndex: 0,
        pointIndex: 1,
        dataPoint: OiDataPoint(x: 5, y: 10),
      );

      expect(result.seriesIndex, 0);
      expect(result.pointIndex, 1);
      expect(result.dataPoint.x, 5);
    });

    test('equality compares all fields', () {
      const a = OiChartHitResult(
        seriesIndex: 0,
        pointIndex: 1,
        dataPoint: OiDataPoint(x: 5, y: 10),
      );
      const b = OiChartHitResult(
        seriesIndex: 0,
        pointIndex: 1,
        dataPoint: OiDataPoint(x: 5, y: 10),
      );
      const c = OiChartHitResult(
        seriesIndex: 1,
        pointIndex: 1,
        dataPoint: OiDataPoint(x: 5, y: 10),
      );

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode is consistent', () {
      const a = OiChartHitResult(
        seriesIndex: 0,
        pointIndex: 0,
        dataPoint: OiDataPoint(x: 0, y: 0),
      );
      const b = OiChartHitResult(
        seriesIndex: 0,
        pointIndex: 0,
        dataPoint: OiDataPoint(x: 0, y: 0),
      );

      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString provides readable output', () {
      const result = OiChartHitResult(
        seriesIndex: 0,
        pointIndex: 1,
        dataPoint: OiDataPoint(x: 5, y: 10),
      );

      expect(result.toString(), contains('series: 0'));
      expect(result.toString(), contains('point: 1'));
    });
  });

  group('OiChartGestureHandler', () {
    late OiChartData data;
    late OiChartBounds bounds;

    setUp(() {
      data = const OiChartData(
        series: [
          OiChartSeries(
            name: 'Test',
            dataPoints: [
              OiDataPoint(x: 0, y: 0),
              OiDataPoint(x: 5, y: 5),
              OiDataPoint(x: 10, y: 10),
            ],
          ),
        ],
      );
      bounds = data.bounds;
    });

    test('hitTest returns null for empty data', () {
      final handler = OiChartGestureHandler(
        data: OiChartData.empty,
        bounds: OiChartBounds.empty,
      );

      final result = handler.hitTest(
        const Offset(100, 100),
        const Size(400, 300),
      );
      expect(result, isNull);
    });

    test('hitTest finds nearest point within tolerance', () {
      final handler = OiChartGestureHandler(
        data: data,
        bounds: bounds,
        hitTolerance: 50,
      );

      // The first data point (0, 0) maps to bottom-left of chart area.
      // Default padding: left=48, bottom=32.
      // So pixel position near (48, 268) should hit the first point.
      final result = handler.hitTest(
        const Offset(48, 268),
        const Size(400, 300),
      );

      expect(result, isNotNull);
      expect(result!.seriesIndex, 0);
      expect(result.pointIndex, 0);
    });

    test('hitTest returns null when tap is outside tolerance', () {
      final handler = OiChartGestureHandler(
        data: data,
        bounds: bounds,
        hitTolerance: 5,
      );

      // Tap far from any data point.
      final result = handler.hitTest(
        const Offset(200, 150),
        const Size(400, 300),
      );

      // Middle of chart maps to (5, 5) which is point index 1.
      // Depending on exact pixel math, this might or might not hit.
      // Use a position definitely far from all points.
      final result2 = handler.hitTest(const Offset(0, 0), const Size(400, 300));
      expect(result2, isNull);
    });

    test('hitTest finds the closest point among multiple', () {
      final handler = OiChartGestureHandler(
        data: data,
        bounds: bounds,
        hitTolerance: 200,
      );

      // Tap near the middle point (5, 5) at chart center.
      const area = Size(400, 300);
      // Middle point (5, 5) is at center of chart area.
      // Chart area: left=48, top=16, right=384, bottom=268
      // Center X: 48 + (384-48)/2 = 48 + 168 = 216
      // Center Y: 268 - (268-16)/2 = 268 - 126 = 142
      final result = handler.hitTest(const Offset(216, 142), area);

      expect(result, isNotNull);
      expect(result!.pointIndex, 1); // Middle point
    });

    test('hitTest works with multiple series', () {
      const multiData = OiChartData(
        series: [
          OiChartSeries(name: 'A', dataPoints: [OiDataPoint(x: 0, y: 0)]),
          OiChartSeries(name: 'B', dataPoints: [OiDataPoint(x: 10, y: 10)]),
        ],
      );
      final multiBounds = multiData.bounds;

      final handler = OiChartGestureHandler(
        data: multiData,
        bounds: multiBounds,
        hitTolerance: 50,
      );

      // Tap near top-right (series B, point at (10, 10)).
      final result = handler.hitTest(
        const Offset(384, 16),
        const Size(400, 300),
      );

      expect(result, isNotNull);
      expect(result!.seriesIndex, 1);
    });

    test('custom hitTolerance is respected', () {
      final handler = OiChartGestureHandler(
        data: data,
        bounds: bounds,
        hitTolerance: 1, // Very tight tolerance.
      );

      // Tap slightly offset from the first point.
      final result = handler.hitTest(
        const Offset(60, 260),
        const Size(400, 300),
      );

      expect(result, isNull);
    });
  });

  group('OiChartTooltipController', () {
    test('initially has null activeResult', () {
      final controller = OiChartTooltipController();
      expect(controller.activeResult.value, isNull);
      controller.dispose();
    });

    test('show sets activeResult', () {
      final controller = OiChartTooltipController();
      const result = OiChartHitResult(
        seriesIndex: 0,
        pointIndex: 0,
        dataPoint: OiDataPoint(x: 1, y: 2),
      );

      controller.show(result);
      expect(controller.activeResult.value, result);
      controller.dispose();
    });

    test('hide clears activeResult', () {
      final controller = OiChartTooltipController();
      const result = OiChartHitResult(
        seriesIndex: 0,
        pointIndex: 0,
        dataPoint: OiDataPoint(x: 1, y: 2),
      );

      controller.show(result);
      controller.hide();
      expect(controller.activeResult.value, isNull);
      controller.dispose();
    });

    test('activeResult notifies listeners', () {
      final controller = OiChartTooltipController();
      var notifyCount = 0;
      controller.activeResult.addListener(() => notifyCount++);

      const result = OiChartHitResult(
        seriesIndex: 0,
        pointIndex: 0,
        dataPoint: OiDataPoint(x: 1, y: 2),
      );

      controller.show(result);
      expect(notifyCount, 1);

      controller.hide();
      expect(notifyCount, 2);

      controller.dispose();
    });

    test('show replaces previous result', () {
      final controller = OiChartTooltipController();

      const result1 = OiChartHitResult(
        seriesIndex: 0,
        pointIndex: 0,
        dataPoint: OiDataPoint(x: 1, y: 2),
      );
      const result2 = OiChartHitResult(
        seriesIndex: 1,
        pointIndex: 1,
        dataPoint: OiDataPoint(x: 3, y: 4),
      );

      controller.show(result1);
      controller.show(result2);

      expect(controller.activeResult.value, result2);
      controller.dispose();
    });
  });
}
