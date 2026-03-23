import 'package:flutter/widgets.dart';

/// Theme data for switch tile components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiSwitchTileThemeData {
  /// Creates an [OiSwitchTileThemeData].
  const OiSwitchTileThemeData({
    this.contentPadding,
    this.densePadding,
    this.titleStyle,
    this.subtitleStyle,
  });

  /// The padding around the switch tile content area.
  final EdgeInsets? contentPadding;

  /// The padding used when the switch tile is in dense mode.
  final EdgeInsets? densePadding;

  /// The text style for the switch tile title.
  final TextStyle? titleStyle;

  /// The text style for the switch tile subtitle.
  final TextStyle? subtitleStyle;

  /// Creates a copy with optionally overridden values.
  OiSwitchTileThemeData copyWith({
    EdgeInsets? contentPadding,
    EdgeInsets? densePadding,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
  }) {
    return OiSwitchTileThemeData(
      contentPadding: contentPadding ?? this.contentPadding,
      densePadding: densePadding ?? this.densePadding,
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiSwitchTileThemeData &&
        other.contentPadding == contentPadding &&
        other.densePadding == densePadding &&
        other.titleStyle == titleStyle &&
        other.subtitleStyle == subtitleStyle;
  }

  @override
  int get hashCode =>
      Object.hash(contentPadding, densePadding, titleStyle, subtitleStyle);
}
