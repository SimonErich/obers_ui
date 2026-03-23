import 'package:flutter/widgets.dart';

/// Theme data for form select components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiFormSelectThemeData {
  /// Creates an [OiFormSelectThemeData].
  const OiFormSelectThemeData({
    this.borderRadius,
    this.dropdownMaxHeight,
    this.errorColor,
  });

  /// The corner radius applied to the form select control border.
  final BorderRadius? borderRadius;

  /// The maximum height of the dropdown list in logical pixels.
  final double? dropdownMaxHeight;

  /// The color used for error states and error messages.
  final Color? errorColor;

  /// Creates a copy with optionally overridden values.
  OiFormSelectThemeData copyWith({
    BorderRadius? borderRadius,
    double? dropdownMaxHeight,
    Color? errorColor,
  }) {
    return OiFormSelectThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      dropdownMaxHeight: dropdownMaxHeight ?? this.dropdownMaxHeight,
      errorColor: errorColor ?? this.errorColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiFormSelectThemeData &&
        other.borderRadius == borderRadius &&
        other.dropdownMaxHeight == dropdownMaxHeight &&
        other.errorColor == errorColor;
  }

  @override
  int get hashCode => Object.hash(borderRadius, dropdownMaxHeight, errorColor);
}
