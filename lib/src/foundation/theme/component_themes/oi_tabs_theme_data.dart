import 'package:flutter/widgets.dart';

/// Theme data for tab-bar components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiTabsThemeData {
  /// Creates an [OiTabsThemeData].
  const OiTabsThemeData({this.indicatorColor, this.height});

  /// The color of the active-tab indicator bar or highlight.
  final Color? indicatorColor;

  /// The height of the tab bar in logical pixels.
  final double? height;

  /// Creates a copy with optionally overridden values.
  OiTabsThemeData copyWith({Color? indicatorColor, double? height}) {
    return OiTabsThemeData(
      indicatorColor: indicatorColor ?? this.indicatorColor,
      height: height ?? this.height,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiTabsThemeData &&
        other.indicatorColor == indicatorColor &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(indicatorColor, height);
}
