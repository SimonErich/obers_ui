import 'package:flutter/foundation.dart';

/// A payment method option displayed during checkout.
///
/// Coverage: REQ-0067
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
    this.isDefault = false,
  });

  /// Unique identifier for this payment method.
  final String key;

  /// Human-readable label (e.g. "Credit Card").
  final String label;

  /// Optional description (e.g. "Visa ending in 4242").
  final String? description;

  /// Optional icon identifier (e.g. a card brand name).
  final String? icon;

  /// Whether this is the default / pre-selected payment method.
  final bool isDefault;

  /// Returns a copy with the specified fields replaced.
  OiPaymentMethod copyWith({
    String? key,
    String? label,
    Object? description = _sentinel,
    Object? icon = _sentinel,
    bool? isDefault,
  }) {
    return OiPaymentMethod(
      key: key ?? this.key,
      label: label ?? this.label,
      description:
          identical(description, _sentinel)
              ? this.description
              : description as String?,
      icon: identical(icon, _sentinel) ? this.icon : icon as String?,
      isDefault: isDefault ?? this.isDefault,
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
        isDefault == other.isDefault;
  }

  @override
  int get hashCode => Object.hash(key, label, description, icon, isDefault);

  @override
  String toString() =>
      'OiPaymentMethod(key: $key, label: $label, isDefault: $isDefault)';
}

/// Sentinel used by [OiPaymentMethod.copyWith] to distinguish an explicit
/// `null` from "not provided".
const Object _sentinel = Object();
