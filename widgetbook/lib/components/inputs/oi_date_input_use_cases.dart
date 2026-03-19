import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiDateInputComponent = WidgetbookComponent(
  name: 'OiDateInput',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Date of Birth',
        );
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 300,
            child: _DateInputDemo(label: label, enabled: enabled),
          ),
        );
      },
    ),
  ],
);

class _DateInputDemo extends StatefulWidget {
  const _DateInputDemo({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  State<_DateInputDemo> createState() => _DateInputDemoState();
}

class _DateInputDemoState extends State<_DateInputDemo> {
  DateTime? _value;

  @override
  Widget build(BuildContext context) {
    return OiDateInput(
      value: _value,
      label: widget.label.isEmpty ? null : widget.label,
      enabled: widget.enabled,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}
