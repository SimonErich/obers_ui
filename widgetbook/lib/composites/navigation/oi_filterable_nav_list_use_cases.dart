import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

// A simple item type for the demo.
class _NavItem {
  const _NavItem({
    required this.id,
    required this.title,
    required this.groupId,
    this.subtitle,
    this.icon,
    this.chipIds = const {},
  });

  final String id;
  final String title;
  final String groupId;
  final String? subtitle;
  final IconData? icon;
  final Set<String> chipIds;
}

const _groups = [
  OiNavGroup(id: 'screens', label: 'Screens'),
  OiNavGroup(id: 'components', label: 'Components', sortOrder: 1),
  OiNavGroup(id: 'assets', label: 'Assets', sortOrder: 2),
];

const _chipFilters = [
  OiChipFilter(id: 'new', label: 'New', color: OiBadgeColor.success),
  OiChipFilter(id: 'modified', label: 'Modified', color: OiBadgeColor.warning),
  OiChipFilter(id: 'error', label: 'Error', color: OiBadgeColor.error),
];

const _items = [
  _NavItem(
    id: 's1',
    title: 'Login Screen',
    groupId: 'screens',
    subtitle: 'Authentication flow',
    icon: Icons.login,
    chipIds: {'new'},
  ),
  _NavItem(
    id: 's2',
    title: 'Dashboard',
    groupId: 'screens',
    subtitle: 'Main overview',
    icon: Icons.dashboard,
    chipIds: {'modified'},
  ),
  _NavItem(
    id: 's3',
    title: 'Settings',
    groupId: 'screens',
    subtitle: 'App configuration',
    icon: Icons.settings,
  ),
  _NavItem(
    id: 'c1',
    title: 'Header',
    groupId: 'components',
    subtitle: 'Shared navigation header',
    icon: Icons.web,
    chipIds: {'modified'},
  ),
  _NavItem(
    id: 'c2',
    title: 'Footer',
    groupId: 'components',
    subtitle: 'Shared page footer',
    icon: Icons.web,
  ),
  _NavItem(
    id: 'c3',
    title: 'Sidebar',
    groupId: 'components',
    subtitle: 'Navigation sidebar',
    icon: Icons.view_sidebar,
    chipIds: {'error'},
  ),
  _NavItem(
    id: 'a1',
    title: 'Logo',
    groupId: 'assets',
    subtitle: 'Brand mark SVG',
    icon: Icons.image,
  ),
  _NavItem(
    id: 'a2',
    title: 'Icon Set',
    groupId: 'assets',
    subtitle: '48 custom icons',
    icon: Icons.emoji_symbols,
    chipIds: {'new'},
  ),
];

final oiFilterableNavListComponent = WidgetbookComponent(
  name: 'OiFilterableNavList',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final showChipFilters = context.knobs.boolean(
          label: 'Show Chip Filters',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 280,
            height: 500,
            child: OiFilterableNavList<_NavItem>(
              label: 'Project navigator',
              items: _items,
              groups: _groups,
              idOf: (item) => item.id,
              groupIdOf: (item) => item.groupId,
              titleOf: (item) => item.title,
              subtitleOf: (item) => item.subtitle ?? '',
              iconOf: (item) => item.icon ?? Icons.circle,
              chipFilters: showChipFilters ? _chipFilters : null,
              chipFilterOf: (item) => item.chipIds,
              selectedItemId: 's2',
              onItemSelected: (_) {},
            ),
          ),
        );
      },
    ),
  ],
);
