import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiSelect, OiSelectOption;
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_option.dart';
import 'package:obers_ui_autoforms/src/widgets/fields/_oi_af_field_binder.dart';

/// Auto-form select that wraps [OiSelect].
class OiAfSelect<TField extends Enum, TValue> extends StatefulWidget {
  const OiAfSelect({
    required this.field,
    required this.options,
    this.label,
    this.hint,
    this.placeholder,
    this.searchable = false,
    this.bottomSheetOnCompact = false,
    this.enabled = true,
    super.key,
  });

  final TField field;
  final List<OiAfOption<TValue>> options;
  final String? label;
  final String? hint;
  final String? placeholder;
  final bool searchable;
  final bool bottomSheetOnCompact;
  final bool enabled;

  @override
  State<OiAfSelect<TField, TValue>> createState() =>
      _OiAfSelectState<TField, TValue>();
}

class _OiAfSelectState<TField extends Enum, TValue>
    extends State<OiAfSelect<TField, TValue>>
    with OiAfFieldBinderMixin<OiAfSelect<TField, TValue>, TField, TValue> {
  @override
  TField get fieldEnum => widget.field;

  @override
  OiAfFieldType get expectedType => OiAfFieldType.select;

  @override
  String? get widgetLabel => widget.label;

  @override
  bool get widgetEnabled => widget.enabled;

  void _handleChanged(TValue? value) {
    onValueChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    if (!fieldCtrl.isVisible) return const SizedBox.shrink();

    final selectOptions = widget.options
        .map(
          (o) => OiSelectOption<TValue>(
            value: o.value,
            label: o.label,
            enabled: o.enabled,
          ),
        )
        .toList();

    return OiSelect<TValue>(
      options: selectOptions,
      value: typedValue,
      onChanged: effectiveEnabled ? _handleChanged : null,
      label: widget.label,
      hint: widget.hint,
      error: fieldCtrl.primaryError,
      placeholder: widget.placeholder,
      enabled: effectiveEnabled,
      searchable: widget.searchable,
      bottomSheetOnCompact: widget.bottomSheetOnCompact,
    );
  }
}
