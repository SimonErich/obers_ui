import 'package:flutter/widgets.dart';

/// Theme data for checkbox components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiCheckboxThemeData {
  /// Creates an [OiCheckboxThemeData].
  const OiCheckboxThemeData({this.size, this.borderRadius});

  /// The width and height of the checkbox in logical pixels.
  final double? size;

  /// The corner radius of the checkbox border.
  final BorderRadius? borderRadius;

  /// Creates a copy with optionally overridden values.
  OiCheckboxThemeData copyWith({double? size, BorderRadius? borderRadius}) {
    return OiCheckboxThemeData(
      size: size ?? this.size,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiCheckboxThemeData &&
        other.size == size &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => Object.hash(size, borderRadius);
}
