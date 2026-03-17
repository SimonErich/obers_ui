// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_date_picker.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Rendering ──────────────────────────────────────────────────────────────

  testWidgets('renders month/year header', (tester) async {
    await tester.pumpObers(OiDatePicker(value: DateTime(2024, 3, 15)));
    expect(find.text('March 2024'), findsOneWidget);
  });

  testWidgets('renders weekday headers', (tester) async {
    await tester.pumpObers(const OiDatePicker());
    expect(find.text('Mo'), findsOneWidget);
    expect(find.text('Su'), findsOneWidget);
    expect(find.text('Sa'), findsOneWidget);
  });

  testWidgets('renders day numbers in current month', (tester) async {
    await tester.pumpObers(OiDatePicker(value: DateTime(2024, 1, 15)));
    // January — verify some day numbers appear.
    expect(find.text('15'), findsOneWidget);
    expect(find.text('31'), findsOneWidget);
  });

  // ── Navigation ─────────────────────────────────────────────────────────────

  testWidgets('prev arrow navigates to previous month', (tester) async {
    await tester.pumpObers(OiDatePicker(value: DateTime(2024, 3, 15)));
    // Tap the left chevron icon (codePoint 0xe5cb).
    await tester.tap(
      find.byWidgetPredicate((w) => w is Icon && w.icon?.codePoint == 0xe5cb),
    );
    await tester.pump();
    expect(find.text('February 2024'), findsOneWidget);
  });

  testWidgets('next arrow navigates to next month', (tester) async {
    await tester.pumpObers(OiDatePicker(value: DateTime(2024, 3, 15)));
    // Tap the right chevron icon (codePoint 0xe5cc).
    await tester.tap(
      find.byWidgetPredicate((w) => w is Icon && w.icon?.codePoint == 0xe5cc),
    );
    await tester.pump();
    expect(find.text('April 2024'), findsOneWidget);
  });

  // ── Selection ──────────────────────────────────────────────────────────────

  testWidgets('tapping a day fires onChanged', (tester) async {
    DateTime? picked;
    await tester.pumpObers(
      OiDatePicker(value: DateTime(2024, 3, 15), onChanged: (d) => picked = d),
    );
    // Tap day 10.
    await tester.tap(find.text('10'));
    await tester.pump();
    expect(picked, isNotNull);
    expect(picked!.day, 10);
    expect(picked!.month, 3);
  });

  // ── Range mode ─────────────────────────────────────────────────────────────

  testWidgets('range mode: tapping two days fires onRangeChanged', (
    tester,
  ) async {
    DateTime? rs;
    DateTime? re;
    await tester.pumpObers(
      OiDatePicker(
        rangeMode: true,
        value: DateTime(2024, 3, 15),
        onRangeChanged: (s, e) {
          rs = s;
          re = e;
        },
      ),
    );
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.text('10'));
    await tester.pump();
    expect(rs?.day, 5);
    expect(re?.day, 10);
  });
}
