import 'package:flutter/widgets.dart';

/// Theme data for badge components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiBadgeThemeData {
  /// Creates an [OiBadgeThemeData].
  const OiBadgeThemeData({
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.height,
    this.useSwatchColors,
    this.counter,
    this.token,
  });

  /// Compact unread-count geometry, independent of status pills.
  final OiBadgeMetrics? counter;

  /// Geometry for short codes, such as allergens.
  final OiBadgeMetrics? token;

  /// The corner radius of the badge pill shape.
  final BorderRadius? borderRadius;

  /// Internal padding of the badge content.
  final EdgeInsets? padding;

  /// Text style for the badge label.
  final TextStyle? textStyle;

  /// Fixed height for badges.
  final double? height;

  /// Uses the explicit swatch muted/dark colors for soft badges and its
  /// foreground for filled badges. Neutral soft badges use surfaceSubtle and
  /// textMuted. Defaults to false: soft backgrounds use a translucent base.
  /// Enable this when a theme supplies its own semantic swatch pairs.
  final bool? useSwatchColors;

  /// Creates a copy with optionally overridden values.
  OiBadgeThemeData copyWith({
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    TextStyle? textStyle,
    double? height,
    bool? useSwatchColors,
    OiBadgeMetrics? counter,
    OiBadgeMetrics? token,
  }) {
    return OiBadgeThemeData(
      counter: counter ?? this.counter,
      token: token ?? this.token,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
      height: height ?? this.height,
      useSwatchColors: useSwatchColors ?? this.useSwatchColors,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiBadgeThemeData &&
        other.counter == counter &&
        other.token == token &&
        other.borderRadius == borderRadius &&
        other.padding == padding &&
        other.textStyle == textStyle &&
        other.height == height &&
        other.useSwatchColors == useSwatchColors;
  }

  @override
  int get hashCode => Object.hash(
    borderRadius,
    padding,
    textStyle,
    height,
    useSwatchColors,
    counter,
    token,
  );
}

/// Layout tokens for a compact badge role. Colors remain semantic.
@immutable
class OiBadgeMetrics {
  /// Creates compact badge tokens; omitted values use the role defaults.
  const OiBadgeMetrics({
    this.height,
    this.minWidth,
    this.padding,
    this.borderRadius,
    this.textStyle,
  });

  /// Fixed height.
  final double? height;

  /// Minimum width, allowing longer counts to grow naturally.
  final double? minWidth;

  /// Horizontal and vertical content inset.
  final EdgeInsets? padding;

  /// Corner shape.
  final BorderRadius? borderRadius;

  /// Label typography, retaining the semantic foreground color.
  final TextStyle? textStyle;
  @override
  bool operator ==(Object other) =>
      other is OiBadgeMetrics &&
      other.height == height &&
      other.minWidth == minWidth &&
      other.padding == padding &&
      other.borderRadius == borderRadius &&
      other.textStyle == textStyle;
  @override
  int get hashCode =>
      Object.hash(height, minWidth, padding, borderRadius, textStyle);
}
