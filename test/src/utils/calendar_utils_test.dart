// Tests are internal; doc comments on local helpers are not required.
// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/utils/calendar_utils.dart';

void main() {
  group('OiCalendarUtils', () {
    group('daysInMonth', () {
      test('returns 31 for January', () {
        expect(OiCalendarUtils.daysInMonth(2025, 1), 31);
      });

      test('returns 28 for February in non-leap year', () {
        expect(OiCalendarUtils.daysInMonth(2025, 2), 28);
      });

      test('returns 29 for February in leap year', () {
        expect(OiCalendarUtils.daysInMonth(2024, 2), 29);
      });

      test('returns 30 for April', () {
        expect(OiCalendarUtils.daysInMonth(2025, 4), 30);
      });

      test('returns 31 for December', () {
        expect(OiCalendarUtils.daysInMonth(2025, 12), 31);
      });

      test('handles year 2000 leap year', () {
        expect(OiCalendarUtils.daysInMonth(2000, 2), 29);
      });

      test('handles year 1900 non-leap year', () {
        expect(OiCalendarUtils.daysInMonth(1900, 2), 28);
      });
    });

    group('firstDayOfWeek', () {
      test('returns Monday for a Wednesday (Monday start)', () {
        // 2025-06-18 is a Wednesday
        final date = DateTime(2025, 6, 18);
        final result = OiCalendarUtils.firstDayOfWeek(date);
        expect(result, DateTime(2025, 6, 16)); // Monday
        expect(result.weekday, DateTime.monday);
      });

      test('returns the same day if already the first day', () {
        // 2025-06-16 is a Monday
        final date = DateTime(2025, 6, 16);
        final result = OiCalendarUtils.firstDayOfWeek(date);
        expect(result, DateTime(2025, 6, 16));
      });

      test('returns Sunday for a Wednesday (Sunday start)', () {
        // 2025-06-18 is a Wednesday
        final date = DateTime(2025, 6, 18);
        final result = OiCalendarUtils.firstDayOfWeek(
          date,
          startOfWeek: DateTime.sunday,
        );
        expect(result, DateTime(2025, 6, 15)); // Sunday
        expect(result.weekday, DateTime.sunday);
      });

      test('handles month boundary', () {
        // 2025-07-01 is a Tuesday
        final date = DateTime(2025, 7, 1);
        final result = OiCalendarUtils.firstDayOfWeek(date);
        expect(result, DateTime(2025, 6, 30)); // Monday
      });
    });

    group('lastDayOfWeek', () {
      test('returns Sunday for a Wednesday (Monday start)', () {
        // 2025-06-18 is a Wednesday
        final date = DateTime(2025, 6, 18);
        final result = OiCalendarUtils.lastDayOfWeek(date);
        expect(result, DateTime(2025, 6, 22)); // Sunday
        expect(result.weekday, DateTime.sunday);
      });

      test('returns Saturday for a Wednesday (Sunday start)', () {
        final date = DateTime(2025, 6, 18);
        final result = OiCalendarUtils.lastDayOfWeek(
          date,
          startOfWeek: DateTime.sunday,
        );
        expect(result, DateTime(2025, 6, 21)); // Saturday
        expect(result.weekday, DateTime.saturday);
      });

      test('returns the same day if already the last day', () {
        // 2025-06-22 is a Sunday
        final date = DateTime(2025, 6, 22);
        final result = OiCalendarUtils.lastDayOfWeek(date);
        expect(result, DateTime(2025, 6, 22));
      });
    });

    group('firstDayOfMonth', () {
      test('returns the first day', () {
        final date = DateTime(2025, 6, 18);
        expect(OiCalendarUtils.firstDayOfMonth(date), DateTime(2025, 6, 1));
      });

      test('returns same if already first', () {
        final date = DateTime(2025, 6, 1);
        expect(OiCalendarUtils.firstDayOfMonth(date), DateTime(2025, 6, 1));
      });
    });

    group('lastDayOfMonth', () {
      test('returns the last day of June (30)', () {
        final date = DateTime(2025, 6, 15);
        expect(OiCalendarUtils.lastDayOfMonth(date), DateTime(2025, 6, 30));
      });

      test('returns the last day of February in leap year', () {
        final date = DateTime(2024, 2, 15);
        expect(OiCalendarUtils.lastDayOfMonth(date), DateTime(2024, 2, 29));
      });

      test('returns the last day of December', () {
        final date = DateTime(2025, 12, 1);
        expect(OiCalendarUtils.lastDayOfMonth(date), DateTime(2025, 12, 31));
      });
    });

    group('isSameDay', () {
      test('returns true for same day', () {
        final a = DateTime(2025, 6, 15, 10, 30);
        final b = DateTime(2025, 6, 15, 22, 45);
        expect(OiCalendarUtils.isSameDay(a, b), isTrue);
      });

      test('returns false for different days', () {
        final a = DateTime(2025, 6, 15);
        final b = DateTime(2025, 6, 16);
        expect(OiCalendarUtils.isSameDay(a, b), isFalse);
      });

      test('returns false for different months', () {
        final a = DateTime(2025, 6, 15);
        final b = DateTime(2025, 7, 15);
        expect(OiCalendarUtils.isSameDay(a, b), isFalse);
      });

      test('returns false for different years', () {
        final a = DateTime(2025, 6, 15);
        final b = DateTime(2024, 6, 15);
        expect(OiCalendarUtils.isSameDay(a, b), isFalse);
      });
    });

    group('isToday', () {
      test('returns true for today', () {
        expect(OiCalendarUtils.isToday(DateTime.now()), isTrue);
      });

      test('returns false for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(OiCalendarUtils.isToday(yesterday), isFalse);
      });

      test('returns false for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(OiCalendarUtils.isToday(tomorrow), isFalse);
      });
    });

    group('isWeekend', () {
      test('Saturday is weekend', () {
        // 2025-06-14 is a Saturday
        expect(OiCalendarUtils.isWeekend(DateTime(2025, 6, 14)), isTrue);
      });

      test('Sunday is weekend', () {
        // 2025-06-15 is a Sunday
        expect(OiCalendarUtils.isWeekend(DateTime(2025, 6, 15)), isTrue);
      });

      test('Monday is not weekend', () {
        // 2025-06-16 is a Monday
        expect(OiCalendarUtils.isWeekend(DateTime(2025, 6, 16)), isFalse);
      });

      test('Friday is not weekend', () {
        // 2025-06-13 is a Friday
        expect(OiCalendarUtils.isWeekend(DateTime(2025, 6, 13)), isFalse);
      });
    });

    group('weekNumber', () {
      test('returns week 1 for Jan 1, 2025', () {
        // 2025-01-01 is a Wednesday, part of week 1
        expect(OiCalendarUtils.weekNumber(DateTime(2025, 1, 1)), 1);
      });

      test('returns week 52 or 53 for end of year', () {
        // 2025-12-31 is a Wednesday, should be week 1 of 2026
        final week = OiCalendarUtils.weekNumber(DateTime(2025, 12, 31));
        expect(week, equals(1));
      });

      test('returns week 1 for first Thursday of year', () {
        // 2025-01-02 is a Thursday
        expect(OiCalendarUtils.weekNumber(DateTime(2025, 1, 2)), 1);
      });

      test('handles Dec 28 which is always in the last week of the year', () {
        final week = OiCalendarUtils.weekNumber(DateTime(2025, 12, 28));
        expect(week, greaterThanOrEqualTo(52));
      });

      test('2024-12-30 is week 1 of 2025', () {
        // 2024-12-30 is a Monday; ISO week 1 of 2025
        expect(OiCalendarUtils.weekNumber(DateTime(2024, 12, 30)), 1);
      });
    });

    group('monthGrid', () {
      test('returns a grid with complete weeks', () {
        final grid = OiCalendarUtils.monthGrid(2025, 6);
        // Grid should be divisible by 7 (complete weeks)
        expect(grid.length % 7, 0);
      });

      test('first day is a Monday by default', () {
        final grid = OiCalendarUtils.monthGrid(2025, 6);
        expect(grid.first.weekday, DateTime.monday);
      });

      test('last day is a Sunday by default', () {
        final grid = OiCalendarUtils.monthGrid(2025, 6);
        expect(grid.last.weekday, DateTime.sunday);
      });

      test('contains all days of the month', () {
        final grid = OiCalendarUtils.monthGrid(2025, 6);
        for (var day = 1; day <= 30; day++) {
          expect(
            grid.contains(DateTime(2025, 6, day)),
            isTrue,
            reason: 'Missing June $day',
          );
        }
      });

      test('first day is Sunday when configured', () {
        final grid = OiCalendarUtils.monthGrid(
          2025,
          6,
          startOfWeek: DateTime.sunday,
        );
        expect(grid.first.weekday, DateTime.sunday);
      });

      test('contains overflow days from previous month', () {
        // June 2025 starts on a Sunday, so with Monday start,
        // the grid should start on May 26 (Monday).
        final grid = OiCalendarUtils.monthGrid(2025, 6);
        expect(grid.first.isBefore(DateTime(2025, 6, 1)), isTrue);
      });
    });

    group('parseNaturalDate', () {
      final ref = DateTime(2025, 6, 18, 12); // Wednesday

      test('parses "today"', () {
        final result = OiCalendarUtils.parseNaturalDate(
          'today',
          relativeTo: ref,
        );
        expect(result, DateTime(2025, 6, 18));
      });

      test('parses "tomorrow"', () {
        final result = OiCalendarUtils.parseNaturalDate(
          'tomorrow',
          relativeTo: ref,
        );
        expect(result, DateTime(2025, 6, 19));
      });

      test('parses "yesterday"', () {
        final result = OiCalendarUtils.parseNaturalDate(
          'yesterday',
          relativeTo: ref,
        );
        expect(result, DateTime(2025, 6, 17));
      });

      test('parses "next friday"', () {
        final result = OiCalendarUtils.parseNaturalDate(
          'next friday',
          relativeTo: ref,
        );
        expect(result, DateTime(2025, 6, 20));
        expect(result!.weekday, DateTime.friday);
      });

      test('parses "next monday"', () {
        // ref is Wednesday, next Monday is 5 days later
        final result = OiCalendarUtils.parseNaturalDate(
          'next monday',
          relativeTo: ref,
        );
        expect(result, DateTime(2025, 6, 23));
        expect(result!.weekday, DateTime.monday);
      });

      test('parses "last monday"', () {
        final result = OiCalendarUtils.parseNaturalDate(
          'last monday',
          relativeTo: ref,
        );
        expect(result, DateTime(2025, 6, 16));
        expect(result!.weekday, DateTime.monday);
      });

      test('parses "dec 25"', () {
        final result = OiCalendarUtils.parseNaturalDate(
          'dec 25',
          relativeTo: ref,
        );
        expect(result, DateTime(2025, 12, 25));
      });

      test('parses "january 1, 2026"', () {
        final result = OiCalendarUtils.parseNaturalDate(
          'january 1, 2026',
          relativeTo: ref,
        );
        expect(result, DateTime(2026, 1, 1));
      });

      test('returns null for unrecognized input', () {
        expect(
          OiCalendarUtils.parseNaturalDate('gibberish', relativeTo: ref),
          isNull,
        );
      });

      test('handles case insensitivity', () {
        final result = OiCalendarUtils.parseNaturalDate(
          'TOMORROW',
          relativeTo: ref,
        );
        expect(result, DateTime(2025, 6, 19));
      });

      test('handles leading/trailing whitespace', () {
        final result = OiCalendarUtils.parseNaturalDate(
          '  tomorrow  ',
          relativeTo: ref,
        );
        expect(result, DateTime(2025, 6, 19));
      });
    });

    group('dateRange', () {
      test('returns inclusive range', () {
        final range = OiCalendarUtils.dateRange(
          DateTime(2025, 6, 15),
          DateTime(2025, 6, 18),
        );
        expect(range.length, 4);
        expect(range.first, DateTime(2025, 6, 15));
        expect(range.last, DateTime(2025, 6, 18));
      });

      test('returns single day for same start and end', () {
        final range = OiCalendarUtils.dateRange(
          DateTime(2025, 6, 15),
          DateTime(2025, 6, 15),
        );
        expect(range.length, 1);
        expect(range.first, DateTime(2025, 6, 15));
      });

      test('returns empty list when start is after end', () {
        final range = OiCalendarUtils.dateRange(
          DateTime(2025, 6, 18),
          DateTime(2025, 6, 15),
        );
        expect(range, isEmpty);
      });

      test('crosses month boundary', () {
        final range = OiCalendarUtils.dateRange(
          DateTime(2025, 6, 29),
          DateTime(2025, 7, 2),
        );
        expect(range.length, 4);
        expect(range[1], DateTime(2025, 6, 30));
        expect(range[2], DateTime(2025, 7, 1));
      });

      test('ignores time components', () {
        final range = OiCalendarUtils.dateRange(
          DateTime(2025, 6, 15, 23, 59),
          DateTime(2025, 6, 17, 0, 1),
        );
        expect(range.length, 3);
      });
    });
  });
}
