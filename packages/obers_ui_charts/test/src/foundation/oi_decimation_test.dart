import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/foundation/oi_decimation.dart';

void main() {
  group('decimateMinMax', () {
    test('preserves global min and max and reduces count', () {
      // 100 points of a sine wave
      final points = List.generate(
        100,
        (i) => math.Point<double>(i.toDouble(), math.sin(i * 0.1) * 100),
      );

      final result = decimateMinMax(points, targetCount: 20);

      // Should reduce count
      expect(result.length, lessThanOrEqualTo(20));
      expect(result.length, greaterThan(1));

      // Should preserve global min and max y values
      final originalYs = points.map((p) => p.y);
      final resultYs = result.map((p) => p.y);

      final originalMin = originalYs.reduce(math.min);
      final originalMax = originalYs.reduce(math.max);
      final resultMin = resultYs.reduce(math.min);
      final resultMax = resultYs.reduce(math.max);

      expect(resultMin, closeTo(originalMin, 0.001));
      expect(resultMax, closeTo(originalMax, 0.001));
    });

    test('empty input returns empty', () {
      final result = decimateMinMax(<math.Point<double>>[], targetCount: 10);
      expect(result, isEmpty);
    });

    test('single point returns unchanged', () {
      final points = [const math.Point<double>(1, 2)];
      final result = decimateMinMax(points, targetCount: 10);
      expect(result, points);
    });

    test('fewer points than target returns all', () {
      final points = [
        const math.Point<double>(0, 0),
        const math.Point<double>(1, 1),
        const math.Point<double>(2, 2),
      ];
      final result = decimateMinMax(points, targetCount: 10);
      expect(result, points);
    });
  });

  group('decimateLttb', () {
    test('preserves visually significant points', () {
      // Create a signal with a clear spike
      final points = <math.Point<double>>[
        for (var i = 0; i < 50; i++) math.Point(i.toDouble(), 0),
        const math.Point(50, 100), // spike
        for (var i = 51; i < 100; i++) math.Point(i.toDouble(), 0),
      ];

      final result = decimateLttb(points, targetCount: 10);

      // Should reduce count
      expect(result.length, 10);

      // Should preserve the spike (the visually most significant point)
      final spikePresent = result.any((p) => p.y == 100);
      expect(spikePresent, isTrue);

      // First and last points should be preserved
      expect(result.first, points.first);
      expect(result.last, points.last);
    });

    test('fewer points than target returns all', () {
      final points = [
        const math.Point<double>(0, 0),
        const math.Point<double>(1, 1),
      ];
      final result = decimateLttb(points, targetCount: 10);
      expect(result, points);
    });

    test('empty input returns empty', () {
      final result = decimateLttb(<math.Point<double>>[], targetCount: 10);
      expect(result, isEmpty);
    });
  });

  group('selectDecimationStrategy', () {
    test('selects correct algorithm based on density ratio', () {
      expect(
        selectDecimationStrategy(pointCount: 10000, pixelWidth: 800),
        OiDecimationStrategy.lttb,
      );

      expect(
        selectDecimationStrategy(pointCount: 100, pixelWidth: 800),
        OiDecimationStrategy.none,
      );
    });
  });
}
