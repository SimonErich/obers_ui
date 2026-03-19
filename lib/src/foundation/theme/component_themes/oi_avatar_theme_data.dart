import 'package:flutter/widgets.dart';

/// Theme data for avatar components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiAvatarThemeData {
  /// Creates an [OiAvatarThemeData].
  const OiAvatarThemeData({this.borderRadius});

  /// The corner radius of the avatar shape.
  ///
  /// Use `BorderRadius.circular(999)` for a fully circular avatar.
  final BorderRadius? borderRadius;

  /// Creates a copy with optionally overridden values.
  OiAvatarThemeData copyWith({BorderRadius? borderRadius}) {
    return OiAvatarThemeData(borderRadius: borderRadius ?? this.borderRadius);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiAvatarThemeData && other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => borderRadius.hashCode;
}
