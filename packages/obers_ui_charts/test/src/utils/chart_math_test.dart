import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/utils/chart_math.dart';

void main() {
  group('chart_math', () {
    test('isMissingValue detects NaN', () {
      expect(isMissingValue(double.nan), isTrue);
    });

    test('isMissingValue detects infinity', () {
      expect(isMissingValue(double.infinity), isTrue);
      expect(isMissingValue(double.negativeInfinity), isTrue);
    });

    test('isMissingValue returns false for valid numbers', () {
      expect(isMissingValue(0), isFalse);
      expect(isMissingValue(42.5), isFalse);
      expect(isMissingValue(-10), isFalse);
    });

    test('isMissingValue returns true for null', () {
      expect(isMissingValue(null), isTrue);
    });

    test('domainPaddingForSinglePoint returns positive padding', () {
      expect(domainPaddingForSinglePoint(100), greaterThan(0));
      expect(domainPaddingForSinglePoint(0), 1.0);
      expect(domainPaddingForSinglePoint(-50), greaterThan(0));
    });

    test('clampDomainRange expands zero-range', () {
      final result = clampDomainRange(5, 5);
      expect(result.min, lessThan(5));
      expect(result.max, greaterThan(5));
    });

    test('clampDomainRange swaps inverted range', () {
      final result = clampDomainRange(10, 5);
      expect(result.min, 5);
      expect(result.max, 10);
    });

    test('clampDomainRange preserves valid range', () {
      final result = clampDomainRange(0, 100);
      expect(result.min, 0);
      expect(result.max, 100);
    });

    test('niceNumber returns nice values', () {
      expect(niceNumber(1), 1.0);
      expect(niceNumber(1.8), 2.0);
      expect(niceNumber(4.5), 5.0);
      expect(niceNumber(8), 10.0);
      expect(niceNumber(15), 20.0);
    });

    test('clampZoom enforces bounds', () {
      expect(clampZoom(0.05), 0.1);
      expect(clampZoom(200), 100.0);
      expect(clampZoom(5), 5.0);
    });
  });
}
