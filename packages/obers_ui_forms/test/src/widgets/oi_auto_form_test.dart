import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart' hide OiFormController;
import 'package:obers_ui_forms/obers_ui_forms.dart';

import '../../helpers/pump_app.dart';

enum SignupFields { name, email, password, passwordRepeat, newsletter, age }

class SignupController extends OiFormController<SignupFields> {
  @override
  Map<SignupFields, OiFormInputController<dynamic>> inputs() => {
    SignupFields.name: OiFormInputController<String>(
      required: true,
      validation: [OiFormValidation.minLength(3)],
    ),
    SignupFields.email: OiFormInputController<String>(
      required: true,
      validation: [OiFormValidation.email()],
      validateOnChange: true,
    ),
    SignupFields.password: OiFormInputController<String>(
      required: true,
      validation: [
        OiFormValidation.securePassword(minLength: 8, requiresUppercase: true),
      ],
    ),
    SignupFields.passwordRepeat: OiFormInputController<String>(
      save: false,
      validation: [OiFormValidation.equals<String>(SignupFields.password)],
    ),
    SignupFields.newsletter: OiFormInputController<bool>(initialValue: false),
    SignupFields.age: OiFormInputController<double>(),
  };
}

void main() {
  group('OiAutoForm', () {
    testWidgets('provides controller and onSubmit to descendants', (
      tester,
    ) async {
      final controller = SignupController();
      var submitted = false;

      await tester.pumpObers(
        OiAutoForm<SignupFields>(
          controller: controller,
          onSubmit: (data, ctrl) => submitted = true,
          child: Builder(
            builder: (context) {
              // Verify scope is accessible
              final ctrl = OiFormScope.of<SignupFields>(context);
              expect(ctrl, same(controller));
              return const SizedBox();
            },
          ),
        ),
      );

      expect(submitted, isFalse);
      controller.dispose();
    });
  });

  group('OiAutoFormTextInput', () {
    testWidgets('renders label and binds to form controller', (tester) async {
      final controller = SignupController();

      await tester.pumpObers(
        OiAutoForm<SignupFields>(
          controller: controller,
          child: OiAutoFormTextInput<SignupFields>(
            fieldKey: SignupFields.name,
            label: 'Full Name',
            placeholder: 'Enter name',
          ),
        ),
      );

      // Label should be rendered with required indicator
      expect(find.textContaining('Full Name'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('typing updates form controller value', (tester) async {
      final controller = SignupController();

      await tester.pumpObers(
        OiAutoForm<SignupFields>(
          controller: controller,
          child: OiAutoFormTextInput<SignupFields>(
            fieldKey: SignupFields.name,
            label: 'Name',
          ),
        ),
      );

      await tester.enterText(find.byType(EditableText), 'John Doe');
      await tester.pump();

      expect(controller.get<String>(SignupFields.name), 'John Doe');

      controller.dispose();
    });

    testWidgets('displays validation error from controller', (tester) async {
      final controller = SignupController();
      controller.set<String>(SignupFields.name, 'Jo');
      controller.validate();

      await tester.pumpObers(
        OiAutoForm<SignupFields>(
          controller: controller,
          child: OiAutoFormTextInput<SignupFields>(
            fieldKey: SignupFields.name,
            label: 'Name',
          ),
        ),
      );

      expect(find.textContaining('at least 3'), findsOneWidget);

      // Allow microtasks to complete before dispose
      await tester.pumpAndSettle();
      controller.dispose();
    });
  });

  group('OiAutoFormCheckbox', () {
    testWidgets('renders and toggles value', (tester) async {
      final controller = SignupController();

      await tester.pumpObers(
        OiAutoForm<SignupFields>(
          controller: controller,
          child: OiAutoFormCheckbox<SignupFields>(
            fieldKey: SignupFields.newsletter,
            label: 'Newsletter',
            checkboxLabel: 'Subscribe',
          ),
        ),
      );

      expect(controller.get<bool>(SignupFields.newsletter), false);

      // Tap the checkbox
      await tester.tap(find.byType(OiCheckbox));
      await tester.pump();

      expect(controller.get<bool>(SignupFields.newsletter), true);

      controller.dispose();
    });
  });

  group('Integration: complete form lifecycle', () {
    testWidgets('fill → validate → submit → get data', (tester) async {
      final controller = SignupController();
      Map<SignupFields, dynamic>? submittedData;

      await tester.pumpObers(
        OiAutoForm<SignupFields>(
          controller: controller,
          onSubmit: (data, ctrl) => submittedData = data,
          child: Column(
            children: [
              OiAutoFormTextInput<SignupFields>(
                fieldKey: SignupFields.name,
                label: 'Name',
              ),
              OiAutoFormTextInput<SignupFields>(
                fieldKey: SignupFields.email,
                label: 'Email',
              ),
              OiAutoFormTextInput<SignupFields>.password(
                fieldKey: SignupFields.password,
                label: 'Password',
              ),
              OiFormSubmitButton<SignupFields>(label: 'Submit'),
            ],
          ),
        ),
      );

      // Form should be invalid initially (required fields empty)
      expect(controller.isValid, isFalse);

      // Fill in required fields
      controller
        ..set<String>(SignupFields.name, 'John Doe')
        ..set<String>(SignupFields.email, 'john@example.com')
        ..set<String>(SignupFields.password, 'SecurePass1!');
      await tester.pump();

      // Form should now be valid
      expect(controller.isValid, isTrue);

      // Submit
      await controller.submit((data, ctrl) => submittedData = data);

      // Verify submitted data
      expect(submittedData, isNotNull);
      expect(submittedData![SignupFields.name], 'John Doe');
      expect(submittedData![SignupFields.email], 'john@example.com');
      // passwordRepeat should NOT be in data (save: false)
      expect(submittedData!.containsKey(SignupFields.passwordRepeat), isFalse);

      controller.dispose();
    });

    testWidgets('submit blocked when form is invalid', (tester) async {
      final controller = SignupController();
      var submitted = false;

      await controller.submit((_, _) => submitted = true);

      expect(submitted, isFalse);
      expect(controller.getErrors(), isNotEmpty);

      controller.dispose();
    });

    testWidgets('reset clears all values and errors', (tester) async {
      final controller = SignupController();

      controller
        ..set<String>(SignupFields.name, 'John')
        ..set<String>(SignupFields.email, 'invalid')
        ..validate();

      expect(controller.isDirty, isTrue);
      expect(controller.getErrors(), isNotEmpty);

      controller.reset();

      expect(controller.isDirty, isFalse);
      expect(controller.getErrors(), isEmpty);
      expect(controller.get<String>(SignupFields.name), isNull);

      controller.dispose();
    });
  });

  group('validateOnChange', () {
    test('auto-validates field when value changes if enabled', () {
      final controller = SignupController();

      // email has validateOnChange: true
      controller.set<String>(SignupFields.email, 'invalid');

      // Should have auto-validated and produced errors
      expect(controller.getError(SignupFields.email), isNotEmpty);

      controller.dispose();
    });

    test('does not auto-validate when validateOnChange is false', () {
      final controller = SignupController();

      // name does NOT have validateOnChange
      controller.set<String>(SignupFields.name, 'Jo');

      // Should NOT have errors yet (no manual validate called)
      expect(controller.getError(SignupFields.name), isEmpty);

      controller.dispose();
    });
  });

  group('validateOnBlur', () {
    test('validates field on blur when enabled', () {
      // Create a controller with validateOnBlur on name
      final controller = _BlurValidateController();

      controller.set<String>(_BlurFields.name, 'Jo');
      expect(controller.getError(_BlurFields.name), isEmpty);

      // Simulate blur
      controller.onFieldBlur(_BlurFields.name);

      expect(controller.getError(_BlurFields.name), isNotEmpty);

      controller.dispose();
    });
  });

  group('get with fallback', () {
    test('returns fallback when value is null', () {
      final controller = SignupController();

      final value = controller.get<String>(
        SignupFields.name,
        fallback: 'Default',
      );

      expect(value, 'Default');

      controller.dispose();
    });

    test('returns actual value when not null', () {
      final controller = SignupController();
      controller.set<String>(SignupFields.name, 'John');

      final value = controller.get<String>(
        SignupFields.name,
        fallback: 'Default',
      );

      expect(value, 'John');

      controller.dispose();
    });
  });

  group('OiFormErrorSummary', () {
    testWidgets('renders all field errors', (tester) async {
      // Use a simple controller without validateOnChange to test
      // manual error injection without auto-validation interference
      final controller = _SimpleController();
      controller.setError(_SimpleFields.first, 'First is required');
      controller.setError(_SimpleFields.second, 'Second is invalid');

      await tester.pumpObers(
        OiFormScope<_SimpleFields>(
          controller: controller,
          child: OiFormErrorSummary<_SimpleFields>(),
        ),
      );

      expect(find.textContaining('First is required'), findsOneWidget);
      expect(find.textContaining('Second is invalid'), findsOneWidget);
      expect(find.textContaining('fix the following'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('renders nothing when no errors', (tester) async {
      final controller = _SimpleController();

      await tester.pumpObers(
        OiFormScope<_SimpleFields>(
          controller: controller,
          child: OiFormErrorSummary<_SimpleFields>(),
        ),
      );

      expect(find.textContaining('fix the following'), findsNothing);

      controller.dispose();
    });
  });

  group('OiFormSubmitButton callback', () {
    testWidgets('invokes onSubmit when form is valid and tapped', (
      tester,
    ) async {
      final controller = SignupController();
      controller
        ..set<String>(SignupFields.name, 'John Doe')
        ..set<String>(SignupFields.email, 'john@example.com')
        ..set<String>(SignupFields.password, 'SecurePass1!');

      var submitted = false;

      await tester.pumpObers(
        OiAutoForm<SignupFields>(
          controller: controller,
          onSubmit: (_, _) => submitted = true,
          child: OiFormSubmitButton<SignupFields>(label: 'Submit'),
        ),
      );

      await tester.tap(find.byType(OiFormSubmitButton<SignupFields>));
      await tester.pumpAndSettle();

      expect(submitted, isTrue);

      controller.dispose();
    });
  });

  group('watchMode triggers', () {
    test('onSubmit recomputes field during submit', () async {
      final controller = _OnSubmitWatchController();

      controller.set<String>(_WatchFields.input, 'hello');
      // Before submit, computed field has no value
      expect(controller.get<String>(_WatchFields.computed), isNull);

      await controller.submit(null);

      // After submit, computed field should have been recomputed
      expect(controller.get<String>(_WatchFields.computed), 'HELLO');

      controller.dispose();
    });
  });
}

// ─── Test helpers ──────────────────────────────────────────────

enum _BlurFields { name }

class _BlurValidateController extends OiFormController<_BlurFields> {
  @override
  Map<_BlurFields, OiFormInputController<dynamic>> inputs() => {
    _BlurFields.name: OiFormInputController<String>(
      required: true,
      validation: [OiFormValidation.minLength(3)],
      validateOnBlur: true,
    ),
  };
}

enum _SimpleFields { first, second }

class _SimpleController extends OiFormController<_SimpleFields> {
  @override
  Map<_SimpleFields, OiFormInputController<dynamic>> inputs() => {
    _SimpleFields.first: OiFormInputController<String>(),
    _SimpleFields.second: OiFormInputController<String>(),
  };
}

enum _WatchFields { input, computed }

class _OnSubmitWatchController extends OiFormController<_WatchFields> {
  @override
  Map<_WatchFields, OiFormInputController<dynamic>> inputs() => {
    _WatchFields.input: OiFormInputController<String>(),
    _WatchFields.computed: OiFormInputController<String>(
      watch: [_WatchFields.input],
      watchMode: OiFormWatchMode.onSubmit,
      computeValue: (controller) {
        final input = (controller as OiFormController<_WatchFields>)
            .get<String>(_WatchFields.input);
        return input?.toUpperCase() ?? '';
      },
    ),
  };
}
