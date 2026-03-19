import 'package:flutter/widgets.dart';

/// Theme data for text-input components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiTextInputThemeData {
  /// Creates an [OiTextInputThemeData].
  const OiTextInputThemeData({
    this.borderRadius,
    this.contentPadding,
    this.borderColor,
    this.focusBorderColor,
  });

  /// The corner radius applied to the input field border.
  final BorderRadius? borderRadius;

  /// The padding between the border and the input text.
  final EdgeInsets? contentPadding;

  /// The color of the input border in its default (unfocused) state.
  final Color? borderColor;

  /// The color of the input border when the field has keyboard focus.
  final Color? focusBorderColor;

  /// Creates a copy with optionally overridden values.
  OiTextInputThemeData copyWith({
    BorderRadius? borderRadius,
    EdgeInsets? contentPadding,
    Color? borderColor,
    Color? focusBorderColor,
  }) {
    return OiTextInputThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      contentPadding: contentPadding ?? this.contentPadding,
      borderColor: borderColor ?? this.borderColor,
      focusBorderColor: focusBorderColor ?? this.focusBorderColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiTextInputThemeData &&
        other.borderRadius == borderRadius &&
        other.contentPadding == contentPadding &&
        other.borderColor == borderColor &&
        other.focusBorderColor == focusBorderColor;
  }

  @override
  int get hashCode =>
      Object.hash(borderRadius, contentPadding, borderColor, focusBorderColor);
}
