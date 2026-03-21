// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_color_input.dart';
import 'package:obers_ui/src/components/inputs/oi_date_input.dart';
import 'package:obers_ui/src/components/inputs/oi_file_input.dart';
import 'package:obers_ui/src/components/inputs/oi_radio.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';
import 'package:obers_ui/src/components/inputs/oi_slider.dart';
import 'package:obers_ui/src/components/inputs/oi_tag_input.dart';
import 'package:obers_ui/src/components/inputs/oi_time_input.dart';
import 'package:obers_ui/src/composites/forms/oi_form.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

List<OiFormSection> _simpleSections() => [
  const OiFormSection(
    title: 'Personal Info',
    description: 'Enter your details',
    fields: [
      OiFormField(key: 'name', label: 'Name', type: OiFieldType.text),
      OiFormField(key: 'age', label: 'Age', type: OiFieldType.number),
    ],
  ),
];

Widget _form({
  List<OiFormSection>? sections,
  OiFormController? controller,
  ValueChanged<Map<String, dynamic>>? onSubmit,
  VoidCallback? onCancel,
  bool autoValidate = false,
  OiFormLayout layout = OiFormLayout.vertical,
  bool dirtyDetection = true,
}) {
  return SizedBox(
    width: 400,
    height: 600,
    child: OiForm(
      sections: sections ?? _simpleSections(),
      controller: controller ?? OiFormController(),
      onSubmit: onSubmit,
      onCancel: onCancel,
      autoValidate: autoValidate,
      layout: layout,
      dirtyDetection: dirtyDetection,
    ),
  );
}

// ── OiFormController unit tests ─────────────────────────────────────────────

void main() {
  group('OiFormController', () {
    test('setValue and getValue work', () {
      final ctrl = OiFormController()..setValue('name', 'Alice');
      expect(ctrl.getValue<String>('name'), 'Alice');
    });

    test('values returns all current values', () {
      final ctrl = OiFormController(initialValues: {'a': 1})..setValue('b', 2);
      expect(ctrl.values, {'a': 1, 'b': 2});
    });

    test('isDirty returns false when no changes are made', () {
      final ctrl = OiFormController(initialValues: {'x': 10});
      expect(ctrl.isDirty, isFalse);
    });

    test('isDirty returns true after setValue changes a value', () {
      final ctrl = OiFormController(initialValues: {'x': 10})
        ..setValue('x', 20);
      expect(ctrl.isDirty, isTrue);
    });

    test('isDirty returns true when a new key is added', () {
      final ctrl = OiFormController(initialValues: {'x': 10})..setValue('y', 5);
      expect(ctrl.isDirty, isTrue);
    });

    test('reset reverts to initial values', () {
      final ctrl = OiFormController(initialValues: {'x': 10})
        ..setValue('x', 99)
        ..setValue('y', 5)
        ..reset();
      expect(ctrl.getValue<int>('x'), 10);
      expect(ctrl.getValue<dynamic>('y'), isNull);
      expect(ctrl.isDirty, isFalse);
    });

    test('reset clears errors', () {
      final ctrl = OiFormController()..setError('name', 'Required');
      expect(ctrl.isValid, isFalse);
      ctrl.reset();
      expect(ctrl.isValid, isTrue);
    });

    test('setError and getError work', () {
      final ctrl = OiFormController()..setError('email', 'Invalid');
      expect(ctrl.getError('email'), 'Invalid');
    });

    test('isValid is true when no errors', () {
      final ctrl = OiFormController();
      expect(ctrl.isValid, isTrue);
    });

    test('isValid is false when any error is set', () {
      final ctrl = OiFormController()..setError('field', 'bad');
      expect(ctrl.isValid, isFalse);
    });

    test('isValid is true when error is cleared with null', () {
      final ctrl = OiFormController()
        ..setError('field', 'bad')
        ..setError('field', null);
      expect(ctrl.isValid, isTrue);
    });

    test('validate runs validators and stores errors', () {
      final ctrl = OiFormController(initialValues: {'name': ''});
      final valid = ctrl.validate({
        'name': (v) => (v == null || v == '') ? 'Required' : null,
      });
      expect(valid, isFalse);
      expect(ctrl.getError('name'), 'Required');
    });

    test('validate returns true when all validators pass', () {
      final ctrl = OiFormController(initialValues: {'name': 'Alice'});
      final valid = ctrl.validate({
        'name': (v) => (v == null || v == '') ? 'Required' : null,
      });
      expect(valid, isTrue);
      expect(ctrl.getError('name'), isNull);
    });

    test('notifies listeners on setValue', () {
      var notified = false;
      OiFormController()
        ..addListener(() => notified = true)
        ..setValue('a', 1);
      expect(notified, isTrue);
    });

    test('notifies listeners on setError', () {
      var notified = false;
      OiFormController()
        ..addListener(() => notified = true)
        ..setError('a', 'err');
      expect(notified, isTrue);
    });

    test('notifies listeners on reset', () {
      var notified = false;
      OiFormController(initialValues: {'a': 1})
        ..setValue('a', 2)
        ..addListener(() => notified = true)
        ..reset();
      expect(notified, isTrue);
    });
  });

  // ── OiForm widget tests ───────────────────────────────────────────────────

  group('OiForm', () {
    testWidgets('fields render from config', (tester) async {
      await tester.pumpObers(_form());

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
    });

    testWidgets('section title renders', (tester) async {
      await tester.pumpObers(_form());

      expect(find.text('Personal Info'), findsOneWidget);
    });

    testWidgets('section description renders', (tester) async {
      await tester.pumpObers(_form());

      expect(find.text('Enter your details'), findsOneWidget);
    });

    testWidgets('submit button renders when onSubmit is provided', (
      tester,
    ) async {
      await tester.pumpObers(_form(onSubmit: (_) {}));

      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('cancel button renders when onCancel is provided', (
      tester,
    ) async {
      await tester.pumpObers(_form(onCancel: () {}));

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('submit collects values with dirtyDetection off', (
      tester,
    ) async {
      final ctrl = OiFormController();
      Map<String, dynamic>? submitted;

      await tester.pumpObers(
        _form(
          controller: ctrl,
          onSubmit: (v) => submitted = v,
          dirtyDetection: false,
        ),
      );

      ctrl.setValue('name', 'Bob');
      await tester.pump();

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(submitted, isNotNull);
      expect(submitted!['name'], 'Bob');
    });

    testWidgets('required field validation prevents submit', (tester) async {
      final ctrl = OiFormController();
      Map<String, dynamic>? submitted;

      await tester.pumpObers(
        _form(
          sections: [
            const OiFormSection(
              fields: [
                OiFormField(
                  key: 'email',
                  label: 'Email',
                  type: OiFieldType.text,
                  required: true,
                ),
              ],
            ),
          ],
          controller: ctrl,
          onSubmit: (v) => submitted = v,
          dirtyDetection: false,
        ),
      );

      // Submit without filling required field.
      await tester.tap(find.text('Submit'));
      await tester.pump();

      // Submit should not have been called because validation fails.
      expect(submitted, isNull);
      expect(ctrl.getError('email'), 'Email is required');
    });

    testWidgets('autoValidate validates on change', (tester) async {
      final ctrl = OiFormController();

      await tester.pumpObers(
        _form(
          sections: [
            OiFormSection(
              fields: [
                OiFormField(
                  key: 'code',
                  label: 'Code',
                  type: OiFieldType.text,
                  validate: (v) =>
                      (v == null || v == '') ? 'Code required' : null,
                ),
              ],
            ),
          ],
          controller: ctrl,
          autoValidate: true,
        ),
      );

      // Setting empty value should trigger validation via autoValidate.
      ctrl.setValue('code', '');
      await tester.pump();

      expect(ctrl.getError('code'), 'Code required');
    });

    testWidgets('cancel calls onCancel and resets controller', (tester) async {
      final ctrl = OiFormController(initialValues: {'name': 'Alice'})
        ..setValue('name', 'Bob');
      var cancelled = false;

      await tester.pumpObers(
        _form(controller: ctrl, onCancel: () => cancelled = true),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(cancelled, isTrue);
      expect(ctrl.getValue<String>('name'), 'Alice');
    });

    testWidgets('checkbox field renders', (tester) async {
      final ctrl = OiFormController();

      await tester.pumpObers(
        _form(
          sections: [
            const OiFormSection(
              fields: [
                OiFormField(
                  key: 'agree',
                  label: 'I agree',
                  type: OiFieldType.checkbox,
                ),
              ],
            ),
          ],
          controller: ctrl,
        ),
      );

      expect(find.text('I agree'), findsOneWidget);
    });

    testWidgets('switch field renders', (tester) async {
      final ctrl = OiFormController();

      await tester.pumpObers(
        _form(
          sections: [
            const OiFormSection(
              fields: [
                OiFormField(
                  key: 'notifications',
                  label: 'Notifications',
                  type: OiFieldType.switchField,
                ),
              ],
            ),
          ],
          controller: ctrl,
        ),
      );

      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('custom field builder renders', (tester) async {
      final ctrl = OiFormController();

      await tester.pumpObers(
        _form(
          sections: [
            OiFormSection(
              fields: [
                OiFormField(
                  key: 'custom',
                  label: 'Custom',
                  type: OiFieldType.custom,
                  customBuilder: (value, onChanged) =>
                      const Text('Custom Widget'),
                ),
              ],
            ),
          ],
          controller: ctrl,
        ),
      );

      expect(find.text('Custom Widget'), findsOneWidget);
    });

    testWidgets('horizontal layout renders fields in a Row', (tester) async {
      await tester.pumpObers(_form(layout: OiFormLayout.horizontal));

      // Horizontal layout wraps fields in a Row with Expanded children.
      expect(find.byType(Expanded), findsWidgets);
    });

    testWidgets('inline layout renders fields in a Wrap', (tester) async {
      await tester.pumpObers(_form(layout: OiFormLayout.inline));

      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('date field renders', (tester) async {
      final ctrl = OiFormController();

      await tester.pumpObers(
        _form(
          sections: [
            const OiFormSection(
              fields: [
                OiFormField(
                  key: 'dob',
                  label: 'Date of Birth',
                  type: OiFieldType.date,
                ),
              ],
            ),
          ],
          controller: ctrl,
        ),
      );

      expect(find.byType(OiDateInput), findsOneWidget);
    });

    testWidgets('time field renders', (tester) async {
      final ctrl = OiFormController();

      await tester.pumpObers(
        _form(
          sections: [
            const OiFormSection(
              fields: [
                OiFormField(
                  key: 'alarm',
                  label: 'Alarm Time',
                  type: OiFieldType.time,
                ),
              ],
            ),
          ],
          controller: ctrl,
        ),
      );

      expect(find.byType(OiTimeInput), findsOneWidget);
    });

    testWidgets('radio field renders', (tester) async {
      final ctrl = OiFormController();

      await tester.pumpObers(
        _form(
          sections: [
            const OiFormSection(
              fields: [
                OiFormField(
                  key: 'size',
                  label: 'Size',
                  type: OiFieldType.radio,
                  config: {
                    'options': [
                      OiRadioOption<dynamic>(value: 's', label: 'Small'),
                      OiRadioOption<dynamic>(value: 'l', label: 'Large'),
                    ],
                  },
                ),
              ],
            ),
          ],
          controller: ctrl,
        ),
      );

      expect(find.byType(OiRadio<dynamic>), findsOneWidget);
    });

    testWidgets('slider field renders', (tester) async {
      final ctrl = OiFormController();

      await tester.pumpObers(
        _form(
          sections: [
            const OiFormSection(
              fields: [
                OiFormField(
                  key: 'volume',
                  label: 'Volume',
                  type: OiFieldType.slider,
                  config: {'min': 0.0, 'max': 100.0},
                ),
              ],
            ),
          ],
          controller: ctrl,
        ),
      );

      expect(find.byType(OiSlider), findsOneWidget);
    });

    testWidgets('color field renders', (tester) async {
      final ctrl = OiFormController();

      await tester.pumpObers(
        _form(
          sections: [
            const OiFormSection(
              fields: [
                OiFormField(
                  key: 'bg',
                  label: 'Background Color',
                  type: OiFieldType.color,
                ),
              ],
            ),
          ],
          controller: ctrl,
        ),
      );

      expect(find.byType(OiColorInput), findsOneWidget);
    });

    testWidgets('file field renders', (tester) async {
      final ctrl = OiFormController();

      await tester.pumpObers(
        _form(
          sections: [
            const OiFormSection(
              fields: [
                OiFormField(
                  key: 'attachment',
                  label: 'Attachment',
                  type: OiFieldType.file,
                ),
              ],
            ),
          ],
          controller: ctrl,
        ),
      );

      expect(find.byType(OiFileInput), findsOneWidget);
    });

    testWidgets('tag field renders', (tester) async {
      final ctrl = OiFormController();

      await tester.pumpObers(
        _form(
          sections: [
            const OiFormSection(
              fields: [
                OiFormField(key: 'tags', label: 'Tags', type: OiFieldType.tag),
              ],
            ),
          ],
          controller: ctrl,
        ),
      );

      expect(find.byType(OiTagInput), findsOneWidget);
    });

    testWidgets('tag field required validation fails for empty list', (
      tester,
    ) async {
      final ctrl = OiFormController(initialValues: {'tags': <String>[]});
      Map<String, dynamic>? submitted;

      await tester.pumpObers(
        _form(
          sections: [
            const OiFormSection(
              fields: [
                OiFormField(
                  key: 'tags',
                  label: 'Tags',
                  type: OiFieldType.tag,
                  required: true,
                ),
              ],
            ),
          ],
          controller: ctrl,
          onSubmit: (v) => submitted = v,
          dirtyDetection: false,
        ),
      );

      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(submitted, isNull);
      expect(ctrl.getError('tags'), 'Tags is required');
    });

    testWidgets('select field renders', (tester) async {
      final ctrl = OiFormController();

      await tester.pumpObers(
        _form(
          sections: [
            const OiFormSection(
              fields: [
                OiFormField(
                  key: 'country',
                  label: 'Country',
                  type: OiFieldType.select,
                  config: {
                    'options': [
                      OiSelectOption<dynamic>(value: 'us', label: 'US'),
                      OiSelectOption<dynamic>(value: 'de', label: 'DE'),
                    ],
                  },
                ),
              ],
            ),
          ],
          controller: ctrl,
        ),
      );

      expect(find.byType(OiSelect<dynamic>), findsOneWidget);
    });
  });
}
