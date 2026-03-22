import 'package:flutter/foundation.dart';
import 'package:obers_ui/obers_ui.dart' show OiCouponInput;

/// The result of applying a coupon code.
///
/// Coverage: REQ-0032
///
/// Returned by the `onApply` callback in [OiCouponInput] to indicate whether
/// the code was accepted, an optional user-facing [message], and the
/// [discountAmount] when known.
///
/// {@category Models}
@immutable
class OiCouponResult {
  /// Creates an [OiCouponResult].
  const OiCouponResult({
    required this.valid,
    this.message,
    this.discountAmount,
  });

  /// Whether the coupon code was accepted.
  final bool valid;

  /// Optional user-facing message (e.g. '20% off applied!' or 'Invalid code').
  final String? message;

  /// The discount amount when the code is valid.
  final double? discountAmount;

  /// Returns a copy with the specified fields replaced.
  OiCouponResult copyWith({
    bool? valid,
    Object? message = _sentinel,
    Object? discountAmount = _sentinel,
  }) {
    return OiCouponResult(
      valid: valid ?? this.valid,
      message: identical(message, _sentinel)
          ? this.message
          : message as String?,
      discountAmount: identical(discountAmount, _sentinel)
          ? this.discountAmount
          : discountAmount as double?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiCouponResult) return false;
    return valid == other.valid &&
        message == other.message &&
        discountAmount == other.discountAmount;
  }

  @override
  int get hashCode => Object.hash(valid, message, discountAmount);

  @override
  String toString() =>
      'OiCouponResult(valid: $valid, message: $message, '
      'discountAmount: $discountAmount)';
}

/// Sentinel used by [OiCouponResult.copyWith] to distinguish an explicit `null`
/// from "not provided".
const Object _sentinel = Object();
