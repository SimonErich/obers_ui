/// Base class for form field validators.
///
/// Validators return `null` when the value is valid, or an error message
/// string when validation fails.
sealed class OiFormValidator<T> {
  const OiFormValidator();

  /// Whether this validator runs asynchronously.
  bool get isAsync => false;
}

/// A synchronous validator that checks a field value immediately.
final class OiSyncFormValidator<T> extends OiFormValidator<T> {
  const OiSyncFormValidator(this._validate);

  final String? Function(T? value, dynamic controller) _validate;

  /// Validate the given [value] with access to the [controller].
  String? validate(T? value, dynamic controller) =>
      _validate(value, controller);
}

/// An asynchronous validator with debounce support.
final class OiAsyncFormValidator<T> extends OiFormValidator<T> {
  const OiAsyncFormValidator(
    this._validate, {
    this.debounce = const Duration(milliseconds: 300),
  });

  final Future<String?> Function(T? value, dynamic controller) _validate;

  /// The debounce duration before running async validation.
  final Duration debounce;

  @override
  bool get isAsync => true;

  /// Validate the given [value] with access to the [controller].
  Future<String?> validate(T? value, dynamic controller) =>
      _validate(value, controller);
}
