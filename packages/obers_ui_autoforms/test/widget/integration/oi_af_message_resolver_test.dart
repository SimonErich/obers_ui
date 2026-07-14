import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

enum _F { email, password }

final class _LocalizedResolver extends OiAfMessageResolver {
  const _LocalizedResolver();

  @override
  String requiredText(BuildContext context) => 'LOCALIZED_REQUIRED';

  @override
  String invalidEmail(BuildContext context) => 'LOCALIZED_EMAIL';

  @override
  String validationFailed(BuildContext context) =>
      'LOCALIZED_VALIDATION_FAILED';

  @override
  String submitFailed(BuildContext context) => 'LOCALIZED_SUBMIT_FAILED';
}

class _SignInCtrl extends OiAfController<_F, Map<String, dynamic>> {
  @override
  void defineFields() {
    addTextField(
      _F.email,
      required: true,
      validators: [OiAfValidators.email()],
    );
    addTextField(_F.password, required: true);
  }

  @override
  Map<String, dynamic> buildData() => json();
}

Widget _pump({
  required OiAfController<_F, Map<String, dynamic>> controller,
  OiAfMessageResolver messageResolver = const OiAfDefaultMessageResolver(),
  Future<void> Function(Map<String, dynamic>, OiAfController<_F, dynamic>)?
  onSubmit,
}) {
  return OiApp(
    home: OiAfForm<_F, Map<String, dynamic>>(
      controller: controller,
      messageResolver: messageResolver,
      onSubmit: onSubmit,
      child: const Column(
        children: [
          OiAfTextInput<_F>(field: _F.email, label: 'Email'),
          OiAfTextInput<_F>.password(field: _F.password, label: 'Password'),
          OiAfSubmitButton<_F, Map<String, dynamic>>(label: 'Sign in'),
        ],
      ),
    ),
  );
}

void main() {
  group('OiAfMessageResolver wiring', () {
    testWidgets('required: true uses custom resolver on failed submit', (
      tester,
    ) async {
      final ctrl = _SignInCtrl();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        _pump(controller: ctrl, messageResolver: const _LocalizedResolver()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('LOCALIZED_REQUIRED'), findsWidgets);
      expect(find.text('This field is required.'), findsNothing);
    });

    testWidgets('invalid email uses custom resolver', (tester) async {
      final ctrl = _SignInCtrl();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        _pump(controller: ctrl, messageResolver: const _LocalizedResolver()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText).first, 'not-an-email');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('LOCALIZED_EMAIL'), findsOneWidget);
      expect(find.text('Please enter a valid email address.'), findsNothing);
    });

    testWidgets('default resolver keeps English required message', (
      tester,
    ) async {
      final ctrl = _SignInCtrl();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(_pump(controller: ctrl));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('This field is required.'), findsWidgets);
    });

    testWidgets('OiAfScope.messageResolverOf returns form resolver', (
      tester,
    ) async {
      final ctrl = _SignInCtrl();
      addTearDown(ctrl.dispose);
      OiAfMessageResolver? resolved;

      await tester.pumpWidget(
        OiApp(
          home: OiAfForm<_F, Map<String, dynamic>>(
            controller: ctrl,
            messageResolver: const _LocalizedResolver(),
            child: Builder(
              builder: (context) {
                resolved = OiAfScope.messageResolverOf(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(resolved, isA<_LocalizedResolver>());
    });

    testWidgets('detached controller falls back to English required message', (
      tester,
    ) async {
      final ctrl = _SignInCtrl();
      addTearDown(ctrl.dispose);

      await ctrl.validate();
      final fc = ctrl.fieldController(_F.email);

      expect(fc.primaryError, 'This field is required.');
    });
  });
}
