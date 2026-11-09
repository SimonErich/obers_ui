import 'package:flutter/widgets.dart';

/// Explicit opt-in typography and content geometry for one button size.
///
/// Null fields retain the exact legacy resolution for that property.
///
/// {@category Foundation}
@immutable
class OiButtonSizeStyle {
  /// Creates a style, rejecting invalid numeric geometry in release builds.
  factory OiButtonSizeStyle({
    TextStyle? textStyle,
    double? iconSize,
    double? iconOnlySize,
    EdgeInsetsGeometry? padding,
    EdgeInsetsDirectional? iconLabelPadding,
    double? iconGap,
    double? minWidth,
  }) {
    for (final value in [iconSize, iconOnlySize, iconGap, minWidth]) {
      if (value != null && (!value.isFinite || value < 0)) {
        throw ArgumentError.value(
          value,
          'geometry',
          'Must be finite and nonnegative',
        );
      }
    }
    for (final insets in [padding, iconLabelPadding]) {
      if (insets == null) continue;
      for (final direction in TextDirection.values) {
        final resolved = insets.resolve(direction);
        for (final edge in [
          resolved.left,
          resolved.top,
          resolved.right,
          resolved.bottom,
        ]) {
          if (!edge.isFinite || edge < 0) {
            throw ArgumentError.value(
              insets,
              'insets',
              'Every resolved LTR/RTL edge must be finite and nonnegative',
            );
          }
        }
      }
    }
    return OiButtonSizeStyle._(
      textStyle: textStyle,
      iconSize: iconSize,
      iconOnlySize: iconOnlySize,
      padding: padding,
      iconLabelPadding: iconLabelPadding,
      iconGap: iconGap,
      minWidth: minWidth,
    );
  }

  const OiButtonSizeStyle._({
    this.textStyle,
    this.iconSize,
    this.iconOnlySize,
    this.padding,
    this.iconLabelPadding,
    this.iconGap,
    this.minWidth,
  });

  /// Label style merged after legacy resolution; foreground remains state-owned.
  final TextStyle? textStyle;

  /// Dimension of a label-adjacent icon or a split-button chevron.
  final double? iconSize;

  /// Dimension of an icon-only glyph, not its button or touch target.
  final double? iconOnlySize;

  /// Content insets for this size, including icon-only and small controls.
  final EdgeInsetsGeometry? padding;

  /// Start/end icon-label insets, applied to explicit small overrides too.
  final EdgeInsetsDirectional? iconLabelPadding;

  /// Direction-aware space between the label and icon.
  final double? iconGap;

  /// Minimum content-frame width; does not replace height or touch targets.
  final double? minWidth;

  /// Omitted fields retain their current value, matching existing themes.
  OiButtonSizeStyle copyWith({
    TextStyle? textStyle,
    double? iconSize,
    double? iconOnlySize,
    EdgeInsetsGeometry? padding,
    EdgeInsetsDirectional? iconLabelPadding,
    double? iconGap,
    double? minWidth,
  }) => OiButtonSizeStyle(
    textStyle: textStyle ?? this.textStyle,
    iconSize: iconSize ?? this.iconSize,
    iconOnlySize: iconOnlySize ?? this.iconOnlySize,
    padding: padding ?? this.padding,
    iconLabelPadding: iconLabelPadding ?? this.iconLabelPadding,
    iconGap: iconGap ?? this.iconGap,
    minWidth: minWidth ?? this.minWidth,
  );

  /// Applies non-null overrides while retaining inherited state and size styles.
  OiButtonSizeStyle merge(OiButtonSizeStyle? other) {
    if (other == null) return this;
    return OiButtonSizeStyle(
      textStyle: textStyle?.merge(other.textStyle) ?? other.textStyle,
      iconSize: other.iconSize ?? iconSize,
      iconOnlySize: other.iconOnlySize ?? iconOnlySize,
      padding: other.padding ?? padding,
      iconLabelPadding: other.iconLabelPadding ?? iconLabelPadding,
      iconGap: other.iconGap ?? iconGap,
      minWidth: other.minWidth ?? minWidth,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is OiButtonSizeStyle &&
      other.textStyle == textStyle &&
      other.iconSize == iconSize &&
      other.iconOnlySize == iconOnlySize &&
      other.padding == padding &&
      other.iconLabelPadding == iconLabelPadding &&
      other.iconGap == iconGap &&
      other.minWidth == minWidth;

  @override
  int get hashCode => Object.hash(
    textStyle,
    iconSize,
    iconOnlySize,
    padding,
    iconLabelPadding,
    iconGap,
    minWidth,
  );
}
