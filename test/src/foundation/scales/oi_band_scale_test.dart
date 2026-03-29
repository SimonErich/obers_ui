// Tests do not require documentation comments.

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/scales/oi_band_scale.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_scale.dart';

void main() {
  group('OiBandScale', () {
    const categories = ['A', 'B', 'C'];

    test('type is band', () {
      const scale = OiBandScale(domain: categories, rangeMin: 0, rangeMax: 300);
      expect(scale.type, OiScaleType.band);
    });

    test('bandwidth is positive for non-empty domain', () {
      const scale = OiBandScale(domain: categories, rangeMin: 0, rangeMax: 300);
      expect(scale.bandwidth, greaterThan(0));
    });

    test('bandwidth is 0 for empty domain', () {
      const scale = OiBandScale(domain: [], rangeMin: 0, rangeMax: 300);
      expect(scale.bandwidth, 0);
    });

    test('toPixel returns band start position', () {
      const scale = OiBandScale(
        domain: categories,
        rangeMin: 0,
        rangeMax: 300,
        paddingInner: 0,
        paddingOuter: 0,
      );
      // With no padding: step = 300/3 = 100
      expect(scale.toPixel('A'), closeTo(0, 0.01));
      expect(scale.toPixel('B'), closeTo(100, 0.01));
      expect(scale.toPixel('C'), closeTo(200, 0.01));
    });

    test('toPixel returns rangeMin for unknown value', () {
      const scale = OiBandScale(domain: categories, rangeMin: 0, rangeMax: 300);
      expect(scale.toPixel('Z'), 0);
    });

    test('bandCenter returns center of each band', () {
      const scale = OiBandScale(
        domain: categories,
        rangeMin: 0,
        rangeMax: 300,
        paddingInner: 0,
        paddingOuter: 0,
      );
      final bw = scale.bandwidth;
      expect(scale.bandCenter('A'), closeTo(bw / 2, 0.01));
    });

    test('fromPixel returns nearest category', () {
      const scale = OiBandScale(
        domain: categories,
        rangeMin: 0,
        rangeMax: 300,
        paddingInner: 0,
        paddingOuter: 0,
      );
      expect(scale.fromPixel(50), 'A');
      expect(scale.fromPixel(150), 'B');
      expect(scale.fromPixel(250), 'C');
    });

    test('fromPixel with empty domain returns empty string', () {
      const scale = OiBandScale(domain: [], rangeMin: 0, rangeMax: 300);
      expect(scale.fromPixel(50), '');
    });

    test('buildTicks returns tick at band center for each category', () {
      const scale = OiBandScale(domain: categories, rangeMin: 0, rangeMax: 300);
      final ticks = scale.buildTicks();
      expect(ticks, hasLength(3));
      expect(ticks[0].value, 'A');
      expect(ticks[1].value, 'B');
      expect(ticks[2].value, 'C');
    });

    test('bandAt returns start and width', () {
      const scale = OiBandScale(
        domain: categories,
        rangeMin: 0,
        rangeMax: 300,
        paddingInner: 0,
        paddingOuter: 0,
      );
      final band = scale.bandAt(0);
      expect(band.start, closeTo(0, 0.01));
      expect(band.width, closeTo(100, 0.01));
    });

    test('bandAt clamps index', () {
      const scale = OiBandScale(domain: categories, rangeMin: 0, rangeMax: 300);
      final band = scale.bandAt(10);
      expect(band.start, scale.toPixel('C'));
    });

    test('padding affects spacing', () {
      const noPadding = OiBandScale(
        domain: categories,
        rangeMin: 0,
        rangeMax: 300,
        paddingInner: 0,
        paddingOuter: 0,
      );
      const withPadding = OiBandScale(
        domain: categories,
        rangeMin: 0,
        rangeMax: 300,
        paddingInner: 0.2,
      );
      expect(withPadding.bandwidth, lessThan(noPadding.bandwidth));
    });

    test('inverted range works', () {
      const scale = OiBandScale(
        domain: categories,
        rangeMin: 300,
        rangeMax: 0,
        paddingInner: 0,
        paddingOuter: 0,
      );
      // With inverted range, 'A' should be near 300, 'C' near 0.
      expect(scale.toPixel('A'), greaterThan(scale.toPixel('C')));
      expect(scale.fromPixel(280), 'A');
      expect(scale.fromPixel(20), 'C');
    });

    test('copyWith returns new instance', () {
      const scale = OiBandScale(domain: categories, rangeMin: 0, rangeMax: 300);
      final copy = scale.copyWith(paddingInner: 0.3);
      expect(copy.paddingInner, 0.3);
      expect(copy.domain, categories);
    });

    test('equality', () {
      const a = OiBandScale(domain: categories, rangeMin: 0, rangeMax: 300);
      const b = OiBandScale(domain: categories, rangeMin: 0, rangeMax: 300);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });
}
