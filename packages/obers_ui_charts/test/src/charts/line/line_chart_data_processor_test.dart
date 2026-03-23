import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

void main() {
  const processor = OiLineChartDataProcessor();

  group('OiLineChartDataProcessor.interpolate', () {
    test('returns original points when fewer than 2', () {
      const points = [OiDataPoint(x: 0, y: 5)];
      final result = processor.interpolate(points, 10);
      expect(result, points);
    });

    test('returns original points when segments is 0', () {
      const points = [OiDataPoint(x: 0, y: 0), OiDataPoint(x: 10, y: 10)];
      final result = processor.interpolate(points, 0);
      expect(result, points);
    });

    test('returns correct number of interpolated points', () {
      const points = [OiDataPoint(x: 0, y: 0), OiDataPoint(x: 10, y: 10)];
      final result = processor.interpolate(points, 5);
      expect(result.length, 6); // segments + 1
    });

    test('interpolated first point matches original first', () {
      const points = [OiDataPoint(x: 0, y: 0), OiDataPoint(x: 10, y: 10)];
      final result = processor.interpolate(points, 5);
      expect(result.first.x, closeTo(0, 0.001));
      expect(result.first.y, closeTo(0, 0.001));
    });

    test('interpolated last point matches original last', () {
      const points = [OiDataPoint(x: 0, y: 0), OiDataPoint(x: 10, y: 10)];
      final result = processor.interpolate(points, 5);
      expect(result.last.x, closeTo(10, 0.001));
      expect(result.last.y, closeTo(10, 0.001));
    });

    test('linear interpolation produces evenly spaced values', () {
      const points = [OiDataPoint(x: 0, y: 0), OiDataPoint(x: 10, y: 10)];
      final result = processor.interpolate(points, 10);

      for (var i = 0; i < result.length; i++) {
        expect(result[i].x, closeTo(i.toDouble(), 0.001));
        expect(result[i].y, closeTo(i.toDouble(), 0.001));
      }
    });

    test('handles multiple segments in source data', () {
      const points = [
        OiDataPoint(x: 0, y: 0),
        OiDataPoint(x: 5, y: 10),
        OiDataPoint(x: 10, y: 5),
      ];
      final result = processor.interpolate(points, 10);
      expect(result.length, 11);

      // At x=5, y should be close to 10.
      final midPoint = result[5];
      expect(midPoint.x, closeTo(5, 0.001));
      expect(midPoint.y, closeTo(10, 0.001));
    });

    test('handles same-x data points gracefully', () {
      const points = [OiDataPoint(x: 5, y: 0), OiDataPoint(x: 5, y: 10)];
      final result = processor.interpolate(points, 3);
      // totalDistance is 0 → returns original points.
      expect(result, points);
    });
  });

  group('OiLineChartDataProcessor.computeControlPoints', () {
    test('returns empty for fewer than 2 points', () {
      const points = [OiDataPoint(x: 0, y: 5)];
      final result = processor.computeControlPoints(points);
      expect(result, isEmpty);
    });

    test('returns 2 control points per segment', () {
      const points = [
        OiDataPoint(x: 0, y: 0),
        OiDataPoint(x: 5, y: 10),
        OiDataPoint(x: 10, y: 5),
      ];

      final result = processor.computeControlPoints(points);
      // 2 segments → 4 control points.
      expect(result.length, 4);
    });

    test('control points are finite offsets', () {
      const points = [
        OiDataPoint(x: 0, y: 0),
        OiDataPoint(x: 1, y: 1),
        OiDataPoint(x: 2, y: 4),
        OiDataPoint(x: 3, y: 9),
      ];

      final result = processor.computeControlPoints(points);

      for (final cp in result) {
        expect(cp.dx.isFinite, isTrue);
        expect(cp.dy.isFinite, isTrue);
      }
    });

    test('two-point case produces exactly 2 control points', () {
      const points = [OiDataPoint(x: 0, y: 0), OiDataPoint(x: 10, y: 10)];

      final result = processor.computeControlPoints(points);
      expect(result.length, 2);
    });

    test('control points lie between data points', () {
      const points = [OiDataPoint(x: 0, y: 0), OiDataPoint(x: 10, y: 10)];

      final result = processor.computeControlPoints(points);
      final cp1 = result[0];
      final cp2 = result[1];

      // Control points should be within the x-range of the segment.
      expect(cp1.dx, greaterThanOrEqualTo(0));
      expect(cp1.dx, lessThanOrEqualTo(10));
      expect(cp2.dx, greaterThanOrEqualTo(0));
      expect(cp2.dx, lessThanOrEqualTo(10));
    });
  });
}
