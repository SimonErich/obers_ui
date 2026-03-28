import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart'
    show OiDateRangePickerField, OiDateRangePreset;
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/widgets/fields/_oi_af_field_binder.dart';

/// Auto-form date range picker field that wraps [OiDateRangePickerField].
class OiAfDateRangePickerField<TField extends Enum> extends StatefulWidget {
  const OiAfDateRangePickerField({
    required this.field,
    this.label,
    this.hint,
    this.minDate,
    this.maxDate,
    this.dateFormat,
    this.clearable = false,
    this.required = false,
    this.presets,
    this.showPresets = true,
    this.semanticLabel,
    this.enabled = true,
    super.key,
  });

  final TField field;
  final String? label;
  final String? hint;
  final DateTime? minDate;
  final DateTime? maxDate;
  final String? dateFormat;
  final bool clearable;
  final bool required;
  final List<OiDateRangePreset>? presets;
  final bool showPresets;
  final String? semanticLabel;
  final bool enabled;

  @override
  State<OiAfDateRangePickerField<TField>> createState() =>
      _OiAfDateRangePickerFieldState<TField>();
}

class _OiAfDateRangePickerFieldState<TField extends Enum>
    extends State<OiAfDateRangePickerField<TField>>
    with
        OiAfFieldBinderMixin<
          OiAfDateRangePickerField<TField>,
          TField,
          (DateTime, DateTime)
        > {
  @override
  TField get fieldEnum => widget.field;

  @override
  OiAfFieldType get expectedType => OiAfFieldType.dateRangePicker;

  @override
  String? get widgetLabel => widget.label;

  @override
  bool get widgetEnabled => widget.enabled;

  void _handleChanged(DateTime start, DateTime end) {
    onValueChanged((start, end));
  }

  void _handleCleared() {
    onValueChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    if (!fieldCtrl.isVisible) return const SizedBox.shrink();

    final value = typedValue;

    return OiDateRangePickerField(
      startDate: value?.$1,
      endDate: value?.$2,
      onChanged: effectiveEnabled ? _handleChanged : null,
      onCleared: effectiveEnabled ? _handleCleared : null,
      minDate: widget.minDate,
      maxDate: widget.maxDate,
      label: widget.label,
      hint: widget.hint,
      error: fieldCtrl.primaryError,
      dateFormat: widget.dateFormat,
      clearable: widget.clearable,
      enabled: effectiveEnabled,
      required: widget.required,
      presets: widget.presets,
      showPresets: widget.showPresets,
      semanticLabel: widget.semanticLabel,
    );
  }
}
