// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inline_edit/oi_editable_select.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';

import '../../../helpers/pump_app.dart';

void main() {
  final options = [
    const OiSelectOption<String>(value: 'a', label: 'Apple'),
    const OiSelectOption<String>(value: 'b', label: 'Banana'),
  ];

  testWidgets('display mode shows selected label', (tester) async {
    await tester.pumpObers(
      OiEditableSelect<String>(options: options, value: 'a'),
    );
    expect(find.text('Apple'), findsOneWidget);
  });

  testWidgets('display mode shows dash when no value', (tester) async {
    await tester.pumpObers(OiEditableSelect<String>(options: options));
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('tap enters edit mode showing OiSelect', (tester) async {
    await tester.pumpObers(
      OiEditableSelect<String>(options: options, value: 'a'),
    );
    await tester.tap(find.text('Apple'));
    await tester.pump();
    expect(find.byType(OiSelect<String>), findsOneWidget);
  });

  testWidgets('edit mode renders OiSelect with current value', (tester) async {
    await tester.pumpObers(
      OiEditableSelect<String>(options: options, value: 'a', onChanged: (_) {}),
    );
    await tester.tap(find.text('Apple'));
    await tester.pump();
    // OiSelect should be present and show the current value.
    final select = tester.widget<OiSelect<String>>(
      find.byType(OiSelect<String>),
    );
    expect(select.value, 'a');
    expect(select.options, options);
  });

  testWidgets('disabled does not enter edit mode', (tester) async {
    await tester.pumpObers(
      OiEditableSelect<String>(options: options, value: 'a', enabled: false),
    );
    await tester.tap(find.text('Apple'));
    await tester.pump();
    expect(find.byType(OiSelect<String>), findsNothing);
  });
}
