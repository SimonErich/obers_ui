// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_date_range_picker_field.dart';
import 'package:obers_ui/src/components/navigation/oi_date_picker.dart';
import 'package:obers_ui/src/composites/scheduling/oi_date_range_picker.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Rendering ─────────────────────────────────────────────────────────────

  testWidgets('renders two calendars on expanded breakpoint', (tester) async {
    await tester.pumpObers(
      const OiDateRangePicker(label: 'Range'),
      surfaceSize: const Size(1200, 800),
    );
    expect(find.byType(OiDatePicker), findsNWidgets(2));
  });

  testWidgets('renders single calendar on compact breakpoint', (tester) async {
    await tester.pumpObers(
      const OiDateRangePicker(label: 'Range'),
      surfaceSize: const Size(400, 800),
    );
    expect(find.byType(OiDatePicker), findsOneWidget);
  });

  testWidgets('singleCalendar flag produces one calendar', (tester) async {
    await tester.pumpObers(
      const SingleChildScrollView(
        child: OiDateRangePicker(label: 'Range', singleCalendar: true),
      ),
      surfaceSize: const Size(1200, 1200),
    );
    expect(find.byType(OiDatePicker), findsOneWidget);
  });

  // ── Presets ───────────────────────────────────────────────────────────────

  testWidgets('shows default presets', (tester) async {
    await tester.pumpObers(
      const OiDateRangePicker(label: 'Range'),
      surfaceSize: const Size(1200, 800),
    );
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Last 7 days'), findsOneWidget);
  });

  testWidgets('hides presets when showPresets is false', (tester) async {
    await tester.pumpObers(
      const OiDateRangePicker(label: 'Range', showPresets: false),
      surfaceSize: const Size(1200, 800),
    );
    expect(find.text('Today'), findsNothing);
    expect(find.text('Last 7 days'), findsNothing);
  });

  testWidgets('custom presets are displayed', (tester) async {
    await tester.pumpObers(
      OiDateRangePicker(
        label: 'Range',
        presets: [
          OiDateRangePreset(
            label: 'Custom Range',
            resolve: () => (DateTime(2026, 1, 1), DateTime(2026, 1, 31)),
          ),
        ],
      ),
      surfaceSize: const Size(1200, 800),
    );
    expect(find.text('Custom Range'), findsOneWidget);
  });

  // ── Footer buttons ────────────────────────────────────────────────────────

  testWidgets('renders Apply and Cancel buttons', (tester) async {
    await tester.pumpObers(
      OiDateRangePicker(label: 'Range', onApply: (_, _) {}, onCancel: () {}),
      surfaceSize: const Size(1200, 800),
    );
    expect(find.text('Apply'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('Cancel calls onCancel', (tester) async {
    var cancelled = false;
    await tester.pumpObers(
      OiDateRangePicker(label: 'Range', onCancel: () => cancelled = true),
      surfaceSize: const Size(1200, 800),
    );
    await tester.tap(find.text('Cancel'));
    expect(cancelled, isTrue);
  });

  testWidgets('custom button labels render', (tester) async {
    await tester.pumpObers(
      const OiDateRangePicker(
        label: 'Range',
        applyLabel: 'Confirm',
        cancelLabel: 'Dismiss',
      ),
      surfaceSize: const Size(1200, 800),
    );
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('Dismiss'), findsOneWidget);
  });

  // ── Initial dates ─────────────────────────────────────────────────────────

  testWidgets('initial start/end dates are passed to calendars', (
    tester,
  ) async {
    await tester.pumpObers(
      OiDateRangePicker(
        label: 'Range',
        startDate: DateTime(2026, 3, 10),
        endDate: DateTime(2026, 3, 20),
      ),
      surfaceSize: const Size(1200, 800),
    );
    // Calendars should show range highlighting.
    expect(find.byType(OiDatePicker), findsNWidgets(2));
  });

  // ── Semantic label ────────────────────────────────────────────────────────

  testWidgets('has semantic label', (tester) async {
    await tester.pumpObers(
      const OiDateRangePicker(label: 'Date range'),
      surfaceSize: const Size(1200, 800),
    );
    expect(find.bySemanticsLabel('Date range'), findsOneWidget);
  });

  // ── OiDateRangePreset new presets ───────────────────────────────────────

  group('OiDateRangePreset new presets', () {
    test('lastWeek resolves to 7-day range ending before this week', () {
      final (start, end) = OiDateRangePreset.lastWeek.resolve();
      expect(end.difference(start).inDays, greaterThanOrEqualTo(6));
      expect(start.weekday, DateTime.monday);
    });

    test('thisQuarter starts on first day of quarter', () {
      final (start, _) = OiDateRangePreset.thisQuarter.resolve();
      expect(start.day, 1);
      expect([1, 4, 7, 10], contains(start.month));
    });

    test('lastQuarter resolves to previous quarter', () {
      final (start, end) = OiDateRangePreset.lastQuarter.resolve();
      expect(start.day, 1);
      expect(end.day, greaterThan(27));
    });

    test('lastYear resolves to previous year', () {
      final now = DateTime.now();
      final (start, end) = OiDateRangePreset.lastYear.resolve();
      expect(start.year, now.year - 1);
      expect(end.year, now.year - 1);
      expect(start.month, 1);
      expect(end.month, 12);
    });
  });
}
