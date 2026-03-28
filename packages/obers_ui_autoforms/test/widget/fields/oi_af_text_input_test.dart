import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

enum _F { name, password, search }

class _Ctrl extends OiAfController<_F, Map<String, dynamic>> {
  _Ctrl({this.nameVisible = true});

  final bool nameVisible;

  @override
  void defineFields() {
    addTextField(
      _F.name,
      initialValue: 'Alice',
      required: true,
      visibleWhen: nameVisible ? null : (_) => false,
    );
    addTextField(_F.password);
    addTextField(_F.search);
  }

  @override
  Map<String, dynamic> buildData() => json();
}

Widget _pump({required _Ctrl controller, required Widget child}) {
  return OiApp(
    home: OiAfForm<_F, Map<String, dynamic>>(
      controller: controller,
      child: child,
    ),
  );
}

void main() {
  group('OiAfTextInput', () {
    late _Ctrl ctrl;

    setUp(() {
      ctrl = _Ctrl();
    });

    tearDown(() {
      ctrl.dispose();
    });

    testWidgets('binds value from controller to OiTextInput', (tester) async {
      await tester.pumpWidget(
        _pump(
          controller: ctrl,
          child: const OiAfTextInput<_F>(field: _F.name, label: 'Name'),
        ),
      );
      await tester.pumpAndSettle();

      // The initial value 'Alice' should be displayed in the text input
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('updates controller on text change', (tester) async {
      await tester.pumpWidget(
        _pump(
          controller: ctrl,
          child: const OiAfTextInput<_F>(field: _F.name, label: 'Name'),
        ),
      );
      await tester.pumpAndSettle();

      // Clear existing text and type new value
      await tester.enterText(find.byType(EditableText), 'Bob');
      await tester.pumpAndSettle();

      expect(ctrl.get<String>(_F.name), 'Bob');
    });

    testWidgets('hides when field is not visible', (tester) async {
      final hiddenCtrl = _Ctrl(nameVisible: false);
      addTearDown(hiddenCtrl.dispose);

      await tester.pumpWidget(
        _pump(
          controller: hiddenCtrl,
          child: const OiAfTextInput<_F>(field: _F.name, label: 'Name'),
        ),
      );
      await tester.pumpAndSettle();

      // Should render SizedBox.shrink when not visible
      expect(find.text('Alice'), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('shows error from field controller', (tester) async {
      await tester.pumpWidget(
        _pump(
          controller: ctrl,
          child: const OiAfTextInput<_F>(field: _F.name, label: 'Name'),
        ),
      );
      await tester.pumpAndSettle();

      // Clear the required field and validate
      ctrl.set(_F.name, '');
      await ctrl.validate(field: _F.name);
      await tester.pumpAndSettle();

      // Should show the required error
      expect(find.textContaining('required'), findsOneWidget);
    });

    testWidgets('OiAfTextInput.password creates obscured input', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pump(
          controller: ctrl,
          child: const OiAfTextInput<_F>.password(
            field: _F.password,
            label: 'Password',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the EditableText and verify it is obscured
      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editableText.obscureText, isTrue);
    });

    testWidgets('OiAfTextInput.search creates search-style input', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pump(
          controller: ctrl,
          child: const OiAfTextInput<_F>.search(field: _F.search),
        ),
      );
      await tester.pumpAndSettle();

      // The search input should render (it wraps OiTextInput.search)
      expect(find.byType(OiAfTextInput<_F>), findsOneWidget);
      expect(find.byType(EditableText), findsOneWidget);
    });
  });
}
