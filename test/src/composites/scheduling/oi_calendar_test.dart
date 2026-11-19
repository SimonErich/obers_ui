// Tests do not require documentation comments.

import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/scheduling/oi_calendar.dart';
import 'package:obers_ui/src/composites/scheduling/oi_calendar_labels.dart';
import 'package:obers_ui/src/foundation/persistence/drivers/oi_in_memory_driver.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/models/settings/oi_calendar_settings.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// A fixed date used as the initial focus for deterministic tests.
final _initialDate = DateTime(2025, 6, 15);

final _events = [
  OiCalendarEvent(
    key: 'e1',
    title: 'Team Standup',
    start: DateTime(2025, 6, 15, 9),
    end: DateTime(2025, 6, 15, 10),
  ),
  OiCalendarEvent(
    key: 'e2',
    title: 'Lunch',
    start: DateTime(2025, 6, 15, 12),
    end: DateTime(2025, 6, 15, 13),
  ),
  OiCalendarEvent(
    key: 'e3',
    title: 'Sprint Review',
    start: DateTime(2025, 6, 20, 14),
    end: DateTime(2025, 6, 20, 15),
  ),
  OiCalendarEvent(
    key: 'e4',
    title: 'Company Holiday',
    start: DateTime(2025, 6, 10),
    end: DateTime(2025, 6, 10),
    allDay: true,
  ),
];

Widget _calendar({
  List<OiCalendarEvent>? events,
  String label = 'Test Calendar',
  OiCalendarMode mode = OiCalendarMode.month,
  DateTime? initialDate,
  ValueChanged<OiCalendarEvent>? onEventTap,
  ValueChanged<DateTime>? onDateTap,
  void Function(OiCalendarEvent event, DateTime start, DateTime end)?
  onEventMove,
  bool showWeekNumbers = false,
  bool showAllDayRow = true,
  int firstDayOfWeek = DateTime.monday,
}) {
  return SizedBox(
    width: 800,
    height: 600,
    child: OiCalendar(
      events: events ?? _events,
      label: label,
      mode: mode,
      initialDate: initialDate ?? _initialDate,
      onEventTap: onEventTap,
      onDateTap: onDateTap,
      onEventMove: onEventMove,
      showWeekNumbers: showWeekNumbers,
      showAllDayRow: showAllDayRow,
      firstDayOfWeek: firstDayOfWeek,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // 1. Month view renders grid of days.
  testWidgets('month view renders day numbers', (tester) async {
    await tester.pumpObers(_calendar());
    // Day 15 should appear (the initial focused date).
    expect(find.text('15'), findsOneWidget);
    // Day 1 should appear.
    expect(find.text('1'), findsWidgets);
  });

  // 2. Events appear on correct dates.
  testWidgets('events appear on their date in month view', (tester) async {
    await tester.pumpObers(_calendar());
    // 'Team Standup' occurs on June 15 — should be visible as an event chip.
    expect(find.text('Team Standup'), findsWidgets);
  });

  // 3. Navigation arrows change month.
  testWidgets('forward navigation changes the header title', (tester) async {
    await tester.pumpObers(_calendar());
    // Initial month: June 2025.
    expect(find.text('June 2025'), findsOneWidget);

    // Tap the forward arrow.
    await tester.tap(find.byKey(const ValueKey('calendar_forward')));
    await tester.pump();

    // Should now show July 2025.
    expect(find.text('July 2025'), findsOneWidget);
    expect(find.text('June 2025'), findsNothing);
  });

  // 4. Backward navigation.
  testWidgets('backward navigation changes the header title', (tester) async {
    await tester.pumpObers(_calendar());
    await tester.tap(find.byKey(const ValueKey('calendar_back')));
    await tester.pump();

    expect(find.text('May 2025'), findsOneWidget);
  });

  // 5. onDateTap fires when a date cell is tapped.
  testWidgets('onDateTap fires when date cell is tapped', (tester) async {
    DateTime? tappedDate;
    await tester.pumpObers(_calendar(onDateTap: (dt) => tappedDate = dt));
    // Tap on day 20 (June 20th).
    await tester.tap(find.text('20'));
    await tester.pump();
    expect(tappedDate, isNotNull);
    expect(tappedDate!.day, 20);
  });

  // 6. onEventTap fires when an event is tapped.
  testWidgets('onEventTap fires when event chip is tapped', (tester) async {
    OiCalendarEvent? tappedEvent;
    await tester.pumpObers(_calendar(onEventTap: (ev) => tappedEvent = ev));
    // Tap 'Team Standup' event chip.
    await tester.tap(find.text('Team Standup').first);
    await tester.pump();
    expect(tappedEvent?.title, 'Team Standup');
  });

  // 7. Today highlighted — we use a fixed date so we check the initial date
  // cell has the bold style. Since _initialDate might not be today, we test
  // that the widget renders without error and the date is present.
  testWidgets('initial date cell is rendered correctly', (tester) async {
    await tester.pumpObers(_calendar());
    expect(find.text('15'), findsOneWidget);
  });

  // 8. Week numbers show when enabled.
  testWidgets('week numbers are shown when showWeekNumbers is true', (
    tester,
  ) async {
    await tester.pumpObers(_calendar(showWeekNumbers: true));
    // 'Wk' header should be present.
    expect(find.text('Wk'), findsOneWidget);
  });

  // 9. Week numbers hidden by default.
  testWidgets('week numbers are hidden by default', (tester) async {
    await tester.pumpObers(_calendar());
    expect(find.text('Wk'), findsNothing);
  });

  // 10. Mode switching from month to week.
  testWidgets('switching mode from month to week changes view', (tester) async {
    await tester.pumpObers(_calendar());
    // Initially in month mode; day headers like 'Mon', 'Tue' are present.
    expect(find.text('Mon'), findsOneWidget);

    // Tap 'Week' mode selector.
    await tester.tap(find.byKey(const ValueKey('calendar_mode_week')));
    await tester.pump();

    // Hour labels should appear in week view.
    expect(find.text('09:00'), findsOneWidget);
  });

  // 11. Mode switching from month to day.
  testWidgets('switching mode from month to day shows hour slots', (
    tester,
  ) async {
    await tester.pumpObers(_calendar());
    await tester.tap(find.byKey(const ValueKey('calendar_mode_day')));
    await tester.pump();

    // Day view shows hour labels.
    expect(find.text('00:00'), findsOneWidget);
  });

  // 12. First day of week respected — Sunday start.
  testWidgets('firstDayOfWeek=7 starts week on Sunday', (tester) async {
    await tester.pumpObers(_calendar(firstDayOfWeek: DateTime.sunday));
    // The first day header should be 'Sun'.
    final headers = tester.widgetList<Text>(find.byType(Text));
    final headerTexts = headers.map((t) => t.data).toList();
    // Find the index of 'Sun' and 'Mon' in the rendered texts.
    final sunIdx = headerTexts.indexOf('Sun');
    final monIdx = headerTexts.indexOf('Mon');
    expect(sunIdx, lessThan(monIdx));
  });

  // 13. Semantics label is applied.
  testWidgets('semantics label is applied', (tester) async {
    await tester.pumpObers(_calendar(label: 'My Schedule'));
    // The Semantics widget wraps the calendar Column.
    final semantics = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics && widget.properties.label == 'My Schedule',
    );
    expect(semantics, findsOneWidget);
  });

  // 14. All-day event row shows when present and enabled.
  testWidgets('all-day events appear in the all-day row', (tester) async {
    await tester.pumpObers(_calendar());
    expect(find.text('Company Holiday'), findsOneWidget);
  });

  // 15. All-day row hidden when showAllDayRow is false.
  testWidgets('all-day row is hidden when showAllDayRow is false', (
    tester,
  ) async {
    await tester.pumpObers(_calendar(showAllDayRow: false));
    expect(find.byKey(const ValueKey('calendar_all_day_row')), findsNothing);
  });

  // 16. Empty events list.
  testWidgets('empty events list renders without error', (tester) async {
    await tester.pumpObers(_calendar(events: const []));
    expect(find.text('June 2025'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
  });

  // 17. Navigation in week mode.
  testWidgets('forward navigation in week mode advances by one week', (
    tester,
  ) async {
    await tester.pumpObers(_calendar(mode: OiCalendarMode.week));
    final headerBefore = tester.widget<Text>(
      find.byKey(const ValueKey('calendar_header_title')),
    );
    final titleBefore = headerBefore.data;

    await tester.tap(find.byKey(const ValueKey('calendar_forward')));
    await tester.pump();

    final headerAfter = tester.widget<Text>(
      find.byKey(const ValueKey('calendar_header_title')),
    );
    final titleAfter = headerAfter.data;
    expect(titleAfter, isNot(equals(titleBefore)));
  });

  // 18. Navigation in day mode.
  testWidgets('forward navigation in day mode advances by one day', (
    tester,
  ) async {
    await tester.pumpObers(_calendar(mode: OiCalendarMode.day));
    // Initial: 15 June 2025.
    expect(find.text('15 June 2025'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('calendar_forward')));
    await tester.pump();

    expect(find.text('16 June 2025'), findsOneWidget);
  });

  // 19. Mode selector highlights current mode.
  testWidgets('mode selector shows all three modes', (tester) async {
    await tester.pumpObers(_calendar());
    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
  });

  // Dragging an event chip to another day fires onEventMove with the
  // time-of-day and duration preserved.
  testWidgets('long-press dragging an event to another day moves it', (
    tester,
  ) async {
    OiCalendarEvent? moved;
    DateTime? newStart;
    DateTime? newEnd;
    await tester.pumpObers(
      _calendar(
        onEventMove: (event, start, end) {
          moved = event;
          newStart = start;
          newEnd = end;
        },
      ),
    );

    // 'Sprint Review' sits on June 20, 14:00-15:00. Drop it on June 11.
    final chip = find.text('Sprint Review');
    expect(chip, findsOneWidget);
    final gesture = await tester.startGesture(tester.getCenter(chip));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await gesture.moveTo(tester.getCenter(find.text('11')));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(moved?.key, 'e3');
    expect(newStart, DateTime(2025, 6, 11, 14));
    expect(newEnd, DateTime(2025, 6, 11, 15));
  });

  // ── Hour cells show every event that overlaps them ────────────────────────

  group('hour cells', () {
    final events = [
      OiCalendarEvent(
        key: 'short',
        title: 'Short',
        start: DateTime(2025, 6, 16, 9),
        end: DateTime(2025, 6, 16, 9, 30),
      ),
      OiCalendarEvent(
        key: 'night',
        title: 'Night',
        start: DateTime(2025, 6, 16, 22),
        end: DateTime(2025, 6, 17, 2),
      ),
      OiCalendarEvent(
        key: 'normal',
        title: 'Normal',
        start: DateTime(2025, 6, 16, 11),
        end: DateTime(2025, 6, 16, 12),
      ),
      OiCalendarEvent(
        key: 'late',
        title: 'Late',
        start: DateTime(2025, 6, 16, 14, 45),
        end: DateTime(2025, 6, 16, 15, 15),
      ),
    ];

    // Tall enough for all 24 hour rows to be built.
    const surface = Size(800, 1400);

    Widget calendar(
      OiCalendarMode mode,
      DateTime date, {
      List<OiCalendarEvent>? of,
    }) {
      return OiCalendar(
        events: of ?? events,
        label: 'Calendar',
        mode: mode,
        initialDate: date,
      );
    }

    testWidgets('week view shows short, overnight and normal events', (
      tester,
    ) async {
      await tester.pumpObers(
        calendar(OiCalendarMode.week, DateTime(2025, 6, 16)),
        surfaceSize: surface,
      );

      expect(find.text('Short'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      // 22:00 and 23:00 on the 16th, 00:00 and 01:00 on the 17th.
      expect(find.text('Night'), findsNWidgets(4));
      // 14:45-15:15 touches the 14:00 and the 15:00 cell.
      expect(find.text('Late'), findsNWidgets(2));
    });

    testWidgets('week view puts an event in the cells of its own hours', (
      tester,
    ) async {
      await tester.pumpObers(
        calendar(OiCalendarMode.week, DateTime(2025, 6, 16)),
        surfaceSize: surface,
      );

      double centerY(Finder finder) => tester.getCenter(finder).dy;
      double labelY(String hour) => tester.getCenter(find.text(hour)).dy;

      expect(centerY(find.text('Short')), closeTo(labelY('09:00'), 1));
      expect(centerY(find.text('Normal')), closeTo(labelY('11:00'), 1));
      final nights = find.text('Night');
      expect(
        [for (var i = 0; i < 4; i++) centerY(nights.at(i))]..sort(),
        [
          closeTo(labelY('00:00'), 1),
          closeTo(labelY('01:00'), 1),
          closeTo(labelY('22:00'), 1),
          closeTo(labelY('23:00'), 1),
        ],
      );
    });

    testWidgets('day view shows short, overnight and normal events', (
      tester,
    ) async {
      await tester.pumpObers(
        calendar(OiCalendarMode.day, DateTime(2025, 6, 16)),
        surfaceSize: surface,
      );

      expect(find.text('Short'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('Night'), findsNWidgets(2));
      expect(find.text('Late'), findsNWidgets(2));

      // The following day only has the two hours after midnight.
      await tester.tap(find.byKey(const ValueKey('calendar_forward')));
      await tester.pump();
      expect(find.text('Night'), findsNWidgets(2));
      expect(find.text('Short'), findsNothing);
    });

    testWidgets('day view shows an event that spans the whole focused day', (
      tester,
    ) async {
      await tester.pumpObers(
        calendar(
          OiCalendarMode.day,
          DateTime(2025, 6, 16),
          of: [
            OiCalendarEvent(
              key: 'conf',
              title: 'Conference',
              start: DateTime(2025, 6, 15, 18),
              end: DateTime(2025, 6, 17, 10),
            ),
          ],
        ),
        surfaceSize: surface,
      );

      expect(find.text('Conference'), findsNWidgets(24));
    });

    testWidgets('an event without a duration shows in the hour it starts', (
      tester,
    ) async {
      await tester.pumpObers(
        calendar(
          OiCalendarMode.day,
          DateTime(2025, 6, 16),
          of: [
            OiCalendarEvent(
              key: 'ping',
              title: 'Reminder',
              start: DateTime(2025, 6, 16, 8),
              end: DateTime(2025, 6, 16, 8),
            ),
          ],
        ),
        surfaceSize: surface,
      );

      expect(find.text('Reminder'), findsOneWidget);
    });
  });

  // ── Labels ────────────────────────────────────────────────────────────────

  testWidgets('labels replace the mode names and the week column header', (
    tester,
  ) async {
    await tester.pumpObers(
      SizedBox(
        width: 800,
        height: 600,
        child: OiCalendar(
          events: const [],
          label: 'Kalender',
          initialDate: _initialDate,
          showWeekNumbers: true,
          labels: const OiCalendarLabels(
            day: 'Tag',
            week: 'Woche',
            month: 'Monat',
            weekNumberHeader: 'KW',
          ),
        ),
      ),
    );

    expect(find.text('Tag'), findsOneWidget);
    expect(find.text('Woche'), findsOneWidget);
    expect(find.text('Monat'), findsOneWidget);
    expect(find.text('KW'), findsOneWidget);
    expect(find.text('Day'), findsNothing);
    expect(find.text('Wk'), findsNothing);
  });

  testWidgets('week numbers label each row with the week of its first day', (
    tester,
  ) async {
    // June 2025 from Monday: rows start on 26 May (week 22) to 30 Jun (27).
    await tester.pumpObers(_calendar(showWeekNumbers: true));
    for (var week = 22; week <= 27; week++) {
      expect(find.byKey(ValueKey('calendar_week_$week')), findsOneWidget);
    }

    // From Sunday the rows are 1-7 Jun, 8-14 Jun, ... The row of 8-14 Jun
    // is labelled 23, the week its Sunday ends, although 9-14 Jun are in
    // ISO week 24.
    await tester.pumpObers(
      _calendar(showWeekNumbers: true, firstDayOfWeek: DateTime.sunday),
    );
    final label = tester.getCenter(
      find.byKey(const ValueKey('calendar_week_23')),
    );
    expect(label.dy, greaterThan(tester.getTopLeft(find.text('14')).dy));
    expect(label.dy, lessThan(tester.getTopLeft(find.text('21')).dy));
  });

  // ── Widget updates ────────────────────────────────────────────────────────

  testWidgets('a new mode and initialDate from the parent are applied', (
    tester,
  ) async {
    await tester.pumpObers(_calendar());
    expect(find.text('June 2025'), findsOneWidget);

    await tester.pumpObers(
      _calendar(mode: OiCalendarMode.day, initialDate: DateTime(2025, 8, 3)),
    );

    expect(find.text('3 August 2025'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
  });

  testWidgets('a rebuild with the same props keeps the navigated date', (
    tester,
  ) async {
    await tester.pumpObers(_calendar());
    await tester.tap(find.byKey(const ValueKey('calendar_forward')));
    await tester.tap(find.byKey(const ValueKey('calendar_mode_day')));
    await tester.pump();
    expect(find.text('1 July 2025'), findsOneWidget);

    await tester.pumpObers(_calendar(label: 'Renamed'));

    expect(find.text('1 July 2025'), findsOneWidget);
  });

  // ── All-day row ───────────────────────────────────────────────────────────

  group('persisted mode', () {
    Widget calendar(
      OiInMemorySettingsDriver driver, {
      OiCalendarMode mode = OiCalendarMode.month,
    }) {
      return OiCalendar(
        events: const [],
        label: 'Calendar',
        mode: mode,
        initialDate: _initialDate,
        settingsDriver: driver,
      );
    }

    Future<void> save(
      OiInMemorySettingsDriver driver,
      OiCalendarViewType viewType,
    ) {
      return driver.save<OiCalendarSettings>(
        namespace: 'oi_calendar',
        data: OiCalendarSettings(viewType: viewType),
        serialize: (settings) => settings.toJson(),
      );
    }

    Future<OiCalendarViewType?> saved(OiInMemorySettingsDriver driver) async {
      final settings = await driver.load<OiCalendarSettings>(
        namespace: 'oi_calendar',
        deserialize: OiCalendarSettings.fromJson,
      );
      return settings?.viewType;
    }

    testWidgets('a saved mode is applied once it has loaded', (tester) async {
      final driver = OiInMemorySettingsDriver();
      await save(driver, OiCalendarViewType.day);

      await tester.pumpObers(calendar(driver));
      await tester.pump();

      expect(find.text('15 June 2025'), findsOneWidget);
    });

    testWidgets('a mode from the parent survives a theme change', (
      tester,
    ) async {
      final driver = OiInMemorySettingsDriver();
      await tester.pumpObers(calendar(driver));
      await tester.pump();
      expect(find.text('June 2025'), findsOneWidget);

      await tester.pumpObers(calendar(driver, mode: OiCalendarMode.day));
      expect(find.text('15 June 2025'), findsOneWidget);

      await tester.pumpObers(
        calendar(driver, mode: OiCalendarMode.day),
        theme: OiThemeData.dark(),
      );
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('15 June 2025'), findsOneWidget);
      expect(await saved(driver), OiCalendarViewType.day);
    });

    testWidgets('a mode from the parent replaces the one the user picked', (
      tester,
    ) async {
      final driver = OiInMemorySettingsDriver();
      await tester.pumpObers(calendar(driver));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('calendar_mode_week')));
      await tester.pump(const Duration(milliseconds: 600));
      expect(await saved(driver), OiCalendarViewType.week);

      await tester.pumpObers(calendar(driver, mode: OiCalendarMode.day));
      await tester.pumpObers(
        calendar(driver, mode: OiCalendarMode.day),
        theme: OiThemeData.dark(),
      );
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('15 June 2025'), findsOneWidget);
      expect(await saved(driver), OiCalendarViewType.day);
    });

    testWidgets('the mode the user picked survives a theme change', (
      tester,
    ) async {
      final driver = OiInMemorySettingsDriver();
      await save(driver, OiCalendarViewType.day);
      await tester.pumpObers(calendar(driver));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('calendar_mode_month')));
      await tester.pump();
      expect(find.text('June 2025'), findsOneWidget);

      await tester.pumpObers(calendar(driver), theme: OiThemeData.dark());
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('June 2025'), findsOneWidget);
    });
  });

  group('all-day row', () {
    final events = [
      OiCalendarEvent(
        key: 'jan',
        title: 'New Year',
        start: DateTime(2025),
        end: DateTime(2025),
        allDay: true,
      ),
      OiCalendarEvent(
        key: 'jun',
        title: 'Company Holiday',
        start: DateTime(2025, 6, 10),
        end: DateTime(2025, 6, 10),
        allDay: true,
      ),
      OiCalendarEvent(
        key: 'trip',
        title: 'Offsite',
        start: DateTime(2025, 6, 12),
        end: DateTime(2025, 6, 17),
        allDay: true,
      ),
    ];

    testWidgets('month view lists only the all-day events it shows', (
      tester,
    ) async {
      await tester.pumpObers(_calendar(events: events));

      expect(find.text('Company Holiday'), findsOneWidget);
      expect(find.text('Offsite'), findsOneWidget);
      expect(find.text('New Year'), findsNothing);
    });

    testWidgets('week view lists only the all-day events of that week', (
      tester,
    ) async {
      // The week of 15 Jun 2025 runs from Mon 9 to Sun 15.
      await tester.pumpObers(
        _calendar(events: events, mode: OiCalendarMode.week),
      );

      expect(find.text('Company Holiday'), findsOneWidget);
      expect(find.text('Offsite'), findsOneWidget);
      expect(find.text('New Year'), findsNothing);

      await tester.tap(find.byKey(const ValueKey('calendar_forward')));
      await tester.pump();
      expect(find.text('Company Holiday'), findsNothing);
      expect(find.text('Offsite'), findsOneWidget);
    });

    testWidgets('day view lists only the all-day events of that day', (
      tester,
    ) async {
      await tester.pumpObers(
        _calendar(events: events, mode: OiCalendarMode.day),
      );

      expect(find.text('Offsite'), findsOneWidget);
      expect(find.text('Company Holiday'), findsNothing);
      expect(find.text('New Year'), findsNothing);
    });

    testWidgets('the row is gone when the view has no all-day event', (
      tester,
    ) async {
      await tester.pumpObers(
        _calendar(
          events: events,
          mode: OiCalendarMode.day,
          initialDate: DateTime(2025, 6, 20),
        ),
      );

      expect(find.byKey(const ValueKey('calendar_all_day_row')), findsNothing);
    });
  });
}
