import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
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
  bool isCollapsed(String groupKey) => _collapsed.contains(groupKey);

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
    bool isCollapsed,
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

  @override
  State<OiGroupedList<T>> createState() => _OiGroupedListState<T>();
}

class _OiGroupedListState<T> extends State<OiGroupedList<T>> {
  late OiGroupedListController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.groupedListController != null) {
      _controller = widget.groupedListController!;
    } else {
      _controller = OiGroupedListController();
      _ownsController = true;
    }
    if (widget.initiallyCollapsed != null) {
      for (final key in widget.initiallyCollapsed!) {
        _controller._collapsed.add(key);
      }
    }
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Map<String, List<T>> _buildGroups() {
    final groups = <String, List<T>>{};
    for (final item in widget.items) {
      final key = widget.groupBy(item);
      groups.putIfAbsent(key, () => []).add(item);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
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

    final children = <Widget>[];

    for (var gi = 0; gi < sortedKeys.length; gi++) {
      final key = sortedKeys[gi];
      final items = groups[key]!;
      final isCollapsed = _controller.isCollapsed(key);

      // Ensure a GlobalKey exists for this header.
      final headerKey = _controller._headerKeys.putIfAbsent(key, GlobalKey.new);

      // Header.
      Widget header;
      if (widget.headerBuilder != null) {
        header = widget.headerBuilder!(context, key, items, isCollapsed);
      } else {
        header = _DefaultGroupHeader(
          groupKey: key,
          itemCount: items.length,
          isCollapsed: isCollapsed,
          collapsible: widget.collapsible,
        );
      }

      if (widget.collapsible) {
        header = OiTappable(
          onTap: () => _controller.toggleGroup(key),
          semanticLabel: isCollapsed ? 'Expand $key' : 'Collapse $key',
          child: header,
        );
      }

      children.add(KeyedSubtree(key: headerKey, child: header));

      // Items.
      if (!isCollapsed) {
        for (var i = 0; i < items.length; i++) {
          children.add(widget.itemBuilder(context, items[i], i));
          if (widget.separator != null && i < items.length - 1) {
            children.add(widget.separator!);
          }
        }
      }

      // Group separator.
      if (widget.groupSeparator != null && gi < sortedKeys.length - 1) {
        children.add(widget.groupSeparator!);
      }
    }

    // Loading indicator.
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
}

class _DefaultGroupHeader extends StatelessWidget {
  const _DefaultGroupHeader({
    required this.groupKey,
    required this.itemCount,
    required this.isCollapsed,
    required this.collapsible,
  });

  final String groupKey;
  final int itemCount;
  final bool isCollapsed;
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
              icon: isCollapsed ? OiIcons.chevronRight : OiIcons.chevronDown,
              size: 14,
              color: colors.textMuted,
            ),
        ],
      ),
    );
  }
}
