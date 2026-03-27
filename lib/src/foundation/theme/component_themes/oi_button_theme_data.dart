import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';

/// Per-variant color overrides for button states.
///
/// All fields are nullable; a `null` value instructs the button to derive
/// colors from [OiColorScheme] swatches as usual.
///
/// {@category Foundation}
@immutable
class OiButtonVariantStyle {
  /// Creates an [OiButtonVariantStyle].
  const OiButtonVariantStyle({
    this.background,
    this.backgroundHover,
    this.backgroundPressed,
    this.backgroundDisabled,
    this.foreground,
    this.foregroundDisabled,
    this.border,
    this.borderHover,
    this.borderPressed,
    this.borderDisabled,
  });

  /// Default background color.
  final Color? background;

  /// Background color on pointer hover.
  final Color? backgroundHover;

  /// Background color when pressed.
  final Color? backgroundPressed;

  /// Background color when disabled.
  final Color? backgroundDisabled;

  /// Foreground (label/icon) color.
  final Color? foreground;

  /// Foreground color when disabled.
  final Color? foregroundDisabled;

  /// Border color in default state.
  final Color? border;

  /// Border color on pointer hover.
  final Color? borderHover;

  /// Border color when pressed.
  final Color? borderPressed;

  /// Border color when disabled.
  final Color? borderDisabled;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiButtonVariantStyle &&
        other.background == background &&
        other.backgroundHover == backgroundHover &&
        other.backgroundPressed == backgroundPressed &&
        other.backgroundDisabled == backgroundDisabled &&
        other.foreground == foreground &&
        other.foregroundDisabled == foregroundDisabled &&
        other.border == border &&
        other.borderHover == borderHover &&
        other.borderPressed == borderPressed &&
        other.borderDisabled == borderDisabled;
  }

  @override
  int get hashCode => Object.hash(
    background,
    backgroundHover,
    backgroundPressed,
    backgroundDisabled,
    foreground,
    foregroundDisabled,
    border,
    borderHover,
    borderPressed,
    borderDisabled,
  );
}

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
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.height,
    this.minWidth,
    this.iconSize,
    this.iconGap,
    this.primaryStyle,
    this.outlineStyle,
    this.ghostStyle,
    this.destructiveStyle,
    this.softStyle,
    this.secondaryStyle,
  });

  /// The corner radius applied to button shapes.
  final BorderRadius? borderRadius;

  /// The internal padding of the button.
  final EdgeInsets? padding;

  /// The text style for button labels.
  final TextStyle? textStyle;

  /// Override button height (ignores size/density calculation).
  final double? height;

  /// Minimum width constraint for buttons.
  final double? minWidth;

  /// Icon dimension override.
  final double? iconSize;

  /// Gap between icon and label text.
  final double? iconGap;

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

  /// Creates a copy with optionally overridden values.
  OiButtonThemeData copyWith({
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    TextStyle? textStyle,
    double? height,
    double? minWidth,
    double? iconSize,
    double? iconGap,
    OiButtonVariantStyle? primaryStyle,
    OiButtonVariantStyle? outlineStyle,
    OiButtonVariantStyle? ghostStyle,
    OiButtonVariantStyle? destructiveStyle,
    OiButtonVariantStyle? softStyle,
    OiButtonVariantStyle? secondaryStyle,
  }) {
    return OiButtonThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
      height: height ?? this.height,
      minWidth: minWidth ?? this.minWidth,
      iconSize: iconSize ?? this.iconSize,
      iconGap: iconGap ?? this.iconGap,
      primaryStyle: primaryStyle ?? this.primaryStyle,
      outlineStyle: outlineStyle ?? this.outlineStyle,
      ghostStyle: ghostStyle ?? this.ghostStyle,
      destructiveStyle: destructiveStyle ?? this.destructiveStyle,
      softStyle: softStyle ?? this.softStyle,
      secondaryStyle: secondaryStyle ?? this.secondaryStyle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiButtonThemeData &&
        other.borderRadius == borderRadius &&
        other.padding == padding &&
        other.textStyle == textStyle &&
        other.height == height &&
        other.minWidth == minWidth &&
        other.iconSize == iconSize &&
        other.iconGap == iconGap &&
        other.primaryStyle == primaryStyle &&
        other.outlineStyle == outlineStyle &&
        other.ghostStyle == ghostStyle &&
        other.destructiveStyle == destructiveStyle &&
        other.softStyle == softStyle &&
        other.secondaryStyle == secondaryStyle;
  }

  @override
  int get hashCode => Object.hash(
    borderRadius,
    padding,
    textStyle,
    height,
    minWidth,
    iconSize,
    iconGap,
    primaryStyle,
    outlineStyle,
    ghostStyle,
    destructiveStyle,
    softStyle,
    secondaryStyle,
  );
}
