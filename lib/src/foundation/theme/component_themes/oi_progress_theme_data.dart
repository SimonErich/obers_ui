import 'package:flutter/widgets.dart';

/// Theme data for linear- and circular-progress components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiProgressThemeData {
  /// Creates an [OiProgressThemeData].
  const OiProgressThemeData({this.height, this.borderRadius});

  /// The height of the linear progress track in logical pixels.
  final double? height;

  /// The corner radius of the linear progress track.
  final BorderRadius? borderRadius;

  /// Creates a copy with optionally overridden values.
  OiProgressThemeData copyWith({double? height, BorderRadius? borderRadius}) {
    return OiProgressThemeData(
      height: height ?? this.height,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiProgressThemeData &&
        other.height == height &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => Object.hash(height, borderRadius);
}
