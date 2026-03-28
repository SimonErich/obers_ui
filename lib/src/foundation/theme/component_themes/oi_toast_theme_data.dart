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
  const OiToastThemeData({
    this.borderRadius,
    this.elevation,
    this.padding,
    this.iconSize,
    this.gap,
    this.backgroundColor,
    this.shadow,
  });

  /// The corner radius of the toast surface.
  final BorderRadius? borderRadius;

  /// The elevation (shadow depth) of the toast.
  final double? elevation;

  /// Internal padding of the toast content.
  final EdgeInsets? padding;

  /// Size of the status icon.
  final double? iconSize;

  /// Gap between the icon and message text.
  final double? gap;

  /// Background color override.
  final Color? backgroundColor;

  /// Explicit shadow override (takes precedence over [elevation]).
  final List<BoxShadow>? shadow;

  /// Creates a copy with optionally overridden values.
  OiToastThemeData copyWith({
    BorderRadius? borderRadius,
    double? elevation,
    EdgeInsets? padding,
    double? iconSize,
    double? gap,
    Color? backgroundColor,
    List<BoxShadow>? shadow,
  }) {
    return OiToastThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      padding: padding ?? this.padding,
      iconSize: iconSize ?? this.iconSize,
      gap: gap ?? this.gap,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiToastThemeData) return false;
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
        other.iconSize == iconSize &&
        other.gap == gap &&
        other.backgroundColor == backgroundColor;
  }

  @override
  int get hashCode => Object.hash(
    borderRadius,
    elevation,
    padding,
    iconSize,
    gap,
    backgroundColor,
    shadow != null ? Object.hashAll(shadow!) : null,
  );
}
