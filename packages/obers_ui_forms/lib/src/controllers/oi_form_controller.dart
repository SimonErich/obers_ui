import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:obers_ui_forms/src/controllers/oi_form_input_controller.dart';
import 'package:obers_ui_forms/src/validation/oi_form_validator.dart';
import 'package:obers_ui_forms/src/validation/oi_form_watch_mode.dart';

/// Type-safe form controller with enum-keyed field access.
///
/// Extend this class and override [inputs] to define your form fields:
///
/// ```dart
/// enum SignupFields { name, email, password }
///
/// class SignupFormController extends OiFormController<SignupFields> {
///   @override
///   Map<SignupFields, OiFormInputController<dynamic>> inputs() => {
///     SignupFields.name: OiFormInputController<String>(required: true),
///     SignupFields.email: OiFormInputController<String>(
///       validation: [OiFormValidation.email()],
///     ),
///   };
/// }
/// ```
abstract class OiFormController<E extends Enum> extends ChangeNotifier {
  OiFormController() {
    _registerFields();
  }

  final Map<E, OiFormInputController<dynamic>> _fields = {};
  final Map<E, VoidCallback> _fieldListeners = {};
  bool _enabled = true;

  /// Override this to define form fields and their configurations.
  Map<E, OiFormInputController<dynamic>> inputs();

  void _registerFields() {
    final fieldMap = inputs();

    // First pass: register all fields
    for (final entry in fieldMap.entries) {
      _fields[entry.key] = entry.value;
      final listener = () => _onFieldChanged(entry.key);
      _fieldListeners[entry.key] = listener;
      entry.value.addListener(listener);
    }

    // Second pass: validate watch dependencies and set up computed fields
    for (final entry in _fields.entries) {
      final field = entry.value;
      if (field.isComputed && field.watch != null) {
        _validateWatchDependencies(entry.key, field.watch!);

        // Compute initial value if watchMode is onInit
        if (field.watchMode == OiFormWatchMode.onInit) {
          _recomputeField(entry.key, field);
        }
      }
    }
  }

  void _validateWatchDependencies(E key, List<Enum> watchKeys) {
    final visited = <Enum>{key};
    final queue = List<Enum>.from(watchKeys);

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (visited.contains(current)) {
        throw StateError(
          'Circular watch dependency detected: '
          '$key depends on $current which creates a cycle',
        );
      }
      visited.add(current);
      final field = _fields[current];
      if (field != null && field.watch != null) {
        queue.addAll(field.watch!);
      }
    }
  }

  void _recomputeField(E key, OiFormInputController<dynamic> field) {
    if (field.computedValue != null) {
      final newValue = field.computedValue!(this);
      field.setValue(newValue);
    }
  }

  void _onFieldChanged(E key) {
    // Trigger recomputation of computed fields that watch this key
    for (final entry in _fields.entries) {
      final field = entry.value;
      if (field.isComputed &&
          field.watch != null &&
          field.watch!.contains(key) &&
          field.watchMode == OiFormWatchMode.onChange) {
        _recomputeField(entry.key, field);
      }
    }
    notifyListeners();
  }

  /// Get a typed value for the given field key.
  T? get<T>(E key) {
    final field = _fields[key];
    assert(field != null, 'No field registered for key: $key');
    return field!.value as T?;
  }

  /// Set a typed value for the given field key.
  void set<T>(E key, T? value) {
    final field = _fields[key];
    assert(field != null, 'No field registered for key: $key');
    // ignore: avoid_dynamic_calls
    (field! as OiFormInputController<T>).setValue(value);
  }

  /// Set multiple field values at once. Notifies listeners once.
  void setMultiple(Map<E, dynamic> values) {
    for (final entry in values.entries) {
      final field = _fields[entry.key];
      if (field != null) {
        // Temporarily remove listener to batch notifications
        final listener = _fieldListeners[entry.key]!;
        field.removeListener(listener);
        field.setValue(entry.value);
        field.addListener(listener);
      }
    }
    notifyListeners();
  }

  /// Get all saved field values as a map keyed by enum.
  Map<E, dynamic> getData() {
    final data = <E, dynamic>{};
    for (final entry in _fields.entries) {
      if (entry.value.save) {
        data[entry.key] = entry.value.value;
      }
    }
    return data;
  }

  /// Get the initial values of all fields.
  Map<E, dynamic> getInitial() {
    final data = <E, dynamic>{};
    for (final entry in _fields.entries) {
      data[entry.key] = entry.value.initialValue;
    }
    return data;
  }

  /// Export form data as JSON-compatible map keyed by enum name.
  Map<String, dynamic> json() {
    final data = <String, dynamic>{};
    for (final entry in _fields.entries) {
      if (entry.value.save) {
        data[entry.key.name] = entry.value.value;
      }
    }
    return data;
  }

  /// Export form data as a JSON string.
  String jsonString() => jsonEncode(json());

  /// Run all field validators synchronously. Returns true if all valid.
  bool validate() {
    var allValid = true;
    for (final field in _fields.values) {
      final errors = field.validateSync(this);
      if (errors.isNotEmpty) allValid = false;
    }
    return allValid;
  }

  /// Run all validators (sync + async). Returns true if all valid.
  ///
  /// Waits for async validators to complete before returning.
  Future<bool> validateAsync() async {
    // Run sync first
    validate();

    // Then run async validators
    final futures = <Future<void>>[];
    for (final field in _fields.values) {
      futures.add(field.validateAsync(this));
    }
    await Future.wait(futures);

    return isValid;
  }

  /// Submit the form: validate all fields, then call [onSubmit] if valid.
  ///
  /// If async validators are running, waits for them to complete.
  Future<bool> submit(
    void Function(Map<E, dynamic> data, OiFormController<E> controller)?
    onSubmit,
  ) async {
    final valid = await validateAsync();
    if (valid && onSubmit != null) {
      onSubmit(getData(), this);
    }
    return valid;
  }

  /// Reset all fields to their initial values.
  void reset() {
    for (final field in _fields.values) {
      field.reset();
    }
  }

  /// Get the error messages for a specific field.
  List<String> getError(E key) {
    final field = _fields[key];
    assert(field != null, 'No field registered for key: $key');
    return field!.errors;
  }

  /// Inject an error message on a specific field.
  void setError(E key, String message) {
    final field = _fields[key];
    assert(field != null, 'No field registered for key: $key');
    field!.addError(message);
  }

  /// Get all errors across all fields.
  Map<E, List<String>> getErrors() {
    final errors = <E, List<String>>{};
    for (final entry in _fields.entries) {
      if (entry.value.errors.isNotEmpty) {
        errors[entry.key] = entry.value.errors;
      }
    }
    return errors;
  }

  /// Whether all fields are valid (no errors and required fields filled).
  bool get isValid {
    for (final field in _fields.values) {
      if (!field.isValid) return false;
    }
    return true;
  }

  /// Whether any field has been modified from its initial value.
  bool get isDirty {
    for (final field in _fields.values) {
      if (field.isDirty) return true;
    }
    return false;
  }

  /// Whether any field is currently running async validation.
  bool get isValidating {
    for (final field in _fields.values) {
      if (field.isValidating) return true;
    }
    return false;
  }

  /// Whether a specific field is valid.
  bool isFieldValid(E key) {
    final field = _fields[key];
    assert(field != null, 'No field registered for key: $key');
    return field!.isValid;
  }

  /// Whether a specific field has been modified.
  bool isFieldDirty(E key) {
    final field = _fields[key];
    assert(field != null, 'No field registered for key: $key');
    return field!.isDirty;
  }

  /// Whether the form is enabled.
  bool get enabled => _enabled;

  /// Enable the entire form.
  void enable() {
    _enabled = true;
    for (final field in _fields.values) {
      field.enabled = true;
    }
  }

  /// Disable the entire form.
  void disable() {
    _enabled = false;
    for (final field in _fields.values) {
      field.enabled = false;
    }
  }

  /// Enable a specific field.
  void enableField(E key) {
    final field = _fields[key];
    assert(field != null, 'No field registered for key: $key');
    field!.enabled = true;
  }

  /// Disable a specific field.
  void disableField(E key) {
    final field = _fields[key];
    assert(field != null, 'No field registered for key: $key');
    field!.enabled = false;
  }

  /// Replace the input controller for a specific field.
  void overwriteInputController(
    E key,
    OiFormInputController<dynamic> controller,
  ) {
    final oldField = _fields[key];
    if (oldField != null) {
      final listener = _fieldListeners[key];
      if (listener != null) oldField.removeListener(listener);
    }
    _fields[key] = controller;
    final listener = () => _onFieldChanged(key);
    _fieldListeners[key] = listener;
    controller.addListener(listener);
    notifyListeners();
  }

  /// Get the input controller for a specific field.
  OiFormInputController<dynamic> getInputController(E key) {
    final field = _fields[key];
    assert(field != null, 'No field registered for key: $key');
    return field!;
  }

  /// All registered field keys.
  Iterable<E> get fieldKeys => _fields.keys;

  /// Whether a field has async validators.
  bool hasAsyncValidators(E key) {
    final field = _fields[key];
    if (field == null) return false;
    return field.validation.any((v) => v is OiAsyncFormValidator);
  }

  @override
  void dispose() {
    for (final entry in _fields.entries) {
      final listener = _fieldListeners[entry.key];
      if (listener != null) entry.value.removeListener(listener);
      entry.value.dispose();
    }
    _fields.clear();
    _fieldListeners.clear();
    super.dispose();
  }
}
