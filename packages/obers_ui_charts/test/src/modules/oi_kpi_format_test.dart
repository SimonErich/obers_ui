import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

void main() {
  group('OiKpiFormat', () {
    test('currency formats 1234567 correctly', () {
      final format = OiKpiFormat.currency();
      final result = format.format(1234567);
      // Should contain the digits of 1,234,567 with separators.
      expect(result.contains('1,234,567'), isTrue);
      expect(result, startsWith(r'$'));
    });

    test('percentage formats 0.0342 as "3.4%"', () {
      final format = OiKpiFormat.percentage();
      final result = format.format(0.0342);
      expect(result, equals('3.4%'));
    });

    test('number formats 42000 correctly', () {
      final format = OiKpiFormat.number();
      final result = format.format(42000);
      expect(result.contains('42,000'), isTrue);
    });

    test('OiKpiStatus has 4 values', () {
      expect(OiKpiStatus.values.length, equals(4));
      expect(
        OiKpiStatus.values,
        containsAll([
          OiKpiStatus.onTrack,
          OiKpiStatus.needsAttention,
          OiKpiStatus.critical,
          OiKpiStatus.neutral,
        ]),
      );
    });

    test('OiKpiCardStyle has 3 values', () {
      expect(OiKpiCardStyle.values.length, equals(3));
      expect(
        OiKpiCardStyle.values,
        containsAll([
          OiKpiCardStyle.standard,
          OiKpiCardStyle.compact,
          OiKpiCardStyle.detailed,
        ]),
      );
    });
  });
}
