import 'package:flutter/widgets.dart';

/// Theme data for slider / range-slider components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiSliderThemeData {
  /// Creates an [OiSliderThemeData].
  const OiSliderThemeData({
    this.trackHeight,
    this.trackRadius,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.thumbSize,
    this.thumbColor,
    this.thumbBorderColor,
    this.thumbBorderWidth,
    this.tooltipBackgroundColor,
    this.tooltipBorderRadius,
    this.tooltipTextStyle,
    this.markColor,
    this.markLabelColor,
    this.markLabelStyle,
  });

  /// Height of the slider track.
  final double? trackHeight;

  /// Border radius of the slider track.
  final BorderRadius? trackRadius;

  /// Color of the active (filled) portion of the track.
  final Color? activeTrackColor;

  /// Color of the inactive (unfilled) portion of the track.
  final Color? inactiveTrackColor;

  /// Diameter of the thumb handle.
  final double? thumbSize;

  /// Fill color of the thumb.
  final Color? thumbColor;

  /// Border/stroke color of the thumb.
  final Color? thumbBorderColor;

  /// Border/stroke width of the thumb.
  final double? thumbBorderWidth;

  /// Background color of the value tooltip.
  final Color? tooltipBackgroundColor;

  /// Border radius of the value tooltip.
  final BorderRadius? tooltipBorderRadius;

  /// Text style for the tooltip value label.
  final TextStyle? tooltipTextStyle;

  /// Color of tick mark indicators.
  final Color? markColor;

  /// Color of tick mark label text.
  final Color? markLabelColor;

  /// Text style for tick mark labels.
  final TextStyle? markLabelStyle;

  /// Creates a copy with optionally overridden values.
  OiSliderThemeData copyWith({
    double? trackHeight,
    BorderRadius? trackRadius,
    Color? activeTrackColor,
    Color? inactiveTrackColor,
    double? thumbSize,
    Color? thumbColor,
    Color? thumbBorderColor,
    double? thumbBorderWidth,
    Color? tooltipBackgroundColor,
    BorderRadius? tooltipBorderRadius,
    TextStyle? tooltipTextStyle,
    Color? markColor,
    Color? markLabelColor,
    TextStyle? markLabelStyle,
  }) {
    return OiSliderThemeData(
      trackHeight: trackHeight ?? this.trackHeight,
      trackRadius: trackRadius ?? this.trackRadius,
      activeTrackColor: activeTrackColor ?? this.activeTrackColor,
      inactiveTrackColor: inactiveTrackColor ?? this.inactiveTrackColor,
      thumbSize: thumbSize ?? this.thumbSize,
      thumbColor: thumbColor ?? this.thumbColor,
      thumbBorderColor: thumbBorderColor ?? this.thumbBorderColor,
      thumbBorderWidth: thumbBorderWidth ?? this.thumbBorderWidth,
      tooltipBackgroundColor:
          tooltipBackgroundColor ?? this.tooltipBackgroundColor,
      tooltipBorderRadius: tooltipBorderRadius ?? this.tooltipBorderRadius,
      tooltipTextStyle: tooltipTextStyle ?? this.tooltipTextStyle,
      markColor: markColor ?? this.markColor,
      markLabelColor: markLabelColor ?? this.markLabelColor,
      markLabelStyle: markLabelStyle ?? this.markLabelStyle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiSliderThemeData &&
        other.trackHeight == trackHeight &&
        other.trackRadius == trackRadius &&
        other.activeTrackColor == activeTrackColor &&
        other.inactiveTrackColor == inactiveTrackColor &&
        other.thumbSize == thumbSize &&
        other.thumbColor == thumbColor &&
        other.thumbBorderColor == thumbBorderColor &&
        other.thumbBorderWidth == thumbBorderWidth &&
        other.tooltipBackgroundColor == tooltipBackgroundColor &&
        other.tooltipBorderRadius == tooltipBorderRadius &&
        other.tooltipTextStyle == tooltipTextStyle &&
        other.markColor == markColor &&
        other.markLabelColor == markLabelColor &&
        other.markLabelStyle == markLabelStyle;
  }

  @override
  int get hashCode => Object.hash(
    trackHeight,
    trackRadius,
    activeTrackColor,
    inactiveTrackColor,
    thumbSize,
    thumbColor,
    thumbBorderColor,
    thumbBorderWidth,
    tooltipBackgroundColor,
    tooltipBorderRadius,
    tooltipTextStyle,
    markColor,
    markLabelColor,
    markLabelStyle,
  );
}
