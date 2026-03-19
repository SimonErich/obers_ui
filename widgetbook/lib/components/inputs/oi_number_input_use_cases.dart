import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiNumberInputComponent = WidgetbookComponent(
  name: 'OiNumberInput',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Quantity',
        );
        final min = context.knobs.double.slider(
          label: 'Min',
          min: -100,
          max: 0,
        );
        final max = context.knobs.double.slider(
          label: 'Max',
          initialValue: 100,
          min: 1,
          max: 1000,
        );
        final step = context.knobs.double.slider(
          label: 'Step',
          initialValue: 1,
          min: 0.1,
          max: 10,
        );
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 200,
            child: _NumberInputDemo(
              label: label,
              min: min,
              max: max,
              step: step,
              enabled: enabled,
            ),
          ),
        );
      },
    ),
  ],
);

class _NumberInputDemo extends StatefulWidget {
  const _NumberInputDemo({
    required this.label,
    required this.min,
    required this.max,
    required this.step,
    required this.enabled,
  });

  final String label;
  final double min;
  final double max;
  final double step;
  final bool enabled;

  @override
  State<_NumberInputDemo> createState() => _NumberInputDemoState();
}

class _NumberInputDemoState extends State<_NumberInputDemo> {
  double? _value = 1;

  @override
  Widget build(BuildContext context) {
    return OiNumberInput(
      value: _value,
      label: widget.label.isEmpty ? null : widget.label,
      min: widget.min,
      max: widget.max,
      step: widget.step,
      enabled: widget.enabled,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}
