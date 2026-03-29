// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('Form validation', () {
    testWidgets('sync validator displays error on form.validate()',
        (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpObers(
        Form(
          key: formKey,
          child: const OiTextInput(
            validator: _requiredValidator,
          ),
        ),
      );

      // Trigger validation on an empty field.
      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('validator clears when valid input entered', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpObers(
        Form(
          key: formKey,
          child: const OiTextInput(
            validator: _requiredValidator,
          ),
        ),
      );

      // Trigger validation to show error.
      formKey.currentState!.validate();
      await tester.pumpAndSettle();
      expect(find.text('Required'), findsOneWidget);

      // Enter valid text.
      await tester.enterText(find.byType(EditableText), 'hello');
      await tester.pumpAndSettle();

      // Re-validate — should pass now.
      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsNothing);
    });

    testWidgets('autovalidateMode.onUserInteraction triggers on edit',
        (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpObers(
        Form(
          key: formKey,
          child: const OiTextInput(
            validator: _minLengthValidator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),
      );

      // No error initially.
      expect(find.text('Too short'), findsNothing);

      // Type something too short — should trigger auto-validation.
      await tester.enterText(find.byType(EditableText), 'ab');
      await tester.pumpAndSettle();

      expect(find.text('Too short'), findsOneWidget);

      // Type enough characters — error clears.
      await tester.enterText(find.byType(EditableText), 'abcde');
      await tester.pumpAndSettle();

      expect(find.text('Too short'), findsNothing);
    });

    testWidgets('manual error overrides validator error', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpObers(
        Form(
          key: formKey,
          child: const OiTextInput(
            error: 'Manual error',
            validator: _requiredValidator,
          ),
        ),
      );

      // The manual error is always shown regardless of validator state.
      expect(find.text('Manual error'), findsOneWidget);

      // Even after validation, the manual error takes priority.
      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      // The manual error prop should still be visible (it overrides).
      expect(find.text('Manual error'), findsOneWidget);
    });

    testWidgets('Form.save() calls onSaved with current value',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      String? savedValue;

      await tester.pumpObers(
        Form(
          key: formKey,
          child: OiTextInput(
            validator: (_) => null,
            onSaved: (value) => savedValue = value,
          ),
        ),
      );

      // Enter text.
      await tester.enterText(find.byType(EditableText), 'saved text');
      await tester.pumpAndSettle();

      // Save the form.
      formKey.currentState!.save();
      await tester.pumpAndSettle();

      expect(savedValue, 'saved text');
    });

    testWidgets('multiple OiTextInputs in one Form validate independently',
        (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpObers(
        Form(
          key: formKey,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OiTextInput(
                label: 'Name',
                validator: _requiredValidator,
              ),
              OiTextInput(
                label: 'Email',
                validator: _emailValidator,
              ),
            ],
          ),
        ),
      );

      // Trigger validation on both — both empty.
      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Invalid email'), findsOneWidget);

      // Fill the name field only.
      final editableTexts = find.byType(EditableText);
      await tester.enterText(editableTexts.at(0), 'Alice');
      await tester.pumpAndSettle();

      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      // Name error should be gone, email error remains.
      expect(find.text('Required'), findsNothing);
      expect(find.text('Invalid email'), findsOneWidget);

      // Fill the email field.
      await tester.enterText(editableTexts.at(1), 'alice@example.com');
      await tester.pumpAndSettle();

      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      expect(find.text('Invalid email'), findsNothing);
    });

    testWidgets('autovalidateMode.always shows error immediately on mount',
        (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpObers(
        Form(
          key: formKey,
          child: const OiTextInput(
            validator: _requiredValidator,
            autovalidateMode: AutovalidateMode.always,
          ),
        ),
      );

      // With AutovalidateMode.always, the error should be visible
      // immediately without any user interaction or manual validate() call.
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('FormField key access — state is accessible via GlobalKey',
        (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpObers(
        Form(
          key: formKey,
          child: const OiTextInput(
            validator: _requiredValidator,
          ),
        ),
      );

      // The OiTextInput with a validator wraps a FormField<String> internally.
      // Verify that the Form's state can access and validate it.
      final formState = formKey.currentState;
      expect(formState, isNotNull);

      // Validate returns false for empty required field.
      expect(formState!.validate(), isFalse);
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsOneWidget);

      // Enter text and re-validate — should pass.
      await tester.enterText(find.byType(EditableText), 'test');
      await tester.pumpAndSettle();

      expect(formState.validate(), isTrue);
    });
  });
}

// ── Validator helpers ────────────────────────────────────────────────────────

String? _requiredValidator(String? value) {
  if (value == null || value.isEmpty) return 'Required';
  return null;
}

String? _minLengthValidator(String? value) {
  if (value == null || value.length < 5) return 'Too short';
  return null;
}

String? _emailValidator(String? value) {
  if (value == null || !value.contains('@')) return 'Invalid email';
  return null;
}
