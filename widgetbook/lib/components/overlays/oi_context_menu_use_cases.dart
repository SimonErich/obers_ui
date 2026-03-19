import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiContextMenuComponent = WidgetbookComponent(
  name: 'OiContextMenu',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        return useCaseWrapper(
          OiContextMenu(
            label: 'File actions',
            items: [
              OiMenuItem(
                label: 'Open',
                icon: Icons.open_in_new,
                onTap: () {},
              ),
              OiMenuItem(
                label: 'Rename',
                icon: Icons.edit,
                onTap: () {},
              ),
              const OiMenuItem(label: '', separator: true),
              OiMenuItem(
                label: 'Delete',
                icon: Icons.delete,
                onTap: () {},
              ),
              const OiMenuItem(
                label: 'Disabled item',
                disabled: true,
              ),
            ],
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Right-click or long-press here'),
              ),
            ),
          ),
        );
      },
    ),
  ],
);
