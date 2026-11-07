// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/primitives/input/oi_raw_input.dart';

import '../../../helpers/pump_app.dart';

void main() {
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

  group('slot icon colour', () {
    Color iconColor(WidgetTester tester, IconData icon) =>
        IconTheme.of(tester.element(find.byIcon(icon))).color!;

    for (final dark in [false, true]) {
      testWidgets('the search icon is readable in ${dark ? 'dark' : 'light'}', (
        tester,
      ) async {
        await tester.pumpObers(
          const SizedBox(width: 300, child: OiTextInput.search()),
          theme: dark ? OiThemeData.dark() : OiThemeData.light(),
        );

        final colors = tester.element(find.byType(OiTextInput)).colors;
        expect(iconColor(tester, OiIcons.search), colors.textMuted);
        expect(
          iconColor(tester, OiIcons.search),
          isNot(const Color(0xFF000000)),
        );
      });
    }

    testWidgets('a trailing icon gets the colour too; its own colour wins', (
      tester,
    ) async {
      await tester.pumpObers(
        const SizedBox(
          width: 300,
          child: OiTextInput(
            leading: Icon(OiIcons.search),
            trailing: Icon(OiIcons.check, color: Color(0xFF123456)),
          ),
        ),
        theme: OiThemeData.dark(),
      );

      final colors = tester.element(find.byType(OiTextInput)).colors;
      expect(iconColor(tester, OiIcons.search), colors.textMuted);
      // The Icon widget's own colour is used in place of the theme's.
      expect(
        tester.widget<Icon>(find.byIcon(OiIcons.check)).color,
        const Color(0xFF123456),
      );
    });
  });
}
