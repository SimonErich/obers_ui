import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

void main() {
  group('OiChartScale.withDomain()', () {
    test(
      'OiLinearScale withDomain returns new scale with overridden domain',
      () {
        const scale = OiLinearScale(
          domainMin: 0,
          domainMax: 100,
          rangeMin: 0,
          rangeMax: 400,
        );

        final constrained = scale.withDomain(25, 75) as OiLinearScale;

        expect(constrained.domainMin, 25);
        expect(constrained.domainMax, 75);
        expect(constrained.rangeMin, 0);
        expect(constrained.rangeMax, 400);
        // Midpoint of 25-75 domain (50) should map to midpoint of range (200).
        expect(constrained.toPixel(50), closeTo(200, 0.01));
        // 25 maps to 0, 75 maps to 400.
        expect(constrained.toPixel(25), closeTo(0, 0.01));
        expect(constrained.toPixel(75), closeTo(400, 0.01));
      },
    );

    test('OiLogarithmicScale withDomain preserves base', () {
      const scale = OiLogarithmicScale(
        domainMin: 1,
        domainMax: 1000,
        rangeMin: 0,
        rangeMax: 300,
        base: 10,
      );

      final constrained = scale.withDomain(10, 100) as OiLogarithmicScale;

      expect(constrained.domainMin, 10);
      expect(constrained.domainMax, 100);
      expect(constrained.base, 10);
    });

    test('OiTimeScale withDomain returns DateTime-typed scale', () {
      final scale = OiTimeScale(
        domainMin: DateTime(2020),
        domainMax: DateTime(2025),
        rangeMin: 0,
        rangeMax: 500,
      );

      final constrained =
          scale.withDomain(DateTime(2022), DateTime(2024)) as OiTimeScale;

      expect(constrained.domainMin, DateTime(2022));
      expect(constrained.domainMax, DateTime(2024));
    });
  });

  group('OiChartScale.buildTicksConstrained()', () {
    test('respects maxCount', () {
      const scale = OiLinearScale(
        domainMin: 0,
        domainMax: 100,
        rangeMin: 0,
        rangeMax: 1000,
      );

      final ticks = scale.buildTicksConstrained(maxCount: 3);
      expect(ticks.length, lessThanOrEqualTo(3));
    });

    test('respects minSpacingPx', () {
      const scale = OiLinearScale(
        domainMin: 0,
        domainMax: 10,
        rangeMin: 0,
        rangeMax: 100,
      );

      // Generate many ticks, then filter by spacing.
      final ticks = scale.buildTicksConstrained(maxCount: 20, minSpacingPx: 25);

      // Check all adjacent ticks are at least 25px apart.
      for (var i = 1; i < ticks.length; i++) {
        expect(
          (ticks[i].position - ticks[i - 1].position).abs(),
          greaterThanOrEqualTo(25),
        );
      }
    });
  });
}
