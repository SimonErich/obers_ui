import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_reader.dart';

/// Context provided to form-level validators.
final class OiAfFormValidationContext<TField extends Enum> {
  const OiAfFormValidationContext({
    required this.form,
    required this.trigger,
  });

  /// Read-only access to the form state.
  final OiAfReader<TField> form;

  /// What triggered this validation run.
  final OiAfValidationTrigger trigger;
}
