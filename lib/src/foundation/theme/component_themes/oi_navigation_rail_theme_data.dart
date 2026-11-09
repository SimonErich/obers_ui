import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiNavigationRail;
import 'package:obers_ui/src/components/navigation/oi_navigation_rail.dart'
    show OiNavigationRail;

/// Theme overrides for [OiNavigationRail].
///
/// Controls the visual appearance of the vertical navigation rail including
/// icon colors, label styles, indicator, and border.
///
/// {@category Foundation}
@immutable
class OiNavigationRailThemeData {
  /// Creates an [OiNavigationRailThemeData].
  const OiNavigationRailThemeData({
    this.indicatorShape,
    this.itemWidth,
    this.itemHeight,
    this.width,
    this.backgroundColor,
    this.indicatorColor,
    this.selectedIconColor,
    this.unselectedIconColor,
    this.hoverIconColor,
    this.hoverColor,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.hoverLabelStyle,
    this.iconSize,
    this.itemSpacing,
    this.itemPadding,
    this.borderColor,
    this.borderWidth,
  });

  /// Shape of the selected destination.
  final ShapeBorder? indicatorShape;

  /// Width of the destination indicator; defaults to 56.
  final double? itemWidth;

  /// Height of the destination indicator; defaults to 32.
  final double? itemHeight;

  /// Width of the rail. Default: 72.
  final double? width;

  /// Background color of the rail.
  final Color? backgroundColor;

  /// Background color of the selected-item indicator.
  final Color? indicatorColor;

  /// Icon color for the selected item.
  final Color? selectedIconColor;

  /// Icon color for unselected items.
  final Color? unselectedIconColor;

  /// Icon color for a hovered, unselected destination.
  ///
  /// Defaults to [unselectedIconColor] when configured, then the primary color.
  /// Selection colors are not reused: their contrast depends on the selected
  /// indicator, which is absent for an unselected destination.
  final Color? hoverIconColor;

  /// Background of a hovered, unselected destination's icon area.
  ///
  /// Defaults to transparent. Selected destinations retain [indicatorColor].
  final Color? hoverColor;

  /// Text style for the selected item label.
  final TextStyle? selectedLabelStyle;

  /// Text style for unselected item labels.
  final TextStyle? unselectedLabelStyle;

  /// Text style for a hovered, unselected destination.
  ///
  /// Merges over [unselectedLabelStyle] so its configured contrast is preserved.
  final TextStyle? hoverLabelStyle;

  /// Size of destination icons. Default: 24.
  final double? iconSize;

  /// Vertical spacing between destination items.
  final double? itemSpacing;

  /// Padding around each destination item.
  final EdgeInsets? itemPadding;

  /// Color of the right-side border.
  final Color? borderColor;

  /// Width of the right-side border. Set to 0 for no border.
  final double? borderWidth;

  /// Creates a copy with optionally overridden values.
  OiNavigationRailThemeData copyWith({
    ShapeBorder? indicatorShape,
    double? itemWidth,
    double? itemHeight,
    double? width,
    Color? backgroundColor,
    Color? indicatorColor,
    Color? selectedIconColor,
    Color? unselectedIconColor,
    Color? hoverIconColor,
    Color? hoverColor,
    TextStyle? selectedLabelStyle,
    TextStyle? unselectedLabelStyle,
    TextStyle? hoverLabelStyle,
    double? iconSize,
    double? itemSpacing,
    EdgeInsets? itemPadding,
    Color? borderColor,
    double? borderWidth,
  }) {
    return OiNavigationRailThemeData(
      indicatorShape: indicatorShape ?? this.indicatorShape,
      itemWidth: itemWidth ?? this.itemWidth,
      itemHeight: itemHeight ?? this.itemHeight,
      width: width ?? this.width,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      selectedIconColor: selectedIconColor ?? this.selectedIconColor,
      unselectedIconColor: unselectedIconColor ?? this.unselectedIconColor,
      hoverIconColor: hoverIconColor ?? this.hoverIconColor,
      hoverColor: hoverColor ?? this.hoverColor,
      selectedLabelStyle: selectedLabelStyle ?? this.selectedLabelStyle,
      unselectedLabelStyle: unselectedLabelStyle ?? this.unselectedLabelStyle,
      hoverLabelStyle: hoverLabelStyle ?? this.hoverLabelStyle,
      iconSize: iconSize ?? this.iconSize,
      itemSpacing: itemSpacing ?? this.itemSpacing,
      itemPadding: itemPadding ?? this.itemPadding,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiNavigationRailThemeData &&
        other.itemHeight == itemHeight &&
        other.itemWidth == itemWidth &&
        other.indicatorShape == indicatorShape &&
        other.width == width &&
        other.backgroundColor == backgroundColor &&
        other.indicatorColor == indicatorColor &&
        other.selectedIconColor == selectedIconColor &&
        other.unselectedIconColor == unselectedIconColor &&
        other.hoverIconColor == hoverIconColor &&
        other.hoverColor == hoverColor &&
        other.selectedLabelStyle == selectedLabelStyle &&
        other.unselectedLabelStyle == unselectedLabelStyle &&
        other.hoverLabelStyle == hoverLabelStyle &&
        other.iconSize == iconSize &&
        other.itemSpacing == itemSpacing &&
        other.itemPadding == itemPadding &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth;
  }

  @override
  int get hashCode => Object.hash(
    indicatorShape,
    itemWidth,
    itemHeight,
    width,
    backgroundColor,
    indicatorColor,
    selectedIconColor,
    unselectedIconColor,
    hoverIconColor,
    hoverColor,
    selectedLabelStyle,
    unselectedLabelStyle,
    hoverLabelStyle,
    iconSize,
    itemSpacing,
    itemPadding,
    borderColor,
    borderWidth,
  );
}
