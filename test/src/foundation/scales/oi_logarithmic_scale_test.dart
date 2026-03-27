// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_scale.dart';
import 'package:obers_ui_charts/src/foundation/oi_logarithmic_scale.dart';

void main() {
  group('OiLogarithmicScale', () {
    test('type is logarithmic', () {
      const scale = OiLogarithmicScale(
        domainMin: 1,
        domainMax: 1000,
        rangeMin: 0,
        rangeMax: 300,
      );
      expect(scale.type, OiScaleType.logarithmic);
    });

    test('toPixel maps powers of 10 evenly', () {
      const scale = OiLogarithmicScale(
        domainMin: 1,
        domainMax: 1000,
        rangeMin: 0,
        rangeMax: 300,
      );
      expect(scale.toPixel(1), closeTo(0, 0.01));
      expect(scale.toPixel(10), closeTo(100, 0.01));
      expect(scale.toPixel(100), closeTo(200, 0.01));
      expect(scale.toPixel(1000), closeTo(300, 0.01));
    });

    test('fromPixel is inverse of toPixel', () {
      const scale = OiLogarithmicScale(
        domainMin: 1,
        domainMax: 1000,
        rangeMin: 0,
        rangeMax: 300,
      );
      for (final v in [1.0, 10.0, 100.0, 1000.0]) {
        expect(scale.fromPixel(scale.toPixel(v)), closeTo(v, 0.01));
      }
    });

    test('handles non-positive value in toPixel', () {
      const scale = OiLogarithmicScale(
        domainMin: 1,
        domainMax: 1000,
        rangeMin: 0,
        rangeMax: 300,
      );
      expect(scale.toPixel(0), 0);
      expect(scale.toPixel(-5), 0);
    });

    test('clamp restricts output', () {
      const scale = OiLogarithmicScale(
        domainMin: 10,
        domainMax: 1000,
        rangeMin: 0,
        rangeMax: 200,
        clamp: true,
      );
      expect(scale.toPixel(1), 0);
      expect(scale.toPixel(10000), 200);
    });

    test('buildTicks generates ticks at powers of base', () {
      const scale = OiLogarithmicScale(
        domainMin: 1,
        domainMax: 10000,
        rangeMin: 0,
        rangeMax: 400,
      );
      final ticks = scale.buildTicks();
      final values = ticks.map((t) => t.value).toList();
      expect(values, contains(1));
      expect(values, contains(10));
      expect(values, contains(100));
      expect(values, contains(1000));
      expect(values, contains(10000));
    });

    test('fromData creates scale from values', () {
      final scale = OiLogarithmicScale.fromData(
        values: const [5, 50, 500],
        rangeMin: 0,
        rangeMax: 300,
      );
      expect(scale.domainMin, lessThanOrEqualTo(5));
      expect(scale.domainMax, greaterThanOrEqualTo(500));
    });

    test('fromData with empty values uses 1..10', () {
      final scale = OiLogarithmicScale.fromData(
        values: const [],
        rangeMin: 0,
        rangeMax: 300,
      );
      expect(scale.domainMin, 1);
      expect(scale.domainMax, 10);
    });

    test('custom base 2', () {
      const scale = OiLogarithmicScale(
        domainMin: 1,
        domainMax: 8,
        rangeMin: 0,
        rangeMax: 300,
        base: 2,
      );
      expect(scale.toPixel(1), closeTo(0, 0.01));
      expect(scale.toPixel(2), closeTo(100, 0.01));
      expect(scale.toPixel(4), closeTo(200, 0.01));
      expect(scale.toPixel(8), closeTo(300, 0.01));
    });

    test('copyWith returns new instance', () {
      const scale = OiLogarithmicScale(
        domainMin: 1,
        domainMax: 1000,
        rangeMin: 0,
        rangeMax: 300,
      );
      final copy = scale.copyWith(domainMax: 10000);
      expect(copy.domainMax, 10000);
      expect(copy.domainMin, 1);
    });

    test('equality', () {
      const a = OiLogarithmicScale(
        domainMin: 1,
        domainMax: 1000,
        rangeMin: 0,
        rangeMax: 300,
      );
      const b = OiLogarithmicScale(
        domainMin: 1,
        domainMax: 1000,
        rangeMin: 0,
        rangeMax: 300,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });
}
