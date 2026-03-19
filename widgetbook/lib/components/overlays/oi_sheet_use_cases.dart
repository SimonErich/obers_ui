import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiSheetComponent = WidgetbookComponent(
  name: 'OiSheet',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final side = context.knobs.enumKnob<OiPanelSide>(
          label: 'Side',
          values: OiPanelSide.values,
          initialValue: OiPanelSide.bottom,
        );
        final dismissible = context.knobs.boolean(
          label: 'Dismissible',
          initialValue: true,
        );
        final dragHandle = context.knobs.boolean(
          label: 'Drag Handle',
          initialValue: true,
        );

        return useCaseWrapper(
          OiButton.primary(
            label: 'Open Sheet',
            onTap: () {
              late OiOverlayHandle handle;
              handle = OiSheet.show(
                context,
                label: 'Sample sheet',
                side: side,
                dismissible: dismissible,
                dragHandle: dragHandle,
                size: 300,
                onClose: () => handle.dismiss(),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sheet Content',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('This is a slide-in sheet panel.'),
                      const SizedBox(height: 24),
                      OiButton.ghost(
                        label: 'Close',
                        onTap: () => handle.dismiss(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ),
  ],
);
