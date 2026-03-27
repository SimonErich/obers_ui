import 'package:flutter/widgets.dart';

/// Theme data for date range picker components.
///
/// {@category Foundation}
@immutable
class OiDateRangePickerThemeData {
  const OiDateRangePickerThemeData({
    this.presetPanelWidth,
    this.calendarSpacing,
    this.footerPadding,
  });

  final double? presetPanelWidth;
  final double? calendarSpacing;
  final EdgeInsetsGeometry? footerPadding;

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
