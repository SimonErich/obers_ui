import 'package:flutter/widgets.dart';

/// Theme data for toast / snackbar components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiToastThemeData {
  /// Creates an [OiToastThemeData].
  const OiToastThemeData({this.borderRadius, this.elevation});

  /// The corner radius of the toast surface.
  final BorderRadius? borderRadius;

  /// The elevation (shadow depth) of the toast.
  final double? elevation;

  /// Creates a copy with optionally overridden values.
  OiToastThemeData copyWith({BorderRadius? borderRadius, double? elevation}) {
    return OiToastThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiToastThemeData &&
        other.borderRadius == borderRadius &&
        other.elevation == elevation;
  }

  @override
  int get hashCode => Object.hash(borderRadius, elevation);
}
