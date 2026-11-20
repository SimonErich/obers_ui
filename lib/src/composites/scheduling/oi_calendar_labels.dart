import 'package:obers_ui/src/composites/scheduling/oi_calendar.dart';

/// The texts of an [OiCalendar], in English by default; pass translations to
/// localize the calendar.
///
/// Weekday and month names are separate lists on the calendar itself
/// ([OiCalendar.weekdayLabels] and [OiCalendar.monthLabels]).
///
/// {@category Composites}
class OiCalendarLabels {
  /// Creates an [OiCalendarLabels].
  const OiCalendarLabels({
    this.day = 'Day',
    this.week = 'Week',
    this.month = 'Month',
    this.weekNumberHeader = 'Wk',
  });

  /// "Day": the mode switch for [OiCalendarMode.day].
  final String day;

  /// "Week": the mode switch for [OiCalendarMode.week].
  final String week;

  /// "Month": the mode switch for [OiCalendarMode.month].
  final String month;

  /// "Wk": the header of the week number column in the month view.
  final String weekNumberHeader;

  /// The name of [mode] on the mode switch.
  String modeName(OiCalendarMode mode) => switch (mode) {
    OiCalendarMode.day => day,
    OiCalendarMode.week => week,
    OiCalendarMode.month => month,
  };
}
