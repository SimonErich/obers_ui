// Tests do not require documentation comments.

// Daylight-saving regression tests for the calendar and Gantt date maths.
//
// A widget test only meets a daylight-saving change when the process runs in
// a zone that has one, so this file is written to pass in any zone and is run
// under several (CI runs the New York one in addition to its own UTC):
//
//   TZ=UTC flutter test test/src/composites/scheduling/scheduling_dst_test.dart
//   TZ=America/New_York flutter test test/src/composites/scheduling/scheduling_dst_test.dart
//   TZ=America/Santiago flutter test test/src/composites/scheduling/scheduling_dst_test.dart
//   TZ=Europe/Berlin flutter test test/src/composites/scheduling/scheduling_dst_test.dart
//
// In New York, 8 March 2026 is the spring-forward day (23 hours long) and
// 1 November 2026 is the fall-back day (25 hours long). In Santiago the
// clocks skip midnight on 6 September 2026, so that day starts at 01:00.

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

/// Matches a list of [DateTime]s that are the first moment of each of
/// [dates] (year, month, day): on that date, and with no earlier moment of
/// the same date. That moment is midnight unless the zone skips it.
Matcher _startsOfDays(List<(int, int, int)> dates) {
  return predicate<List<DateTime>>((days) {
    if (days.length != dates.length) return false;
    for (var i = 0; i < days.length; i++) {
      final day = days[i];
      final (year, month, date) = dates[i];
      if (day.isUtc) return false;
      if (day.year != year || day.month != month || day.day != date) {
        return false;
      }
      final justBefore = day.subtract(const Duration(microseconds: 1));
      if (justBefore.day == date) return false;
    }
    return true;
  }, 'the first moments of $dates');
}

/// The first wall-clock hour of 2026 that does not exist in this zone, as
/// (year, month, day, hour); null when the zone skips none.
(int, int, int, int)? _firstSkippedHour() {
  for (var dayOfYear = 0; dayOfYear < 365; dayOfYear++) {
    final date = DateTime.utc(2026, 1, 1 + dayOfYear);
    for (var hour = 0; hour < 24; hour++) {
      final local = DateTime(date.year, date.month, date.day, hour);
      if (local.hour != hour) return (date.year, date.month, date.day, hour);
    }
  }
  return null;
}

/// The horizontal scroll views of an [OiGantt]: its header, then its body.
Finder _ganttTimeline() => find.byWidgetPredicate(
  (widget) =>
      widget is SingleChildScrollView &&
      widget.scrollDirection == Axis.horizontal,
);

/// The width of the timeline of an [OiGantt].
double _timelineWidth(WidgetTester tester) {
  final view = tester.widget<SingleChildScrollView>(_ganttTimeline().first);
  return (view.child! as SizedBox).width!;
}

void main() {
  group('time zone', () {
    // Whether the zone this process runs in changes its UTC offset in 2026.
    // Found from DateTime itself, so it holds for any zone and any way of
    // selecting it.
    final offsets = {
      for (var month = 1; month <= 12; month++)
        DateTime(2026, month, 15).timeZoneOffset,
    };
    final hasTransition = offsets.length > 1;
    final wantsNewYork = Platform.environment['TZ'] == 'America/New_York';

    test(
      'this run crosses a daylight-saving change',
      () {
        // Without a transition the rest of this file passes without testing
        // the cases it is here for.
        expect(hasTransition, isTrue, reason: 'TZ is set but not honoured');
        if (!wantsNewYork) return;
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
      },
      // A New York run without transitions must fail, not skip.
      skip: hasTransition || wantsNewYork
          ? false
          : 'zone ${DateTime.now().timeZoneName} has no 2026 daylight-saving '
                'change; the tests below only cover plain dates here',
    );
  });

  group('OiCalendarUtils.addDays', () {
    test('steps over the fall-back day one date at a time', () {
      final start = DateTime(2026, 10, 26);
      expect(
        [for (var n = 0; n < 14; n++) OiCalendarUtils.addDays(start, n)],
        _startsOfDays(const [
          (2026, 10, 26),
          (2026, 10, 27),
          (2026, 10, 28),
          (2026, 10, 29),
          (2026, 10, 30),
          (2026, 10, 31),
          (2026, 11, 1),
          (2026, 11, 2),
          (2026, 11, 3),
          (2026, 11, 4),
          (2026, 11, 5),
          (2026, 11, 6),
          (2026, 11, 7),
          (2026, 11, 8),
        ]),
      );
    });

    test('steps over the spring-forward day one date at a time', () {
      final start = DateTime(2026, 3, 6);
      expect(
        [for (var n = 0; n < 6; n++) OiCalendarUtils.addDays(start, n)],
        _startsOfDays(const [
          (2026, 3, 6),
          (2026, 3, 7),
          (2026, 3, 8),
          (2026, 3, 9),
          (2026, 3, 10),
          (2026, 3, 11),
        ]),
      );
    });

    test('steps over a day whose midnight is skipped (Santiago)', () {
      // In Santiago the clocks go from 24:00 on 5 Sep 2026 straight to 01:00
      // on the 6th, so that day has no midnight.
      final start = DateTime(2026, 9, 4);
      expect(
        [for (var n = 0; n < 5; n++) OiCalendarUtils.addDays(start, n)],
        _startsOfDays(const [
          (2026, 9, 4),
          (2026, 9, 5),
          (2026, 9, 6),
          (2026, 9, 7),
          (2026, 9, 8),
        ]),
      );
      expect(
        OiCalendarUtils.addDays(DateTime(2026, 9, 7, 15), -1).day,
        6,
      );
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

    group('an hour the clocks skip', () {
      // The hour this zone skips in 2026 (02:00 on 8 Mar in New York, 00:00
      // on 6 Sep in Santiago). Zones without one use an ordinary hour, which
      // must then behave like any other.
      final skipped = _firstSkippedHour();
      final (year, month, day, hour) = skipped ?? (2026, 3, 8, 2);
      final rowLabel = '${hour.toString().padLeft(2, '0')}:00';
      final events = [
        OiCalendarEvent(
          key: 'after',
          title: 'After the gap',
          start: DateTime(year, month, day, hour + 1),
          end: DateTime(year, month, day, hour + 2),
        ),
      ];

      Widget calendar(OiCalendarMode mode, {ValueChanged<DateTime>? onTap}) {
        return OiCalendar(
          events: events,
          label: 'Calendar',
          mode: mode,
          initialDate: DateTime(year, month, day, 12),
          onDateTap: onTap,
        );
      }

      testWidgets('shows the following event once in the day view', (
        tester,
      ) async {
        await tester.pumpObers(calendar(OiCalendarMode.day));
        expect(find.text('After the gap'), findsOneWidget);
      });

      testWidgets('shows the following event once in the week view', (
        tester,
      ) async {
        await tester.pumpObers(calendar(OiCalendarMode.week));
        expect(find.text('After the gap'), findsOneWidget);
      });

      testWidgets('does not report a tap as the hour after it', (tester) async {
        DateTime? tapped;
        await tester.pumpObers(
          calendar(OiCalendarMode.day, onTap: (date) => tapped = date),
        );

        await tester.tap(find.text(rowLabel));
        expect(
          tapped,
          skipped == null ? DateTime(year, month, day, hour) : isNull,
        );
      });
    });
  });

  group('OiGantt', () {
    Rect bar(WidgetTester tester, String key) =>
        tester.getRect(find.byKey(ValueKey('gantt_task_$key')));

    Widget gantt(List<OiGanttTask> tasks, {DateTime? viewStart}) {
      return OiGantt(
        label: 'Gantt',
        zoom: OiGanttZoom.day,
        showToday: false,
        viewStart: viewStart,
        tasks: tasks,
      );
    }

    testWidgets('UTC dates use their own date and time, like the bars', (
      tester,
    ) async {
      await tester.pumpObers(
        gantt([
          OiGanttTask(
            key: 'a',
            label: 'A',
            start: DateTime.utc(2026, 1, 5),
            end: DateTime.utc(2026, 1, 9, 3),
          ),
        ]),
      );

      // 5 Jan up to the end of 9 Jan, whatever the local zone is.
      expect(_timelineWidth(tester), 5 * 40);
      final rect = bar(tester, 'a');
      expect(rect.left, tester.getTopLeft(_ganttTimeline().last).dx);
      expect(rect.width, closeTo((4 + 3 / 24) * 40, 0.01));
    });

    testWidgets('a UTC midnight end does not add a day', (tester) async {
      await tester.pumpObers(
        gantt([
          OiGanttTask(
            key: 'a',
            label: 'A',
            start: DateTime.utc(2026, 1, 5),
            end: DateTime.utc(2026, 1, 10),
          ),
        ]),
      );

      expect(_timelineWidth(tester), 5 * 40);
      expect(bar(tester, 'a').width, 5 * 40);
    });

    testWidgets('columns start at the date line when midnight is skipped', (
      tester,
    ) async {
      // In Santiago 6 Sep 2026 starts at 01:00.
      await tester.pumpObers(
        gantt(
          [
            OiGanttTask(
              key: 'a',
              label: 'A',
              start: DateTime(2026, 9, 7),
              end: DateTime(2026, 9, 9),
            ),
          ],
          viewStart: DateTime(2026, 9, 6),
        ),
      );

      final origin = tester.getTopLeft(_ganttTimeline().last).dx;
      expect(bar(tester, 'a').left - origin, 40);
      expect(_timelineWidth(tester), 3 * 40);
    });

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
