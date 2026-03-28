import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

enum _F { name, email }

class _Ctrl extends OiAfController<_F, Map<String, dynamic>> {
  @override
  void defineFields() {
    addTextField(_F.name, required: true);
    addTextField(
      _F.email,
      required: true,
      validators: [OiAfValidators.email<_F>()],
    );
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
  group('OiAfErrorSummary', () {
    late _Ctrl ctrl;

    setUp(() {
      ctrl = _Ctrl();
    });

    tearDown(() {
      ctrl.dispose();
    });

    testWidgets('hideWhenEmpty=true renders nothing when no errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pump(
          controller: ctrl,
          child: const OiAfErrorSummary<_F>(),
        ),
      );
      await tester.pumpAndSettle();

      // No errors exist, so the widget should render as empty
      expect(find.byType(OiAfErrorSummary<_F>), findsOneWidget);
      expect(find.byType(OiSurface), findsNothing);
    });

    testWidgets('shows errors after validation fails', (tester) async {
      await tester.pumpWidget(
        _pump(controller: ctrl, child: const OiAfErrorSummary<_F>()),
      );
      await tester.pumpAndSettle();

      // Trigger validation to produce errors on required fields
      await ctrl.validate();
      await tester.pumpAndSettle();

      // Should show error text for required fields
      expect(find.textContaining('required'), findsWidgets);
    });

    testWidgets('showOnlyAfterSubmit=true hides errors before submit', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pump(
          controller: ctrl,
          child: const OiAfErrorSummary<_F>(showOnlyAfterSubmit: true),
        ),
      );
      await tester.pumpAndSettle();

      // Validate without submitting
      await ctrl.validate();
      await tester.pumpAndSettle();

      // Errors should be hidden since form has not been submitted
      expect(find.textContaining('required'), findsNothing);
    });

    testWidgets('focusFieldOnTap=true renders tappable items after errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pump(
          controller: ctrl,
          child: const OiAfErrorSummary<_F>(),
        ),
      );
      await tester.pumpAndSettle();

      await ctrl.validate();
      await tester.pumpAndSettle();

      // Should render the error summary with GestureDetector items
      expect(find.byType(OiAfErrorSummary<_F>), findsOneWidget);
      expect(find.byType(GestureDetector), findsWidgets);
    });
  });
}
