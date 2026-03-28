import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiArrayInput;
import 'package:obers_ui_autoforms/src/definitions/oi_af_field_definition.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/widgets/fields/_oi_af_field_binder.dart';

/// Auto-form array input that wraps [OiArrayInput].
class OiAfArrayInput<TField extends Enum, TItem> extends StatefulWidget {
  const OiAfArrayInput({
    required this.field,
    required this.label,
    required this.itemBuilder,
    this.reorderable = true,
    this.addable = true,
    this.removable = true,
    this.addLabel = 'Add',
    this.enabled = true,
    super.key,
  });

  final TField field;
  final String label;
  final Widget Function(
    BuildContext context,
    int index,
    TItem item,
    ValueChanged<TItem> onItemChanged,
  )
  itemBuilder;
  final bool reorderable;
  final bool addable;
  final bool removable;
  final String addLabel;
  final bool enabled;

  @override
  State<OiAfArrayInput<TField, TItem>> createState() =>
      _OiAfArrayInputState<TField, TItem>();
}

class _OiAfArrayInputState<TField extends Enum, TItem>
    extends State<OiAfArrayInput<TField, TItem>>
    with
        OiAfFieldBinderMixin<
          OiAfArrayInput<TField, TItem>,
          TField,
          List<TItem>
        > {
  @override
  TField get fieldEnum => widget.field;

  @override
  OiAfFieldType get expectedType => OiAfFieldType.array;

  @override
  String? get widgetLabel => widget.label;

  @override
  bool get widgetEnabled => widget.enabled;

  void _handleChanged(List<TItem> value) {
    onValueChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    if (!fieldCtrl.isVisible) return const SizedBox.shrink();

    final def = fieldCtrl.definition;
    final arrayDef = def is OiAfArrayFieldDef<TField, TItem> ? def : null;
    final items = typedValue ?? const [];

    return OiArrayInput<TItem>(
      label: widget.label,
      items: items,
      itemBuilder: widget.itemBuilder,
      createEmpty: arrayDef?.createEmpty ?? () => null as TItem,
      onChanged: effectiveEnabled ? _handleChanged : null,
      error: fieldCtrl.primaryError,
      reorderable: widget.reorderable,
      addable: widget.addable,
      removable: widget.removable,
      minItems: arrayDef?.minItems,
      maxItems: arrayDef?.maxItems,
      addLabel: widget.addLabel,
    );
  }
}
