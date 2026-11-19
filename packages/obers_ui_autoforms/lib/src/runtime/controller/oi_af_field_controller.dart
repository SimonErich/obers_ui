import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import 'package:obers_ui_autoforms/src/definitions/oi_af_field_definition.dart';
import 'package:obers_ui_autoforms/src/diagnostics/oi_af_observer.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_reader.dart';
import 'package:obers_ui_autoforms/src/validation/oi_af_validation_messages.dart';
import 'package:obers_ui_autoforms/src/validation/oi_af_validators.dart';
import 'package:obers_ui_autoforms/src/widgets/fields/_oi_af_field_binder.dart'
    show OiAfFieldBinderMixin;

/// Validation phase state machine for onBlurThenChange mode.
enum OiAfFieldValidationPhase {
  /// Never interacted — no errors shown.
  pristine,

  /// User focused and left the field — show errors.
  blurredOnce,

  /// User is changing after first blur — show errors live.
  activelyEditing,
}

/// The arguments of a validation run, kept so an interrupted run can start
/// over with the same ones.
typedef _OiAfValidationRun<TField extends Enum> = ({
  OiAfValidateMode effectiveMode,
  OiAfReader<TField> form,
  OiAfValidationTrigger trigger,
});

/// Per-field runtime controller.
///
/// Stores values as [Object?] internally. Widget binders access typed values
/// through the [OiAfFieldBinderMixin.typedValue] helper. This avoids Dart
/// generic invariance issues when storing controllers in a homogeneous map.
///
/// Each field has its own [ChangeNotifier] to enable granular widget rebuilds.
class OiAfFieldController<TField extends Enum> extends ChangeNotifier {
  OiAfFieldController({
    required OiAfFieldDefinition<TField, dynamic> definition,
    required Object? initialValue,
  }) : _definition = definition,
       _value = initialValue,
       _initialValue = initialValue;

  /// The field definition, stored with `dynamic` TValue to avoid invariant
  /// generic cast issues when accessing typed members (validators, equals, derive).
  final OiAfFieldDefinition<TField, dynamic> _definition;

  Object? _value;
  Object? _initialValue;

  bool _isDirty = false;
  bool _isTouched = false;
  bool _isFocused = false;
  bool _isEnabled = true;
  bool _isVisible = true;
  bool _isValidating = false;
  bool _hasUserEdited = false;
  bool _manualOverrideActive = false;

  OiAfFieldValidationPhase _validationPhase = OiAfFieldValidationPhase.pristine;

  final List<String> _validationErrors = [];
  final List<String> _backendErrors = [];
  final List<String> _runtimeErrors = [];

  /// Bumped whenever a validation starts or an in-flight one becomes stale
  /// (new value, hidden, disabled, reset, disposed). A run only applies its
  /// result while its own version is still the current one.
  int _validationVersion = 0;

  /// The arguments of the run in flight, or null when none is.
  _OiAfValidationRun<TField>? _activeRun;

  /// Completes when the run in flight finishes or is cancelled, so superseded
  /// runs can wait for the outcome instead of reporting one of their own.
  Completer<void>? _validationSettled;

  bool _disposed = false;

  String? _displayLabel;
  FocusNode? registeredFocusNode;

  /// Callback to notify the parent form controller of value changes.
  void Function(TField field, {required bool fromUser})? onValueChanged;

  /// Callback to notify the parent form controller of focus changes.
  void Function(TField field, {required bool focused})? onFocusChanged;

  /// Lazy getter for the parent controller's observer (stays in sync).
  OiAfObserver? Function()? observerGetter;

  /// Lazy getter for localized validation messages from the attached form.
  OiAfValidationMessages? Function()? validationMessagesGetter;

  // ── Public getters ─────────────────────────────────────────────────────

  /// The immutable field definition.
  OiAfFieldDefinition<TField, dynamic> get definition => _definition;

  /// The enum key identifying this field.
  TField get field => _definition.field;

  /// The field type.
  OiAfFieldType get type => _definition.type;

  /// The current value (untyped). Use [OiAfFieldBinderMixin.typedValue]
  /// for typed access in widgets.
  Object? get value => _value;

  /// The initial value resolved at construction.
  Object? get initialValue => _initialValue;

  /// Whether the current value differs from the initial value.
  bool get isDirty => _isDirty;

  /// Whether the user has interacted with this field.
  bool get isTouched => _isTouched;

  /// Whether this field currently has focus.
  bool get isFocused => _isFocused;

  /// Whether this field is enabled for interaction.
  bool get isEnabled => _isEnabled;

  /// Whether this field is visible in the UI.
  bool get isVisible => _isVisible;

  /// Whether all validation errors are empty.
  bool get isValid =>
      _validationErrors.isEmpty &&
      _backendErrors.isEmpty &&
      _runtimeErrors.isEmpty;

  /// Whether an async validation is in progress.
  bool get isValidating => _isValidating;

  /// Whether this field has any errors.
  bool get hasErrors => !isValid;

  /// Whether the user has manually edited this field.
  bool get hasUserEdited => _hasUserEdited;

  /// Whether a derived field has been manually overridden.
  bool get isDerived => _definition.derive != null && !_manualOverrideActive;

  /// The first error message, or null.
  String? get primaryError {
    if (_validationErrors.isNotEmpty) return _validationErrors.first;
    if (_backendErrors.isNotEmpty) return _backendErrors.first;
    if (_runtimeErrors.isNotEmpty) return _runtimeErrors.first;
    return null;
  }

  /// All error messages from all buckets.
  List<String> get errors => List.unmodifiable([
    ..._validationErrors,
    ..._backendErrors,
    ..._runtimeErrors,
  ]);

  /// The display label registered by the bound widget.
  String? get displayLabel => _displayLabel;

  /// The focus node registered by the bound widget.

  // ── Value mutation ─────────────────────────────────────────────────────

  /// Sets the field value.
  void setValue(
    Object? value, {
    bool markDirty = true,
    bool markTouched = true,
    bool fromUser = true,
    bool notify = true,
  }) {
    final valueChanged = !_valuesEqual(value, _value);
    if (!valueChanged && !(markTouched && !_isTouched)) {
      return;
    }

    // A validation still running was started for the old value.
    final interrupted = valueChanged ? _cancelValidation() : null;

    _value = value;

    if (markTouched) _isTouched = true;
    if (fromUser) _hasUserEdited = true;

    if (fromUser &&
        _definition.derive != null &&
        _definition.derivedOverrideMode ==
            OiAfDerivedOverrideMode.stopAfterUserEdit) {
      _manualOverrideActive = true;
    }

    if (markDirty) {
      _isDirty = !_valuesEqual(_value, _initialValue);
    }

    if (_definition.clearErrorsOnChange) {
      _validationErrors.clear();
      _runtimeErrors.clear();
    }
    if (fromUser) {
      _backendErrors.clear();
    }

    if (notify) notifyListeners();

    onValueChanged?.call(_definition.field, fromUser: fromUser);

    // Whoever awaits the interrupted run (a submit, for one) needs a verdict
    // on the new value, also when the change itself did not trigger one.
    _restartValidation(interrupted);
  }

  /// Notifies this field's listeners without mutating any state.
  ///
  /// Bound widgets only observe their own field controller, so form-level
  /// batch operations that mutate many fields with `notify: false` must call
  /// this afterwards or the widgets will keep rendering stale values.
  void notifyChanged() => notifyListeners();

  // ── Focus ──────────────────────────────────────────────────────────────

  void setFocused({required bool focused, bool notify = true}) {
    if (_isFocused == focused) return;
    _isFocused = focused;
    if (!focused) {
      _isTouched = true;
    }
    if (notify) notifyListeners();
    onFocusChanged?.call(_definition.field, focused: focused);
  }

  void setTouched({required bool touched, bool notify = true}) {
    if (_isTouched == touched) return;
    _isTouched = touched;
    if (notify) notifyListeners();
  }

  void setEnabled({required bool enabled, bool notify = true}) {
    if (_isEnabled == enabled) return;
    _isEnabled = enabled;
    if (!enabled && _definition.skipValidationWhenDisabled) {
      _cancelValidation();
      _validationErrors.clear();
    }
    if (notify) notifyListeners();
  }

  void setVisible({required bool visible, bool notify = true}) {
    if (_isVisible == visible) return;
    _isVisible = visible;
    _OiAfValidationRun<TField>? interrupted;
    if (!visible) {
      if (_definition.excludeWhenHidden || _definition.clearValueWhenHidden) {
        interrupted = _cancelValidation();
      }
      if (_definition.excludeWhenHidden) {
        _validationErrors.clear();
        _backendErrors.clear();
      }
      if (_definition.clearValueWhenHidden) {
        _value = null;
        _isDirty = false;
      }
      if (_isFocused) {
        _isFocused = false;
      }
    }
    if (notify) notifyListeners();
    // Only starts a run when the field is still validated while hidden and
    // its value was just cleared; otherwise validate() returns right away.
    _restartValidation(interrupted);
  }

  // ── Errors ─────────────────────────────────────────────────────────────

  void setError(String error, {bool notify = true}) {
    _validationErrors
      ..clear()
      ..add(error);
    if (notify) notifyListeners();
  }

  void setErrors(List<String> errors, {bool notify = true}) {
    _validationErrors
      ..clear()
      ..addAll(errors);
    if (notify) notifyListeners();
  }

  void clearErrors({bool notify = true}) {
    final hadErrors = _validationErrors.isNotEmpty || _runtimeErrors.isNotEmpty;
    _validationErrors.clear();
    _runtimeErrors.clear();
    if (hadErrors && notify) notifyListeners();
  }

  void setBackendError(String error, {bool notify = true}) {
    _backendErrors
      ..clear()
      ..add(error);
    if (notify) notifyListeners();
  }

  void setBackendErrors(List<String> errors, {bool notify = true}) {
    _backendErrors
      ..clear()
      ..addAll(errors);
    if (notify) notifyListeners();
  }

  void clearBackendErrors({bool notify = true}) {
    final hadErrors = _backendErrors.isNotEmpty;
    _backendErrors.clear();
    if (hadErrors && notify) notifyListeners();
  }

  // ── Validation ─────────────────────────────────────────────────────────

  /// Whether validation should run for this trigger and mode.
  bool shouldValidateForTrigger(
    OiAfValidationTrigger trigger,
    OiAfValidateMode mode,
  ) {
    if (trigger == OiAfValidationTrigger.submit) return true;
    if (trigger == OiAfValidationTrigger.manual) return true;
    if (trigger == OiAfValidationTrigger.dependencyChange) return true;

    switch (mode) {
      case OiAfValidateMode.disabled:
        return false;
      case OiAfValidateMode.onSubmit:
        return trigger == OiAfValidationTrigger.submit;
      case OiAfValidateMode.onBlur:
        return trigger == OiAfValidationTrigger.blur;
      case OiAfValidateMode.onChange:
        return true;
      case OiAfValidateMode.onBlurThenChange:
        if (trigger == OiAfValidationTrigger.blur) {
          _validationPhase = OiAfFieldValidationPhase.blurredOnce;
          return true;
        }
        if (trigger == OiAfValidationTrigger.change) {
          return _validationPhase.index >=
              OiAfFieldValidationPhase.blurredOnce.index;
        }
        return false;
      case OiAfValidateMode.onInit:
        return true;
    }
  }

  /// Run validation using the definition's validators.
  ///
  /// Resolves to whether the field passed. A run that is overtaken, by a
  /// newer [validate] call or by the value changing underneath it, never
  /// applies its own result: it waits for the validation that replaced it and
  /// resolves to that outcome. A run cancelled without a replacement (field
  /// hidden, disabled, reset or disposed) resolves to whether validation
  /// errors are left on the field; hiding, disabling and resetting clear them.
  Future<bool> validate({
    required OiAfValidateMode effectiveMode,
    required OiAfReader<TField> form,
    OiAfValidationTrigger trigger = OiAfValidationTrigger.manual,
  }) async {
    if (!_isVisible && _definition.excludeWhenHidden) return true;
    if (!_isEnabled && _definition.skipValidationWhenDisabled) return true;
    if (!shouldValidateForTrigger(trigger, effectiveMode)) {
      return isValid;
    }

    _validationVersion++;
    final version = _validationVersion;
    _isValidating = true;
    _activeRun = (effectiveMode: effectiveMode, form: form, trigger: trigger);
    _validationSettled ??= Completer<void>();
    notifyListeners();

    final errors = <String>[];
    var bail = false;

    // Required check
    if (_definition.required) {
      final error = _checkRequired();
      if (error != null) {
        errors.add(error);
        bail = true;
      }
    }

    if (!bail) {
      // Access validators through dynamic to bypass Dart's reified generic
      // invariance check on the List return type.
      final validators = (_definition as dynamic).validators as List;
      for (var i = 0; i < validators.length; i++) {
        final validator = validators[i] as Function;
        if (version != _validationVersion) return _settledResult();

        // Check for bail sentinel
        if (identical(validator, OiAfValidators.bail)) {
          if (errors.isNotEmpty) break;
          continue;
        }

        try {
          // Create the context via dynamic dispatch on the definition so
          // that Dart's reified generics produce the concrete TValue type
          // (e.g. OiAfValidationContext<TField, String>) instead of dynamic.
          final ctx = (_definition as dynamic).createValidationContext(
            value: _value,
            form: form,
            trigger: trigger,
            isRequired: _definition.required,
            isVisible: _isVisible,
            isEnabled: _isEnabled,
            messages: validationMessagesGetter?.call(),
          );
          final result = await (validator as dynamic)(ctx) as String?;
          if (version != _validationVersion) return _settledResult();
          if (result != null) errors.add(result);
        } on Object catch (e, st) {
          errors.add(_resolveValidationFailed());
          observerGetter?.call()?.onValidationCrash(_definition.field, e, st);
        }
      }
    }

    if (version != _validationVersion) return _settledResult();

    _validationErrors
      ..clear()
      ..addAll(errors);
    _endValidation();
    observerGetter?.call()?.onFieldValidated(_definition.field, errors);
    notifyListeners();

    return errors.isEmpty;
  }

  /// The outcome for a run that was overtaken: whatever is left on the field
  /// once no validation is in flight any more.
  Future<bool> _settledResult() async {
    while (_isValidating) {
      await _validationSettled!.future;
    }
    return _validationErrors.isEmpty;
  }

  /// Marks the run in flight as finished and wakes the runs waiting on it.
  void _endValidation() {
    _isValidating = false;
    _activeRun = null;
    _validationSettled?.complete();
    _validationSettled = null;
  }

  /// Makes the result of a validation in flight stale.
  ///
  /// Returns the arguments of the cancelled run, or null when none was
  /// running. Callers notify listeners themselves.
  _OiAfValidationRun<TField>? _cancelValidation() {
    _validationVersion++;
    final run = _activeRun;
    if (_isValidating) _endValidation();
    return run;
  }

  /// Starts [run] over, unless something else already started a validation.
  void _restartValidation(_OiAfValidationRun<TField>? run) {
    if (run == null || _isValidating || _disposed) return;
    unawaited(
      validate(
        effectiveMode: run.effectiveMode,
        form: run.form,
        trigger: run.trigger,
      ),
    );
  }

  String? _checkRequired() {
    final message = _resolveRequiredText();
    if (_value == null) return message;
    if (_value is String && (_value! as String).trim().isEmpty) {
      return message;
    }
    if (_value is List && (_value! as List).isEmpty) {
      return message;
    }
    return null;
  }

  String _resolveRequiredText() {
    final messages = validationMessagesGetter?.call();
    if (messages != null) {
      return messages.resolver.requiredText(messages.context);
    }
    return 'This field is required.';
  }

  String _resolveValidationFailed() {
    final messages = validationMessagesGetter?.call();
    if (messages != null) {
      return messages.resolver.validationFailed(messages.context);
    }
    return 'Validation failed.';
  }

  /// Force the validation phase to blurredOnce (used after submit).
  void promoteValidationPhase() {
    if (_validationPhase == OiAfFieldValidationPhase.pristine) {
      _validationPhase = OiAfFieldValidationPhase.blurredOnce;
    }
  }

  // ── Reset ──────────────────────────────────────────────────────────────

  void reset({bool notify = true}) {
    _value = _initialValue;
    _isDirty = false;
    _isTouched = false;
    _hasUserEdited = false;
    _manualOverrideActive = false;
    _validationErrors.clear();
    _backendErrors.clear();
    _runtimeErrors.clear();
    _validationPhase = OiAfFieldValidationPhase.pristine;
    _cancelValidation();
    if (notify) notifyListeners();
  }

  /// Update the initial value (for rebase).
  void rebaseInitialValue(Object? newInitial, {bool notify = true}) {
    _initialValue = newInitial;
    _value = newInitial;
    _isDirty = false;
    _isTouched = false;
    _hasUserEdited = false;
    _manualOverrideActive = false;
    _validationErrors.clear();
    _backendErrors.clear();
    _runtimeErrors.clear();
    _validationPhase = OiAfFieldValidationPhase.pristine;
    _cancelValidation();
    if (notify) notifyListeners();
  }

  // ── Widget binding ─────────────────────────────────────────────────────

  void attachWidget() {}

  void detachWidget() {
    _displayLabel = null;
    registeredFocusNode = null;
  }

  void registerPresentationMetadata({String? label, String? semanticLabel}) {
    _displayLabel = label ?? semanticLabel;
  }

  void unregisterFocusNode(FocusNode node) {
    if (registeredFocusNode == node) registeredFocusNode = null;
  }

  // ── Disposal ───────────────────────────────────────────────────────────

  /// Async validators and focus callbacks can outlive the controller, so a
  /// notification after [dispose] is dropped instead of throwing.
  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelValidation();
    onValueChanged = null;
    onFocusChanged = null;
    super.dispose();
  }

  // ── Private ────────────────────────────────────────────────────────────

  bool _valuesEqual(Object? a, Object? b) {
    if (_definition.equals != null) return _definition.equals!(a, b);
    if (a is List && b is List) {
      return const DeepCollectionEquality().equals(a, b);
    }
    return a == b;
  }
}
