import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

class _SampleItem {
  const _SampleItem({
    required this.id,
    required this.title,
    required this.subtitle,
  });
  final String id;
  final String title;
  final String subtitle;
}

const _sampleItems = [
  _SampleItem(
    id: '1',
    title: 'Design System Tokens',
    subtitle: 'Define color, spacing, and typography tokens',
  ),
  _SampleItem(
    id: '2',
    title: 'Button Component',
    subtitle: 'Primary, secondary, ghost, and destructive variants',
  ),
  _SampleItem(
    id: '3',
    title: 'Input Fields',
    subtitle: 'Text input, search, and textarea components',
  ),
  _SampleItem(
    id: '4',
    title: 'Modal Dialogs',
    subtitle: 'Confirmation, form, and alert dialog patterns',
  ),
  _SampleItem(
    id: '5',
    title: 'Navigation Bar',
    subtitle: 'Top bar with breadcrumbs and actions',
  ),
];

final _sortOptions = [
  const OiListSortOption(id: 'name', label: 'Name'),
  const OiListSortOption(id: 'date', label: 'Date'),
  const OiListSortOption(id: 'status', label: 'Status'),
];

Widget _buildItem(_SampleItem item) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          item.subtitle,
          style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
        ),
      ],
    ),
  );
}

final oiListViewComponent = WidgetbookComponent(
  name: 'OiListView',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final loading = context.knobs.boolean(label: 'Loading');
        final showSearch = context.knobs.boolean(
          label: 'Show Search',
          initialValue: true,
        );
        final showSort = context.knobs.boolean(
          label: 'Show Sort Options',
          initialValue: true,
        );
        final moreAvailable = context.knobs.boolean(label: 'More Available');

        return useCaseWrapper(
          SizedBox(
            height: 600,
            width: 500,
            child: OiListView<_SampleItem>(
              items: loading ? const [] : _sampleItems,
              itemBuilder: _buildItem,
              itemKey: (item) => item.id,
              label: 'Components',
              onSelectionChange: (_) {},
              loading: loading,
              onSearch: showSearch ? (_) {} : null,
              sortOptions: showSort ? _sortOptions : null,
              activeSort: showSort ? _sortOptions.first : null,
              onSort: showSort ? (_) {} : null,
              moreAvailable: moreAvailable,
              onLoadMore: moreAvailable ? () async {} : null,
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Empty State',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            height: 400,
            width: 500,
            child: OiListView<_SampleItem>(
              items: const [],
              itemBuilder: _buildItem,
              itemKey: (item) => item.id,
              label: 'Empty list',
            ),
          ),
        );
      },
    ),
  ],
);
