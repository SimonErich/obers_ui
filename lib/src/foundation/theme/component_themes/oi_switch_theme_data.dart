import 'package:flutter/widgets.dart';

/// Theme data for toggle-switch components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiSwitchThemeData {
  /// Creates an [OiSwitchThemeData].
  const OiSwitchThemeData({this.width, this.height});

  /// The total width of the switch track in logical pixels.
  final double? width;

  /// The total height of the switch track in logical pixels.
  final double? height;

  /// Creates a copy with optionally overridden values.
  OiSwitchThemeData copyWith({double? width, double? height}) {
    return OiSwitchThemeData(
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiSwitchThemeData &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(width, height);
}
