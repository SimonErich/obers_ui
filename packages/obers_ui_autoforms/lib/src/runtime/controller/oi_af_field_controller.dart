import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import 'package:obers_ui_autoforms/src/definitions/oi_af_field_definition.dart';
import 'package:obers_ui_autoforms/src/diagnostics/oi_af_observer.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_reader.dart';
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

  int _validationVersion = 0;

  String? _displayLabel;
  FocusNode? registeredFocusNode;

  /// Callback to notify the parent form controller of value changes.
  void Function(TField field, {required bool fromUser})? onValueChanged;

  /// Callback to notify the parent form controller of focus changes.
  void Function(TField field, {required bool focused})? onFocusChanged;

  /// Lazy getter for the parent controller's observer (stays in sync).
  OiAfObserver? Function()? observerGetter;

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
    if (_valuesEqual(value, _value) && !(markTouched && !_isTouched)) {
      return;
    }

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
  }

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
      _validationErrors.clear();
    }
    if (notify) notifyListeners();
  }

  void setVisible({required bool visible, bool notify = true}) {
    if (_isVisible == visible) return;
    _isVisible = visible;
    if (!visible) {
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
        if (version != _validationVersion) {
          _isValidating = false;
          notifyListeners();
          return false;
        }

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
          );
          final result = await (validator as dynamic)(ctx) as String?;
          if (version != _validationVersion) {
            _isValidating = false;
            notifyListeners();
            return false;
          }
          if (result != null) errors.add(result);
        } on Object catch (e, st) {
          errors.add('Validation failed.');
          observerGetter?.call()?.onValidationCrash(_definition.field, e, st);
        }
      }
    }

    if (version == _validationVersion) {
      _validationErrors
        ..clear()
        ..addAll(errors);
      _isValidating = false;
      observerGetter?.call()?.onFieldValidated(_definition.field, errors);
      notifyListeners();
    }

    return errors.isEmpty;
  }

  String? _checkRequired() {
    if (_value == null) return 'This field is required.';
    if (_value is String && (_value! as String).trim().isEmpty) {
      return 'This field is required.';
    }
    if (_value is List && (_value! as List).isEmpty) {
      return 'This field is required.';
    }
    return null;
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
    _validationVersion++;
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
    _validationVersion++;
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

  // ── Private ────────────────────────────────────────────────────────────

  bool _valuesEqual(Object? a, Object? b) {
    if (_definition.equals != null) return _definition.equals!(a, b);
    if (a is List && b is List) {
      return const DeepCollectionEquality().equals(a, b);
    }
    return a == b;
  }
}
