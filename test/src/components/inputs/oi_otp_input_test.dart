// Tests do not require documentation comments.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiTextInput.otp', () {
    testWidgets('renders correct number of boxes for length=6',
        (tester) async {
      await tester.pumpObers(
        const OiTextInput.otp(length: 6, autofocus: false),
      );

      // Each OTP box contains an EditableText.
      expect(find.byType(EditableText), findsNWidgets(6));
    });

    testWidgets('renders correct number of boxes for length=4',
        (tester) async {
      await tester.pumpObers(
        const OiTextInput.otp(length: 4, autofocus: false),
      );

      expect(find.byType(EditableText), findsNWidgets(4));
    });

    testWidgets('digit entry auto-advances focus', (tester) async {
      await tester.pumpObers(
        const OiTextInput.otp(length: 4, autofocus: false),
      );

      final boxes = find.byType(EditableText);

      // Focus the first box and enter a digit.
      await tester.tap(boxes.at(0));
      await tester.pumpAndSettle();
      await tester.enterText(boxes.at(0), '1');
      await tester.pumpAndSettle();

      // After entering '1' in box 0, focus should move to box 1.
      final focusNode1 = tester.widget<EditableText>(boxes.at(1)).focusNode;
      expect(focusNode1.hasFocus, isTrue);
    });

    testWidgets('onCompleted fires when all boxes filled', (tester) async {
      String? completedValue;

      await tester.pumpObers(
        OiTextInput.otp(
          length: 4,
          autofocus: false,
          onCompleted: (value) => completedValue = value,
        ),
      );

      final boxes = find.byType(EditableText);

      // Fill each box one by one.
      await tester.enterText(boxes.at(0), '1');
      await tester.pumpAndSettle();
      await tester.enterText(boxes.at(1), '2');
      await tester.pumpAndSettle();
      await tester.enterText(boxes.at(2), '3');
      await tester.pumpAndSettle();

      // Not yet completed.
      expect(completedValue, isNull);

      await tester.enterText(boxes.at(3), '4');
      await tester.pumpAndSettle();

      expect(completedValue, '1234');
    });

    testWidgets('error state shows error text', (tester) async {
      await tester.pumpObers(
        const OiTextInput.otp(
          length: 6,
          autofocus: false,
          error: 'Invalid code',
        ),
      );

      expect(find.text('Invalid code'), findsOneWidget);
    });

    testWidgets('disabled state shows reduced opacity', (tester) async {
      await tester.pumpObers(
        const OiTextInput.otp(
          length: 4,
          autofocus: false,
          enabled: false,
        ),
      );

      // The OTP widget wraps its row in an Opacity widget with 0.6 when
      // disabled.
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.6);
    });

    testWidgets('non-digit input is rejected', (tester) async {
      await tester.pumpObers(
        const OiTextInput.otp(length: 4, autofocus: false),
      );

      final boxes = find.byType(EditableText);

      // Try entering a letter — the digits-only formatter should reject it.
      await tester.enterText(boxes.at(0), 'a');
      await tester.pumpAndSettle();

      // The box should remain empty.
      final controller = tester.widget<EditableText>(boxes.at(0)).controller;
      expect(controller.text, isEmpty);
    });

    testWidgets('backspace on empty box moves focus to previous box',
        (tester) async {
      await tester.pumpObers(
        const OiTextInput.otp(length: 4, autofocus: false),
      );

      final boxes = find.byType(EditableText);

      // Enter a digit in box 0 — focus advances to box 1.
      await tester.tap(boxes.at(0));
      await tester.pumpAndSettle();
      await tester.enterText(boxes.at(0), '5');
      await tester.pumpAndSettle();

      // Box 1 should now have focus.
      expect(
        tester.widget<EditableText>(boxes.at(1)).focusNode.hasFocus,
        isTrue,
      );

      // Press backspace on the empty box 1 — should move focus to box 0.
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pumpAndSettle();

      expect(
        tester.widget<EditableText>(boxes.at(0)).focusNode.hasFocus,
        isTrue,
      );
    });

    testWidgets('obscure: true sets obscureText on EditableText',
        (tester) async {
      await tester.pumpObers(
        const OiTextInput.otp(length: 4, autofocus: false, obscure: true),
      );

      final boxes = find.byType(EditableText);

      // Every OTP box's EditableText should have obscureText enabled.
      for (var i = 0; i < 4; i++) {
        final editableText = tester.widget<EditableText>(boxes.at(i));
        expect(editableText.obscureText, isTrue);
      }
    });

    testWidgets('paste distributes digits across boxes', (tester) async {
      String? completedValue;

      await tester.pumpObers(
        OiTextInput.otp(
          length: 4,
          autofocus: false,
          onCompleted: (value) => completedValue = value,
        ),
      );

      final boxes = find.byType(EditableText);

      // Focus the first box.
      await tester.tap(boxes.at(0));
      await tester.pumpAndSettle();

      // Simulate paste by directly setting the controller text to a
      // multi-character string. The LengthLimitingTextInputFormatter
      // prevents multi-char entry via enterText, but a real paste
      // operation sets the controller value directly.
      tester.widget<EditableText>(boxes.at(0)).controller.text = '1234';
      await tester.pumpAndSettle();

      // Each box should contain one digit after distribution.
      for (var i = 0; i < 4; i++) {
        final boxController =
            tester.widget<EditableText>(boxes.at(i)).controller;
        expect(boxController.text, '${i + 1}');
      }

      // onCompleted should have fired with the full code.
      expect(completedValue, '1234');
    });
  });
}
