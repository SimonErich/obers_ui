// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_country_option.dart';

void main() {
  group('OiCountryOption', () {
    test('constructor sets all fields', () {
      const option = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: ['California', 'New York'],
      );

      expect(option.code, 'US');
      expect(option.name, 'United States');
      expect(option.states, ['California', 'New York']);
    });

    test('constructor with null states', () {
      const option = OiCountryOption(code: 'DE', name: 'Germany');
      expect(option.states, isNull);
    });

    test('copyWith replaces code', () {
      const original = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: ['California'],
      );

      final copied = original.copyWith(code: 'GB');
      expect(copied.code, 'GB');
      expect(copied.name, 'United States');
      expect(copied.states, ['California']);
    });

    test('copyWith replaces name', () {
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

    test('copyWith replaces states', () {
      const original = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: ['California'],
      );

      final copied = original.copyWith(states: ['New York', 'Texas']);
      expect(copied.code, 'US');
      expect(copied.name, 'United States');
      expect(copied.states, ['New York', 'Texas']);
    });

    test('copyWith with explicit null for states', () {
      const original = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: ['California'],
      );

      final copied = original.copyWith(states: null);
      expect(copied.states, isNull);
    });

    test('copyWith preserves unset fields', () {
      const original = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: ['California'],
      );

      final copied = original.copyWith();
      expect(copied, original);
      expect(copied.code, 'US');
      expect(copied.name, 'United States');
      expect(copied.states, ['California']);
    });

    test('equality for same values', () {
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

      expect(a, b);
    });

    test('equality for different values', () {
      const a = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: ['CA'],
      );
      const b = OiCountryOption(code: 'GB', name: 'United Kingdom');

      expect(a, isNot(b));
    });

    test('equality with different states lists (deep list comparison)', () {
      const a = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: ['CA', 'NY'],
      );
      const b = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: ['CA', 'NY'],
      );
      const c = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: ['CA', 'TX'],
      );
      const d = OiCountryOption(code: 'US', name: 'United States');

      // Same contents — equal
      expect(a, b);
      // Different contents — not equal
      expect(a, isNot(c));
      // Non-null vs null — not equal
      expect(a, isNot(d));
    });

    test('hashCode consistency', () {
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

      expect(a.hashCode, b.hashCode);
      expect(a.hashCode, isNot(c.hashCode));
    });

    test('toString includes all fields', () {
      const option = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: ['CA'],
      );

      final str = option.toString();
      expect(str, contains('US'));
      expect(str, contains('United States'));
      expect(str, contains('CA'));
      expect(
        str,
        'OiCountryOption(code: US, name: United States, states: [CA])',
      );

      // Also verify with null states
      const optionNull = OiCountryOption(code: 'DE', name: 'Germany');
      expect(
        optionNull.toString(),
        'OiCountryOption(code: DE, name: Germany, states: null)',
      );
    });
  });
}
