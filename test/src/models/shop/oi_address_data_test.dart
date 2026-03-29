// Why: Test files are not part of the public API surface; requiring doc comments on every test group and helper closure would add noise without value.

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_address_data.dart';

void main() {
  group('OiAddressData', () {
    test('default constructor creates empty address', () {
      const address = OiAddressData();
      expect(address.firstName, isNull);
      expect(address.lastName, isNull);
      expect(address.company, isNull);
      expect(address.line1, isNull);
      expect(address.line2, isNull);
      expect(address.city, isNull);
      expect(address.state, isNull);
      expect(address.postalCode, isNull);
      expect(address.country, isNull);
      expect(address.phone, isNull);
      expect(address.email, isNull);
    });

    test('isComplete returns true when required fields are filled', () {
      const address = OiAddressData(
        firstName: 'Jane',
        lastName: 'Doe',
        line1: '123 Main St',
        city: 'Zürich',
        postalCode: '8001',
        country: 'CH',
      );
      expect(address.isComplete, isTrue);
    });

    test('isComplete returns false when required fields are missing', () {
      const address = OiAddressData(firstName: 'Jane');
      expect(address.isComplete, isFalse);
    });

    test('isComplete returns false when a required field is empty string', () {
      const address = OiAddressData(
        firstName: '',
        lastName: 'Doe',
        line1: '123 Main St',
        city: 'Zürich',
        postalCode: '8001',
        country: 'CH',
      );
      expect(address.isComplete, isFalse);
    });

    test('copyWith replaces specified fields', () {
      const original = OiAddressData(firstName: 'Jane', city: 'Zürich');
      final copy = original.copyWith(city: 'Bern');
      expect(copy.firstName, 'Jane');
      expect(copy.city, 'Bern');
    });

    test('copyWith can set fields to null', () {
      const original = OiAddressData(firstName: 'Jane', city: 'Zürich');
      final copy = original.copyWith(city: null);
      expect(copy.city, isNull);
      expect(copy.firstName, 'Jane');
    });

    test('equality works for equal instances', () {
      const a = OiAddressData(firstName: 'Jane', city: 'Zürich');
      const b = OiAddressData(firstName: 'Jane', city: 'Zürich');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('equality fails for different instances', () {
      const a = OiAddressData(firstName: 'Jane');
      const b = OiAddressData(firstName: 'John');
      expect(a, isNot(equals(b)));
    });

    test('toString includes key fields', () {
      const address = OiAddressData(firstName: 'Jane', country: 'CH');
      expect(address.toString(), contains('Jane'));
      expect(address.toString(), contains('CH'));
    });
  });
}
