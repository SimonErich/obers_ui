import 'package:flutter/widgets.dart';

/// Visual tokens for a command/search trigger that opens an overlay.
@immutable
class OiSearchTriggerThemeData {
  /// Null tokens inherit semantic defaults.
  const OiSearchTriggerThemeData({
    this.height,
    this.padding,
    this.decoration,
    this.textStyle,
    this.foreground,
    this.iconSize,
    this.gap,
  });

  /// Control height; defaults to the medium control size.
  final double? height;

  /// Insets around the icon, hint and shortcut.
  final EdgeInsetsGeometry? padding;

  /// Neutral surface, border and shadow. Interaction effects remain shared.
  final BoxDecoration? decoration;

  /// Hint typography, merged over the body role.
  final TextStyle? textStyle;

  /// Hint and search-icon color.
  final Color? foreground;

  /// Search icon size; defaults to 16.
  final double? iconSize;

  /// Space between the icon, hint and shortcut; defaults to 8.
  final double? gap;

  /// Returns these tokens with selected overrides.
  OiSearchTriggerThemeData copyWith({
    double? height,
    EdgeInsetsGeometry? padding,
    BoxDecoration? decoration,
    TextStyle? textStyle,
    Color? foreground,
    double? iconSize,
    double? gap,
  }) => OiSearchTriggerThemeData(
    height: height ?? this.height,
    padding: padding ?? this.padding,
    decoration: decoration ?? this.decoration,
    textStyle: textStyle ?? this.textStyle,
    foreground: foreground ?? this.foreground,
    iconSize: iconSize ?? this.iconSize,
    gap: gap ?? this.gap,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiSearchTriggerThemeData &&
          other.height == height &&
          other.padding == padding &&
          other.decoration == decoration &&
          other.textStyle == textStyle &&
          other.foreground == foreground &&
          other.iconSize == iconSize &&
          other.gap == gap;

  @override
  int get hashCode => Object.hash(
    height,
    padding,
    decoration,
    textStyle,
    foreground,
    iconSize,
    gap,
  );
}
