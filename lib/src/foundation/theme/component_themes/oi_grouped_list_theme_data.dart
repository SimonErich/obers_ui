import 'package:flutter/widgets.dart';

/// Theme data for grouped list components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiGroupedListThemeData {
  /// Creates an [OiGroupedListThemeData].
  const OiGroupedListThemeData({
    this.headerPadding,
    this.stickyHeaderColor,
    this.separatorColor,
  });

  /// Padding applied to group headers.
  final EdgeInsetsGeometry? headerPadding;

  /// Background color for sticky headers.
  final Color? stickyHeaderColor;

  /// Color for separators between items.
  final Color? separatorColor;

  /// Creates a copy with optionally overridden values.
  OiGroupedListThemeData copyWith({
    EdgeInsetsGeometry? headerPadding,
    Color? stickyHeaderColor,
    Color? separatorColor,
  }) {
    return OiGroupedListThemeData(
      headerPadding: headerPadding ?? this.headerPadding,
      stickyHeaderColor: stickyHeaderColor ?? this.stickyHeaderColor,
      separatorColor: separatorColor ?? this.separatorColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiGroupedListThemeData &&
        other.headerPadding == headerPadding &&
        other.stickyHeaderColor == stickyHeaderColor &&
        other.separatorColor == separatorColor;
  }

  @override
  int get hashCode =>
      Object.hash(headerPadding, stickyHeaderColor, separatorColor);
}
