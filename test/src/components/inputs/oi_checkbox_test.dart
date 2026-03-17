// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_checkbox.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders unchecked state', (tester) async {
    await tester.pumpObers(
      const OiCheckbox(value: OiCheckboxState.unchecked),
    );
    expect(find.byType(OiCheckbox), findsOneWidget);
  });

  testWidgets('renders checked state', (tester) async {
    await tester.pumpObers(
      const OiCheckbox(value: OiCheckboxState.checked),
    );
    expect(find.byType(OiCheckbox), findsOneWidget);
  });

  testWidgets('renders indeterminate state', (tester) async {
    await tester.pumpObers(
      const OiCheckbox(value: OiCheckboxState.indeterminate),
    );
    expect(find.byType(OiCheckbox), findsOneWidget);
  });

  testWidgets('tapping unchecked fires onChanged with true', (tester) async {
    bool? result;
    await tester.pumpObers(
      OiCheckbox(
        value: OiCheckboxState.unchecked,
        onChanged: (v) => result = v,
      ),
    );
    await tester.tap(find.byType(OiCheckbox));
    await tester.pump();
    expect(result, isTrue);
  });

  testWidgets('tapping checked fires onChanged with false', (tester) async {
    bool? result;
    await tester.pumpObers(
      OiCheckbox(
        value: OiCheckboxState.checked,
        onChanged: (v) => result = v,
      ),
    );
    await tester.tap(find.byType(OiCheckbox));
    await tester.pump();
    expect(result, isFalse);
  });

  testWidgets('tapping indeterminate fires onChanged with true', (tester) async {
    bool? result;
    await tester.pumpObers(
      OiCheckbox(
        value: OiCheckboxState.indeterminate,
        onChanged: (v) => result = v,
      ),
    );
    await tester.tap(find.byType(OiCheckbox));
    await tester.pump();
    expect(result, isTrue);
  });

  testWidgets('label is shown', (tester) async {
    await tester.pumpObers(
      const OiCheckbox(
        value: OiCheckboxState.unchecked,
        label: 'Accept terms',
      ),
    );
    expect(find.text('Accept terms'), findsOneWidget);
  });

  testWidgets('enabled=false suppresses onChanged', (tester) async {
    bool? result;
    await tester.pumpObers(
      OiCheckbox(
        value: OiCheckboxState.unchecked,
        enabled: false,
        onChanged: (v) => result = v,
      ),
    );
    await tester.tap(find.byType(OiCheckbox), warnIfMissed: false);
    await tester.pump();
    expect(result, isNull);
  });
}
