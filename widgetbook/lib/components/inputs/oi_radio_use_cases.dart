import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiRadioComponent = WidgetbookComponent(
  name: 'OiRadio',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final direction = context.knobs.enumKnob<Axis>(
          label: 'Direction',
          values: Axis.values,
          initialValue: Axis.vertical,
        );
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );

        return useCaseWrapper(
          _RadioDemo(direction: direction, enabled: enabled),
        );
      },
    ),
  ],
);

class _RadioDemo extends StatefulWidget {
  const _RadioDemo({required this.direction, required this.enabled});

  final Axis direction;
  final bool enabled;

  @override
  State<_RadioDemo> createState() => _RadioDemoState();
}

class _RadioDemoState extends State<_RadioDemo> {
  String? _value;

  static const _options = [
    OiRadioOption(value: 'small', label: 'Small'),
    OiRadioOption(value: 'medium', label: 'Medium'),
    OiRadioOption(value: 'large', label: 'Large'),
    OiRadioOption(value: 'xl', label: 'Extra Large'),
  ];

  @override
  Widget build(BuildContext context) {
    return OiRadio<String>(
      options: _options,
      value: _value,
      direction: widget.direction,
      enabled: widget.enabled,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}
