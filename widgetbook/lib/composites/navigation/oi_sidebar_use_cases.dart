import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final _sampleSections = [
  OiSidebarSection(
    title: 'MAIN',
    items: [
      const OiSidebarItem(id: 'home', label: 'Home', icon: Icons.home),
      const OiSidebarItem(
        id: 'inbox',
        label: 'Inbox',
        icon: Icons.inbox,
        badgeCount: 3,
      ),
      const OiSidebarItem(
        id: 'settings',
        label: 'Settings',
        icon: Icons.settings,
      ),
    ],
  ),
  OiSidebarSection(
    title: 'PROJECTS',
    items: [
      const OiSidebarItem(
        id: 'proj1',
        label: 'Project Alpha',
        icon: Icons.folder,
      ),
      const OiSidebarItem(
        id: 'proj2',
        label: 'Project Beta',
        icon: Icons.folder,
        disabled: true,
      ),
    ],
  ),
];

final oiSidebarComponent = WidgetbookComponent(
  name: 'OiSidebar',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final mode = context.knobs.enumKnob<OiSidebarMode>(
          label: 'Mode',
          values: OiSidebarMode.values,
        );
        final resizable = context.knobs.boolean(
          label: 'Resizable',
          initialValue: false,
        );

        return StatefulBuilder(
          builder: (context, setState) {
            var selectedId = 'home';
            return SizedBox(
              height: 500,
              child: OiSidebar(
                label: 'Main navigation',
                sections: _sampleSections,
                selectedId: selectedId,
                onSelect: (id) => setState(() => selectedId = id),
                mode: mode,
                resizable: resizable,
              ),
            );
          },
        );
      },
    ),
  ],
);
