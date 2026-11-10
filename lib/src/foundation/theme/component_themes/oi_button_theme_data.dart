import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiButtonFontSizeScale;
import 'package:obers_ui/src/foundation/theme/component_themes/oi_button_size_styles.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_button_variant_style.dart';

export 'oi_button_size_style.dart';
export 'oi_button_size_styles.dart';
export 'oi_button_variant_style.dart';

/// Theme data for button components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults. Per-variant styles allow fine-grained control
/// over each button variant's colors across all interactive states.
///
/// {@category Foundation}
@immutable
class OiButtonThemeData {
  /// Creates an [OiButtonThemeData].
  const OiButtonThemeData({
    this.sizeStyles,
    this.borderRadius,
    this.padding,
    this.iconLabelPadding,
    this.textStyle,
    this.fontSizes,
    this.smallHeight,
    this.mediumHeight,
    this.largeHeight,
    this.height,
    this.minWidth,
    this.iconSize,
    this.iconGap,
    this.smallIconGap,
    this.primaryStyle,
    this.outlineStyle,
    this.ghostStyle,
    this.destructiveStyle,
    this.softStyle,
    this.secondaryStyle,
  });

  /// Opt-in size-specific typography and geometry; null preserves legacy output.
  final OiButtonSizeStyles? sizeStyles;

  /// The corner radius applied to button shapes.
  final BorderRadius? borderRadius;

  /// The internal padding of the button.
  final EdgeInsets? padding;

  /// Optional regular icon-and-label insets: start is the icon side, end the
  /// label side. Trailing icons reverse these insets. Small and icon-only
  /// controls retain [padding]. Null preserves ordinary padding resolution.
  final EdgeInsetsDirectional? iconLabelPadding;

  /// The text style for button labels.
  final TextStyle? textStyle;

  /// Per-size font sizes and weights. Overrides the built-in 12/14/16,
  /// w500 defaults when set.
  final OiButtonFontSizeScale? fontSizes;

  /// Override button height (ignores size/density calculation).
  final double? height;

  /// Large control height.
  final double? largeHeight;

  /// Medium control height.
  final double? mediumHeight;

  /// Small control height.
  final double? smallHeight;

  /// Minimum width constraint for buttons.
  final double? minWidth;

  /// Icon dimension override.
  final double? iconSize;

  /// Gap between icon and label text.
  final double? iconGap;

  /// Small-button icon gap; null retains [iconGap] or the built-in spacing.
  final double? smallIconGap;

  /// Color overrides for the primary button variant.
  final OiButtonVariantStyle? primaryStyle;

  /// Color overrides for the outline button variant.
  final OiButtonVariantStyle? outlineStyle;

  /// Color overrides for the ghost button variant.
  final OiButtonVariantStyle? ghostStyle;

  /// Color overrides for the destructive button variant.
  final OiButtonVariantStyle? destructiveStyle;

  /// Color overrides for the soft button variant.
  final OiButtonVariantStyle? softStyle;

  /// Color overrides for the secondary button variant.
  final OiButtonVariantStyle? secondaryStyle;

  /// Copies legacy tokens and retains the current size styles.
  ///
  /// Use [merge] with a partial theme to override size styles. Keeping this
  /// signature stable preserves existing subclass overrides.
  OiButtonThemeData copyWith({
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    EdgeInsetsDirectional? iconLabelPadding,
    TextStyle? textStyle,
    OiButtonFontSizeScale? fontSizes,
    double? smallHeight,
    double? mediumHeight,
    double? largeHeight,
    double? height,
    double? minWidth,
    double? iconSize,
    double? iconGap,
    double? smallIconGap,
    OiButtonVariantStyle? primaryStyle,
    OiButtonVariantStyle? outlineStyle,
    OiButtonVariantStyle? ghostStyle,
    OiButtonVariantStyle? destructiveStyle,
    OiButtonVariantStyle? softStyle,
    OiButtonVariantStyle? secondaryStyle,
  }) {
    return OiButtonThemeData(
      sizeStyles: sizeStyles,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      iconLabelPadding: iconLabelPadding ?? this.iconLabelPadding,
      textStyle: textStyle ?? this.textStyle,
      fontSizes: fontSizes ?? this.fontSizes,
      smallHeight: smallHeight ?? this.smallHeight,
      mediumHeight: mediumHeight ?? this.mediumHeight,
      largeHeight: largeHeight ?? this.largeHeight,
      height: height ?? this.height,
      minWidth: minWidth ?? this.minWidth,
      iconSize: iconSize ?? this.iconSize,
      iconGap: iconGap ?? this.iconGap,
      smallIconGap: smallIconGap ?? this.smallIconGap,
      primaryStyle: primaryStyle ?? this.primaryStyle,
      outlineStyle: outlineStyle ?? this.outlineStyle,
      ghostStyle: ghostStyle ?? this.ghostStyle,
      destructiveStyle: destructiveStyle ?? this.destructiveStyle,
      softStyle: softStyle ?? this.softStyle,
      secondaryStyle: secondaryStyle ?? this.secondaryStyle,
    );
  }

  /// Applies non-null overrides while retaining inherited state and size styles.
  OiButtonThemeData merge(OiButtonThemeData? other) {
    if (other == null) return this;
    return OiButtonThemeData(
      sizeStyles: sizeStyles?.merge(other.sizeStyles) ?? other.sizeStyles,
      borderRadius: other.borderRadius ?? borderRadius,
      padding: other.padding ?? padding,
      iconLabelPadding: other.iconLabelPadding ?? iconLabelPadding,
      textStyle: textStyle?.merge(other.textStyle) ?? other.textStyle,
      fontSizes: other.fontSizes ?? fontSizes,
      height: other.height ?? height,
      largeHeight: other.largeHeight ?? largeHeight,
      mediumHeight: other.mediumHeight ?? mediumHeight,
      smallHeight: other.smallHeight ?? smallHeight,
      minWidth: other.minWidth ?? minWidth,
      iconSize: other.iconSize ?? iconSize,
      iconGap: other.iconGap ?? iconGap,
      smallIconGap: other.smallIconGap ?? smallIconGap,
      primaryStyle:
          primaryStyle?.merge(other.primaryStyle) ?? other.primaryStyle,
      outlineStyle:
          outlineStyle?.merge(other.outlineStyle) ?? other.outlineStyle,
      ghostStyle: ghostStyle?.merge(other.ghostStyle) ?? other.ghostStyle,
      destructiveStyle:
          destructiveStyle?.merge(other.destructiveStyle) ??
          other.destructiveStyle,
      softStyle: softStyle?.merge(other.softStyle) ?? other.softStyle,
      secondaryStyle:
          secondaryStyle?.merge(other.secondaryStyle) ?? other.secondaryStyle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiButtonThemeData &&
        other.sizeStyles == sizeStyles &&
        other.largeHeight == largeHeight &&
        other.mediumHeight == mediumHeight &&
        other.smallHeight == smallHeight &&
        other.borderRadius == borderRadius &&
        other.padding == padding &&
        other.iconLabelPadding == iconLabelPadding &&
        other.textStyle == textStyle &&
        other.fontSizes == fontSizes &&
        other.height == height &&
        other.minWidth == minWidth &&
        other.iconSize == iconSize &&
        other.iconGap == iconGap &&
        other.smallIconGap == smallIconGap &&
        other.primaryStyle == primaryStyle &&
        other.outlineStyle == outlineStyle &&
        other.ghostStyle == ghostStyle &&
        other.destructiveStyle == destructiveStyle &&
        other.softStyle == softStyle &&
        other.secondaryStyle == secondaryStyle;
  }

  @override
  int get hashCode => Object.hash(
    sizeStyles,
    borderRadius,
    padding,
    iconLabelPadding,
    textStyle,
    fontSizes,
    Object.hash(largeHeight, mediumHeight, smallHeight, height),
    minWidth,
    iconSize,
    iconGap,
    smallIconGap,
    primaryStyle,
    outlineStyle,
    ghostStyle,
    destructiveStyle,
    softStyle,
    secondaryStyle,
  );
}
