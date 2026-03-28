import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart'
    show OiSegment, OiSegmentedControl, OiSegmentedControlSize;
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_option.dart';
import 'package:obers_ui_autoforms/src/widgets/fields/_oi_af_field_binder.dart';

/// Auto-form segmented control that wraps [OiSegmentedControl].
class OiAfSegmentedControl<TField extends Enum, TValue> extends StatefulWidget {
  const OiAfSegmentedControl({
    required this.field,
    required this.options,
    this.size = OiSegmentedControlSize.medium,
    this.expand = false,
    this.semanticLabel,
    this.enabled = true,
    super.key,
  });

  final TField field;
  final List<OiAfOption<TValue>> options;
  final OiSegmentedControlSize size;
  final bool expand;
  final String? semanticLabel;
  final bool enabled;

  @override
  State<OiAfSegmentedControl<TField, TValue>> createState() =>
      _OiAfSegmentedControlState<TField, TValue>();
}

class _OiAfSegmentedControlState<TField extends Enum, TValue>
    extends State<OiAfSegmentedControl<TField, TValue>>
    with
        OiAfFieldBinderMixin<
          OiAfSegmentedControl<TField, TValue>,
          TField,
          TValue
        > {
  @override
  TField get fieldEnum => widget.field;

  @override
  OiAfFieldType get expectedType => OiAfFieldType.segmentedControl;

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

    final segments = widget.options
        .map(
          (o) => OiSegment<TValue>(
            value: o.value,
            label: o.label,
            enabled: o.enabled,
          ),
        )
        .toList();

    // OiSegmentedControl requires a non-null selected value.
    // Fall back to the first segment's value if field value is null.
    final selected = typedValue ?? segments.first.value;

    return OiSegmentedControl<TValue>(
      segments: segments,
      selected: selected,
      onChanged: effectiveEnabled ? _handleChanged : _noOp,
      enabled: effectiveEnabled,
      size: widget.size,
      expand: widget.expand,
      semanticLabel: widget.semanticLabel,
    );
  }

  // OiSegmentedControl requires a non-null onChanged callback.
  static void _noOp<T>(T _) {}
}
