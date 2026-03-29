// Tests do not require documentation comments.

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/models/oi_address_data.dart';

void main() {
  group('OiAddressData', () {
    test('empty construction has all null fields', () {
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

    test('full construction with all fields', () {
      const address = OiAddressData(
        firstName: 'John',
        lastName: 'Doe',
        company: 'Acme Inc',
        line1: '123 Main St',
        line2: 'Suite 100',
        city: 'Springfield',
        state: 'IL',
        postalCode: '62701',
        country: 'US',
        phone: '+1-555-0100',
        email: 'john@example.com',
      );
      expect(address.firstName, 'John');
      expect(address.lastName, 'Doe');
      expect(address.company, 'Acme Inc');
      expect(address.line1, '123 Main St');
      expect(address.line2, 'Suite 100');
      expect(address.city, 'Springfield');
      expect(address.state, 'IL');
      expect(address.postalCode, '62701');
      expect(address.country, 'US');
      expect(address.phone, '+1-555-0100');
      expect(address.email, 'john@example.com');
    });

    test('isComplete returns true when required fields are present', () {
      const address = OiAddressData(
        firstName: 'John',
        lastName: 'Doe',
        line1: '123 Main St',
        city: 'Springfield',
        postalCode: '62701',
        country: 'US',
      );
      expect(address.isComplete, true);
    });

    test('isComplete returns false when firstName is missing', () {
      const address = OiAddressData(
        lastName: 'Doe',
        line1: '123 Main St',
        city: 'Springfield',
        postalCode: '62701',
        country: 'US',
      );
      expect(address.isComplete, false);
    });

    test('isComplete returns false when lastName is missing', () {
      const address = OiAddressData(
        firstName: 'John',
        line1: '123 Main St',
        city: 'Springfield',
        postalCode: '62701',
        country: 'US',
      );
      expect(address.isComplete, false);
    });

    test('isComplete returns false when line1 is missing', () {
      const address = OiAddressData(
        firstName: 'John',
        lastName: 'Doe',
        city: 'Springfield',
        postalCode: '62701',
        country: 'US',
      );
      expect(address.isComplete, false);
    });

    test('isComplete returns false when city is missing', () {
      const address = OiAddressData(
        firstName: 'John',
        lastName: 'Doe',
        line1: '123 Main St',
        postalCode: '62701',
        country: 'US',
      );
      expect(address.isComplete, false);
    });

    test('isComplete returns false when postalCode is missing', () {
      const address = OiAddressData(
        firstName: 'John',
        lastName: 'Doe',
        line1: '123 Main St',
        city: 'Springfield',
        country: 'US',
      );
      expect(address.isComplete, false);
    });

    test('isComplete returns false when country is missing', () {
      const address = OiAddressData(
        firstName: 'John',
        lastName: 'Doe',
        line1: '123 Main St',
        city: 'Springfield',
        postalCode: '62701',
      );
      expect(address.isComplete, false);
    });

    test('isComplete returns false when required field is empty string', () {
      const address = OiAddressData(
        firstName: '',
        lastName: 'Doe',
        line1: '123 Main St',
        city: 'Springfield',
        postalCode: '62701',
        country: 'US',
      );
      expect(address.isComplete, false);
    });

    test('copyWith replaces fields', () {
      const address = OiAddressData(
        firstName: 'John',
        lastName: 'Doe',
        city: 'Springfield',
      );
      final updated = address.copyWith(
        firstName: 'Jane',
        city: 'Chicago',
        state: 'IL',
      );
      expect(updated.firstName, 'Jane');
      expect(updated.lastName, 'Doe');
      expect(updated.city, 'Chicago');
      expect(updated.state, 'IL');
    });

    test('copyWith can null out fields', () {
      const address = OiAddressData(
        firstName: 'John',
        lastName: 'Doe',
        company: 'Acme',
        line1: '123 Main',
        line2: 'Suite 1',
        phone: '555-0100',
        email: 'john@example.com',
      );
      final cleared = address.copyWith(
        company: null,
        line2: null,
        phone: null,
        email: null,
      );
      expect(cleared.company, isNull);
      expect(cleared.line2, isNull);
      expect(cleared.phone, isNull);
      expect(cleared.email, isNull);
      expect(cleared.firstName, 'John');
      expect(cleared.lastName, 'Doe');
      expect(cleared.line1, '123 Main');
    });

    test('copyWith with no args returns equal instance', () {
      const address = OiAddressData(firstName: 'John', lastName: 'Doe');
      final copy = address.copyWith();
      expect(copy, equals(address));
    });

    test('equal instances are ==', () {
      const a = OiAddressData(
        firstName: 'John',
        lastName: 'Doe',
        line1: '123 Main St',
        city: 'Springfield',
        postalCode: '62701',
        country: 'US',
      );
      const b = OiAddressData(
        firstName: 'John',
        lastName: 'Doe',
        line1: '123 Main St',
        city: 'Springfield',
        postalCode: '62701',
        country: 'US',
      );
      expect(a, equals(b));
    });

    test('equal instances have the same hashCode', () {
      const a = OiAddressData(firstName: 'John', lastName: 'Doe');
      const b = OiAddressData(firstName: 'John', lastName: 'Doe');
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different instances are not ==', () {
      const a = OiAddressData(firstName: 'John', lastName: 'Doe');
      const b = OiAddressData(firstName: 'Jane', lastName: 'Doe');
      expect(a, isNot(equals(b)));
    });

    test('toString includes firstName, lastName, city, country', () {
      const address = OiAddressData(
        firstName: 'John',
        lastName: 'Doe',
        city: 'Springfield',
        country: 'US',
      );
      final str = address.toString();
      expect(str, contains('John'));
      expect(str, contains('Doe'));
      expect(str, contains('Springfield'));
      expect(str, contains('US'));
    });
  });
}
