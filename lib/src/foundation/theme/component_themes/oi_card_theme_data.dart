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
  const OiCardThemeData({
    this.borderRadius,
    this.elevation,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.shadow,
  });

  /// The corner radius of the card surface.
  final BorderRadius? borderRadius;

  /// The elevation (shadow depth) of the card.
  final double? elevation;

  /// The internal padding of the card content area.
  final EdgeInsets? padding;

  /// Background color override for the card surface.
  final Color? backgroundColor;

  /// Border color for outlined card variants.
  final Color? borderColor;

  /// Border width for outlined card variants.
  final double? borderWidth;

  /// Explicit shadow override (takes precedence over [elevation]).
  final List<BoxShadow>? shadow;

  /// Creates a copy with optionally overridden values.
  OiCardThemeData copyWith({
    BorderRadius? borderRadius,
    double? elevation,
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    List<BoxShadow>? shadow,
  }) {
    return OiCardThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      padding: padding ?? this.padding,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiCardThemeData) return false;
    if (shadow != null && other.shadow != null) {
      if (shadow!.length != other.shadow!.length) return false;
      for (var i = 0; i < shadow!.length; i++) {
        if (shadow![i] != other.shadow![i]) return false;
      }
    } else if (shadow != other.shadow) {
      return false;
    }
    return other.borderRadius == borderRadius &&
        other.elevation == elevation &&
        other.padding == padding &&
        other.backgroundColor == backgroundColor &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth;
  }

  @override
  int get hashCode => Object.hash(
    borderRadius,
    elevation,
    padding,
    backgroundColor,
    borderColor,
    borderWidth,
    shadow != null ? Object.hashAll(shadow!) : null,
  );
}
