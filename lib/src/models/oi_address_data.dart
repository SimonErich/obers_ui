import 'package:flutter/foundation.dart';

/// A postal / shipping address.
///
/// Coverage: REQ-0067
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
    this.address1,
    this.address2,
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
  final String? address1;

  /// Secondary street address line (apt, suite, etc.).
  final String? address2;

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
      address1 != null &&
      address1!.isNotEmpty &&
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
    Object? address1 = _sentinel,
    Object? address2 = _sentinel,
    Object? city = _sentinel,
    Object? state = _sentinel,
    Object? postalCode = _sentinel,
    Object? country = _sentinel,
    Object? phone = _sentinel,
    Object? email = _sentinel,
  }) {
    return OiAddressData(
      firstName:
          identical(firstName, _sentinel)
              ? this.firstName
              : firstName as String?,
      lastName:
          identical(lastName, _sentinel) ? this.lastName : lastName as String?,
      company:
          identical(company, _sentinel) ? this.company : company as String?,
      address1:
          identical(address1, _sentinel) ? this.address1 : address1 as String?,
      address2:
          identical(address2, _sentinel) ? this.address2 : address2 as String?,
      city: identical(city, _sentinel) ? this.city : city as String?,
      state: identical(state, _sentinel) ? this.state : state as String?,
      postalCode:
          identical(postalCode, _sentinel)
              ? this.postalCode
              : postalCode as String?,
      country:
          identical(country, _sentinel) ? this.country : country as String?,
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
        address1 == other.address1 &&
        address2 == other.address2 &&
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
    address1,
    address2,
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
