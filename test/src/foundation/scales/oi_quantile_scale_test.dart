// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_scale.dart';
import 'package:obers_ui_charts/src/foundation/oi_quantile_scale.dart';

void main() {
  group('OiQuantileScale', () {
    test('type is quantile', () {
      final scale = OiQuantileScale(
        values: const [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(scale.type, OiScaleType.quantile);
    });

    test('sortedValues returns sorted copy', () {
      final scale = OiQuantileScale(
        values: const [5, 3, 8, 1, 9],
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(scale.sortedValues, [1, 3, 5, 8, 9]);
    });

    test('thresholds divides domain into quantiles', () {
      final scale = OiQuantileScale(
        values: const [1, 2, 3, 4, 5, 6, 7, 8],
        rangeMin: 0,
        rangeMax: 400,
      );
      final t = scale.thresholds;
      expect(t, hasLength(3)); // 4 bins → 3 thresholds
      // Thresholds should be ascending.
      for (var i = 1; i < t.length; i++) {
        expect(t[i], greaterThanOrEqualTo(t[i - 1]));
      }
    });

    test('toPixel maps to bin centers', () {
      final scale = OiQuantileScale(
        values: const [1, 2, 3, 4, 5, 6, 7, 8],
        rangeMin: 0,
        rangeMax: 400,
      );
      // band width = 400/4 = 100
      // Bin 0 center = 50, Bin 1 center = 150, etc.
      final p1 = scale.toPixel(1);
      final p8 = scale.toPixel(8);
      expect(p1, closeTo(50, 0.01)); // First bin center
      expect(p8, closeTo(350, 0.01)); // Last bin center
    });

    test('fromPixel returns representative value', () {
      final scale = OiQuantileScale(
        values: const [1, 2, 3, 4, 5, 6, 7, 8],
        rangeMin: 0,
        rangeMax: 400,
      );
      final val = scale.fromPixel(50);
      expect(val, isNotNull);
      expect(val, greaterThanOrEqualTo(1));
      expect(val, lessThanOrEqualTo(8));
    });

    test('buildTicks includes boundaries', () {
      final scale = OiQuantileScale(
        values: const [1, 2, 3, 4, 5, 6, 7, 8],
        rangeMin: 0,
        rangeMax: 400,
      );
      final ticks = scale.buildTicks();
      expect(ticks, isNotEmpty);
      expect(ticks.first.value, 1);
      expect(ticks.last.value, 8);
    });

    test('empty values returns empty thresholds', () {
      final scale = OiQuantileScale(
        values: const [],
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(scale.thresholds, isEmpty);
    });

    test('equality', () {
      final a = OiQuantileScale(
        values: const [1, 2, 3],
        rangeMin: 0,
        rangeMax: 400,
      );
      final b = OiQuantileScale(
        values: const [1, 2, 3],
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('copyWith returns new instance', () {
      final scale = OiQuantileScale(
        values: const [1, 2, 3, 4],
        rangeMin: 0,
        rangeMax: 400,
      );
      final copy = scale.copyWith(rangeMax: 800);
      expect(copy.rangeMax, 800);
      expect(copy.sortedValues, [1, 2, 3, 4]);
      expect(copy.quantileCount, 4);
    });

    test('clamp restricts output', () {
      final scale = OiQuantileScale(
        values: const [1, 2, 3, 4, 5, 6, 7, 8],
        rangeMin: 100,
        rangeMax: 300,
        clamp: true,
      );
      expect(scale.toPixel(1), greaterThanOrEqualTo(100));
      expect(scale.toPixel(8), lessThanOrEqualTo(300));
    });

    test('different values are not equal', () {
      final a = OiQuantileScale(
        values: const [1, 2, 3],
        rangeMin: 0,
        rangeMax: 400,
      );
      final b = OiQuantileScale(
        values: const [4, 5, 6],
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(a, isNot(equals(b)));
    });
  });
}
