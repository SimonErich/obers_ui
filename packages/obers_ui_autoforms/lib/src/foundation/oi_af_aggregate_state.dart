/// Aggregate form state snapshot for widgets that observe the whole form.
final class OiAfAggregateState {
  const OiAfAggregateState({
    required this.isValid,
    required this.isDirty,
    required this.isTouched,
    required this.isEnabled,
    required this.isSubmitting,
    required this.isValidating,
    required this.hasSubmitted,
    required this.submitCount,
    required this.fieldErrorCount,
    required this.globalErrorCount,
  });

  /// Whether all visible + enabled fields pass validation.
  final bool isValid;

  /// Whether any field has been modified from its initial value.
  final bool isDirty;

  /// Whether any field has been focused.
  final bool isTouched;

  /// Whether the form is enabled.
  final bool isEnabled;

  /// Whether a submit is in progress.
  final bool isSubmitting;

  /// Whether any field is currently validating.
  final bool isValidating;

  /// Whether submit has been attempted at least once.
  final bool hasSubmitted;

  /// Number of submit attempts.
  final int submitCount;

  /// Number of fields with at least one error.
  final int fieldErrorCount;

  /// Number of global (form-level) errors.
  final int globalErrorCount;

  /// Whether the form has any errors.
  bool get hasErrors => fieldErrorCount > 0 || globalErrorCount > 0;

  /// Total error count.
  int get totalErrorCount => fieldErrorCount + globalErrorCount;
}
