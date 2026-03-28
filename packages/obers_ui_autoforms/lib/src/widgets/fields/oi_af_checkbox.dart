import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiCheckbox;
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/widgets/fields/_oi_af_field_binder.dart';

/// Auto-form checkbox that wraps [OiCheckbox].
class OiAfCheckbox<TField extends Enum> extends StatefulWidget {
  const OiAfCheckbox({
    required this.field,
    this.label,
    this.enabled = true,
    super.key,
  });

  final TField field;
  final String? label;
  final bool enabled;

  @override
  State<OiAfCheckbox<TField>> createState() => _OiAfCheckboxState<TField>();
}

class _OiAfCheckboxState<TField extends Enum>
    extends State<OiAfCheckbox<TField>>
    with OiAfFieldBinderMixin<OiAfCheckbox<TField>, TField, bool?> {
  @override
  TField get fieldEnum => widget.field;

  @override
  OiAfFieldType get expectedType => OiAfFieldType.checkbox;

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

    return OiCheckbox(
      value: typedValue,
      onChanged: effectiveEnabled ? _handleChanged : null,
      label: widget.label,
      enabled: effectiveEnabled,
    );
  }
}
