import 'package:flutter/foundation.dart';

/// A global scale defining interactive component heights.
///
/// Provides consistent sizing for buttons, inputs, selects, and other
/// interactive elements. All values are in logical pixels.
///
/// {@category Foundation}
@immutable
class OiComponentSizeScale {
  /// Creates an [OiComponentSizeScale] with explicit values.
  const OiComponentSizeScale({
    this.small = 28,
    this.medium = 36,
    this.large = 44,
  });

  /// Arco Design sizing (compact): 28 / 32 / 36.
  const OiComponentSizeScale.arco() : small = 28, medium = 32, large = 36;

  /// Standard obers_ui sizing: 28 / 36 / 44.
  const OiComponentSizeScale.standard() : small = 28, medium = 36, large = 44;

  /// Height for small-size interactive components.
  final double small;

  /// Height for medium-size (default) interactive components.
  final double medium;

  /// Height for large-size interactive components.
  final double large;

  /// Creates a copy with optionally overridden values.
  OiComponentSizeScale copyWith({
    double? small,
    double? medium,
    double? large,
  }) {
    return OiComponentSizeScale(
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiComponentSizeScale &&
        other.small == small &&
        other.medium == medium &&
        other.large == large;
  }

  @override
  int get hashCode => Object.hash(small, medium, large);
}
