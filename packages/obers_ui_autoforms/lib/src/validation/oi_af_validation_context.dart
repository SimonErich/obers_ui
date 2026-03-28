import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_reader.dart';

/// Context provided to field-level validators.
final class OiAfValidationContext<TField extends Enum, TValue> {
  const OiAfValidationContext({
    required this.field,
    required this.value,
    required this.form,
    required this.trigger,
    required this.isRequired,
    required this.isVisible,
    required this.isEnabled,
  });

  /// The field being validated.
  final TField field;

  /// The current value of the field.
  final TValue? value;

  /// Read-only access to the form state (for cross-field validation).
  final OiAfReader<TField> form;

  /// What triggered this validation run.
  final OiAfValidationTrigger trigger;

  /// Whether the field definition has `required: true`.
  final bool isRequired;

  /// Whether the field is currently visible.
  final bool isVisible;

  /// Whether the field is currently enabled.
  final bool isEnabled;
}
