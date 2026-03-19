import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiSwitchComponent = WidgetbookComponent(
  name: 'OiSwitch',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final size = context.knobs.enumKnob<OiSwitchSize>(
          label: 'Size',
          values: OiSwitchSize.values,
        );
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Notifications',
        );
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );

        return useCaseWrapper(
          _SwitchDemo(size: size, label: label, enabled: enabled),
        );
      },
    ),
  ],
);

class _SwitchDemo extends StatefulWidget {
  const _SwitchDemo({
    required this.size,
    required this.label,
    required this.enabled,
  });

  final OiSwitchSize size;
  final String label;
  final bool enabled;

  @override
  State<_SwitchDemo> createState() => _SwitchDemoState();
}

class _SwitchDemoState extends State<_SwitchDemo> {
  bool _value = false;

  @override
  Widget build(BuildContext context) {
    return OiSwitch(
      value: _value,
      size: widget.size,
      label: widget.label.isEmpty ? null : widget.label,
      enabled: widget.enabled,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}
