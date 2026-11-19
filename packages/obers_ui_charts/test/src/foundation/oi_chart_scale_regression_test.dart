// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/foundation/oi_linear_scale.dart';
import 'package:obers_ui_charts/src/foundation/oi_logarithmic_scale.dart';

import '../../helpers/run_bounded.dart';

void main() {
  group('OiLinearScale non-finite input', () {
    test('buildTicks on a NaN domain returns no ticks', () {
      const scale = OiLinearScale(
        domainMin: double.nan,
        domainMax: double.nan,
        rangeMin: 0,
        rangeMax: 100,
      );
      expect(scale.buildTicks(), isEmpty);
    });

    test('buildTicks on an infinite domain returns no ticks', () {
      const scale = OiLinearScale(
        domainMin: 0,
        domainMax: double.infinity,
        rangeMin: 0,
        rangeMax: 100,
      );
      expect(scale.buildTicks(), isEmpty);
    });

    test('fromData ignores NaN values', () {
      final scale = OiLinearScale.fromData(
        values: const [double.nan, 1, 3],
        rangeMin: 0,
        rangeMax: 100,
      );
      expect(scale.domainMin, 1);
      expect(scale.domainMax, 3);
    });

    test('fromData ignores infinite values', () {
      final scale = OiLinearScale.fromData(
        values: const [1, double.infinity, 3, double.negativeInfinity],
        rangeMin: 0,
        rangeMax: 100,
      );
      expect(scale.domainMin, 1);
      expect(scale.domainMax, 3);
    });

    test('fromData with only non-finite values uses the default domain', () {
      final scale = OiLinearScale.fromData(
        values: const [double.nan, double.infinity],
        rangeMin: 0,
        rangeMax: 100,
      );
      expect(scale.domainMin, 0);
      expect(scale.domainMax, 1);
    });
  });

  // A regression here loops forever, so the work runs on another isolate
  // with a time limit (see runBounded).
  group('OiLinearScale huge magnitudes', () {
    Future<({double min, double max, List<double> ticks})> build(
      List<double> values, {
      int count = 5,
    }) {
      return runBounded(() {
        final scale = OiLinearScale.fromData(
          values: values,
          rangeMin: 0,
          rangeMax: 100,
        );
        return (
          min: scale.domainMin,
          max: scale.domainMax,
          ticks: [for (final t in scale.buildTicks(count: count)) t.value],
        );
      });
    }

    void expectSane(
      ({double min, double max, List<double> ticks}) result, {
      int count = 5,
    }) {
      expect(result.min.isFinite, isTrue);
      expect(result.max.isFinite, isTrue);
      expect(result.ticks.length, inInclusiveRange(2, count * 3));
      for (final tick in result.ticks) {
        expect(tick, inInclusiveRange(result.min, result.max));
      }
    }

    test('a range above the int64 limit gets nice ticks', () async {
      final result = await build(const [1e19, 9e19], count: 6);
      expect(result.min, 0);
      expect(result.max, 1e20);
      expect(result.ticks, [0, 2e19, 4e19, 6e19, 8e19, 1e20]);
    });

    test('1e22..3e22 gets a handful of ticks', () async {
      expectSane(await build(const [1e22, 3e22], count: 6), count: 6);
    });

    test('a single value near the double limit does not throw', () async {
      final result = await build(const [1.7e308]);
      expect(result.min, lessThan(1.7e308));
      expectSane(result);
    });

    test('a range spanning nearly all doubles terminates', () async {
      expectSane(await build(const [-1.7e308, 1.7e308]));
    });

    test('a tiny range around a large value terminates', () async {
      final ticks = await runBounded(() {
        const scale = OiLinearScale(
          domainMin: 1e20,
          domainMax: 1e20 + 16384,
          rangeMin: 0,
          rangeMax: 100,
        );
        return scale.buildTicks().length;
      });
      expect(ticks, lessThanOrEqualTo(15));
    });
  });

  group('OiLinearScale single-value padding', () {
    test('a small value keeps a domain of its own magnitude', () {
      final scale = OiLinearScale.fromData(
        values: const [0.001],
        rangeMin: 0,
        rangeMax: 100,
      );
      expect(scale.domainMin, greaterThan(0));
      expect(scale.domainMin, lessThan(0.001));
      expect(scale.domainMax, greaterThan(0.001));
      expect(scale.domainMax, lessThan(0.002));
    });

    test('a large value is padded in proportion', () {
      final scale = OiLinearScale.fromData(
        values: const [1000000],
        rangeMin: 0,
        rangeMax: 100,
        nice: false,
      );
      expect(scale.domainMin, 900000);
      expect(scale.domainMax, 1100000);
    });

    test('a negative value is padded on both sides', () {
      final scale = OiLinearScale.fromData(
        values: const [-50],
        rangeMin: 0,
        rangeMax: 100,
        nice: false,
      );
      expect(scale.domainMin, -55);
      expect(scale.domainMax, -45);
    });

    test('zero still expands to -1..1', () {
      final scale = OiLinearScale.fromData(
        values: const [0],
        rangeMin: 0,
        rangeMax: 100,
        nice: false,
      );
      expect(scale.domainMin, -1);
      expect(scale.domainMax, 1);
    });
  });

  group('OiLogarithmicScale', () {
    test('fromData keeps an exact power of the base as the lower bound', () {
      final scale = OiLogarithmicScale.fromData(
        values: const [1000, 5000],
        rangeMin: 0,
        rangeMax: 100,
      );
      expect(scale.domainMin, 1000);
      expect(scale.domainMax, 10000);
    });

    test('fromData ignores non-finite values', () {
      final scale = OiLogarithmicScale.fromData(
        values: const [10, double.nan, double.infinity, 100],
        rangeMin: 0,
        rangeMax: 100,
      );
      expect(scale.domainMin, 10);
      expect(scale.domainMax, 100);
    });

    test('buildTicks thins decades down to count', () {
      const scale = OiLogarithmicScale(
        domainMin: 1,
        domainMax: 1000000,
        rangeMin: 0,
        rangeMax: 600,
      );
      final three = scale.buildTicks(count: 3).map((t) => t.value).toList();
      expect(three, [1.0, 1000.0, 1000000.0]);

      final ten = scale.buildTicks(count: 10).map((t) => t.value).toList();
      expect(ten, [1.0, 10.0, 100.0, 1000.0, 10000.0, 100000.0, 1000000.0]);
    });

    test('buildTicks keeps both ends of the domain when thinning', () {
      const decades = OiLogarithmicScale(
        domainMin: 1,
        domainMax: 1000000,
        rangeMin: 0,
        rangeMax: 600,
      );
      List<double> ticks(OiLogarithmicScale scale, int count) =>
          scale.buildTicks(count: count).map((t) => t.value).toList();

      expect(ticks(decades, 2), [1.0, 1000000.0]);
      expect(ticks(decades, 4), [1.0, 100.0, 10000.0, 1000000.0]);
      expect(ticks(decades, 5), hasLength(5));
      expect(ticks(decades, 5).first, 1);
      expect(ticks(decades, 5).last, 1000000);
      expect(ticks(decades, 1), [1.0]);

      const binary = OiLogarithmicScale(
        domainMin: 1,
        domainMax: 1024,
        rangeMin: 0,
        rangeMax: 600,
        base: 2,
      );
      expect(ticks(binary, 5), [1.0, 8.0, 32.0, 256.0, 1024.0]);
      expect(ticks(binary, 3), [1.0, 32.0, 1024.0]);

      // Sub-decade ticks are thinned the same way.
      const single = OiLogarithmicScale(
        domainMin: 2,
        domainMax: 8,
        rangeMin: 0,
        rangeMax: 300,
      );
      expect(ticks(single, 1), [2.0]);
    });

    test('buildTicks with count 0 returns no ticks', () {
      const scale = OiLogarithmicScale(
        domainMin: 1,
        domainMax: 1000,
        rangeMin: 0,
        rangeMax: 300,
      );
      expect(scale.buildTicks(count: 0), isEmpty);
    });

    test('buildTicks adds sub-decade ticks inside a single decade', () {
      const scale = OiLogarithmicScale(
        domainMin: 2,
        domainMax: 8,
        rangeMin: 0,
        rangeMax: 300,
      );
      final five = scale.buildTicks().map((t) => t.value).toList();
      expect(five, [2.0, 5.0]);

      final ten = scale.buildTicks(count: 10).map((t) => t.value).toList();
      expect(ten, [2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]);
    });

    test('buildTicks fills a short range with sub-decade ticks', () {
      const scale = OiLogarithmicScale(
        domainMin: 1,
        domainMax: 100,
        rangeMin: 0,
        rangeMax: 300,
      );
      final values = scale.buildTicks(count: 8).map((t) => t.value).toList();
      expect(values, [1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0]);
    });

    test('toPixel reports values outside the log domain as NaN', () {
      const scale = OiLogarithmicScale(
        domainMin: 1,
        domainMax: 1000,
        rangeMin: 0,
        rangeMax: 300,
      );
      expect(scale.toPixel(0), isNaN);
      expect(scale.toPixel(-1), isNaN);
      expect(scale.toPixel(double.nan), isNaN);
      expect(scale.toPixel(1), 0);
    });
  });
}
