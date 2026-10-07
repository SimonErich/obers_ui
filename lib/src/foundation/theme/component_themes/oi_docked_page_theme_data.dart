import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';

/// Responsive page insets and dock presentation.
///
/// {@category Foundation}
@immutable
class OiDockedPageThemeData {
  /// Creates visual tokens; omitted values inherit the surrounding theme.
  const OiDockedPageThemeData({
    this.backgroundColor,
    this.dockDecoration,
    this.headerPadding,
    this.bodyPadding,
    this.bodyPaddingWithHeader,
    this.dockPadding,
    this.maxWidth,
  });

  /// Page background; defaults to the theme background.
  final Color? backgroundColor;

  /// Full width dock fill and border.
  final Decoration? dockDecoration;

  /// Insets around the header within the content width.
  final OiResponsive<EdgeInsetsGeometry>? headerPadding;

  /// Insets around the scrolling body.
  final OiResponsive<EdgeInsetsGeometry>? bodyPadding;

  /// Body insets when a header is present.
  final OiResponsive<EdgeInsetsGeometry>? bodyPaddingWithHeader;

  /// Insets around dock content within the content width.
  final OiResponsive<EdgeInsetsGeometry>? dockPadding;

  /// Maximum content width; the dock background remains full width.
  final double? maxWidth;

  /// Creates a copy with selected tokens replaced.
  OiDockedPageThemeData copyWith({
    Color? backgroundColor,
    Decoration? dockDecoration,
    OiResponsive<EdgeInsetsGeometry>? headerPadding,
    OiResponsive<EdgeInsetsGeometry>? bodyPadding,
    OiResponsive<EdgeInsetsGeometry>? bodyPaddingWithHeader,
    OiResponsive<EdgeInsetsGeometry>? dockPadding,
    double? maxWidth,
  }) => OiDockedPageThemeData(
    backgroundColor: backgroundColor ?? this.backgroundColor,
    dockDecoration: dockDecoration ?? this.dockDecoration,
    headerPadding: headerPadding ?? this.headerPadding,
    bodyPadding: bodyPadding ?? this.bodyPadding,
    bodyPaddingWithHeader: bodyPaddingWithHeader ?? this.bodyPaddingWithHeader,
    dockPadding: dockPadding ?? this.dockPadding,
    maxWidth: maxWidth ?? this.maxWidth,
  );

  @override
  bool operator ==(Object other) =>
      other is OiDockedPageThemeData &&
      other.backgroundColor == backgroundColor &&
      other.dockDecoration == dockDecoration &&
      other.headerPadding == headerPadding &&
      other.bodyPadding == bodyPadding &&
      other.bodyPaddingWithHeader == bodyPaddingWithHeader &&
      other.dockPadding == dockPadding &&
      other.maxWidth == maxWidth;

  @override
  int get hashCode => Object.hashAll([
    backgroundColor,
    dockDecoration,
    headerPadding,
    bodyPadding,
    bodyPaddingWithHeader,
    dockPadding,
    maxWidth,
  ]);
}
