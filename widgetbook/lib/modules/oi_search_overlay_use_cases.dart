import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

const _sampleCategories = [
  OiSearchCategory(key: 'docs', label: 'Docs', icon: OiIcons.fileText),
  OiSearchCategory(key: 'code', label: 'Code', icon: OiIcons.code),
  OiSearchCategory(key: 'users', label: 'Users', icon: OiIcons.users),
];

const _sampleSuggestions = [
  OiSearchSuggestion(
    key: '1',
    title: 'Getting Started Guide',
    subtitle: 'Learn the basics of the platform',
    icon: OiIcons.fileText,
    category: 'Docs',
  ),
  OiSearchSuggestion(
    key: '2',
    title: 'Authentication API',
    subtitle: 'REST endpoints for login and registration',
    icon: OiIcons.code,
    category: 'Code',
  ),
  OiSearchSuggestion(
    key: '3',
    title: 'Jane Doe',
    subtitle: 'jane.doe@example.com',
    icon: OiIcons.user,
    category: 'Users',
  ),
  OiSearchSuggestion(
    key: '4',
    title: 'Dashboard Overview',
    subtitle: 'Main dashboard documentation',
    icon: OiIcons.fileText,
    category: 'Docs',
  ),
  OiSearchSuggestion(
    key: '5',
    title: 'Widget Library',
    subtitle: 'Component reference and usage patterns',
    icon: OiIcons.code,
    category: 'Code',
  ),
];

Future<List<OiSearchSuggestion>> _mockSearch(
  String query,
  String? categoryKey,
) async {
  // Simulate network delay.
  await Future<void>.delayed(const Duration(milliseconds: 400));
  final lower = query.toLowerCase();
  return _sampleSuggestions.where((s) {
    final matchesQuery =
        s.title.toLowerCase().contains(lower) ||
        (s.subtitle?.toLowerCase().contains(lower) ?? false);
    final matchesCategory =
        categoryKey == null || s.category?.toLowerCase() == categoryKey;
    return matchesQuery && matchesCategory;
  }).toList();
}

final oiSearchOverlayComponent = WidgetbookComponent(
  name: 'OiSearchOverlay',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final showCategories = context.knobs.boolean(
          label: 'Show Categories',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 700,
            height: 500,
            child: OiSearchOverlay(
              label: 'Search',
              placeholder: 'Search docs, code, users...',
              categories: showCategories ? _sampleCategories : const [],
              onSearch: _mockSearch,
              onSuggestionTap: (s) {},
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'With Recent Searches',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 700,
            height: 500,
            child: OiSearchOverlay(
              label: 'Search',
              recentSearches: const [
                'authentication',
                'dashboard widgets',
                'file upload API',
                'user permissions',
              ],
              categories: _sampleCategories,
              onSearch: _mockSearch,
              onSuggestionTap: (s) {},
              onRecentTap: (q) {},
              onClearRecents: () {},
            ),
          ),
        );
      },
    ),
  ],
);
