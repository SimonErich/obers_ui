import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' hide OiFormController;
import 'package:obers_ui_forms/src/controllers/oi_form_controller.dart';
import 'package:obers_ui_forms/src/widgets/oi_form_element.dart';
import 'package:obers_ui_forms/src/widgets/oi_form_scope.dart';

/// A form-aware select dropdown that auto-binds to [OiFormScope].
///
/// ```dart
/// OiAutoFormSelect<SignupFields, String>(
///   fieldKey: SignupFields.gender,
///   label: 'Gender',
///   options: [
///     OiSelectOption(value: 'male', label: 'Male'),
///     OiSelectOption(value: 'female', label: 'Female'),
///   ],
/// )
/// ```
class OiAutoFormSelect<E extends Enum, T> extends StatelessWidget {
  const OiAutoFormSelect({
    required this.fieldKey,
    required this.options,
    this.label,
    this.placeholder,
    this.hint,
    this.searchable = false,
    this.hideIf,
    this.showIf,
    this.revalidateOnChangeOf,
    super.key,
  });

  final E fieldKey;
  final List<OiSelectOption<T>> options;
  final String? label;
  final String? placeholder;
  final String? hint;
  final bool searchable;
  final bool Function(OiFormController<E> controller)? hideIf;
  final bool Function(OiFormController<E> controller)? showIf;
  final List<E>? revalidateOnChangeOf;

  @override
  Widget build(BuildContext context) {
    final controller = OiFormScope.maybeOf<E>(context);
    final field = controller?.getInputController(fieldKey);
    final value = field?.value as T?;
    final error = field?.errors.isNotEmpty == true ? field!.errors.first : null;
    final enabled = field?.enabled ?? true;

    return OiFormElement<E>(
      fieldKey: fieldKey,
      label: label,
      hideIf: hideIf,
      showIf: showIf,
      revalidateOnChangeOf: revalidateOnChangeOf,
      child: OiSelect<T>(
        options: options,
        value: value,
        placeholder: placeholder,
        hint: hint,
        error: error,
        searchable: searchable,
        enabled: enabled,
        onChanged: (v) => controller?.set<T>(fieldKey, v),
      ),
    );
  }
}
