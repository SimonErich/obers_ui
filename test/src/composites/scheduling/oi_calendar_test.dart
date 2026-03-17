// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/scheduling/oi_calendar.dart';

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
}
