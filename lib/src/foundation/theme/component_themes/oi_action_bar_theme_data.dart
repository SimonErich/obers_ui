import 'package:flutter/widgets.dart';

/// Theme data for action bar components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiActionBarThemeData {
  /// Creates an [OiActionBarThemeData].
  const OiActionBarThemeData({
    this.spacing,
    this.padding,
    this.menuPadding,
    this.menuItemPadding,
    this.menuMinWidth,
    this.menuIconGap,
    this.menuRadius,
    this.menuItemRadius,
  });

  /// The spacing between action buttons.
  final double? spacing;

  /// The internal padding of the action bar.
  final EdgeInsetsGeometry? padding;

  /// Inset around overflow-menu items.
  final EdgeInsetsGeometry? menuPadding;

  /// Inset inside each overflow action.
  final EdgeInsetsGeometry? menuItemPadding;

  /// Minimum overflow-menu width.
  final double? menuMinWidth;

  /// Space between an overflow action's icon and label.
  final double? menuIconGap;

  /// Overflow-menu surface corners.
  final BorderRadius? menuRadius;

  /// Overflow-action hover and focus corners.
  final BorderRadius? menuItemRadius;

  /// Creates a copy with optionally overridden values.
  OiActionBarThemeData copyWith({
    double? spacing,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? menuPadding,
    EdgeInsetsGeometry? menuItemPadding,
    double? menuMinWidth,
    double? menuIconGap,
    BorderRadius? menuRadius,
    BorderRadius? menuItemRadius,
  }) {
    return OiActionBarThemeData(
      spacing: spacing ?? this.spacing,
      padding: padding ?? this.padding,
      menuPadding: menuPadding ?? this.menuPadding,
      menuItemPadding: menuItemPadding ?? this.menuItemPadding,
      menuMinWidth: menuMinWidth ?? this.menuMinWidth,
      menuIconGap: menuIconGap ?? this.menuIconGap,
      menuRadius: menuRadius ?? this.menuRadius,
      menuItemRadius: menuItemRadius ?? this.menuItemRadius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiActionBarThemeData &&
        other.spacing == spacing &&
        other.padding == padding &&
        other.menuPadding == menuPadding &&
        other.menuItemPadding == menuItemPadding &&
        other.menuMinWidth == menuMinWidth &&
        other.menuIconGap == menuIconGap &&
        other.menuRadius == menuRadius &&
        other.menuItemRadius == menuItemRadius;
  }

  @override
  int get hashCode => Object.hash(
    spacing,
    padding,
    menuPadding,
    menuItemPadding,
    menuMinWidth,
    menuIconGap,
    menuRadius,
    menuItemRadius,
  );
}
