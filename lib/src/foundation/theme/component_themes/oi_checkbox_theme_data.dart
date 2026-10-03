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
    this.borderWidth,
    this.checkedColor,
    this.uncheckedBorderColor,
    this.checkmarkColor,
    this.disabledColor,
  });

  /// The width and height of the checkbox in logical pixels.
  final double? size;

  /// The corner radius of the checkbox border.
  final BorderRadius? borderRadius;

  /// Outline thickness; defaults to 1.5 logical pixels.
  final double? borderWidth;

  /// Fill color when the checkbox is checked or indeterminate.
  final Color? checkedColor;

  /// Border color when the checkbox is unchecked.
  final Color? uncheckedBorderColor;

  /// Color of the check mark icon.
  final Color? checkmarkColor;

  /// Fill/border color of a noninteractive checkbox.
  final Color? disabledColor;

  /// Creates a copy with optionally overridden values.
  OiCheckboxThemeData copyWith({
    double? size,
    BorderRadius? borderRadius,
    double? borderWidth,
    Color? checkedColor,
    Color? uncheckedBorderColor,
    Color? checkmarkColor,
    Color? disabledColor,
  }) {
    return OiCheckboxThemeData(
      size: size ?? this.size,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      checkedColor: checkedColor ?? this.checkedColor,
      uncheckedBorderColor: uncheckedBorderColor ?? this.uncheckedBorderColor,
      checkmarkColor: checkmarkColor ?? this.checkmarkColor,
      disabledColor: disabledColor ?? this.disabledColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiCheckboxThemeData &&
        other.size == size &&
        other.borderRadius == borderRadius &&
        other.borderWidth == borderWidth &&
        other.checkedColor == checkedColor &&
        other.uncheckedBorderColor == uncheckedBorderColor &&
        other.checkmarkColor == checkmarkColor &&
        other.disabledColor == disabledColor;
  }

  @override
  int get hashCode => Object.hash(
    size,
    borderRadius,
    borderWidth,
    checkedColor,
    uncheckedBorderColor,
    checkmarkColor,
    disabledColor,
  );
}
