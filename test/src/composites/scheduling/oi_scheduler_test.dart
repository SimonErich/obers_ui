// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/scheduling/oi_scheduler.dart';

import '../../../helpers/pump_app.dart';

void main() {
  final baseDate = DateTime(2025, 6, 10); // Tuesday

  List<OiScheduleSlot> sampleSlots() => [
    OiScheduleSlot(
      key: 'slot1',
      title: 'Standup',
      start: DateTime(2025, 6, 10, 9),
      end: DateTime(2025, 6, 10, 10),
    ),
    OiScheduleSlot(
      key: 'slot2',
      title: 'Lunch',
      start: DateTime(2025, 6, 10, 12),
      end: DateTime(2025, 6, 10, 13),
    ),
  ];

  group('OiScheduler', () {
    testWidgets('renders in day mode with header', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiScheduler(
            slots: sampleSlots(),
            label: 'Test scheduler',
            date: baseDate,
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('scheduler_header_title')),
        findsOneWidget,
      );
      expect(find.text('10 June 2025'), findsOneWidget);
    });

    testWidgets('renders in week mode with header', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 800,
          height: 600,
          child: OiScheduler(
            slots: sampleSlots(),
            label: 'Test scheduler',
            date: baseDate,
            mode: OiSchedulerMode.week,
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('scheduler_header_title')),
        findsOneWidget,
      );
      // Week of 9 June (Monday) to 15 June (Sunday) 2025
      expect(find.text('9/6 - 15/6 2025'), findsOneWidget);
    });

    testWidgets('displays slot titles in day view', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiScheduler(
            slots: sampleSlots(),
            label: 'Test scheduler',
            date: baseDate,
          ),
        ),
      );

      expect(find.text('Standup'), findsOneWidget);
    });

    testWidgets('navigates forward in day mode', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiScheduler(
            slots: const [],
            label: 'Test scheduler',
            date: baseDate,
          ),
        ),
      );

      expect(find.text('10 June 2025'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('scheduler_forward')));
      await tester.pump();

      expect(find.text('11 June 2025'), findsOneWidget);
    });

    testWidgets('navigates backward in day mode', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiScheduler(
            slots: const [],
            label: 'Test scheduler',
            date: baseDate,
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('scheduler_back')));
      await tester.pump();

      expect(find.text('9 June 2025'), findsOneWidget);
    });

    testWidgets('switches between day and week mode', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 800,
          height: 600,
          child: OiScheduler(
            slots: const [],
            label: 'Test scheduler',
            date: baseDate,
          ),
        ),
      );

      expect(find.text('10 June 2025'), findsOneWidget);

      // Switch to week mode
      await tester.tap(find.byKey(const ValueKey('scheduler_mode_week')));
      await tester.pump();

      expect(find.text('9/6 - 15/6 2025'), findsOneWidget);
    });

    testWidgets('onSlotTap fires when slot is tapped', (tester) async {
      OiScheduleSlot? tappedSlot;
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiScheduler(
            slots: sampleSlots(),
            label: 'Test scheduler',
            date: baseDate,
            onSlotTap: (slot) => tappedSlot = slot,
          ),
        ),
      );

      await tester.tap(find.text('Standup'));
      await tester.pump();

      expect(tappedSlot, isNotNull);
      expect(tappedSlot!.title, 'Standup');
    });

    testWidgets('onTimeSlotTap fires when empty cell is tapped', (
      tester,
    ) async {
      DateTime? tappedTime;
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiScheduler(
            slots: const [],
            label: 'Test scheduler',
            date: baseDate,
            onTimeSlotTap: (dt) => tappedTime = dt,
          ),
        ),
      );

      // Tap on the first hour row (08:00)
      await tester.tap(find.text('08:00'));
      await tester.pump();

      expect(tappedTime, isNotNull);
      expect(tappedTime!.hour, 8);
    });

    testWidgets('respects custom startHour and endHour', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiScheduler(
            slots: const [],
            label: 'Test scheduler',
            date: baseDate,
            startHour: 10,
            endHour: 14,
          ),
        ),
      );

      expect(find.text('10:00'), findsOneWidget);
      expect(find.text('13:00'), findsOneWidget);
      // 08:00 should not appear since startHour is 10
      expect(find.text('08:00'), findsNothing);
    });

    testWidgets('has Semantics with label', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiScheduler(
            slots: const [],
            label: 'My scheduler',
            date: baseDate,
          ),
        ),
      );

      final semantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'My scheduler',
        ),
      );
      expect(semantics, isNotNull);
    });

    testWidgets('slot with custom color renders', (tester) async {
      final slots = [
        OiScheduleSlot(
          key: 'colored',
          title: 'Colored slot',
          start: DateTime(2025, 6, 10, 9),
          end: DateTime(2025, 6, 10, 10),
          color: const Color(0xFFFF0000),
        ),
      ];

      await tester.pumpObers(
        SizedBox(
          width: 400,
          height: 600,
          child: OiScheduler(
            slots: slots,
            label: 'Test scheduler',
            date: baseDate,
          ),
        ),
      );

      expect(find.text('Colored slot'), findsOneWidget);
    });
  });
}
