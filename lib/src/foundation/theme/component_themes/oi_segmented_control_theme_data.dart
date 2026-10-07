import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';

/// Theme data for segmented control components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiSegmentedControlThemeData {
  /// Creates an [OiSegmentedControlThemeData].
  const OiSegmentedControlThemeData({
    this.backgroundColor,
    this.selectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.borderRadius,
    this.borderColor,
    this.height,
    this.inset,
    this.innerRadius,
    this.labelStyle,
    this.subtitleStyle,
    this.subtitleGap,
    this.spacing,
    this.selectedShadow,
  });

  /// The background color of the segmented control track.
  final Color? backgroundColor;

  /// The fill color of the selected segment.
  final Color? selectedColor;

  /// The text color of the selected segment label.
  final Color? selectedTextColor;

  /// The text color of unselected segment labels.
  final Color? unselectedTextColor;

  /// The corner radius of the segmented control.
  final BorderRadius? borderRadius;

  /// The border color of the segmented control.
  final Color? borderColor;

  /// The height of the segmented control in logical pixels.
  final double? height;

  /// Insets individually rounded segments inside the shared track; defaults to 0.
  final double? inset;

  /// Radius of each segment when [inset] is positive.
  final BorderRadius? innerRadius;

  /// Typography for labels, including an optional shared emphasis weight.
  final TextStyle? labelStyle;

  /// Typography for the optional second line.
  final TextStyle? subtitleStyle;

  /// Vertical space between a label and subtitle; defaults to zero.
  final double? subtitleGap;

  /// Space between labelled segments. Icon-only controls remain contiguous.
  final double? spacing;

  /// Optional elevation painted behind the selected segment.
  final List<BoxShadow>? selectedShadow;

  /// Creates a copy with optionally overridden values.
  OiSegmentedControlThemeData copyWith({
    Color? backgroundColor,
    Color? selectedColor,
    Color? selectedTextColor,
    Color? unselectedTextColor,
    BorderRadius? borderRadius,
    Color? borderColor,
    double? height,
    double? inset,
    BorderRadius? innerRadius,
    TextStyle? labelStyle,
    TextStyle? subtitleStyle,
    double? subtitleGap,
    double? spacing,
    List<BoxShadow>? selectedShadow,
  }) {
    return OiSegmentedControlThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedTextColor: selectedTextColor ?? this.selectedTextColor,
      unselectedTextColor: unselectedTextColor ?? this.unselectedTextColor,
      borderRadius: borderRadius ?? this.borderRadius,
      borderColor: borderColor ?? this.borderColor,
      height: height ?? this.height,
      inset: inset ?? this.inset,
      innerRadius: innerRadius ?? this.innerRadius,
      labelStyle: labelStyle ?? this.labelStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      subtitleGap: subtitleGap ?? this.subtitleGap,
      spacing: spacing ?? this.spacing,
      selectedShadow: selectedShadow ?? this.selectedShadow,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiSegmentedControlThemeData &&
        other.backgroundColor == backgroundColor &&
        other.selectedColor == selectedColor &&
        other.selectedTextColor == selectedTextColor &&
        other.unselectedTextColor == unselectedTextColor &&
        other.borderRadius == borderRadius &&
        other.borderColor == borderColor &&
        other.height == height &&
        other.inset == inset &&
        other.innerRadius == innerRadius &&
        other.labelStyle == labelStyle &&
        other.subtitleStyle == subtitleStyle &&
        other.subtitleGap == subtitleGap &&
        other.spacing == spacing &&
        listEquals(other.selectedShadow, selectedShadow);
  }

  @override
  int get hashCode => Object.hash(
    backgroundColor,
    selectedColor,
    selectedTextColor,
    unselectedTextColor,
    borderRadius,
    borderColor,
    height,
    inset,
    innerRadius,
    labelStyle,
    subtitleStyle,
    subtitleGap,
    spacing,
    selectedShadow == null ? null : Object.hashAll(selectedShadow!),
  );
}
