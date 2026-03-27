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
  const OiBadgeThemeData({
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.height,
  });

  /// The corner radius of the badge pill shape.
  final BorderRadius? borderRadius;

  /// Internal padding of the badge content.
  final EdgeInsets? padding;

  /// Text style for the badge label.
  final TextStyle? textStyle;

  /// Fixed height for badges.
  final double? height;

  /// Creates a copy with optionally overridden values.
  OiBadgeThemeData copyWith({
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    TextStyle? textStyle,
    double? height,
  }) {
    return OiBadgeThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
      height: height ?? this.height,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiBadgeThemeData &&
        other.borderRadius == borderRadius &&
        other.padding == padding &&
        other.textStyle == textStyle &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(borderRadius, padding, textStyle, height);
}
