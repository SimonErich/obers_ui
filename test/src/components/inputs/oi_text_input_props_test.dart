// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/primitives/input/oi_raw_input.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('Text behavior', () {
    testWidgets('showCounter true with maxLength renders counter', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiTextInput(showCounter: true, maxLength: 50),
      );

      // Counter starts at 0.
      expect(find.text('0/50'), findsOneWidget);

      // Type some text.
      await tester.enterText(find.byType(EditableText), 'Hello');
      await tester.pumpAndSettle();

      expect(find.text('5/50'), findsOneWidget);
    });

    testWidgets('showCounter false hides counter', (tester) async {
      await tester.pumpObers(const OiTextInput(maxLength: 50));

      expect(find.text('0/50'), findsNothing);

      // Type text — still no counter.
      await tester.enterText(find.byType(EditableText), 'Hello');
      await tester.pumpAndSettle();

      expect(find.text('5/50'), findsNothing);
    });

    testWidgets('custom counterBuilder renders custom widget', (tester) async {
      await tester.pumpObers(
        OiTextInput(
          showCounter: true,
          maxLength: 100,
          counterBuilder:
              (
                context, {
                required int currentLength,
                required int? maxLength,
                required bool focused,
              }) {
                return Text(
                  '$currentLength chars remaining: ${maxLength! - currentLength}',
                );
              },
        ),
      );

      expect(find.text('0 chars remaining: 100'), findsOneWidget);

      await tester.enterText(find.byType(EditableText), 'Test');
      await tester.pumpAndSettle();

      expect(find.text('4 chars remaining: 96'), findsOneWidget);
    });
  });

  group('Interaction', () {
    testWidgets('onTap fires when input tapped', (tester) async {
      var tapped = false;

      await tester.pumpObers(OiTextInput(onTap: () => tapped = true));

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('password constructor renders with obscured text', (
      tester,
    ) async {
      await tester.pumpObers(const OiTextInput.password(label: 'Password'));

      // The password field should render an EditableText with obscureText.
      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editableText.obscureText, isTrue);
    });

    testWidgets('password trailing icon toggles visibility', (tester) async {
      await tester.pumpObers(const OiTextInput.password(label: 'Password'));

      // Initially obscured — eye icon (toggle to show) should be present.
      expect(find.byIcon(OiIcons.eye), findsOneWidget);
      expect(find.byIcon(OiIcons.eyeOff), findsNothing);

      // Tap the eye icon to reveal.
      await tester.tap(find.byIcon(OiIcons.eye));
      await tester.pumpAndSettle();

      // Now text is visible — eyeSlash icon (toggle to hide) shown.
      expect(find.byIcon(OiIcons.eyeOff), findsOneWidget);
      expect(find.byIcon(OiIcons.eye), findsNothing);

      // Verify the EditableText is no longer obscured.
      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editableText.obscureText, isFalse);

      // Tap again to re-obscure.
      await tester.tap(find.byIcon(OiIcons.eyeOff));
      await tester.pumpAndSettle();

      expect(find.byIcon(OiIcons.eye), findsOneWidget);
      final reobscured = tester.widget<EditableText>(find.byType(EditableText));
      expect(reobscured.obscureText, isTrue);
    });
  });

  group('Property forwarding', () {
    testWidgets('textCapitalization forwarded to OiRawInput', (tester) async {
      await tester.pumpObers(
        const OiTextInput(textCapitalization: TextCapitalization.words),
      );

      final rawInput = tester.widget<OiRawInput>(find.byType(OiRawInput));
      expect(rawInput.textCapitalization, TextCapitalization.words);
    });

    testWidgets('textAlign forwarded to OiRawInput', (tester) async {
      await tester.pumpObers(const OiTextInput(textAlign: TextAlign.center));

      final rawInput = tester.widget<OiRawInput>(find.byType(OiRawInput));
      expect(rawInput.textAlign, TextAlign.center);
    });

    testWidgets('showCounter false hides counter by default', (tester) async {
      await tester.pumpObers(const OiTextInput(maxLength: 50));

      // showCounter defaults to false, so no counter text should appear.
      expect(find.text('0/50'), findsNothing);

      await tester.enterText(find.byType(EditableText), 'Hello');
      await tester.pumpAndSettle();

      expect(find.text('5/50'), findsNothing);
    });

    testWidgets('onTapOutside property is stored on widget', (tester) async {
      void handler(PointerDownEvent event) {}

      await tester.pumpObers(OiTextInput(onTapOutside: handler));

      final widget = tester.widget<OiTextInput>(find.byType(OiTextInput));
      expect(widget.onTapOutside, equals(handler));
    });
  });

  group('Constructors', () {
    testWidgets('multiline constructor renders with correct keyboardType '
        'and textInputAction', (tester) async {
      await tester.pumpObers(const OiTextInput.multiline());

      final rawInput = tester.widget<OiRawInput>(find.byType(OiRawInput));
      expect(rawInput.keyboardType, TextInputType.multiline);
      expect(rawInput.textInputAction, TextInputAction.newline);
    });
  });
}
