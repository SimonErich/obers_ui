import 'package:flutter/widgets.dart';

/// Theme data for tooltip components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiTooltipThemeData {
  /// Creates an [OiTooltipThemeData].
  const OiTooltipThemeData({this.borderRadius, this.padding});

  /// The corner radius of the tooltip surface.
  final BorderRadius? borderRadius;

  /// The internal padding of the tooltip content.
  final EdgeInsets? padding;

  /// Creates a copy with optionally overridden values.
  OiTooltipThemeData copyWith({
    BorderRadius? borderRadius,
    EdgeInsets? padding,
  }) {
    return OiTooltipThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiTooltipThemeData &&
        other.borderRadius == borderRadius &&
        other.padding == padding;
  }

  @override
  int get hashCode => Object.hash(borderRadius, padding);
}
