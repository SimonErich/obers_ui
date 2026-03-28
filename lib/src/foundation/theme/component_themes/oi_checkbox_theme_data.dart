import 'package:flutter/widgets.dart';

/// Theme data for checkbox components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiCheckboxThemeData {
  /// Creates an [OiCheckboxThemeData].
  const OiCheckboxThemeData({
    this.size,
    this.borderRadius,
    this.checkedColor,
    this.uncheckedBorderColor,
    this.checkmarkColor,
  });

  /// The width and height of the checkbox in logical pixels.
  final double? size;

  /// The corner radius of the checkbox border.
  final BorderRadius? borderRadius;

  /// Fill color when the checkbox is checked or indeterminate.
  final Color? checkedColor;

  /// Border color when the checkbox is unchecked.
  final Color? uncheckedBorderColor;

  /// Color of the check mark icon.
  final Color? checkmarkColor;

  /// Creates a copy with optionally overridden values.
  OiCheckboxThemeData copyWith({
    double? size,
    BorderRadius? borderRadius,
    Color? checkedColor,
    Color? uncheckedBorderColor,
    Color? checkmarkColor,
  }) {
    return OiCheckboxThemeData(
      size: size ?? this.size,
      borderRadius: borderRadius ?? this.borderRadius,
      checkedColor: checkedColor ?? this.checkedColor,
      uncheckedBorderColor: uncheckedBorderColor ?? this.uncheckedBorderColor,
      checkmarkColor: checkmarkColor ?? this.checkmarkColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiCheckboxThemeData &&
        other.size == size &&
        other.borderRadius == borderRadius &&
        other.checkedColor == checkedColor &&
        other.uncheckedBorderColor == uncheckedBorderColor &&
        other.checkmarkColor == checkmarkColor;
  }

  @override
  int get hashCode => Object.hash(
    size,
    borderRadius,
    checkedColor,
    uncheckedBorderColor,
    checkmarkColor,
  );
}
