// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_scale.dart';
import 'package:obers_ui/src/foundation/scales/oi_point_scale.dart';

void main() {
  group('OiPointScale', () {
    const categories = ['A', 'B', 'C', 'D'];

    test('type is point', () {
      const scale = OiPointScale(
        domain: categories,
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(scale.type, OiScaleType.point);
    });

    test('toPixel distributes points evenly', () {
      const scale = OiPointScale(
        domain: categories,
        rangeMin: 0,
        rangeMax: 400,
        padding: 0,
      );
      // With 4 items and no padding: step = 400/3
      const step = 400.0 / 3;
      expect(scale.toPixel('A'), closeTo(0, 0.01));
      expect(scale.toPixel('B'), closeTo(step, 0.01));
      expect(scale.toPixel('C'), closeTo(step * 2, 0.01));
      expect(scale.toPixel('D'), closeTo(400, 0.01));
    });

    test('toPixel with padding adds outer spacing', () {
      const scale = OiPointScale(
        domain: categories,
        rangeMin: 0,
        rangeMax: 400,
      );
      // step = 400 / (4-1+2*0.5) = 400/4 = 100, offset = 50
      expect(scale.toPixel('A'), closeTo(50, 0.01));
      expect(scale.toPixel('B'), closeTo(150, 0.01));
      expect(scale.toPixel('C'), closeTo(250, 0.01));
      expect(scale.toPixel('D'), closeTo(350, 0.01));
    });

    test('toPixel returns rangeMin for unknown value', () {
      const scale = OiPointScale(
        domain: categories,
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(scale.toPixel('Z'), 0);
    });

    test('fromPixel returns nearest category', () {
      const scale = OiPointScale(
        domain: categories,
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(scale.fromPixel(50), 'A');
      expect(scale.fromPixel(160), 'B');
      expect(scale.fromPixel(240), 'C');
      expect(scale.fromPixel(350), 'D');
    });

    test('fromPixel with empty domain returns empty string', () {
      const scale = OiPointScale(domain: [], rangeMin: 0, rangeMax: 400);
      expect(scale.fromPixel(50), '');
    });

    test('single item places at center of range', () {
      const scale = OiPointScale(domain: ['Only'], rangeMin: 0, rangeMax: 400);
      expect(scale.toPixel('Only'), closeTo(200, 0.01));
    });

    test('buildTicks returns tick for each category', () {
      const scale = OiPointScale(
        domain: categories,
        rangeMin: 0,
        rangeMax: 400,
      );
      final ticks = scale.buildTicks();
      expect(ticks, hasLength(4));
      expect(ticks.map((t) => t.value).toList(), categories);
    });

    test('copyWith returns new instance', () {
      const scale = OiPointScale(
        domain: categories,
        rangeMin: 0,
        rangeMax: 400,
      );
      final copy = scale.copyWith(padding: 1);
      expect(copy.padding, 1);
      expect(copy.domain, categories);
    });

    test('equality', () {
      const a = OiPointScale(domain: categories, rangeMin: 0, rangeMax: 400);
      const b = OiPointScale(domain: categories, rangeMin: 0, rangeMax: 400);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });
}
