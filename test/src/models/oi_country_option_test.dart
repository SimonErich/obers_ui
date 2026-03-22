// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_country_option.dart';

void main() {
  group('OiCountryOption', () {
    test('constructor assigns fields correctly', () {
      const option = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: ['California', 'New York'],
      );

      expect(option.code, 'US');
      expect(option.name, 'United States');
      expect(option.states, ['California', 'New York']);
    });

    test('states defaults to null', () {
      const option = OiCountryOption(code: 'DE', name: 'Germany');
      expect(option.states, isNull);
    });

    test('copyWith replaces specified fields', () {
      const original = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: ['California'],
      );

      final copied = original.copyWith(name: 'USA');
      expect(copied.code, 'US');
      expect(copied.name, 'USA');
      expect(copied.states, ['California']);
    });

    test('copyWith can set states to null', () {
      const original = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: ['California'],
      );

      final copied = original.copyWith(states: null);
      expect(copied.states, isNull);
    });

    test('copyWith without arguments returns equal instance', () {
      const original = OiCountryOption(code: 'US', name: 'United States');
      final copied = original.copyWith();
      expect(copied, original);
    });

    test('equality based on all fields', () {
      const a = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: ['CA'],
      );
      const b = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: ['CA'],
      );
      const c = OiCountryOption(code: 'GB', name: 'United Kingdom');

      expect(a, b);
      expect(a, isNot(c));
      expect(a.hashCode, b.hashCode);
      expect(a.hashCode, isNot(c.hashCode));
    });

    test('equality with different states lists', () {
      const a = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: ['CA'],
      );
      const b = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: ['NY'],
      );

      expect(a, isNot(b));
    });

    test('equality with null vs non-null states', () {
      const a = OiCountryOption(code: 'US', name: 'United States');
      const b = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: ['CA'],
      );

      expect(a, isNot(b));
    });

    test('toString returns expected format', () {
      const option = OiCountryOption(code: 'US', name: 'United States');
      expect(
        option.toString(),
        'OiCountryOption(code: US, name: United States, states: null)',
      );
    });
  });
}
