import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiDatePickerField;
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/widgets/fields/_oi_af_field_binder.dart';

/// Auto-form date picker field that wraps [OiDatePickerField].
class OiAfDatePickerField<TField extends Enum> extends StatefulWidget {
  const OiAfDatePickerField({
    required this.field,
    this.label,
    this.hint,
    this.placeholder,
    this.minDate,
    this.maxDate,
    this.selectableDayPredicate,
    this.dateFormat,
    this.clearable = false,
    this.readOnly = false,
    this.semanticLabel,
    this.enabled = true,
    super.key,
  });

  final TField field;
  final String? label;
  final String? hint;
  final String? placeholder;
  final DateTime? minDate;
  final DateTime? maxDate;
  final bool Function(DateTime)? selectableDayPredicate;
  final String? dateFormat;
  final bool clearable;
  final bool readOnly;
  final String? semanticLabel;
  final bool enabled;

  @override
  State<OiAfDatePickerField<TField>> createState() =>
      _OiAfDatePickerFieldState<TField>();
}

class _OiAfDatePickerFieldState<TField extends Enum>
    extends State<OiAfDatePickerField<TField>>
    with OiAfFieldBinderMixin<OiAfDatePickerField<TField>, TField, DateTime> {
  @override
  TField get fieldEnum => widget.field;

  @override
  OiAfFieldType get expectedType => OiAfFieldType.datePicker;

  @override
  String? get widgetLabel => widget.label;

  @override
  bool get widgetEnabled => widget.enabled;

  void _handleChanged(DateTime? value) {
    onValueChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    if (!fieldCtrl.isVisible) return const SizedBox.shrink();

    return OiDatePickerField(
      value: typedValue,
      onChanged: effectiveEnabled ? _handleChanged : null,
      minDate: widget.minDate,
      maxDate: widget.maxDate,
      selectableDayPredicate: widget.selectableDayPredicate,
      label: widget.label,
      hint: widget.hint,
      placeholder: widget.placeholder,
      error: fieldCtrl.primaryError,
      dateFormat: widget.dateFormat,
      clearable: widget.clearable,
      enabled: effectiveEnabled,
      readOnly: widget.readOnly,
      semanticLabel: widget.semanticLabel,
    );
  }
}
