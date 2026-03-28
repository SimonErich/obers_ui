import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiColorInput;
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/widgets/fields/_oi_af_field_binder.dart';

/// Auto-form color input that wraps [OiColorInput].
class OiAfColorInput<TField extends Enum> extends StatefulWidget {
  const OiAfColorInput({
    required this.field,
    this.label,
    this.hint,
    this.showHex = true,
    this.showOpacity = false,
    this.enabled = true,
    super.key,
  });

  final TField field;
  final String? label;
  final String? hint;
  final bool showHex;
  final bool showOpacity;
  final bool enabled;

  @override
  State<OiAfColorInput<TField>> createState() => _OiAfColorInputState<TField>();
}

class _OiAfColorInputState<TField extends Enum>
    extends State<OiAfColorInput<TField>>
    with OiAfFieldBinderMixin<OiAfColorInput<TField>, TField, Color> {
  @override
  TField get fieldEnum => widget.field;

  @override
  OiAfFieldType get expectedType => OiAfFieldType.color;

  @override
  String? get widgetLabel => widget.label;

  @override
  bool get widgetEnabled => widget.enabled;

  void _handleChanged(Color? value) {
    onValueChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    if (!fieldCtrl.isVisible) return const SizedBox.shrink();

    return OiColorInput(
      value: typedValue,
      onChanged: effectiveEnabled ? _handleChanged : null,
      label: widget.label,
      hint: widget.hint,
      error: fieldCtrl.primaryError,
      enabled: effectiveEnabled,
      showHex: widget.showHex,
      showOpacity: widget.showOpacity,
    );
  }
}
