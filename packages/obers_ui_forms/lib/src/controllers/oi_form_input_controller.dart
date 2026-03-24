import 'package:flutter/foundation.dart';
import 'package:obers_ui_forms/src/validation/oi_form_validator.dart';
import 'package:obers_ui_forms/src/validation/oi_form_watch_mode.dart';

/// Controller for a single form field.
///
/// Manages value storage, dirty tracking, validation, enabled/disabled state,
/// and value transformers for one field within a form controller.
///
/// ```dart
/// final nameController = OiFormInputController<String>(
///   required: true,
///   validation: [OiFormValidation.minLength(3)],
/// );
/// ```
class OiFormInputController<T> extends ChangeNotifier {
  OiFormInputController({
    T? initialValue,
    this.required = false,
    List<OiFormValidator<T>>? validation,
    this.getter,
    this.setter,
    this.options,
    this.optionQuery,
    this.initFetch = true,
    this.watch,
    this.watchMode = OiFormWatchMode.onChange,
    this.computedValue,
    this.save = true,
    bool enabled = true,
    this.clearErrorOnChange = true,
    this.validateOnChange = false,
    this.validateOnBlur = false,
  }) : _value = initialValue,
       _initialValue = initialValue,
       _enabled = enabled,
       validation = validation ?? [];

  /// Whether this field is required.
  final bool required;

  /// List of validators to run on this field.
  final List<OiFormValidator<T>> validation;

  /// Optional getter transformer applied when reading the value.
  final T Function(T? value)? getter;

  /// Optional setter transformer applied when writing the value.
  final T Function(T? value)? setter;

  /// Static options for select-type fields.
  final List<T>? options;

  /// Async option query for search-based selects.
  final Future<List<T>> Function(String input)? optionQuery;

  /// Whether to fetch options on init (default: true).
  final bool initFetch;

  /// List of field keys to watch for computed fields.
  final List<Enum>? watch;

  /// When to re-evaluate a computed field.
  final OiFormWatchMode watchMode;

  /// Callback to compute this field's value from the form controller.
  final T Function(dynamic controller)? computedValue;

  /// Whether to include this field in getData()/json() output.
  final bool save;

  /// Whether to clear errors when the value changes (default: true).
  final bool clearErrorOnChange;

  /// Whether to validate on every value change.
  final bool validateOnChange;

  /// Whether to validate when the field loses focus.
  final bool validateOnBlur;

  T? _value;
  T? _initialValue;
  bool _enabled;
  List<String> _errors = [];
  bool _isValidating = false;

  /// The current field value, applying getter transform if present.
  T? get value => getter != null ? getter!(_value) : _value;

  /// The raw stored value without getter transform.
  T? get rawValue => _value;

  /// The initial value at creation or last reset.
  T? get initialValue => _initialValue;

  /// Whether the field is enabled.
  bool get enabled => _enabled;

  /// Whether the value has changed from the initial value.
  bool get isDirty => _value != _initialValue;

  /// Current validation errors for this field.
  List<String> get errors => List.unmodifiable(_errors);

  /// Whether the field has no validation errors and passes required check.
  bool get isValid {
    if (required &&
        (_value == null || (_value is String && (_value! as String).isEmpty))) {
      return false;
    }
    return _errors.isEmpty;
  }

  /// Whether an async validation is currently running.
  bool get isValidating => _isValidating;

  /// Whether this is a computed/virtual field.
  bool get isComputed => computedValue != null;

  /// Set the field value, applying setter transform if present.
  void setValue(T? value) {
    final transformed = setter != null ? setter!(value) : value;
    if (_value == transformed) return;
    _value = transformed;
    if (clearErrorOnChange) _errors = [];
    notifyListeners();
  }

  /// Set the initial value (used during form controller registration).
  void setInitialValue(T? value) {
    _initialValue = value;
    _value = value;
  }

  /// Set the enabled state.
  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    notifyListeners();
  }

  /// Set validation errors directly.
  void setErrors(List<String> errors) {
    _errors = List.of(errors);
    notifyListeners();
  }

  /// Add a single error message.
  void addError(String error) {
    _errors = [..._errors, error];
    notifyListeners();
  }

  /// Clear all errors.
  void clearErrors() {
    if (_errors.isEmpty) return;
    _errors = [];
    notifyListeners();
  }

  /// Run synchronous validators and return collected error messages.
  List<String> validateSync(dynamic controller) {
    final errors = <String>[];

    if (required &&
        (_value == null || (_value is String && (_value! as String).isEmpty))) {
      errors.add('This field is required');
    }

    for (final validator in validation) {
      if (validator is OiSyncFormValidator<T>) {
        final error = validator.validate(_value, controller);
        if (error != null) errors.add(error);
      }
    }

    _errors = errors;
    notifyListeners();
    return errors;
  }

  /// Set the async validating state.
  set isValidating(bool value) {
    if (_isValidating == value) return;
    _isValidating = value;
    notifyListeners();
  }

  /// Reset the field to its initial value and clear errors.
  void reset() {
    _value = _initialValue;
    _errors = [];
    _isValidating = false;
    notifyListeners();
  }
}
