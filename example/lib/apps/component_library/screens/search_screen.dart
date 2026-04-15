import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_example/apps/component_library/shared/component_showcase_section.dart';

/// Showcase screen for search and command palette widgets.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _showCommandBar = false;
  String? _selectedFruit;
  List<String> _selectedFruits = [];
  String? _selectedGroupedItem;
  String? _selectedAsyncFruit;
  String? _selectedCreatable;
  String? _selectedWithSections;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.all(spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── OiSearch ───────────────────────────────────────────────
              ComponentShowcaseSection(
                title: 'Search',
                widgetName: 'OiSearch',
                description:
                    'A global search overlay with multiple data sources, '
                    'category grouping, filters, and a preview pane. '
                    'Spotlight/Alfred-style search experience.',
                examples: [
                  ComponentExample(
                    title: 'Multi-source search',
                    child: SizedBox(
                      height: 400,
                      child: OiSearch(
                        label: 'Search',
                        sources: [
                          OiSearchSource(
                            category: 'Fruits',
                            icon: OiIcons.apple,
                            search: (query) async {
                              final fruits = [
                                'Apple',
                                'Banana',
                                'Cherry',
                                'Date',
                                'Elderberry',
                              ];
                              final filtered = fruits
                                  .where(
                                    (f) => f.toLowerCase().contains(
                                      query.toLowerCase(),
                                    ),
                                  )
                                  .toList();
                              return filtered
                                  .map(
                                    (f) => OiSearchResult(
                                      id: f.toLowerCase(),
                                      title: f,
                                    ),
                                  )
                                  .toList();
                            },
                          ),
                          OiSearchSource(
                            category: 'Pages',
                            icon: OiIcons.fileText,
                            search: (query) async {
                              final pages = [
                                'Dashboard',
                                'Settings',
                                'Profile',
                                'Reports',
                              ];
                              final filtered = pages
                                  .where(
                                    (p) => p.toLowerCase().contains(
                                      query.toLowerCase(),
                                    ),
                                  )
                                  .toList();
                              return filtered
                                  .map(
                                    (p) => OiSearchResult(
                                      id: p.toLowerCase(),
                                      title: p,
                                      subtitle: 'Navigate to $p',
                                    ),
                                  )
                                  .toList();
                            },
                          ),
                        ],
                        onSelect: (_) {},
                        showPreview: false,
                      ),
                    ),
                  ),
                ],
              ),

              // ── OiComboBox ─────────────────────────────────────────────
              _buildComboBoxSection(context),

              // ── OiCommandBar ───────────────────────────────────────────
              ComponentShowcaseSection(
                title: 'Command Bar',
                widgetName: 'OiCommandBar',
                description:
                    'A VS Code/Raycast-style command palette with fuzzy search, '
                    'nested commands, keyboard shortcut display, and category '
                    'grouping. Triggered via a button or keyboard shortcut.',
                examples: [
                  ComponentExample(
                    title: 'Open command palette',
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 180),
                        child: OiButton.primary(
                          label: 'Open Command Bar',
                          icon: OiIcons.terminal,
                          fullWidth: true,
                          onTap: () {
                            setState(() {
                              _showCommandBar = true;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Command bar overlay ────────────────────────────────────────
        if (_showCommandBar)
          OiCommandBar(
            label: 'Command bar',
            commands: [
              OiCommand(
                id: 'nav-dashboard',
                label: 'Go to Dashboard',
                description: 'Navigate to the dashboard',
                category: 'Navigation',
                icon: OiIcons.layoutDashboard,
                onExecute: () {},
              ),
              OiCommand(
                id: 'nav-settings',
                label: 'Go to Settings',
                description: 'Open application settings',
                category: 'Navigation',
                icon: OiIcons.settings,
                onExecute: () {},
              ),
              OiCommand(
                id: 'action-save',
                label: 'Save Document',
                description: 'Save the current document',
                category: 'Actions',
                icon: OiIcons.save,
                onExecute: () {},
              ),
              OiCommand(
                id: 'action-export',
                label: 'Export as PDF',
                description: 'Export the current view as PDF',
                category: 'Actions',
                icon: OiIcons.download,
                onExecute: () {},
              ),
            ],
            onDismiss: () {
              setState(() {
                _showCommandBar = false;
              });
            },
          ),
      ],
    );
  }

  Widget _buildComboBoxCard({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    return Container(
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: radius.md,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OiLabel.caption(title, color: colors.textMuted),
          SizedBox(height: spacing.md),
          child,
        ],
      ),
    );
  }

  Widget _buildComboBoxSection(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final bp = context.breakpoint;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────
          const OiLabel.h3('Combo Box'),
          SizedBox(height: spacing.xs),
          OiLabel.code('OiComboBox', color: colors.primary.base),
          SizedBox(height: spacing.xs),
          OiLabel.body(
            'A searchable select box with type-ahead filtering. '
            'Supports async search, multi-select, grouping, '
            'create-new, and virtualization.',
            color: colors.textSubtle,
          ),
          SizedBox(height: spacing.lg),

          // ── Examples grid ────────────────────────────────────────────
          OiGrid(
            breakpoint: bp,
            columns: OiResponsive.breakpoints({
              OiBreakpoint.compact: 1,
              OiBreakpoint.medium: 2,
              OiBreakpoint.expanded: 3,
            }),
            gap: OiResponsive(spacing.sm),
            rowGap: OiResponsive(spacing.sm),
            children: [
              _buildComboBoxCard(
                context: context,
                title: 'Searchable dropdown',
                child: OiComboBox<String>(
                  label: 'Select fruit',
                  items: const [
                    'Apple',
                    'Banana',
                    'Cherry',
                    'Date',
                    'Elderberry',
                    'Fig',
                    'Grape',
                  ],
                  labelOf: (item) => item,
                  value: _selectedFruit,
                  onSelect: (fruit) {
                    setState(() => _selectedFruit = fruit);
                  },
                  placeholder: 'Type to search...',
                ),
              ),
              _buildComboBoxCard(
                context: context,
                title: 'Multi-select',
                child: OiComboBox<String>(
                  label: 'Select fruits',
                  items: const [
                    'Apple',
                    'Banana',
                    'Cherry',
                    'Date',
                    'Elderberry',
                    'Fig',
                    'Grape',
                  ],
                  labelOf: (item) => item,
                  multiSelect: true,
                  selectedValues: _selectedFruits,
                  onMultiSelect: (fruits) {
                    setState(() => _selectedFruits = fruits);
                  },
                  placeholder: 'Type to search...',
                ),
              ),
              _buildComboBoxCard(
                context: context,
                title: 'Grouped items',
                child: OiComboBox<String>(
                  label: 'Select item',
                  items: const [
                    'Apple',
                    'Banana',
                    'Cherry',
                    'Carrot',
                    'Broccoli',
                    'Spinach',
                    'Salmon',
                    'Chicken',
                    'Tofu',
                  ],
                  labelOf: (item) => item,
                  value: _selectedGroupedItem,
                  onSelect: (item) {
                    setState(() => _selectedGroupedItem = item);
                  },
                  groupBy: (item) {
                    const fruits = ['Apple', 'Banana', 'Cherry'];
                    const vegetables = ['Carrot', 'Broccoli', 'Spinach'];
                    if (fruits.contains(item)) return 'Fruits';
                    if (vegetables.contains(item)) return 'Vegetables';
                    return 'Protein';
                  },
                  groupOrder: const ['Fruits', 'Vegetables', 'Protein'],
                  placeholder: 'Select a food...',
                ),
              ),
              _buildComboBoxCard(
                context: context,
                title: 'Async search',
                child: OiComboBox<String>(
                  label: 'Search fruit',
                  labelOf: (item) => item,
                  value: _selectedAsyncFruit,
                  onSelect: (fruit) {
                    setState(() => _selectedAsyncFruit = fruit);
                  },
                  search: (query) async {
                    // Simulate network delay.
                    await Future<void>.delayed(
                      const Duration(milliseconds: 500),
                    );
                    const allFruits = [
                      'Apple',
                      'Apricot',
                      'Avocado',
                      'Banana',
                      'Blackberry',
                      'Blueberry',
                      'Cherry',
                      'Coconut',
                      'Cranberry',
                      'Dragon fruit',
                      'Elderberry',
                      'Fig',
                      'Grape',
                      'Guava',
                      'Kiwi',
                      'Lemon',
                      'Lime',
                      'Lychee',
                      'Mango',
                      'Melon',
                    ];
                    return allFruits
                        .where(
                          (f) => f.toLowerCase().contains(query.toLowerCase()),
                        )
                        .toList();
                  },
                  placeholder: 'Type to search remotely...',
                ),
              ),
              _buildComboBoxCard(
                context: context,
                title: 'Creatable',
                child: OiComboBox<String>(
                  label: 'Select or create tag',
                  items: const [
                    'Bug',
                    'Feature',
                    'Enhancement',
                    'Documentation',
                  ],
                  labelOf: (item) => item,
                  value: _selectedCreatable,
                  onSelect: (tag) {
                    setState(() => _selectedCreatable = tag);
                  },
                  onCreate: (value) {
                    setState(() => _selectedCreatable = value);
                  },
                  placeholder: 'Select or type new...',
                ),
              ),
              _buildComboBoxCard(
                context: context,
                title: 'Recent & favorites',
                child: OiComboBox<String>(
                  label: 'Select city',
                  items: const [
                    'Amsterdam',
                    'Berlin',
                    'Copenhagen',
                    'Dublin',
                    'Edinburgh',
                    'Florence',
                    'Geneva',
                    'Helsinki',
                  ],
                  labelOf: (item) => item,
                  value: _selectedWithSections,
                  onSelect: (city) {
                    setState(() => _selectedWithSections = city);
                  },
                  recentItems: const ['Berlin', 'Dublin'],
                  favoriteItems: const ['Amsterdam', 'Copenhagen'],
                  placeholder: 'Select a city...',
                ),
              ),
              _buildComboBoxCard(
                context: context,
                title: 'Custom option rendering',
                child: OiComboBox<String>(
                  label: 'Select status',
                  items: const ['Online', 'Away', 'Busy', 'Offline'],
                  labelOf: (item) => item,
                  onSelect: (_) {},
                  placeholder: 'Set your status...',
                  optionBuilder:
                      (
                        item, {
                        required bool highlighted,
                        required bool selected,
                      }) {
                        final color = switch (item) {
                          'Online' => const Color(0xFF22C55E),
                          'Away' => const Color(0xFFEAB308),
                          'Busy' => const Color(0xFFEF4444),
                          _ => const Color(0xFF6B7280),
                        };
                        return Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(item),
                          ],
                        );
                      },
                ),
              ),
              _buildComboBoxCard(
                context: context,
                title: 'Disabled',
                child: OiComboBox<String>(
                  label: 'Select fruit',
                  items: const ['Apple', 'Banana', 'Cherry'],
                  labelOf: (item) => item,
                  value: 'Banana',
                  onSelect: (_) {},
                  enabled: false,
                  placeholder: 'Disabled...',
                ),
              ),
            ],
          ),

          // ── Separator ────────────────────────────────────────────────
          SizedBox(height: spacing.md),
          const OiDivider(),
        ],
      ),
    );
  }
}
