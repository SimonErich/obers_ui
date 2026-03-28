import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

enum _F { name }

class _Ctrl extends OiAfController<_F, Map<String, dynamic>> {
  @override
  void defineFields() {
    addTextField(_F.name);
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
  group('OiAfResetButton', () {
    late _Ctrl ctrl;

    setUp(() {
      ctrl = _Ctrl();
    });

    tearDown(() {
      ctrl.dispose();
    });

    testWidgets('renders with label text', (tester) async {
      await tester.pumpWidget(
        _pump(
          controller: ctrl,
          child: const OiAfResetButton<_F>(label: 'Reset'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('hideWhenClean=true hides when form is not dirty', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pump(
          controller: ctrl,
          child: const OiAfResetButton<_F>(label: 'Reset', hideWhenClean: true),
        ),
      );
      await tester.pumpAndSettle();

      // Form starts clean, button should be hidden
      expect(find.text('Reset'), findsNothing);

      // Make form dirty
      ctrl.set(_F.name, 'Changed');
      await tester.pumpAndSettle();

      // Now the button should appear
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('tapping resets the form', (tester) async {
      await tester.pumpWidget(
        _pump(
          controller: ctrl,
          child: const OiAfResetButton<_F>(label: 'Reset'),
        ),
      );
      await tester.pumpAndSettle();

      // Dirty the form
      ctrl.set(_F.name, 'Changed');
      await tester.pumpAndSettle();
      expect(ctrl.isDirty, isTrue);

      // Tap the reset button
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // Controller should no longer be dirty
      expect(ctrl.isDirty, isFalse);
    });
  });
}
