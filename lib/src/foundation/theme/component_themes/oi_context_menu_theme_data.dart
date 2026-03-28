import 'package:flutter/widgets.dart';

/// Theme data for context menu components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiContextMenuThemeData {
  /// Creates an [OiContextMenuThemeData].
  const OiContextMenuThemeData({
    this.borderRadius,
    this.minWidth,
    this.maxWidth,
    this.maxHeight,
    this.backgroundColor,
    this.borderColor,
    this.shadow,
  });

  /// The corner radius applied to the menu panel.
  final BorderRadius? borderRadius;

  /// The minimum width of the menu panel.
  final double? minWidth;

  /// The maximum width of the menu panel.
  final double? maxWidth;

  /// The maximum height of the menu panel before it becomes scrollable.
  final double? maxHeight;

  /// The background color of the menu panel.
  final Color? backgroundColor;

  /// The border color of the menu panel.
  final Color? borderColor;

  /// The box shadows applied to the menu panel.
  final List<BoxShadow>? shadow;

  /// Creates a copy with optionally overridden values.
  OiContextMenuThemeData copyWith({
    BorderRadius? borderRadius,
    double? minWidth,
    double? maxWidth,
    double? maxHeight,
    Color? backgroundColor,
    Color? borderColor,
    List<BoxShadow>? shadow,
  }) {
    return OiContextMenuThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiContextMenuThemeData) return false;
    // BoxShadow lists require deep comparison; use toString as pragmatic check.
    return other.borderRadius == borderRadius &&
        other.minWidth == minWidth &&
        other.maxWidth == maxWidth &&
        other.maxHeight == maxHeight &&
        other.backgroundColor == backgroundColor &&
        other.borderColor == borderColor &&
        '${other.shadow}' == '$shadow';
  }

  @override
  int get hashCode => Object.hash(
    borderRadius,
    minWidth,
    maxWidth,
    maxHeight,
    backgroundColor,
    borderColor,
    shadow.toString(),
  );
}
