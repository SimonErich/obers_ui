import 'package:flutter/widgets.dart';

/// Radio indicator geometry, colors and group label typography.
///
/// Null values retain component defaults.
/// {@category Foundation}
@immutable
class OiRadioThemeData {
  /// Creates component overrides.
  const OiRadioThemeData({
    this.size,
    this.dotSize,
    this.borderWidth,
    this.borderColor,
    this.selectedBorderColor,
    this.selectedFillColor,
    this.selectedDotColor,
    this.labelStyle,
    this.groupLabelStyle,
    this.groupLabelSpacing,
    this.optionPadding,
    this.optionSpacing,
  });

  /// Outer indicator diameter.
  final double? size;

  /// Selected center diameter.
  final double? dotSize;

  /// Outline width, drawn inside the indicator bounds.
  final double? borderWidth;

  /// Unselected outline color.
  final Color? borderColor;

  /// Selected outline color.
  final Color? selectedBorderColor;

  /// Fill behind the selected center.
  final Color? selectedFillColor;

  /// Selected center color.
  final Color? selectedDotColor;

  /// Typography for individual radio labels.
  final TextStyle? labelStyle;

  /// Typography for a heading above a group of radio choices.
  final TextStyle? groupLabelStyle;

  /// Spacing after the group heading; defaults to eight pixels.
  final double? groupLabelSpacing;

  /// Padding around each ordinary radio option; defaults to four vertical pixels.
  final EdgeInsetsGeometry? optionPadding;

  /// Horizontal gap between radio options; defaults to sixteen pixels.
  final double? optionSpacing;

  /// Copies the theme with selected overrides.
  OiRadioThemeData copyWith({
    double? size,
    double? dotSize,
    double? borderWidth,
    Color? borderColor,
    Color? selectedBorderColor,
    Color? selectedFillColor,
    Color? selectedDotColor,
    TextStyle? labelStyle,
    TextStyle? groupLabelStyle,
    double? groupLabelSpacing,
    EdgeInsetsGeometry? optionPadding,
    double? optionSpacing,
  }) => OiRadioThemeData(
    size: size ?? this.size,
    dotSize: dotSize ?? this.dotSize,
    borderWidth: borderWidth ?? this.borderWidth,
    borderColor: borderColor ?? this.borderColor,
    selectedBorderColor: selectedBorderColor ?? this.selectedBorderColor,
    selectedFillColor: selectedFillColor ?? this.selectedFillColor,
    selectedDotColor: selectedDotColor ?? this.selectedDotColor,
    labelStyle: labelStyle ?? this.labelStyle,
    groupLabelStyle: groupLabelStyle ?? this.groupLabelStyle,
    groupLabelSpacing: groupLabelSpacing ?? this.groupLabelSpacing,
    optionPadding: optionPadding ?? this.optionPadding,
    optionSpacing: optionSpacing ?? this.optionSpacing,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiRadioThemeData &&
          other.size == size &&
          other.dotSize == dotSize &&
          other.borderWidth == borderWidth &&
          other.borderColor == borderColor &&
          other.selectedBorderColor == selectedBorderColor &&
          other.selectedFillColor == selectedFillColor &&
          other.selectedDotColor == selectedDotColor &&
          other.labelStyle == labelStyle &&
          other.groupLabelStyle == groupLabelStyle &&
          other.groupLabelSpacing == groupLabelSpacing &&
          other.optionPadding == optionPadding &&
          other.optionSpacing == optionSpacing;

  @override
  int get hashCode => Object.hash(
    size,
    dotSize,
    borderWidth,
    borderColor,
    selectedBorderColor,
    selectedFillColor,
    selectedDotColor,
    labelStyle,
    groupLabelStyle,
    groupLabelSpacing,
    optionPadding,
    optionSpacing,
  );
}
