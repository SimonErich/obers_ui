import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiShortcutsComponent = WidgetbookComponent(
  name: 'OiShortcuts',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            var lastAction = 'None';
            final bindings = [
              OiShortcutBinding(
                activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyS),
                label: 'Save',
                category: 'File',
                onInvoke: () => setState(() => lastAction = 'Save'),
              ),
              OiShortcutBinding(
                activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyZ),
                label: 'Undo',
                category: 'Edit',
                onInvoke: () => setState(() => lastAction = 'Undo'),
              ),
              OiShortcutBinding(
                activator: OiShortcutActivator.primary(
                  LogicalKeyboardKey.keyZ,
                  shift: true,
                ),
                label: 'Redo',
                category: 'Edit',
                onInvoke: () => setState(() => lastAction = 'Redo'),
              ),
            ];
            return OiShortcuts(
              shortcuts: bindings,
              child: useCaseWrapper(
                Text('Last action: $lastAction\n\nPress ? for help overlay'),
              ),
            );
          },
        );
      },
    ),
  ],
);
