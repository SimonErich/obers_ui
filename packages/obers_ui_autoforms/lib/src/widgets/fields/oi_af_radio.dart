import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiRadio, OiRadioOption;
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_option.dart';
import 'package:obers_ui_autoforms/src/widgets/fields/_oi_af_field_binder.dart';

/// Auto-form radio group that wraps [OiRadio].
class OiAfRadio<TField extends Enum, TValue> extends StatefulWidget {
  const OiAfRadio({
    required this.field,
    required this.options,
    this.direction = Axis.vertical,
    this.enabled = true,
    super.key,
  });

  final TField field;
  final List<OiAfOption<TValue>> options;
  final Axis direction;
  final bool enabled;

  @override
  State<OiAfRadio<TField, TValue>> createState() =>
      _OiAfRadioState<TField, TValue>();
}

class _OiAfRadioState<TField extends Enum, TValue>
    extends State<OiAfRadio<TField, TValue>>
    with OiAfFieldBinderMixin<OiAfRadio<TField, TValue>, TField, TValue> {
  @override
  TField get fieldEnum => widget.field;

  @override
  OiAfFieldType get expectedType => OiAfFieldType.radio;

  @override
  String? get widgetLabel => null;

  @override
  bool get widgetEnabled => widget.enabled;

  void _handleChanged(TValue value) {
    onValueChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    if (!fieldCtrl.isVisible) return const SizedBox.shrink();

    final radioOptions = widget.options
        .map(
          (o) => OiRadioOption<TValue>(
            value: o.value,
            label: o.label,
            enabled: o.enabled,
          ),
        )
        .toList();

    return OiRadio<TValue>(
      options: radioOptions,
      value: typedValue,
      onChanged: effectiveEnabled ? _handleChanged : null,
      enabled: effectiveEnabled,
      direction: widget.direction,
    );
  }
}
