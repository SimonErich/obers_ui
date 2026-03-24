import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' hide OiFormController;
import 'package:obers_ui_forms/src/controllers/oi_form_controller.dart';
import 'package:obers_ui_forms/src/widgets/oi_form_element.dart';
import 'package:obers_ui_forms/src/widgets/oi_form_scope.dart';

/// A form-aware number input that auto-binds to [OiFormScope].
///
/// ```dart
/// OiAutoFormNumberInput<SignupFields>(
///   fieldKey: SignupFields.age,
///   label: 'Age',
///   min: 0,
///   max: 120,
/// )
/// ```
class OiAutoFormNumberInput<E extends Enum> extends StatelessWidget {
  const OiAutoFormNumberInput({
    required this.fieldKey,
    this.label,
    this.hint,
    this.min,
    this.max,
    this.step = 1,
    this.decimalPlaces,
    this.hideIf,
    this.showIf,
    super.key,
  });

  final E fieldKey;
  final String? label;
  final String? hint;
  final double? min;
  final double? max;
  final double step;
  final int? decimalPlaces;
  final bool Function(OiFormController<E> controller)? hideIf;
  final bool Function(OiFormController<E> controller)? showIf;

  @override
  Widget build(BuildContext context) {
    final controller = OiFormScope.maybeOf<E>(context);
    final field = controller?.getInputController(fieldKey);
    final value = field?.value as double?;
    final error = field?.errors.isNotEmpty == true ? field!.errors.first : null;
    final enabled = field?.enabled ?? true;

    return OiFormElement<E>(
      fieldKey: fieldKey,
      label: label,
      hideIf: hideIf,
      showIf: showIf,
      child: OiNumberInput(
        value: value,
        hint: hint,
        error: error,
        min: min,
        max: max,
        step: step,
        decimalPlaces: decimalPlaces,
        enabled: enabled,
        onChanged: (v) => controller?.set<double>(fieldKey, v),
      ),
    );
  }
}
