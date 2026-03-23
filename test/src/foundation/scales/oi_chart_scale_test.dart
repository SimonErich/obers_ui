// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_scale.dart';

void main() {
  group('OiScaleType', () {
    test('contains all 8 required types', () {
      expect(OiScaleType.values, hasLength(8));
      expect(
        OiScaleType.values.map((e) => e.name).toList(),
        containsAll([
          'linear',
          'logarithmic',
          'time',
          'category',
          'band',
          'point',
          'quantile',
          'threshold',
        ]),
      );
    });
  });

  group('OiTick', () {
    test('stores value and position', () {
      const tick = OiTick<double>(value: 10, position: 50);
      expect(tick.value, 10);
      expect(tick.position, 50);
    });

    test('equality', () {
      const a = OiTick<double>(value: 5, position: 25);
      const b = OiTick<double>(value: 5, position: 25);
      const c = OiTick<double>(value: 5, position: 30);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, b.hashCode);
    });

    test('toString includes value and position', () {
      const tick = OiTick<String>(value: 'A', position: 0);
      expect(tick.toString(), contains('A'));
      expect(tick.toString(), contains('0'));
    });
  });

  group('OiChartScale.inferType', () {
    test('returns linear for num values', () {
      expect(OiChartScale.inferType([1, 2.5, 3]), OiScaleType.linear);
    });

    test('returns time for DateTime values', () {
      expect(
        OiChartScale.inferType([DateTime(2024), DateTime(2025)]),
        OiScaleType.time,
      );
    });

    test('returns category for String values', () {
      expect(OiChartScale.inferType(['A', 'B', 'C']), OiScaleType.category);
    });

    test('returns null for empty list', () {
      expect(OiChartScale.inferType([]), isNull);
    });

    test('returns null for unsupported types', () {
      expect(OiChartScale.inferType([true, false]), isNull);
    });
  });
}
