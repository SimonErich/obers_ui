import 'package:flutter/widgets.dart';

/// Theme data for tab-bar components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiTabsThemeData {
  /// Creates an [OiTabsThemeData].
  const OiTabsThemeData({
    this.indicatorColor,
    this.height,
    this.indicatorThickness,
    this.labelStyle,
    this.activeLabelColor,
    this.inactiveLabelColor,
    this.tabPadding,
  });

  /// The color of the active-tab indicator bar or highlight.
  final Color? indicatorColor;

  /// The height of the tab bar in logical pixels.
  final double? height;

  /// The thickness of the indicator bar in logical pixels.
  final double? indicatorThickness;

  /// Text style for tab labels.
  final TextStyle? labelStyle;

  /// Text color for the active (selected) tab label.
  final Color? activeLabelColor;

  /// Text color for inactive tab labels.
  final Color? inactiveLabelColor;

  /// Internal padding within each tab.
  final EdgeInsets? tabPadding;

  /// Creates a copy with optionally overridden values.
  OiTabsThemeData copyWith({
    Color? indicatorColor,
    double? height,
    double? indicatorThickness,
    TextStyle? labelStyle,
    Color? activeLabelColor,
    Color? inactiveLabelColor,
    EdgeInsets? tabPadding,
  }) {
    return OiTabsThemeData(
      indicatorColor: indicatorColor ?? this.indicatorColor,
      height: height ?? this.height,
      indicatorThickness: indicatorThickness ?? this.indicatorThickness,
      labelStyle: labelStyle ?? this.labelStyle,
      activeLabelColor: activeLabelColor ?? this.activeLabelColor,
      inactiveLabelColor: inactiveLabelColor ?? this.inactiveLabelColor,
      tabPadding: tabPadding ?? this.tabPadding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiTabsThemeData &&
        other.indicatorColor == indicatorColor &&
        other.height == height &&
        other.indicatorThickness == indicatorThickness &&
        other.labelStyle == labelStyle &&
        other.activeLabelColor == activeLabelColor &&
        other.inactiveLabelColor == inactiveLabelColor &&
        other.tabPadding == tabPadding;
  }

  @override
  int get hashCode => Object.hash(
    indicatorColor,
    height,
    indicatorThickness,
    labelStyle,
    activeLabelColor,
    inactiveLabelColor,
    tabPadding,
  );
}
