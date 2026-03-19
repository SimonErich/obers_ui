import 'package:flutter/widgets.dart';

/// Theme data for button components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiButtonThemeData {
  /// Creates an [OiButtonThemeData].
  const OiButtonThemeData({this.borderRadius, this.padding, this.textStyle});

  /// The corner radius applied to button shapes.
  final BorderRadius? borderRadius;

  /// The internal padding of the button.
  final EdgeInsets? padding;

  /// The text style for button labels.
  final TextStyle? textStyle;

  /// Creates a copy with optionally overridden values.
  OiButtonThemeData copyWith({
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    TextStyle? textStyle,
  }) {
    return OiButtonThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiButtonThemeData &&
        other.borderRadius == borderRadius &&
        other.padding == padding &&
        other.textStyle == textStyle;
  }

  @override
  int get hashCode => Object.hash(borderRadius, padding, textStyle);
}
