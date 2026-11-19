// Tests intentionally call @protected addXxxField methods via the
// onDefineFields callback to exercise field registration logic.
// ignore_for_file: invalid_use_of_protected_member
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

import '../../fixtures/test_enums.dart';

/// A validator whose every call stays pending until the test completes it.
class _GatedValidator {
  final List<({String? value, Completer<String?> gate})> calls = [];

  FutureOr<String?> call(OiAfValidationContext<TestField, String> ctx) {
    final gate = Completer<String?>();
    calls.add((value: ctx.value, gate: gate));
    return gate.future;
  }
}

TestController _gatedController(
  _GatedValidator validator, {
  String initialValue = 'x',
  OiAfVisibleWhen<TestField>? visibleWhen,
  OiAfEnabledWhen<TestField>? enabledWhen,
}) => TestController(
  onDefineFields: (ctrl) {
    ctrl
      ..addBoolField(TestField.agree, initialValue: true)
      ..addTextField(
        TestField.name,
        initialValue: initialValue,
        validators: [validator.call],
        visibleWhen: visibleWhen,
        enabledWhen: enabledWhen,
      );
  },
);

void _attach(
  TestController ctrl, {
  OiAfValidateMode validateMode = OiAfValidateMode.onBlurThenChange,
  Future<void> Function(
    Map<String, dynamic>,
    OiAfController<TestField, Map<String, dynamic>>,
  )?
  onSubmit,
}) {
  ctrl.attach(
    validateMode: validateMode,
    submitOnEnterFromLastField: true,
    focusFirstInvalidFieldOnSubmitFailure: false,
    clearGlobalErrorsOnFieldChange: true,
    enabled: true,
    onSubmit: onSubmit,
  );
}

void main() {
  // ═════════════════════════════════════════════════════════════════════════
  //  DISPOSE
  // ═════════════════════════════════════════════════════════════════════════

  group('dispose', () {
    test('a validation that finishes after dispose does not throw', () async {
      final validator = _GatedValidator();
      final ctrl = _gatedController(validator);

      final pending = ctrl.validate();
      ctrl.dispose();
      validator.calls.single.gate.complete(null);

      await expectLater(pending, completes);
    });

    test('a submit that finishes after dispose does not throw', () async {
      final submitGate = Completer<void>();
      final ctrl = TestController();
      _attach(ctrl, onSubmit: (_, _) => submitGate.future);

      final pending = ctrl.submit();
      await pumpEventQueue();
      expect(ctrl.isSubmitting, isTrue);

      ctrl.dispose();
      submitGate.complete();

      await expectLater(pending, completes);
    });

    test('a submit disposed while validating never calls onSubmit', () async {
      final validator = _GatedValidator();
      final ctrl = _gatedController(validator);
      var submitted = false;
      _attach(ctrl, onSubmit: (_, _) async => submitted = true);

      final pending = ctrl.submit();
      ctrl.dispose();
      validator.calls.single.gate.complete(null);

      final result = await pending;
      expect(result, isNot(isA<OiAfSubmitSuccess<Map<String, dynamic>>>()));
      expect(submitted, isFalse);
    });

    test('disposes the field controllers', () {
      final ctrl = TestController();
      final fc = ctrl.fieldController(TestField.name);

      ctrl.dispose();

      expect(() => fc.addListener(() {}), throwsFlutterError);
    });

    test('a field change after dispose does not throw', () {
      final ctrl = TestController();
      final fc = ctrl.fieldController(TestField.name);

      ctrl.dispose();

      expect(() => fc.setValue('late'), returnsNormally);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  SUPERSEDED VALIDATION
  // ═════════════════════════════════════════════════════════════════════════

  group('superseded validation', () {
    test(
      'an older run waits for the newer one and reports its result',
      () async {
        final validator = _GatedValidator();
        final ctrl = _gatedController(validator);
        addTearDown(ctrl.dispose);
        final fc = ctrl.fieldController(TestField.name);

        final first = ctrl.validate(field: TestField.name);
        final second = ctrl.validate(field: TestField.name);
        expect(validator.calls, hasLength(2));

        var firstDone = false;
        unawaited(first.whenComplete(() => firstDone = true));

        validator.calls[0].gate.complete(null);
        await pumpEventQueue();

        expect(
          fc.isValidating,
          isTrue,
          reason: 'the newer run is still pending',
        );
        expect(firstDone, isFalse);

        validator.calls[1].gate.complete(null);

        expect(await first, isTrue);
        expect(await second, isTrue);
        expect(fc.isValidating, isFalse);
        expect(fc.errors, isEmpty);
      },
    );

    test('an older run reports the newer run failing', () async {
      final validator = _GatedValidator();
      final ctrl = _gatedController(validator);
      addTearDown(ctrl.dispose);

      final first = ctrl.validate(field: TestField.name);
      final second = ctrl.validate(field: TestField.name);

      validator.calls[0].gate.complete(null);
      validator.calls[1].gate.complete('is bad');

      expect(await first, isFalse);
      expect(await second, isFalse);
      expect(ctrl.getErrors(TestField.name), ['is bad']);
    });

    test('typing during a submit does not fail a valid form', () async {
      final validator = _GatedValidator();
      final ctrl = _gatedController(validator);
      addTearDown(ctrl.dispose);
      _attach(ctrl);

      final pending = ctrl.submit();
      expect(validator.calls, hasLength(1));

      // The user keeps typing while the slow validator is still running.
      ctrl.fieldController(TestField.name).setValue('xy');
      expect(validator.calls, hasLength(2));
      expect(validator.calls[1].value, 'xy');

      validator.calls[0].gate.complete(null);
      validator.calls[1].gate.complete(null);

      final result = await pending;
      expect(result, isA<OiAfSubmitSuccess<Map<String, dynamic>>>());
      expect(
        (result as OiAfSubmitSuccess<Map<String, dynamic>>).data['name'],
        'xy',
      );
    });

    test(
      'a submit validates the value typed while it was validating, even when '
      'the mode does not validate on change',
      () async {
        final validator = _GatedValidator();
        final ctrl = _gatedController(validator);
        addTearDown(ctrl.dispose);
        _attach(ctrl, validateMode: OiAfValidateMode.onSubmit);

        final pending = ctrl.submit();
        ctrl.fieldController(TestField.name).setValue('bad');

        expect(validator.calls, hasLength(2));
        expect(validator.calls[1].value, 'bad');

        validator.calls[0].gate.complete(null);
        validator.calls[1].gate.complete('is bad');

        final result = await pending;
        expect(result, isA<OiAfSubmitInvalid<Map<String, dynamic>>>());
        expect(ctrl.getErrors(TestField.name), ['is bad']);
      },
    );
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  STALE ASYNC RESULTS
  // ═════════════════════════════════════════════════════════════════════════

  group('stale async validation results', () {
    test('a result for the old value does not land on the new one', () async {
      final validator = _GatedValidator();
      final ctrl = _gatedController(validator, initialValue: 'bad');
      addTearDown(ctrl.dispose);
      final fc = ctrl.fieldController(TestField.name);

      final pending = ctrl.validate(field: TestField.name);
      ctrl.set<String>(TestField.name, 'good');

      // The interrupted run starts over with the new value.
      expect(validator.calls, hasLength(2));
      expect(validator.calls[1].value, 'good');
      expect(fc.isValidating, isTrue);

      validator.calls[0].gate.complete('is bad');
      await pumpEventQueue();

      expect(fc.value, 'good');
      expect(fc.errors, isEmpty);

      validator.calls[1].gate.complete(null);

      expect(await pending, isTrue);
      expect(fc.errors, isEmpty);
      expect(fc.isValidating, isFalse);
    });

    test('a result does not land on a field hidden meanwhile', () async {
      final validator = _GatedValidator();
      final ctrl = _gatedController(
        validator,
        visibleWhen: (form) => form.getOr<bool>(TestField.agree, false),
      );
      addTearDown(ctrl.dispose);
      final fc = ctrl.fieldController(TestField.name);

      final pending = ctrl.validate(field: TestField.name);
      ctrl.set<bool>(TestField.agree, false);

      expect(fc.isVisible, isFalse);
      expect(fc.isValidating, isFalse);

      validator.calls.single.gate.complete('is bad');

      expect(await pending, isTrue);
      expect(fc.errors, isEmpty);
    });

    test('a result does not land on a field disabled meanwhile', () async {
      final validator = _GatedValidator();
      final ctrl = _gatedController(
        validator,
        enabledWhen: (form) => form.getOr<bool>(TestField.agree, false),
      );
      addTearDown(ctrl.dispose);
      final fc = ctrl.fieldController(TestField.name);

      final pending = ctrl.validate(field: TestField.name);
      ctrl.set<bool>(TestField.agree, false);

      expect(fc.isEnabled, isFalse);
      expect(fc.isValidating, isFalse);

      validator.calls.single.gate.complete('is bad');

      expect(await pending, isTrue);
      expect(fc.errors, isEmpty);
    });

    test('a result does not land on a field reset meanwhile', () async {
      final validator = _GatedValidator();
      final ctrl = _gatedController(validator);
      addTearDown(ctrl.dispose);
      final fc = ctrl.fieldController(TestField.name);

      final pending = ctrl.validate(field: TestField.name);
      ctrl.reset();

      expect(fc.isValidating, isFalse);

      validator.calls.single.gate.complete('is bad');

      // The reset value was never validated, so the run cannot vouch for it.
      expect(await pending, isFalse);
      expect(fc.errors, isEmpty);
      expect(fc.isValidationCurrent, isFalse);
    });

    test('isValidationCurrent follows the value', () async {
      final ctrl = TestController();
      addTearDown(ctrl.dispose);
      final fc = ctrl.fieldController(TestField.name);
      expect(fc.isValidationCurrent, isFalse);

      await ctrl.validate(field: TestField.name);
      expect(fc.isValidationCurrent, isTrue);

      ctrl.set<String>(TestField.name, 'changed');
      expect(fc.isValidationCurrent, isFalse);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  REBASE
  // ═════════════════════════════════════════════════════════════════════════

  group('rebase', () {
    TestController conditional() => TestController(
      onDefineFields: (ctrl) {
        ctrl
          ..addBoolField(TestField.agree, initialValue: false)
          ..addTextField(
            TestField.name,
            initialValue: 'aaa',
            visibleWhen: (form) => form.getOr<bool>(TestField.agree, false),
          )
          ..addTextField(
            TestField.fullName,
            dependsOn: [TestField.name],
            derive: (form) => '${form.getOr<String>(TestField.name, '')}!',
          );
      },
    );

    test('re-evaluates conditions and derived fields', () {
      final ctrl = conditional();
      addTearDown(ctrl.dispose);
      expect(ctrl.isFieldVisible(TestField.name), isFalse);
      expect(ctrl.get<String>(TestField.fullName), 'aaa!');

      ctrl.rebase({TestField.agree: true, TestField.name: 'zzz'});

      expect(ctrl.isFieldVisible(TestField.name), isTrue);
      expect(ctrl.get<String>(TestField.fullName), 'zzz!');
      expect(ctrl.isDirty, isFalse);
    });

    test('restore(rebaseInitial) does the same', () {
      final ctrl = conditional();
      addTearDown(ctrl.dispose);

      ctrl.restore({
        TestField.agree: true,
        TestField.name: 'zzz',
      }, mode: OiAfRestoreMode.rebaseInitial);

      expect(ctrl.isFieldVisible(TestField.name), isTrue);
      expect(ctrl.get<String>(TestField.fullName), 'zzz!');
    });

    test('a derived value supplied in the map wins over derive', () {
      final ctrl = conditional();
      addTearDown(ctrl.dispose);

      ctrl.rebase({TestField.name: 'b', TestField.fullName: 'Custom'});

      expect(ctrl.get<String>(TestField.name), 'b');
      expect(ctrl.get<String>(TestField.fullName), 'Custom');
      expect(ctrl.isDirty, isFalse);
    });

    test('restore(rebaseInitial) keeps a stored derived value', () {
      final ctrl = conditional();
      addTearDown(ctrl.dispose);

      ctrl.restore({
        TestField.name: 'b',
        TestField.fullName: 'Custom',
      }, mode: OiAfRestoreMode.rebaseInitial);

      expect(ctrl.get<String>(TestField.fullName), 'Custom');
    });

    test('a derived field the user overrode is not re-derived', () {
      final ctrl = conditional();
      addTearDown(ctrl.dispose);
      ctrl.fieldController(TestField.fullName).setValue('Mine');

      ctrl.rebase({TestField.name: 'c'});

      expect(ctrl.get<String>(TestField.name), 'c');
      expect(ctrl.get<String>(TestField.fullName), 'Mine');
    });

    test('an alwaysDerived field is re-derived after a user edit', () {
      final ctrl = TestController(
        onDefineFields: (ctrl) {
          ctrl
            ..addTextField(TestField.name, initialValue: 'aaa')
            ..addTextField(
              TestField.fullName,
              dependsOn: [TestField.name],
              derivedOverrideMode: OiAfDerivedOverrideMode.alwaysDerived,
              derive: (form) => '${form.getOr<String>(TestField.name, '')}!',
            );
        },
      );
      addTearDown(ctrl.dispose);
      ctrl.fieldController(TestField.fullName).setValue('Mine');

      ctrl.rebase({TestField.name: 'c'});

      expect(ctrl.get<String>(TestField.fullName), 'c!');
    });

    test('reset() after a rebase derives from the rebased values', () {
      final ctrl = conditional();
      addTearDown(ctrl.dispose);

      ctrl
        ..rebase({TestField.name: 'zzz'})
        ..set<String>(TestField.name, 'edited');
      expect(ctrl.get<String>(TestField.fullName), 'edited!');

      ctrl.reset();

      expect(ctrl.get<String>(TestField.name), 'zzz');
      expect(ctrl.get<String>(TestField.fullName), 'zzz!');
      expect(ctrl.isDirty, isFalse);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  SET
  // ═════════════════════════════════════════════════════════════════════════

  group('set', () {
    test('does not mark the field touched by default', () {
      final ctrl = TestController();
      addTearDown(ctrl.dispose);

      ctrl.set<String>(TestField.name, 'programmatic');

      expect(ctrl.get<String>(TestField.name), 'programmatic');
      expect(ctrl.isFieldDirty(TestField.name), isTrue);
      expect(ctrl.isFieldTouched(TestField.name), isFalse);
      expect(ctrl.isTouched, isFalse);
    });

    test('marks the field touched when asked to', () {
      final ctrl = TestController();
      addTearDown(ctrl.dispose);

      ctrl.set<String>(TestField.name, 'programmatic', markTouched: true);

      expect(ctrl.isFieldTouched(TestField.name), isTrue);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  PATCH
  // ═════════════════════════════════════════════════════════════════════════

  group('patch', () {
    test('does not mark the fields touched by default', () {
      final ctrl = TestController();
      addTearDown(ctrl.dispose);

      ctrl.patch({TestField.name: 'draft', TestField.email: 'a@b.com'});

      expect(ctrl.get<String>(TestField.name), 'draft');
      expect(ctrl.isFieldDirty(TestField.name), isTrue);
      expect(ctrl.isFieldTouched(TestField.name), isFalse);
      expect(ctrl.isFieldTouched(TestField.email), isFalse);
      expect(ctrl.isTouched, isFalse);
    });

    test('marks the fields touched when asked to', () {
      final ctrl = TestController();
      addTearDown(ctrl.dispose);

      ctrl.patch({TestField.name: 'draft'}, markTouched: true);

      expect(ctrl.isFieldTouched(TestField.name), isTrue);
      expect(ctrl.isFieldTouched(TestField.email), isFalse);
    });

    test('restore(patchCurrent) does not mark the fields touched', () {
      final ctrl = TestController();
      addTearDown(ctrl.dispose);

      ctrl.restore({TestField.name: 'draft'});

      expect(ctrl.get<String>(TestField.name), 'draft');
      expect(ctrl.isFieldDirty(TestField.name), isTrue);
      expect(ctrl.isTouched, isFalse);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  DERIVED-FIELD CYCLES
  // ═════════════════════════════════════════════════════════════════════════

  group('derived dependency graph', () {
    test('a cycle throws a StateError naming a field', () {
      expect(
        () => TestController(
          onDefineFields: (ctrl) {
            ctrl
              ..addTextField(
                TestField.name,
                dependsOn: [TestField.fullName],
                derive: (form) => form.getOr<String>(TestField.fullName, ''),
              )
              ..addTextField(
                TestField.fullName,
                dependsOn: [TestField.name],
                derive: (form) => form.getOr<String>(TestField.name, ''),
              );
          },
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Circular'),
          ),
        ),
      );
    });

    test('a dependency on an unregistered field throws a StateError', () {
      expect(
        () => TestController(
          onDefineFields: (ctrl) {
            ctrl.addTextField(
              TestField.fullName,
              dependsOn: [TestField.name],
              derive: (form) => form.getOr<String>(TestField.name, ''),
            );
          },
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('unregistered'),
          ),
        ),
      );
    });
  });
}
