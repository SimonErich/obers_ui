import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiTextInputThemeData;
import 'package:obers_ui/src/foundation/theme/component_themes/oi_text_input_theme_data.dart' show OiTextInputThemeData;
import 'package:obers_ui/src/foundation/theme/oi_component_themes.dart' show OiTextInputThemeData;

/// Theme overrides for the OTP (one-time-password) input variant.
///
/// Used as a sub-theme of [OiTextInputThemeData] to style the individual
/// digit boxes rendered by `OiTextInput.otp()`.
///
/// {@category Foundation}
@immutable
class OiOtpThemeData {
  /// Creates an [OiOtpThemeData].
  const OiOtpThemeData({
    this.boxWidth,
    this.boxHeight,
    this.gap,
    this.boxRadius,
    this.filledBoxColor,
    this.emptyBoxColor,
    this.focusedBoxColor,
    this.digitStyle,
  });

  /// Width of each digit box. Default: 48.
  final double? boxWidth;

  /// Height of each digit box. Default: 56.
  final double? boxHeight;

  /// Spacing between digit boxes. Default: 8.
  final double? gap;

  /// Corner radius of each digit box.
  final BorderRadius? boxRadius;

  /// Background color of a box that contains a digit.
  final Color? filledBoxColor;

  /// Background color of an empty box.
  final Color? emptyBoxColor;

  /// Background color of the currently focused box.
  final Color? focusedBoxColor;

  /// Text style for the entered digits.
  final TextStyle? digitStyle;

  /// Creates a copy with optionally overridden values.
  OiOtpThemeData copyWith({
    double? boxWidth,
    double? boxHeight,
    double? gap,
    BorderRadius? boxRadius,
    Color? filledBoxColor,
    Color? emptyBoxColor,
    Color? focusedBoxColor,
    TextStyle? digitStyle,
  }) {
    return OiOtpThemeData(
      boxWidth: boxWidth ?? this.boxWidth,
      boxHeight: boxHeight ?? this.boxHeight,
      gap: gap ?? this.gap,
      boxRadius: boxRadius ?? this.boxRadius,
      filledBoxColor: filledBoxColor ?? this.filledBoxColor,
      emptyBoxColor: emptyBoxColor ?? this.emptyBoxColor,
      focusedBoxColor: focusedBoxColor ?? this.focusedBoxColor,
      digitStyle: digitStyle ?? this.digitStyle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiOtpThemeData &&
        other.boxWidth == boxWidth &&
        other.boxHeight == boxHeight &&
        other.gap == gap &&
        other.boxRadius == boxRadius &&
        other.filledBoxColor == filledBoxColor &&
        other.emptyBoxColor == emptyBoxColor &&
        other.focusedBoxColor == focusedBoxColor &&
        other.digitStyle == digitStyle;
  }

  @override
  int get hashCode => Object.hash(
        boxWidth,
        boxHeight,
        gap,
        boxRadius,
        filledBoxColor,
        emptyBoxColor,
        focusedBoxColor,
        digitStyle,
      );
}
