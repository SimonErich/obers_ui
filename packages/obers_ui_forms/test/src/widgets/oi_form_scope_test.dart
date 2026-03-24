import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_forms/obers_ui_forms.dart';

import '../../helpers/pump_app.dart';

enum TestFields { name }

class TestController extends OiFormController<TestFields> {
  @override
  Map<TestFields, OiFormInputController<dynamic>> inputs() => {
    TestFields.name: OiFormInputController<String>(initialValue: 'Hello'),
  };
}

void main() {
  group('OiFormScope', () {
    testWidgets('provides controller to descendant via context', (
      tester,
    ) async {
      final controller = TestController();
      String? capturedValue;

      await tester.pumpObers(
        OiFormScope<TestFields>(
          controller: controller,
          child: Builder(
            builder: (context) {
              final ctrl = OiFormScope.of<TestFields>(context);
              capturedValue = ctrl.get<String>(TestFields.name);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedValue, 'Hello');

      controller.dispose();
    });

    testWidgets('maybeOf returns null when no scope in tree', (tester) async {
      OiFormController<TestFields>? capturedController;

      await tester.pumpObers(
        Builder(
          builder: (context) {
            capturedController = OiFormScope.maybeOf<TestFields>(context);
            return const SizedBox();
          },
        ),
      );

      expect(capturedController, isNull);
    });

    testWidgets('context extension provides controller', (tester) async {
      final controller = TestController();
      String? capturedValue;

      await tester.pumpObers(
        OiFormScope<TestFields>(
          controller: controller,
          child: Builder(
            builder: (context) {
              final ctrl = context.formController<TestFields>();
              capturedValue = ctrl.get<String>(TestFields.name);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedValue, 'Hello');

      controller.dispose();
    });

    testWidgets('rebuilds descendants when controller notifies', (
      tester,
    ) async {
      final controller = TestController();
      var buildCount = 0;

      await tester.pumpObers(
        OiFormScope<TestFields>(
          controller: controller,
          child: Builder(
            builder: (context) {
              OiFormScope.of<TestFields>(context);
              buildCount++;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, 1);

      controller.set<String>(TestFields.name, 'World');
      await tester.pump();

      expect(buildCount, 2);

      controller.dispose();
    });
  });
}
