import 'package:flutter/widgets.dart';

/// Theme data for data-table components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiTableThemeData {
  /// Creates an [OiTableThemeData].
  const OiTableThemeData({this.headerHeight, this.rowHeight, this.borderColor});

  /// The height of the table header row in logical pixels.
  final double? headerHeight;

  /// The height of each data row in logical pixels.
  final double? rowHeight;

  /// The color of the table border and row dividers.
  final Color? borderColor;

  /// Creates a copy with optionally overridden values.
  OiTableThemeData copyWith({
    double? headerHeight,
    double? rowHeight,
    Color? borderColor,
  }) {
    return OiTableThemeData(
      headerHeight: headerHeight ?? this.headerHeight,
      rowHeight: rowHeight ?? this.rowHeight,
      borderColor: borderColor ?? this.borderColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiTableThemeData &&
        other.headerHeight == headerHeight &&
        other.rowHeight == rowHeight &&
        other.borderColor == borderColor;
  }

  @override
  int get hashCode => Object.hash(headerHeight, rowHeight, borderColor);
}
