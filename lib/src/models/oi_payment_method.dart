import 'package:flutter/widgets.dart';

/// A payment method option displayed during checkout.
///
/// Coverage: REQ-0005
///
/// {@category Models}
@immutable
class OiPaymentMethod {
  /// Creates an [OiPaymentMethod].
  const OiPaymentMethod({
    required this.key,
    required this.label,
    this.description,
    this.icon,
    this.defaultMethod = false,
    this.lastFour,
    this.expiryDate,
    this.logo,
  });

  /// Unique identifier for this payment method.
  final Object key;

  /// Human-readable label (e.g. "Credit Card").
  final String label;

  /// Optional description (e.g. "Visa ending in 4242").
  final String? description;

  /// Optional icon for this payment method.
  final IconData? icon;

  /// Whether this is the default / pre-selected payment method.
  final bool defaultMethod;

  /// Last four digits of the card (e.g. '•••• 4242' for saved cards).
  final String? lastFour;

  /// Card expiry date (e.g. '12/25').
  final String? expiryDate;

  /// Optional logo widget (e.g. a card brand image).
  final Widget? logo;

  /// Returns a copy with the specified fields replaced.
  OiPaymentMethod copyWith({
    Object? key,
    String? label,
    Object? description = _sentinel,
    Object? icon = _sentinel,
    bool? defaultMethod,
    Object? lastFour = _sentinel,
    Object? expiryDate = _sentinel,
    Object? logo = _sentinel,
  }) {
    return OiPaymentMethod(
      key: key ?? this.key,
      label: label ?? this.label,
      description: identical(description, _sentinel)
          ? this.description
          : description as String?,
      icon: identical(icon, _sentinel) ? this.icon : icon as IconData?,
      defaultMethod: defaultMethod ?? this.defaultMethod,
      lastFour: identical(lastFour, _sentinel)
          ? this.lastFour
          : lastFour as String?,
      expiryDate: identical(expiryDate, _sentinel)
          ? this.expiryDate
          : expiryDate as String?,
      logo: identical(logo, _sentinel) ? this.logo : logo as Widget?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiPaymentMethod) return false;
    return key == other.key &&
        label == other.label &&
        description == other.description &&
        icon == other.icon &&
        defaultMethod == other.defaultMethod &&
        lastFour == other.lastFour &&
        expiryDate == other.expiryDate &&
        logo == other.logo;
  }

  @override
  int get hashCode => Object.hash(
    key,
    label,
    description,
    icon,
    defaultMethod,
    lastFour,
    expiryDate,
    logo,
  );

  @override
  String toString() =>
      'OiPaymentMethod(key: $key, label: $label, defaultMethod: $defaultMethod)';
}

/// Sentinel used by [OiPaymentMethod.copyWith] to distinguish an explicit
/// `null` from "not provided".
const Object _sentinel = Object();
