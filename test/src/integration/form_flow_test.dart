// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/forms/oi_form.dart';

import '../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

List<OiFormSection> _sections({bool withValidation = false}) => [
  OiFormSection(
    title: 'Contact',
    fields: [
      OiFormField(
        key: 'firstName',
        label: 'First Name',
        type: OiFieldType.text,
        required: withValidation,
      ),
      OiFormField(
        key: 'lastName',
        label: 'Last Name',
        type: OiFieldType.text,
        required: withValidation,
      ),
      OiFormField(
        key: 'email',
        label: 'Email',
        type: OiFieldType.text,
        required: withValidation,
        validate: withValidation
            ? (v) {
                if (v == null || v == '') return 'Email is required';
                if (!(v as String).contains('@')) return 'Invalid email';
                return null;
              }
            : null,
      ),
    ],
  ),
];

Widget _form({
  OiFormController? controller,
  List<OiFormSection>? sections,
  ValueChanged<Map<String, dynamic>>? onSubmit,
  VoidCallback? onCancel,
  bool dirtyDetection = false,
}) {
  return SizedBox(
    width: 500,
    height: 700,
    child: OiForm(
      sections: sections ?? _sections(),
      controller: controller ?? OiFormController(),
      onSubmit: onSubmit,
      onCancel: onCancel,
      dirtyDetection: dirtyDetection,
    ),
  );
}

// ── Integration tests ─────────────────────────────────────────────────────────

void main() {
  group('Form fill → validate → submit flow', () {
    testWidgets('fill fields and submit successfully', (tester) async {
      final ctrl = OiFormController();
      Map<String, dynamic>? submitted;

      await tester.pumpObers(
        _form(controller: ctrl, onSubmit: (v) => submitted = v),
        surfaceSize: const Size(600, 800),
      );

      // Fill in fields via the controller (typed text inputs are backed by
      // the controller's value map).
      ctrl
        ..setValue('firstName', 'Alice')
        ..setValue('lastName', 'Smith')
        ..setValue('email', 'alice@example.com');
      await tester.pump();

      // Submit the form.
      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(submitted, isNotNull);
      expect(submitted!['firstName'], 'Alice');
      expect(submitted!['lastName'], 'Smith');
      expect(submitted!['email'], 'alice@example.com');
    });

    testWidgets('required field validation blocks submit', (tester) async {
      final ctrl = OiFormController();
      Map<String, dynamic>? submitted;

      await tester.pumpObers(
        _form(
          sections: _sections(withValidation: true),
          controller: ctrl,
          onSubmit: (v) => submitted = v,
        ),
        surfaceSize: const Size(600, 800),
      );

      // Attempt to submit without filling required fields.
      await tester.tap(find.text('Submit'));
      await tester.pump();

      // Submit should not have been called because required fields are empty.
      expect(submitted, isNull);
    });

    testWidgets('fix validation errors then submit succeeds', (tester) async {
      final ctrl = OiFormController();
      Map<String, dynamic>? submitted;

      await tester.pumpObers(
        _form(
          sections: _sections(withValidation: true),
          controller: ctrl,
          onSubmit: (v) => submitted = v,
        ),
        surfaceSize: const Size(600, 800),
      );

      // First attempt fails.
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(submitted, isNull);

      // Fill in all required fields.
      ctrl
        ..setValue('firstName', 'Bob')
        ..setValue('lastName', 'Jones')
        ..setValue('email', 'bob@example.com');
      await tester.pump();

      // Second attempt succeeds.
      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(submitted, isNotNull);
      expect(submitted!['firstName'], 'Bob');
      expect(submitted!['email'], 'bob@example.com');
    });

    testWidgets('cancel callback fires', (tester) async {
      var cancelled = false;

      await tester.pumpObers(
        _form(onCancel: () => cancelled = true),
        surfaceSize: const Size(600, 800),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(cancelled, isTrue);
    });

    testWidgets('controller tracks dirty state across flow', (tester) async {
      final ctrl = OiFormController(
        initialValues: {'firstName': '', 'lastName': '', 'email': ''},
      );

      await tester.pumpObers(
        _form(controller: ctrl, onSubmit: (_) {}, dirtyDetection: true),
        surfaceSize: const Size(600, 800),
      );

      // Initially not dirty.
      expect(ctrl.isDirty, isFalse);

      // Modify a value.
      ctrl.setValue('firstName', 'Changed');
      await tester.pump();

      expect(ctrl.isDirty, isTrue);

      // Reset and verify clean.
      ctrl.reset();
      await tester.pump();

      expect(ctrl.isDirty, isFalse);
      expect(ctrl.getValue<String>('firstName'), '');
    });
  });
}
