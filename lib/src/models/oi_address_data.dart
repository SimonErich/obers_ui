import 'package:flutter/foundation.dart';

/// A postal / shipping address.
///
/// Coverage: REQ-0006
///
/// All fields are nullable to support partial entry during checkout flows.
///
/// {@category Models}
@immutable
class OiAddressData {
  /// Creates an [OiAddressData].
  const OiAddressData({
    this.firstName,
    this.lastName,
    this.company,
    this.line1,
    this.line2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.phone,
    this.email,
  });

  /// First name of the recipient.
  final String? firstName;

  /// Last name of the recipient.
  final String? lastName;

  /// Company or organisation name.
  final String? company;

  /// Primary street address line.
  final String? line1;

  /// Secondary street address line (apt, suite, etc.).
  final String? line2;

  /// City or locality.
  final String? city;

  /// State, province, or region.
  final String? state;

  /// Postal / ZIP code.
  final String? postalCode;

  /// Country code or name.
  final String? country;

  /// Phone number.
  final String? phone;

  /// Email address.
  final String? email;

  /// Whether all required fields are filled in.
  bool get isComplete =>
      firstName != null &&
      firstName!.isNotEmpty &&
      lastName != null &&
      lastName!.isNotEmpty &&
      line1 != null &&
      line1!.isNotEmpty &&
      city != null &&
      city!.isNotEmpty &&
      postalCode != null &&
      postalCode!.isNotEmpty &&
      country != null &&
      country!.isNotEmpty;

  /// Returns a copy with the specified fields replaced.
  OiAddressData copyWith({
    Object? firstName = _sentinel,
    Object? lastName = _sentinel,
    Object? company = _sentinel,
    Object? line1 = _sentinel,
    Object? line2 = _sentinel,
    Object? city = _sentinel,
    Object? state = _sentinel,
    Object? postalCode = _sentinel,
    Object? country = _sentinel,
    Object? phone = _sentinel,
    Object? email = _sentinel,
  }) {
    return OiAddressData(
      firstName: identical(firstName, _sentinel)
          ? this.firstName
          : firstName as String?,
      lastName: identical(lastName, _sentinel)
          ? this.lastName
          : lastName as String?,
      company: identical(company, _sentinel)
          ? this.company
          : company as String?,
      line1: identical(line1, _sentinel)
          ? this.line1
          : line1 as String?,
      line2: identical(line2, _sentinel)
          ? this.line2
          : line2 as String?,
      city: identical(city, _sentinel) ? this.city : city as String?,
      state: identical(state, _sentinel) ? this.state : state as String?,
      postalCode: identical(postalCode, _sentinel)
          ? this.postalCode
          : postalCode as String?,
      country: identical(country, _sentinel)
          ? this.country
          : country as String?,
      phone: identical(phone, _sentinel) ? this.phone : phone as String?,
      email: identical(email, _sentinel) ? this.email : email as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiAddressData) return false;
    return firstName == other.firstName &&
        lastName == other.lastName &&
        company == other.company &&
        line1 == other.line1 &&
        line2 == other.line2 &&
        city == other.city &&
        state == other.state &&
        postalCode == other.postalCode &&
        country == other.country &&
        phone == other.phone &&
        email == other.email;
  }

  @override
  int get hashCode => Object.hash(
    firstName,
    lastName,
    company,
    line1,
    line2,
    city,
    state,
    postalCode,
    country,
    phone,
    email,
  );

  @override
  String toString() =>
      'OiAddressData(firstName: $firstName, lastName: $lastName, '
      'city: $city, country: $country)';
}

/// Sentinel used by [OiAddressData.copyWith] to distinguish an explicit `null`
/// from "not provided".
const Object _sentinel = Object();
