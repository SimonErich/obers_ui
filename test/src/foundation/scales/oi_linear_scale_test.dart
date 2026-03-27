// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_scale.dart';
import 'package:obers_ui/src/foundation/scales/oi_linear_scale.dart';

void main() {
  group('OiLinearScale', () {
    test('type is linear', () {
      const scale = OiLinearScale(
        domainMin: 0,
        domainMax: 100,
        rangeMin: 0,
        rangeMax: 500,
      );
      expect(scale.type, OiScaleType.linear);
    });

    test('toPixel maps domain to range linearly', () {
      const scale = OiLinearScale(
        domainMin: 0,
        domainMax: 100,
        rangeMin: 0,
        rangeMax: 500,
      );
      expect(scale.toPixel(0), 0);
      expect(scale.toPixel(50), 250);
      expect(scale.toPixel(100), 500);
    });

    test('fromPixel maps range back to domain', () {
      const scale = OiLinearScale(
        domainMin: 0,
        domainMax: 100,
        rangeMin: 0,
        rangeMax: 500,
      );
      expect(scale.fromPixel(0), 0);
      expect(scale.fromPixel(250), 50);
      expect(scale.fromPixel(500), 100);
    });

    test('toPixel and fromPixel are inverse', () {
      const scale = OiLinearScale(
        domainMin: -10,
        domainMax: 30,
        rangeMin: 50,
        rangeMax: 450,
      );
      for (final v in [-10.0, 0.0, 10.0, 20.0, 30.0]) {
        expect(scale.fromPixel(scale.toPixel(v)), closeTo(v, 1e-10));
      }
    });

    test('clamp restricts output to range bounds', () {
      const scale = OiLinearScale(
        domainMin: 0,
        domainMax: 100,
        rangeMin: 0,
        rangeMax: 500,
        clamp: true,
      );
      expect(scale.toPixel(-50), 0);
      expect(scale.toPixel(200), 500);
    });

    test('without clamp allows values outside range', () {
      const scale = OiLinearScale(
        domainMin: 0,
        domainMax: 100,
        rangeMin: 0,
        rangeMax: 500,
      );
      expect(scale.toPixel(-50), -250);
      expect(scale.toPixel(200), 1000);
    });

    test('handles zero domain extent', () {
      const scale = OiLinearScale(
        domainMin: 50,
        domainMax: 50,
        rangeMin: 0,
        rangeMax: 500,
      );
      expect(scale.toPixel(50), 0);
    });

    test('buildTicks returns expected number of ticks', () {
      const scale = OiLinearScale(
        domainMin: 0,
        domainMax: 100,
        rangeMin: 0,
        rangeMax: 500,
      );
      final ticks = scale.buildTicks();
      expect(ticks, isNotEmpty);
      for (final tick in ticks) {
        expect(tick.value, greaterThanOrEqualTo(0));
        expect(tick.value, lessThanOrEqualTo(100));
      }
    });

    test('buildTicks with count=1 returns midpoint', () {
      const scale = OiLinearScale(
        domainMin: 0,
        domainMax: 100,
        rangeMin: 0,
        rangeMax: 500,
      );
      final ticks = scale.buildTicks(count: 1);
      expect(ticks, hasLength(1));
      expect(ticks.first.value, 50);
    });

    test('buildTicks with count=0 returns empty', () {
      const scale = OiLinearScale(
        domainMin: 0,
        domainMax: 100,
        rangeMin: 0,
        rangeMax: 500,
      );
      expect(scale.buildTicks(count: 0), isEmpty);
    });

    test('fromData creates scale from values', () {
      final scale = OiLinearScale.fromData(
        values: const [10, 20, 30, 40, 50],
        rangeMin: 0,
        rangeMax: 400,
        nice: false,
      );
      expect(scale.domainMin, 10);
      expect(scale.domainMax, 50);
    });

    test('fromData with nice rounds domain bounds', () {
      final scale = OiLinearScale.fromData(
        values: const [3, 7, 12, 18, 23],
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(scale.domainMin, lessThanOrEqualTo(3));
      expect(scale.domainMax, greaterThanOrEqualTo(23));
    });

    test('fromData with empty values uses 0..1', () {
      final scale = OiLinearScale.fromData(
        values: const [],
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(scale.domainMin, 0);
      expect(scale.domainMax, 1);
    });

    test('fromData with single value expands domain', () {
      final scale = OiLinearScale.fromData(
        values: const [5],
        rangeMin: 0,
        rangeMax: 400,
        nice: false,
      );
      expect(scale.domainMin, lessThan(5));
      expect(scale.domainMax, greaterThan(5));
    });

    test('copyWith returns new instance with overrides', () {
      const scale = OiLinearScale(
        domainMin: 0,
        domainMax: 100,
        rangeMin: 0,
        rangeMax: 500,
      );
      final copy = scale.copyWith(domainMax: 200);
      expect(copy.domainMax, 200);
      expect(copy.domainMin, 0);
      expect(copy.rangeMax, 500);
    });

    test('equality', () {
      const a = OiLinearScale(
        domainMin: 0,
        domainMax: 100,
        rangeMin: 0,
        rangeMax: 500,
      );
      const b = OiLinearScale(
        domainMin: 0,
        domainMax: 100,
        rangeMin: 0,
        rangeMax: 500,
      );
      const c = OiLinearScale(
        domainMin: 0,
        domainMax: 200,
        rangeMin: 0,
        rangeMax: 500,
      );
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, b.hashCode);
    });

    test('rangeExtent is computed correctly', () {
      const scale = OiLinearScale(
        domainMin: 0,
        domainMax: 100,
        rangeMin: 50,
        rangeMax: 450,
      );
      expect(scale.rangeExtent, 400);
    });

    test('inverted range works', () {
      const scale = OiLinearScale(
        domainMin: 0,
        domainMax: 100,
        rangeMin: 500,
        rangeMax: 0,
      );
      expect(scale.toPixel(0), 500);
      expect(scale.toPixel(100), 0);
      expect(scale.toPixel(50), 250);
    });
  });
}
