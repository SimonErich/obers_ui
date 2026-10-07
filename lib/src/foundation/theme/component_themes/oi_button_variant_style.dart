import 'package:flutter/widgets.dart';

/// Per-variant color overrides for button states.
///
/// All fields are nullable; a `null` value instructs the button to derive
/// colors from semantic swatches as usual.
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
    this.foregroundHover,
    this.foregroundPressed,
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

  /// Foreground color on pointer hover.
  final Color? foregroundHover;

  /// Foreground color when pressed.
  final Color? foregroundPressed;

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

  /// Applies non-null overrides while retaining inherited state and size styles.
  OiButtonVariantStyle merge(OiButtonVariantStyle? other) {
    if (other == null) return this;
    return OiButtonVariantStyle(
      background: other.background ?? background,
      backgroundHover: other.backgroundHover ?? backgroundHover,
      backgroundPressed: other.backgroundPressed ?? backgroundPressed,
      backgroundDisabled: other.backgroundDisabled ?? backgroundDisabled,
      foreground: other.foreground ?? foreground,
      foregroundHover: other.foregroundHover ?? foregroundHover,
      foregroundPressed: other.foregroundPressed ?? foregroundPressed,
      foregroundDisabled: other.foregroundDisabled ?? foregroundDisabled,
      border: other.border ?? border,
      borderHover: other.borderHover ?? borderHover,
      borderPressed: other.borderPressed ?? borderPressed,
      borderDisabled: other.borderDisabled ?? borderDisabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiButtonVariantStyle &&
        other.background == background &&
        other.backgroundHover == backgroundHover &&
        other.backgroundPressed == backgroundPressed &&
        other.backgroundDisabled == backgroundDisabled &&
        other.foreground == foreground &&
        other.foregroundHover == foregroundHover &&
        other.foregroundPressed == foregroundPressed &&
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
    foregroundHover,
    foregroundPressed,
    foregroundDisabled,
    border,
    borderHover,
    borderPressed,
    borderDisabled,
  );
}
