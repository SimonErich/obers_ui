import 'package:obers_ui_autoforms/src/foundation/oi_af_submit_result.dart';

/// Observer interface for form lifecycle events.
///
/// Implement and attach to a controller for logging, analytics,
/// or debugging.
abstract class OiAfObserver {
  /// Called when a field value changes.
  void onFieldValueChanged(Enum field, Object? oldValue, Object? newValue) {}

  /// Called after a field is validated.
  void onFieldValidated(Enum field, List<String> errors) {}

  /// Called when a validator throws unexpectedly.
  void onValidationCrash(Enum field, Object error, StackTrace stackTrace) {}

  /// Called when a submit begins.
  void onSubmitStarted() {}

  /// Called when a submit completes.
  void onSubmitCompleted(OiAfSubmitResult<Object?> result) {}

  /// Called when the form is reset.
  void onFormReset() {}
}
