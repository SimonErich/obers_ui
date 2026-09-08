import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_pagination.dart';
import 'package:obers_ui/src/components/feedback/oi_bulk_bar.dart';
import 'package:obers_ui/src/components/panels/oi_resizable.dart';
import 'package:obers_ui/src/composites/data/oi_pagination_controller.dart';
import 'package:obers_ui/src/composites/data/oi_table_controller.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_mixin.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/settings/oi_table_settings.dart';

part 'oi_table/oi_table_body.part.dart';
part 'oi_table/oi_table_column_manager.part.dart';
part 'oi_table/oi_table_data.part.dart';
part 'oi_table/oi_table_header.part.dart';
part 'oi_table/oi_table_interactions.part.dart';
part 'oi_table/oi_table_loading.part.dart';
part 'oi_table/oi_table_pagination.part.dart';
part 'oi_table/oi_table_status.part.dart';

// ── Column definition ─────────────────────────────────────────────────────────

/// A column definition for [OiTable].
///
/// Describes how a single column is displayed, sorted, and filtered.
///
/// {@category Composites}
@immutable
class OiTableColumn<T> {
  /// Creates an [OiTableColumn].
  const OiTableColumn({
    required this.id,
    required this.header,
    this.width,
    this.minWidth = 60,
    this.maxWidth = 500,
    this.sortable = true,
    this.filterable = true,
    this.resizable = true,
    this.reorderable = true,
    this.hidden = false,
    this.frozen = false,
    this.cellBuilder,
    this.valueGetter,
    this.comparator,
    this.textAlign = TextAlign.start,
  });

  /// Unique identifier for this column.
  final String id;

  /// Text shown in the column header.
  final String header;

  /// Default width in logical pixels. When `null` the table uses a flex layout.
  final double? width;

  /// Minimum width in logical pixels.
  final double minWidth;

  /// Maximum width in logical pixels.
  final double maxWidth;

  /// Whether the user can sort by this column.
  final bool sortable;

  /// Whether the user can filter by this column.
  final bool filterable;

  /// Whether the user can resize this column by dragging its right edge.
  final bool resizable;

  /// Whether the user can drag this column header to reorder.
  final bool reorderable;

  /// Whether the column is initially hidden.
  final bool hidden;

  /// Whether this column is frozen to the left of the scroll viewport.
  final bool frozen;

  /// Custom cell builder. When `null` [valueGetter] is used to render a [Text].
  final Widget Function(BuildContext context, T row, int rowIndex)? cellBuilder;

  /// Extracts the cell value for this column from a row.
  ///
  /// Used for text rendering when [cellBuilder] is `null`, for filtering,
  /// and for the default sort comparator.
  final String Function(T row)? valueGetter;

  /// Custom comparator for sorting. When `null` string comparison is used.
  final int Function(T a, T b)? comparator;

  /// Alignment of text within each cell.
  final TextAlign textAlign;
}

// ── Pagination mode ───────────────────────────────────────────────────────────

/// Controls how [OiTable] handles pagination.
///
/// {@category Composites}
enum OiTablePaginationMode {
  /// No pagination — all rows are shown in a single scrolling list.
  none,

  /// Discrete pages with previous/next controls.
  pages,

  /// Infinite scroll — [OiTable.onLoadMore] is called when the user
  /// reaches the end of the list.
  infinite,

  /// Virtual/windowed pagination for very large server-side datasets.
  virtual,
}

// ── OiTable ───────────────────────────────────────────────────────────────────

/// A full-featured data table composite.
///
/// Supports sorting, filtering, column management, selection, inline editing,
/// row reordering, grouping, pagination, and settings persistence.
///
/// **(REQ-0438):** Provide a typed [rows] list and a set of [columns]
/// describing how each field should be displayed and interacted with.
///
/// **Accessibility (REQ-0014, REQ-0022):** [label] is required so every data
/// table has an accessible description announced by screen readers.
///
/// ```dart
/// OiTable<Person>(
///   label: 'Employee directory',
///   rows: people,
///   columns: [
///     OiTableColumn(id: 'name', header: 'Name',
///         valueGetter: (p) => p.name),
///     OiTableColumn(id: 'age',  header: 'Age',
///         valueGetter: (p) => p.age.toString()),
///   ],
/// )
/// ```
///
/// {@category Composites}
class OiTable<T> extends StatefulWidget {
  /// Creates an [OiTable].
  const OiTable({
    required this.label,
    required this.rows,
    required this.columns,
    this.controller,
    this.selectable = false,
    this.multiSelect = false,
    this.rowKey,
    this.onSelectionChanged,
    this.onRowTap,
    this.onRowDoubleTap,
    this.serverSideSort = false,
    this.onSort,
    this.serverSideFilter = false,
    this.onFilter,
    this.paginationMode = OiTablePaginationMode.none,
    this.totalRows,
    this.onLoadMore,
    this.pageSizeOptions = const [10, 25, 50, 100],
    this.onPageSizeChanged,
    this.onPageChange,
    this.showColumnManager = false,
    this.onCellChanged,
    this.reorderable = false,
    this.onRowReordered,
    this.copyable = false,
    this.groupBy,
    this.groupHeaderBuilder,
    this.emptyState,
    this.loading = false,
    this.striped = false,
    this.dense = false,
    this.rowHeight,
    this.showStatusBar = true,
    this.settingsDriver,
    this.settingsKey,
    this.settingsNamespace = 'oi_table',
    this.bulkActions,
    this.settingsSaveDebounce = const Duration(milliseconds: 500),
    this.shrinkWrap = false,
    super.key,
  }) : assert(
         !shrinkWrap ||
             (paginationMode != OiTablePaginationMode.infinite &&
                 paginationMode != OiTablePaginationMode.virtual),
         'shrinkWrap cannot be combined with infinite or virtual pagination: '
         "both load more rows in response to the table's own scroll "
         'position, which a shrink-wrapped table does not have.',
       );

  // ── Accessibility ────────────────────────────────────────────────────────

  /// Accessible label describing the table for screen readers.
  final String label;

  // ── Data ──────────────────────────────────────────────────────────────────

  /// The rows to display.
  final List<T> rows;

  /// The column definitions.
  final List<OiTableColumn<T>> columns;

  // ── Controller ────────────────────────────────────────────────────────────

  /// External controller. When `null` an internal one is created.
  final OiTableController? controller;

  // ── Selection ─────────────────────────────────────────────────────────────

  /// Whether rows are selectable.
  final bool selectable;

  /// Whether multiple rows can be selected simultaneously.
  final bool multiSelect;

  /// Extracts a stable, unique key from a row.
  ///
  /// Required when [selectable] is `true`. The key must be unique across all
  /// rows and remain stable across sort, filter, and pagination changes so
  /// that selection tracks the correct domain objects (REQ-0478).
  final String Function(T row)? rowKey;

  /// Called when the selection changes with the set of selected row keys.
  final void Function(Set<String> selectedKeys)? onSelectionChanged;

  // ── Row interaction ───────────────────────────────────────────────────────

  /// Called when a row is tapped.
  final void Function(T row, int index)? onRowTap;

  /// Called when a row is double-tapped.
  final void Function(T row, int index)? onRowDoubleTap;

  // ── Sorting ───────────────────────────────────────────────────────────────

  /// When `true`, sorting is delegated to the caller via [onSort] and the
  /// table does not reorder [rows] itself.
  final bool serverSideSort;

  /// Called when the user requests a sort, providing the column ID and
  /// direction.
  final void Function(String columnId, {required bool ascending})? onSort;

  // ── Filtering ─────────────────────────────────────────────────────────────

  /// When `true`, filtering is delegated to the caller via [onFilter] and the
  /// table does not filter [rows] itself.
  final bool serverSideFilter;

  /// Called when the active filter set changes.
  final void Function(Map<String, String> filters)? onFilter;

  // ── Pagination ────────────────────────────────────────────────────────────

  /// The pagination strategy.
  final OiTablePaginationMode paginationMode;

  /// Total row count for server-side pagination. Ignored for client-side modes.
  final int? totalRows;

  /// Called when the user reaches the end of the list in [OiTablePaginationMode.infinite]
  /// or [OiTablePaginationMode.virtual] mode.
  final Future<void> Function()? onLoadMore;

  /// The page size options displayed in the pagination page size selector.
  final List<int> pageSizeOptions;

  /// Called when the user selects a different page size.
  final ValueChanged<int>? onPageSizeChanged;

  /// Called when the current page or page size changes.
  ///
  /// Typically used with server-side pagination: the consumer fetches the
  /// requested page from a remote source, then updates [rows] and
  /// [OiTableController.totalRows].
  final void Function(int page, int pageSize)? onPageChange;

  // ── Column management ─────────────────────────────────────────────────────

  /// Whether to show a column manager button in the header bar.
  final bool showColumnManager;

  // ── Inline editing ────────────────────────────────────────────────────────

  /// Called when the user commits an inline cell edit.
  final void Function(T row, int rowIndex, String columnId, dynamic value)?
  onCellChanged;

  // ── Row reordering ────────────────────────────────────────────────────────

  /// Whether rows can be dragged to reorder them.
  final bool reorderable;

  /// Called after the user drops a row at a new position.
  final void Function(int oldIndex, int newIndex)? onRowReordered;

  // ── Copy ──────────────────────────────────────────────────────────────────

  /// Whether Ctrl+C copies the selected rows to the clipboard.
  final bool copyable;

  // ── Grouping ──────────────────────────────────────────────────────────────

  /// Column ID to group rows by initially. `null` disables grouping.
  final String? groupBy;

  /// Custom group header builder. When `null` a default header is shown.
  final Widget Function(BuildContext context, String groupKey, List<T> rows)?
  groupHeaderBuilder;

  // ── Empty / loading states ────────────────────────────────────────────────

  /// Widget displayed when [rows] is empty and [loading] is `false`.
  final Widget? emptyState;

  /// When `true` a loading indicator is shown instead of the row list.
  final bool loading;

  // ── Styling ───────────────────────────────────────────────────────────────

  /// Whether alternating rows have a subtle background tint.
  final bool striped;

  /// Whether to use compact row heights.
  final bool dense;

  /// Fixed row height. When `null` rows size to their content.
  final double? rowHeight;

  // ── Bulk actions ─────────────────────────────────────────────────────────

  /// Bulk action definitions. When provided and rows are selected, an
  /// [OiBulkBar] automatically appears at the bottom of the table.
  final List<OiBulkAction>? bulkActions;

  // ── Status bar ────────────────────────────────────────────────────────────

  /// Whether to show the status bar at the bottom of the table.
  final bool showStatusBar;

  // ── Settings persistence ──────────────────────────────────────────────────

  /// Driver used to persist settings. When `null` settings are not persisted.
  final OiSettingsDriver? settingsDriver;

  /// Sub-key scoping this table's settings within [settingsNamespace].
  final String? settingsKey;

  /// Top-level namespace for settings storage.
  final String settingsNamespace;

  /// Debounce duration for auto-saving settings after changes.
  ///
  /// Default: 500ms. Set to [Duration.zero] for immediate saves.
  final Duration settingsSaveDebounce;

  // ── Layout ────────────────────────────────────────────────────────────────

  /// Whether the table sizes itself to its rows instead of expanding to fill
  /// its parent.
  ///
  /// By default the table expands, which requires a parent that provides a
  /// bounded height. When `true`, the body shrink-wraps its rows so the table
  /// can be placed inside unbounded-height containers such as a [Column]
  /// inside a scroll view.
  ///
  /// Rows are no longer virtualised in this mode — every row is built and laid
  /// out eagerly, and scrolling is left to the surrounding scrollable. Prefer
  /// the default for large datasets.
  ///
  /// Cannot be combined with [OiTablePaginationMode.infinite] or
  /// [OiTablePaginationMode.virtual], which both depend on the table owning
  /// its own scroll position.
  final bool shrinkWrap;

  @override
  State<OiTable<T>> createState() => _OiTableState<T>();
}

// ── State ─────────────────────────────────────────────────────────────────────

class _OiTableState<T> extends State<OiTable<T>>
    with
        OiSettingsMixin<OiTable<T>, OiTableSettings>,
        TickerProviderStateMixin {
  late OiTableController _ctrl;
  bool _ownsController = false;
  bool _loadingMore = false;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  final Map<String, AnimationController> _groupExpandControllers = {};
  int _prevPage = 0;
  int _prevPageSize = 25;
  bool _needsHorizontalScroll = false;
  int? _hoveredRowIndex;

  /// Tracks the last row index selected by a single click, used for
  /// Shift+click range selection.
  int? _lastSelectedIndex;

  /// Focus node for the keyboard listener (Ctrl+C copy).
  final FocusNode _keyboardFocusNode = FocusNode();

  /// Overlay entry for the column manager panel.
  OverlayEntry? _columnManagerOverlay;

  /// Resolved driver: explicit widget prop → OiSettingsProvider → null.
  OiSettingsDriver? _resolvedDriver;

  // ── setState helpers (callable from extensions) ───────────────────────────

  void _setHoveredRow(int? index) => setState(() => _hoveredRowIndex = index);

  void _setLoadingMore({required bool loading}) =>
      setState(() => _loadingMore = loading);

  // ── OiSettingsMixin contract ───────────────────────────────────────────────

  @override
  String get settingsNamespace => widget.settingsNamespace;

  @override
  String? get settingsKey => widget.settingsKey;

  @override
  OiSettingsDriver? get settingsDriver => _resolvedDriver;

  @override
  OiTableSettings get defaultSettings => const OiTableSettings();

  @override
  OiTableSettings deserializeSettings(Map<String, dynamic> json) =>
      OiTableSettings.fromJson(json);

  @override
  OiTableSettings mergeSettings(
    OiTableSettings saved,
    OiTableSettings defaults,
  ) => saved.mergeWith(defaults);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    // Seed _resolvedDriver from the widget prop so that the mixin's initState
    // can start loading immediately when an explicit driver is provided.
    // Provider fallback is resolved later in didChangeDependencies.
    _resolvedDriver = widget.settingsDriver;
    super.initState();
    _initController();
    if (widget.groupBy != null) {
      _ctrl.groupByColumnId = widget.groupBy;
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(OiTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _disposeControllerIfOwned();
      _initController();
    }
    // Sync totalRows for server-side pagination.
    final total = widget.totalRows ?? widget.rows.length;
    if (_ctrl.pagination.totalItems != total) {
      _ctrl.pagination.setTotalItems(total);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Resolve driver: widget prop → OiSettingsProvider → null.
    final newDriver = widget.settingsDriver ?? OiSettingsProvider.of(context);
    if (newDriver != _resolvedDriver) {
      _resolvedDriver = newDriver;
      // Driver changed (e.g. provider now available) — reload settings.
      if (settingsLoaded) {
        unawaited(reloadSettings());
      }
    }
    // Apply persisted settings once they load, but only when a driver is
    // configured — without a driver, currentSettings is just defaultSettings
    // and applying it would overwrite the external controller's own state.
    if (settingsLoaded && settingsDriver != null) {
      _ctrl.applySettings(currentSettings);
    }
  }

  @override
  void dispose() {
    _closeColumnManager();
    _keyboardFocusNode.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _horizontalScrollController.dispose();
    for (final c in _groupExpandControllers.values) {
      c.dispose();
    }
    _disposeControllerIfOwned();
    super.dispose();
  }

  AnimationController _groupControllerFor(String groupKey) {
    return _groupExpandControllers.putIfAbsent(groupKey, () {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        value: _ctrl.expandedGroups.contains(groupKey) ? 1.0 : 0.0,
      );
    });
  }

  void _initController() {
    if (widget.controller != null) {
      _ctrl = widget.controller!;
      _ownsController = false;
      // Sync explicit totalRows into the external controller's pagination.
      if (widget.totalRows != null) {
        _ctrl.pagination.setTotalItems(widget.totalRows!);
      }
    } else {
      final total = widget.totalRows ?? widget.rows.length;
      _ctrl = OiTableController(totalRows: total);
      _ownsController = true;
    }
    _ctrl.addListener(_onControllerChanged);
    _prevPage = _ctrl.pagination.currentPage;
    _prevPageSize = _ctrl.pagination.pageSize;
  }

  void _disposeControllerIfOwned() {
    _ctrl.removeListener(_onControllerChanged);
    if (_ownsController) _ctrl.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    // Fire onPageChange when the current page or page size changes.
    final curPage = _ctrl.pagination.currentPage;
    final curPageSize = _ctrl.pagination.pageSize;
    if (widget.onPageChange != null &&
        (curPage != _prevPage || curPageSize != _prevPageSize)) {
      _prevPage = curPage;
      _prevPageSize = curPageSize;
      widget.onPageChange!(curPage, curPageSize);
    }
    // Snap group animation controllers to match the current expanded state
    // when toggled programmatically (not via the GestureDetector tap).
    for (final entry in _groupExpandControllers.entries) {
      final key = entry.key;
      final animCtrl = entry.value;
      if (_ctrl.expandedGroups.contains(key)) {
        if (animCtrl.isDismissed) animCtrl.value = 1.0;
      } else {
        if (animCtrl.isCompleted) animCtrl.value = 0.0;
      }
    }
    // Persist settings on every controller change (debounced by the mixin).
    updateSettings(_ctrl.toSettings(), debounce: widget.settingsSaveDebounce);
    setState(() {});
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  /// Wraps the header + body area so it expands to fill the available height,
  /// or sizes to its content when [OiTable.shrinkWrap] is set.
  Widget _wrapTableArea(Widget child) {
    if (widget.shrinkWrap) return child;
    return Expanded(child: child);
  }

  @override
  Widget build(BuildContext context) {
    final hasBulkActions =
        widget.bulkActions != null && widget.bulkActions!.isNotEmpty;

    final tableContent = Semantics(
      label: widget.label,
      explicitChildNodes: true,
      child: KeyboardListener(
        focusNode: _keyboardFocusNode,
        onKeyEvent: (event) {
          if (!widget.copyable) return;
          if (event is! KeyDownEvent) return;
          final isCtrlOrMeta =
              HardwareKeyboard.instance.isControlPressed ||
              HardwareKeyboard.instance.isMetaPressed;
          if (isCtrlOrMeta && event.logicalKey == LogicalKeyboardKey.keyC) {
            _copySelectedRows();
          }
        },
        child: Column(
          mainAxisSize: widget.shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showColumnManager) _buildColumnManagerBar(),
            _wrapTableArea(
              LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = _computeTotalColumnsWidth();
                  final needsScroll = totalWidth > constraints.maxWidth;
                  _needsHorizontalScroll = needsScroll;
                  final tableWidth = needsScroll
                      ? totalWidth
                      : constraints.maxWidth;

                  final header = _buildHeaderRow();
                  // When shrink-wrapping the body sizes to its rows, so it
                  // must not claim flex from the surrounding Column.
                  final body = widget.shrinkWrap
                      ? _buildBody()
                      : Expanded(child: _buildBody());

                  if (needsScroll) {
                    // Wrap header and body to scroll horizontally in sync.
                    return SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: tableWidth,
                        child: Column(
                          mainAxisSize: widget.shrinkWrap
                              ? MainAxisSize.min
                              : MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [header, body],
                        ),
                      ),
                    );
                  }

                  return Column(
                    mainAxisSize: widget.shrinkWrap
                        ? MainAxisSize.min
                        : MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [header, body],
                  );
                },
              ),
            ),
            if (widget.paginationMode == OiTablePaginationMode.pages)
              _buildPaginationFooter(),
            if (widget.showStatusBar) _buildStatusBar(),
          ],
        ),
      ),
    );

    if (!hasBulkActions) return tableContent;

    return Stack(children: [tableContent, _buildBulkBar()]);
  }
}
