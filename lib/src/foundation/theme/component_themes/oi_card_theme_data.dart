import 'package:flutter/widgets.dart';

/// Theme data for card components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiCardThemeData {
  /// Creates an [OiCardThemeData].
  const OiCardThemeData({this.borderRadius, this.elevation, this.padding});

  /// The corner radius of the card surface.
  final BorderRadius? borderRadius;

  /// The elevation (shadow depth) of the card.
  final double? elevation;

  /// The internal padding of the card content area.
  final EdgeInsets? padding;

  /// Creates a copy with optionally overridden values.
  OiCardThemeData copyWith({
    BorderRadius? borderRadius,
    double? elevation,
    EdgeInsets? padding,
  }) {
    return OiCardThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      padding: padding ?? this.padding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiCardThemeData &&
        other.borderRadius == borderRadius &&
        other.elevation == elevation &&
        other.padding == padding;
  }

  @override
  int get hashCode => Object.hash(borderRadius, elevation, padding);
}
