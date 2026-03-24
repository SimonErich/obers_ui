import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_forms/obers_ui_forms.dart';

enum TestFields { name, email, password, passwordRepeat, newsletter }

class TestFormController extends OiFormController<TestFields> {
  @override
  Map<TestFields, OiFormInputController<dynamic>> inputs() => {
    TestFields.name: OiFormInputController<String>(
      required: true,
      initialValue: 'initial',
    ),
    TestFields.email: OiFormInputController<String>(
      validation: [OiFormValidation.email()],
    ),
    TestFields.password: OiFormInputController<String>(
      required: true,
      validation: [OiFormValidation.minLength(8)],
    ),
    TestFields.passwordRepeat: OiFormInputController<String>(
      save: false,
      validation: [OiFormValidation.equals<String>(TestFields.password)],
    ),
    TestFields.newsletter: OiFormInputController<bool>(initialValue: false),
  };
}

void main() {
  group('OiFormController', () {
    test('get/set typed values round-trip', () {
      final controller = TestFormController();

      controller.set<String>(TestFields.name, 'John');

      expect(controller.get<String>(TestFields.name), 'John');

      controller.dispose();
    });

    test('required field empty → isValid false; filled → isValid true', () {
      final controller = TestFormController();

      // name is required but has initial value, password is required and empty
      expect(controller.isValid, isFalse);

      controller.set<String>(TestFields.password, 'longpassword');

      expect(controller.isValid, isTrue);

      controller.dispose();
    });

    test('isDirty false initially; true after set', () {
      final controller = TestFormController();

      expect(controller.isDirty, isFalse);

      controller.set<String>(TestFields.email, 'test@example.com');

      expect(controller.isDirty, isTrue);

      controller.dispose();
    });

    test('reset restores all fields to initial, clears dirty+errors', () {
      final controller = TestFormController();

      controller.set<String>(TestFields.name, 'Changed');
      controller.setError(TestFields.name, 'error');
      expect(controller.isDirty, isTrue);
      expect(controller.getError(TestFields.name), isNotEmpty);

      controller.reset();

      expect(controller.get<String>(TestFields.name), 'initial');
      expect(controller.isDirty, isFalse);
      expect(controller.getError(TestFields.name), isEmpty);

      controller.dispose();
    });

    test('getData excludes fields with save:false', () {
      final controller = TestFormController();

      controller.set<String>(TestFields.passwordRepeat, 'secret');

      final data = controller.getData();

      expect(data.containsKey(TestFields.passwordRepeat), isFalse);
      expect(data.containsKey(TestFields.name), isTrue);

      controller.dispose();
    });

    test('json returns Map<String, dynamic> keyed by enum name', () {
      final controller = TestFormController();

      controller.set<String>(TestFields.name, 'John');

      final jsonData = controller.json();

      expect(jsonData['name'], 'John');
      expect(jsonData.containsKey('passwordRepeat'), isFalse);

      controller.dispose();
    });

    test('validate runs all field validators, collects errors', () {
      final controller = TestFormController();

      controller.set<String>(TestFields.name, 'John');
      controller.set<String>(TestFields.email, 'invalid');
      controller.set<String>(TestFields.password, 'short');

      final valid = controller.validate();

      expect(valid, isFalse);
      expect(controller.getErrors(), isNotEmpty);
      expect(controller.getError(TestFields.email), isNotEmpty);
      expect(controller.getError(TestFields.password), isNotEmpty);

      controller.dispose();
    });

    test('setError injects error; getError retrieves it', () {
      final controller = TestFormController();

      controller.setError(TestFields.name, 'Server error');

      expect(controller.getError(TestFields.name), contains('Server error'));

      controller.dispose();
    });

    test('equals validator compares against other field value', () {
      final controller = TestFormController();

      controller.set<String>(TestFields.password, 'mypassword');
      controller.set<String>(TestFields.passwordRepeat, 'different');

      controller.validate();

      expect(controller.getError(TestFields.passwordRepeat), isNotEmpty);

      controller.set<String>(TestFields.passwordRepeat, 'mypassword');
      controller.validate();

      expect(controller.getError(TestFields.passwordRepeat), isEmpty);

      controller.dispose();
    });

    test('enable/disable form sets all fields state', () {
      final controller = TestFormController();

      controller.disable();

      expect(controller.enabled, isFalse);
      expect(controller.getInputController(TestFields.name).enabled, isFalse);

      controller.enable();

      expect(controller.enabled, isTrue);
      expect(controller.getInputController(TestFields.name).enabled, isTrue);

      controller.dispose();
    });

    test('enableField/disableField per-field', () {
      final controller = TestFormController();

      controller.disableField(TestFields.email);

      expect(controller.getInputController(TestFields.email).enabled, isFalse);
      expect(controller.getInputController(TestFields.name).enabled, isTrue);

      controller.enableField(TestFields.email);

      expect(controller.getInputController(TestFields.email).enabled, isTrue);

      controller.dispose();
    });

    test('overwriteInputController replaces field controller', () {
      final controller = TestFormController();

      final newInput = OiFormInputController<String>(
        required: true,
        initialValue: 'overwritten',
      );
      controller.overwriteInputController(TestFields.name, newInput);

      expect(controller.get<String>(TestFields.name), 'overwritten');

      controller.dispose();
    });

    test('getInputController returns current field controller', () {
      final controller = TestFormController();

      final input = controller.getInputController(TestFields.name);

      expect(input, isA<OiFormInputController<dynamic>>());
      expect(input.value, 'initial');

      controller.dispose();
    });

    test('setMultiple updates multiple fields', () {
      final controller = TestFormController();
      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.setMultiple({
        TestFields.name: 'John',
        TestFields.email: 'john@example.com',
      });

      expect(controller.get<String>(TestFields.name), 'John');
      expect(controller.get<String>(TestFields.email), 'john@example.com');
      // Should batch into a single notification
      expect(notifyCount, 1);

      controller.dispose();
    });

    test('getInitial returns initial values map', () {
      final controller = TestFormController();

      final initial = controller.getInitial();

      expect(initial[TestFields.name], 'initial');
      expect(initial[TestFields.newsletter], false);
      expect(initial[TestFields.email], isNull);

      controller.dispose();
    });

    test('isFieldValid checks specific field', () {
      final controller = TestFormController();

      // name has initial value, so valid
      expect(controller.isFieldValid(TestFields.name), isTrue);
      // password is required and empty
      expect(controller.isFieldValid(TestFields.password), isFalse);

      controller.dispose();
    });

    test('isFieldDirty checks specific field', () {
      final controller = TestFormController();

      expect(controller.isFieldDirty(TestFields.name), isFalse);

      controller.set<String>(TestFields.name, 'Changed');

      expect(controller.isFieldDirty(TestFields.name), isTrue);

      controller.dispose();
    });

    test('field change notifies form controller listeners', () {
      final controller = TestFormController();
      var notified = false;
      controller.addListener(() => notified = true);

      controller.set<String>(TestFields.name, 'Changed');

      expect(notified, isTrue);

      controller.dispose();
    });

    test('dispose cleans up field listeners', () {
      final controller = TestFormController();

      // Should not throw
      controller.dispose();
    });
  });
}
