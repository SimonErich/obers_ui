import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_forms/obers_ui_forms.dart';

void main() {
  group('OiFormInputController', () {
    test('set value and get returns same typed value', () {
      final controller = OiFormInputController<String>();

      controller.setValue('hello');

      expect(controller.value, 'hello');
    });

    test('required=true with null value returns isValid false', () {
      final controller = OiFormInputController<String>(required: true);

      expect(controller.isValid, isFalse);
    });

    test('required=true with non-null value returns isValid true', () {
      final controller = OiFormInputController<String>(required: true);

      controller.setValue('hello');

      expect(controller.isValid, isTrue);
    });

    test('required=true with empty string returns isValid false', () {
      final controller = OiFormInputController<String>(required: true);

      controller.setValue('');

      expect(controller.isValid, isFalse);
    });

    test('isDirty is false initially', () {
      final controller = OiFormInputController<String>(initialValue: 'initial');

      expect(controller.isDirty, isFalse);
    });

    test('isDirty is true after setValue', () {
      final controller = OiFormInputController<String>(initialValue: 'initial');

      controller.setValue('changed');

      expect(controller.isDirty, isTrue);
    });

    test('reset restores initialValue and clears dirty and errors', () {
      final controller = OiFormInputController<String>(initialValue: 'initial');

      controller.setValue('changed');
      controller.addError('some error');
      expect(controller.isDirty, isTrue);
      expect(controller.errors, isNotEmpty);

      controller.reset();

      expect(controller.value, 'initial');
      expect(controller.isDirty, isFalse);
      expect(controller.errors, isEmpty);
    });

    test('getter transforms value on read', () {
      final controller = OiFormInputController<String>(
        getter: (val) => val?.toUpperCase() ?? '',
      );

      controller.setValue('hello');

      expect(controller.value, 'HELLO');
      expect(controller.rawValue, 'hello');
    });

    test('setter transforms value on write', () {
      final controller = OiFormInputController<String>(
        setter: (val) => val?.trim() ?? '',
      );

      controller.setValue('  hello  ');

      expect(controller.value, 'hello');
    });

    test('enabled defaults to true', () {
      final controller = OiFormInputController<String>();
      expect(controller.enabled, isTrue);
    });

    test('enabled=false reports disabled state', () {
      final controller = OiFormInputController<String>(enabled: false);
      expect(controller.enabled, isFalse);
    });

    test('setting enabled notifies listeners', () {
      final controller = OiFormInputController<String>();
      var notified = false;
      controller.addListener(() => notified = true);

      controller.enabled = false;

      expect(notified, isTrue);
      expect(controller.enabled, isFalse);
    });

    test('clearErrorOnChange clears errors when value changes', () {
      final controller = OiFormInputController<String>();
      controller.addError('error');
      expect(controller.errors, hasLength(1));

      controller.setValue('new value');

      expect(controller.errors, isEmpty);
    });

    test('clearErrorOnChange=false preserves errors on value change', () {
      final controller = OiFormInputController<String>(
        clearErrorOnChange: false,
      );
      controller.addError('error');

      controller.setValue('new value');

      expect(controller.errors, hasLength(1));
    });

    test('notifies listeners on setValue', () {
      final controller = OiFormInputController<String>();
      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.setValue('a');
      controller.setValue('b');

      expect(notifyCount, 2);
    });

    test('does not notify when setting same value', () {
      final controller = OiFormInputController<String>();
      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.setValue('a');
      controller.setValue('a');

      expect(notifyCount, 1);
    });

    test('save flag defaults to true', () {
      final controller = OiFormInputController<String>();
      expect(controller.save, isTrue);
    });

    test('save=false marks field as transient', () {
      final controller = OiFormInputController<String>(save: false);
      expect(controller.save, isFalse);
    });

    test('isComputed returns true when computedValue is set', () {
      final controller = OiFormInputController<String>(
        computedValue: (_) => 'computed',
      );
      expect(controller.isComputed, isTrue);
    });

    test('isComputed returns false by default', () {
      final controller = OiFormInputController<String>();
      expect(controller.isComputed, isFalse);
    });
  });

  group('OiFormInputController.validateSync', () {
    test('validates required field', () {
      final controller = OiFormInputController<String>(required: true);

      final errors = controller.validateSync(null);

      expect(errors, contains('This field is required'));
      expect(controller.isValid, isFalse);
    });

    test('required field with value passes', () {
      final controller = OiFormInputController<String>(required: true);
      controller.setValue('hello');

      final errors = controller.validateSync(null);

      expect(errors, isEmpty);
      expect(controller.isValid, isTrue);
    });

    test('runs sync validators and collects errors', () {
      final controller = OiFormInputController<String>(
        validation: [OiFormValidation.minLength(5)],
      );
      controller.setValue('hi');

      final errors = controller.validateSync(null);

      expect(errors, hasLength(1));
      expect(errors.first, contains('at least 5'));
    });

    test('multiple validators can produce multiple errors', () {
      final controller = OiFormInputController<String>(
        required: true,
        validation: [OiFormValidation.minLength(5), OiFormValidation.email()],
      );
      controller.setValue('hi');

      final errors = controller.validateSync(null);

      expect(errors.length, greaterThanOrEqualTo(2));
    });
  });
}
