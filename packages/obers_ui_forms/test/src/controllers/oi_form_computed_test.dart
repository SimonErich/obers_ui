import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_forms/obers_ui_forms.dart';

enum ComputedFields { name, username, fullName }

class ComputedFormController extends OiFormController<ComputedFields> {
  @override
  Map<ComputedFields, OiFormInputController<dynamic>> inputs() => {
    ComputedFields.name: OiFormInputController<String>(initialValue: 'John'),
    ComputedFields.username: OiFormInputController<String>(
      watch: [ComputedFields.name],
      watchMode: OiFormWatchMode.onChange,
      computedValue: (controller) {
        final name = (controller as OiFormController<ComputedFields>)
            .get<String>(ComputedFields.name);
        return name?.toLowerCase().replaceAll(' ', '_') ?? '';
      },
    ),
    ComputedFields.fullName: OiFormInputController<String>(
      save: false,
      watch: [ComputedFields.name],
      watchMode: OiFormWatchMode.onChange,
      computedValue: (controller) {
        final name = (controller as OiFormController<ComputedFields>)
            .get<String>(ComputedFields.name);
        return 'Mr. $name';
      },
    ),
  };
}

class OnInitComputedController extends OiFormController<ComputedFields> {
  @override
  Map<ComputedFields, OiFormInputController<dynamic>> inputs() => {
    ComputedFields.name: OiFormInputController<String>(initialValue: 'Alice'),
    ComputedFields.username: OiFormInputController<String>(
      watch: [ComputedFields.name],
      watchMode: OiFormWatchMode.onInit,
      computedValue: (controller) {
        final name = (controller as OiFormController<ComputedFields>)
            .get<String>(ComputedFields.name);
        return name?.toLowerCase() ?? '';
      },
    ),
    ComputedFields.fullName: OiFormInputController<String>(),
  };
}

void main() {
  group('Computed fields', () {
    test('computed field updates when watched field changes', () {
      final controller = ComputedFormController();

      controller.set<String>(ComputedFields.name, 'Jane Doe');

      expect(controller.get<String>(ComputedFields.username), 'jane_doe');

      controller.dispose();
    });

    test('watchMode.onInit computes value at registration', () {
      final controller = OnInitComputedController();

      expect(controller.get<String>(ComputedFields.username), 'alice');

      controller.dispose();
    });

    test('circular watch dependency throws at registration', () {
      expect(
        () => _CircularController(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Circular watch dependency'),
          ),
        ),
      );
    });

    test('computed field with save:false excluded from getData', () {
      final controller = ComputedFormController();

      controller.set<String>(ComputedFields.name, 'Test');

      final data = controller.getData();

      expect(data.containsKey(ComputedFields.fullName), isFalse);
      expect(data.containsKey(ComputedFields.name), isTrue);
      expect(data.containsKey(ComputedFields.username), isTrue);

      controller.dispose();
    });

    test('computed field recalculates on each watched field change', () {
      final controller = ComputedFormController();

      controller.set<String>(ComputedFields.name, 'First');
      expect(controller.get<String>(ComputedFields.username), 'first');

      controller.set<String>(ComputedFields.name, 'Second Name');
      expect(controller.get<String>(ComputedFields.username), 'second_name');

      controller.dispose();
    });
  });
}

enum _CircularFields { a, b }

class _CircularController extends OiFormController<_CircularFields> {
  @override
  Map<_CircularFields, OiFormInputController<dynamic>> inputs() => {
    _CircularFields.a: OiFormInputController<String>(
      watch: [_CircularFields.b],
      computedValue: (_) => 'a',
    ),
    _CircularFields.b: OiFormInputController<String>(
      watch: [_CircularFields.a],
      computedValue: (_) => 'b',
    ),
  };
}
