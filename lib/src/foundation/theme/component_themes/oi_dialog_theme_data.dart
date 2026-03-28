import 'package:flutter/widgets.dart';

/// Theme data for dialog components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiDialogThemeData {
  /// Creates an [OiDialogThemeData].
  const OiDialogThemeData({
    this.borderRadius,
    this.maxWidth,
    this.contentPadding,
    this.titleBodyGap,
    this.contentButtonGap,
    this.buttonGap,
    this.backgroundColor,
    this.shadow,
  });

  /// The corner radius of the dialog surface.
  final BorderRadius? borderRadius;

  /// The maximum width of the dialog in logical pixels.
  final double? maxWidth;

  /// Padding around the dialog content area.
  final EdgeInsets? contentPadding;

  /// Vertical gap between the title and body text.
  final double? titleBodyGap;

  /// Vertical gap between the content area and the button grid.
  final double? contentButtonGap;

  /// Horizontal gap between action buttons.
  final double? buttonGap;

  /// Background color override for the dialog surface.
  final Color? backgroundColor;

  /// Explicit shadow override for the dialog.
  final List<BoxShadow>? shadow;

  /// Creates a copy with optionally overridden values.
  OiDialogThemeData copyWith({
    BorderRadius? borderRadius,
    double? maxWidth,
    EdgeInsets? contentPadding,
    double? titleBodyGap,
    double? contentButtonGap,
    double? buttonGap,
    Color? backgroundColor,
    List<BoxShadow>? shadow,
  }) {
    return OiDialogThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      maxWidth: maxWidth ?? this.maxWidth,
      contentPadding: contentPadding ?? this.contentPadding,
      titleBodyGap: titleBodyGap ?? this.titleBodyGap,
      contentButtonGap: contentButtonGap ?? this.contentButtonGap,
      buttonGap: buttonGap ?? this.buttonGap,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiDialogThemeData) return false;
    if (shadow != null && other.shadow != null) {
      if (shadow!.length != other.shadow!.length) return false;
      for (var i = 0; i < shadow!.length; i++) {
        if (shadow![i] != other.shadow![i]) return false;
      }
    } else if (shadow != other.shadow) {
      return false;
    }
    return other.borderRadius == borderRadius &&
        other.maxWidth == maxWidth &&
        other.contentPadding == contentPadding &&
        other.titleBodyGap == titleBodyGap &&
        other.contentButtonGap == contentButtonGap &&
        other.buttonGap == buttonGap &&
        other.backgroundColor == backgroundColor;
  }

  @override
  int get hashCode => Object.hash(
    borderRadius,
    maxWidth,
    contentPadding,
    titleBodyGap,
    contentButtonGap,
    buttonGap,
    backgroundColor,
    shadow != null ? Object.hashAll(shadow!) : null,
  );
}
