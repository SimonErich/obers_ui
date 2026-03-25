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
              ComponentShowcaseSection(
                title: 'Combo Box',
                widgetName: 'OiComboBox',
                description:
                    'A searchable select box with type-ahead filtering. '
                    'Supports async search, multi-select, grouping, '
                    'create-new, and virtualization.',
                examples: [
                  ComponentExample(
                    title: 'Searchable dropdown',
                    child: SizedBox(
                      width: 300,
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
                  ),
                ],
              ),

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
}
