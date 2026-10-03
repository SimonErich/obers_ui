import 'package:flutter/widgets.dart';

/// Theme overrides for modal sheets.
///
/// Explicit widget properties override these values. Null uses semantic defaults.
@immutable
class OiSheetThemeData {
  /// Creates theme overrides for sheet.
  const OiSheetThemeData({
    this.borderRadius,
    this.inset,
    this.backgroundColor,
    this.barrierColor,
    this.shadow,
    this.headerPadding,
    this.footerPadding,
  });

  /// Sheet corner radius.
  final BorderRadius? borderRadius;

  /// Distance from the viewport edges.
  final EdgeInsetsGeometry? inset;

  /// Panel surface.
  final Color? backgroundColor;

  /// Modal scrim color.
  final Color? barrierColor;

  /// Panel shadows.
  final List<BoxShadow>? shadow;

  /// Header insets.
  final EdgeInsetsGeometry? headerPadding;

  /// Footer insets.
  final EdgeInsetsGeometry? footerPadding;

  /// Returns a copy with the supplied overrides.
  OiSheetThemeData copyWith({
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? inset,
    Color? backgroundColor,
    Color? barrierColor,
    List<BoxShadow>? shadow,
    EdgeInsetsGeometry? headerPadding,
    EdgeInsetsGeometry? footerPadding,
  }) => OiSheetThemeData(
    borderRadius: borderRadius ?? this.borderRadius,
    inset: inset ?? this.inset,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    barrierColor: barrierColor ?? this.barrierColor,
    shadow: shadow ?? this.shadow,
    headerPadding: headerPadding ?? this.headerPadding,
    footerPadding: footerPadding ?? this.footerPadding,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiSheetThemeData &&
          other.borderRadius == borderRadius &&
          other.inset == inset &&
          other.backgroundColor == backgroundColor &&
          other.barrierColor == barrierColor &&
          other.shadow == shadow &&
          other.headerPadding == headerPadding &&
          other.footerPadding == footerPadding;

  @override
  int get hashCode => Object.hashAll([
    borderRadius,
    inset,
    backgroundColor,
    barrierColor,
    shadow,
    headerPadding,
    footerPadding,
  ]);
}
