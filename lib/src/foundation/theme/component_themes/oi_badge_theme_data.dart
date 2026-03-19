import 'package:flutter/widgets.dart';

/// Theme data for badge components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiBadgeThemeData {
  /// Creates an [OiBadgeThemeData].
  const OiBadgeThemeData({this.borderRadius});

  /// The corner radius of the badge pill shape.
  final BorderRadius? borderRadius;

  /// Creates a copy with optionally overridden values.
  OiBadgeThemeData copyWith({BorderRadius? borderRadius}) {
    return OiBadgeThemeData(borderRadius: borderRadius ?? this.borderRadius);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiBadgeThemeData && other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => borderRadius.hashCode;
}
