import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

const _sampleItems = [
  OiNavMenuItem(id: 'all', label: 'All Files', icon: Icons.folder),
  OiNavMenuItem(id: 'recent', label: 'Recent', icon: Icons.access_time),
  OiNavMenuItem(
    id: 'starred',
    label: 'Starred',
    icon: Icons.star,
    badgeCount: 5,
  ),
  OiNavMenuItem(
    id: 'trash',
    label: 'Trash',
    icon: Icons.delete,
    disabled: true,
  ),
];

final oiNavMenuComponent = WidgetbookComponent(
  name: 'OiNavMenu',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final reorderable = context.knobs.boolean(label: 'Reorderable');

        return StatefulBuilder(
          builder: (context, setState) {
            var selectedId = 'all';
            return SizedBox(
              width: 260,
              child: OiNavMenu(
                label: 'File navigation',
                items: _sampleItems,
                selectedId: selectedId,
                onSelect: (id) => setState(() => selectedId = id),
                reorderable: reorderable,
              ),
            );
          },
        );
      },
    ),
  ],
);
