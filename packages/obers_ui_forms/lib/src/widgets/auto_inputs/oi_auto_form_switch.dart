import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' hide OiFormController;
import 'package:obers_ui_forms/src/controllers/oi_form_controller.dart';
import 'package:obers_ui_forms/src/widgets/oi_form_element.dart';
import 'package:obers_ui_forms/src/widgets/oi_form_scope.dart';

/// A form-aware switch that auto-binds to [OiFormScope].
///
/// ```dart
/// OiAutoFormSwitch<SignupFields>(
///   fieldKey: SignupFields.newsletter,
///   label: 'Newsletter',
/// )
/// ```
class OiAutoFormSwitch<E extends Enum> extends StatelessWidget {
  const OiAutoFormSwitch({
    required this.fieldKey,
    this.label,
    this.switchLabel,
    this.size = OiSwitchSize.medium,
    this.hideIf,
    this.showIf,
    super.key,
  });

  final E fieldKey;
  final String? label;
  final String? switchLabel;
  final OiSwitchSize size;
  final bool Function(OiFormController<E> controller)? hideIf;
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
      child: OiSwitch(
        value: value,
        label: switchLabel,
        size: size,
        enabled: enabled,
        onChanged: (v) => controller?.set<bool>(fieldKey, v),
      ),
    );
  }
}
