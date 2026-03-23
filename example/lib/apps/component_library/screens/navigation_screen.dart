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
              ComponentExample(
                title: 'Filled indicator',
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
              ComponentExample(
                title: 'Pill indicator',
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
                child: SizedBox(
                  height: 80,
                  child: MediaQuery(
                    data: const MediaQueryData(size: Size(400, 800)),
                    child: OiBottomBar(
                      items: OiBottomBar.fromNavigationItems(const [
                        OiNavigationItem(icon: OiIcons.home, label: 'Home'),
                        OiNavigationItem(icon: OiIcons.search, label: 'Search'),
                        OiNavigationItem(icon: OiIcons.bell, label: 'Alerts'),
                        OiNavigationItem(icon: OiIcons.user, label: 'Profile'),
                      ]),
                      currentIndex: _bottomBarIndex,
                      onTap: (i) => setState(() => _bottomBarIndex = i),
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
                  height: 200,
                  child: ClipRect(
                    child: Stack(
                      children: [
                        Center(
                          child: OiButton.primary(
                            label: _drawerOpen ? 'Close drawer' : 'Open drawer',
                            onTap: () =>
                                setState(() => _drawerOpen = !_drawerOpen),
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
                    const OiMenuItem(label: '', separator: true),
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
        ],
      ),
    );
  }
}
