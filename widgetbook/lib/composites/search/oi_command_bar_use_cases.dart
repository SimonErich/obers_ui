import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final _sampleCommands = [
  OiCommand(
    id: 'open',
    label: 'Open File',
    icon: Icons.folder_open,
    category: 'File',
    shortcut: OiShortcutActivator.primary(LogicalKeyboardKey.keyO),
  ),
  OiCommand(
    id: 'save',
    label: 'Save',
    icon: Icons.save,
    category: 'File',
    shortcut: OiShortcutActivator.primary(LogicalKeyboardKey.keyS),
  ),
  const OiCommand(
    id: 'theme',
    label: 'Toggle Theme',
    icon: Icons.brightness_6,
    category: 'View',
  ),
  const OiCommand(
    id: 'settings',
    label: 'Open Settings',
    icon: Icons.settings,
    category: 'View',
    description: 'Open the application settings panel',
  ),
];

final oiCommandBarComponent = WidgetbookComponent(
  name: 'OiCommandBar',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 500,
            height: 400,
            child: OiCommandBar(
              label: 'Command palette',
              commands: _sampleCommands,
            ),
          ),
        );
      },
    ),
  ],
);
