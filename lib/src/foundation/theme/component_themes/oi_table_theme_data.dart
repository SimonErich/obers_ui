import 'package:flutter/widgets.dart';

/// Theme overrides for data tables.
///
/// Explicit widget properties override these values. Null uses semantic defaults.
@immutable
class OiTableThemeData {
  /// Creates theme overrides for table.
  const OiTableThemeData({
    this.headerHeight,
    this.rowHeight,
    this.borderColor,
    this.headerBackground,
    this.selectedBackground,
    this.hoverBackground,
    this.headerTextStyle,
    this.cellTextStyle,
    this.cellPadding,
    this.rowBorderRadius,
  });

  /// Table header row height.
  final double? headerHeight;

  /// Data row height.
  final double? rowHeight;

  /// Row and column border color.
  final Color? borderColor;

  /// Header surface.
  final Color? headerBackground;

  /// Selected row surface.
  final Color? selectedBackground;

  /// Hovered row surface.
  final Color? hoverBackground;

  /// Header text style.
  final TextStyle? headerTextStyle;

  /// Default cell text style.
  final TextStyle? cellTextStyle;

  /// Cell content insets.
  final EdgeInsetsGeometry? cellPadding;

  /// Corners for row selection, hover and stripe surfaces.
  final BorderRadius? rowBorderRadius;

  /// Returns a copy with the supplied overrides.
  OiTableThemeData copyWith({
    double? headerHeight,
    double? rowHeight,
    Color? borderColor,
    Color? headerBackground,
    Color? selectedBackground,
    Color? hoverBackground,
    TextStyle? headerTextStyle,
    TextStyle? cellTextStyle,
    EdgeInsetsGeometry? cellPadding,
    BorderRadius? rowBorderRadius,
  }) => OiTableThemeData(
    headerHeight: headerHeight ?? this.headerHeight,
    rowHeight: rowHeight ?? this.rowHeight,
    borderColor: borderColor ?? this.borderColor,
    headerBackground: headerBackground ?? this.headerBackground,
    selectedBackground: selectedBackground ?? this.selectedBackground,
    hoverBackground: hoverBackground ?? this.hoverBackground,
    headerTextStyle: headerTextStyle ?? this.headerTextStyle,
    cellTextStyle: cellTextStyle ?? this.cellTextStyle,
    cellPadding: cellPadding ?? this.cellPadding,
    rowBorderRadius: rowBorderRadius ?? this.rowBorderRadius,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiTableThemeData &&
          other.headerHeight == headerHeight &&
          other.rowHeight == rowHeight &&
          other.borderColor == borderColor &&
          other.headerBackground == headerBackground &&
          other.selectedBackground == selectedBackground &&
          other.hoverBackground == hoverBackground &&
          other.headerTextStyle == headerTextStyle &&
          other.cellTextStyle == cellTextStyle &&
          other.cellPadding == cellPadding &&
          other.rowBorderRadius == rowBorderRadius;

  @override
  int get hashCode => Object.hashAll([
    headerHeight,
    rowHeight,
    borderColor,
    headerBackground,
    selectedBackground,
    hoverBackground,
    headerTextStyle,
    cellTextStyle,
    cellPadding,
    rowBorderRadius,
  ]);
}
