import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_mixin.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';
import 'package:obers_ui/src/foundation/theme/oi_spacing_scale.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/settings/oi_grouped_list_settings.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

/// How to handle groups with zero items.
///
/// {@category Composites}
enum OiEmptyGroupBehavior {
  /// Don't render the group at all.
  hide,

  /// Show the header with an empty state message.
  showHeader,

  /// Show header and a custom empty state widget.
  showEmpty,
}

/// Controller for [OiGroupedList] — expand, collapse, scroll to group.
///
/// {@category Composites}
class OiGroupedListController extends ChangeNotifier {
  final Set<String> _collapsed = {};
  final Set<String> _knownGroups = {};
  final Map<String, GlobalKey> _headerKeys = {};

  /// Expand a specific group.
  void expandGroup(String groupKey) {
    if (_collapsed.remove(groupKey)) notifyListeners();
  }

  /// Collapse a specific group.
  void collapseGroup(String groupKey) {
    if (_collapsed.add(groupKey)) notifyListeners();
  }

  /// Toggle a group's collapsed state.
  void toggleGroup(String groupKey) {
    if (_collapsed.contains(groupKey)) {
      _collapsed.remove(groupKey);
    } else {
      _collapsed.add(groupKey);
    }
    notifyListeners();
  }

  /// Expand all groups.
  void expandAll() {
    if (_collapsed.isNotEmpty) {
      _collapsed.clear();
      notifyListeners();
    }
  }

  /// Collapse all currently known groups.
  void collapseAll() {
    _collapsed.addAll(_knownGroups);
    notifyListeners();
  }

  /// Whether a group is currently collapsed.
  bool collapsed(String groupKey) => _collapsed.contains(groupKey);

  /// Current set of collapsed group keys (read-only).
  Set<String> get collapsedGroups => Set.unmodifiable(_collapsed);

  /// Scroll to bring a group header into view.
  Future<void> scrollToGroup(String groupKey) async {
    final key = _headerKeys[groupKey];
    if (key?.currentContext != null) {
      await Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
      );
    }
  }
}

/// Data list with automatic grouping, sticky headers, and collapsible
/// sections.
///
/// Groups a flat item list by a key function and renders each group under
/// a section header. Use for contacts, events, categorized products, etc.
///
/// ```dart
/// OiGroupedList<Contact>(
///   items: contacts,
///   itemBuilder: (_, c, __) => OiListTile(title: c.name),
///   groupBy: (c) => c.name[0],
///   label: 'Contacts',
/// )
/// ```
///
/// {@category Composites}
class OiGroupedList<T> extends StatefulWidget {
  /// Creates an [OiGroupedList].
  const OiGroupedList({
    required this.items,
    required this.itemBuilder,
    required this.groupBy,
    required this.label,
    this.headerBuilder,
    this.groupOrder,
    this.collapsible = false,
    this.initiallyCollapsed,
    this.emptyGroupBehavior = OiEmptyGroupBehavior.hide,
    this.emptyState,
    this.separator,
    this.groupSeparator,
    this.onLoadMore,
    this.moreAvailable = false,
    this.loading = false,
    this.padding,
    this.controller,
    this.groupedListController,
    this.semanticLabel,
    this.itemKey,
    this.stickyHeaders = true,
    this.onRefresh,
    this.physics,
    this.settingsDriver,
    this.settingsKey,
    super.key,
  });

  /// Flat list of all items. Grouped automatically via [groupBy].
  final List<T> items;

  /// Builds the widget for each item.
  final Widget Function(BuildContext context, T item, int indexInGroup)
  itemBuilder;

  /// Returns the group key for an item.
  final String Function(T item) groupBy;

  /// Accessibility label for the list.
  final String label;

  /// Builds the section header widget.
  final Widget Function(
    BuildContext context,
    String groupKey,
    List<T> groupItems,
    bool collapsed,
  )?
  headerBuilder;

  /// Controls group ordering.
  final int Function(String a, String b)? groupOrder;

  /// Whether groups can be collapsed by tapping the header.
  final bool collapsible;

  /// Set of group keys that start collapsed.
  final Set<String>? initiallyCollapsed;

  /// How to handle groups with zero items.
  final OiEmptyGroupBehavior emptyGroupBehavior;

  /// Widget shown when [items] is empty.
  final Widget? emptyState;

  /// Widget rendered between items within a group.
  final Widget? separator;

  /// Widget rendered between groups.
  final Widget? groupSeparator;

  /// Infinite scroll: called when reaching the bottom.
  final VoidCallback? onLoadMore;

  /// Whether more items are available for loading.
  final bool moreAvailable;

  /// Shows a loading indicator at the bottom.
  final bool loading;

  /// List padding.
  final EdgeInsetsGeometry? padding;

  /// Scroll controller.
  final ScrollController? controller;

  /// Programmatic controller for expand/collapse.
  final OiGroupedListController? groupedListController;

  /// Accessibility label.
  final String? semanticLabel;

  /// Unique key per item. Required for virtual scrolling and animations.
  final Object Function(T item)? itemKey;

  /// Whether section headers stick to the top during scroll.
  final bool stickyHeaders;

  /// Pull-to-refresh callback.
  final Future<void> Function()? onRefresh;

  /// Scroll physics override.
  final ScrollPhysics? physics;

  /// Driver for persisting collapsed-group state across sessions.
  ///
  /// When `null`, state is not persisted. Falls back to [OiSettingsProvider]
  /// if one is present in the widget tree and no explicit driver is provided.
  final OiSettingsDriver? settingsDriver;

  /// Sub-key scoping this list's settings within its namespace.
  final String? settingsKey;

  @override
  State<OiGroupedList<T>> createState() => _OiGroupedListState<T>();
}

class _OiGroupedListState<T> extends State<OiGroupedList<T>>
    with OiSettingsMixin<OiGroupedList<T>, OiGroupedListSettings> {
  late OiGroupedListController _controller;
  bool _ownsController = false;
  bool _settingsApplied = false;

  /// Resolved settings driver: explicit prop → OiSettingsProvider → null.
  OiSettingsDriver? _resolvedDriver;

  // ── OiSettingsMixin contract ───────────────────────────────────────────────

  @override
  String get settingsNamespace => 'oi_grouped_list';

  @override
  String? get settingsKey => widget.settingsKey;

  @override
  OiSettingsDriver? get settingsDriver => _resolvedDriver;

  @override
  OiGroupedListSettings get defaultSettings => const OiGroupedListSettings();

  @override
  OiGroupedListSettings deserializeSettings(Map<String, dynamic> json) =>
      OiGroupedListSettings.fromJson(json);

  @override
  OiGroupedListSettings mergeSettings(
    OiGroupedListSettings saved,
    OiGroupedListSettings defaults,
  ) => saved.mergeWith(defaults);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    _resolvedDriver = widget.settingsDriver;
    if (widget.groupedListController != null) {
      _controller = widget.groupedListController!;
      _ownsController = false;
    } else {
      _controller = OiGroupedListController();
      _ownsController = true;
    }
    if (widget.initiallyCollapsed != null) {
      for (final key in widget.initiallyCollapsed!) {
        _controller._collapsed.add(key);
      }
    }
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newDriver = widget.settingsDriver ?? OiSettingsProvider.of(context);
    if (newDriver != _resolvedDriver) {
      _resolvedDriver = newDriver;
      _settingsApplied = false;
      if (settingsLoaded) reloadSettings();
    }
  }

  @override
  void didUpdateWidget(covariant OiGroupedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.settingsDriver != oldWidget.settingsDriver ||
        widget.settingsKey != oldWidget.settingsKey) {
      _resolvedDriver = widget.settingsDriver;
      _settingsApplied = false;
      reloadSettings();
    }
    if (widget.groupedListController != oldWidget.groupedListController) {
      _controller.removeListener(_onControllerChanged);
      if (_ownsController) _controller.dispose();
      if (widget.groupedListController != null) {
        _controller = widget.groupedListController!;
        _ownsController = false;
      } else {
        _controller = OiGroupedListController();
        _ownsController = true;
      }
      _controller.addListener(_onControllerChanged);
    }
  }

  /// Applies saved settings once after the async load completes.
  ///
  /// Called from [build] when [settingsLoaded] flips to true for the first time
  /// (after the mixin's async load calls [setState]).
  void _applySettingsOnce() {
    if (_settingsApplied || !settingsLoaded || settingsDriver == null) return;
    _settingsApplied = true;
    for (final key in currentSettings.collapsedGroups) {
      _controller._collapsed.add(key);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    if (settingsDriver != null) {
      updateSettings(
        OiGroupedListSettings(collapsedGroups: Set.of(_controller._collapsed)),
      );
    } else {
      setState(() {});
    }
  }

  Map<String, List<T>> _buildGroups() {
    final groups = <String, List<T>>{};
    for (final item in widget.items) {
      final key = widget.groupBy(item);
      groups.putIfAbsent(key, () => []).add(item);
    }
    return groups;
  }

  Widget _buildHeader(
    BuildContext context,
    String key,
    List<T> items,
    bool collapsed,
    GlobalKey headerKey,
  ) {
    Widget header;
    if (widget.headerBuilder != null) {
      header = widget.headerBuilder!(context, key, items, collapsed);
    } else {
      header = _DefaultGroupHeader(
        groupKey: key,
        itemCount: items.length,
        collapsed: collapsed,
        collapsible: widget.collapsible,
      );
    }

    if (widget.collapsible) {
      header = OiTappable(
        onTap: () => _controller.toggleGroup(key),
        semanticLabel: collapsed ? 'Expand $key' : 'Collapse $key',
        child: header,
      );
    }

    return KeyedSubtree(key: headerKey, child: header);
  }

  @override
  Widget build(BuildContext context) {
    _applySettingsOnce();

    if (widget.items.isEmpty && widget.emptyState != null) {
      return widget.emptyState!;
    }

    final groups = _buildGroups();
    var sortedKeys = groups.keys.toList();
    if (widget.groupOrder != null) {
      sortedKeys.sort(widget.groupOrder);
    }

    // Update known groups on the controller for collapseAll support.
    _controller._knownGroups
      ..clear()
      ..addAll(sortedKeys);

    final spacing = context.spacing;

    if (widget.stickyHeaders) {
      return _buildStickyScrollView(context, groups, sortedKeys, spacing);
    }

    return _buildFlatListView(context, groups, sortedKeys, spacing);
  }

  Widget _buildFlatListView(
    BuildContext context,
    Map<String, List<T>> groups,
    List<String> sortedKeys,
    OiSpacingScale spacing,
  ) {
    final children = <Widget>[];

    for (var gi = 0; gi < sortedKeys.length; gi++) {
      final key = sortedKeys[gi];
      final items = groups[key]!;
      final collapsed = _controller.collapsed(key);
      final headerKey = _controller._headerKeys.putIfAbsent(key, GlobalKey.new);

      children.add(_buildHeader(context, key, items, collapsed, headerKey));

      if (!collapsed) {
        for (var i = 0; i < items.length; i++) {
          children.add(widget.itemBuilder(context, items[i], i));
          if (widget.separator != null && i < items.length - 1) {
            children.add(widget.separator!);
          }
        }
      }

      if (widget.groupSeparator != null && gi < sortedKeys.length - 1) {
        children.add(widget.groupSeparator!);
      }
    }

    if (widget.loading) {
      children.add(
        Padding(
          padding: EdgeInsets.all(spacing.md),
          child: const Center(
            child: SizedBox.square(
              dimension: 24,
              child: OiProgress.circular(indeterminate: true, size: 24),
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      child: ListView(
        controller: widget.controller,
        padding: widget.padding,
        physics: widget.physics,
        children: children,
      ),
    );
  }

  Widget _buildStickyScrollView(
    BuildContext context,
    Map<String, List<T>> groups,
    List<String> sortedKeys,
    OiSpacingScale spacing,
  ) {
    final slivers = <Widget>[];

    for (var gi = 0; gi < sortedKeys.length; gi++) {
      final key = sortedKeys[gi];
      final items = groups[key]!;
      final collapsed = _controller.collapsed(key);
      final headerKey = _controller._headerKeys.putIfAbsent(key, GlobalKey.new);

      final headerWidget = _buildHeader(
        context,
        key,
        items,
        collapsed,
        headerKey,
      );

      // Sticky persistent header for each group.
      // Use 48.0 to accommodate touch target padding on interactive headers.
      final headerExtent = widget.collapsible ? 48.0 : 40.0;
      slivers.add(
        SliverPersistentHeader(
          pinned: true,
          delegate: _GroupHeaderDelegate(
            child: headerWidget,
            extent: headerExtent,
          ),
        ),
      );

      // Items for this group.
      if (!collapsed) {
        final itemWidgets = <Widget>[];
        for (var i = 0; i < items.length; i++) {
          itemWidgets.add(widget.itemBuilder(context, items[i], i));
          if (widget.separator != null && i < items.length - 1) {
            itemWidgets.add(widget.separator!);
          }
        }
        if (itemWidgets.isNotEmpty) {
          slivers.add(
            SliverList(delegate: SliverChildListDelegate(itemWidgets)),
          );
        }
      }

      // Group separator.
      if (widget.groupSeparator != null && gi < sortedKeys.length - 1) {
        slivers.add(SliverToBoxAdapter(child: widget.groupSeparator!));
      }
    }

    // Loading indicator.
    if (widget.loading) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(spacing.md),
            child: const Center(
              child: SizedBox.square(
                dimension: 24,
                child: OiProgress.circular(indeterminate: true, size: 24),
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      child: CustomScrollView(
        controller: widget.controller,
        physics: widget.physics,
        slivers: slivers,
      ),
    );
  }
}

/// Delegate for sticky group headers using [SliverPersistentHeader].
class _GroupHeaderDelegate extends SliverPersistentHeaderDelegate {
  _GroupHeaderDelegate({required this.child, required this.extent});

  final Widget child;
  final double extent;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _GroupHeaderDelegate oldDelegate) {
    return child != oldDelegate.child || extent != oldDelegate.extent;
  }
}

class _DefaultGroupHeader extends StatelessWidget {
  const _DefaultGroupHeader({
    required this.groupKey,
    required this.itemCount,
    required this.collapsed,
    required this.collapsible,
  });

  final String groupKey;
  final int itemCount;
  final bool collapsed;
  final bool collapsible;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    final breakpoint = context.breakpoint;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: spacing.xs,
        horizontal: spacing.sm,
      ),
      child: OiRow(
        breakpoint: breakpoint,
        gap: OiResponsive<double>(spacing.xs),
        children: [
          OiLabel.h4(groupKey),
          if (collapsible)
            OiIcon.decorative(
              icon: collapsed ? OiIcons.chevronRight : OiIcons.chevronDown,
              size: 14,
              color: colors.textMuted,
            ),
        ],
      ),
    );
  }
}
