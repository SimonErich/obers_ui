import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiSliverHeader;
import 'package:obers_ui/src/components/display/oi_sliver_header.dart' show OiSliverHeader;

/// Theme overrides for [OiSliverHeader].
///
/// Controls the visual appearance of the sticky sliver header including
/// colors, typography, and scroll-under behavior.
///
/// {@category Foundation}
@immutable
class OiSliverHeaderThemeData {
  /// Creates an [OiSliverHeaderThemeData].
  const OiSliverHeaderThemeData({
    this.backgroundColor,
    this.foregroundColor,
    this.scrolledUnderBackgroundColor,
    this.border,
    this.toolbarHeight,
    this.titleSpacing,
    this.titleStyle,
    this.subtitleStyle,
    this.centerTitle,
  });

  /// Background color of the header.
  final Color? backgroundColor;

  /// Foreground color for title and icons.
  final Color? foregroundColor;

  /// Background color when content is scrolled under the header.
  final Color? scrolledUnderBackgroundColor;

  /// Bottom border of the header.
  final BorderSide? border;

  /// Height of the toolbar area. Default: 56.
  final double? toolbarHeight;

  /// Horizontal spacing around the title. Default: 16.
  final double? titleSpacing;

  /// Text style for the title.
  final TextStyle? titleStyle;

  /// Text style for the subtitle.
  final TextStyle? subtitleStyle;

  /// Whether the title is centered.
  final bool? centerTitle;

  /// Creates a copy with optionally overridden values.
  OiSliverHeaderThemeData copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    Color? scrolledUnderBackgroundColor,
    BorderSide? border,
    double? toolbarHeight,
    double? titleSpacing,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    bool? centerTitle,
  }) {
    return OiSliverHeaderThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      scrolledUnderBackgroundColor:
          scrolledUnderBackgroundColor ?? this.scrolledUnderBackgroundColor,
      border: border ?? this.border,
      toolbarHeight: toolbarHeight ?? this.toolbarHeight,
      titleSpacing: titleSpacing ?? this.titleSpacing,
      titleStyle: titleStyle ?? this.titleStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      centerTitle: centerTitle ?? this.centerTitle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiSliverHeaderThemeData &&
        other.backgroundColor == backgroundColor &&
        other.foregroundColor == foregroundColor &&
        other.scrolledUnderBackgroundColor == scrolledUnderBackgroundColor &&
        other.border == border &&
        other.toolbarHeight == toolbarHeight &&
        other.titleSpacing == titleSpacing &&
        other.titleStyle == titleStyle &&
        other.subtitleStyle == subtitleStyle &&
        other.centerTitle == centerTitle;
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        foregroundColor,
        scrolledUnderBackgroundColor,
        border,
        toolbarHeight,
        titleSpacing,
        titleStyle,
        subtitleStyle,
        centerTitle,
      );
}
