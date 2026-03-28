import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiTimeOfDay;
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart'
    show OiAfErrorSummary;
import 'package:obers_ui_autoforms/src/definitions/oi_af_field_definition.dart';
import 'package:obers_ui_autoforms/src/diagnostics/oi_af_observer.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_aggregate_state.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_option.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_reader.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_submit_result.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_typedefs.dart';
import 'package:obers_ui_autoforms/src/runtime/controller/oi_af_field_controller.dart';
import 'package:obers_ui_autoforms/src/runtime/graphs/oi_af_condition_tracker.dart';
import 'package:obers_ui_autoforms/src/runtime/graphs/oi_af_dependency_graph.dart';
import 'package:obers_ui_autoforms/src/runtime/graphs/oi_af_focus_graph.dart';

import 'package:obers_ui_autoforms/src/validation/oi_af_form_validation_context.dart';
import 'package:obers_ui_autoforms/src/widgets/aggregate/oi_af_error_summary.dart'
    show OiAfErrorSummary;

/// Error summary item for display in [OiAfErrorSummary].
final class OiAfErrorSummaryItem<TField extends Enum> {
  const OiAfErrorSummaryItem({
    required this.message,
    this.field,
    this.fieldLabel,
    this.isGlobal = false,
  });

  final TField? field;
  final String? fieldLabel;
  final String message;
  final bool isGlobal;
}

/// Abstract base form controller.
///
/// Subclass and implement [defineFields] and [buildData].
///
/// ```dart
/// class MyController extends OiAfController<MyField, MyData> {
///   @override
///   void defineFields() {
///     addTextField(MyField.name, required: true);
///   }
///
///   @override
///   MyData buildData() => MyData(name: getOr(MyField.name, ''));
/// }
/// ```
abstract class OiAfController<TField extends Enum, TData> extends ChangeNotifier
    implements OiAfReader<TField> {
  OiAfController() {
    defineFields();
    _initialized = true;
    _buildDependencyGraph();
    _evaluateAllConditions();
    _computeInitialDerivedFields();
    _validateOnInitFields();
  }

  // ── Internal state ─────────────────────────────────────────────────────

  final Map<TField, OiAfFieldDefinition<TField, dynamic>> _definitions = {};
  final Map<TField, OiAfFieldController<TField>> _fieldControllers = {};
  final List<OiAfFormValidator<TField>> _formValidators = [];

  // Dependency tracking
  final OiAfDependencyGraph<TField> _depGraph = OiAfDependencyGraph<TField>();
  final OiAfConditionTracker<TField> _conditionTracker =
      OiAfConditionTracker<TField>();
  final OiAfFocusGraph<TField> _focusGraph = OiAfFocusGraph<TField>();

  final List<String> _globalErrors = [];
  final List<TField> _fieldOrder = [];

  bool _initialized = false;
  bool _isAttached = false;
  bool _isEnabled = true;
  bool _isSubmitting = false;
  bool _hasSubmitted = false;
  int _submitCount = 0;
  OiAfSubmitResult<TData>? _lastSubmitResult;
  Future<OiAfSubmitResult<TData>>? _activeSubmitFuture;

  OiAfValidateMode _validateMode = OiAfValidateMode.onBlurThenChange;
  bool _submitOnEnterFromLastField = true;
  bool _focusFirstInvalidFieldOnSubmitFailure = true;
  bool _clearGlobalErrorsOnFieldChange = true;

  Future<void> Function(TData data, OiAfController<TField, TData> controller)?
  _onSubmit;
  void Function(
    OiAfSubmitResult<TData> result,
    OiAfController<TField, TData> controller,
  )?
  _onSubmitResult;
  OiAfSubmitErrorMapper<TField, TData>? _errorMapper;

  // ── Lifecycle ──────────────────────────────────────────────────────────

  bool get isInitialized => _initialized;
  bool get isAttached => _isAttached;

  /// Observer for form lifecycle events (logging, analytics, debugging).
  OiAfObserver? observer;

  // ── Aggregate state ────────────────────────────────────────────────────

  bool get isValid =>
      _activeFieldControllers.every((fc) => fc.isValid) &&
      _globalErrors.isEmpty;
  bool get isDirty => _fieldControllers.values.any((fc) => fc.isDirty);
  bool get isTouched => _fieldControllers.values.any((fc) => fc.isTouched);
  bool get isEnabled => _isEnabled;
  bool get isSubmitting => _isSubmitting;
  bool get isValidating =>
      _fieldControllers.values.any((fc) => fc.isValidating);
  bool get hasSubmitted => _hasSubmitted;
  int get submitCount => _submitCount;
  OiAfSubmitResult<TData>? get lastSubmitResult => _lastSubmitResult;

  OiAfAggregateState get aggregateState => OiAfAggregateState(
    isValid: isValid,
    isDirty: isDirty,
    isTouched: isTouched,
    isEnabled: isEnabled,
    isSubmitting: isSubmitting,
    isValidating: isValidating,
    hasSubmitted: hasSubmitted,
    submitCount: submitCount,
    fieldErrorCount: _activeFieldControllers.where((fc) => fc.hasErrors).length,
    globalErrorCount: _globalErrors.length,
  );

  Iterable<OiAfFieldController<TField>> get _activeFieldControllers =>
      _fieldControllers.values.where((fc) => fc.isVisible && fc.isEnabled);

  // ── Field registry ─────────────────────────────────────────────────────

  List<TField> get registeredFields => List.unmodifiable(_fieldOrder);

  OiAfFieldDefinition<TField, dynamic> definitionOf(TField field) {
    final def = _definitions[field];
    assert(def != null, 'Field $field is not registered.');
    return def!;
  }

  // ── Typed value access ─────────────────────────────────────────────────

  @override
  TValue? get<TValue>(TField field) {
    final fc = _fieldControllers[field];
    if (fc == null) return null;
    return fc.value as TValue?;
  }

  @override
  TValue getOr<TValue>(TField field, TValue fallback) {
    return get<TValue>(field) ?? fallback;
  }

  // ── Value mutation ─────────────────────────────────────────────────────

  void set<TValue>(TField field, TValue? value, {bool markDirty = true}) {
    final fc = _fieldControllers[field];
    assert(fc != null, 'Field $field is not registered.');
    fc!.setValue(value, markDirty: markDirty, fromUser: false);
  }

  void patch(
    Map<TField, Object?> values, {
    bool markDirty = true,
    bool validate = false,
  }) {
    for (final entry in values.entries) {
      final fc = _fieldControllers[entry.key];
      if (fc != null) {
        fc.setValue(
          entry.value,
          markDirty: markDirty,
          fromUser: false,
          notify: false,
        );
      }
    }
    notifyListeners();
    if (validate) this.validate();
  }

  void rebase(Map<TField, Object?> values, {bool validate = false}) {
    for (final entry in values.entries) {
      final fc = _fieldControllers[entry.key];
      if (fc != null) {
        fc.rebaseInitialValue(entry.value, notify: false);
      }
    }
    _globalErrors.clear();
    notifyListeners();
    if (validate) this.validate();
  }

  void restore(
    Map<TField, Object?> values, {
    OiAfRestoreMode mode = OiAfRestoreMode.patchCurrent,
    bool validate = false,
  }) {
    switch (mode) {
      case OiAfRestoreMode.patchCurrent:
        patch(values, validate: validate);
      case OiAfRestoreMode.rebaseInitial:
        rebase(values, validate: validate);
    }
  }

  // ── Field state queries ────────────────────────────────────────────────

  @override
  bool isFieldDirty(TField field) => _fieldControllers[field]?.isDirty ?? false;

  bool isFieldTouched(TField field) =>
      _fieldControllers[field]?.isTouched ?? false;

  bool isFieldValid(TField field) => _fieldControllers[field]?.isValid ?? true;

  @override
  bool isFieldEnabled(TField field) =>
      _fieldControllers[field]?.isEnabled ?? true;

  @override
  bool isFieldVisible(TField field) =>
      _fieldControllers[field]?.isVisible ?? true;

  // ── Field state mutation ───────────────────────────────────────────────

  void disableField(TField field) =>
      _fieldControllers[field]?.setEnabled(enabled: false);
  void enableField(TField field) =>
      _fieldControllers[field]?.setEnabled(enabled: true);

  void disable() {
    _isEnabled = false;
    notifyListeners();
  }

  void enable() {
    _isEnabled = true;
    notifyListeners();
  }

  // ── Errors ─────────────────────────────────────────────────────────────

  String? getError(TField field) => _fieldControllers[field]?.primaryError;

  List<String> getErrors(TField field) =>
      _fieldControllers[field]?.errors ?? const [];

  Map<TField, List<String>> getAllFieldErrors() {
    final map = <TField, List<String>>{};
    for (final entry in _fieldControllers.entries) {
      if (entry.value.errors.isNotEmpty) {
        map[entry.key] = entry.value.errors;
      }
    }
    return map;
  }

  List<String> get globalErrors => List.unmodifiable(_globalErrors);

  void setBackendError(TField field, String message) {
    _fieldControllers[field]?.setBackendError(message);
  }

  void setBackendErrors(TField field, List<String> messages) {
    _fieldControllers[field]?.setBackendErrors(messages);
  }

  void setGlobalError(String message) {
    _globalErrors.add(message);
    notifyListeners();
  }

  void clearBackendErrors({TField? field}) {
    if (field != null) {
      _fieldControllers[field]?.clearBackendErrors();
    } else {
      for (final fc in _fieldControllers.values) {
        fc.clearBackendErrors(notify: false);
      }
      notifyListeners();
    }
  }

  void clearErrors({TField? field, bool includeGlobal = true}) {
    if (field != null) {
      _fieldControllers[field]
        ?..clearErrors(notify: false)
        ..clearBackendErrors();
    } else {
      for (final fc in _fieldControllers.values) {
        fc
          ..clearErrors(notify: false)
          ..clearBackendErrors(notify: false);
      }
      if (includeGlobal) _globalErrors.clear();
      notifyListeners();
    }
  }

  // ── Field controller access ────────────────────────────────────────────

  /// Returns the field controller for [field].
  OiAfFieldController<TField> fieldController(TField field) {
    final fc = _fieldControllers[field];
    assert(fc != null, 'Field $field is not registered.');
    return fc!;
  }

  /// Replaces the internal field controller for [field] with [controller].
  ///
  /// Use this to inject a custom field controller that overrides the default
  /// behavior for a specific field. The previous controller is detached and
  /// disposed.
  void overrideFieldController(
    TField field,
    OiAfFieldController<TField> controller,
  ) {
    assert(
      _fieldControllers.containsKey(field),
      'Cannot override controller for unregistered field $field.',
    );
    _fieldControllers[field]!
      ..removeListener(_notifyListeners)
      ..dispose();

    controller
      ..onValueChanged = _handleFieldValueChanged
      ..onFocusChanged = _handleFieldFocusChanged
      ..observerGetter = () => observer;

    _fieldControllers[field] = controller;
    notifyListeners();
  }

  void _notifyListeners() => notifyListeners();

  // ── Validation ─────────────────────────────────────────────────────────

  Future<bool> validate({
    TField? field,
    OiAfValidationTrigger trigger = OiAfValidationTrigger.manual,
  }) async {
    if (field != null) {
      final fc = _fieldControllers[field];
      if (fc == null) return true;
      return fc.validate(
        trigger: trigger,
        effectiveMode: _effectiveValidateMode(field),
        form: this,
      );
    }

    final results = await Future.wait(
      _activeFieldControllers.map(
        (fc) => fc.validate(
          trigger: trigger,
          effectiveMode: _effectiveValidateMode(fc.field),
          form: this,
        ),
      ),
    );

    // Form-level validators
    _globalErrors.clear();
    for (final validator in _formValidators) {
      try {
        final ctx = OiAfFormValidationContext<TField>(
          form: this,
          trigger: trigger,
        );
        final result = await validator(ctx);
        if (result != null) _globalErrors.add(result);
      } on Object {
        _globalErrors.add('Validation failed.');
      }
    }

    notifyListeners();
    return results.every((r) => r) && _globalErrors.isEmpty;
  }

  OiAfValidateMode _effectiveValidateMode(TField field) {
    return _definitions[field]?.validateModeOverride ?? _validateMode;
  }

  // ── Submit ─────────────────────────────────────────────────────────────

  Future<OiAfSubmitResult<TData>> submit() async {
    if (_activeSubmitFuture != null) return _activeSubmitFuture!;

    final future = _executeSubmit();
    _activeSubmitFuture = future;
    try {
      return await future;
    } finally {
      _activeSubmitFuture = null;
    }
  }

  Future<OiAfSubmitResult<TData>> _executeSubmit() async {
    _globalErrors.clear();
    _hasSubmitted = true;
    _submitCount++;
    observer?.onSubmitStarted();

    // Promote all fields so they show errors after submit
    for (final fc in _fieldControllers.values) {
      fc.promoteValidationPhase();
    }

    final isValid = await validate(trigger: OiAfValidationTrigger.submit);

    if (!isValid) {
      final result = OiAfSubmitInvalid<TData>(
        fieldErrors: getAllFieldErrors(),
        globalErrors: List.unmodifiable(_globalErrors),
      );
      _lastSubmitResult = result;
      if (_focusFirstInvalidFieldOnSubmitFailure) focusFirstInvalidField();
      observer?.onSubmitCompleted(result);
      _onSubmitResult?.call(result, this);
      notifyListeners();
      return result;
    }

    late TData data;
    try {
      data = buildData();
    } on Object catch (e, st) {
      final result = OiAfSubmitFailure<TData>(
        error: e,
        stackTrace: st,
        globalErrors: ['Failed to build form data.'],
      );
      _lastSubmitResult = result;
      observer?.onSubmitCompleted(result);
      _onSubmitResult?.call(result, this);
      notifyListeners();
      return result;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      if (_onSubmit != null) {
        await _onSubmit!(data, this);
      }
      final result = OiAfSubmitSuccess<TData>(data);
      _lastSubmitResult = result;
      observer?.onSubmitCompleted(result);
      _onSubmitResult?.call(result, this);
      return result;
    } on Object catch (e, st) {
      var globalErrors = <String>['Submission failed.'];
      if (_errorMapper != null) {
        try {
          final mapped = _errorMapper!(
            OiAfSubmitErrorContext<TField, TData>(
              error: e,
              stackTrace: st,
              data: data,
              controller: this,
            ),
          );
          for (final entry in mapped.fieldErrors.entries) {
            _fieldControllers[entry.key]?.setBackendErrors(
              entry.value,
              notify: false,
            );
          }
          globalErrors = mapped.globalErrors;
        } on Object catch (_) {
          // Error mapper threw — fall back to generic.
        }
      }
      _globalErrors.addAll(globalErrors);
      final result = OiAfSubmitFailure<TData>(
        data: data,
        error: e,
        stackTrace: st,
        globalErrors: globalErrors,
      );
      _lastSubmitResult = result;
      observer?.onSubmitCompleted(result);
      _onSubmitResult?.call(result, this);
      return result;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ── Reset ──────────────────────────────────────────────────────────────

  void reset({OiAfResetMode mode = OiAfResetMode.toInitial}) {
    switch (mode) {
      case OiAfResetMode.toInitial:
        for (final fc in _fieldControllers.values) {
          fc.reset(notify: false);
        }
      case OiAfResetMode.toCurrentPatchedValues:
        for (final fc in _fieldControllers.values) {
          fc.rebaseInitialValue(fc.value, notify: false);
        }
      case OiAfResetMode.clear:
        for (final fc in _fieldControllers.values) {
          fc.rebaseInitialValue(null, notify: false);
        }
    }
    _globalErrors.clear();
    _hasSubmitted = false;
    _lastSubmitResult = null;
    observer?.onFormReset();
    _evaluateAllConditions();
    _computeInitialDerivedFields();
    notifyListeners();
  }

  // ── Export ──────────────────────────────────────────────────────────────

  /// Override to construct the typed data from form values.
  TData buildData();

  Map<String, dynamic> json() {
    final map = <String, dynamic>{};
    for (final entry in _fieldControllers.entries) {
      if (!shouldExportField(entry.key)) continue;
      map[entry.key.name] = entry.value.value;
    }
    return map;
  }

  bool shouldExportField(TField field) {
    final def = _definitions[field];
    if (def == null) return false;
    if (!def.save) return false;
    final fc = _fieldControllers[field]!;
    if (!fc.isVisible && def.excludeWhenHidden) return false;
    return true;
  }

  // ── Focus ──────────────────────────────────────────────────────────────

  void focusField(TField field) {
    _focusGraph.focusField(field, controllers: _fieldControllers);
  }

  void focusFirstAvailableField() {
    _focusGraph.focusFirstAvailable(
      fieldOrder: _fieldOrder,
      controllers: _fieldControllers,
    );
  }

  void focusFirstInvalidField() {
    _focusGraph.focusFirstInvalid(
      fieldOrder: _fieldOrder,
      controllers: _fieldControllers,
    );
  }

  void focusNextField(TField currentField) {
    _focusGraph.focusNext(
      currentField,
      fieldOrder: _fieldOrder,
      controllers: _fieldControllers,
    );
  }

  void focusPreviousField(TField currentField) {
    _focusGraph.focusPrevious(
      currentField,
      fieldOrder: _fieldOrder,
      controllers: _fieldControllers,
    );
  }

  bool isLastFocusableField(TField field) {
    return _focusGraph.isLast(
      field,
      fieldOrder: _fieldOrder,
      controllers: _fieldControllers,
    );
  }

  bool isFirstFocusableField(TField field) {
    return _focusGraph.isFirst(
      field,
      fieldOrder: _fieldOrder,
      controllers: _fieldControllers,
    );
  }

  /// Whether enter on this field should trigger submit.
  bool get submitOnEnterFromLastField => _submitOnEnterFromLastField;

  // ── Error summary ──────────────────────────────────────────────────────

  List<OiAfErrorSummaryItem<TField>> buildErrorSummaryItems() {
    final items = <OiAfErrorSummaryItem<TField>>[];

    // Global errors first
    for (final error in _globalErrors) {
      items.add(OiAfErrorSummaryItem(message: error, isGlobal: true));
    }

    // Field errors in order
    for (final field in _fieldOrder) {
      final fc = _fieldControllers[field]!;
      if (!fc.isVisible || !fc.isEnabled) continue;
      for (final error in fc.errors) {
        items.add(
          OiAfErrorSummaryItem(
            field: field,
            fieldLabel: fc.displayLabel ?? field.name,
            message: error,
          ),
        );
      }
    }

    return items;
  }

  // ── Diagnostics ────────────────────────────────────────────────────────

  Map<String, dynamic> debugSnapshot() {
    return {
      'isValid': isValid,
      'isDirty': isDirty,
      'isTouched': isTouched,
      'isEnabled': isEnabled,
      'isSubmitting': isSubmitting,
      'hasSubmitted': hasSubmitted,
      'submitCount': submitCount,
      'globalErrors': _globalErrors,
      'fields': {
        for (final entry in _fieldControllers.entries)
          entry.key.name: {
            'value': entry.value.value,
            'isDirty': entry.value.isDirty,
            'isTouched': entry.value.isTouched,
            'isEnabled': entry.value.isEnabled,
            'isVisible': entry.value.isVisible,
            'errors': entry.value.errors,
          },
      },
    };
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  REGISTRATION HELPERS — called in defineFields()
  // ═══════════════════════════════════════════════════════════════════════

  /// Override to define all fields for this form.
  @protected
  void defineFields();

  @protected
  void addTextField(
    TField field, {
    String? initialValue,
    bool required = false,
    bool save = true,
    bool clearErrorsOnChange = true,
    bool validateOnInit = false,
    bool excludeWhenHidden = true,
    bool clearValueWhenHidden = false,
    OiAfValidateMode? validateModeOverride,
    List<OiAfValidator<TField, String>> validators = const [],
    List<TField> revalidateWhen = const [],
    OiAfVisibleWhen<TField>? visibleWhen,
    OiAfEnabledWhen<TField>? enabledWhen,
    List<TField> dependsOn = const [],
    OiAfDeriveMode deriveMode = OiAfDeriveMode.onChange,
    OiAfDerivedOverrideMode derivedOverrideMode =
        OiAfDerivedOverrideMode.stopAfterUserEdit,
    OiAfDerivedValue<TField, String>? derive,
  }) {
    final def = OiAfTextFieldDef<TField>(
      field: field,
      initialValue: initialValue,
      required: required,
      save: save,
      clearErrorsOnChange: clearErrorsOnChange,
      validateOnInit: validateOnInit,
      excludeWhenHidden: excludeWhenHidden,
      clearValueWhenHidden: clearValueWhenHidden,
      validateModeOverride: validateModeOverride,
      validators: validators,
      revalidateWhen: revalidateWhen,
      visibleWhen: visibleWhen,
      enabledWhen: enabledWhen,
      dependsOn: dependsOn,
      deriveMode: deriveMode,
      derivedOverrideMode: derivedOverrideMode,
      derive: derive,
    );
    _registerField<String>(def);
  }

  @protected
  void addNumberField(
    TField field, {
    num? initialValue,
    bool required = false,
    bool save = true,
    num? min,
    num? max,
    num step = 1,
    int? decimalPlaces,
    List<OiAfValidator<TField, num>> validators = const [],
    List<TField> revalidateWhen = const [],
    OiAfVisibleWhen<TField>? visibleWhen,
    OiAfEnabledWhen<TField>? enabledWhen,
    List<TField> dependsOn = const [],
    OiAfDeriveMode deriveMode = OiAfDeriveMode.onChange,
    OiAfDerivedOverrideMode derivedOverrideMode =
        OiAfDerivedOverrideMode.stopAfterUserEdit,
    OiAfDerivedValue<TField, num>? derive,
  }) {
    final def = OiAfNumberFieldDef<TField>(
      field: field,
      initialValue: initialValue,
      required: required,
      save: save,
      min: min,
      max: max,
      step: step,
      decimalPlaces: decimalPlaces,
      validators: validators,
      revalidateWhen: revalidateWhen,
      visibleWhen: visibleWhen,
      enabledWhen: enabledWhen,
      dependsOn: dependsOn,
      deriveMode: deriveMode,
      derivedOverrideMode: derivedOverrideMode,
      derive: derive,
    );
    _registerField<num>(def);
  }

  @protected
  void addBoolField(
    TField field, {
    bool? initialValue,
    bool required = false,
    bool save = true,
    bool tristate = false,
    List<OiAfValidator<TField, bool?>> validators = const [],
    List<TField> revalidateWhen = const [],
    OiAfVisibleWhen<TField>? visibleWhen,
    OiAfEnabledWhen<TField>? enabledWhen,
    List<TField> dependsOn = const [],
    OiAfDeriveMode deriveMode = OiAfDeriveMode.onChange,
    OiAfDerivedOverrideMode derivedOverrideMode =
        OiAfDerivedOverrideMode.stopAfterUserEdit,
    OiAfDerivedValue<TField, bool?>? derive,
  }) {
    final def = OiAfBoolFieldDef<TField>(
      field: field,
      initialValue: initialValue,
      required: required,
      save: save,
      tristate: tristate,
      validators: validators,
      revalidateWhen: revalidateWhen,
      visibleWhen: visibleWhen,
      enabledWhen: enabledWhen,
      dependsOn: dependsOn,
      deriveMode: deriveMode,
      derivedOverrideMode: derivedOverrideMode,
      derive: derive,
    );
    _registerField<bool?>(def);
  }

  @protected
  void addSelectField<TValue>(
    TField field, {
    TValue? initialValue,
    List<OiAfOption<TValue>> options = const [],
    bool required = false,
    bool save = true,
    List<OiAfValidator<TField, TValue>> validators = const [],
    List<TField> revalidateWhen = const [],
    OiAfVisibleWhen<TField>? visibleWhen,
    OiAfEnabledWhen<TField>? enabledWhen,
    List<TField> dependsOn = const [],
    OiAfDeriveMode deriveMode = OiAfDeriveMode.onChange,
    OiAfDerivedOverrideMode derivedOverrideMode =
        OiAfDerivedOverrideMode.stopAfterUserEdit,
    OiAfDerivedValue<TField, TValue>? derive,
  }) {
    final def = OiAfSelectFieldDef<TField, TValue>(
      field: field,
      options: options,
      initialValue: initialValue,
      required: required,
      save: save,
      validators: validators,
      revalidateWhen: revalidateWhen,
      visibleWhen: visibleWhen,
      enabledWhen: enabledWhen,
      dependsOn: dependsOn,
      deriveMode: deriveMode,
      derivedOverrideMode: derivedOverrideMode,
      derive: derive,
    );
    _registerField<TValue>(def);
  }

  @protected
  void addMultiSelectField<TValue>(
    TField field, {
    List<TValue>? initialValue,
    List<OiAfOption<TValue>> options = const [],
    bool required = false,
    bool save = true,
    List<OiAfValidator<TField, List<TValue>>> validators = const [],
    List<TField> revalidateWhen = const [],
    OiAfVisibleWhen<TField>? visibleWhen,
    OiAfEnabledWhen<TField>? enabledWhen,
  }) {
    final def = OiAfMultiSelectFieldDef<TField, TValue>(
      field: field,
      options: options,
      initialValue: initialValue,
      required: required,
      save: save,
      validators: validators,
      revalidateWhen: revalidateWhen,
      visibleWhen: visibleWhen,
      enabledWhen: enabledWhen,
    );
    _registerField<List<TValue>>(def);
  }

  @protected
  void addRadioField<TValue>(
    TField field, {
    TValue? initialValue,
    List<OiAfOption<TValue>> options = const [],
    bool required = false,
    bool save = true,
    List<OiAfValidator<TField, TValue>> validators = const [],
    List<TField> revalidateWhen = const [],
    OiAfVisibleWhen<TField>? visibleWhen,
    OiAfEnabledWhen<TField>? enabledWhen,
  }) {
    final def = OiAfRadioFieldDef<TField, TValue>(
      field: field,
      options: options,
      initialValue: initialValue,
      required: required,
      save: save,
      validators: validators,
      revalidateWhen: revalidateWhen,
      visibleWhen: visibleWhen,
      enabledWhen: enabledWhen,
    );
    _registerField<TValue>(def);
  }

  @protected
  void addDateField(
    TField field, {
    DateTime? initialValue,
    DateTime? minDate,
    DateTime? maxDate,
    bool required = false,
    bool save = true,
    List<OiAfValidator<TField, DateTime>> validators = const [],
    List<TField> revalidateWhen = const [],
    OiAfVisibleWhen<TField>? visibleWhen,
    OiAfEnabledWhen<TField>? enabledWhen,
  }) {
    final def = OiAfDateFieldDef<TField>(
      field: field,
      initialValue: initialValue,
      minDate: minDate,
      maxDate: maxDate,
      required: required,
      save: save,
      validators: validators,
      revalidateWhen: revalidateWhen,
      visibleWhen: visibleWhen,
      enabledWhen: enabledWhen,
    );
    _registerField<DateTime>(def);
  }

  @protected
  void addTimeField(
    TField field, {
    OiTimeOfDay? initialValue,
    bool required = false,
    bool save = true,
    List<OiAfValidator<TField, OiTimeOfDay>> validators = const [],
    OiAfVisibleWhen<TField>? visibleWhen,
    OiAfEnabledWhen<TField>? enabledWhen,
  }) {
    final def = OiAfTimeFieldDef<TField>(
      field: field,
      initialValue: initialValue,
      required: required,
      save: save,
      validators: validators,
      visibleWhen: visibleWhen,
      enabledWhen: enabledWhen,
    );
    _registerField<OiTimeOfDay>(def);
  }

  @protected
  void addDateTimeField(
    TField field, {
    DateTime? initialValue,
    DateTime? minDate,
    DateTime? maxDate,
    bool required = false,
    bool save = true,
    List<OiAfValidator<TField, DateTime>> validators = const [],
    OiAfVisibleWhen<TField>? visibleWhen,
    OiAfEnabledWhen<TField>? enabledWhen,
  }) {
    final def = OiAfDateTimeFieldDef<TField>(
      field: field,
      initialValue: initialValue,
      minDate: minDate,
      maxDate: maxDate,
      required: required,
      save: save,
      validators: validators,
      visibleWhen: visibleWhen,
      enabledWhen: enabledWhen,
    );
    _registerField<DateTime>(def);
  }

  @protected
  void addDatePickerField(
    TField field, {
    DateTime? initialValue,
    DateTime? minDate,
    DateTime? maxDate,
    bool required = false,
    bool save = true,
    List<OiAfValidator<TField, DateTime>> validators = const [],
    OiAfVisibleWhen<TField>? visibleWhen,
    OiAfEnabledWhen<TField>? enabledWhen,
  }) {
    final def = OiAfDatePickerFieldDef<TField>(
      field: field,
      initialValue: initialValue,
      minDate: minDate,
      maxDate: maxDate,
      required: required,
      save: save,
      validators: validators,
      visibleWhen: visibleWhen,
      enabledWhen: enabledWhen,
    );
    _registerField<DateTime>(def);
  }

  @protected
  void addDateRangePickerField(
    TField field, {
    (DateTime, DateTime)? initialValue,
    DateTime? minDate,
    DateTime? maxDate,
    bool required = false,
    bool save = true,
    List<OiAfValidator<TField, (DateTime, DateTime)>> validators = const [],
    OiAfVisibleWhen<TField>? visibleWhen,
    OiAfEnabledWhen<TField>? enabledWhen,
  }) {
    final def = OiAfDateRangePickerFieldDef<TField>(
      field: field,
      initialValue: initialValue,
      minDate: minDate,
      maxDate: maxDate,
      required: required,
      save: save,
      validators: validators,
      visibleWhen: visibleWhen,
      enabledWhen: enabledWhen,
    );
    _registerField<(DateTime, DateTime)>(def);
  }

  @protected
  void addTimePickerField(
    TField field, {
    OiTimeOfDay? initialValue,
    bool use24Hour = true,
    int minuteInterval = 1,
    bool required = false,
    bool save = true,
    List<OiAfValidator<TField, OiTimeOfDay>> validators = const [],
    OiAfVisibleWhen<TField>? visibleWhen,
    OiAfEnabledWhen<TField>? enabledWhen,
  }) {
    final def = OiAfTimePickerFieldDef<TField>(
      field: field,
      initialValue: initialValue,
      use24Hour: use24Hour,
      minuteInterval: minuteInterval,
      required: required,
      save: save,
      validators: validators,
      visibleWhen: visibleWhen,
      enabledWhen: enabledWhen,
    );
    _registerField<OiTimeOfDay>(def);
  }

  @protected
  void addTagField(
    TField field, {
    List<String>? initialValue,
    int? maxTags,
    bool required = false,
    bool save = true,
    List<OiAfValidator<TField, List<String>>> validators = const [],
    OiAfVisibleWhen<TField>? visibleWhen,
    OiAfEnabledWhen<TField>? enabledWhen,
  }) {
    final def = OiAfTagFieldDef<TField>(
      field: field,
      initialValue: initialValue,
      maxTags: maxTags,
      required: required,
      save: save,
      validators: validators,
      visibleWhen: visibleWhen,
      enabledWhen: enabledWhen,
    );
    _registerField<List<String>>(def);
  }

  @protected
  void addSliderField(
    TField field, {
    double? initialValue,
    double min = 0,
    double max = 100,
    int? divisions,
    bool isRange = false,
    bool required = false,
    bool save = true,
    List<OiAfValidator<TField, double>> validators = const [],
    OiAfVisibleWhen<TField>? visibleWhen,
    OiAfEnabledWhen<TField>? enabledWhen,
  }) {
    final def = OiAfSliderFieldDef<TField>(
      field: field,
      initialValue: initialValue,
      min: min,
      max: max,
      divisions: divisions,
      isRange: isRange,
      required: required,
      save: save,
      validators: validators,
      visibleWhen: visibleWhen,
      enabledWhen: enabledWhen,
    );
    _registerField<double>(def);
  }

  @protected
  void addColorField(
    TField field, {
    Color? initialValue,
    bool required = false,
    bool save = true,
    List<OiAfValidator<TField, Color>> validators = const [],
    OiAfVisibleWhen<TField>? visibleWhen,
    OiAfEnabledWhen<TField>? enabledWhen,
  }) {
    final def = OiAfColorFieldDef<TField>(
      field: field,
      initialValue: initialValue,
      required: required,
      save: save,
      validators: validators,
      visibleWhen: visibleWhen,
      enabledWhen: enabledWhen,
    );
    _registerField<Color>(def);
  }

  @protected
  void addFileField(
    TField field, {
    List<OiAfFileValue>? initialValue,
    int? maxFiles,
    List<String>? acceptedTypes,
    bool required = false,
    bool save = true,
    List<OiAfValidator<TField, List<OiAfFileValue>>> validators = const [],
    OiAfVisibleWhen<TField>? visibleWhen,
    OiAfEnabledWhen<TField>? enabledWhen,
  }) {
    final def = OiAfFileFieldDef<TField>(
      field: field,
      initialValue: initialValue,
      maxFiles: maxFiles,
      acceptedTypes: acceptedTypes,
      required: required,
      save: save,
      validators: validators,
      visibleWhen: visibleWhen,
      enabledWhen: enabledWhen,
    );
    _registerField<List<OiAfFileValue>>(def);
  }

  @protected
  void addSegmentedControlField<TValue>(
    TField field, {
    TValue? initialValue,
    List<OiAfOption<TValue>> segments = const [],
    bool required = false,
    bool save = true,
    List<OiAfValidator<TField, TValue>> validators = const [],
    OiAfVisibleWhen<TField>? visibleWhen,
    OiAfEnabledWhen<TField>? enabledWhen,
  }) {
    final def = OiAfSegmentedControlFieldDef<TField, TValue>(
      field: field,
      segments: segments,
      initialValue: initialValue,
      required: required,
      save: save,
      validators: validators,
      visibleWhen: visibleWhen,
      enabledWhen: enabledWhen,
    );
    _registerField<TValue>(def);
  }

  @protected
  void addComboBoxField<TValue>(
    TField field, {
    TValue? initialValue,
    List<OiAfOption<TValue>> options = const [],
    bool multiSelect = false,
    bool required = false,
    bool save = true,
    List<OiAfValidator<TField, TValue>> validators = const [],
    OiAfVisibleWhen<TField>? visibleWhen,
    OiAfEnabledWhen<TField>? enabledWhen,
  }) {
    final def = OiAfComboBoxFieldDef<TField, TValue>(
      field: field,
      options: options,
      multiSelect: multiSelect,
      initialValue: initialValue,
      required: required,
      save: save,
      validators: validators,
      visibleWhen: visibleWhen,
      enabledWhen: enabledWhen,
    );
    _registerField<TValue>(def);
  }

  @protected
  void addRichTextField(
    TField field, {
    String? initialValue,
    bool required = false,
    bool save = true,
    List<OiAfValidator<TField, String>> validators = const [],
    List<TField> revalidateWhen = const [],
    OiAfVisibleWhen<TField>? visibleWhen,
    OiAfEnabledWhen<TField>? enabledWhen,
    List<TField> dependsOn = const [],
    OiAfDeriveMode deriveMode = OiAfDeriveMode.onChange,
    OiAfDerivedOverrideMode derivedOverrideMode =
        OiAfDerivedOverrideMode.stopAfterUserEdit,
    OiAfDerivedValue<TField, String>? derive,
  }) {
    final def = OiAfRichTextFieldDef<TField>(
      field: field,
      initialValue: initialValue,
      required: required,
      save: save,
      validators: validators,
      revalidateWhen: revalidateWhen,
      visibleWhen: visibleWhen,
      enabledWhen: enabledWhen,
      dependsOn: dependsOn,
      deriveMode: deriveMode,
      derivedOverrideMode: derivedOverrideMode,
      derive: derive,
    );
    _registerField<String>(def);
  }

  @protected
  void addArrayField<TItem>(
    TField field, {
    required TItem Function() createEmpty,
    List<TItem>? initialValue,
    int? minItems,
    int? maxItems,
    bool required = false,
    bool save = true,
    List<OiAfValidator<TField, List<TItem>>> validators = const [],
    List<TField> revalidateWhen = const [],
    OiAfVisibleWhen<TField>? visibleWhen,
    OiAfEnabledWhen<TField>? enabledWhen,
  }) {
    final def = OiAfArrayFieldDef<TField, TItem>(
      field: field,
      createEmpty: createEmpty,
      initialValue: initialValue,
      minItems: minItems,
      maxItems: maxItems,
      required: required,
      save: save,
      validators: validators,
      revalidateWhen: revalidateWhen,
      visibleWhen: visibleWhen,
      enabledWhen: enabledWhen,
    );
    _registerField<List<TItem>>(def);
  }

  @protected
  void addFormValidator(OiAfFormValidator<TField> validator) {
    _formValidators.add(validator);
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  INTERNAL REGISTRATION
  // ═══════════════════════════════════════════════════════════════════════

  void _registerField<TValue>(OiAfFieldDefinition<TField, TValue> definition) {
    assert(
      !_definitions.containsKey(definition.field),
      'Duplicate field registration: ${definition.field}',
    );
    assert(
      definition.derive == null || definition.dependsOn.isNotEmpty,
      'Derived field ${definition.field} must specify dependsOn.',
    );

    _definitions[definition.field] =
        definition as OiAfFieldDefinition<TField, dynamic>;
    _fieldOrder.add(definition.field);

    final fc =
        OiAfFieldController<TField>(
            definition: definition,
            initialValue: definition.initialValue,
          )
          ..onValueChanged = _handleFieldValueChanged
          ..onFocusChanged = _handleFieldFocusChanged
          ..observerGetter = () => observer;

    _fieldControllers[definition.field] = fc;
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  INTERNAL — DEPENDENCY GRAPH
  // ═══════════════════════════════════════════════════════════════════════

  void _buildDependencyGraph() {
    _depGraph.build(definitions: _definitions, fieldOrder: _fieldOrder);
  }

  void _evaluateAllConditions() {
    _conditionTracker.evaluateAll(
      reader: this,
      definitions: _definitions,
      controllers: _fieldControllers,
    );
  }

  void _computeInitialDerivedFields() {
    // Use topologically sorted order so dependencies are computed before
    // their dependents.
    for (final field in _depGraph.sortedOrder) {
      final def = _definitions[field]!;
      if (def.deriveMode != OiAfDeriveMode.onSubmit) {
        final value = def.derive!(this);
        _fieldControllers[field]!.setValue(
          value,
          markDirty: false,
          markTouched: false,
          fromUser: false,
          notify: false,
        );
      }
    }
  }

  void _validateOnInitFields() {
    for (final field in _fieldOrder) {
      final def = _definitions[field]!;
      if (def.validateOnInit) {
        _fieldControllers[field]!.validate(
          trigger: OiAfValidationTrigger.init,
          effectiveMode: OiAfValidateMode.onInit,
          form: this,
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  INTERNAL — FIELD CHANGE HANDLING
  // ═══════════════════════════════════════════════════════════════════════

  void _handleFieldValueChanged(TField field, {required bool fromUser}) {
    observer?.onFieldValueChanged(field, null, _fieldControllers[field]?.value);

    if (_clearGlobalErrorsOnFieldChange && fromUser) {
      _globalErrors.clear();
    }

    // Re-evaluate conditions that depend on this field
    _reevaluateConditionsFor(field);

    // Recompute derived fields that depend on this field
    _recomputeDerivedFieldsFor(field);

    // Revalidate fields that have revalidateWhen containing this field
    _revalidateFieldsFor(field);

    // Validate this field based on mode
    final effectiveMode = _effectiveValidateMode(field);
    _fieldControllers[field]!.validate(
      trigger: OiAfValidationTrigger.change,
      effectiveMode: effectiveMode,
      form: this,
    );

    notifyListeners();
  }

  void _handleFieldFocusChanged(TField field, {required bool focused}) {
    if (!focused) {
      // Blur — trigger validation
      _fieldControllers[field]!.validate(
        trigger: OiAfValidationTrigger.blur,
        effectiveMode: _effectiveValidateMode(field),
        form: this,
      );
    }
    notifyListeners();
  }

  void _reevaluateConditionsFor(TField changedField) {
    _conditionTracker.reevaluateFor(
      changedField: changedField,
      reader: this,
      definitions: _definitions,
      controllers: _fieldControllers,
    );
  }

  void _recomputeDerivedFieldsFor(TField changedField) {
    final dependents = _depGraph.dependentsOf(changedField);
    if (dependents.isEmpty) return;

    for (final dependent in dependents) {
      final def = _definitions[dependent]!;
      final fc = _fieldControllers[dependent]!;
      if (def.derive == null) continue;
      if (fc.hasUserEdited &&
          def.derivedOverrideMode ==
              OiAfDerivedOverrideMode.stopAfterUserEdit) {
        continue;
      }
      if (def.deriveMode == OiAfDeriveMode.onSubmit) continue;

      final value = def.derive!(this);
      fc.setValue(value, markTouched: false, fromUser: false);
    }
  }

  void _revalidateFieldsFor(TField changedField) {
    for (final def in _definitions.values) {
      if (def.revalidateWhen.contains(changedField)) {
        _fieldControllers[def.field]!.validate(
          trigger: OiAfValidationTrigger.dependencyChange,
          effectiveMode: _effectiveValidateMode(def.field),
          form: this,
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  ATTACHMENT (called by OiAfForm)
  // ═══════════════════════════════════════════════════════════════════════

  void attach({
    required OiAfValidateMode validateMode,
    required bool submitOnEnterFromLastField,
    required bool focusFirstInvalidFieldOnSubmitFailure,
    required bool clearGlobalErrorsOnFieldChange,
    required bool enabled,
    Future<void> Function(TData, OiAfController<TField, TData>)? onSubmit,
    void Function(OiAfSubmitResult<TData>, OiAfController<TField, TData>)?
    onSubmitResult,
    OiAfSubmitErrorMapper<TField, TData>? errorMapper,
  }) {
    assert(!_isAttached, 'Controller already attached to a form.');
    _isAttached = true;
    _validateMode = validateMode;
    _submitOnEnterFromLastField = submitOnEnterFromLastField;
    _focusFirstInvalidFieldOnSubmitFailure =
        focusFirstInvalidFieldOnSubmitFailure;
    _clearGlobalErrorsOnFieldChange = clearGlobalErrorsOnFieldChange;
    _isEnabled = enabled;
    _onSubmit = onSubmit;
    _onSubmitResult = onSubmitResult;
    _errorMapper = errorMapper;
  }

  void detach() {
    _isAttached = false;
    _onSubmit = null;
    _onSubmitResult = null;
    _errorMapper = null;
  }
}
