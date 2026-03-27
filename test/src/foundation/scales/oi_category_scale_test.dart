// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/scales/oi_category_scale.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_scale.dart';

void main() {
  group('OiCategoryScale', () {
    const categories = ['A', 'B', 'C', 'D'];

    test('type is category', () {
      const scale = OiCategoryScale(
        domain: categories,
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(scale.type, OiScaleType.category);
    });

    test('toPixel places categories at band centers', () {
      const scale = OiCategoryScale(
        domain: categories,
        rangeMin: 0,
        rangeMax: 400,
      );
      // step = 400/4 = 100, centers at 50, 150, 250, 350
      expect(scale.toPixel('A'), closeTo(50, 0.01));
      expect(scale.toPixel('B'), closeTo(150, 0.01));
      expect(scale.toPixel('C'), closeTo(250, 0.01));
      expect(scale.toPixel('D'), closeTo(350, 0.01));
    });

    test('toPixel returns rangeMin for unknown value', () {
      const scale = OiCategoryScale(
        domain: categories,
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(scale.toPixel('Z'), 0);
    });

    test('fromPixel returns nearest category', () {
      const scale = OiCategoryScale(
        domain: categories,
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(scale.fromPixel(50), 'A');
      expect(scale.fromPixel(140), 'B');
      expect(scale.fromPixel(250), 'C');
      expect(scale.fromPixel(370), 'D');
    });

    test('fromPixel clamps to valid range', () {
      const scale = OiCategoryScale(
        domain: categories,
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(scale.fromPixel(-100), 'A');
      expect(scale.fromPixel(600), 'D');
    });

    test('fromPixel with empty domain returns empty string', () {
      const scale = OiCategoryScale(domain: [], rangeMin: 0, rangeMax: 400);
      expect(scale.fromPixel(50), '');
    });

    test('step is computed correctly', () {
      const scale = OiCategoryScale(
        domain: categories,
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(scale.step, 100);
    });

    test('step is 0 for empty domain', () {
      const scale = OiCategoryScale(domain: [], rangeMin: 0, rangeMax: 400);
      expect(scale.step, 0);
    });

    test('buildTicks returns tick for each category', () {
      const scale = OiCategoryScale(
        domain: categories,
        rangeMin: 0,
        rangeMax: 400,
      );
      final ticks = scale.buildTicks();
      expect(ticks, hasLength(4));
      expect(ticks[0].value, 'A');
      expect(ticks[1].value, 'B');
      expect(ticks[2].value, 'C');
      expect(ticks[3].value, 'D');
    });

    test('copyWith returns new instance', () {
      const scale = OiCategoryScale(
        domain: categories,
        rangeMin: 0,
        rangeMax: 400,
      );
      final copy = scale.copyWith(rangeMax: 800);
      expect(copy.rangeMax, 800);
      expect(copy.domain, categories);
    });

    test('equality', () {
      const a = OiCategoryScale(domain: categories, rangeMin: 0, rangeMax: 400);
      const b = OiCategoryScale(domain: categories, rangeMin: 0, rangeMax: 400);
      const c = OiCategoryScale(domain: ['X', 'Y'], rangeMin: 0, rangeMax: 400);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, b.hashCode);
    });
  });
}
