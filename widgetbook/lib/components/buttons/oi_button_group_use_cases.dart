import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiButtonGroupComponent = WidgetbookComponent(
  name: 'OiButtonGroup',
  useCases: [
    WidgetbookUseCase(
      name: 'Non-Exclusive',
      builder: (context) {
        final size = context.knobs.enumKnob<OiButtonSize>(
          label: 'Size',
          values: OiButtonSize.values,
        );
        final direction = context.knobs.enumKnob<Axis>(
          label: 'Direction',
          values: Axis.values,
          initialValue: Axis.horizontal,
        );
        final spacing = context.knobs.double.slider(
          label: 'Spacing',
          initialValue: 0,
          min: 0,
          max: 16,
        );

        return useCaseWrapper(
          OiButtonGroup(
            label: 'Actions',
            size: size,
            direction: direction,
            spacing: spacing,
            items: const [
              OiButtonGroupItem(label: 'Cut'),
              OiButtonGroupItem(label: 'Copy'),
              OiButtonGroupItem(label: 'Paste'),
            ],
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Exclusive (Tab-like)',
      builder: (context) {
        final size = context.knobs.enumKnob<OiButtonSize>(
          label: 'Size',
          values: OiButtonSize.values,
        );

        return useCaseWrapper(
          _ExclusiveGroupDemo(size: size),
        );
      },
    ),
  ],
);

class _ExclusiveGroupDemo extends StatefulWidget {
  const _ExclusiveGroupDemo({required this.size});

  final OiButtonSize size;

  @override
  State<_ExclusiveGroupDemo> createState() => _ExclusiveGroupDemoState();
}

class _ExclusiveGroupDemoState extends State<_ExclusiveGroupDemo> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return OiButtonGroup(
      label: 'View mode',
      exclusive: true,
      size: widget.size,
      items: const [
        OiButtonGroupItem(label: 'Day'),
        OiButtonGroupItem(label: 'Week'),
        OiButtonGroupItem(label: 'Month'),
      ],
      selectedIndex: _selectedIndex,
      onSelect: (i) => setState(() => _selectedIndex = i),
    );
  }
}
