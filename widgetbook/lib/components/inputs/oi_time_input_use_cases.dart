import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiTimeInputComponent = WidgetbookComponent(
  name: 'OiTimeInput',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final use24Hour = context.knobs.boolean(
          label: '24-Hour Format',
          initialValue: true,
        );
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Start Time',
        );

        return useCaseWrapper(
          SizedBox(
            width: 300,
            child: _TimeInputDemo(
              use24Hour: use24Hour,
              enabled: enabled,
              label: label,
            ),
          ),
        );
      },
    ),
  ],
);

class _TimeInputDemo extends StatefulWidget {
  const _TimeInputDemo({
    required this.use24Hour,
    required this.enabled,
    required this.label,
  });

  final bool use24Hour;
  final bool enabled;
  final String label;

  @override
  State<_TimeInputDemo> createState() => _TimeInputDemoState();
}

class _TimeInputDemoState extends State<_TimeInputDemo> {
  OiTimeOfDay? _value;

  @override
  Widget build(BuildContext context) {
    return OiTimeInput(
      value: _value,
      use24Hour: widget.use24Hour,
      enabled: widget.enabled,
      label: widget.label.isEmpty ? null : widget.label,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}
