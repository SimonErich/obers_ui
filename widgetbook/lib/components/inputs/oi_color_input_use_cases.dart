import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiColorInputComponent = WidgetbookComponent(
  name: 'OiColorInput',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final showHex = context.knobs.boolean(
          label: 'Show Hex',
          initialValue: true,
        );
        final showOpacity = context.knobs.boolean(label: 'Show Opacity');
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Brand Color',
        );

        return useCaseWrapper(
          SizedBox(
            width: 300,
            child: _ColorInputDemo(
              showHex: showHex,
              showOpacity: showOpacity,
              enabled: enabled,
              label: label,
            ),
          ),
        );
      },
    ),
  ],
);

class _ColorInputDemo extends StatefulWidget {
  const _ColorInputDemo({
    required this.showHex,
    required this.showOpacity,
    required this.enabled,
    required this.label,
  });

  final bool showHex;
  final bool showOpacity;
  final bool enabled;
  final String label;

  @override
  State<_ColorInputDemo> createState() => _ColorInputDemoState();
}

class _ColorInputDemoState extends State<_ColorInputDemo> {
  Color? _value = const Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    return OiColorInput(
      value: _value,
      showHex: widget.showHex,
      showOpacity: widget.showOpacity,
      enabled: widget.enabled,
      label: widget.label.isEmpty ? null : widget.label,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}
