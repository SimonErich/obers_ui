/// Sealed class hierarchy for form submit results.
sealed class OiAfSubmitResult<TData> {
  const OiAfSubmitResult();
}

/// Submit succeeded with validated data.
final class OiAfSubmitSuccess<TData> extends OiAfSubmitResult<TData> {
  const OiAfSubmitSuccess(this.data);

  /// The successfully built and validated data.
  final TData data;
}

/// Submit blocked by validation errors.
final class OiAfSubmitInvalid<TData> extends OiAfSubmitResult<TData> {
  const OiAfSubmitInvalid({
    required this.fieldErrors,
    required this.globalErrors,
  });

  /// Field-level validation errors keyed by field enum.
  final Map<Enum, List<String>> fieldErrors;

  /// Form-level (global) validation errors.
  final List<String> globalErrors;
}

/// Submit failed with an exception.
final class OiAfSubmitFailure<TData> extends OiAfSubmitResult<TData> {
  const OiAfSubmitFailure({
    required this.error,
    required this.stackTrace,
    required this.globalErrors,
    this.data,
  });

  /// The data that was being submitted, if available.
  final TData? data;

  /// The error that was thrown.
  final Object error;

  /// Stack trace of the error.
  final StackTrace stackTrace;

  /// Error messages mapped to global scope.
  final List<String> globalErrors;
}
