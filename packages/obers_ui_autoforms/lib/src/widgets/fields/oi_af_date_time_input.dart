import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiDateTimeInput;
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/widgets/fields/_oi_af_field_binder.dart';

/// Auto-form date-time input that wraps [OiDateTimeInput].
class OiAfDateTimeInput<TField extends Enum> extends StatefulWidget {
  const OiAfDateTimeInput({
    required this.field,
    required this.label,
    this.hint,
    this.min,
    this.max,
    this.required = false,
    this.readOnly = false,
    this.enabled = true,
    super.key,
  });

  final TField field;
  final String label;
  final String? hint;
  final DateTime? min;
  final DateTime? max;
  final bool required;
  final bool readOnly;
  final bool enabled;

  @override
  State<OiAfDateTimeInput<TField>> createState() =>
      _OiAfDateTimeInputState<TField>();
}

class _OiAfDateTimeInputState<TField extends Enum>
    extends State<OiAfDateTimeInput<TField>>
    with OiAfFieldBinderMixin<OiAfDateTimeInput<TField>, TField, DateTime> {
  @override
  TField get fieldEnum => widget.field;

  @override
  OiAfFieldType get expectedType => OiAfFieldType.dateTime;

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

    return OiDateTimeInput(
      label: widget.label,
      value: typedValue,
      onChanged: effectiveEnabled ? _handleChanged : null,
      hint: widget.hint,
      error: fieldCtrl.primaryError,
      min: widget.min,
      max: widget.max,
      required: widget.required,
      readOnly: widget.readOnly,
      enabled: effectiveEnabled,
    );
  }
}
