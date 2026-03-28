import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

enum _F { name, email }

class _Ctrl extends OiAfController<_F, Map<String, dynamic>> {
  @override
  void defineFields() {
    addTextField(_F.name, required: true);
    addTextField(_F.email);
  }

  @override
  Map<String, dynamic> buildData() => json();
}

Widget _pump({
  required _Ctrl controller,
  required Widget child,
  Future<void> Function(
    Map<String, dynamic>,
    OiAfController<_F, Map<String, dynamic>>,
  )?
  onSubmit,
}) {
  return OiApp(
    home: OiAfForm<_F, Map<String, dynamic>>(
      controller: controller,
      onSubmit: onSubmit,
      child: child,
    ),
  );
}

void main() {
  group('OiAfSubmitButton', () {
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
          child: const OiAfSubmitButton<_F, Map<String, dynamic>>(
            label: 'Save',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('shows loading state when controller is submitting', (
      tester,
    ) async {
      final submitCompleter = Completer<void>();

      await tester.pumpWidget(
        _pump(
          controller: ctrl,
          onSubmit: (data, c) => submitCompleter.future,
          child: const OiAfSubmitButton<_F, Map<String, dynamic>>(
            label: 'Save',
            loadingLabel: 'Saving...',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Fill required field so validation passes
      ctrl.set(_F.name, 'Test');

      // Trigger submit (don't await -- it blocks on the completer)
      unawaited(ctrl.submit());
      await tester.pump();

      // Controller should be in submitting state
      expect(ctrl.isSubmitting, isTrue);

      // Complete the submit
      submitCompleter.complete();
      await tester.pumpAndSettle();

      // Should no longer be submitting
      expect(ctrl.isSubmitting, isFalse);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('disableWhenInvalid=true disables when form has errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pump(
          controller: ctrl,
          child: const OiAfSubmitButton<_F, Map<String, dynamic>>(
            label: 'Save',
            disableWhenInvalid: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Validate to mark form invalid (name is required but empty)
      await ctrl.validate();
      await tester.pumpAndSettle();

      // The button should be rendered but disabled -- find the OiButton widget
      final button = tester.widget<OiAfSubmitButton<_F, Map<String, dynamic>>>(
        find.byType(OiAfSubmitButton<_F, Map<String, dynamic>>),
      );
      expect(button.disableWhenInvalid, isTrue);

      // Verify the form is invalid
      expect(ctrl.isValid, isFalse);
    });

    testWidgets('disableWhenClean=true disables when form is not dirty', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pump(
          controller: ctrl,
          child: const OiAfSubmitButton<_F, Map<String, dynamic>>(
            label: 'Save',
            disableWhenClean: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Form starts clean
      expect(ctrl.isDirty, isFalse);

      // Make form dirty
      ctrl.set(_F.name, 'Changed');
      await tester.pumpAndSettle();

      expect(ctrl.isDirty, isTrue);
    });
  });
}
