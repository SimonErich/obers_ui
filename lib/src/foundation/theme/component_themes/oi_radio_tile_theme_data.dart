import 'package:flutter/widgets.dart';

/// Surface and spacing overrides for selectable radio cards.
///
/// Null values retain component defaults.
/// {@category Foundation}
@immutable
class OiRadioTileThemeData {
  /// Creates component overrides.
  const OiRadioTileThemeData({
    this.borderRadius,
    this.borderWidth,
    this.selectedBorderWidth,
    this.borderColor,
    this.selectedBorderColor,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.padding,
    this.minHeight,
    this.controlGap,
    this.bodyGap,
    this.titleStyle,
  });

  /// Card corner radius.
  final BorderRadius? borderRadius;

  /// Unselected outline width.
  final double? borderWidth;

  /// Selected outline width; never changes layout.
  final double? selectedBorderWidth;

  /// Unselected outline color.
  final Color? borderColor;

  /// Selected outline color.
  final Color? selectedBorderColor;

  /// Unselected fill.
  final Color? backgroundColor;

  /// Selected fill.
  final Color? selectedBackgroundColor;

  /// Default card content padding.
  final EdgeInsetsGeometry? padding;

  /// Minimum card height; content can grow freely.
  final double? minHeight;

  /// Space between the selection control and the identity.
  final double? controlGap;

  /// Space between the identity and a separate supporting body.
  final double? bodyGap;

  /// Typography for a card title; null retains the bodyStrong role.
  final TextStyle? titleStyle;

  /// Copies the theme with selected overrides.
  OiRadioTileThemeData copyWith({
    BorderRadius? borderRadius,
    double? borderWidth,
    double? selectedBorderWidth,
    Color? borderColor,
    Color? selectedBorderColor,
    Color? backgroundColor,
    Color? selectedBackgroundColor,
    EdgeInsetsGeometry? padding,
    double? minHeight,
    double? controlGap,
    double? bodyGap,
    TextStyle? titleStyle,
  }) => OiRadioTileThemeData(
    borderRadius: borderRadius ?? this.borderRadius,
    borderWidth: borderWidth ?? this.borderWidth,
    selectedBorderWidth: selectedBorderWidth ?? this.selectedBorderWidth,
    borderColor: borderColor ?? this.borderColor,
    selectedBorderColor: selectedBorderColor ?? this.selectedBorderColor,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    selectedBackgroundColor:
        selectedBackgroundColor ?? this.selectedBackgroundColor,
    padding: padding ?? this.padding,
    minHeight: minHeight ?? this.minHeight,
    controlGap: controlGap ?? this.controlGap,
    bodyGap: bodyGap ?? this.bodyGap,
    titleStyle: titleStyle ?? this.titleStyle,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiRadioTileThemeData &&
          other.borderRadius == borderRadius &&
          other.borderWidth == borderWidth &&
          other.selectedBorderWidth == selectedBorderWidth &&
          other.borderColor == borderColor &&
          other.selectedBorderColor == selectedBorderColor &&
          other.backgroundColor == backgroundColor &&
          other.selectedBackgroundColor == selectedBackgroundColor &&
          other.padding == padding &&
          other.minHeight == minHeight &&
          other.controlGap == controlGap &&
          other.bodyGap == bodyGap &&
          other.titleStyle == titleStyle;

  @override
  int get hashCode => Object.hash(
    borderRadius,
    borderWidth,
    selectedBorderWidth,
    borderColor,
    selectedBorderColor,
    backgroundColor,
    selectedBackgroundColor,
    padding,
    minHeight,
    controlGap,
    bodyGap,
    titleStyle,
  );
}
