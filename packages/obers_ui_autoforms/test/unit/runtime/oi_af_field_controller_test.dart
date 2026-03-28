import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

// ── Test Enum ────────────────────────────────────────────────────────────────

enum TestField { name, email, password, age, agree }

// ── Mock Reader ──────────────────────────────────────────────────────────────

class MockReader implements OiAfReader<TestField> {
  MockReader([this._values = const {}]);

  final Map<TestField, Object?> _values;

  @override
  TValue? get<TValue>(TestField field) {
    final v = _values[field];
    if (v is TValue) return v;
    return null;
  }

  @override
  TValue getOr<TValue>(TestField field, TValue fallback) =>
      get<TValue>(field) ?? fallback;

  @override
  bool isFieldVisible(TestField field) => true;

  @override
  bool isFieldEnabled(TestField field) => true;

  @override
  bool isFieldDirty(TestField field) => false;
}

// ── Helpers ──────────────────────────────────────────────────────────────────

OiAfFieldController<TestField> _textFieldController({
  String? initialValue,
  bool required = false,
  List<OiAfValidator<TestField, String>> validators = const [],
  bool clearErrorsOnChange = true,
  bool excludeWhenHidden = true,
  bool clearValueWhenHidden = false,
  bool skipValidationWhenDisabled = true,
}) {
  final def = OiAfTextFieldDef<TestField>(
    field: TestField.name,
    initialValue: initialValue,
    required: required,
    validators: validators,
    clearErrorsOnChange: clearErrorsOnChange,
    excludeWhenHidden: excludeWhenHidden,
    clearValueWhenHidden: clearValueWhenHidden,
    skipValidationWhenDisabled: skipValidationWhenDisabled,
  );
  return OiAfFieldController<TestField>(
    definition: def as OiAfFieldDefinition<TestField, String>,
    initialValue: initialValue,
  );
}

void main() {
  // ═════════════════════════════════════════════════════════════════════════
  //  INITIAL STATE
  // ═════════════════════════════════════════════════════════════════════════

  group('initial state', () {
    test('has initial value', () {
      final fc = _textFieldController(initialValue: 'hello');
      expect(fc.value, 'hello');
      expect(fc.initialValue, 'hello');
    });

    test('starts not dirty', () {
      final fc = _textFieldController(initialValue: 'hello');
      expect(fc.isDirty, isFalse);
    });

    test('starts not touched', () {
      final fc = _textFieldController();
      expect(fc.isTouched, isFalse);
    });

    test('starts not focused', () {
      final fc = _textFieldController();
      expect(fc.isFocused, isFalse);
    });

    test('starts enabled', () {
      final fc = _textFieldController();
      expect(fc.isEnabled, isTrue);
    });

    test('starts visible', () {
      final fc = _textFieldController();
      expect(fc.isVisible, isTrue);
    });

    test('starts valid (no errors)', () {
      final fc = _textFieldController();
      expect(fc.isValid, isTrue);
      expect(fc.hasErrors, isFalse);
      expect(fc.errors, isEmpty);
      expect(fc.primaryError, isNull);
    });

    test('null initialValue', () {
      final fc = _textFieldController();
      expect(fc.value, isNull);
      expect(fc.initialValue, isNull);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  setValue
  // ═════════════════════════════════════════════════════════════════════════

  group('setValue', () {
    test('updates value', () {
      final fc = _textFieldController()..setValue('new');
      expect(fc.value, 'new');
    });

    test('marks dirty when value differs from initial', () {
      final fc = _textFieldController(initialValue: 'old')..setValue('new');
      expect(fc.isDirty, isTrue);
    });

    test('not dirty when value matches initial', () {
      final fc = _textFieldController(initialValue: 'same')
        ..setValue('different')
        ..setValue('same');
      expect(fc.isDirty, isFalse);
    });

    test('marks touched by default', () {
      final fc = _textFieldController()..setValue('val');
      expect(fc.isTouched, isTrue);
    });

    test('does not mark touched when markTouched is false', () {
      final fc = _textFieldController()..setValue('val', markTouched: false);
      expect(fc.isTouched, isFalse);
    });

    test('marks user edited when fromUser is true', () {
      final fc = _textFieldController()..setValue('val');
      expect(fc.hasUserEdited, isTrue);
    });

    test('does not mark user edited when fromUser is false', () {
      final fc = _textFieldController()..setValue('val', fromUser: false);
      expect(fc.hasUserEdited, isFalse);
    });

    test('clears validation errors when clearErrorsOnChange is true', () {
      final fc = _textFieldController()..setError('some error');
      expect(fc.errors, isNotEmpty);
      fc.setValue('new');
      // Validation errors should be cleared (only validation, not backend)
      // Let's verify by checking the isValid which depends on both
      // Actually checking the error count from the source
      expect(fc.errors.where((e) => e == 'some error'), isEmpty);
    });

    test('clears backend errors when fromUser is true', () {
      final fc = _textFieldController()..setBackendError('server error');
      expect(fc.errors, contains('server error'));
      fc.setValue('new');
      expect(fc.errors.where((e) => e == 'server error'), isEmpty);
    });

    test('does not clear backend errors when fromUser is false', () {
      final fc = _textFieldController()
        ..setBackendError('server error')
        ..setValue('new', fromUser: false);
      expect(fc.errors, contains('server error'));
    });

    test('notifies listeners', () {
      final fc = _textFieldController();
      var notified = false;
      fc
        ..addListener(() => notified = true)
        ..setValue('val');
      expect(notified, isTrue);
    });

    test('does not notify when notify is false', () {
      final fc = _textFieldController();
      var notified = false;
      fc
        ..addListener(() => notified = true)
        ..setValue('val', notify: false);
      expect(notified, isFalse);
    });

    test('fires onValueChanged callback', () {
      final fc = _textFieldController();
      TestField? changedField;
      bool? wasFromUser;
      fc
        ..onValueChanged = (field, {required bool fromUser}) {
          changedField = field;
          wasFromUser = fromUser;
        }
        ..setValue('val');
      expect(changedField, TestField.name);
      expect(wasFromUser, isTrue);
    });

    test('skips notification when value unchanged', () {
      final fc = _textFieldController(initialValue: 'same');
      var notifyCount = 0;
      fc
        ..addListener(() => notifyCount++)
        ..setValue('same', markTouched: false);
      expect(notifyCount, 0);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  ERROR BUCKETS
  // ═════════════════════════════════════════════════════════════════════════

  group('error buckets', () {
    test('setError replaces validation errors', () {
      final fc = _textFieldController()..setError('err1');
      expect(fc.primaryError, 'err1');
      fc.setError('err2');
      expect(fc.primaryError, 'err2');
      expect(fc.errors.length, 1);
    });

    test('setErrors sets multiple validation errors', () {
      final fc = _textFieldController()..setErrors(['e1', 'e2', 'e3']);
      expect(fc.errors.length, 3);
      expect(fc.primaryError, 'e1');
    });

    test('clearErrors clears validation errors', () {
      final fc = _textFieldController()
        ..setErrors(['e1', 'e2'])
        ..clearErrors();
      expect(fc.errors, isEmpty);
      expect(fc.isValid, isTrue);
    });

    test('setBackendError sets backend error', () {
      final fc = _textFieldController()..setBackendError('backend err');
      expect(fc.errors, contains('backend err'));
      expect(fc.primaryError, 'backend err');
    });

    test('setBackendErrors sets multiple backend errors', () {
      final fc = _textFieldController()..setBackendErrors(['b1', 'b2']);
      expect(fc.errors.length, 2);
    });

    test('clearBackendErrors clears only backend errors', () {
      final fc = _textFieldController()
        ..setError('validation err')
        ..setBackendError('backend err')
        ..clearBackendErrors();
      expect(fc.errors, contains('validation err'));
      expect(fc.errors.where((e) => e == 'backend err'), isEmpty);
    });

    test('errors combines validation and backend errors', () {
      final fc = _textFieldController()
        ..setError('val err')
        ..setBackendError('be err');
      expect(fc.errors, containsAll(['val err', 'be err']));
    });

    test('isValid requires both buckets empty', () {
      final fc = _textFieldController();
      expect(fc.isValid, isTrue);

      fc.setBackendError('err');
      expect(fc.isValid, isFalse);

      fc.clearBackendErrors();
      expect(fc.isValid, isTrue);

      fc.setError('err');
      expect(fc.isValid, isFalse);
    });

    test('primaryError prefers validation errors over backend', () {
      final fc = _textFieldController()
        ..setError('val err')
        ..setBackendError('be err');
      expect(fc.primaryError, 'val err');
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  FOCUS
  // ═════════════════════════════════════════════════════════════════════════

  group('focus', () {
    test('setFocused updates isFocused', () {
      final fc = _textFieldController()..setFocused(focused: true);
      expect(fc.isFocused, isTrue);
      fc.setFocused(focused: false);
      expect(fc.isFocused, isFalse);
    });

    test('losing focus marks touched', () {
      final fc = _textFieldController();
      expect(fc.isTouched, isFalse);
      fc.setFocused(focused: true);
      expect(fc.isTouched, isFalse);
      fc.setFocused(focused: false);
      expect(fc.isTouched, isTrue);
    });

    test('fires onFocusChanged callback', () {
      final fc = _textFieldController();
      TestField? changedField;
      bool? wasFocused;
      fc
        ..onFocusChanged = (field, {required bool focused}) {
          changedField = field;
          wasFocused = focused;
        }
        ..setFocused(focused: true);
      expect(changedField, TestField.name);
      expect(wasFocused, isTrue);
    });

    test('does not re-notify when focus unchanged', () {
      final fc = _textFieldController()..setFocused(focused: true);
      var count = 0;
      fc
        ..addListener(() => count++)
        ..setFocused(focused: true); // no change
      expect(count, 0);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  ENABLED / VISIBLE
  // ═════════════════════════════════════════════════════════════════════════

  group('enabled', () {
    test('setEnabled updates isEnabled', () {
      final fc = _textFieldController()..setEnabled(enabled: false);
      expect(fc.isEnabled, isFalse);
      fc.setEnabled(enabled: true);
      expect(fc.isEnabled, isTrue);
    });

    test(
      'disabling clears validation errors when skipValidationWhenDisabled',
      () {
        final fc = _textFieldController()
          ..setError('err')
          ..setEnabled(enabled: false);
        // Validation errors should be cleared
        expect(fc.errors.where((e) => e == 'err'), isEmpty);
      },
    );
  });

  group('visible', () {
    test('setVisible updates isVisible', () {
      final fc = _textFieldController()..setVisible(visible: false);
      expect(fc.isVisible, isFalse);
      fc.setVisible(visible: true);
      expect(fc.isVisible, isTrue);
    });

    test('hiding clears errors when excludeWhenHidden', () {
      final fc = _textFieldController()
        ..setError('val err')
        ..setBackendError('be err')
        ..setVisible(visible: false);
      expect(fc.errors, isEmpty);
    });

    test('hiding clears value when clearValueWhenHidden', () {
      final fc = _textFieldController(
        initialValue: 'hello',
        clearValueWhenHidden: true,
      )..setVisible(visible: false);
      expect(fc.value, isNull);
      expect(fc.isDirty, isFalse);
    });

    test('hiding removes focus', () {
      final fc = _textFieldController()
        ..setFocused(focused: true)
        ..setVisible(visible: false);
      expect(fc.isFocused, isFalse);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  VALIDATION PHASE STATE MACHINE
  // ═════════════════════════════════════════════════════════════════════════

  group('validation phase (onBlurThenChange)', () {
    test('starts pristine', () {
      final fc = _textFieldController();
      // Change trigger should not validate in pristine
      expect(
        fc.shouldValidateForTrigger(
          OiAfValidationTrigger.change,
          OiAfValidateMode.onBlurThenChange,
        ),
        isFalse,
      );
    });

    test('blur transitions to blurredOnce and validates', () {
      final fc = _textFieldController();
      expect(
        fc.shouldValidateForTrigger(
          OiAfValidationTrigger.blur,
          OiAfValidateMode.onBlurThenChange,
        ),
        isTrue,
      );
    });

    test('after blur, change triggers validate', () {
      // First blur
      final fc = _textFieldController()
        ..shouldValidateForTrigger(
          OiAfValidationTrigger.blur,
          OiAfValidateMode.onBlurThenChange,
        );
      // Now change should also validate
      expect(
        fc.shouldValidateForTrigger(
          OiAfValidationTrigger.change,
          OiAfValidateMode.onBlurThenChange,
        ),
        isTrue,
      );
    });

    test('promoteValidationPhase makes change validate immediately', () {
      final fc = _textFieldController();
      // pristine
      expect(
        fc.shouldValidateForTrigger(
          OiAfValidationTrigger.change,
          OiAfValidateMode.onBlurThenChange,
        ),
        isFalse,
      );
      fc.promoteValidationPhase();
      expect(
        fc.shouldValidateForTrigger(
          OiAfValidationTrigger.change,
          OiAfValidateMode.onBlurThenChange,
        ),
        isTrue,
      );
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  shouldValidateForTrigger
  // ═════════════════════════════════════════════════════════════════════════

  group('shouldValidateForTrigger', () {
    late OiAfFieldController<TestField> fc;

    setUp(() {
      fc = _textFieldController();
    });

    test('submit always returns true', () {
      for (final mode in OiAfValidateMode.values) {
        expect(
          fc.shouldValidateForTrigger(OiAfValidationTrigger.submit, mode),
          isTrue,
          reason: 'submit should always validate for $mode',
        );
      }
    });

    test('manual always returns true', () {
      for (final mode in OiAfValidateMode.values) {
        expect(
          fc.shouldValidateForTrigger(OiAfValidationTrigger.manual, mode),
          isTrue,
          reason: 'manual should always validate for $mode',
        );
      }
    });

    test('dependencyChange always returns true', () {
      for (final mode in OiAfValidateMode.values) {
        expect(
          fc.shouldValidateForTrigger(
            OiAfValidationTrigger.dependencyChange,
            mode,
          ),
          isTrue,
          reason: 'dependencyChange should always validate for $mode',
        );
      }
    });

    test('disabled mode rejects change and blur', () {
      expect(
        fc.shouldValidateForTrigger(
          OiAfValidationTrigger.change,
          OiAfValidateMode.disabled,
        ),
        isFalse,
      );
      expect(
        fc.shouldValidateForTrigger(
          OiAfValidationTrigger.blur,
          OiAfValidateMode.disabled,
        ),
        isFalse,
      );
    });

    test('onSubmit mode only accepts submit trigger', () {
      expect(
        fc.shouldValidateForTrigger(
          OiAfValidationTrigger.change,
          OiAfValidateMode.onSubmit,
        ),
        isFalse,
      );
      expect(
        fc.shouldValidateForTrigger(
          OiAfValidationTrigger.blur,
          OiAfValidateMode.onSubmit,
        ),
        isFalse,
      );
    });

    test('onBlur mode accepts blur trigger', () {
      expect(
        fc.shouldValidateForTrigger(
          OiAfValidationTrigger.blur,
          OiAfValidateMode.onBlur,
        ),
        isTrue,
      );
    });

    test('onBlur mode rejects change trigger', () {
      expect(
        fc.shouldValidateForTrigger(
          OiAfValidationTrigger.change,
          OiAfValidateMode.onBlur,
        ),
        isFalse,
      );
    });

    test('onChange mode accepts all triggers', () {
      expect(
        fc.shouldValidateForTrigger(
          OiAfValidationTrigger.change,
          OiAfValidateMode.onChange,
        ),
        isTrue,
      );
      expect(
        fc.shouldValidateForTrigger(
          OiAfValidationTrigger.blur,
          OiAfValidateMode.onChange,
        ),
        isTrue,
      );
    });

    test('onInit mode accepts all triggers', () {
      expect(
        fc.shouldValidateForTrigger(
          OiAfValidationTrigger.change,
          OiAfValidateMode.onInit,
        ),
        isTrue,
      );
      expect(
        fc.shouldValidateForTrigger(
          OiAfValidationTrigger.init,
          OiAfValidateMode.onInit,
        ),
        isTrue,
      );
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  VALIDATION
  // ═════════════════════════════════════════════════════════════════════════

  group('validate', () {
    test('required field fails for null', () async {
      final fc = _textFieldController(required: true);
      final result = await fc.validate(
        effectiveMode: OiAfValidateMode.onChange,
        form: MockReader(),
      );
      expect(result, isFalse);
      expect(fc.errors, isNotEmpty);
    });

    test('required field passes for non-null', () async {
      final fc = _textFieldController(required: true)
        ..setValue('hello', fromUser: false);
      final result = await fc.validate(
        effectiveMode: OiAfValidateMode.onChange,
        form: MockReader(),
      );
      expect(result, isTrue);
      expect(fc.errors, isEmpty);
    });

    test('runs custom validators', () async {
      final fc = _textFieldController(
        validators: [OiAfValidators.minLength<TestField>(5)],
      )..setValue('ab', fromUser: false);
      final result = await fc.validate(
        effectiveMode: OiAfValidateMode.onChange,
        form: MockReader(),
      );
      expect(result, isFalse);
      expect(fc.errors, isNotEmpty);
    });

    test('skips validation when hidden and excludeWhenHidden', () async {
      final fc = _textFieldController(required: true)
        ..setVisible(visible: false);
      final result = await fc.validate(
        effectiveMode: OiAfValidateMode.onChange,
        form: MockReader(),
      );
      expect(result, isTrue);
    });

    test(
      'skips validation when disabled and skipValidationWhenDisabled',
      () async {
        final fc = _textFieldController(required: true)
          ..setEnabled(enabled: false);
        final result = await fc.validate(
          effectiveMode: OiAfValidateMode.onChange,
          form: MockReader(),
        );
        expect(result, isTrue);
      },
    );

    test('respects shouldValidateForTrigger', () async {
      final fc = _textFieldController(required: true);
      // In pristine state, onChange should not trigger for onBlurThenChange
      final result = await fc.validate(
        trigger: OiAfValidationTrigger.change,
        effectiveMode: OiAfValidateMode.onBlurThenChange,
        form: MockReader(),
      );
      // Should return current isValid (no errors set yet since it skipped)
      expect(result, isTrue);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  RESET
  // ═════════════════════════════════════════════════════════════════════════

  group('reset', () {
    test('restores initial value', () {
      final fc = _textFieldController(initialValue: 'original')
        ..setValue('changed')
        ..reset();
      expect(fc.value, 'original');
    });

    test('clears dirty state', () {
      final fc = _textFieldController(initialValue: 'original')
        ..setValue('changed')
        ..reset();
      expect(fc.isDirty, isFalse);
    });

    test('clears touched state', () {
      final fc = _textFieldController()
        ..setValue('val')
        ..reset();
      expect(fc.isTouched, isFalse);
    });

    test('clears user edit tracking', () {
      final fc = _textFieldController()
        ..setValue('val')
        ..reset();
      expect(fc.hasUserEdited, isFalse);
    });

    test('clears all errors', () {
      final fc = _textFieldController()
        ..setError('err1')
        ..setBackendError('err2')
        ..reset();
      expect(fc.errors, isEmpty);
      expect(fc.isValid, isTrue);
    });

    test('resets validation phase to pristine', () {
      // Trigger blur to move to blurredOnce
      final fc = _textFieldController()
        ..shouldValidateForTrigger(
          OiAfValidationTrigger.blur,
          OiAfValidateMode.onBlurThenChange,
        )
        ..reset();
      // After reset, change should not trigger in onBlurThenChange
      expect(
        fc.shouldValidateForTrigger(
          OiAfValidationTrigger.change,
          OiAfValidateMode.onBlurThenChange,
        ),
        isFalse,
      );
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  REBASE
  // ═════════════════════════════════════════════════════════════════════════

  group('rebaseInitialValue', () {
    test('updates both initial and current value', () {
      final fc = _textFieldController(initialValue: 'old')
        ..rebaseInitialValue('new');
      expect(fc.value, 'new');
      expect(fc.initialValue, 'new');
    });

    test('resets all state', () {
      final fc = _textFieldController(initialValue: 'old')
        ..setValue('changed')
        ..setError('err')
        ..rebaseInitialValue('rebased');
      expect(fc.isDirty, isFalse);
      expect(fc.isTouched, isFalse);
      expect(fc.errors, isEmpty);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  TOUCHED / ENABLED STATE
  // ═════════════════════════════════════════════════════════════════════════

  group('setTouched', () {
    test('explicitly sets touched', () {
      final fc = _textFieldController()..setTouched(touched: true);
      expect(fc.isTouched, isTrue);
      fc.setTouched(touched: false);
      expect(fc.isTouched, isFalse);
    });

    test('does not notify when unchanged', () {
      final fc = _textFieldController();
      var count = 0;
      fc
        ..addListener(() => count++)
        ..setTouched(touched: false); // already false
      expect(count, 0);
    });
  });

  // ═════════════════════════════════════════════════════════════════════════
  //  WIDGET BINDING
  // ═════════════════════════════════════════════════════════════════════════

  group('widget binding', () {
    test('registerPresentationMetadata sets displayLabel', () {
      final fc = _textFieldController()
        ..registerPresentationMetadata(label: 'Name');
      expect(fc.displayLabel, 'Name');
    });

    test('detachWidget clears metadata', () {
      final fc = _textFieldController()
        ..registerPresentationMetadata(label: 'Name')
        ..detachWidget();
      expect(fc.displayLabel, isNull);
    });
  });
}
