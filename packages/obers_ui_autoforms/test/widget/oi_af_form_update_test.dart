import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

import '../helpers/pump_helpers.dart';

enum _F { name, amount }

class _Ctrl extends OiAfController<_F, Map<String, dynamic>> {
  @override
  void defineFields() {
    addTextField(_F.name, initialValue: 'Ada');
    addSliderField(_F.amount, initialValue: 10);
  }

  @override
  Map<String, dynamic> buildData() => json();
}

class _FailingBuildCtrl extends _Ctrl {
  @override
  Map<String, dynamic> buildData() => throw StateError('boom');
}

final class _LocalizedResolver extends OiAfMessageResolver {
  const _LocalizedResolver();

  @override
  String buildDataFailed(BuildContext context) => 'LOCALIZED_BUILD_FAILED';
}

/// Kept `const` so the fields below only rebuild when the form tells them to.
const Widget _fields = Column(
  children: [
    OiAfTextInput<_F>(field: _F.name, label: 'Name'),
    OiAfSubmitButton<_F, Map<String, dynamic>>(label: 'Save'),
  ],
);

void main() {
  group('OiAfForm prop changes', () {
    testWidgets('enabled is applied to the attached controller', (
      tester,
    ) async {
      final ctrl = _Ctrl();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        pumpFormWithController(controller: ctrl, child: _fields),
      );
      expect(ctrl.isEnabled, isTrue);
      expect(tester.widget<OiButton>(find.byType(OiButton)).enabled, isTrue);

      await tester.pumpWidget(
        pumpFormWithController(
          controller: ctrl,
          enabled: false,
          child: _fields,
        ),
      );

      expect(ctrl.isEnabled, isFalse);
      expect(tester.widget<OiButton>(find.byType(OiButton)).enabled, isFalse);
      expect(
        tester.widget<OiTextInput>(find.byType(OiTextInput)).enabled,
        isFalse,
      );

      await tester.pumpWidget(
        pumpFormWithController(controller: ctrl, child: _fields),
      );

      expect(ctrl.isEnabled, isTrue);
      expect(tester.widget<OiButton>(find.byType(OiButton)).enabled, isTrue);
    });

    testWidgets('an unrelated rebuild keeps controller.disable()', (
      tester,
    ) async {
      final ctrl = _Ctrl();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        pumpFormWithController(controller: ctrl, child: _fields),
      );
      ctrl.disable();

      await tester.pumpWidget(
        pumpFormWithController(
          controller: ctrl,
          validateMode: OiAfValidateMode.onChange,
          child: _fields,
        ),
      );

      expect(ctrl.isEnabled, isFalse);
    });

    testWidgets(
      'a changed enabled prop notifies the controller listeners once, '
      'after the frame',
      (tester) async {
        final ctrl = _Ctrl();
        addTearDown(ctrl.dispose);
        final seen = <bool>[];

        await tester.pumpWidget(
          pumpFormWithController(controller: ctrl, child: _fields),
        );
        ctrl.addListener(() => seen.add(ctrl.isEnabled));

        await tester.pumpWidget(
          pumpFormWithController(
            controller: ctrl,
            enabled: false,
            child: _fields,
          ),
        );
        expect(seen, [false]);

        // Same enabled value, another prop changed: nothing to announce.
        await tester.pumpWidget(
          pumpFormWithController(
            controller: ctrl,
            enabled: false,
            validateMode: OiAfValidateMode.onChange,
            child: _fields,
          ),
        );
        expect(seen, [false]);

        await tester.pumpWidget(
          pumpFormWithController(
            controller: ctrl,
            validateMode: OiAfValidateMode.onChange,
            child: _fields,
          ),
        );
        expect(seen, [false, true]);
      },
    );

    testWidgets('a controller disposed in the same frame is not notified', (
      tester,
    ) async {
      final ctrl = _Ctrl();
      var notified = 0;

      await tester.pumpWidget(
        pumpFormWithController(controller: ctrl, child: _fields),
      );
      ctrl.addListener(() => notified++);

      // Registered first, so it runs before the notification the form queues
      // while it rebuilds.
      tester.binding.addPostFrameCallback((_) => ctrl.dispose());
      await tester.pumpWidget(
        pumpFormWithController(
          controller: ctrl,
          enabled: false,
          child: _fields,
        ),
      );

      expect(notified, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a new onSubmit replaces the old closure', (tester) async {
      final ctrl = _Ctrl();
      addTearDown(ctrl.dispose);
      final calls = <String>[];

      await tester.pumpWidget(
        pumpFormWithController(
          controller: ctrl,
          onSubmit: (_, _) async => calls.add('old'),
          child: _fields,
        ),
      );
      await tester.pumpWidget(
        pumpFormWithController(
          controller: ctrl,
          onSubmit: (_, _) async => calls.add('new'),
          child: _fields,
        ),
      );

      await ctrl.submit();

      expect(calls, ['new']);
    });

    testWidgets('a new validateMode is applied', (tester) async {
      final ctrl = _Ctrl();
      addTearDown(ctrl.dispose);
      var validations = 0;
      ctrl.observer = _CountingObserver(() => validations++);

      await tester.pumpWidget(
        pumpFormWithController(
          controller: ctrl,
          validateMode: OiAfValidateMode.onSubmit,
          child: _fields,
        ),
      );
      ctrl.fieldController(_F.name).setValue('Grace');
      await tester.pump();
      expect(validations, 0);

      await tester.pumpWidget(
        pumpFormWithController(
          controller: ctrl,
          validateMode: OiAfValidateMode.onChange,
          child: _fields,
        ),
      );
      ctrl.fieldController(_F.name).setValue('Linus');
      await tester.pump();

      expect(validations, 1);
    });
  });

  group('OiAfForm messages', () {
    testWidgets('a buildData failure uses the message resolver', (
      tester,
    ) async {
      final ctrl = _FailingBuildCtrl();
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        OiApp(
          home: OiAfForm<_F, Map<String, dynamic>>(
            controller: ctrl,
            messageResolver: const _LocalizedResolver(),
            child: _fields,
          ),
        ),
      );

      final result = await ctrl.submit();

      expect((result as OiAfSubmitFailure<Map<String, dynamic>>).globalErrors, [
        'LOCALIZED_BUILD_FAILED',
      ]);
    });
  });

  group('field value type mismatch', () {
    testWidgets('names the field instead of a bare cast error', (tester) async {
      final ctrl = _Ctrl();
      addTearDown(ctrl.dispose);
      // A slider holds a double; an int is not one on native platforms.
      ctrl.set<int>(_F.amount, 5);

      await tester.pumpWidget(
        pumpFormWithController(
          controller: ctrl,
          child: const OiAfSlider<_F>(field: _F.amount, min: 0, max: 100),
        ),
      );

      final error = tester.takeException();
      expect(error, isA<FlutterError>());
      expect(error.toString(), contains('_F.amount'));
      expect(error.toString(), contains('int'));
      expect(error.toString(), contains('double'));
    });
  });
}

final class _CountingObserver extends OiAfObserver {
  _CountingObserver(this.onValidated);

  final void Function() onValidated;

  @override
  void onFieldValidated(Enum field, List<String> errors) => onValidated();
}
