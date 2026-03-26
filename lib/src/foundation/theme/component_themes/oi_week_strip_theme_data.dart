import 'package:flutter/widgets.dart';

/// Theme data for week strip components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiWeekStripThemeData {
  /// Creates an [OiWeekStripThemeData].
  const OiWeekStripThemeData({this.daySize, this.selectedRadius});

  /// The size (width and height) of each day cell.
  final double? daySize;

  /// The corner radius of the selected-day highlight.
  final BorderRadius? selectedRadius;

  /// Creates a copy with optionally overridden values.
  OiWeekStripThemeData copyWith({
    double? daySize,
    BorderRadius? selectedRadius,
  }) {
    return OiWeekStripThemeData(
      daySize: daySize ?? this.daySize,
      selectedRadius: selectedRadius ?? this.selectedRadius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiWeekStripThemeData &&
        other.daySize == daySize &&
        other.selectedRadius == selectedRadius;
  }

  @override
  int get hashCode => Object.hash(daySize, selectedRadius);
}
