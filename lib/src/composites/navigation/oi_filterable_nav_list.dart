import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ── Data models ──────────────────────────────────────────────────────────────

/// A named group that navigation items can belong to.
///
/// Groups are displayed as collapsible sections sorted by [sortOrder].
///
/// {@category Composites}
@immutable
class OiNavGroup {
  /// Creates an [OiNavGroup].
  const OiNavGroup({required this.id, required this.label, this.sortOrder = 0});

  /// A unique identifier for this group.
  final String id;

  /// The display label shown as the group header.
  final String label;

  /// Determines the display order of groups. Lower values appear first.
  final int sortOrder;
}

/// A chip filter that can be toggled to narrow the visible items.
///
/// {@category Composites}
@immutable
class OiChipFilter {
  /// Creates an [OiChipFilter].
  const OiChipFilter({
    required this.id,
    required this.label,
    this.color = OiBadgeColor.neutral,
  });

  /// A unique identifier for this filter.
  final String id;

  /// The display label shown on the chip.
  final String label;

  /// The semantic color of the chip badge.
  final OiBadgeColor color;
}

// ── OiFilterableNavList ─────────────────────────────────────────────────────

/// A composite navigation list with search, chip filters, and grouped items.
///
/// Items of type [T] are grouped by [groupIdOf], optionally filtered by a
/// search query and chip filters, and displayed in collapsible sections sorted
/// by [OiNavGroup.sortOrder].
///
/// The widget is fully generic: provide accessor callbacks ([idOf], [groupIdOf],
/// [titleOf], etc.) to map your data type to the display.
///
/// {@category Composites}
class OiFilterableNavList<T> extends StatefulWidget {
  /// Creates an [OiFilterableNavList].
  const OiFilterableNavList({
    required this.items,
    required this.groups,
    required this.idOf,
    required this.groupIdOf,
    required this.titleOf,
    required this.label,
    this.subtitleOf,
    this.iconOf,
    this.searchPlaceholder = 'Search...',
    this.chipFilters,
    this.chipFilterOf,
    this.selectedItemId,
    this.onItemSelected,
    this.headerAction,
    this.itemLoadingIds,
    this.emptyState,
    this.onGroupHeaderTap,
    super.key,
  });

  /// The full list of items to display (before filtering).
  final List<T> items;

  /// The groups that items can belong to.
  final List<OiNavGroup> groups;

  /// Returns a unique identifier for an item.
  final String Function(T) idOf;

  /// Returns the group identifier that an item belongs to.
  final String Function(T) groupIdOf;

  /// Returns the display title for an item.
  final String Function(T) titleOf;

  /// An accessibility label for the navigation list.
  final String label;

  /// Returns an optional subtitle for an item.
  final String Function(T)? subtitleOf;

  /// Returns an optional icon for an item.
  final IconData Function(T)? iconOf;

  /// Placeholder text shown in the search input.
  final String searchPlaceholder;

  /// The set of chip filters available for narrowing results.
  final List<OiChipFilter>? chipFilters;

  /// Maps an item to the set of chip filter IDs it belongs to.
  ///
  /// When chip filters are active, only items whose [chipFilterOf] result
  /// intersects the active chip IDs are shown.
  final Set<String> Function(T)? chipFilterOf;

  /// The ID of the currently selected item, or `null` for no selection.
  final String? selectedItemId;

  /// Called when the user taps an item.
  final void Function(T)? onItemSelected;

  /// An optional widget rendered between the chip filters and the item list.
  final Widget? headerAction;

  /// IDs of items currently loading. These show a spinner instead of an icon.
  final Set<String>? itemLoadingIds;

  /// Widget shown when no items match the current search/filter.
  ///
  /// Defaults to an empty [SizedBox] when null.
  final Widget? emptyState;

  /// Called when the user taps a group header row.
  ///
  /// Receives the [OiNavGroup] that was tapped. When null, group headers still
  /// toggle expand/collapse but no extra callback is fired.
  final void Function(OiNavGroup group)? onGroupHeaderTap;

  @override
  State<OiFilterableNavList<T>> createState() => _OiFilterableNavListState<T>();
}

class _OiFilterableNavListState<T> extends State<OiFilterableNavList<T>> {
  String _query = '';
  final Set<String> _activeChipIds = {};
  final Set<String> _expandedGroupIds = {};
  bool _expandedInitialized = false;

  // ── Filtering ───────────────────────────────────────────────────────────

  List<T> get _filteredItems {
    var items = widget.items;

    // Apply search filter.
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      items = items.where((item) {
        final title = widget.titleOf(item).toLowerCase();
        final subtitle = widget.subtitleOf?.call(item).toLowerCase() ?? '';
        return title.contains(q) || subtitle.contains(q);
      }).toList();
    }

    // Apply chip filters.
    if (_activeChipIds.isNotEmpty && widget.chipFilterOf != null) {
      items = items.where((item) {
        final itemChips = widget.chipFilterOf!(item);
        return _activeChipIds.any(itemChips.contains);
      }).toList();
    }

    return items;
  }

  /// Groups items by group ID and sorts groups by [OiNavGroup.sortOrder].
  List<_GroupedItems<T>> _groupItems(List<T> items) {
    final groupMap = <String, List<T>>{};
    for (final item in items) {
      final gid = widget.groupIdOf(item);
      (groupMap[gid] ??= []).add(item);
    }

    final sortedGroups = List<OiNavGroup>.of(widget.groups)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return sortedGroups
        .where((g) => groupMap.containsKey(g.id))
        .map((g) => _GroupedItems(group: g, items: groupMap[g.id]!))
        .toList();
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────

  void _initExpandedGroups() {
    if (!_expandedInitialized) {
      _expandedGroupIds.addAll(widget.groups.map((g) => g.id));
      _expandedInitialized = true;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _initExpandedGroups();

    final filtered = _filteredItems;
    final grouped = _groupItems(filtered);

    // Auto-expand groups that contain search matches.
    if (_query.isNotEmpty) {
      for (final g in grouped) {
        _expandedGroupIds.add(g.group.id);
      }
    }

    return Semantics(
      label: widget.label,
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Search ─────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.sm,
              vertical: context.spacing.xs,
            ),
            child: OiTextInput.search(
              onChanged: (v) => setState(() => _query = v),
            ),
          ),

          // ── Chip filters ──────────────────────────────────────────────
          if (widget.chipFilters != null && widget.chipFilters!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.sm,
                vertical: context.spacing.xs,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final chip in widget.chipFilters!)
                      Padding(
                        padding: EdgeInsets.only(right: context.spacing.xs),
                        child: _ChipFilterButton(
                          chip: chip,
                          active: _activeChipIds.contains(chip.id),
                          onToggle: () {
                            setState(() {
                              if (_activeChipIds.contains(chip.id)) {
                                _activeChipIds.remove(chip.id);
                              } else {
                                _activeChipIds.add(chip.id);
                              }
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // ── Header action ─────────────────────────────────────────────
          if (widget.headerAction != null)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacing.sm,
                vertical: context.spacing.xs,
              ),
              child: widget.headerAction,
            ),

          // ── Grouped item list ─────────────────────────────────────────
          Expanded(
            child: grouped.isEmpty
                ? (widget.emptyState ?? const SizedBox.shrink())
                : ListView.builder(
                    itemCount: grouped.length,
                    padding: EdgeInsets.symmetric(vertical: context.spacing.xs),
                    itemBuilder: (context, index) {
                      final group = grouped[index];
                      final isExpanded = _expandedGroupIds.contains(
                        group.group.id,
                      );

                      return _GroupSection<T>(
                        group: group,
                        expanded: isExpanded,
                        onToggle: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedGroupIds.remove(group.group.id);
                            } else {
                              _expandedGroupIds.add(group.group.id);
                            }
                          });
                          widget.onGroupHeaderTap?.call(group.group);
                        },
                        selectedItemId: widget.selectedItemId,
                        onItemSelected: widget.onItemSelected,
                        idOf: widget.idOf,
                        titleOf: widget.titleOf,
                        subtitleOf: widget.subtitleOf,
                        iconOf: widget.iconOf,
                        itemLoadingIds: widget.itemLoadingIds,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Private helpers ─────────────────────────────────────────────────────────

@immutable
class _GroupedItems<T> {
  const _GroupedItems({required this.group, required this.items});
  final OiNavGroup group;
  final List<T> items;
}

/// A toggleable chip filter button rendered with [OiBadge.soft].
class _ChipFilterButton extends StatelessWidget {
  const _ChipFilterButton({
    required this.chip,
    required this.active,
    required this.onToggle,
  });

  final OiChipFilter chip;
  final bool active;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return OiTappable(
      onTap: onToggle,
      semanticLabel: '${chip.label} filter',
      child: Opacity(
        opacity: active ? 1.0 : 0.6,
        child: OiBadge.soft(
          label: chip.label,
          color: active ? chip.color : OiBadgeColor.neutral,
        ),
      ),
    );
  }
}

/// A collapsible group section with a header and animated item rows.
class _GroupSection<T> extends StatefulWidget {
  const _GroupSection({
    required this.group,
    required this.expanded,
    required this.onToggle,
    required this.selectedItemId,
    required this.onItemSelected,
    required this.idOf,
    required this.titleOf,
    this.subtitleOf,
    this.iconOf,
    this.itemLoadingIds,
  });

  final _GroupedItems<T> group;
  final bool expanded;
  final VoidCallback onToggle;
  final String? selectedItemId;
  final void Function(T)? onItemSelected;
  final String Function(T) idOf;
  final String Function(T) titleOf;
  final String Function(T)? subtitleOf;
  final IconData Function(T)? iconOf;
  final Set<String>? itemLoadingIds;

  @override
  State<_GroupSection<T>> createState() => _GroupSectionState<T>();
}

class _GroupSectionState<T> extends State<_GroupSection<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: widget.expanded ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(_GroupSection<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded != oldWidget.expanded) {
      if (widget.expanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Group header
        OiTappable(
          onTap: widget.onToggle,
          semanticLabel:
              '${widget.group.group.label} group, '
              '${widget.expanded ? "collapse" : "expand"}',
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.sm,
              vertical: spacing.xs,
            ),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: widget.expanded ? 0.25 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: const OiIcon.decorative(
                    icon: OiIcons.chevronRight,
                    size: 14,
                  ),
                ),
                SizedBox(width: spacing.xs),
                Expanded(
                  child: OiLabel.small(
                    widget.group.group.label,
                    color: context.colors.textSubtle,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Group items with animated expand/collapse
        SizeTransition(
          sizeFactor: _animation,
          axisAlignment: -1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final item in widget.group.items)
                _NavItemTile<T>(
                  item: item,
                  selected: widget.selectedItemId == widget.idOf(item),
                  loading:
                      widget.itemLoadingIds?.contains(widget.idOf(item)) ??
                      false,
                  onTap: widget.onItemSelected != null
                      ? () => widget.onItemSelected!(item)
                      : null,
                  idOf: widget.idOf,
                  titleOf: widget.titleOf,
                  subtitleOf: widget.subtitleOf,
                  iconOf: widget.iconOf,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A single navigation item row with hover and selection states.
class _NavItemTile<T> extends StatefulWidget {
  const _NavItemTile({
    required this.item,
    required this.selected,
    required this.loading,
    required this.onTap,
    required this.idOf,
    required this.titleOf,
    this.subtitleOf,
    this.iconOf,
  });

  final T item;
  final bool selected;
  final bool loading;
  final VoidCallback? onTap;
  final String Function(T) idOf;
  final String Function(T) titleOf;
  final String Function(T)? subtitleOf;
  final IconData Function(T)? iconOf;

  @override
  State<_NavItemTile<T>> createState() => _NavItemTileState<T>();
}

class _NavItemTileState<T> extends State<_NavItemTile<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;
    final subtitle = widget.subtitleOf?.call(widget.item);
    final iconData = widget.iconOf?.call(widget.item);

    Color? bg;
    if (widget.selected) {
      bg = colors.primary.base.withValues(alpha: 0.1);
    } else if (_hovered) {
      bg = colors.surfaceHover;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Semantics(
          label: widget.titleOf(widget.item),
          button: true,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: spacing.xs, vertical: 1),
            padding: EdgeInsets.only(
              left: spacing.sm + spacing.md,
              right: spacing.sm,
              top: spacing.xs,
              bottom: spacing.xs,
            ),
            decoration: BoxDecoration(color: bg, borderRadius: radius.sm),
            child: Row(
              children: [
                // Leading: icon or loading spinner
                if (widget.loading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: OiProgress.circular(
                      indeterminate: true,
                      size: 18,
                      strokeWidth: 2,
                    ),
                  )
                else if (iconData != null)
                  OiIcon.decorative(icon: iconData, size: 18),

                if (widget.loading || iconData != null)
                  SizedBox(width: spacing.sm),

                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OiLabel.small(
                        widget.titleOf(widget.item),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        color: widget.selected ? colors.primary.base : null,
                      ),
                      if (subtitle != null && subtitle.isNotEmpty)
                        OiLabel.tiny(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          color: colors.textMuted,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
