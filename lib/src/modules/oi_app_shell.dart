import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/navigation/oi_breadcrumbs.dart';
import 'package:obers_ui/src/components/navigation/oi_drawer.dart';
import 'package:obers_ui/src/composites/navigation/oi_sidebar.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_mixin.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/settings/oi_app_shell_settings.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ── Data model ──────────────────────────────────────────────────────────────

/// A navigation item in an [OiAppShell].
///
/// Maps to [OiSidebarSection] / [OiSidebarItem] internally. The [section]
/// field groups items under labeled headers; [dividerBefore] inserts a
/// visual separator.
///
/// {@category Modules}
///
/// Coverage: REQ-0029
@immutable
class OiNavItem {
  /// Creates an [OiNavItem].
  const OiNavItem({
    required this.label,
    required this.icon,
    this.route,
    this.children,
    this.badge,
    this.dividerBefore = false,
    this.section,
  });

  /// Display label for this item.
  final String label;

  /// Icon displayed for this item.
  final IconData icon;

  /// Route string used for active-state matching.
  final String? route;

  /// Nested child navigation items rendered as accordion children.
  final List<OiNavItem>? children;

  /// Optional badge text displayed beside the label.
  final String? badge;

  /// Whether to insert a divider before this item.
  final bool dividerBefore;

  /// Group label — items with the same [section] value are grouped under
  /// a labeled header in the sidebar.
  final String? section;
}

// ── OiAppShell ──────────────────────────────────────────────────────────────

/// A master layout scaffold for admin-style applications.
///
/// Composes a sidebar, top bar (breadcrumbs, title, actions, user menu),
/// and content area. Responds to viewport width:
/// - **Desktop** (≥ [mobileBreakpoint]): sidebar left + top bar + content.
/// - **Mobile** (< [mobileBreakpoint]): sidebar becomes an [OiDrawer] with
///   a hamburger icon in the top bar.
///
/// Sidebar collapse/expand is animatable and persisted via
/// [OiSettingsMixin] when a [settingsDriver] is available.
///
/// {@category Modules}
///
/// Coverage: REQ-0029
class OiAppShell extends StatefulWidget {
  /// Creates an [OiAppShell].
  const OiAppShell({
    required this.child,
    required this.label,
    required this.navigation,
    this.leading,
    this.title,
    this.actions,
    this.userMenu,
    this.sidebarCollapsible = true,
    this.sidebarDefaultCollapsed = false,
    this.sidebarWidth = 256,
    this.sidebarCollapsedWidth = 64,
    this.breadcrumbs,
    this.showBreadcrumbs = true,
    this.mobileBreakpoint = OiBreakpoint.medium,
    this.currentRoute,
    this.onNavigate,
    this.settingsDriver,
    this.settingsKey,
    this.settingsNamespace = 'oi_app_shell',
    super.key,
  });

  /// The main content area.
  final Widget child;

  /// Accessibility label for the shell.
  final String label;

  /// Navigation items rendered in the sidebar.
  final List<OiNavItem> navigation;

  /// Optional logo or app name widget in the sidebar header.
  final Widget? leading;

  /// Optional page title shown in the top bar.
  final String? title;

  /// Optional action widgets for the right side of the top bar.
  final List<Widget>? actions;

  /// Optional user menu widget in the top bar.
  final Widget? userMenu;

  /// Whether the sidebar can be collapsed.
  final bool sidebarCollapsible;

  /// Whether the sidebar starts in collapsed state.
  final bool sidebarDefaultCollapsed;

  /// Sidebar width when fully expanded.
  final double sidebarWidth;

  /// Sidebar width when collapsed (icon-only mode).
  final double sidebarCollapsedWidth;

  /// Breadcrumb items for the top bar.
  final List<OiBreadcrumbItem>? breadcrumbs;

  /// Whether to show breadcrumbs in the top bar.
  final bool showBreadcrumbs;

  /// Breakpoint below which the layout switches to mobile mode.
  final OiBreakpoint mobileBreakpoint;

  /// The currently active route for highlighting.
  final String? currentRoute;

  /// Called when a navigation item is selected.
  final ValueChanged<String>? onNavigate;

  // ── Settings persistence ──────────────────────────────────────────────────

  /// Driver used to persist settings. When `null` settings are not persisted.
  final OiSettingsDriver? settingsDriver;

  /// Sub-key scoping this shell's settings within [settingsNamespace].
  final String? settingsKey;

  /// Top-level namespace for settings storage.
  final String settingsNamespace;

  @override
  State<OiAppShell> createState() => _OiAppShellState();
}

class _OiAppShellState extends State<OiAppShell>
    with OiSettingsMixin<OiAppShell, OiAppShellSettings> {
  bool _sidebarCollapsed = false;
  bool _drawerOpen = false;

  /// Resolved driver: explicit widget prop → OiSettingsProvider → null.
  OiSettingsDriver? _resolvedDriver;

  // ── OiSettingsMixin contract ─────────────────────────────────────────────

  @override
  String get settingsNamespace => widget.settingsNamespace;

  @override
  String? get settingsKey => widget.settingsKey;

  @override
  OiSettingsDriver? get settingsDriver => _resolvedDriver;

  @override
  OiAppShellSettings get defaultSettings =>
      OiAppShellSettings(sidebarCollapsed: widget.sidebarDefaultCollapsed);

  @override
  OiAppShellSettings deserializeSettings(Map<String, dynamic> json) =>
      OiAppShellSettings.fromJson(json);

  @override
  OiAppShellSettings mergeSettings(
    OiAppShellSettings saved,
    OiAppShellSettings defaults,
  ) => saved.mergeWith(defaults);

  // ── Lifecycle ───────────────────────────────────────────────────────────

  @override
  void initState() {
    _resolvedDriver = widget.settingsDriver;
    _sidebarCollapsed = widget.sidebarDefaultCollapsed;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newDriver = widget.settingsDriver ?? OiSettingsProvider.of(context);
    if (newDriver != _resolvedDriver) {
      _resolvedDriver = newDriver;
      if (settingsLoaded) {
        reloadSettings();
      }
    }
    if (settingsLoaded && settingsDriver != null) {
      _applySettings(currentSettings);
    }
  }

  void _applySettings(OiAppShellSettings settings) {
    _sidebarCollapsed = settings.sidebarCollapsed;
  }

  OiAppShellSettings _toSettings() {
    return OiAppShellSettings(sidebarCollapsed: _sidebarCollapsed);
  }

  void _toggleSidebar() {
    setState(() {
      _sidebarCollapsed = !_sidebarCollapsed;
    });
    updateSettings(_toSettings());
  }

  void _handleNavSelect(String id) {
    widget.onNavigate?.call(id);
    if (_drawerOpen) {
      setState(() => _drawerOpen = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bp = context.breakpoint;
    final isMobile = bp.minWidth < widget.mobileBreakpoint.minWidth;

    return Semantics(
      label: widget.label,
      container: true,
      child: isMobile
          ? _buildMobileLayout(context)
          : _buildDesktopLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final colors = context.colors;
    final hasNav = widget.navigation.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasNav)
          AnimatedContainer(
            duration:
                context.animations.reducedMotion ||
                    MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: _sidebarCollapsed
                ? widget.sidebarCollapsedWidth
                : widget.sidebarWidth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(right: BorderSide(color: colors.borderSubtle)),
              ),
              child: _buildSidebar(context),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(context, showHamburger: false),
              Expanded(child: widget.child),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopBar(context, showHamburger: widget.navigation.isNotEmpty),
            Expanded(child: widget.child),
          ],
        ),
        if (widget.navigation.isNotEmpty)
          OiDrawer(
            open: _drawerOpen,
            width: widget.sidebarWidth,
            onClose: () => setState(() => _drawerOpen = false),
            child: _buildSidebar(context),
          ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, {required bool showHamburger}) {
    final colors = context.colors;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.borderSubtle)),
      ),
      child: Row(
        children: [
          if (showHamburger)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: OiTappable(
                semanticLabel: 'Open navigation',
                onTap: () => setState(() => _drawerOpen = true),
                child: Icon(
                  OiIcons.menu, // menu
                  size: 24,
                  color: colors.text,
                ),
              ),
            ),
          if (widget.title != null) OiLabel.h4(widget.title!),
          if (widget.showBreadcrumbs &&
              widget.breadcrumbs != null &&
              widget.breadcrumbs!.isNotEmpty &&
              !showHamburger) ...[
            if (widget.title != null) const SizedBox(width: 16),
            Flexible(
              child: OiBreadcrumbs(items: widget.breadcrumbs!, maxVisible: 3),
            ),
          ],
          const Spacer(),
          if (widget.actions != null)
            for (final action in widget.actions!)
              Padding(padding: const EdgeInsets.only(left: 8), child: action),
          if (widget.userMenu != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: widget.userMenu,
            ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final sections = _navItemsToSections();
    final activeId = _findActiveId(widget.navigation, widget.currentRoute);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.leading != null)
          Padding(padding: const EdgeInsets.all(16), child: widget.leading),
        Expanded(
          child: OiSidebar(
            sections: sections,
            selectedId: activeId,
            onSelect: _handleNavSelect,
            label: widget.label,
            mode: _sidebarCollapsed
                ? OiSidebarMode.compact
                : OiSidebarMode.full,
            width: widget.sidebarWidth,
            compactWidth: widget.sidebarCollapsedWidth,
          ),
        ),
        if (widget.sidebarCollapsible && !_isMobile(context))
          _buildCollapseToggle(context),
      ],
    );
  }

  bool _isMobile(BuildContext context) {
    final bp = context.breakpoint;
    return bp.minWidth < widget.mobileBreakpoint.minWidth;
  }

  Widget _buildCollapseToggle(BuildContext context) {
    final colors = context.colors;
    return OiTappable(
      semanticLabel: _sidebarCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
      onTap: _toggleSidebar,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.borderSubtle)),
        ),
        alignment: Alignment.center,
        child: Icon(
          _sidebarCollapsed
              ? OiIcons.chevronRight // chevron_right
              : OiIcons.chevronLeft, // chevron_left
          size: 20,
          color: colors.textMuted,
        ),
      ),
    );
  }

  List<OiSidebarSection> _navItemsToSections() {
    if (widget.navigation.isEmpty) return const [];

    final sectionMap = <String?, List<OiNavItem>>{};
    final sectionOrder = <String?>[];

    for (final item in widget.navigation) {
      final key = item.section;
      if (!sectionMap.containsKey(key)) {
        sectionMap[key] = [];
        sectionOrder.add(key);
      }
      sectionMap[key]!.add(item);
    }

    final sections = <OiSidebarSection>[];
    for (final key in sectionOrder) {
      final items = sectionMap[key]!;
      final sidebarItems = <OiSidebarItem>[];

      for (final item in items) {
        sidebarItems.add(_navItemToSidebarItem(item));
      }

      sections.add(OiSidebarSection(title: key, items: sidebarItems));
    }

    return sections;
  }

  OiSidebarItem _navItemToSidebarItem(OiNavItem item) {
    int? badgeCount;
    if (item.badge != null) {
      badgeCount = int.tryParse(item.badge!);
    }

    List<OiSidebarItem>? children;
    if (item.children != null && item.children!.isNotEmpty) {
      children = item.children!.map(_navItemToSidebarItem).toList();
    }

    return OiSidebarItem(
      id: item.route ?? item.label,
      label: item.label,
      icon: item.icon,
      badgeCount: badgeCount,
      children: children,
    );
  }

  String? _findActiveId(List<OiNavItem> items, String? currentRoute) {
    if (currentRoute == null) return null;

    for (final item in items) {
      if (item.route == currentRoute) {
        return item.route;
      }
      if (item.children != null) {
        final childMatch = _findActiveId(item.children!, currentRoute);
        if (childMatch != null) return childMatch;
      }
    }

    return null;
  }
}
