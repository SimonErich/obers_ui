import 'package:flutter/widgets.dart';

/// Presentation tokens for capacity tracks, ratios and warnings.
@immutable
class OiCapacityThemeData {
  /// Creates capacity tokens; omitted values use accessible component defaults.
  const OiCapacityThemeData({
    this.labelStyle,
    this.valueStyle,
    this.valueWidth,
    this.warningIcon,
    this.alignWarningWithTrack,
    this.columnGap,
    this.trackRadius,
    this.stripeColor,
    this.warningGap,
  });

  /// Equal horizontal gaps between the label, track and value.
  final double? columnGap;

  /// Track corner radius; defaults to half its height.
  final double? trackRadius;

  /// Color of stripes in the unused part of the track.
  final Color? stripeColor;

  /// Gap between a capacity row and its warning text.
  final double? warningGap;

  /// Typography of the resource label.
  final TextStyle? labelStyle;

  /// Typography of the used amount and total. The total uses muted color.
  final TextStyle? valueStyle;

  /// Reserved ratio width in horizontal layouts, keeping tracks aligned.
  final double? valueWidth;

  /// Optional icon before a warning, in addition to its text and color.
  final IconData? warningIcon;

  /// Aligns horizontal warning text under the track instead of the label.
  final bool? alignWarningWithTrack;

  /// Copies the tokens with optional overrides.
  OiCapacityThemeData copyWith({
    TextStyle? labelStyle,
    TextStyle? valueStyle,
    double? valueWidth,
    IconData? warningIcon,
    bool? alignWarningWithTrack,
    double? columnGap,
    double? trackRadius,
    Color? stripeColor,
    double? warningGap,
  }) => OiCapacityThemeData(
    columnGap: columnGap ?? this.columnGap,
    trackRadius: trackRadius ?? this.trackRadius,
    stripeColor: stripeColor ?? this.stripeColor,
    warningGap: warningGap ?? this.warningGap,
    labelStyle: labelStyle ?? this.labelStyle,
    valueStyle: valueStyle ?? this.valueStyle,
    valueWidth: valueWidth ?? this.valueWidth,
    warningIcon: warningIcon ?? this.warningIcon,
    alignWarningWithTrack: alignWarningWithTrack ?? this.alignWarningWithTrack,
  );
  @override
  bool operator ==(Object other) =>
      other is OiCapacityThemeData &&
      other.columnGap == columnGap &&
      other.trackRadius == trackRadius &&
      other.stripeColor == stripeColor &&
      other.warningGap == warningGap &&
      other.labelStyle == labelStyle &&
      other.valueStyle == valueStyle &&
      other.valueWidth == valueWidth &&
      other.warningIcon == warningIcon &&
      other.alignWarningWithTrack == alignWarningWithTrack;
  @override
  int get hashCode => Object.hash(
    labelStyle,
    valueStyle,
    valueWidth,
    warningIcon,
    alignWarningWithTrack,
    columnGap,
    trackRadius,
    stripeColor,
    warningGap,
  );
}
