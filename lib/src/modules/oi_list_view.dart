import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_empty_state.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/components/overlays/oi_sheet.dart';
import 'package:obers_ui/src/composites/navigation/oi_filter_bar.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_mixin.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/settings/oi_list_view_settings.dart'
    hide OiListViewLayout;
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:obers_ui/src/primitives/layout/oi_grid.dart';

// ---------------------------------------------------------------------------
// Supporting types
// ---------------------------------------------------------------------------

/// A sort option for [OiListView].
///
/// Each option has a unique [id] and a human-readable [label].
/// An optional [icon] may be displayed alongside the label in sort menus.
@immutable
class OiListSortOption {
  /// Creates an [OiListSortOption].
  const OiListSortOption({required this.id, required this.label, this.icon});

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
    required this.items,
    required this.itemBuilder,
    required this.itemKey,
    required this.label,
    super.key,
    this.searchQuery,
    this.onSearch,
    this.filters,
    this.activeFilters = const {},
    this.onFilterChange,
    this.sortOptions,
    this.activeSort,
    this.onSort,
    this.selectionMode = OiSelectionMode.none,
    this.selectedKeys = const {},
    this.onSelectionChange,
    this.selectionActions,
    this.onLoadMore,
    this.moreAvailable = false,
    this.loading = false,
    this.emptyState,
    this.layout = OiListViewLayout.list,
    this.gridColumns,
    this.gridGap,
    this.headerActions,
    this.footer,
    this.onRefresh,
    this.settingsDriver,
    this.settingsKey,
    this.settingsNamespace = 'oi_list_view',
    this.settingsSaveDebounce = const Duration(milliseconds: 500),
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

  /// Available filter definitions shown as chips in the filter bar.
  final List<OiFilterDefinition>? filters;

  /// The currently active filters keyed by [OiFilterDefinition.key].
  final Map<String, OiColumnFilter> activeFilters;

  /// Called when the active filter set changes.
  final ValueChanged<Map<String, OiColumnFilter>>? onFilterChange;

  /// Available sort options displayed in the sort bar.
  final List<OiListSortOption>? sortOptions;

  /// The currently active sort option.
  final OiListSortOption? activeSort;

  /// Called when the user selects a sort option.
  final ValueChanged<OiListSortOption>? onSort;

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
  final bool moreAvailable;

  /// Whether the list is currently loading data.
  final bool loading;

  /// Widget displayed when there are no items and loading is false.
  final Widget? emptyState;

  /// The layout mode for the list.
  final OiListViewLayout layout;

  /// Responsive column count for the grid layout.
  ///
  /// When null, defaults to 3 columns for all breakpoints.
  final OiResponsive<int>? gridColumns;

  /// Gap between grid items in logical pixels.
  ///
  /// When null, defaults to [OiSpacingTheme.md].
  final OiResponsive<double>? gridGap;

  /// Widget displayed in the header action slot.
  final Widget? headerActions;

  /// Optional widget displayed below the list body (e.g. pagination).
  final Widget? footer;

  /// Called when the user triggers a pull-to-refresh.
  final Future<void> Function()? onRefresh;

  // ── Settings persistence ──────────────────────────────────────────────────

  /// Driver used to persist settings. When `null` settings are not persisted.
  final OiSettingsDriver? settingsDriver;

  /// Sub-key scoping this list view's settings within [settingsNamespace].
  final String? settingsKey;

  /// Top-level namespace for settings storage.
  final String settingsNamespace;

  /// Debounce duration for auto-saving settings after changes.
  final Duration settingsSaveDebounce;

  @override
  State<OiListView<T>> createState() => _OiListViewState<T>();
}

class _OiListViewState<T> extends State<OiListView<T>>
    with OiSettingsMixin<OiListView<T>, OiListViewSettings> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isRefreshing = false;
  double _overscrollAccumulated = 0;
  VoidCallback? _dismissFilterSheet;

  /// Resolved driver: explicit widget prop → OiSettingsProvider → null.
  OiSettingsDriver? _resolvedDriver;

  // ── OiSettingsMixin contract ───────────────────────────────────────────────

  @override
  String get settingsNamespace => widget.settingsNamespace;

  @override
  String? get settingsKey => widget.settingsKey;

  @override
  OiSettingsDriver? get settingsDriver => _resolvedDriver;

  @override
  OiListViewSettings get defaultSettings => const OiListViewSettings();

  @override
  OiListViewSettings deserializeSettings(Map<String, dynamic> json) =>
      OiListViewSettings.fromJson(json);

  @override
  OiListViewSettings mergeSettings(
    OiListViewSettings saved,
    OiListViewSettings defaults,
  ) => saved.mergeWith(defaults);

  bool get _refreshEnabled =>
      widget.onRefresh != null &&
      OiDensityScope.of(context) == OiDensity.comfortable;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    _resolvedDriver = widget.settingsDriver;
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.text = widget.searchQuery ?? '';
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
    // Sync search controller when the external query changes (e.g. reset).
    final externalQuery = widget.searchQuery ?? '';
    if (_searchController.text != externalQuery) {
      _searchController.text = externalQuery;
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.moreAvailable || widget.loading) return;
    if (widget.onLoadMore == null) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 100) {
      unawaited(widget.onLoadMore!());
    }
  }

  Future<void> _triggerRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      await widget.onRefresh!();
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!_refreshEnabled) return false;
    if (notification is OverscrollNotification) {
      if (notification.overscroll < 0) {
        _overscrollAccumulated += notification.overscroll.abs();
        if (_overscrollAccumulated >= 60 && !_isRefreshing) {
          _overscrollAccumulated = 0;
          unawaited(_triggerRefresh());
        }
      }
    }
    if (notification is ScrollEndNotification) {
      _overscrollAccumulated = 0;
    }
    return false;
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

  void _openFilterSheet(BuildContext context) {
    _dismissFilterSheet?.call();
    final handle = OiSheet.show(
      context,
      label: 'Filters',
      dragHandle: true,
      onClose: () => _dismissFilterSheet = null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const OiLabel.h4('Filters'),
            const SizedBox(height: 12),
            OiFilterBar(
              filters: widget.filters!,
              activeFilters: widget.activeFilters,
              onFilterChange: (updated) {
                widget.onFilterChange?.call(updated);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    _dismissFilterSheet = handle.dismiss;
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;
    final hasSelectionBar =
        widget.selectionActions != null && widget.selectedKeys.isNotEmpty;

    return Semantics(
      label: widget.label,
      container: true,
      explicitChildNodes: true,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            if (hasSelectionBar && !isCompact) _buildSelectionBar(context),
            Expanded(child: _buildBody(context)),
            if (widget.footer != null) widget.footer!,
            if (hasSelectionBar && isCompact) _buildSelectionBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isCompact = context.isCompact;
    final hasFilters = widget.filters != null && widget.filters!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: OiLabel.h2(widget.label),
              ),
              if (hasFilters && isCompact) ...[
                _buildFiltersButton(context),
                const SizedBox(width: 8),
              ],
              if (widget.headerActions != null) widget.headerActions!,
            ],
          ),
          if (isCompact) ...[
            if (widget.onSearch != null) ...[
              const SizedBox(height: 12),
              OiTextInput(
                placeholder: 'Search...',
                onChanged: widget.onSearch,
                controller: _searchController,
              ),
            ],
            if (hasFilters) ...[
              const SizedBox(height: 8),
              OiFilterBar(
                filters: widget.filters!,
                activeFilters: widget.activeFilters,
                onFilterChange: (updated) {
                  widget.onFilterChange?.call(updated);
                },
              ),
            ],
            if (widget.sortOptions != null &&
                widget.sortOptions!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildSortBar(context),
            ],
          ] else ...[
            if (widget.onSearch != null ||
                hasFilters ||
                (widget.sortOptions != null &&
                    widget.sortOptions!.isNotEmpty)) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (widget.onSearch != null)
                    Expanded(
                      child: OiTextInput(
                        placeholder: 'Search...',
                        onChanged: widget.onSearch,
                        controller: _searchController,
                      ),
                    ),
                  if (widget.onSearch != null &&
                      (hasFilters ||
                          (widget.sortOptions != null &&
                              widget.sortOptions!.isNotEmpty)))
                    const SizedBox(width: 16),
                  if (hasFilters)
                    Flexible(
                      child: OiFilterBar(
                        filters: widget.filters!,
                        activeFilters: widget.activeFilters,
                        onFilterChange: (updated) {
                          widget.onFilterChange?.call(updated);
                        },
                      ),
                    ),
                  if (hasFilters &&
                      widget.sortOptions != null &&
                      widget.sortOptions!.isNotEmpty)
                    const SizedBox(width: 16),
                  if (widget.sortOptions != null &&
                      widget.sortOptions!.isNotEmpty)
                    _buildSortBar(context),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildFiltersButton(BuildContext context) {
    final colors = context.colors;
    final activeCount = widget.activeFilters.length;

    return OiTappable(
      onTap: () => _openFilterSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: activeCount > 0
              ? colors.primary.base.withValues(alpha: 0.1)
              : null,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(OiIcons.alignLeft, size: 16, color: colors.text),
            const SizedBox(width: 4),
            OiLabel.small('Filters', color: colors.text),
            if (activeCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colors.primary.base,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: OiLabel.tiny(
                    '$activeCount',
                    color: colors.textOnPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSortBar(BuildContext context) {
    final colors = context.colors;
    final options = widget.sortOptions!;
    return Row(
      children: [
        OiLabel.small('Sort by:', color: colors.textMuted),
        const SizedBox(width: 8),
        OiSelect<String>.inline(
          options: [
            for (final option in options)
              OiSelectOption(value: option.id, label: option.label),
          ],
          value: widget.activeSort?.id ?? options.first.id,
          onChanged: (id) {
            if (id == null) return;
            final option = options.firstWhere((o) => o.id == id);
            widget.onSort?.call(option);
          },
        ),
      ],
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
          OiLabel.smallStrong(
            '${widget.selectedKeys.length} selected',
            color: colors.text,
          ),
          const Spacer(),
          ...actions,
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.loading && widget.items.isEmpty) {
      return const Center(child: OiProgress.linear(indeterminate: true));
    }

    if (widget.items.isEmpty && !widget.loading) {
      return widget.emptyState ?? const OiEmptyState(title: 'No items');
    }

    Widget buildItem(BuildContext context, int index) {
      if (index >= widget.items.length) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: OiProgress.linear(indeterminate: true)),
        );
      }
      final item = widget.items[index];
      final key = widget.itemKey(item);
      final isSelected = widget.selectedKeys.contains(key);

      var child = widget.itemBuilder(item);

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
    }

    final itemCount = widget.items.length + (widget.moreAvailable ? 1 : 0);

    final Widget list;
    if (widget.layout == OiListViewLayout.grid) {
      final defaultGap = OiResponsive<double>(context.spacing.md);
      list = SingleChildScrollView(
        key: const Key('oi_list_view_scroll'),
        controller: _scrollController,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: OiGrid.containerRelative(
          columns: widget.gridColumns ?? const OiResponsive<int>(3),
          gap: widget.gridGap ?? defaultGap,
          stretchRows: true,
          children: [
            for (var i = 0; i < itemCount; i++) buildItem(context, i),
          ],
        ),
      );
    } else {
      list = ListView.builder(
        key: const Key('oi_list_view_scroll'),
        controller: _scrollController,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          final child = buildItem(context, index);
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < widget.items.length - 1 ? context.spacing.md : 0,
            ),
            child: child,
          );
        },
      );
    }

    if (widget.onRefresh == null) return list;

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: list,
        ),
        if (_isRefreshing)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: OiProgress.linear(indeterminate: true),
              ),
            ),
          ),
      ],
    );
  }
}
