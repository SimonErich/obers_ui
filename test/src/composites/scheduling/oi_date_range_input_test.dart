// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/scheduling/oi_date_range_input.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('displays formatted date range', (tester) async {
    await tester.pumpObers(
      OiDateRangeInput(
        label: 'Period',
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 3, 15),
      ),
    );

    // Same-year format: "Mar 1 – Mar 15, 2026"
    expect(find.textContaining('Mar 1'), findsOneWidget);
    expect(find.textContaining('Mar 15'), findsOneWidget);
  });

  testWidgets('shows error text', (tester) async {
    await tester.pumpObers(
      const OiDateRangeInput(label: 'Period', error: 'Range is required'),
    );

    expect(find.text('Range is required'), findsOneWidget);
  });

  testWidgets('disabled prevents interaction', (tester) async {
    var tapped = false;
    await tester.pumpObers(
      OiDateRangeInput(
        label: 'Period',
        enabled: false,
        onChanged: (_, __) => tapped = true,
      ),
    );

    // Tap the field — should not open dialog or fire callback.
    await tester.tap(find.byType(OiDateRangeInput));
    await tester.pumpAndSettle();
    expect(tapped, isFalse);
  });

  testWidgets('renders with required label', (tester) async {
    await tester.pumpObers(
      const OiDateRangeInput(label: 'Period', required: true),
    );

    expect(find.text('Period *'), findsOneWidget);
  });
}
