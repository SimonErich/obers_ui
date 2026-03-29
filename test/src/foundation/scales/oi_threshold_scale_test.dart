// Tests do not require documentation comments.

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_scale.dart';
import 'package:obers_ui/src/foundation/scales/oi_threshold_scale.dart';

void main() {
  group('OiThresholdScale', () {
    test('type is threshold', () {
      const scale = OiThresholdScale(
        thresholds: [10, 20, 30],
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(scale.type, OiScaleType.threshold);
    });

    test('segmentCount is thresholds + 1', () {
      const scale = OiThresholdScale(
        thresholds: [10, 20, 30],
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(scale.segmentCount, 4);
    });

    test('toPixel maps values to segment centers', () {
      const scale = OiThresholdScale(
        thresholds: [10, 20, 30],
        rangeMin: 0,
        rangeMax: 400,
      );
      // 4 segments, bandwidth = 100
      // Centers at 50, 150, 250, 350
      expect(scale.toPixel(5), closeTo(50, 0.01)); // < 10 → bin 0
      expect(scale.toPixel(15), closeTo(150, 0.01)); // 10-20 → bin 1
      expect(scale.toPixel(25), closeTo(250, 0.01)); // 20-30 → bin 2
      expect(scale.toPixel(35), closeTo(350, 0.01)); // ≥ 30 → bin 3
    });

    test('toPixel at exact threshold goes to higher bin', () {
      const scale = OiThresholdScale(
        thresholds: [10, 20, 30],
        rangeMin: 0,
        rangeMax: 400,
      );
      // Value exactly at threshold goes to the bin above.
      expect(scale.toPixel(10), closeTo(150, 0.01)); // bin 1
      expect(scale.toPixel(20), closeTo(250, 0.01)); // bin 2
    });

    test('fromPixel returns representative value', () {
      const scale = OiThresholdScale(
        thresholds: [10, 20, 30],
        rangeMin: 0,
        rangeMax: 400,
      );
      final val = scale.fromPixel(150); // bin 1 → between 10 and 20
      expect(val, closeTo(15, 0.01));
    });

    test('buildTicks returns tick at each threshold', () {
      const scale = OiThresholdScale(
        thresholds: [10, 20, 30],
        rangeMin: 0,
        rangeMax: 400,
      );
      final ticks = scale.buildTicks();
      expect(ticks, hasLength(3));
      expect(ticks[0].value, 10);
      expect(ticks[1].value, 20);
      expect(ticks[2].value, 30);
    });

    test('empty thresholds creates single segment', () {
      const scale = OiThresholdScale(
        thresholds: [],
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(scale.segmentCount, 1);
      expect(scale.toPixel(50), closeTo(200, 0.01));
    });

    test('clamp restricts output', () {
      const scale = OiThresholdScale(
        thresholds: [10, 20, 30],
        rangeMin: 0,
        rangeMax: 400,
        clamp: true,
      );
      // All values should be within 0-400.
      expect(scale.toPixel(-1000), greaterThanOrEqualTo(0));
      expect(scale.toPixel(1000), lessThanOrEqualTo(400));
    });

    test('copyWith returns new instance', () {
      const scale = OiThresholdScale(
        thresholds: [10, 20, 30],
        rangeMin: 0,
        rangeMax: 400,
      );
      final copy = scale.copyWith(rangeMax: 800);
      expect(copy.rangeMax, 800);
      expect(copy.thresholds, [10, 20, 30]);
    });

    test('equality', () {
      const a = OiThresholdScale(
        thresholds: [10, 20, 30],
        rangeMin: 0,
        rangeMax: 400,
      );
      const b = OiThresholdScale(
        thresholds: [10, 20, 30],
        rangeMin: 0,
        rangeMax: 400,
      );
      const c = OiThresholdScale(
        thresholds: [5, 15, 25],
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, b.hashCode);
    });
  });
}
