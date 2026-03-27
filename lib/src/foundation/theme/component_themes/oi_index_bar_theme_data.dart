import 'package:flutter/widgets.dart';

/// Theme data for index bar components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiIndexBarThemeData {
  /// Creates an [OiIndexBarThemeData].
  const OiIndexBarThemeData({this.labelSize, this.activeColor});

  /// The font size of each index label.
  final double? labelSize;

  /// The color used for the currently active label.
  final Color? activeColor;

  /// Creates a copy with optionally overridden values.
  OiIndexBarThemeData copyWith({double? labelSize, Color? activeColor}) {
    return OiIndexBarThemeData(
      labelSize: labelSize ?? this.labelSize,
      activeColor: activeColor ?? this.activeColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiIndexBarThemeData &&
        other.labelSize == labelSize &&
        other.activeColor == activeColor;
  }

  @override
  int get hashCode => Object.hash(labelSize, activeColor);
}
