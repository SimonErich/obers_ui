// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_country_option.dart';

void main() {
  group('OiStateOption', () {
    test('constructor sets all fields', () {
      const option = OiStateOption(name: 'California', code: 'CA');
      expect(option.name, 'California');
      expect(option.code, 'CA');
    });

    test('equality for same values', () {
      const a = OiStateOption(name: 'California', code: 'CA');
      const b = OiStateOption(name: 'California', code: 'CA');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('inequality for different values', () {
      const a = OiStateOption(name: 'California', code: 'CA');
      const b = OiStateOption(name: 'New York', code: 'NY');
      expect(a, isNot(b));
    });

    test('toString includes all fields', () {
      const option = OiStateOption(name: 'California', code: 'CA');
      expect(option.toString(), 'OiStateOption(name: California, code: CA)');
    });
  });

  group('OiCountryOption', () {
    test('constructor sets all fields', () {
      const option = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: [
          OiStateOption(name: 'California', code: 'CA'),
          OiStateOption(name: 'New York', code: 'NY'),
        ],
      );

      expect(option.code, 'US');
      expect(option.name, 'United States');
      expect(option.states, hasLength(2));
      expect(option.states![0].name, 'California');
      expect(option.states![1].code, 'NY');
    });

    test('constructor with null states', () {
      const option = OiCountryOption(code: 'DE', name: 'Germany');
      expect(option.states, isNull);
    });

    test('copyWith replaces code', () {
      const original = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: [OiStateOption(name: 'California', code: 'CA')],
      );

      final copied = original.copyWith(code: 'GB');
      expect(copied.code, 'GB');
      expect(copied.name, 'United States');
      expect(copied.states, hasLength(1));
    });

    test('copyWith replaces name', () {
      const original = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: [OiStateOption(name: 'California', code: 'CA')],
      );

      final copied = original.copyWith(name: 'USA');
      expect(copied.code, 'US');
      expect(copied.name, 'USA');
      expect(copied.states, hasLength(1));
    });

    test('copyWith replaces states', () {
      const original = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: [OiStateOption(name: 'California', code: 'CA')],
      );

      final copied = original.copyWith(
        states: [
          const OiStateOption(name: 'New York', code: 'NY'),
          const OiStateOption(name: 'Texas', code: 'TX'),
        ],
      );
      expect(copied.code, 'US');
      expect(copied.name, 'United States');
      expect(copied.states, hasLength(2));
      expect(copied.states![0].name, 'New York');
    });

    test('copyWith with explicit null for states', () {
      const original = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: [OiStateOption(name: 'California', code: 'CA')],
      );

      final copied = original.copyWith(states: null);
      expect(copied.states, isNull);
    });

    test('copyWith preserves unset fields', () {
      const original = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: [OiStateOption(name: 'California', code: 'CA')],
      );

      final copied = original.copyWith();
      expect(copied, original);
      expect(copied.code, 'US');
      expect(copied.name, 'United States');
      expect(copied.states, hasLength(1));
    });

    test('equality for same values', () {
      const a = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: [OiStateOption(name: 'California', code: 'CA')],
      );
      const b = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: [OiStateOption(name: 'California', code: 'CA')],
      );

      expect(a, b);
    });

    test('equality for different values', () {
      const a = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: [OiStateOption(name: 'California', code: 'CA')],
      );
      const b = OiCountryOption(code: 'GB', name: 'United Kingdom');

      expect(a, isNot(b));
    });

    test('equality with different states lists (deep list comparison)', () {
      const a = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: [
          OiStateOption(name: 'California', code: 'CA'),
          OiStateOption(name: 'New York', code: 'NY'),
        ],
      );
      const b = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: [
          OiStateOption(name: 'California', code: 'CA'),
          OiStateOption(name: 'New York', code: 'NY'),
        ],
      );
      const c = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: [
          OiStateOption(name: 'California', code: 'CA'),
          OiStateOption(name: 'Texas', code: 'TX'),
        ],
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
        states: [OiStateOption(name: 'California', code: 'CA')],
      );
      const b = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: [OiStateOption(name: 'California', code: 'CA')],
      );
      const c = OiCountryOption(code: 'GB', name: 'United Kingdom');

      expect(a.hashCode, b.hashCode);
      expect(a.hashCode, isNot(c.hashCode));
    });

    test('toString includes all fields', () {
      const option = OiCountryOption(
        code: 'US',
        name: 'United States',
        states: [OiStateOption(name: 'California', code: 'CA')],
      );

      final str = option.toString();
      expect(str, contains('US'));
      expect(str, contains('United States'));
      expect(str, contains('OiStateOption'));

      // Also verify with null states
      const optionNull = OiCountryOption(code: 'DE', name: 'Germany');
      expect(
        optionNull.toString(),
        'OiCountryOption(code: DE, name: Germany, states: null)',
      );
    });
  });
}
