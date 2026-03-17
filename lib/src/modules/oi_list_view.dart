import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_empty_state.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ---------------------------------------------------------------------------
// Supporting types
// ---------------------------------------------------------------------------

/// A sort option for [OiListView].
///
/// Each option has a unique [id] and a human-readable [label].
/// An optional [icon] may be displayed alongside the label in sort menus.
@immutable
class OiSortOption {
  /// Creates an [OiSortOption].
  const OiSortOption({required this.id, required this.label, this.icon});

  /// Unique identifier for this sort option.
  final String id;

  /// Human-readable label displayed in the sort menu.
  final String label;

  /// Optional icon displayed next to the label.
  final IconData? icon;
}

/// Layout options for [OiListView].
enum OiListViewLayout {
  /// A vertical scrolling list.
  list,

  /// A grid layout with multiple columns.
  grid,

  /// A tabular layout.
  table,
}

/// Selection mode for [OiListView].
enum OiSelectionMode {
  /// No selection behaviour.
  none,

  /// At most one item may be selected at a time.
  single,

  /// Multiple items may be selected simultaneously.
  multi,
}

// ---------------------------------------------------------------------------
// OiListView
// ---------------------------------------------------------------------------

/// A complete list screen with search, filters, sorting, and selection.
///
/// The most common screen pattern in any app — a searchable, filterable,
/// sortable list of entities with bulk actions and pagination.
///
/// {@category Modules}
class OiListView<T> extends StatefulWidget {
  /// Creates an [OiListView].
  const OiListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.itemKey,
    required this.label,
    this.searchQuery,
    this.onSearch,
    this.sortOptions,
    this.activeSort,
    this.onSort,
    this.selectionMode = OiSelectionMode.none,
    this.selectedKeys = const {},
    this.onSelectionChange,
    this.selectionActions,
    this.onLoadMore,
    this.hasMore = false,
    this.loading = false,
    this.emptyState,
    this.layout = OiListViewLayout.list,
    this.headerActions,
    this.onRefresh,
  });

  /// The data items to display.
  final List<T> items;

  /// Builder that creates a widget for each data item.
  final Widget Function(T) itemBuilder;

  /// Extracts a unique key from each item, used for selection tracking.
  final Object Function(T) itemKey;

  /// Accessible label for the list screen.
  final String label;

  /// The current search query string.
  final String? searchQuery;

  /// Called when the user types in the search field.
  final ValueChanged<String>? onSearch;

  /// Available sort options displayed in the sort bar.
  final List<OiSortOption>? sortOptions;

  /// The currently active sort option.
  final OiSortOption? activeSort;

  /// Called when the user selects a sort option.
  final ValueChanged<OiSortOption>? onSort;

  /// The selection mode for the list.
  final OiSelectionMode selectionMode;

  /// The set of currently selected item keys.
  final Set<Object> selectedKeys;

  /// Called when the selection changes.
  final ValueChanged<Set<Object>>? onSelectionChange;

  /// Builder for bulk action widgets shown when items are selected.
  final List<Widget> Function(Set<Object> selectedKeys)? selectionActions;

  /// Called when the user scrolls near the end to load more items.
  final Future<void> Function()? onLoadMore;

  /// Whether more items are available to load.
  final bool hasMore;

  /// Whether the list is currently loading data.
  final bool loading;

  /// Widget displayed when there are no items and loading is false.
  final Widget? emptyState;

  /// The layout mode for the list.
  final OiListViewLayout layout;

  /// Widget displayed in the header action slot.
  final Widget? headerActions;

  /// Called when the user triggers a pull-to-refresh.
  final Future<void> Function()? onRefresh;

  @override
  State<OiListView<T>> createState() => _OiListViewState<T>();
}

class _OiListViewState<T> extends State<OiListView<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || widget.loading) return;
    if (widget.onLoadMore == null) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 100) {
      widget.onLoadMore!();
    }
  }

  void _handleItemTap(T item) {
    if (widget.selectionMode == OiSelectionMode.none) return;
    final key = widget.itemKey(item);
    final selected = Set<Object>.from(widget.selectedKeys);
    if (widget.selectionMode == OiSelectionMode.single) {
      if (selected.contains(key)) {
        selected.remove(key);
      } else {
        selected
          ..clear()
          ..add(key);
      }
    } else {
      if (selected.contains(key)) {
        selected.remove(key);
      } else {
        selected.add(key);
      }
    }
    widget.onSelectionChange?.call(selected);
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      container: true,
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          if (widget.selectionActions != null &&
              widget.selectedKeys.isNotEmpty)
            _buildSelectionBar(context),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
              ),
              if (widget.headerActions != null) widget.headerActions!,
            ],
          ),
          if (widget.onSearch != null) ...[
            const SizedBox(height: 12),
            OiTextInput(
              placeholder: 'Search...',
              onChanged: widget.onSearch,
              controller: TextEditingController(text: widget.searchQuery),
            ),
          ],
          if (widget.sortOptions != null &&
              widget.sortOptions!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildSortBar(context),
          ],
        ],
      ),
    );
  }

  Widget _buildSortBar(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final option in widget.sortOptions!)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: OiTappable(
                onTap: () => widget.onSort?.call(option),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.activeSort?.id == option.id
                        ? colors.primary.base.withValues(alpha: 0.1)
                        : null,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (option.icon != null) ...[
                        Icon(option.icon, size: 14, color: colors.text),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        option.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: widget.activeSort?.id == option.id
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: colors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectionBar(BuildContext context) {
    final colors = context.colors;
    final actions = widget.selectionActions!(widget.selectedKeys);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colors.primary.base.withValues(alpha: 0.08),
      child: Row(
        children: [
          Text(
            '${widget.selectedKeys.length} selected',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colors.text,
            ),
          ),
          const Spacer(),
          ...actions,
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.loading && widget.items.isEmpty) {
      return const Center(child: OiProgress(indeterminate: true));
    }

    if (widget.items.isEmpty && !widget.loading) {
      return widget.emptyState ??
          const OiEmptyState(title: 'No items');
    }

    return ListView.builder(
      key: const Key('oi_list_view_scroll'),
      controller: _scrollController,
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: OiProgress(indeterminate: true)),
          );
        }
        final item = widget.items[index];
        final key = widget.itemKey(item);
        final isSelected = widget.selectedKeys.contains(key);

        Widget child = widget.itemBuilder(item);

        if (widget.selectionMode != OiSelectionMode.none) {
          child = OiTappable(
            onTap: () => _handleItemTap(item),
            child: Container(
              color: isSelected
                  ? context.colors.primary.base.withValues(alpha: 0.08)
                  : null,
              child: child,
            ),
          );
        }

        return child;
      },
    );
  }
}
