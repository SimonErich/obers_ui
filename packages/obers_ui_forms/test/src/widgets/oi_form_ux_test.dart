import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_forms/obers_ui_forms.dart';

import '../../helpers/pump_app.dart';

enum UxFields { name, email }

class UxController extends OiFormController<UxFields> {
  @override
  Map<UxFields, OiFormInputController<dynamic>> inputs() => {
    UxFields.name: OiFormInputController<String>(required: true),
    UxFields.email: OiFormInputController<String>(),
  };
}

void main() {
  group('UX: disabled form', () {
    testWidgets('disabled form wraps content in Opacity', (tester) async {
      final controller = UxController();
      controller.disable();

      await tester.pumpObers(
        OiFormScope<UxFields>(
          controller: controller,
          child: Column(
            children: [
              OiFormElement<UxFields>(
                fieldKey: UxFields.name,
                label: 'Name',
                child: const SizedBox(key: Key('name-input')),
              ),
            ],
          ),
        ),
      );

      // When disabled, an Opacity widget with 0.6 should wrap the content
      final opacityFinder = find.byWidgetPredicate(
        (w) => w is Opacity && w.opacity == 0.6,
      );
      expect(opacityFinder, findsOneWidget);

      controller.dispose();
    });

    testWidgets('enabled form has no reduced Opacity', (tester) async {
      final controller = UxController();
      controller.set<String>(UxFields.name, 'Valid');

      await tester.pumpObers(
        OiFormScope<UxFields>(
          controller: controller,
          child: Column(
            children: [
              OiFormElement<UxFields>(
                fieldKey: UxFields.name,
                label: 'Name',
                child: const SizedBox(key: Key('name-input')),
              ),
            ],
          ),
        ),
      );

      final opacityFinder = find.byWidgetPredicate(
        (w) => w is Opacity && w.opacity == 0.6,
      );
      expect(opacityFinder, findsNothing);

      controller.dispose();
    });
  });

  group('UX: required field indicator', () {
    testWidgets('required fields show asterisk in label', (tester) async {
      final controller = UxController();

      await tester.pumpObers(
        OiFormScope<UxFields>(
          controller: controller,
          child: OiFormElement<UxFields>(
            fieldKey: UxFields.name,
            label: 'Name',
            child: const SizedBox(),
          ),
        ),
      );

      // OiLabel renders text, check for "Name *" in the rendered text
      expect(find.textContaining('Name *'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('non-required fields show no asterisk', (tester) async {
      final controller = UxController();

      await tester.pumpObers(
        OiFormScope<UxFields>(
          controller: controller,
          child: OiFormElement<UxFields>(
            fieldKey: UxFields.email,
            label: 'Email',
            child: const SizedBox(),
          ),
        ),
      );

      // Should find "Email" but not "Email *"
      expect(find.textContaining('Email'), findsOneWidget);
      expect(find.textContaining('Email *'), findsNothing);

      controller.dispose();
    });
  });

  group('UX: error semantics', () {
    testWidgets('error messages have liveRegion semantics', (tester) async {
      final controller = UxController();
      controller.setError(UxFields.name, 'Required');

      await tester.pumpObers(
        OiFormScope<UxFields>(
          controller: controller,
          child: OiFormElement<UxFields>(
            fieldKey: UxFields.name,
            label: 'Name',
            child: const SizedBox(),
          ),
        ),
      );

      // Find Semantics with liveRegion=true
      final semanticsFinder = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.liveRegion == true,
      );
      expect(semanticsFinder, findsAtLeastNWidgets(1));

      controller.dispose();
    });
  });

  group('UX: firstInvalidField', () {
    test('returns first invalid field key after validate', () {
      final controller = UxController();

      controller.validate();

      expect(controller.firstInvalidField, UxFields.name);

      controller.dispose();
    });

    test('returns null when all fields are valid', () {
      final controller = UxController();
      controller.set<String>(UxFields.name, 'Valid');

      controller.validate();

      expect(controller.firstInvalidField, isNull);

      controller.dispose();
    });
  });
}
