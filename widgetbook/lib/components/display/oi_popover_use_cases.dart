import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiPopoverComponent = WidgetbookComponent(
  name: 'OiPopover',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        return useCaseWrapper(
          StatefulBuilder(
            builder: (context, setState) {
              var open = false;
              return OiPopover(
                label: 'Info popover',
                open: open,
                onClose: () => setState(() => open = false),
                anchor: OiButton.primary(
                  label: 'Toggle Popover',
                  onTap: () => setState(() => open = !open),
                ),
                content: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Popover content goes here.'),
                ),
              );
            },
          ),
        );
      },
    ),
  ],
);
