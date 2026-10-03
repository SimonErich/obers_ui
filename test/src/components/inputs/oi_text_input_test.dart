// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/primitives/input/oi_raw_input.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('multiline hint and counter share a footer without clipping', (
    tester,
  ) async {
    await tester.pumpObers(
      const SizedBox(
        width: 320,
        child: OiTextInput(
          label: 'Delivery note',
          hint: 'Printed for the driver.',
          maxLines: 3,
          minLines: 3,
          maxLength: 200,
          showCounter: true,
        ),
      ),
    );
    final hint = tester.getRect(find.text('Printed for the driver.'));
    final count = tester.getRect(find.text('0/200'));
    expect(hint.top, closeTo(count.top, 1));
    expect(hint.right, lessThan(count.left));
    await tester.enterText(find.byType(EditableText), 'Leave at reception');
    await tester.pump();
    expect(find.text('18/200'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('multiline placeholder wraps at the top of its editor', (
    tester,
  ) async {
    const placeholder =
        'Only visible to your team, for example a preparation or delivery note.';
    await tester.pumpObers(
      const Center(
        child: SizedBox(
          width: 260,
          child: OiTextInput(
            placeholder: placeholder,
            maxLines: 3,
            minLines: 3,
          ),
        ),
      ),
    );
    final hint = tester.getRect(find.text(placeholder));
    final editor = tester.getRect(find.byType(EditableText));
    expect(hint.top, closeTo(editor.top, 1));
    expect(hint.height, greaterThan(20));
    expect(hint.height, lessThanOrEqualTo(editor.height));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'explicit accessible names stay stable when placeholders disappear',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpObers(
        const OiTextInput(
          semanticLabel: 'Voucher code',
          placeholder: 'e.g. WELCOME10',
        ),
      );
      var data = tester
          .getSemantics(find.byType(EditableText))
          .getSemanticsData();
      expect(data.label, 'Voucher code');
      expect(data.hint, 'e.g. WELCOME10');
      await tester.enterText(find.byType(EditableText), 'LUNCH15');
      await tester.pump();
      data = tester.getSemantics(find.byType(EditableText)).getSemanticsData();
      expect(data.label, 'Voucher code');
      expect(data.value, 'LUNCH15');
      semantics.dispose();
    },
  );

  testWidgets(
    'visible label names the editable control for assistive technology',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpObers(
        const OiTextInput(
          label: 'Cost centre',
          hint: 'Optional billing reference',
        ),
      );
      final data = tester
          .getSemantics(find.byType(EditableText))
          .getSemanticsData();
      expect(data.label, 'Cost centre');
      expect(data.hint, contains('Optional billing reference'));
      await tester.enterText(find.byType(EditableText), 'Team seven');
      await tester.pump();
      expect(
        tester.getSemantics(find.byType(EditableText)).getSemanticsData().value,
        'Team seven',
      );
      semantics.dispose();
    },
  );

  testWidgets('renders without error', (tester) async {
    await tester.pumpObers(const OiTextInput());
    expect(find.byType(OiTextInput), findsOneWidget);
  });

  testWidgets('displays label', (tester) async {
    await tester.pumpObers(const OiTextInput(label: 'Email'));
    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('displays hint', (tester) async {
    await tester.pumpObers(const OiTextInput(hint: 'Enter your email'));
    expect(find.text('Enter your email'), findsOneWidget);
  });

  testWidgets('displays error and hides hint', (tester) async {
    await tester.pumpObers(
      const OiTextInput(hint: 'Enter email', error: 'Required'),
    );
    expect(find.text('Required'), findsOneWidget);
    expect(find.text('Enter email'), findsNothing);
  });

  testWidgets('onChanged fires when text is entered', (tester) async {
    final values = <String>[];
    await tester.pumpObers(OiTextInput(onChanged: values.add));
    await tester.enterText(find.byType(EditableText), 'hello');
    await tester.pump();
    expect(values, contains('hello'));
  });

  testWidgets('enabled=false makes input read-only', (tester) async {
    final values = <String>[];
    await tester.pumpObers(OiTextInput(enabled: false, onChanged: values.add));
    await tester.enterText(find.byType(EditableText), 'test');
    await tester.pump();
    expect(values, isEmpty);
  });

  testWidgets('external controller is used', (tester) async {
    final ctrl = TextEditingController(text: 'initial');
    await tester.pumpObers(OiTextInput(controller: ctrl));
    expect(find.text('initial'), findsOneWidget);
    ctrl.dispose();
  });

  testWidgets('placeholder shown when empty', (tester) async {
    await tester.pumpObers(const OiTextInput(placeholder: 'Type here'));
    expect(find.text('Type here'), findsOneWidget);
  });

  testWidgets('uses OiRawInput internally', (tester) async {
    await tester.pumpObers(const OiTextInput());
    expect(find.byType(OiRawInput), findsOneWidget);
  });
}
