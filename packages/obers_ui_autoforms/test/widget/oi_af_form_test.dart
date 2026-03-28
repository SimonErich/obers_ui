import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

// ── Test Enum ────────────────────────────────────────────────────────────────

enum TestField { name, email, password, age, agree }

// ── Test Controller ──────────────────────────────────────────────────────────

class SimpleFormController
    extends OiAfController<TestField, Map<String, dynamic>> {
  @override
  void defineFields() {
    addTextField(TestField.name, initialValue: '');
  }

  @override
  Map<String, dynamic> buildData() => json();
}

class MultiFieldController
    extends OiAfController<TestField, Map<String, dynamic>> {
  @override
  void defineFields() {
    addTextField(TestField.name, initialValue: '');
    addTextField(TestField.email, initialValue: '');
    addBoolField(TestField.agree, initialValue: false);
  }

  @override
  Map<String, dynamic> buildData() => json();
}

// ── Helpers ──────────────────────────────────────────────────────────────────

Widget _pumpAutoForm(Widget child) {
  return OiApp(home: child);
}

void main() {
  // ═════════════════════════════════════════════════════════════════════════
  //  SCOPE — OiAfForm provides controller via inherited widget
  // ═════════════════════════════════════════════════════════════════════════

  group('OiAfForm provides scope', () {
    testWidgets('controller is accessible via OiAfScope.of', (tester) async {
      final controller = SimpleFormController();

      await tester.pumpWidget(
        _pumpAutoForm(
          OiAfForm<TestField, Map<String, dynamic>>(
            controller: controller,
            child: Builder(
              builder: (context) {
                final scope = OiAfScope.of<TestField, Object?>(context);
                expect(scope, same(controller));
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('OiAfScope.maybeOf returns null when no scope', (tester) async {
      await tester.pumpWidget(
        _pumpAutoForm(
          Builder(
            builder: (context) {
              final scope = OiAfScope.maybeOf<TestField, Map<String, dynamic>>(
                context,
              );
              expect(scope, isNull);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('controller is attached when form mounts', (tester) async {
      final controller = SimpleFormController();
      expect(controller.isAttached, isFalse);

      await tester.pumpWidget(
        _pumpAutoForm(
          OiAfForm<TestField, Map<String, dynamic>>(
            controller: controller,
            child: const SizedBox.shrink(),
          ),
        ),
      );

      expect(controller.isAttached, isTrue);
    });

    testWidgets('controller is detached when form unmounts', (tester) async {
      final controller = SimpleFormController();

      await tester.pumpWidget(
        _pumpAutoForm(
          OiAfForm<TestField, Map<String, dynamic>>(
            controller: controller,
            child: const SizedBox.shrink(),
          ),
        ),
      );
      expect(controller.isAttached, isTrue);

      await tester.pumpWidget(_pumpAutoForm(const SizedBox.shrink()));
      expect(controller.isAttached, isFalse);
    });

    testWidgets('attach passes enabled to controller', (tester) async {
      final controller = SimpleFormController();

      await tester.pumpWidget(
        _pumpAutoForm(
          OiAfForm<TestField, Map<String, dynamic>>(
            controller: controller,
            enabled: false,
            child: const SizedBox.shrink(),
          ),
        ),
      );

      expect(controller.isEnabled, isFalse);
      expect(controller.isAttached, isTrue);
    });

    testWidgets('changing controller detaches old and attaches new', (
      tester,
    ) async {
      final controller1 = SimpleFormController();
      final controller2 = SimpleFormController();

      await tester.pumpWidget(
        _pumpAutoForm(
          OiAfForm<TestField, Map<String, dynamic>>(
            controller: controller1,
            child: const SizedBox.shrink(),
          ),
        ),
      );
      expect(controller1.isAttached, isTrue);

      await tester.pumpWidget(
        _pumpAutoForm(
          OiAfForm<TestField, Map<String, dynamic>>(
            controller: controller2,
            child: const SizedBox.shrink(),
          ),
        ),
      );
      expect(controller1.isAttached, isFalse);
      expect(controller2.isAttached, isTrue);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  SUBMIT BUTTON — renders (uses OiAfScope<TField, TData> directly)
  // ═════════════════════════════════════════════════════════════════════════

  group('OiAfSubmitButton', () {
    testWidgets('renders with label', (tester) async {
      final controller = SimpleFormController();

      await tester.pumpWidget(
        _pumpAutoForm(
          OiAfForm<TestField, Map<String, dynamic>>(
            controller: controller,
            child: const OiAfSubmitButton<TestField, Map<String, dynamic>>(
              label: 'Save',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('disabled when form is disabled', (tester) async {
      final controller = SimpleFormController();

      await tester.pumpWidget(
        _pumpAutoForm(
          OiAfForm<TestField, Map<String, dynamic>>(
            controller: controller,
            enabled: false,
            child: const OiAfSubmitButton<TestField, Map<String, dynamic>>(
              label: 'Save',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Save'), findsOneWidget);
      expect(controller.isEnabled, isFalse);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  CONTROLLER STATE THROUGH FORM
  // ═════════════════════════════════════════════════════════════════════════

  group('controller state through OiAfForm', () {
    testWidgets('set/get values through controller', (tester) async {
      final controller = SimpleFormController();

      await tester.pumpWidget(
        _pumpAutoForm(
          OiAfForm<TestField, Map<String, dynamic>>(
            controller: controller,
            child: const SizedBox.shrink(),
          ),
        ),
      );

      controller.set<String>(TestField.name, 'Test');
      expect(controller.get<String>(TestField.name), 'Test');
      expect(controller.isDirty, isTrue);

      controller.reset();
      expect(controller.get<String>(TestField.name), '');
      expect(controller.isDirty, isFalse);
    });

    testWidgets('error management through controller', (tester) async {
      final controller = SimpleFormController();

      await tester.pumpWidget(
        _pumpAutoForm(
          OiAfForm<TestField, Map<String, dynamic>>(
            controller: controller,
            child: const SizedBox.shrink(),
          ),
        ),
      );

      controller.setGlobalError('Something went wrong');
      expect(controller.globalErrors, contains('Something went wrong'));
      expect(controller.isValid, isFalse);

      controller.clearErrors();
      expect(controller.globalErrors, isEmpty);
      expect(controller.isValid, isTrue);
    });

    testWidgets('disable/enable through controller', (tester) async {
      final controller = SimpleFormController();

      await tester.pumpWidget(
        _pumpAutoForm(
          OiAfForm<TestField, Map<String, dynamic>>(
            controller: controller,
            child: const SizedBox.shrink(),
          ),
        ),
      );

      controller.disable();
      expect(controller.isEnabled, isFalse);

      controller.enable();
      expect(controller.isEnabled, isTrue);
    });

    testWidgets('patch updates multiple values', (tester) async {
      final controller = MultiFieldController();

      await tester.pumpWidget(
        _pumpAutoForm(
          OiAfForm<TestField, Map<String, dynamic>>(
            controller: controller,
            child: const SizedBox.shrink(),
          ),
        ),
      );

      controller.patch({
        TestField.name: 'John',
        TestField.email: 'john@test.com',
      });

      expect(controller.get<String>(TestField.name), 'John');
      expect(controller.get<String>(TestField.email), 'john@test.com');
      expect(controller.isDirty, isTrue);
    });

    testWidgets('reset clears all state', (tester) async {
      final controller = SimpleFormController();

      await tester.pumpWidget(
        _pumpAutoForm(
          OiAfForm<TestField, Map<String, dynamic>>(
            controller: controller,
            child: const SizedBox.shrink(),
          ),
        ),
      );

      controller
        ..set<String>(TestField.name, 'dirty')
        ..setGlobalError('error');
      expect(controller.isDirty, isTrue);

      controller.reset();
      expect(controller.isDirty, isFalse);
      expect(controller.get<String>(TestField.name), '');
      expect(controller.globalErrors, isEmpty);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  FORM ENABLED STATE
  // ═════════════════════════════════════════════════════════════════════════

  group('form enabled state', () {
    testWidgets('enabled: false propagates to controller', (tester) async {
      final controller = SimpleFormController();

      await tester.pumpWidget(
        _pumpAutoForm(
          OiAfForm<TestField, Map<String, dynamic>>(
            controller: controller,
            enabled: false,
            child: const SizedBox.shrink(),
          ),
        ),
      );

      expect(controller.isEnabled, isFalse);
    });

    testWidgets('enabled: true (default) keeps controller enabled', (
      tester,
    ) async {
      final controller = SimpleFormController();

      await tester.pumpWidget(
        _pumpAutoForm(
          OiAfForm<TestField, Map<String, dynamic>>(
            controller: controller,
            child: const SizedBox.shrink(),
          ),
        ),
      );

      expect(controller.isEnabled, isTrue);
    });
  });
}
