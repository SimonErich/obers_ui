import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiNumberInput;
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/widgets/fields/_oi_af_field_binder.dart';

/// Auto-form number input that wraps [OiNumberInput].
class OiAfNumberInput<TField extends Enum> extends StatefulWidget {
  const OiAfNumberInput({
    required this.field,
    this.label,
    this.hint,
    this.min,
    this.max,
    this.step = 1,
    this.decimalPlaces,
    this.enabled = true,
    super.key,
  });

  final TField field;
  final String? label;
  final String? hint;
  final double? min;
  final double? max;
  final double step;
  final int? decimalPlaces;
  final bool enabled;

  @override
  State<OiAfNumberInput<TField>> createState() =>
      _OiAfNumberInputState<TField>();
}

class _OiAfNumberInputState<TField extends Enum>
    extends State<OiAfNumberInput<TField>>
    with OiAfFieldBinderMixin<OiAfNumberInput<TField>, TField, num> {
  @override
  TField get fieldEnum => widget.field;

  @override
  OiAfFieldType get expectedType => OiAfFieldType.number;

  @override
  String? get widgetLabel => widget.label;

  @override
  bool get widgetEnabled => widget.enabled;

  void _handleChanged(double? value) {
    onValueChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    if (!fieldCtrl.isVisible) return const SizedBox.shrink();

    return OiNumberInput(
      value: typedValue?.toDouble(),
      onChanged: effectiveEnabled ? _handleChanged : null,
      min: widget.min,
      max: widget.max,
      step: widget.step,
      decimalPlaces: widget.decimalPlaces,
      label: widget.label,
      hint: widget.hint,
      error: fieldCtrl.primaryError,
      enabled: effectiveEnabled,
    );
  }
}
