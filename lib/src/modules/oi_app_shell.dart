import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/navigation/oi_breadcrumbs.dart';
import 'package:obers_ui/src/components/navigation/oi_drawer.dart';
import 'package:obers_ui/src/components/navigation/oi_navigation_rail.dart';
import 'package:obers_ui/src/composites/navigation/oi_sidebar.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_mixin.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_navigation_item.dart';
import 'package:obers_ui/src/models/settings/oi_app_shell_settings.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
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
    this.contextChild = false,
    this.monospace = false,
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

  /// A contextual record branch, without a repeated destination icon.
  final bool contextChild;

  /// Uses the semantic code typography role for identifiers.
  final bool monospace;

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
    this.primaryNavigation = const [],
    this.currentPrimaryRoute,
    this.onPrimaryNavigate,
    this.primaryLeading,
    this.primaryTrailing,
    this.navigationHeader,
    this.navigationFooter,
    this.search,
    this.onSearch,
    this.searchLabel = 'Search',
    this.leading,
    this.title,
    this.actions,
    this.userMenu,
    this.sidebarCollapsible = true,
    this.sidebarDefaultCollapsed = false,
    this.sidebarWidth,
    this.sidebarCollapsedWidth,
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

  /// Primary destinations, rendered in a rail beside contextual navigation.
  final List<OiNavItem> primaryNavigation;

  /// Active primary destination route.
  final String? currentPrimaryRoute;

  /// Primary route callback; falls back to onNavigate.
  final ValueChanged<String>? onPrimaryNavigate;

  /// Brand content above the primary destinations.
  final Widget? primaryLeading;

  /// Utility/account content below the primary destinations.
  final Widget? primaryTrailing;

  /// Header above contextual navigation.
  final Widget? navigationHeader;

  /// Footer below contextual navigation.
  final Widget? navigationFooter;

  /// Search trigger or field in the top bar.
  final Widget? search;

  /// Opens search from an icon button when the header is too narrow for [search].
  ///
  /// Also provides a search button when no custom search widget is supplied.
  final VoidCallback? onSearch;

  /// Accessible name of the compact search button.
  final String searchLabel;

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
  final double? sidebarWidth;

  /// Sidebar width when collapsed (icon-only mode).
  final double? sidebarCollapsedWidth;

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
        unawaited(reloadSettings());
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
        if (widget.primaryNavigation.isNotEmpty)
          _buildPrimaryNavigation(context),
        if (hasNav)
          AnimatedContainer(
            duration:
                context.animations.reducedMotion ||
                    MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: _sidebarCollapsed
                ? (widget.sidebarCollapsedWidth ??
                      context.components.sidebar?.compactWidth ??
                      64)
                : (widget.sidebarWidth ??
                      context.components.sidebar?.width ??
                      256),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color:
                    context.components.sidebar?.backgroundColor ??
                    colors.surface,
                border: Border(
                  right: BorderSide(
                    color:
                        context.components.appShell?.borderColor ??
                        colors.borderSubtle,
                  ),
                ),
              ),
              child: _buildSidebar(context),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(context, showHamburger: false),
              Expanded(child: _buildContent()),
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
            _buildTopBar(
              context,
              showHamburger:
                  widget.navigation.isNotEmpty ||
                  widget.primaryNavigation.isNotEmpty,
            ),
            Expanded(child: _buildContent()),
          ],
        ),
        if (widget.navigation.isNotEmpty || widget.primaryNavigation.isNotEmpty)
          OiDrawer(
            open: _drawerOpen,
            width:
                (widget.sidebarWidth ??
                    context.components.sidebar?.width ??
                    256) +
                (widget.primaryNavigation.isEmpty
                    ? 0
                    : context.components.appShell?.primaryNavigationWidth ??
                          64),
            onClose: () => setState(() => _drawerOpen = false),
            child: Row(
              children: [
                if (widget.primaryNavigation.isNotEmpty)
                  _buildPrimaryNavigation(context),
                Expanded(child: _buildSidebar(context)),
              ],
            ),
          ),
      ],
    );
  }

  // A nested Navigator's route barrier must not hide the shell controls
  // painted before it from accessibility traversal.
  Widget _buildContent() => Semantics(
    container: true,
    explicitChildNodes: true,
    child: widget.child,
  );

  Widget _buildTopBar(BuildContext context, {required bool showHamburger}) {
    final colors = context.colors;

    return Container(
      height: context.components.appShell?.topBarHeight ?? 56,
      padding:
          context.components.appShell?.topBarPadding ??
          const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.components.appShell?.backgroundColor ?? colors.surface,
        border: Border(
          bottom: BorderSide(
            color:
                context.components.appShell?.borderColor ?? colors.borderSubtle,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compactSearch =
              widget.onSearch != null &&
              (widget.search == null ||
                  constraints.maxWidth < OiBreakpoint.medium.minWidth);
          return Row(
            children: [
              if (showHamburger)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: OiTappable(
                    semanticLabel: 'Open navigation',
                    onTap: () => setState(() => _drawerOpen = true),
                    child: OiIcon.raw(
                      OiIcons.menu, // menu
                      size: 24,
                      color: colors.text,
                    ),
                  ),
                ),
              Expanded(
                child: Row(
                  children: [
                    if (widget.title != null)
                      Flexible(
                        child: OiLabel.variant(
                          widget.title!,
                          variant: OiLabelVariant.h4,
                          style: context.components.appShell?.titleStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (widget.showBreadcrumbs &&
                        widget.breadcrumbs != null &&
                        widget.breadcrumbs!.isNotEmpty &&
                        !showHamburger) ...[
                      if (widget.title != null) const SizedBox(width: 16),
                      Expanded(
                        child: OiBreadcrumbs(
                          items: widget.breadcrumbs!,
                          maxVisible: 3,
                          linkStyle:
                              context.components.appShell?.breadcrumbLinkStyle,
                          separatorIcon: context
                              .components
                              .appShell
                              ?.breadcrumbSeparatorIcon,
                          separatorSpacing:
                              context.components.appShell?.breadcrumbSpacing ??
                              6,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (compactSearch)
                OiButton.icon(
                  icon: OiIcons.search,
                  label: widget.searchLabel,
                  onTap: widget.onSearch,
                )
              else if (widget.search != null)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        (context.components.appShell?.searchMaxWidth ?? 420)
                            .clamp(0, constraints.maxWidth / 2)
                            .toDouble(),
                  ),
                  child: widget.search,
                ),
              if (widget.actions != null)
                for (final action in widget.actions!)
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: context.components.appShell?.actionSpacing ?? 8,
                    ),
                    child: action,
                  ),
              if (widget.userMenu != null)
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: context.components.appShell?.actionSpacing ?? 8,
                  ),
                  child: widget.userMenu,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final sections = _navItemsToSections();
    final activeId = _findActiveId(widget.navigation, widget.currentRoute);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.navigationHeader != null) widget.navigationHeader!,
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
            width:
                widget.sidebarWidth ?? context.components.sidebar?.width ?? 256,
            compactWidth:
                widget.sidebarCollapsedWidth ??
                context.components.sidebar?.compactWidth ??
                64,
          ),
        ),
        if (widget.navigationFooter != null) widget.navigationFooter!,
        if (widget.sidebarCollapsible && !_isMobile(context))
          _buildCollapseToggle(context),
      ],
    );
  }

  Widget _buildPrimaryNavigation(BuildContext context) {
    final items = widget.primaryNavigation;
    final selected = items.indexWhere(
      (item) => item.route == widget.currentPrimaryRoute,
    );
    return OiNavigationRail(
      items: [
        for (final item in items)
          OiNavigationItem(
            icon: item.icon,
            label: item.label,
            badge: item.badge,
            tooltip: item.label,
          ),
      ],
      currentIndex: selected,
      onTap: (index) {
        final route = items[index].route;
        if (route == null) return;
        (widget.onPrimaryNavigate ?? widget.onNavigate)?.call(route);
        if (_drawerOpen) setState(() => _drawerOpen = false);
      },
      width: context.components.appShell?.primaryNavigationWidth ?? 64,
      leading: widget.primaryLeading,
      trailing: widget.primaryTrailing,
      labelBehavior: OiRailLabelBehavior.none,
      semanticLabel: '${widget.label} primary navigation',
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
        child: OiIcon.raw(
          _sidebarCollapsed
              ? OiIcons
                    .chevronRight // chevron_right
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
      contextChild: item.contextChild,
      monospace: item.monospace,
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
