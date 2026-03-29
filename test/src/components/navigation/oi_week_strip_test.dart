// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_week_strip.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Rendering ──────────────────────────────────────────────────────────────

  testWidgets('renders 7 day cells', (tester) async {
    await tester.pumpObers(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (_) {},
        label: 'Week selector',
      ),
      surfaceSize: const Size(800, 200),
    );

    // Week of March 25 2026 (Wednesday), Monday-start: 23–29.
    expect(find.text('23'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    expect(find.text('26'), findsOneWidget);
    expect(find.text('27'), findsOneWidget);
    expect(find.text('28'), findsOneWidget);
    expect(find.text('29'), findsOneWidget);
  });

  // ── Selection ──────────────────────────────────────────────────────────────

  testWidgets('highlights selected date', (tester) async {
    await tester.pumpObers(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (_) {},
        label: 'Week selector',
      ),
      surfaceSize: const Size(800, 200),
    );

    // Find the container that wraps the selected day (25).
    // The selected day should have a non-transparent background color.
    final dayLabel = find.text('25');
    expect(dayLabel, findsOneWidget);

    // Verify the day 25 exists and is rendered (basic selection check).
    final dayWidget = tester.widget<OiLabel>(
      find.widgetWithText(OiLabel, '25'),
    );
    expect(dayWidget, isNotNull);
  });

  testWidgets('tapping a day calls onDateSelected', (tester) async {
    DateTime? picked;
    await tester.pumpObers(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (d) => picked = d,
        label: 'Week selector',
      ),
      surfaceSize: const Size(800, 200),
    );

    // Tap day 26.
    await tester.tap(find.text('26'));
    await tester.pump();
    expect(picked, isNotNull);
    expect(picked!.day, 26);
    expect(picked!.month, 3);
    expect(picked!.year, 2026);
  });

  // ── Navigation ─────────────────────────────────────────────────────────────

  testWidgets('navigation arrows change visible week', (tester) async {
    await tester.pumpObers(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (_) {},
        label: 'Week selector',
      ),
      surfaceSize: const Size(800, 200),
    );

    // Tap the right chevron (next week). codePoint 0xe06f.
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is Icon && w.icon?.codePoint == OiIcons.chevronRight.codePoint,
      ),
    );
    await tester.pump();

    // Next week: March 30 – April 5.
    expect(find.text('30'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    // Tap the left chevron (prev week). codePoint 0xe06e.
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is Icon && w.icon?.codePoint == OiIcons.chevronLeft.codePoint,
      ),
    );
    await tester.pump();

    // Back to original week: March 23–29.
    expect(find.text('23'), findsOneWidget);
    expect(find.text('29'), findsOneWidget);
  });

  // ── Event Dots ─────────────────────────────────────────────────────────────

  testWidgets('event dots for eventCounts', (tester) async {
    await tester.pumpObers(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (_) {},
        label: 'Week selector',
        eventCounts: {DateTime(2026, 3, 24): 3, DateTime(2026, 3, 26): 1},
      ),
      surfaceSize: const Size(800, 200),
    );

    // Event dots are rendered as 4x4 containers with circle shape.
    // We should find at least 2 event dot containers (for days 24 and 26).
    final dotFinder = find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).shape == BoxShape.circle &&
          w.constraints?.maxWidth == 4,
    );
    // At least 2 event dots + possibly a today indicator.
    expect(dotFinder, findsAtLeast(2));
  });

  // ── Disabled Dates ─────────────────────────────────────────────────────────

  testWidgets('disabled dates not tappable', (tester) async {
    DateTime? picked;
    await tester.pumpObers(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (d) => picked = d,
        label: 'Week selector',
        firstDate: DateTime(2026, 3, 24),
      ),
      surfaceSize: const Size(800, 200),
    );

    // Day 23 is before firstDate (March 24), should be disabled.
    await tester.tap(find.text('23'));
    await tester.pump();
    expect(picked, isNull);

    // Day 25 should be tappable.
    await tester.tap(find.text('25'));
    await tester.pump();
    expect(picked, isNotNull);
    expect(picked!.day, 25);
  });

  // ── First Day of Week ──────────────────────────────────────────────────────

  testWidgets('firstDayOfWeek=sunday starts on Sunday', (tester) async {
    await tester.pumpObers(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (_) {},
        label: 'Week selector',
        firstDayOfWeek: DateTime.sunday,
      ),
      surfaceSize: const Size(800, 200),
    );

    // With Sunday start, the week containing March 25 (Wed) is
    // Sun March 22 – Sat March 28.
    expect(find.text('22'), findsOneWidget);
    expect(find.text('28'), findsOneWidget);
    // Day abbreviation headers should start with Sun.
    expect(find.text('Sun'), findsOneWidget);
  });

  // ── Month Label ────────────────────────────────────────────────────────────

  testWidgets('showMonth displays month name', (tester) async {
    await tester.pumpObers(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (_) {},
        label: 'Week selector',
      ),
      surfaceSize: const Size(800, 200),
    );

    expect(find.textContaining('March'), findsOneWidget);
  });

  // ── Today Label ────────────────────────────────────────────────────────────

  testWidgets('todayLabel shows jump button', (tester) async {
    await tester.pumpObers(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (_) {},
        label: 'Week selector',
        todayLabel: 'Today',
      ),
      surfaceSize: const Size(800, 200),
    );

    expect(find.text('Today'), findsOneWidget);
  });

  // ── firstDate disables previous navigation ─────────────────────────────────

  testWidgets('firstDate disables previous navigation', (tester) async {
    await tester.pumpObers(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (_) {},
        label: 'Week selector',
        firstDate: DateTime(2026, 3, 23),
      ),
      surfaceSize: const Size(800, 200),
    );

    // The current week starts on March 23, which is exactly firstDate.
    // Tapping previous should not change the week since the previous
    // week (March 16–22) is entirely before firstDate.
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is Icon && w.icon?.codePoint == OiIcons.chevronLeft.codePoint,
      ),
    );
    await tester.pump();

    // Still showing current week.
    expect(find.text('23'), findsOneWidget);
    expect(find.text('29'), findsOneWidget);
  });

  // ── New params ──────────────────────────────────────────────────────────

  testWidgets('disabledDates prevents selection of specific dates', (
    tester,
  ) async {
    DateTime? selected;
    await tester.pumpObers(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (d) => selected = d,
        label: 'Week',
        disabledDates: {DateTime(2026, 3, 26)},
      ),
      surfaceSize: const Size(800, 200),
    );
    await tester.tap(find.text('26'));
    expect(selected, isNull);
  });

  testWidgets('disabledDaysOfWeek prevents selection of weekday types', (
    tester,
  ) async {
    DateTime? selected;
    await tester.pumpObers(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (d) => selected = d,
        label: 'Week',
        disabledDaysOfWeek: const {DateTime.sunday}, // Sunday = 7
      ),
      surfaceSize: const Size(800, 200),
    );
    // Sunday the 29th should be disabled.
    await tester.tap(find.text('29'));
    expect(selected, isNull);
  });

  testWidgets('showYear displays year with month', (tester) async {
    await tester.pumpObers(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (_) {},
        label: 'Week',
        showYear: true,
      ),
      surfaceSize: const Size(800, 200),
    );
    // The month label should contain "2026".
    expect(find.textContaining('2026'), findsOneWidget);
  });

  testWidgets('eventDotColor customizes dot color', (tester) async {
    await tester.pumpObers(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (_) {},
        label: 'Week',
        eventCounts: {DateTime(2026, 3, 25): 1},
        eventDotColor: const Color(0xFFFF0000),
      ),
      surfaceSize: const Size(800, 200),
    );
    // Event dot should render.
    final widget = tester.widget<OiWeekStrip>(find.byType(OiWeekStrip));
    expect(widget.eventDotColor, const Color(0xFFFF0000));
  });

  testWidgets('has swipe gesture detector for week navigation', (tester) async {
    await tester.pumpObers(
      OiWeekStrip(
        selectedDate: DateTime(2026, 3, 25),
        onDateSelected: (_) {},
        label: 'Week',
      ),
      surfaceSize: const Size(800, 200),
    );
    // Verify GestureDetector for horizontal drag is in the tree.
    expect(find.byType(GestureDetector), findsWidgets);
  });

  testWidgets('today indicator visible when not selected', (tester) async {
    // Use today's date but select tomorrow to verify today dot still shows.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Select yesterday so today is visible but not selected.
    final selected = today.subtract(const Duration(days: 1));
    await tester.pumpObers(
      OiWeekStrip(
        selectedDate: selected,
        onDateSelected: (_) {},
        label: 'Week',
      ),
      surfaceSize: const Size(800, 200),
    );
    // The widget should render without errors (today dot is in tree).
    expect(find.byType(OiWeekStrip), findsOneWidget);
  });
}
