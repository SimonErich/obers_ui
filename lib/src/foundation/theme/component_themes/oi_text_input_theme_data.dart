import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_otp_theme_data.dart';

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
    this.validationErrorColor,
    this.errorAnimationDuration,
    this.otp,
  });

  /// The corner radius applied to the input field border.
  final BorderRadius? borderRadius;

  /// The padding between the border and the input text.
  final EdgeInsets? contentPadding;

  /// The color of the input border in its default (unfocused) state.
  final Color? borderColor;

  /// The color of the input border when the field has keyboard focus.
  final Color? focusBorderColor;

  /// Border color when validation fails.
  ///
  /// Defaults to `colorScheme.error.base` when null.
  final Color? validationErrorColor;

  /// Animation duration for error text appearance.
  final Duration? errorAnimationDuration;

  /// OTP-specific sub-theme for digit box dimensions and styling.
  final OiOtpThemeData? otp;

  /// Creates a copy with optionally overridden values.
  OiTextInputThemeData copyWith({
    BorderRadius? borderRadius,
    EdgeInsets? contentPadding,
    Color? borderColor,
    Color? focusBorderColor,
    Color? validationErrorColor,
    Duration? errorAnimationDuration,
    OiOtpThemeData? otp,
  }) {
    return OiTextInputThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      contentPadding: contentPadding ?? this.contentPadding,
      borderColor: borderColor ?? this.borderColor,
      focusBorderColor: focusBorderColor ?? this.focusBorderColor,
      validationErrorColor:
          validationErrorColor ?? this.validationErrorColor,
      errorAnimationDuration:
          errorAnimationDuration ?? this.errorAnimationDuration,
      otp: otp ?? this.otp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiTextInputThemeData &&
        other.borderRadius == borderRadius &&
        other.contentPadding == contentPadding &&
        other.borderColor == borderColor &&
        other.focusBorderColor == focusBorderColor &&
        other.validationErrorColor == validationErrorColor &&
        other.errorAnimationDuration == errorAnimationDuration &&
        other.otp == otp;
  }

  @override
  int get hashCode => Object.hash(
        borderRadius,
        contentPadding,
        borderColor,
        focusBorderColor,
        validationErrorColor,
        errorAnimationDuration,
        otp,
      );
}
