import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

class _Point {
  const _Point(this.x, this.y);
  final double x;
  final double y;
}

void main() {
  group('normalizeSeries()', () {
    test('produces correct OiChartDatum count', () {
      final datums = normalizeSeries<_Point>(
        seriesId: 'test',
        data: const [_Point(1, 10), _Point(2, 20), _Point(3, 30)],
        xMapper: (p) => p.x,
        yMapper: (p) => p.y,
      );

      expect(datums.length, 3);
      expect(datums[0].seriesId, 'test');
      expect(datums[0].index, 0);
      expect(datums[0].xRaw, 1.0);
      expect(datums[0].yRaw, 10.0);
      expect(datums[2].xRaw, 3.0);
      expect(datums[2].yRaw, 30.0);
    });

    test('maps raw item correctly', () {
      const point = _Point(5, 50);
      final datums = normalizeSeries<_Point>(
        seriesId: 's1',
        data: const [point],
        xMapper: (p) => p.x,
        yMapper: (p) => p.y,
      );

      expect(datums[0].rawItem, point);
    });

    test('detects missing points via isMissing', () {
      final datums = normalizeSeries<_Point>(
        seriesId: 's1',
        data: const [_Point(1, 10), _Point(2, -1), _Point(3, 30)],
        xMapper: (p) => p.x,
        yMapper: (p) => p.y,
        isMissing: (p) => p.y < 0,
      );

      expect(datums[0].isMissing, isFalse);
      expect(datums[1].isMissing, isTrue);
      expect(datums[2].isMissing, isFalse);
    });

    test('includes point labels when provided', () {
      final datums = normalizeSeries<_Point>(
        seriesId: 's1',
        data: const [_Point(1, 100)],
        xMapper: (p) => p.x,
        yMapper: (p) => p.y,
        pointLabel: (p) => 'Value: ${p.y}',
      );

      expect(datums[0].label, 'Value: 100.0');
    });

    test('empty data produces empty list', () {
      final datums = normalizeSeries<_Point>(
        seriesId: 's1',
        data: const [],
        xMapper: (p) => p.x,
        yMapper: (p) => p.y,
      );

      expect(datums, isEmpty);
    });
  });

  group('Decimation functions', () {
    test('decimateMinMax reduces point count', () {
      final points = List.generate(
        1000,
        (i) => math.Point<double>(i.toDouble(), (i * 7 % 100).toDouble()),
      );

      final decimated = decimateMinMax(points, targetCount: 100);

      expect(decimated.length, lessThanOrEqualTo(100));
      expect(decimated.length, greaterThan(0));
    });

    test('decimateLttb preserves visual shape', () {
      final points = List.generate(
        500,
        (i) => math.Point<double>(i.toDouble(), (i * 3 % 50).toDouble()),
      );

      final decimated = decimateLttb(points, targetCount: 50);

      expect(decimated.length, 50);
      // First and last points should be preserved.
      expect(decimated.first, points.first);
      expect(decimated.last, points.last);
    });

    test('decimation is no-op when points below target', () {
      final points = [
        const math.Point<double>(1, 10),
        const math.Point<double>(2, 20),
      ];

      expect(decimateMinMax(points, targetCount: 100), points);
      expect(decimateLttb(points, targetCount: 100), points);
    });
  });
}
