import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_example/apps/component_library/shared/component_showcase_section.dart';

/// Showcase screen for navigation-related widgets.
class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  // ── OiTabs state ──────────────────────────────────────────────────────────
  int _tabIndex = 0;
  int _tabFilledIndex = 0;
  int _tabPillIndex = 0;

  // ── OiBottomBar state ─────────────────────────────────────────────────────
  int _bottomBarIndex = 0;

  // ── OiNavigationRail state ────────────────────────────────────────────────
  int _railIndex = 0;

  // ── OiPagination state ────────────────────────────────────────────────────
  int _currentPage = 0;
  int _compactPage = 0;
  int _loadedCount = 25;
  int _perPage = 25;

  // ── OiThemeToggle state ───────────────────────────────────────────────────
  OiThemeMode _themeMode = OiThemeMode.light;

  // ── OiLocaleSwitcher state ────────────────────────────────────────────────
  Locale _currentLocale = const Locale('en');

  // ── OiDrawer state ────────────────────────────────────────────────────────
  bool _drawerOpen = false;

  // ── OiFilterBar state ─────────────────────────────────────────────────────
  Map<String, OiColumnFilter> _activeFilters = {};

  // ── OiArrowNav state ──────────────────────────────────────────────────────
  int? _arrowHighlight;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OiLabel.h2('Navigation'),
          SizedBox(height: spacing.xs),
          OiLabel.body(
            'Widgets for navigating between pages, sections, and states.',
            color: context.colors.textSubtle,
          ),
          SizedBox(height: spacing.xl),

          // ── 1. OiTabs ─────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Tabs',
            widgetName: 'OiTabs',
            description:
                'A horizontal tab bar with animated selection indicators. '
                'Supports underline, filled, and pill indicator styles.',
            examples: [
              ComponentExample(
                title: 'Underline (default)',
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: OiTabs(
                    tabs: const [
                      OiTabItem(label: 'Overview'),
                      OiTabItem(label: 'Details'),
                      OiTabItem(label: 'Settings'),
                    ],
                    selectedIndex: _tabIndex,
                    onSelected: (i) => setState(() => _tabIndex = i),
                  ),
                ),
              ),
              ComponentExample(
                title: 'Filled indicator',
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: OiTabs(
                    tabs: const [
                      OiTabItem(label: 'Active'),
                      OiTabItem(label: 'Pending'),
                      OiTabItem(label: 'Archived'),
                    ],
                    selectedIndex: _tabFilledIndex,
                    onSelected: (i) => setState(() => _tabFilledIndex = i),
                    indicatorStyle: OiTabIndicatorStyle.filled,
                  ),
                ),
              ),
              ComponentExample(
                title: 'Pill indicator',
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: OiTabs(
                    tabs: const [
                      OiTabItem(label: 'Day'),
                      OiTabItem(label: 'Week'),
                      OiTabItem(label: 'Month'),
                    ],
                    selectedIndex: _tabPillIndex,
                    onSelected: (i) => setState(() => _tabPillIndex = i),
                    indicatorStyle: OiTabIndicatorStyle.pill,
                  ),
                ),
              ),
            ],
          ),

          // ── 2. OiAccordion ────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Accordion',
            widgetName: 'OiAccordion',
            description:
                'Vertically stacked collapsible sections. Only one section '
                'is open at a time by default.',
            examples: [
              ComponentExample(
                title: 'Default (single open)',
                child: OiAccordion(
                  sections: [
                    OiAccordionSection(
                      title: 'What is ObersUI?',
                      content: OiLabel.body(
                        'A comprehensive Flutter UI library with 160+ widgets '
                        'organized in a 4-tier architecture.',
                      ),
                    ),
                    OiAccordionSection(
                      title: 'How do I get started?',
                      content: OiLabel.body(
                        'Add obers_ui to your pubspec.yaml and import '
                        'package:obers_ui/obers_ui.dart.',
                      ),
                    ),
                    OiAccordionSection(
                      title: 'Is it free to use?',
                      content: OiLabel.body(
                        'Yes, ObersUI is open-source and free for commercial '
                        'and personal projects.',
                      ),
                    ),
                  ],
                ),
              ),
              ComponentExample(
                title: 'Allow multiple open',
                child: OiAccordion(
                  allowMultiple: true,
                  sections: [
                    OiAccordionSection(
                      title: 'Section A',
                      content: OiLabel.body('Content for section A.'),
                      initiallyExpanded: true,
                    ),
                    OiAccordionSection(
                      title: 'Section B',
                      content: OiLabel.body('Content for section B.'),
                    ),
                    OiAccordionSection(
                      title: 'Section C',
                      content: OiLabel.body('Content for section C.'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── 3. OiBreadcrumbs ──────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Breadcrumbs',
            widgetName: 'OiBreadcrumbs',
            description:
                'A horizontal breadcrumb trail with optional item collapsing. '
                'The last item is always non-interactive.',
            examples: [
              ComponentExample(
                title: 'Standard breadcrumb trail',
                child: OiBreadcrumbs(
                  items: [
                    OiBreadcrumbItem(label: 'Home', onTap: () {}),
                    OiBreadcrumbItem(label: 'Products', onTap: () {}),
                    OiBreadcrumbItem(label: 'Electronics', onTap: () {}),
                    const OiBreadcrumbItem(label: 'Headphones'),
                  ],
                ),
              ),
            ],
          ),

          // ── 4. OiBottomBar ────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Bottom Bar',
            widgetName: 'OiBottomBar',
            description:
                'A bottom navigation bar with icon + label items. '
                'Supports fixed, shifting, labeled, and icon-only styles.',
            examples: [
              ComponentExample(
                title: 'Fixed style',
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SizedBox(
                    height: 80,
                    child: MediaQuery(
                      data: const MediaQueryData(size: Size(400, 800)),
                      child: OiBottomBar(
                        items: OiBottomBar.fromNavigationItems(const [
                          OiNavigationItem(icon: OiIcons.home, label: 'Home'),
                          OiNavigationItem(
                            icon: OiIcons.search,
                            label: 'Search',
                          ),
                          OiNavigationItem(icon: OiIcons.bell, label: 'Alerts'),
                          OiNavigationItem(
                            icon: OiIcons.user,
                            label: 'Profile',
                          ),
                        ]),
                        currentIndex: _bottomBarIndex,
                        onTap: (i) => setState(() => _bottomBarIndex = i),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── 5. OiNavigationRail ───────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Navigation Rail',
            widgetName: 'OiNavigationRail',
            description:
                'A compact vertical navigation strip for persistent '
                'top-level navigation on medium and larger screens.',
            examples: [
              ComponentExample(
                title: 'Default rail',
                child: SizedBox(
                  height: 300,
                  width: 80,
                  child: OiNavigationRail(
                    items: const [
                      OiNavigationItem(icon: OiIcons.home, label: 'Home'),
                      OiNavigationItem(icon: OiIcons.search, label: 'Search'),
                      OiNavigationItem(
                        icon: OiIcons.settings,
                        label: 'Settings',
                      ),
                    ],
                    currentIndex: _railIndex,
                    onTap: (i) => setState(() => _railIndex = i),
                  ),
                ),
              ),
            ],
          ),

          // ── 6. OiDrawer ───────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Drawer',
            widgetName: 'OiDrawer',
            description:
                'A slide-in navigation panel from the left edge with a '
                'scrim overlay. Best used as a full-screen overlay.',
            examples: [
              ComponentExample(
                title: 'Drawer preview (constrained)',
                child: SizedBox(
                  width: double.infinity,
                  child: SizedBox(
                    height: 200,
                    child: ClipRect(
                      child: Stack(
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 150),
                              child: OiButton.primary(
                                label: _drawerOpen
                                    ? 'Close drawer'
                                    : 'Open drawer',
                                fullWidth: true,
                                onTap: () =>
                                    setState(() => _drawerOpen = !_drawerOpen),
                              ),
                            ),
                          ),
                          OiDrawer(
                            open: _drawerOpen,
                            onClose: () => setState(() => _drawerOpen = false),
                            width: 200,
                            child: Padding(
                              padding: EdgeInsets.all(spacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const OiLabel.bodyStrong('Navigation'),
                                  SizedBox(height: spacing.md),
                                  const OiLabel.body('Home'),
                                  SizedBox(height: spacing.sm),
                                  const OiLabel.body('Settings'),
                                  SizedBox(height: spacing.sm),
                                  const OiLabel.body('Profile'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── 7. OiPagination ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Pagination',
            widgetName: 'OiPagination',
            description:
                'Navigation controls for paged data. Available in pages, '
                'compact, and load-more variants.',
            examples: [
              ComponentExample(
                title: 'Pages variant (default)',
                child: OiPagination(
                  totalItems: 250,
                  currentPage: _currentPage,
                  perPage: _perPage,
                  label: 'Results pagination',
                  onPageChange: (p) => setState(() => _currentPage = p),
                  onPerPageChange: (pp) => setState(() {
                    _perPage = pp;
                    _currentPage = 0;
                  }),
                ),
              ),
              ComponentExample(
                title: 'Compact variant',
                child: OiPagination.compact(
                  totalItems: 100,
                  currentPage: _compactPage,
                  label: 'Compact pagination',
                  onPageChange: (p) => setState(() => _compactPage = p),
                ),
              ),
              ComponentExample(
                title: 'Load more variant',
                child: OiPagination.loadMore(
                  loadedCount: _loadedCount,
                  totalItems: 100,
                  label: 'Load more pagination',
                  onLoadMore: () => setState(
                    () => _loadedCount = (_loadedCount + 25).clamp(0, 100),
                  ),
                ),
              ),
            ],
          ),

          // ── 8. OiUserMenu ─────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'User Menu',
            widgetName: 'OiUserMenu',
            description:
                'An avatar-triggered dropdown showing user info and account '
                'actions.',
            examples: [
              ComponentExample(
                title: 'Default user menu',
                child: OiUserMenu(
                  label: 'User menu',
                  userName: 'Jane Doe',
                  userEmail: 'jane@example.com',
                  avatarInitials: 'JD',
                  items: [
                    OiMenuItem(
                      label: 'Profile',
                      icon: OiIcons.user,
                      onTap: () {},
                    ),
                    OiMenuItem(
                      label: 'Settings',
                      icon: OiIcons.settings,
                      onTap: () {},
                    ),
                    const OiMenuDivider(),
                    OiMenuItem(
                      label: 'Log out',
                      icon: OiIcons.logOut,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── 9. OiThemeToggle ──────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Theme Toggle',
            widgetName: 'OiThemeToggle',
            description:
                'A toggle button that switches between light, dark, and '
                'system theme modes.',
            examples: [
              ComponentExample(
                title: 'With system option',
                child: OiThemeToggle(
                  currentMode: _themeMode,
                  onModeChange: (m) => setState(() => _themeMode = m),
                ),
              ),
              ComponentExample(
                title: 'Without system option (cycles light/dark)',
                child: OiThemeToggle(
                  currentMode: _themeMode,
                  onModeChange: (m) => setState(() => _themeMode = m),
                  showSystemOption: false,
                ),
              ),
            ],
          ),

          // ── 10. OiLocaleSwitcher ──────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Locale Switcher',
            widgetName: 'OiLocaleSwitcher',
            description:
                'A dropdown for switching the application locale. Shows '
                'flag emoji and locale name.',
            examples: [
              ComponentExample(
                title: 'Language selector',
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 80),
                    child: OiLocaleSwitcher(
                      currentLocale: _currentLocale,
                      locales: const [
                        OiLocaleOption(
                          locale: Locale('en'),
                          name: 'English',
                          flagEmoji: '\u{1F1FA}\u{1F1F8}',
                        ),
                        OiLocaleOption(
                          locale: Locale('de'),
                          name: 'Deutsch',
                          flagEmoji: '\u{1F1E9}\u{1F1EA}',
                        ),
                        OiLocaleOption(
                          locale: Locale('fr'),
                          name: 'Fran\u00e7ais',
                          flagEmoji: '\u{1F1EB}\u{1F1F7}',
                        ),
                      ],
                      onLocaleChange: (l) => setState(() => _currentLocale = l),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── 11. OiFilterBar ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Filter Bar',
            widgetName: 'OiFilterBar',
            description:
                'A bar of filter chips that open input controls. Supports '
                'text, select, date, and number filter types.',
            examples: [
              ComponentExample(
                title: 'Text and select filters',
                child: OiFilterBar(
                  filters: const [
                    OiFilterDefinition(
                      key: 'name',
                      label: 'Name',
                      type: OiFilterType.text,
                    ),
                    OiFilterDefinition(
                      key: 'status',
                      label: 'Status',
                      type: OiFilterType.select,
                      options: [
                        OiSelectOption(value: 'active', label: 'Active'),
                        OiSelectOption(value: 'inactive', label: 'Inactive'),
                        OiSelectOption(value: 'pending', label: 'Pending'),
                      ],
                    ),
                  ],
                  activeFilters: _activeFilters,
                  onFilterChange: (filters) =>
                      setState(() => _activeFilters = filters),
                ),
              ),
            ],
          ),

          // ── 12. OiArrowNav ────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Arrow Navigation',
            widgetName: 'OiArrowNav',
            description:
                'A keyboard-driven navigation behavior widget. Wraps a list '
                'of children and enables arrow key navigation between them.',
            examples: [
              ComponentExample(
                title: 'Vertical arrow navigation',
                child: OiArrowNav(
                  itemCount: 3,
                  highlightedIndex: _arrowHighlight,
                  onHighlightChange: (i) => setState(() => _arrowHighlight = i),
                  onSelect: (i) {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < 3; i++)
                        Container(
                          padding: EdgeInsets.all(spacing.sm),
                          decoration: BoxDecoration(
                            color: _arrowHighlight == i
                                ? context.colors.primary.base.withValues(
                                    alpha: 0.1,
                                  )
                                : null,
                          ),
                          child: OiLabel.body('Item ${i + 1}'),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── 13. OiPathBar ─────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Path Bar',
            widgetName: 'OiPathBar',
            description:
                'A dual-mode path navigation bar. Shows clickable breadcrumb '
                'segments and can switch to an editable text input mode.',
            examples: [
              ComponentExample(
                title: 'File path navigation',
                child: OiPathBar(
                  segments: [
                    OiPathSegment(id: 'home', label: 'Home', onTap: () {}),
                    OiPathSegment(id: 'docs', label: 'Documents', onTap: () {}),
                    const OiPathSegment(id: 'reports', label: 'Reports'),
                  ],
                  onNavigate: (_) {},
                ),
              ),
            ],
          ),

          // ── OiMenuBar ──────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Menu Bar',
            widgetName: 'OiMenuBar',
            description:
                'A horizontal desktop-style menu bar with dropdown menus. '
                'Uses OiMenuItem for top-level entries and nested children. '
                'Supports keyboard navigation and dividers.',
            examples: [
              ComponentExample(
                title: 'Application menu',
                child: OiMenuBar(
                  label: 'App menu',
                  items: [
                    OiMenuItem(
                      label: 'File',
                      children: [
                        OiMenuItem(label: 'New', onTap: () {}),
                        OiMenuItem(label: 'Open', onTap: () {}),
                        OiMenuItem(label: 'Save', onTap: () {}),
                        const OiMenuDivider(),
                        OiMenuItem(label: 'Exit', onTap: () {}),
                      ],
                    ),
                    OiMenuItem(
                      label: 'Edit',
                      children: [
                        OiMenuItem(label: 'Undo', onTap: () {}),
                        OiMenuItem(label: 'Redo', onTap: () {}),
                        const OiMenuDivider(),
                        OiMenuItem(label: 'Cut', onTap: () {}),
                        OiMenuItem(label: 'Copy', onTap: () {}),
                        OiMenuItem(label: 'Paste', onTap: () {}),
                      ],
                    ),
                    OiMenuItem(
                      label: 'View',
                      children: [
                        OiMenuItem(label: 'Zoom In', onTap: () {}),
                        OiMenuItem(label: 'Zoom Out', onTap: () {}),
                        OiMenuItem(label: 'Reset Zoom', onTap: () {}),
                      ],
                    ),
                    OiMenuItem(
                      label: 'Help',
                      children: [
                        OiMenuItem(label: 'Documentation', onTap: () {}),
                        OiMenuItem(label: 'About', onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiStatusBar ────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Status Bar',
            widgetName: 'OiStatusBar',
            description:
                'A compact bottom status bar with leading and trailing '
                'widget slots. Ideal for showing editor-style status '
                'information like file encoding, line numbers, and '
                'git branch.',
            examples: [
              ComponentExample(
                title: 'Editor status bar',
                child: OiStatusBar(
                  label: 'Editor status',
                  leading: [
                    OiStatusBarItem(label: 'main', icon: OiIcons.gitBranch),
                    OiStatusBarItem(label: '0 errors', icon: OiIcons.circleX),
                  ],
                  trailing: [
                    OiStatusBarItem(label: 'UTF-8'),
                    OiStatusBarItem(label: 'Ln 42, Col 8'),
                    OiStatusBarItem(label: 'Dart', icon: OiIcons.code),
                  ],
                ),
              ),
            ],
          ),

          // ── OiFilterableNavList ─────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Filterable Nav List',
            widgetName: 'OiFilterableNavList',
            description:
                'A navigation list with search filtering, chip filters, '
                'and collapsible groups. Generic over item type. '
                'Commonly used in master-detail layouts.',
            examples: [
              ComponentExample(
                title: 'Project navigation',
                child: SizedBox(
                  height: 350,
                  width: 280,
                  child:
                      OiFilterableNavList<
                        ({String id, String title, String group})
                      >(
                        label: 'Projects',
                        items: const [
                          (id: '1', title: 'Website Redesign', group: 'active'),
                          (id: '2', title: 'Mobile App', group: 'active'),
                          (id: '3', title: 'API Refactor', group: 'active'),
                          (id: '4', title: 'Docs Site', group: 'completed'),
                          (id: '5', title: 'CI Pipeline', group: 'completed'),
                        ],
                        groups: const [
                          OiNavGroup(id: 'active', label: 'Active'),
                          OiNavGroup(id: 'completed', label: 'Completed'),
                        ],
                        idOf: (item) => item.id,
                        groupIdOf: (item) => item.group,
                        titleOf: (item) => item.title,
                        selectedItemId: '1',
                        onItemSelected: (_) {},
                      ),
                ),
              ),
            ],
          ),

          // ── OiThreeColumnLayout ─────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Three Column Layout',
            widgetName: 'OiThreeColumnLayout',
            description:
                'A configurable three-column layout with resizable '
                'dividers. Common for IDE-style layouts with sidebar, '
                'content area, and detail/preview panel.',
            examples: [
              ComponentExample(
                title: 'Mail client layout',
                child: SizedBox(
                  height: 300,
                  child: OiThreeColumnLayout(
                    label: 'Mail layout',
                    leftColumnWidth: 180,
                    leftColumnMinWidth: 140,
                    rightColumnWidth: 220,
                    leftColumn: ColoredBox(
                      color: context.colors.surfaceSubtle,
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: OiLabel.bodyStrong('Folders'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: OiLabel.body('Inbox'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: OiLabel.body('Sent'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: OiLabel.body('Drafts'),
                          ),
                        ],
                      ),
                    ),
                    middleColumn: const Center(
                      child: OiLabel.body('Message list'),
                    ),
                    rightColumn: const Center(
                      child: OiLabel.body('Message preview'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
