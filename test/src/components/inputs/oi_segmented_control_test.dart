// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

const _segments = [
  OiSegment<String>(value: 'day', label: 'Day'),
  OiSegment<String>(value: 'week', label: 'Week'),
  OiSegment<String>(value: 'month', label: 'Month'),
];

void main() {
  testWidgets('renders all segment labels', (tester) async {
    await tester.pumpObers(
      OiSegmentedControl<String>(
        segments: _segments,
        selected: 'day',
        onChanged: (_) {},
      ),
    );

    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
  });

  testWidgets('selected segment uses bold font weight', (tester) async {
    await tester.pumpObers(
      OiSegmentedControl<String>(
        segments: _segments,
        selected: 'week',
        onChanged: (_) {},
      ),
    );

    final selectedText = tester.widget<Text>(find.text('Week'));
    final unselectedText = tester.widget<Text>(find.text('Day'));

    expect(selectedText.style?.fontWeight, FontWeight.w600);
    expect(unselectedText.style?.fontWeight, FontWeight.w400);
  });

  testWidgets('tapping segment fires onChanged', (tester) async {
    String? result;
    await tester.pumpObers(
      OiSegmentedControl<String>(
        segments: _segments,
        selected: 'day',
        onChanged: (v) => result = v,
      ),
    );

    await tester.tap(find.text('Month'));
    await tester.pump();

    expect(result, 'month');
  });

  testWidgets('disabled segment cannot be tapped', (tester) async {
    String? result;
    final segmentsWithDisabled = [
      const OiSegment<String>(value: 'day', label: 'Day'),
      const OiSegment<String>(value: 'week', label: 'Week', enabled: false),
      const OiSegment<String>(value: 'month', label: 'Month'),
    ];

    await tester.pumpObers(
      OiSegmentedControl<String>(
        segments: segmentsWithDisabled,
        selected: 'day',
        onChanged: (v) => result = v,
      ),
    );

    await tester.tap(find.text('Week'), warnIfMissed: false);
    await tester.pump();

    expect(result, isNull);
  });

  testWidgets('expand mode fills available width', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 400,
        child: OiSegmentedControl<String>(
          segments: _segments,
          selected: 'day',
          onChanged: (_) {},
          expand: true,
        ),
      ),
    );

    // When expand is true the Row uses MainAxisSize.max.
    final row = tester.widget<Row>(find.byType(Row).first);
    expect(row.mainAxisSize, MainAxisSize.max);
  });
}
