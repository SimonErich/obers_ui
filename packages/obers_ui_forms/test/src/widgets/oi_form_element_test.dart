import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_forms/obers_ui_forms.dart';

import '../../helpers/pump_app.dart';

enum TestFields { name, email }

class TestController extends OiFormController<TestFields> {
  @override
  Map<TestFields, OiFormInputController<dynamic>> inputs() => {
    TestFields.name: OiFormInputController<String>(
      required: true,
      initialValue: 'John',
    ),
    TestFields.email: OiFormInputController<String>(),
  };
}

void main() {
  group('OiFormElement', () {
    testWidgets('renders label and child', (tester) async {
      final controller = TestController();

      await tester.pumpObers(
        OiFormScope<TestFields>(
          controller: controller,
          child: OiFormElement<TestFields>(
            fieldKey: TestFields.name,
            label: 'Full Name',
            child: const SizedBox(key: Key('input')),
          ),
        ),
      );

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.byKey(const Key('input')), findsOneWidget);

      controller.dispose();
    });

    testWidgets('displays error message when field has validation error', (
      tester,
    ) async {
      final controller = TestController();
      controller.setError(TestFields.name, 'Name is too short');

      await tester.pumpObers(
        OiFormScope<TestFields>(
          controller: controller,
          child: OiFormElement<TestFields>(
            fieldKey: TestFields.name,
            label: 'Name',
            child: const SizedBox(),
          ),
        ),
      );

      expect(find.text('Name is too short'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('hideIf hides field when condition returns true', (
      tester,
    ) async {
      final controller = TestController();

      await tester.pumpObers(
        OiFormScope<TestFields>(
          controller: controller,
          child: OiFormElement<TestFields>(
            fieldKey: TestFields.name,
            label: 'Name',
            hideIf: (_) => true,
            child: const SizedBox(key: Key('input')),
          ),
        ),
      );

      expect(find.text('Name'), findsNothing);
      expect(find.byKey(const Key('input')), findsNothing);

      controller.dispose();
    });

    testWidgets('showIf takes precedence over hideIf', (tester) async {
      final controller = TestController();

      await tester.pumpObers(
        OiFormScope<TestFields>(
          controller: controller,
          child: OiFormElement<TestFields>(
            fieldKey: TestFields.name,
            label: 'Name',
            hideIf: (_) => true,
            showIf: (_) => true,
            child: const SizedBox(key: Key('input')),
          ),
        ),
      );

      // showIf=true wins over hideIf=true
      expect(find.text('Name'), findsOneWidget);
      expect(find.byKey(const Key('input')), findsOneWidget);

      controller.dispose();
    });

    testWidgets('renders standalone without OiFormScope (no crash)', (
      tester,
    ) async {
      await tester.pumpObers(
        OiFormElement<TestFields>(
          fieldKey: TestFields.name,
          label: 'Name',
          child: const SizedBox(key: Key('input')),
        ),
      );

      expect(find.text('Name'), findsOneWidget);
      expect(find.byKey(const Key('input')), findsOneWidget);
    });

    testWidgets('errors clear when field value changes', (tester) async {
      final controller = TestController();
      controller.setError(TestFields.name, 'Error!');

      await tester.pumpObers(
        OiFormScope<TestFields>(
          controller: controller,
          child: OiFormElement<TestFields>(
            fieldKey: TestFields.name,
            label: 'Name',
            child: const SizedBox(),
          ),
        ),
      );

      expect(find.text('Error!'), findsOneWidget);

      // Changing value clears errors (clearErrorOnChange default)
      controller.set<String>(TestFields.name, 'New value');
      await tester.pump();

      expect(find.text('Error!'), findsNothing);

      controller.dispose();
    });
  });
}
