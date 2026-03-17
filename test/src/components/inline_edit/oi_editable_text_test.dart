// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inline_edit/oi_editable_text.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('display mode shows label text', (tester) async {
    await tester.pumpObers(const OiEditableText(value: 'hello world'));
    expect(find.text('hello world'), findsOneWidget);
    expect(find.byType(OiTextInput), findsNothing);
  });

  testWidgets('tap switches to edit mode', (tester) async {
    await tester.pumpObers(const OiEditableText(value: 'hello'));
    await tester.tap(find.text('hello'));
    await tester.pump();
    expect(find.byType(OiTextInput), findsOneWidget);
  });

  testWidgets('submitting input commits the value', (tester) async {
    String? committed;
    await tester.pumpObers(
      OiEditableText(value: 'old', onChanged: (v) => committed = v),
    );
    await tester.tap(find.text('old'));
    await tester.pump();

    await tester.enterText(find.byType(OiTextInput), 'new value');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(committed, 'new value');
    expect(find.byType(OiTextInput), findsNothing);
  });

  testWidgets('disabled does not enter edit mode on tap', (tester) async {
    await tester.pumpObers(
      const OiEditableText(value: 'hello', enabled: false),
    );
    await tester.tap(find.text('hello'));
    await tester.pump();
    expect(find.byType(OiTextInput), findsNothing);
  });
}
