import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

// ── Enums ────────────────────────────────────────────────────────────────

enum _F { name, email, username, secret }

// ── Controllers ──────────────────────────────────────────────────────────

class _SubmitCtrl extends OiAfController<_F, Map<String, dynamic>> {
  @override
  void defineFields() {
    addTextField(_F.name, required: true);
    addTextField(_F.email, required: true);
  }

  @override
  Map<String, dynamic> buildData() => json();
}

class _VisibilityCtrl extends OiAfController<_F, Map<String, dynamic>> {
  @override
  void defineFields() {
    addTextField(_F.name);
    addTextField(
      _F.secret,
      visibleWhen: (form) => form.getOr<String>(_F.name, '') == 'admin',
      dependsOn: [_F.name],
    );
  }

  @override
  Map<String, dynamic> buildData() => json();
}

class _DerivedCtrl extends OiAfController<_F, Map<String, dynamic>> {
  @override
  void defineFields() {
    addTextField(_F.name);
    addTextField(
      _F.username,
      dependsOn: [_F.name],
      derive: (form) {
        final name = form.getOr<String>(_F.name, '');
        return name.toLowerCase().replaceAll(' ', '_');
      },
    );
  }

  @override
  Map<String, dynamic> buildData() => json();
}

enum _Cycle { a, b }

class _CycleCtrl extends OiAfController<_Cycle, Map<String, dynamic>> {
  @override
  void defineFields() {
    addTextField(
      _Cycle.a,
      dependsOn: [_Cycle.b],
      derive: (form) => form.getOr<String>(_Cycle.b, ''),
    );
    addTextField(
      _Cycle.b,
      dependsOn: [_Cycle.a],
      derive: (form) => form.getOr<String>(_Cycle.a, ''),
    );
  }

  @override
  Map<String, dynamic> buildData() => json();
}

// ── Helpers ──────────────────────────────────────────────────────────────

Widget
_pump<TCtrl extends OiAfController<TField, TData>, TField extends Enum, TData>({
  required TCtrl controller,
  required Widget child,
  Future<void> Function(TData, TCtrl)? onSubmit,
}) {
  return OiApp(
    home: OiAfForm<TField, TData>(
      controller: controller,
      onSubmit: onSubmit != null
          ? (data, ctrl) => onSubmit(data, ctrl as TCtrl)
          : null,
      child: child,
    ),
  );
}

void main() {
  group('OiAfForm integration', () {
    testWidgets('full submit flow: fill fields, submit, onSubmit called', (
      tester,
    ) async {
      final ctrl = _SubmitCtrl();
      addTearDown(ctrl.dispose);

      Map<String, dynamic>? submittedData;

      await tester.pumpWidget(
        _pump<_SubmitCtrl, _F, Map<String, dynamic>>(
          controller: ctrl,
          onSubmit: (data, c) async {
            submittedData = data;
          },
          child: const Column(
            children: [
              OiAfTextInput<_F>(field: _F.name, label: 'Name'),
              OiAfTextInput<_F>(field: _F.email, label: 'Email'),
              OiAfSubmitButton<_F, Map<String, dynamic>>(label: 'Submit'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Fill in name
      final nameInput = find.byType(EditableText).first;
      await tester.enterText(nameInput, 'Alice');
      await tester.pumpAndSettle();

      // Fill in email
      final emailInput = find.byType(EditableText).last;
      await tester.enterText(emailInput, 'alice@example.com');
      await tester.pumpAndSettle();

      // Tap submit
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(submittedData, isNotNull);
      expect(submittedData!['name'], 'Alice');
      expect(submittedData!['email'], 'alice@example.com');
    });

    testWidgets('conditional visibility: field hidden/shown based on value', (
      tester,
    ) async {
      final ctrl = _VisibilityCtrl();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        _pump<_VisibilityCtrl, _F, Map<String, dynamic>>(
          controller: ctrl,
          child: const Column(
            children: [
              OiAfTextInput<_F>(field: _F.name, label: 'Name'),
              OiAfTextInput<_F>(field: _F.secret, label: 'Secret'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Secret field should be hidden (name is empty, not 'admin')
      expect(find.text('Secret'), findsNothing);

      // Type 'admin' in name field
      await tester.enterText(find.byType(EditableText).first, 'admin');
      await tester.pumpAndSettle();

      // Secret field should now be visible
      expect(ctrl.isFieldVisible(_F.secret), isTrue);
    });

    testWidgets('derived field: username derives from name', (tester) async {
      final ctrl = _DerivedCtrl();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        _pump<_DerivedCtrl, _F, Map<String, dynamic>>(
          controller: ctrl,
          child: const Column(
            children: [
              OiAfTextInput<_F>(field: _F.name, label: 'Name'),
              OiAfTextInput<_F>(field: _F.username, label: 'Username'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Set name programmatically
      ctrl.set(_F.name, 'John Doe');
      await tester.pumpAndSettle();

      // Username should be derived
      expect(ctrl.get<String>(_F.username), 'john_doe');
    });

    testWidgets('reset clears all fields back to initial values', (
      tester,
    ) async {
      final ctrl = _SubmitCtrl();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        _pump<_SubmitCtrl, _F, Map<String, dynamic>>(
          controller: ctrl,
          child: const Column(
            children: [
              OiAfTextInput<_F>(field: _F.name, label: 'Name'),
              OiAfTextInput<_F>(field: _F.email, label: 'Email'),
              OiAfResetButton<_F>(label: 'Reset'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Modify fields
      ctrl
        ..set(_F.name, 'Changed')
        ..set(_F.email, 'changed@test.com');
      await tester.pumpAndSettle();

      expect(ctrl.isDirty, isTrue);

      // Tap reset
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // Fields should be back to initial (null/empty for text fields)
      expect(ctrl.isDirty, isFalse);
      expect(ctrl.get<String>(_F.name), isNull);
      expect(ctrl.get<String>(_F.email), isNull);
    });

    test('cycle detection: assert fires for circular dependencies', () {
      // The controller constructor calls defineFields then _buildDependencyGraph
      // which detects cycles and fires an assertion.
      expect(_CycleCtrl.new, throwsA(isA<AssertionError>()));
    });
  });
}
