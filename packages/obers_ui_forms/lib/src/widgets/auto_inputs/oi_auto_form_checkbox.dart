import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' hide OiFormController;
import 'package:obers_ui_forms/src/controllers/oi_form_controller.dart';
import 'package:obers_ui_forms/src/widgets/oi_form_element.dart';
import 'package:obers_ui_forms/src/widgets/oi_form_scope.dart';

/// A form-aware checkbox that auto-binds to [OiFormScope].
///
/// ```dart
/// OiAutoFormCheckbox<SignupFields>(
///   fieldKey: SignupFields.acceptTerms,
///   label: 'Accept Terms',
/// )
/// ```
class OiAutoFormCheckbox<E extends Enum> extends StatelessWidget {
  const OiAutoFormCheckbox({
    required this.fieldKey,
    this.label,
    this.checkboxLabel,
    this.hideIf,
    this.showIf,
    super.key,
  });

  /// The enum key linking this input to its field controller.
  final E fieldKey;

  /// Label displayed above the checkbox (via OiFormElement).
  final String? label;

  /// Label displayed next to the checkbox (via OiCheckbox).
  final String? checkboxLabel;

  /// Hide when condition is true.
  final bool Function(OiFormController<E> controller)? hideIf;

  /// Show when condition is true.
  final bool Function(OiFormController<E> controller)? showIf;

  @override
  Widget build(BuildContext context) {
    final controller = OiFormScope.maybeOf<E>(context);
    final field = controller?.getInputController(fieldKey);
    final value = field?.value as bool? ?? false;
    final enabled = field?.enabled ?? true;

    return OiFormElement<E>(
      fieldKey: fieldKey,
      label: label,
      hideIf: hideIf,
      showIf: showIf,
      child: OiCheckbox(
        value: value,
        label: checkboxLabel,
        enabled: enabled,
        onChanged: (v) => controller?.set<bool>(fieldKey, v),
      ),
    );
  }
}
