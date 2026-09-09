// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_checkbox.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders unchecked state', (tester) async {
    await tester.pumpObers(const OiCheckbox(value: false));
    expect(find.byType(OiCheckbox), findsOneWidget);
  });

  testWidgets('renders checked state', (tester) async {
    await tester.pumpObers(const OiCheckbox(value: true));
    expect(find.byType(OiCheckbox), findsOneWidget);
  });

  testWidgets('renders indeterminate state', (tester) async {
    await tester.pumpObers(const OiCheckbox(value: null));
    expect(find.byType(OiCheckbox), findsOneWidget);
  });

  testWidgets('tapping unchecked fires onChanged with true', (tester) async {
    bool? result;
    await tester.pumpObers(
      OiCheckbox(value: false, onChanged: (v) => result = v),
    );
    await tester.tap(find.byType(OiCheckbox));
    await tester.pump();
    expect(result, isTrue);
  });

  testWidgets('tapping checked fires onChanged with false', (tester) async {
    bool? result;
    await tester.pumpObers(
      OiCheckbox(value: true, onChanged: (v) => result = v),
    );
    await tester.tap(find.byType(OiCheckbox));
    await tester.pump();
    expect(result, isFalse);
  });

  testWidgets('tapping indeterminate fires onChanged with true', (
    tester,
  ) async {
    bool? result;
    await tester.pumpObers(
      OiCheckbox(value: null, onChanged: (v) => result = v),
    );
    await tester.tap(find.byType(OiCheckbox));
    await tester.pump();
    expect(result, isTrue);
  });

  testWidgets('label is shown', (tester) async {
    await tester.pumpObers(
      const OiCheckbox(value: false, label: 'Accept terms'),
    );
    expect(find.text('Accept terms'), findsOneWidget);
  });

  testWidgets('tapping the label fires onChanged', (tester) async {
    bool? result;
    await tester.pumpObers(
      OiCheckbox(
        value: false,
        label: 'Accept terms',
        onChanged: (v) => result = v,
      ),
    );
    await tester.tap(find.text('Accept terms'));
    await tester.pump();
    expect(result, isTrue);
  });

  testWidgets('labelGap is used between box and label', (tester) async {
    await tester.pumpObers(
      const OiCheckbox(value: false, label: 'Accept terms', labelGap: 24),
    );
    final gaps = tester.widgetList<SizedBox>(find.byType(SizedBox));
    expect(gaps.any((box) => box.width == 24), isTrue);
  });

  testWidgets('enabled=false suppresses onChanged', (tester) async {
    bool? result;
    await tester.pumpObers(
      OiCheckbox(value: false, enabled: false, onChanged: (v) => result = v),
    );
    await tester.tap(find.byType(OiCheckbox), warnIfMissed: false);
    await tester.pump();
    expect(result, isNull);
  });
}
