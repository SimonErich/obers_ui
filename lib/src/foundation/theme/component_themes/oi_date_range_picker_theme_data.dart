import 'package:flutter/widgets.dart';

/// Theme data for date range picker components.
///
/// {@category Foundation}
@immutable
class OiDateRangePickerThemeData {
  /// Creates an [OiDateRangePickerThemeData].
  const OiDateRangePickerThemeData({
    this.presetPanelWidth,
    this.calendarSpacing,
    this.footerPadding,
  });

  /// Width of the preset shortcuts panel shown beside the calendars.
  final double? presetPanelWidth;

  /// Horizontal gap between the two calendar months.
  final double? calendarSpacing;

  /// Padding applied around the footer action row.
  final EdgeInsetsGeometry? footerPadding;

  /// Creates a copy with optionally overridden values.
  OiDateRangePickerThemeData copyWith({
    double? presetPanelWidth,
    double? calendarSpacing,
    EdgeInsetsGeometry? footerPadding,
  }) {
    return OiDateRangePickerThemeData(
      presetPanelWidth: presetPanelWidth ?? this.presetPanelWidth,
      calendarSpacing: calendarSpacing ?? this.calendarSpacing,
      footerPadding: footerPadding ?? this.footerPadding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiDateRangePickerThemeData &&
        other.presetPanelWidth == presetPanelWidth &&
        other.calendarSpacing == calendarSpacing &&
        other.footerPadding == footerPadding;
  }

  @override
  int get hashCode =>
      Object.hash(presetPanelWidth, calendarSpacing, footerPadding);
}
