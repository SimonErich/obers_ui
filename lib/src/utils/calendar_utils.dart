/// Utility class for calendar and date calculations.
///
/// Provides static methods for computing dates, date ranges, week numbers,
/// and parsing natural language date strings.
///
/// {@category Utils}
class OiCalendarUtils {
  const OiCalendarUtils._();

  /// Returns the number of days in a given [month] and [year].
  ///
  /// [month] is 1-based (1 = January, 12 = December).
  static int daysInMonth(int year, int month) {
    // The 0th day of the next month is the last day of this month.
    return DateTime(year, month + 1, 0).day;
  }

  /// Returns the first day of the week for a given [date].
  ///
  /// [startOfWeek] determines which day starts the week
  /// (default [DateTime.monday]).
  static DateTime firstDayOfWeek(
    DateTime date, {
    int startOfWeek = DateTime.monday,
  }) {
    var diff = (date.weekday - startOfWeek) % 7;
    if (diff < 0) diff += 7;
    return DateTime(date.year, date.month, date.day - diff);
  }

  /// Returns the last day of the week for a given [date].
  ///
  /// [startOfWeek] determines which day starts the week
  /// (default [DateTime.monday]).
  static DateTime lastDayOfWeek(
    DateTime date, {
    int startOfWeek = DateTime.monday,
  }) {
    final first = firstDayOfWeek(date, startOfWeek: startOfWeek);
    return DateTime(first.year, first.month, first.day + 6);
  }

  /// Returns the first day of the month containing [date].
  static DateTime firstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }

  /// Returns the last day of the month containing [date].
  static DateTime lastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Returns whether two dates [a] and [b] are on the same day.
  ///
  /// Ignores time components.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Returns whether [date] is today.
  ///
  /// Compares only year, month, and day components.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  /// Returns whether [date] falls on a weekend (Saturday or Sunday).
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday;
  }

  /// Returns the ISO 8601 week number for [date].
  ///
  /// Week 1 is the week containing the first Thursday of the year.
  static int weekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year)).inDays + 1;
    final weekday = date.weekday; // Mon=1 .. Sun=7

    // ISO week date calculation
    var woy = ((dayOfYear - weekday + 10) / 7).floor();

    if (woy < 1) {
      // Belongs to the last week of the previous year.
      woy = _isoWeeksInYear(date.year - 1);
    } else if (woy > _isoWeeksInYear(date.year)) {
      woy = 1;
    }

    return woy;
  }

  /// Returns all dates in a month grid (including overflow from previous
  /// and next months).
  ///
  /// The grid always contains complete weeks. The number of rows depends
  /// on the month. [startOfWeek] defaults to [DateTime.monday].
  static List<DateTime> monthGrid(
    int year,
    int month, {
    int startOfWeek = DateTime.monday,
  }) {
    final first = DateTime(year, month);
    final start = firstDayOfWeek(first, startOfWeek: startOfWeek);

    final last = DateTime(year, month + 1, 0);
    final end = lastDayOfWeek(last, startOfWeek: startOfWeek);

    final dates = <DateTime>[];
    var current = start;
    while (!current.isAfter(end)) {
      dates.add(current);
      current = DateTime(current.year, current.month, current.day + 1);
    }

    return dates;
  }

  /// Parses natural language date strings like "tomorrow", "next friday",
  /// "dec 25".
  ///
  /// Returns null if the input cannot be parsed.
  /// [relativeTo] defaults to [DateTime.now] if not provided.
  static DateTime? parseNaturalDate(String input, {DateTime? relativeTo}) {
    final ref = relativeTo ?? DateTime.now();
    final normalized = input.trim().toLowerCase();

    // Simple keywords
    if (normalized == 'today') {
      return DateTime(ref.year, ref.month, ref.day);
    }
    if (normalized == 'tomorrow') {
      return DateTime(ref.year, ref.month, ref.day + 1);
    }
    if (normalized == 'yesterday') {
      return DateTime(ref.year, ref.month, ref.day - 1);
    }

    // "next <weekday>"
    final nextDayMatch = RegExp(r'^next\s+(\w+)$').firstMatch(normalized);
    if (nextDayMatch != null) {
      final dayNum = _parseWeekday(nextDayMatch.group(1)!);
      if (dayNum != null) {
        var daysUntil = (dayNum - ref.weekday) % 7;
        if (daysUntil <= 0) daysUntil += 7;
        return DateTime(ref.year, ref.month, ref.day + daysUntil);
      }
    }

    // "last <weekday>"
    final lastDayMatch = RegExp(r'^last\s+(\w+)$').firstMatch(normalized);
    if (lastDayMatch != null) {
      final dayNum = _parseWeekday(lastDayMatch.group(1)!);
      if (dayNum != null) {
        var daysSince = (ref.weekday - dayNum) % 7;
        if (daysSince <= 0) daysSince += 7;
        return DateTime(ref.year, ref.month, ref.day - daysSince);
      }
    }

    // "<month> <day>" or "<month> <day>, <year>"
    final monthDayMatch =
        RegExp(r'^(\w+)\s+(\d{1,2})(?:,?\s+(\d{4}))?$').firstMatch(normalized);
    if (monthDayMatch != null) {
      final monthNum = _parseMonth(monthDayMatch.group(1)!);
      if (monthNum != null) {
        final day = int.parse(monthDayMatch.group(2)!);
        final year = monthDayMatch.group(3) != null
            ? int.parse(monthDayMatch.group(3)!)
            : ref.year;
        return DateTime(year, monthNum, day);
      }
    }

    return null;
  }

  /// Returns a list of dates between [start] and [end] (inclusive).
  ///
  /// Both [start] and [end] dates are included. If [start] is after [end],
  /// returns an empty list.
  static List<DateTime> dateRange(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    if (startDate.isAfter(endDate)) return [];

    final dates = <DateTime>[];
    var current = startDate;
    while (!current.isAfter(endDate)) {
      dates.add(current);
      current = DateTime(current.year, current.month, current.day + 1);
    }

    return dates;
  }

  /// Returns the number of ISO weeks in the given [year].
  static int _isoWeeksInYear(int year) {
    final dec28 = DateTime(year, 12, 28);
    final dayOfYear = dec28.difference(DateTime(year)).inDays + 1;
    return ((dayOfYear - dec28.weekday + 10) / 7).floor();
  }

  /// Parses a weekday name to [DateTime] weekday number (1=Monday..7=Sunday).
  static int? _parseWeekday(String name) {
    const days = {
      'monday': 1, 'mon': 1,
      'tuesday': 2, 'tue': 2, 'tues': 2,
      'wednesday': 3, 'wed': 3,
      'thursday': 4, 'thu': 4, 'thur': 4, 'thurs': 4,
      'friday': 5, 'fri': 5,
      'saturday': 6, 'sat': 6,
      'sunday': 7, 'sun': 7,
    };
    return days[name.toLowerCase()];
  }

  /// Parses a month name (full or abbreviated) to month number (1-12).
  static int? _parseMonth(String name) {
    const months = {
      'january': 1, 'jan': 1,
      'february': 2, 'feb': 2,
      'march': 3, 'mar': 3,
      'april': 4, 'apr': 4,
      'may': 5,
      'june': 6, 'jun': 6,
      'july': 7, 'jul': 7,
      'august': 8, 'aug': 8,
      'september': 9, 'sep': 9, 'sept': 9,
      'october': 10, 'oct': 10,
      'november': 11, 'nov': 11,
      'december': 12, 'dec': 12,
    };
    return months[name.toLowerCase()];
  }
}
