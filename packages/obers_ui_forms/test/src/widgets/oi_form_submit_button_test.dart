import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart' hide OiFormController;
import 'package:obers_ui_forms/obers_ui_forms.dart';

import '../../helpers/pump_app.dart';

enum TestFields { name }

class TestController extends OiFormController<TestFields> {
  @override
  Map<TestFields, OiFormInputController<dynamic>> inputs() => {
    TestFields.name: OiFormInputController<String>(required: true),
  };
}

void main() {
  group('OiFormSubmitButton', () {
    testWidgets('disabled when form is invalid', (tester) async {
      final controller = TestController();
      // name is required but empty → invalid

      await tester.pumpObers(
        OiFormScope<TestFields>(
          controller: controller,
          child: OiFormSubmitButton<TestFields>(label: 'Submit'),
        ),
      );

      // Find the OiButton and check it's disabled
      final button = tester.widget<OiButton>(find.byType(OiButton));
      expect(button.enabled, isFalse);

      controller.dispose();
    });

    testWidgets('enabled when form is valid', (tester) async {
      final controller = TestController();
      controller.set<String>(TestFields.name, 'Valid Name');

      await tester.pumpObers(
        OiFormScope<TestFields>(
          controller: controller,
          child: OiFormSubmitButton<TestFields>(label: 'Submit'),
        ),
      );

      final button = tester.widget<OiButton>(find.byType(OiButton));
      expect(button.enabled, isTrue);

      controller.dispose();
    });

    testWidgets('shows correct label', (tester) async {
      final controller = TestController();

      await tester.pumpObers(
        OiFormScope<TestFields>(
          controller: controller,
          child: OiFormSubmitButton<TestFields>(label: 'Sign Up'),
        ),
      );

      expect(find.text('Sign Up'), findsOneWidget);

      controller.dispose();
    });
  });
}
