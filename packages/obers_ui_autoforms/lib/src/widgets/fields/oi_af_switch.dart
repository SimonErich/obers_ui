import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiSwitch, OiSwitchSize;
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/widgets/fields/_oi_af_field_binder.dart';

/// Auto-form switch that wraps [OiSwitch].
class OiAfSwitch<TField extends Enum> extends StatefulWidget {
  const OiAfSwitch({
    required this.field,
    this.label,
    this.size = OiSwitchSize.medium,
    this.enabled = true,
    super.key,
  });

  final TField field;
  final String? label;
  final OiSwitchSize size;
  final bool enabled;

  @override
  State<OiAfSwitch<TField>> createState() => _OiAfSwitchState<TField>();
}

class _OiAfSwitchState<TField extends Enum> extends State<OiAfSwitch<TField>>
    with OiAfFieldBinderMixin<OiAfSwitch<TField>, TField, bool> {
  @override
  TField get fieldEnum => widget.field;

  @override
  OiAfFieldType get expectedType => OiAfFieldType.switcher;

  @override
  String? get widgetLabel => widget.label;

  @override
  bool get widgetEnabled => widget.enabled;

  void _handleChanged(bool value) {
    onValueChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    if (!fieldCtrl.isVisible) return const SizedBox.shrink();

    return OiSwitch(
      value: typedValue ?? false,
      onChanged: effectiveEnabled ? _handleChanged : null,
      size: widget.size,
      enabled: effectiveEnabled,
      label: widget.label,
    );
  }
}
