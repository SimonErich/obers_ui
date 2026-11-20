// Tests intentionally call @protected addXxxField methods via the
// onDefineFields callback to exercise field registration logic.
// ignore_for_file: invalid_use_of_protected_member
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

import '../../fixtures/test_enums.dart';

typedef _Data = Map<String, dynamic>;

/// A validator whose every call stays pending until the test completes it.
class _GatedValidator {
  final List<({String? value, Completer<String?> gate})> calls = [];

  FutureOr<String?> call(OiAfValidationContext<TestField, String> ctx) {
    final gate = Completer<String?>();
    calls.add((value: ctx.value, gate: gate));
    return gate.future;
  }
}

class _RecordingObserver extends OiAfObserver {
  int started = 0;
  final List<OiAfSubmitResult<Object?>> completed = [];

  @override
  void onSubmitStarted() => started++;

  @override
  void onSubmitCompleted(OiAfSubmitResult<Object?> result) =>
      completed.add(result);
}

/// `name` runs the gated validator; `agree` gates its visibility or enabled
/// state when asked to; `email` is required.
TestController _controller(
  _GatedValidator validator, {
  String nameInitial = '',
  bool gateVisibility = false,
  bool gateEnabled = false,
}) => TestController(
  onDefineFields: (ctrl) {
    ctrl
      ..addBoolField(TestField.agree, initialValue: true)
      ..addTextField(
        TestField.name,
        initialValue: nameInitial,
        validators: [validator.call],
        visibleWhen: gateVisibility
            ? (form) => form.getOr<bool>(TestField.agree, false)
            : null,
        enabledWhen: gateEnabled
            ? (form) => form.getOr<bool>(TestField.agree, false)
            : null,
      )
      ..addTextField(TestField.email, initialValue: 'a@b.com', required: true);
  },
);

/// Attaches [ctrl] and returns the list `onSubmit` records its data in.
List<_Data> _attach(
  TestController ctrl, {
  OiAfValidateMode validateMode = OiAfValidateMode.onBlurThenChange,
}) {
  final submitted = <_Data>[];
  ctrl.attach(
    validateMode: validateMode,
    submitOnEnterFromLastField: true,
    focusFirstInvalidFieldOnSubmitFailure: false,
    clearGlobalErrorsOnFieldChange: true,
    enabled: true,
    onSubmit: (data, _) async => submitted.add(data),
  );
  return submitted;
}

void main() {
  // ═════════════════════════════════════════════════════════════════════════
  //  RESET / REBASE UNDER A SUBMIT
  // ═════════════════════════════════════════════════════════════════════════

  group('submit never sends a value that was not validated', () {
    test(
      'reset() mid-submit: the reset value is validated and fails',
      () async {
        final validator = _GatedValidator();
        final ctrl = _controller(validator);
        addTearDown(ctrl.dispose);
        final submitted = _attach(ctrl);
        ctrl.fieldController(TestField.name).setValue('x');

        final pending = ctrl.submit();
        expect(validator.calls.single.value, 'x');

        ctrl.reset();
        validator.calls[0].gate.complete(null);
        await pumpEventQueue();

        expect(validator.calls, hasLength(2));
        expect(validator.calls[1].value, '');
        validator.calls[1].gate.complete('is empty');

        final result = await pending;
        expect(result, isA<OiAfSubmitInvalid<_Data>>());
        expect((result as OiAfSubmitInvalid<_Data>).fieldErrors, {
          TestField.name: ['is empty'],
        });
        expect(submitted, isEmpty);
      },
    );

    test(
      'reset() mid-submit: the reset value is validated and passes',
      () async {
        final validator = _GatedValidator();
        final ctrl = _controller(validator);
        addTearDown(ctrl.dispose);
        final submitted = _attach(ctrl);
        ctrl.fieldController(TestField.name).setValue('x');

        final pending = ctrl.submit();
        ctrl.reset();
        validator.calls[0].gate.complete('x is bad');
        await pumpEventQueue();

        expect(validator.calls, hasLength(2));
        expect(validator.calls[1].value, '');
        validator.calls[1].gate.complete(null);

        expect(await pending, isA<OiAfSubmitSuccess<_Data>>());
        expect(submitted.single['name'], '');
      },
    );

    test('rebase() mid-submit: the rebased value is validated', () async {
      final validator = _GatedValidator();
      final ctrl = _controller(validator, nameInitial: 'ok');
      addTearDown(ctrl.dispose);
      final submitted = _attach(ctrl);

      final pending = ctrl.submit();
      expect(validator.calls.single.value, 'ok');

      ctrl.rebase({TestField.name: 'bad'});
      validator.calls[0].gate.complete(null);
      await pumpEventQueue();

      expect(validator.calls, hasLength(2));
      expect(validator.calls[1].value, 'bad');
      validator.calls[1].gate.complete('is bad');

      final result = await pending;
      expect(result, isA<OiAfSubmitInvalid<_Data>>());
      expect(ctrl.getErrors(TestField.name), ['is bad']);
      expect(submitted, isEmpty);
    });

    // ═══════════════════════════════════════════════════════════════════════
    //  HIDE / DISABLE AND BACK UNDER A SUBMIT
    // ═══════════════════════════════════════════════════════════════════════

    test('a field hidden and shown again mid-submit is validated', () async {
      final validator = _GatedValidator();
      final ctrl = _controller(
        validator,
        nameInitial: 'x',
        gateVisibility: true,
      );
      addTearDown(ctrl.dispose);
      final submitted = _attach(ctrl);

      final pending = ctrl.submit();
      ctrl
        ..set<bool>(TestField.agree, false)
        ..set<bool>(TestField.agree, true);
      expect(ctrl.isFieldVisible(TestField.name), isTrue);

      validator.calls[0].gate.complete('is bad');
      await pumpEventQueue();

      expect(validator.calls, hasLength(2));
      expect(validator.calls[1].value, 'x');
      validator.calls[1].gate.complete('is bad');

      final result = await pending;
      expect(result, isA<OiAfSubmitInvalid<_Data>>());
      expect(ctrl.getErrors(TestField.name), ['is bad']);
      expect(submitted, isEmpty);
    });

    test(
      'a field disabled and enabled again mid-submit is validated',
      () async {
        final validator = _GatedValidator();
        final ctrl = _controller(
          validator,
          nameInitial: 'x',
          gateEnabled: true,
        );
        addTearDown(ctrl.dispose);
        final submitted = _attach(ctrl);

        final pending = ctrl.submit();
        ctrl
          ..set<bool>(TestField.agree, false)
          ..set<bool>(TestField.agree, true);
        expect(ctrl.isFieldEnabled(TestField.name), isTrue);

        validator.calls[0].gate.complete(null);
        await pumpEventQueue();

        expect(validator.calls, hasLength(2));
        validator.calls[1].gate.complete('is bad');

        final result = await pending;
        expect(result, isA<OiAfSubmitInvalid<_Data>>());
        expect(ctrl.getErrors(TestField.name), ['is bad']);
        expect(submitted, isEmpty);
      },
    );

    test('a field still hidden when the submit decides is left out', () async {
      final validator = _GatedValidator();
      final ctrl = _controller(
        validator,
        nameInitial: 'x',
        gateVisibility: true,
      );
      addTearDown(ctrl.dispose);
      final submitted = _attach(ctrl);

      final pending = ctrl.submit();
      ctrl.set<bool>(TestField.agree, false);
      validator.calls.single.gate.complete('is bad');

      expect(await pending, isA<OiAfSubmitSuccess<_Data>>());
      expect(validator.calls, hasLength(1));
      expect(submitted.single.containsKey('name'), isFalse);
    });

    // ═══════════════════════════════════════════════════════════════════════
    //  ANOTHER FIELD CHANGING UNDER A SUBMIT
    // ═══════════════════════════════════════════════════════════════════════

    test('a field that passed and is then emptied fails the submit', () async {
      final validator = _GatedValidator();
      final ctrl = _controller(validator, nameInitial: 'x');
      addTearDown(ctrl.dispose);
      final submitted = _attach(ctrl);

      final pending = ctrl.submit();
      // email already passed its (synchronous) required check.
      ctrl.fieldController(TestField.email).setValue('');
      validator.calls.single.gate.complete(null);

      final result = await pending;
      expect(result, isA<OiAfSubmitInvalid<_Data>>());
      expect((result as OiAfSubmitInvalid<_Data>).fieldErrors, {
        TestField.email: ['This field is required.'],
      });
      expect(submitted, isEmpty);
    });

    test('the same holds when the mode does not validate on change', () async {
      final validator = _GatedValidator();
      final ctrl = _controller(validator, nameInitial: 'x');
      addTearDown(ctrl.dispose);
      final submitted = _attach(ctrl, validateMode: OiAfValidateMode.onSubmit);

      final pending = ctrl.submit();
      ctrl.fieldController(TestField.email).setValue('');
      expect(ctrl.getErrors(TestField.email), isEmpty);
      validator.calls.single.gate.complete(null);

      final result = await pending;
      expect(result, isA<OiAfSubmitInvalid<_Data>>());
      expect(ctrl.getErrors(TestField.email), ['This field is required.']);
      expect(submitted, isEmpty);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  OBSERVER
  // ═════════════════════════════════════════════════════════════════════════

  group('observer', () {
    test(
      'a submit disposed while validating still reports completion',
      () async {
        final validator = _GatedValidator();
        final ctrl = _controller(validator, nameInitial: 'x');
        final observer = _RecordingObserver();
        ctrl.observer = observer;
        _attach(ctrl);

        final pending = ctrl.submit();
        ctrl.dispose();
        validator.calls.single.gate.complete(null);
        final result = await pending;

        expect(observer.started, 1);
        expect(observer.completed, [same(result)]);
        expect(result, isA<OiAfSubmitFailure<_Data>>());
      },
    );
  });
}
