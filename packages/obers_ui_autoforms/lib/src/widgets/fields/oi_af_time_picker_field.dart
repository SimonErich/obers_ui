import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiTimeOfDay, OiTimePickerField;
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/widgets/fields/_oi_af_field_binder.dart';

/// Auto-form time picker field that wraps [OiTimePickerField].
class OiAfTimePickerField<TField extends Enum> extends StatefulWidget {
  const OiAfTimePickerField({
    required this.field,
    this.label,
    this.hint,
    this.placeholder,
    this.minTime,
    this.maxTime,
    this.minuteInterval = 1,
    this.use24Hour = true,
    this.clearable = false,
    this.semanticLabel,
    this.enabled = true,
    super.key,
  });

  final TField field;
  final String? label;
  final String? hint;
  final String? placeholder;
  final OiTimeOfDay? minTime;
  final OiTimeOfDay? maxTime;
  final int minuteInterval;
  final bool use24Hour;
  final bool clearable;
  final String? semanticLabel;
  final bool enabled;

  @override
  State<OiAfTimePickerField<TField>> createState() =>
      _OiAfTimePickerFieldState<TField>();
}

class _OiAfTimePickerFieldState<TField extends Enum>
    extends State<OiAfTimePickerField<TField>>
    with
        OiAfFieldBinderMixin<OiAfTimePickerField<TField>, TField, OiTimeOfDay> {
  @override
  TField get fieldEnum => widget.field;

  @override
  OiAfFieldType get expectedType => OiAfFieldType.timePicker;

  @override
  String? get widgetLabel => widget.label;

  @override
  bool get widgetEnabled => widget.enabled;

  void _handleChanged(OiTimeOfDay? value) {
    onValueChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    if (!fieldCtrl.isVisible) return const SizedBox.shrink();

    return OiTimePickerField(
      value: typedValue,
      onChanged: effectiveEnabled ? _handleChanged : null,
      minTime: widget.minTime,
      maxTime: widget.maxTime,
      minuteInterval: widget.minuteInterval,
      label: widget.label,
      hint: widget.hint,
      placeholder: widget.placeholder,
      error: fieldCtrl.primaryError,
      use24Hour: widget.use24Hour,
      clearable: widget.clearable,
      enabled: effectiveEnabled,
      semanticLabel: widget.semanticLabel,
    );
  }
}
