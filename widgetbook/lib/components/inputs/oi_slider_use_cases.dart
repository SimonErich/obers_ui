import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiSliderComponent = WidgetbookComponent(
  name: 'OiSlider',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final min = context.knobs.double.slider(label: 'Min', max: 50);
        final max = context.knobs.double.slider(
          label: 'Max',
          initialValue: 100,
          min: 50,
          max: 200,
        );
        final divisions = context.knobs.int.slider(label: 'Divisions');
        final showLabels = context.knobs.boolean(label: 'Show Labels');
        final showTicks = context.knobs.boolean(label: 'Show Ticks');
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Volume',
        );

        return useCaseWrapper(
          SizedBox(
            width: 300,
            child: _SliderDemo(
              min: min,
              max: max,
              divisions: divisions == 0 ? null : divisions,
              showLabels: showLabels,
              showTicks: showTicks,
              enabled: enabled,
              label: label,
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Range',
      builder: (context) {
        return useCaseWrapper(SizedBox(width: 300, child: _RangeSliderDemo()));
      },
    ),
  ],
);

class _SliderDemo extends StatefulWidget {
  const _SliderDemo({
    required this.min,
    required this.max,
    required this.showLabels,
    required this.showTicks,
    required this.enabled,
    required this.label,
    this.divisions,
  });

  final double min;
  final double max;
  final int? divisions;
  final bool showLabels;
  final bool showTicks;
  final bool enabled;
  final String label;

  @override
  State<_SliderDemo> createState() => _SliderDemoState();
}

class _SliderDemoState extends State<_SliderDemo> {
  double _value = 50;

  @override
  Widget build(BuildContext context) {
    return OiSlider(
      value: _value.clamp(widget.min, widget.max),
      min: widget.min,
      max: widget.max,
      divisions: widget.divisions,
      showLabels: widget.showLabels,
      showTicks: widget.showTicks,
      enabled: widget.enabled,
      label: widget.label.isEmpty ? null : widget.label,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}

class _RangeSliderDemo extends StatefulWidget {
  @override
  State<_RangeSliderDemo> createState() => _RangeSliderDemoState();
}

class _RangeSliderDemoState extends State<_RangeSliderDemo> {
  double _start = 20;
  double _end = 80;

  @override
  Widget build(BuildContext context) {
    return OiSlider(
      value: _start,
      secondaryValue: _end,
      min: 0,
      max: 100,
      showLabels: true,
      label: 'Price range',
      onRangeChanged: (start, end) => setState(() {
        _start = start;
        _end = end;
      }),
    );
  }
}
