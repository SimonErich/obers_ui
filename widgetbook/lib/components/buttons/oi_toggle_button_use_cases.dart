import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiToggleButtonComponent = WidgetbookComponent(
  name: 'OiToggleButton',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Bold',
        );
        final size = context.knobs.enumKnob<OiButtonSize>(
          label: 'Size',
          values: OiButtonSize.values,
        );
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );
        final showIcon = context.knobs.boolean(
          label: 'Show Icon',
          initialValue: false,
        );
        final icon = showIcon ? context.knobs.iconKnob() : null;

        return useCaseWrapper(
          _ToggleButtonDemo(
            label: label,
            icon: icon,
            size: size,
            enabled: enabled,
          ),
        );
      },
    ),
  ],
);

class _ToggleButtonDemo extends StatefulWidget {
  const _ToggleButtonDemo({
    required this.label,
    required this.size,
    required this.enabled,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final OiButtonSize size;
  final bool enabled;

  @override
  State<_ToggleButtonDemo> createState() => _ToggleButtonDemoState();
}

class _ToggleButtonDemoState extends State<_ToggleButtonDemo> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return OiToggleButton(
      label: widget.label,
      icon: widget.icon,
      selected: _selected,
      semanticLabel: widget.label,
      size: widget.size,
      enabled: widget.enabled,
      onChanged: (v) => setState(() => _selected = v),
    );
  }
}
