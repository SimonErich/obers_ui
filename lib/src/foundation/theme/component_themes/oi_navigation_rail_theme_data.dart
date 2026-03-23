import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiNavigationRail;
import 'package:obers_ui/src/components/navigation/oi_navigation_rail.dart' show OiNavigationRail;

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
    this.width,
    this.backgroundColor,
    this.indicatorColor,
    this.selectedIconColor,
    this.unselectedIconColor,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.iconSize,
    this.itemSpacing,
    this.itemPadding,
    this.borderColor,
    this.borderWidth,
  });

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

  /// Text style for the selected item label.
  final TextStyle? selectedLabelStyle;

  /// Text style for unselected item labels.
  final TextStyle? unselectedLabelStyle;

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
    double? width,
    Color? backgroundColor,
    Color? indicatorColor,
    Color? selectedIconColor,
    Color? unselectedIconColor,
    TextStyle? selectedLabelStyle,
    TextStyle? unselectedLabelStyle,
    double? iconSize,
    double? itemSpacing,
    EdgeInsets? itemPadding,
    Color? borderColor,
    double? borderWidth,
  }) {
    return OiNavigationRailThemeData(
      width: width ?? this.width,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      selectedIconColor: selectedIconColor ?? this.selectedIconColor,
      unselectedIconColor: unselectedIconColor ?? this.unselectedIconColor,
      selectedLabelStyle: selectedLabelStyle ?? this.selectedLabelStyle,
      unselectedLabelStyle:
          unselectedLabelStyle ?? this.unselectedLabelStyle,
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
        other.width == width &&
        other.backgroundColor == backgroundColor &&
        other.indicatorColor == indicatorColor &&
        other.selectedIconColor == selectedIconColor &&
        other.unselectedIconColor == unselectedIconColor &&
        other.selectedLabelStyle == selectedLabelStyle &&
        other.unselectedLabelStyle == unselectedLabelStyle &&
        other.iconSize == iconSize &&
        other.itemSpacing == itemSpacing &&
        other.itemPadding == itemPadding &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth;
  }

  @override
  int get hashCode => Object.hash(
        width,
        backgroundColor,
        indicatorColor,
        selectedIconColor,
        unselectedIconColor,
        selectedLabelStyle,
        unselectedLabelStyle,
        iconSize,
        itemSpacing,
        itemPadding,
        borderColor,
        borderWidth,
      );
}
