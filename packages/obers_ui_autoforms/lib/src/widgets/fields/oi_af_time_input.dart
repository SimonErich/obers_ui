import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiTimeInput, OiTimeOfDay;
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/widgets/fields/_oi_af_field_binder.dart';

/// Auto-form time input that wraps [OiTimeInput].
class OiAfTimeInput<TField extends Enum> extends StatefulWidget {
  const OiAfTimeInput({
    required this.field,
    this.label,
    this.hint,
    this.use24Hour = true,
    this.enabled = true,
    super.key,
  });

  final TField field;
  final String? label;
  final String? hint;
  final bool use24Hour;
  final bool enabled;

  @override
  State<OiAfTimeInput<TField>> createState() => _OiAfTimeInputState<TField>();
}

class _OiAfTimeInputState<TField extends Enum>
    extends State<OiAfTimeInput<TField>>
    with OiAfFieldBinderMixin<OiAfTimeInput<TField>, TField, OiTimeOfDay> {
  @override
  TField get fieldEnum => widget.field;

  @override
  OiAfFieldType get expectedType => OiAfFieldType.time;

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

    return OiTimeInput(
      value: typedValue,
      onChanged: effectiveEnabled ? _handleChanged : null,
      label: widget.label,
      hint: widget.hint,
      error: fieldCtrl.primaryError,
      enabled: effectiveEnabled,
      use24Hour: widget.use24Hour,
    );
  }
}
