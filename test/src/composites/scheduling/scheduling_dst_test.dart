// Tests do not require documentation comments.

// Daylight-saving regression tests for the calendar and Gantt date maths.
//
// A widget test only meets a daylight-saving change when the process runs in
// a zone that has one, so this file is written to pass in any zone and is run
// twice, here and in CI:
//
//   TZ=UTC flutter test test/src/composites/scheduling/scheduling_dst_test.dart
//   TZ=America/New_York flutter test test/src/composites/scheduling/scheduling_dst_test.dart
//
// In New York, 8 March 2026 is the spring-forward day (23 hours long) and
// 1 November 2026 is the fall-back day (25 hours long).

import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/scheduling/oi_calendar.dart';
import 'package:obers_ui/src/composites/scheduling/oi_gantt.dart';
import 'package:obers_ui/src/utils/calendar_utils.dart';

import '../../../helpers/pump_app.dart';

Widget _calendar({
  required DateTime initialDate,
  ValueChanged<DateTime>? onDateTap,
  bool showWeekNumbers = false,
}) {
  return SizedBox(
    width: 800,
    height: 600,
    child: OiCalendar(
      events: const [],
      label: 'Calendar',
      initialDate: initialDate,
      onDateTap: onDateTap,
      showWeekNumbers: showWeekNumbers,
    ),
  );
}

/// The day numbers of the month grid, in reading order.
List<int> _gridDayNumbers(WidgetTester tester) => [
  for (final text in tester.widgetList<Text>(find.byType(Text)))
    if (int.tryParse(text.data ?? '') case final int day) day,
];

void main() {
  group('time zone', () {
    test('the New York run really has the 2026 transitions', () {
      if (Platform.environment['TZ'] != 'America/New_York') return;
      // Guards against a runner that ignores TZ: without the transitions the
      // rest of this file would pass without testing anything.
      expect(
        DateTime(2026, 3, 9).difference(DateTime(2026, 3, 8)).inHours,
        23,
        reason: '8 Mar 2026 is spring-forward in New York',
      );
      expect(
        DateTime(2026, 11, 2).difference(DateTime(2026, 11)).inHours,
        25,
        reason: '1 Nov 2026 is fall-back in New York',
      );
    });
  });

  group('OiCalendarUtils.addDays', () {
    test('steps over the fall-back day one date at a time', () {
      final start = DateTime(2026, 10, 26);
      final days = [
        for (var n = 0; n < 14; n++) OiCalendarUtils.addDays(start, n),
      ];

      expect(days.map((d) => d.day), [
        26,
        27,
        28,
        29,
        30,
        31,
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
      ]);
      for (final day in days) {
        expect(day, DateTime(day.year, day.month, day.day), reason: '$day');
      }
    });

    test('steps over the spring-forward day one date at a time', () {
      final start = DateTime(2026, 3, 6);
      final days = [
        for (var n = 0; n < 6; n++) OiCalendarUtils.addDays(start, n),
      ];

      expect(days.map((d) => d.day), [6, 7, 8, 9, 10, 11]);
      for (final day in days) {
        expect(day, DateTime(day.year, day.month, day.day), reason: '$day');
      }
    });

    test('steps backwards and drops the time of day', () {
      expect(
        OiCalendarUtils.addDays(DateTime(2026, 11, 2, 15, 30), -1),
        DateTime(2026, 11),
      );
      expect(
        OiCalendarUtils.addDays(DateTime(2026, 3, 9, 15, 30), -1),
        DateTime(2026, 3, 8),
      );
    });
  });

  group('OiCalendarUtils.daysBetween', () {
    test('counts the 23 hour spring-forward day as one day', () {
      expect(
        OiCalendarUtils.daysBetween(DateTime(2026, 3, 8), DateTime(2026, 3, 9)),
        1,
      );
      expect(
        OiCalendarUtils.daysBetween(DateTime(2026, 3), DateTime(2026, 3, 15)),
        14,
      );
    });

    test('counts the 25 hour fall-back day as one day', () {
      expect(
        OiCalendarUtils.daysBetween(DateTime(2026, 11), DateTime(2026, 11, 2)),
        1,
      );
      expect(
        OiCalendarUtils.daysBetween(
          DateTime(2026, 10, 26),
          DateTime(2026, 11, 9),
        ),
        14,
      );
    });

    test('ignores the time of day and is negative backwards', () {
      expect(
        OiCalendarUtils.daysBetween(
          DateTime(2026, 3, 7, 23, 59),
          DateTime(2026, 3, 9, 0, 1),
        ),
        2,
      );
      expect(
        OiCalendarUtils.daysBetween(DateTime(2026, 3, 9), DateTime(2026, 3, 7)),
        -2,
      );
    });
  });

  group('OiCalendarUtils.fractionalDaysBetween', () {
    test('adds the time of day as a fraction', () {
      expect(
        OiCalendarUtils.fractionalDaysBetween(
          DateTime(2026, 6),
          DateTime(2026, 6, 2, 12),
        ),
        1.5,
      );
      expect(
        OiCalendarUtils.fractionalDaysBetween(
          DateTime(2026, 6, 1, 9),
          DateTime(2026, 6, 1, 17),
        ),
        closeTo(8 / 24, 1e-9),
      );
    });

    test('is not shifted by spring-forward', () {
      expect(
        OiCalendarUtils.fractionalDaysBetween(
          DateTime(2026, 3),
          DateTime(2026, 3, 10),
        ),
        9,
      );
      expect(
        OiCalendarUtils.fractionalDaysBetween(
          DateTime(2026, 3),
          DateTime(2026, 3, 9, 12),
        ),
        8.5,
      );
    });

    test('is not shifted by fall-back', () {
      expect(
        OiCalendarUtils.fractionalDaysBetween(
          DateTime(2026, 10, 26),
          DateTime(2026, 11, 2, 6),
        ),
        7.25,
      );
    });
  });

  group('OiCalendarUtils.weekNumber', () {
    test('9 Mar 2026 is in ISO week 11', () {
      expect(OiCalendarUtils.weekNumber(DateTime(2026, 3, 9)), 11);
    });

    test('every Monday of 2026 is one week after the previous one', () {
      // 1 Jan 2026 is a Thursday, so 5 Jan is the Monday of week 2 and the
      // year has 53 weeks.
      final firstMonday = DateTime(2026, 1, 5);
      for (var i = 0; i < 52; i++) {
        final monday = OiCalendarUtils.addDays(firstMonday, i * 7);
        expect(OiCalendarUtils.weekNumber(monday), i + 2, reason: '$monday');
      }
    });
  });

  group('OiCalendar', () {
    testWidgets('the November 2026 grid shows every date once', (tester) async {
      await tester.pumpObers(_calendar(initialDate: DateTime(2026, 11, 15)));

      expect(_gridDayNumbers(tester), [
        for (var d = 26; d <= 31; d++) d,
        for (var d = 1; d <= 30; d++) d,
        for (var d = 1; d <= 6; d++) d,
      ]);
    });

    testWidgets('a cell after fall-back reports its own date', (tester) async {
      DateTime? tapped;
      await tester.pumpObers(
        _calendar(
          initialDate: DateTime(2026, 11, 15),
          onDateTap: (date) => tapped = date,
        ),
      );

      await tester.tap(find.text('15'));
      expect(tapped, DateTime(2026, 11, 15));
    });

    testWidgets('the March 2026 grid shows every date once', (tester) async {
      await tester.pumpObers(_calendar(initialDate: DateTime(2026, 3, 15)));

      expect(_gridDayNumbers(tester), [
        for (var d = 23; d <= 28; d++) d,
        for (var d = 1; d <= 31; d++) d,
        for (var d = 1; d <= 5; d++) d,
      ]);
    });

    testWidgets('week numbers after fall-back are those of their rows', (
      tester,
    ) async {
      await tester.pumpObers(
        _calendar(initialDate: DateTime(2026, 11, 15), showWeekNumbers: true),
      );

      // Rows start on 26 Oct, 2, 9, 16, 23 and 30 Nov.
      for (var week = 44; week <= 49; week++) {
        expect(
          find.byKey(ValueKey('calendar_week_$week')),
          findsOneWidget,
          reason: 'week $week',
        );
      }
    });

    testWidgets('stepping a day forward over fall-back lands on 2 Nov', (
      tester,
    ) async {
      await tester.pumpObers(
        SizedBox(
          width: 800,
          height: 600,
          child: OiCalendar(
            events: const [],
            label: 'Calendar',
            mode: OiCalendarMode.day,
            initialDate: DateTime(2026, 11),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('calendar_forward')));
      await tester.pump();
      expect(find.text('2 November 2026'), findsOneWidget);
    });
  });

  group('OiGantt', () {
    testWidgets('a bar after spring-forward sits in its own column', (
      tester,
    ) async {
      await tester.pumpObers(
        SizedBox(
          width: 1000,
          height: 600,
          child: OiGantt(
            label: 'Gantt',
            zoom: OiGanttZoom.day,
            showToday: false,
            tasks: [
              OiGanttTask(
                key: 'first',
                label: 'First',
                start: DateTime(2026, 3),
                end: DateTime(2026, 3, 2),
              ),
              OiGanttTask(
                key: 'after',
                label: 'After',
                start: DateTime(2026, 3, 10),
                end: DateTime(2026, 3, 12),
              ),
            ],
          ),
        ),
      );

      final origin = tester.getTopLeft(
        find.byKey(const ValueKey('gantt_task_first')),
      );
      final after = tester.getRect(
        find.byKey(const ValueKey('gantt_task_after')),
      );
      // Day zoom is 40px per day; 10 Mar is nine days after 1 Mar.
      expect(after.left - origin.dx, 9 * 40);
      expect(after.width, 2 * 40);
    });
  });
}
