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

  /// Creates a copy with optionally overridden values.
  OiSegmentedControlThemeData copyWith({
    Color? backgroundColor,
    Color? selectedColor,
    Color? selectedTextColor,
    Color? unselectedTextColor,
    BorderRadius? borderRadius,
    Color? borderColor,
    double? height,
  }) {
    return OiSegmentedControlThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedTextColor: selectedTextColor ?? this.selectedTextColor,
      unselectedTextColor: unselectedTextColor ?? this.unselectedTextColor,
      borderRadius: borderRadius ?? this.borderRadius,
      borderColor: borderColor ?? this.borderColor,
      height: height ?? this.height,
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
        other.height == height;
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
      );
}
