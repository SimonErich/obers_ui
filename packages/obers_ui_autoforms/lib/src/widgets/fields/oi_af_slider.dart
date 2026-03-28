import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiSlider;
import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/widgets/fields/_oi_af_field_binder.dart';

/// Auto-form slider that wraps [OiSlider].
class OiAfSlider<TField extends Enum> extends StatefulWidget {
  const OiAfSlider({
    required this.field,
    required this.min,
    required this.max,
    this.divisions,
    this.label,
    this.showLabels = false,
    this.showTicks = false,
    this.enabled = true,
    super.key,
  });

  final TField field;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final bool showLabels;
  final bool showTicks;
  final bool enabled;

  @override
  State<OiAfSlider<TField>> createState() => _OiAfSliderState<TField>();
}

class _OiAfSliderState<TField extends Enum> extends State<OiAfSlider<TField>>
    with OiAfFieldBinderMixin<OiAfSlider<TField>, TField, double> {
  @override
  TField get fieldEnum => widget.field;

  @override
  OiAfFieldType get expectedType => OiAfFieldType.slider;

  @override
  String? get widgetLabel => widget.label;

  @override
  bool get widgetEnabled => widget.enabled;

  void _handleChanged(double value) {
    onValueChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    if (!fieldCtrl.isVisible) return const SizedBox.shrink();

    return OiSlider(
      value: typedValue ?? widget.min,
      min: widget.min,
      max: widget.max,
      divisions: widget.divisions,
      onChanged: effectiveEnabled ? _handleChanged : null,
      label: widget.label,
      showLabels: widget.showLabels,
      showTicks: widget.showTicks,
      enabled: effectiveEnabled,
    );
  }
}
