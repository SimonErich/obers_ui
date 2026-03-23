import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

void main() {
  group('OiDataPoint', () {
    test('constructs with required parameters', () {
      const point = OiDataPoint(x: 1, y: 2);
      expect(point.x, 1);
      expect(point.y, 2);
      expect(point.label, isNull);
    });

    test('constructs with optional label', () {
      const point = OiDataPoint(x: 1, y: 2, label: 'test');
      expect(point.label, 'test');
    });

    test('equality compares all fields', () {
      const a = OiDataPoint(x: 1, y: 2, label: 'a');
      const b = OiDataPoint(x: 1, y: 2, label: 'a');
      const c = OiDataPoint(x: 1, y: 3, label: 'a');

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode is consistent with equality', () {
      const a = OiDataPoint(x: 1, y: 2);
      const b = OiDataPoint(x: 1, y: 2);

      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString provides readable output', () {
      const point = OiDataPoint(x: 1, y: 2, label: 'test');
      expect(point.toString(), contains('1'));
      expect(point.toString(), contains('2'));
      expect(point.toString(), contains('test'));
    });
  });

  group('OiChartSeries', () {
    test('isValid returns true when data points exist', () {
      const series = OiChartSeries(
        name: 'Test',
        dataPoints: [OiDataPoint(x: 0, y: 1)],
      );
      expect(series.isValid, isTrue);
    });

    test('isValid returns false for empty data points', () {
      const series = OiChartSeries(name: 'Empty', dataPoints: []);
      expect(series.isValid, isFalse);
    });

    test('stores optional color', () {
      const series = OiChartSeries(
        name: 'Colored',
        dataPoints: [],
        color: Color(0xFFFF0000),
      );
      expect(series.color, const Color(0xFFFF0000));
    });

    test('equality compares name, points, and color', () {
      const a = OiChartSeries(name: 'A', dataPoints: [OiDataPoint(x: 1, y: 2)]);
      const b = OiChartSeries(name: 'A', dataPoints: [OiDataPoint(x: 1, y: 2)]);
      const c = OiChartSeries(name: 'B', dataPoints: [OiDataPoint(x: 1, y: 2)]);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('equality handles different length data points', () {
      const a = OiChartSeries(name: 'A', dataPoints: [OiDataPoint(x: 1, y: 2)]);
      const b = OiChartSeries(
        name: 'A',
        dataPoints: [OiDataPoint(x: 1, y: 2), OiDataPoint(x: 3, y: 4)],
      );

      expect(a, isNot(equals(b)));
    });
  });

  group('OiChartBounds', () {
    test('computes xRange and yRange', () {
      const bounds = OiChartBounds(minX: 0, maxX: 10, minY: -5, maxY: 5);
      expect(bounds.xRange, 10);
      expect(bounds.yRange, 10);
    });

    test('xRange returns 1 when min equals max', () {
      const bounds = OiChartBounds(minX: 5, maxX: 5, minY: 0, maxY: 10);
      expect(bounds.xRange, 1);
    });

    test('yRange returns 1 when min equals max', () {
      const bounds = OiChartBounds(minX: 0, maxX: 10, minY: 5, maxY: 5);
      expect(bounds.yRange, 1);
    });

    test('empty bounds provides default range', () {
      const bounds = OiChartBounds.empty;
      expect(bounds.minX, 0);
      expect(bounds.maxX, 1);
      expect(bounds.xRange, 1);
      expect(bounds.yRange, 1);
    });

    test('equality and hashCode', () {
      const a = OiChartBounds.empty;
      const b = OiChartBounds.empty;

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString provides readable output', () {
      const bounds = OiChartBounds(minX: 0, maxX: 10, minY: -5, maxY: 5);
      expect(bounds.toString(), contains('minX'));
    });
  });

  group('OiChartData', () {
    test('isEmpty is true for no series', () {
      expect(OiChartData.empty.isEmpty, isTrue);
    });

    test('isEmpty is true for series with no points', () {
      const data = OiChartData(
        series: [OiChartSeries(name: 'Empty', dataPoints: [])],
      );
      expect(data.isEmpty, isTrue);
    });

    test('isEmpty is false when data exists', () {
      const data = OiChartData(
        series: [
          OiChartSeries(name: 'A', dataPoints: [OiDataPoint(x: 0, y: 1)]),
        ],
      );
      expect(data.isEmpty, isFalse);
    });

    test('bounds returns empty bounds for empty data', () {
      expect(OiChartData.empty.bounds, OiChartBounds.empty);
    });

    test('bounds computes correct min/max across series', () {
      const data = OiChartData(
        series: [
          OiChartSeries(
            name: 'A',
            dataPoints: [OiDataPoint(x: 0, y: 5), OiDataPoint(x: 10, y: 15)],
          ),
          OiChartSeries(
            name: 'B',
            dataPoints: [OiDataPoint(x: -2, y: 3), OiDataPoint(x: 8, y: 20)],
          ),
        ],
      );

      final bounds = data.bounds;
      expect(bounds.minX, -2);
      expect(bounds.maxX, 10);
      expect(bounds.minY, 3);
      expect(bounds.maxY, 20);
    });

    test('bounds handles single data point', () {
      const data = OiChartData(
        series: [
          OiChartSeries(name: 'A', dataPoints: [OiDataPoint(x: 5, y: 10)]),
        ],
      );

      final bounds = data.bounds;
      // Single point: should expand by 0.5 in each direction.
      expect(bounds.minX, 4.5);
      expect(bounds.maxX, 5.5);
      expect(bounds.minY, 9.5);
      expect(bounds.maxY, 10.5);
    });

    test('bounds handles negative values', () {
      const data = OiChartData(
        series: [
          OiChartSeries(
            name: 'A',
            dataPoints: [
              OiDataPoint(x: -10, y: -20),
              OiDataPoint(x: -5, y: -1),
            ],
          ),
        ],
      );

      final bounds = data.bounds;
      expect(bounds.minX, -10);
      expect(bounds.maxX, -5);
      expect(bounds.minY, -20);
      expect(bounds.maxY, -1);
    });

    test('bounds handles all-zero values', () {
      const data = OiChartData(
        series: [
          OiChartSeries(
            name: 'A',
            dataPoints: [OiDataPoint(x: 0, y: 0), OiDataPoint(x: 0, y: 0)],
          ),
        ],
      );

      final bounds = data.bounds;
      expect(bounds.xRange, 1);
      expect(bounds.yRange, 1);
    });

    test('totalPoints sums across series', () {
      const data = OiChartData(
        series: [
          OiChartSeries(
            name: 'A',
            dataPoints: [OiDataPoint(x: 0, y: 1), OiDataPoint(x: 1, y: 2)],
          ),
          OiChartSeries(name: 'B', dataPoints: [OiDataPoint(x: 0, y: 3)]),
        ],
      );

      expect(data.totalPoints, 3);
    });
  });
}
