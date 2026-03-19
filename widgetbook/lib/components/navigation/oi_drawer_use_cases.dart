import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiDrawerComponent = WidgetbookComponent(
  name: 'OiDrawer',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final width = context.knobs.double.slider(
          label: 'Width',
          initialValue: 280,
          min: 200,
          max: 400,
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
                      label: 'Open Drawer',
                      onTap: () => setState(() => open = true),
                    ),
                  ),
                  OiDrawer(
                    open: open,
                    width: width,
                    onClose: () => setState(() => open = false),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Drawer Content',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 16),
                          OiListTile(
                            title: 'Home',
                            leading: const Icon(Icons.home, size: 20),
                            onTap: () {},
                          ),
                          OiListTile(
                            title: 'Settings',
                            leading: const Icon(Icons.settings, size: 20),
                            onTap: () {},
                          ),
                        ],
                      ),
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
