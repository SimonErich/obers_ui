// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_calendar_week_picker.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const initial = OiCalendarWeek(week: 10, year: 2026);

  Future<void> openDialog(
    WidgetTester tester, {
    String? cancelLabel,
    String? confirmLabel,
    ValueChanged<OiCalendarWeek?>? onResult,
  }) async {
    await tester.pumpObers(
      Builder(
        builder: (ctx) => GestureDetector(
          onTap: () async {
            final result = cancelLabel == null || confirmLabel == null
                ? await OiCalendarWeekPicker.show(ctx, initialValue: initial)
                : await OiCalendarWeekPicker.show(
                    ctx,
                    initialValue: initial,
                    cancelLabel: cancelLabel,
                    confirmLabel: confirmLabel,
                  );
            onResult?.call(result);
          },
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('OiCalendarWeekPicker.show', () {
    testWidgets('defaults to English button labels', (tester) async {
      await openDialog(tester);

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('renders the given button labels', (tester) async {
      await openDialog(
        tester,
        cancelLabel: 'Abbrechen',
        confirmLabel: 'Übernehmen',
      );

      expect(find.text('Abbrechen'), findsOneWidget);
      expect(find.text('Übernehmen'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
      expect(find.text('OK'), findsNothing);
    });

    testWidgets('confirm button returns the selected week', (tester) async {
      OiCalendarWeek? result;
      await openDialog(
        tester,
        cancelLabel: 'Abbrechen',
        confirmLabel: 'Übernehmen',
        onResult: (week) => result = week,
      );

      await tester.tap(find.text('Übernehmen'));
      await tester.pumpAndSettle();

      expect(result, initial);
    });

    testWidgets('passes the labels on to the year picker', (tester) async {
      await openDialog(
        tester,
        cancelLabel: 'Abbrechen',
        confirmLabel: 'Übernehmen',
      );

      await tester.tap(find.text('2026').last);
      await tester.pumpAndSettle();

      // Both dialogs are open, each with its own buttons.
      expect(find.text('Abbrechen'), findsNWidgets(2));
      expect(find.text('Übernehmen'), findsNWidgets(2));
      expect(find.text('Cancel'), findsNothing);
      expect(find.text('OK'), findsNothing);
    });
  });
}
