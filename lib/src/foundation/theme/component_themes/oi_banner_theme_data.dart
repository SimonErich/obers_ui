import 'package:flutter/widgets.dart';

/// Theme data for banner components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiBannerThemeData {
  /// Creates an [OiBannerThemeData].
  const OiBannerThemeData({
    this.borderRadius,
    this.padding,
    this.iconSize,
    this.animationDuration,
    this.animationCurve,
  });

  /// The corner radius of the banner.
  final BorderRadius? borderRadius;

  /// The internal padding of the banner.
  final EdgeInsetsGeometry? padding;

  /// The size of the leading severity icon.
  final double? iconSize;

  /// The duration of the show/dismiss animation.
  final Duration? animationDuration;

  /// The curve used for the show/dismiss animation.
  final Curve? animationCurve;

  /// Creates a copy with optionally overridden values.
  OiBannerThemeData copyWith({
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    double? iconSize,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return OiBannerThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      iconSize: iconSize ?? this.iconSize,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiBannerThemeData &&
        other.borderRadius == borderRadius &&
        other.padding == padding &&
        other.iconSize == iconSize &&
        other.animationDuration == animationDuration &&
        other.animationCurve == animationCurve;
  }

  @override
  int get hashCode => Object.hash(
    borderRadius,
    padding,
    iconSize,
    animationDuration,
    animationCurve,
  );
}
