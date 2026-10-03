import 'package:flutter/widgets.dart';

/// Theme overrides for sidebar navigation.
///
/// Explicit widget properties override these values. Null uses semantic defaults.
@immutable
class OiSidebarThemeData {
  /// Creates theme overrides for sidebar.
  const OiSidebarThemeData({
    this.width,
    this.headerHeight,
    this.headerPadding,
    this.headerTextStyle,
    this.compactWidth,
    this.itemHeight,
    this.itemSpacing,
    this.labelGap,
    this.iconSize,
    this.iconWidth,
    this.itemPadding,
    this.padding,
    this.itemRadius,
    this.backgroundColor,
    this.selectedBackground,
    this.selectedForeground,
    this.selectedIconColor,
    this.selectedBorderColor,
    this.contextBranchColor,
    this.foreground,
    this.iconColor,
    this.textStyle,
    this.selectedTextStyle,
    this.plainBadges,
    this.badgeTextStyle,
  });

  /// Expanded width; defaults to 260.
  final double? width;

  /// Minimum workspace heading height, including its insets; defaults to 64.
  final double? headerHeight;

  /// Insets around a workspace heading and its trailing action.
  final EdgeInsetsGeometry? headerPadding;

  /// Typography of the workspace heading.
  final TextStyle? headerTextStyle;

  /// Collapsed width; defaults to 64.
  final double? compactWidth;

  /// Minimum navigation row height; defaults to 40.
  final double? itemHeight;

  /// Vertical space between destinations; defaults to zero.
  final double? itemSpacing;

  /// Space between the leading icon area and label; defaults to zero.
  final double? labelGap;

  /// Destination icon size; defaults to 20.
  final double? iconSize;

  /// Width allocated to the icon.
  final double? iconWidth;

  /// Insets inside each item.
  final EdgeInsetsGeometry? itemPadding;

  /// Insets around navigation items.
  final EdgeInsetsGeometry? padding;

  /// Navigation item corner radius.
  final BorderRadius? itemRadius;

  /// Sidebar background.
  final Color? backgroundColor;

  /// Selected item fill.
  final Color? selectedBackground;

  /// Selected text and icon color.
  final Color? selectedForeground;

  /// Selected icon color, independent of the destination label.
  final Color? selectedIconColor;

  /// Optional outline around the selected destination.
  final Color? selectedBorderColor;

  /// Decorative contextual branch stroke; null uses the subtle border role.
  final Color? contextBranchColor;

  /// Ordinary text color.
  final Color? foreground;

  /// Ordinary icon color.
  final Color? iconColor;

  /// Destination text style.
  final TextStyle? textStyle;

  /// Selected destination text style.
  final TextStyle? selectedTextStyle;

  /// Shows counts as plain text instead of filled badges; defaults to false.
  final bool? plainBadges;

  /// Typography for plain count labels.
  final TextStyle? badgeTextStyle;

  /// Returns a copy with the supplied overrides.
  OiSidebarThemeData copyWith({
    double? width,
    double? headerHeight,
    EdgeInsetsGeometry? headerPadding,
    TextStyle? headerTextStyle,
    double? compactWidth,
    double? itemHeight,
    double? itemSpacing,
    double? labelGap,
    double? iconSize,
    double? iconWidth,
    EdgeInsetsGeometry? itemPadding,
    EdgeInsetsGeometry? padding,
    BorderRadius? itemRadius,
    Color? backgroundColor,
    Color? selectedBackground,
    Color? selectedForeground,
    Color? selectedIconColor,
    Color? selectedBorderColor,
    Color? contextBranchColor,
    Color? foreground,
    Color? iconColor,
    TextStyle? textStyle,
    TextStyle? selectedTextStyle,
    bool? plainBadges,
    TextStyle? badgeTextStyle,
  }) => OiSidebarThemeData(
    width: width ?? this.width,
    headerHeight: headerHeight ?? this.headerHeight,
    headerPadding: headerPadding ?? this.headerPadding,
    headerTextStyle: headerTextStyle ?? this.headerTextStyle,
    compactWidth: compactWidth ?? this.compactWidth,
    itemHeight: itemHeight ?? this.itemHeight,
    itemSpacing: itemSpacing ?? this.itemSpacing,
    labelGap: labelGap ?? this.labelGap,
    iconSize: iconSize ?? this.iconSize,
    iconWidth: iconWidth ?? this.iconWidth,
    itemPadding: itemPadding ?? this.itemPadding,
    padding: padding ?? this.padding,
    itemRadius: itemRadius ?? this.itemRadius,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    selectedBackground: selectedBackground ?? this.selectedBackground,
    selectedForeground: selectedForeground ?? this.selectedForeground,
    selectedIconColor: selectedIconColor ?? this.selectedIconColor,
    selectedBorderColor: selectedBorderColor ?? this.selectedBorderColor,
    contextBranchColor: contextBranchColor ?? this.contextBranchColor,
    foreground: foreground ?? this.foreground,
    iconColor: iconColor ?? this.iconColor,
    textStyle: textStyle ?? this.textStyle,
    selectedTextStyle: selectedTextStyle ?? this.selectedTextStyle,
    plainBadges: plainBadges ?? this.plainBadges,
    badgeTextStyle: badgeTextStyle ?? this.badgeTextStyle,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiSidebarThemeData &&
          other.width == width &&
          other.headerHeight == headerHeight &&
          other.headerPadding == headerPadding &&
          other.headerTextStyle == headerTextStyle &&
          other.compactWidth == compactWidth &&
          other.itemHeight == itemHeight &&
          other.itemSpacing == itemSpacing &&
          other.labelGap == labelGap &&
          other.iconSize == iconSize &&
          other.iconWidth == iconWidth &&
          other.itemPadding == itemPadding &&
          other.padding == padding &&
          other.itemRadius == itemRadius &&
          other.backgroundColor == backgroundColor &&
          other.selectedBackground == selectedBackground &&
          other.selectedForeground == selectedForeground &&
          other.selectedIconColor == selectedIconColor &&
          other.selectedBorderColor == selectedBorderColor &&
          other.contextBranchColor == contextBranchColor &&
          other.foreground == foreground &&
          other.iconColor == iconColor &&
          other.textStyle == textStyle &&
          other.selectedTextStyle == selectedTextStyle &&
          other.plainBadges == plainBadges &&
          other.badgeTextStyle == badgeTextStyle;

  @override
  int get hashCode => Object.hashAll([
    width,
    headerHeight,
    headerPadding,
    headerTextStyle,
    compactWidth,
    itemHeight,
    itemSpacing,
    labelGap,
    iconSize,
    iconWidth,
    itemPadding,
    padding,
    itemRadius,
    backgroundColor,
    selectedBackground,
    selectedForeground,
    selectedIconColor,
    selectedBorderColor,
    contextBranchColor,
    foreground,
    iconColor,
    textStyle,
    selectedTextStyle,
    plainBadges,
    badgeTextStyle,
  ]);
}
