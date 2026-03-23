import 'package:flutter/widgets.dart';

/// Theme data for date picker field components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiDatePickerFieldThemeData {
  /// Creates an [OiDatePickerFieldThemeData].
  const OiDatePickerFieldThemeData({
    this.borderRadius,
    this.iconColor,
    this.clearIconColor,
  });

  /// The corner radius applied to the date picker field border.
  final BorderRadius? borderRadius;

  /// The color of the calendar icon.
  final Color? iconColor;

  /// The color of the clear / reset icon.
  final Color? clearIconColor;

  /// Creates a copy with optionally overridden values.
  OiDatePickerFieldThemeData copyWith({
    BorderRadius? borderRadius,
    Color? iconColor,
    Color? clearIconColor,
  }) {
    return OiDatePickerFieldThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      iconColor: iconColor ?? this.iconColor,
      clearIconColor: clearIconColor ?? this.clearIconColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiDatePickerFieldThemeData &&
        other.borderRadius == borderRadius &&
        other.iconColor == iconColor &&
        other.clearIconColor == clearIconColor;
  }

  @override
  int get hashCode => Object.hash(borderRadius, iconColor, clearIconColor);
}
