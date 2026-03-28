import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiMenuBarComponent = WidgetbookComponent(
  name: 'OiMenuBar',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 800,
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OiMenuBar(
                  label: 'Application menu',
                  items: [
                    OiMenuItem(
                      label: 'File',
                      children: [
                        OiMenuItem(
                          label: 'New File',
                          shortcut: 'Cmd+N',
                          icon: Icons.note_add,
                          onTap: () {},
                        ),
                        OiMenuItem(
                          label: 'Open...',
                          shortcut: 'Cmd+O',
                          icon: Icons.folder_open,
                          onTap: () {},
                        ),
                        const OiMenuDivider(),
                        OiMenuItem(
                          label: 'Save',
                          shortcut: 'Cmd+S',
                          icon: Icons.save,
                          onTap: () {},
                        ),
                        OiMenuItem(
                          label: 'Save As...',
                          shortcut: 'Cmd+Shift+S',
                          onTap: () {},
                        ),
                        const OiMenuDivider(),
                        OiMenuItem(
                          label: 'Delete',
                          destructive: true,
                          onTap: () {},
                        ),
                      ],
                    ),
                    OiMenuItem(
                      label: 'Edit',
                      children: [
                        OiMenuItem(
                          label: 'Undo',
                          shortcut: 'Cmd+Z',
                          onTap: () {},
                        ),
                        OiMenuItem(
                          label: 'Redo',
                          shortcut: 'Cmd+Shift+Z',
                          onTap: () {},
                        ),
                        const OiMenuDivider(),
                        OiMenuItem(
                          label: 'Cut',
                          shortcut: 'Cmd+X',
                          onTap: () {},
                        ),
                        OiMenuItem(
                          label: 'Copy',
                          shortcut: 'Cmd+C',
                          onTap: () {},
                        ),
                        OiMenuItem(
                          label: 'Paste',
                          shortcut: 'Cmd+V',
                          onTap: () {},
                        ),
                      ],
                    ),
                    OiMenuItem(
                      label: 'View',
                      children: [
                        OiMenuItem(
                          label: 'Word Wrap',
                          checked: true,
                          onTap: () {},
                        ),
                        OiMenuItem(
                          label: 'Minimap',
                          checked: false,
                          onTap: () {},
                        ),
                        const OiMenuDivider(),
                        OiMenuItem(
                          label: 'Zoom In',
                          shortcut: 'Cmd+=',
                          onTap: () {},
                        ),
                        OiMenuItem(
                          label: 'Zoom Out',
                          shortcut: 'Cmd+-',
                          onTap: () {},
                        ),
                        const OiMenuDivider(),
                        const OiMenuItem(
                          label: 'Full Screen (disabled)',
                          enabled: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  ],
);
