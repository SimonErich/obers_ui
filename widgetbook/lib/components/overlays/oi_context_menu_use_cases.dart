import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

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
                icon: OiIcons.externalLink,
                shortcut: 'Cmd+O',
                onTap: () {},
              ),
              OiMenuItem(
                label: 'Rename',
                icon: OiIcons.pencil,
                shortcut: 'F2',
                onTap: () {},
              ),
              const OiMenuDivider(),
              OiMenuItem(
                label: 'Share',
                icon: OiIcons.share,
                children: [
                  OiMenuItem(label: 'Email', onTap: () {}),
                  OiMenuItem(label: 'Copy Link', onTap: () {}),
                ],
              ),
              const OiMenuDivider(),
              const OiMenuItem(
                label: 'Auto-save',
                icon: OiIcons.check,
                checked: true,
              ),
              const OiMenuItem(label: 'Word wrap', checked: false),
              const OiMenuDivider(),
              const OiMenuItem(label: 'Disabled item', enabled: false),
              OiMenuItem(
                label: 'Delete',
                icon: OiIcons.trash,
                destructive: true,
                onTap: () {},
              ),
            ],
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCCCCCC)),
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
