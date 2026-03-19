import 'package:flutter/widgets.dart';

/// Theme data for dialog components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiDialogThemeData {
  /// Creates an [OiDialogThemeData].
  const OiDialogThemeData({this.borderRadius, this.maxWidth});

  /// The corner radius of the dialog surface.
  final BorderRadius? borderRadius;

  /// The maximum width of the dialog in logical pixels.
  final double? maxWidth;

  /// Creates a copy with optionally overridden values.
  OiDialogThemeData copyWith({BorderRadius? borderRadius, double? maxWidth}) {
    return OiDialogThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      maxWidth: maxWidth ?? this.maxWidth,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiDialogThemeData &&
        other.borderRadius == borderRadius &&
        other.maxWidth == maxWidth;
  }

  @override
  int get hashCode => Object.hash(borderRadius, maxWidth);
}
