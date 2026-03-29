// Why: Test files are not part of the public API surface; requiring doc comments on every test group and helper closure would add noise without value.

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_country_option.dart';

void main() {
  group('OiCountryOption', () {
    test('constructor and field access', () {
      const country = OiCountryOption(
        code: 'CH',
        name: 'Switzerland',
        states: [
          OiStateOption(name: 'Zürich', code: 'ZH'),
          OiStateOption(name: 'Bern', code: 'BE'),
          OiStateOption(name: 'Geneva', code: 'GE'),
        ],
      );
      expect(country.code, 'CH');
      expect(country.name, 'Switzerland');
      expect(country.states, hasLength(3));
    });

    test('defaults: states null', () {
      const country = OiCountryOption(code: 'DE', name: 'Germany');
      expect(country.states, isNull);
    });

    test('copyWith replaces specified fields', () {
      const country = OiCountryOption(code: 'CH', name: 'Switzerland');
      final copy = country.copyWith(name: 'Schweiz');
      expect(copy.name, 'Schweiz');
      expect(copy.code, 'CH');
    });

    test('copyWith can set states to null', () {
      const country = OiCountryOption(
        code: 'US',
        name: 'USA',
        states: [
          OiStateOption(name: 'California', code: 'CA'),
          OiStateOption(name: 'New York', code: 'NY'),
        ],
      );
      final copy = country.copyWith(states: null);
      expect(copy.states, isNull);
    });

    test('equality works', () {
      const a = OiCountryOption(code: 'CH', name: 'Switzerland');
      const b = OiCountryOption(code: 'CH', name: 'Switzerland');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality considers states', () {
      const a = OiCountryOption(
        code: 'US',
        name: 'USA',
        states: [OiStateOption(name: 'California', code: 'CA')],
      );
      const b = OiCountryOption(
        code: 'US',
        name: 'USA',
        states: [OiStateOption(name: 'New York', code: 'NY')],
      );
      expect(a, isNot(equals(b)));
    });

    test('toString includes key fields', () {
      const country = OiCountryOption(code: 'CH', name: 'Switzerland');
      expect(country.toString(), contains('CH'));
      expect(country.toString(), contains('Switzerland'));
    });
  });
}
