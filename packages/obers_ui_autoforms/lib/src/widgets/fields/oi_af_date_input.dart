import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiDateInput;
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/widgets/fields/_oi_af_field_binder.dart';

/// Auto-form date input that wraps [OiDateInput].
class OiAfDateInput<TField extends Enum> extends StatefulWidget {
  const OiAfDateInput({
    required this.field,
    this.label,
    this.hint,
    this.firstDate,
    this.lastDate,
    this.dateFormat,
    this.enabled = true,
    super.key,
  });

  final TField field;
  final String? label;
  final String? hint;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? dateFormat;
  final bool enabled;

  @override
  State<OiAfDateInput<TField>> createState() => _OiAfDateInputState<TField>();
}

class _OiAfDateInputState<TField extends Enum>
    extends State<OiAfDateInput<TField>>
    with OiAfFieldBinderMixin<OiAfDateInput<TField>, TField, DateTime> {
  @override
  TField get fieldEnum => widget.field;

  @override
  OiAfFieldType get expectedType => OiAfFieldType.date;

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

    return OiDateInput(
      value: typedValue,
      onChanged: effectiveEnabled ? _handleChanged : null,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      label: widget.label,
      hint: widget.hint,
      error: fieldCtrl.primaryError,
      enabled: effectiveEnabled,
      dateFormat: widget.dateFormat,
    );
  }
}
