import 'package:flutter/widgets.dart';

/// Theme data for toggle-switch components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiSwitchThemeData {
  /// Creates an [OiSwitchThemeData].
  const OiSwitchThemeData({
    this.width,
    this.height,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.thumbInset,
  });

  /// The total width of the switch track in logical pixels.
  final double? width;

  /// The total height of the switch track in logical pixels.
  final double? height;

  /// Track color when the switch is on.
  final Color? activeTrackColor;

  /// Track color when the switch is off.
  final Color? inactiveTrackColor;

  /// Thumb (knob) color.
  final Color? thumbColor;

  /// Inset around the thumb inside its track; defaults to 2 pixels.
  final double? thumbInset;

  /// Creates a copy with optionally overridden values.
  OiSwitchThemeData copyWith({
    double? width,
    double? height,
    Color? activeTrackColor,
    Color? inactiveTrackColor,
    Color? thumbColor,
    double? thumbInset,
  }) {
    return OiSwitchThemeData(
      width: width ?? this.width,
      height: height ?? this.height,
      activeTrackColor: activeTrackColor ?? this.activeTrackColor,
      inactiveTrackColor: inactiveTrackColor ?? this.inactiveTrackColor,
      thumbColor: thumbColor ?? this.thumbColor,
      thumbInset: thumbInset ?? this.thumbInset,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiSwitchThemeData &&
        other.width == width &&
        other.height == height &&
        other.activeTrackColor == activeTrackColor &&
        other.inactiveTrackColor == inactiveTrackColor &&
        other.thumbColor == thumbColor &&
        other.thumbInset == thumbInset;
  }

  @override
  int get hashCode => Object.hash(
    width,
    height,
    activeTrackColor,
    inactiveTrackColor,
    thumbColor,
    thumbInset,
  );
}
