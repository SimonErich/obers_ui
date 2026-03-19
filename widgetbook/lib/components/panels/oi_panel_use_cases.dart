import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiPanelComponent = WidgetbookComponent(
  name: 'OiPanel',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final side = context.knobs.enumKnob<OiPanelSide>(
          label: 'Side',
          values: OiPanelSide.values,
          initialValue: OiPanelSide.left,
        );
        final dismissible = context.knobs.boolean(
          label: 'Dismissible',
          initialValue: true,
        );

        return SizedBox(
          width: 500,
          height: 400,
          child: StatefulBuilder(
            builder: (context, setState) {
              var open = false;
              return Stack(
                children: [
                  Center(
                    child: OiButton.primary(
                      label: 'Toggle Panel',
                      onTap: () => setState(() => open = !open),
                    ),
                  ),
                  OiPanel(
                    label: 'Side panel',
                    open: open,
                    side: side,
                    size: 260,
                    dismissible: dismissible,
                    showScrim: true,
                    onClose: () => setState(() => open = false),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Panel content'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    ),
  ],
);
