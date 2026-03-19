import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/panels/oi_resizable.dart';
import 'package:obers_ui/src/composites/data/oi_pagination_controller.dart';
import 'package:obers_ui/src/composites/data/oi_table_controller.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_mixin.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';
import 'package:obers_ui/src/models/settings/oi_table_settings.dart';

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
/// Provide a typed [rows] list and a set of [columns] describing how each
/// field should be displayed and interacted with.
///
/// **Accessibility (REQ-0014):** [label] is required so every data table has
/// an accessible description announced by screen readers.
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
    this.settingsSaveDebounce = const Duration(milliseconds: 500),
    super.key,
  });

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

  @override
  State<OiTable<T>> createState() => _OiTableState<T>();
}

// ── State ─────────────────────────────────────────────────────────────────────

class _OiTableState<T> extends State<OiTable<T>>
    with OiSettingsMixin<OiTable<T>, OiTableSettings> {
  late OiTableController _ctrl;
  bool _ownsController = false;
  bool _loadingMore = false;
  final ScrollController _scrollController = ScrollController();
  int _prevPage = 0;
  int _prevPageSize = 25;

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
    final newDriver =
        widget.settingsDriver ?? OiSettingsProvider.of(context);
    if (newDriver != _resolvedDriver) {
      _resolvedDriver = newDriver;
      // Driver changed (e.g. provider now available) — reload settings.
      if (settingsLoaded) {
        reloadSettings();
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
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _disposeControllerIfOwned();
    super.dispose();
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
    // Persist settings on every controller change (debounced by the mixin).
    updateSettings(_ctrl.toSettings(), debounce: widget.settingsSaveDebounce);
    setState(() {});
  }

  void _onScroll() {
    if (!mounted) return;
    if (widget.paginationMode != OiTablePaginationMode.infinite) return;
    if (_loadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _triggerLoadMore();
    }
  }

  Future<void> _triggerLoadMore() async {
    if (_loadingMore || widget.onLoadMore == null) return;
    setState(() => _loadingMore = true);
    try {
      await widget.onLoadMore!();
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  // ── Data helpers ───────────────────────────────────────────────────────────

  /// Returns the effective column list respecting [OiTableController.columnOrder]
  /// and [OiTableController.columnVisibility].
  List<OiTableColumn<T>> get _visibleColumns {
    final order = _ctrl.columnOrder;
    final List<OiTableColumn<T>> cols;
    if (order.isEmpty) {
      cols = List<OiTableColumn<T>>.from(widget.columns);
    } else {
      final byId = {for (final c in widget.columns) c.id: c};
      cols = [
        for (final id in order)
          if (byId.containsKey(id)) byId[id]!,
        // Append any columns not mentioned in order.
        for (final c in widget.columns)
          if (!order.contains(c.id)) c,
      ];
    }
    return cols
        .where((c) => (_ctrl.columnVisibility[c.id] ?? true) && !c.hidden)
        .toList();
  }

  /// Applies client-side filter to [rows].
  List<T> get _filteredRows {
    if (widget.serverSideFilter || _ctrl.activeFilters.isEmpty) {
      return widget.rows;
    }
    return widget.rows.where((row) {
      for (final entry in _ctrl.activeFilters.entries) {
        final col = _columnById(entry.key);
        if (col == null) continue;
        final value = col.valueGetter?.call(row) ?? '';
        if (!value.toLowerCase().contains(entry.value.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  /// Applies client-side sort to [rows].
  List<T> _sortedRows(List<T> rows) {
    final colId = _ctrl.sortColumnId;
    if (widget.serverSideSort || colId == null) return rows;
    final col = _columnById(colId);
    if (col == null) return rows;
    final sorted = List<T>.from(rows)
      ..sort((a, b) {
        final cmp = col.comparator != null
            ? col.comparator!(a, b)
            : (col.valueGetter?.call(a) ?? '').compareTo(
                col.valueGetter?.call(b) ?? '',
              );
        return _ctrl.sortAscending ? cmp : -cmp;
      });
    return sorted;
  }

  /// Applies pagination to [rows] in [OiTablePaginationMode.pages] mode.
  ///
  /// When [OiPaginationController.serverSide] is `true` the rows are returned
  /// as-is because the consumer already provides the correct page of data.
  List<T> _paginatedRows(List<T> rows) {
    if (widget.paginationMode != OiTablePaginationMode.pages) return rows;
    if (_ctrl.pagination.serverSide) return rows;
    final start = _ctrl.pagination.startIndex;
    final end = math.min(_ctrl.pagination.endIndex, rows.length);
    if (start >= rows.length) return const [];
    return rows.sublist(start, end);
  }

  /// Returns [rows] after filter → sort → paginate pipeline.
  List<T> get _displayRows {
    final filtered = _filteredRows;
    final sorted = _sortedRows(filtered);
    // Update pagination total after filter — only for fully client-side tables
    // that do not supply an explicit totalRows override.
    if (!widget.serverSideSort &&
        !widget.serverSideFilter &&
        widget.totalRows == null &&
        !_ctrl.pagination.serverSide &&
        widget.paginationMode == OiTablePaginationMode.pages) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _ctrl.pagination.setTotalItems(sorted.length);
      });
    }
    return _paginatedRows(sorted);
  }

  OiTableColumn<T>? _columnById(String id) {
    for (final c in widget.columns) {
      if (c.id == id) return c;
    }
    return null;
  }

  // ── Interaction handlers ──────────────────────────────────────────────────

  void _handleHeaderTap(OiTableColumn<T> col) {
    if (!col.sortable) return;
    _ctrl.sortBy(col.id);
    widget.onSort?.call(col.id, ascending: _ctrl.sortAscending);
  }

  /// Returns the stable key for [row] at [index], using the [OiTable.rowKey]
  /// callback when provided, falling back to [index.toString()].
  String _rowKeyAt(T row, int index) {
    return widget.rowKey?.call(row) ?? index.toString();
  }

  /// Tracks the last row index selected by a single click, used for
  /// Shift+click range selection.
  int? _lastSelectedIndex;

  void _handleRowTap(T row, int index) {
    if (widget.selectable) {
      final isShift = HardwareKeyboard.instance.isShiftPressed;
      final isCtrlOrMeta = HardwareKeyboard.instance.isControlPressed ||
          HardwareKeyboard.instance.isMetaPressed;
      final key = _rowKeyAt(row, index);

      if (widget.multiSelect && isShift && _lastSelectedIndex != null) {
        // Shift+click: select range from last selected to current.
        final start = math.min(_lastSelectedIndex!, index);
        final end = math.max(_lastSelectedIndex!, index);
        final keys = <String>{};
        for (var i = start; i <= end; i++) {
          keys.add(_rowKeyAt(widget.rows[i], i));
        }
        _ctrl.selectRange(keys);
      } else if (widget.multiSelect && isCtrlOrMeta) {
        // Ctrl/Cmd+click: toggle this row without clearing others.
        _ctrl.toggleRow(key);
      } else {
        // Plain click always selects only the clicked row, even when
        // multiSelect is enabled. Multi-select accumulation is handled
        // by Ctrl+click (toggleRow) and Shift+click (selectRange).
        _ctrl.selectRow(key);
      }
      _lastSelectedIndex = index;
      widget.onSelectionChanged?.call(Set<String>.from(_ctrl.selectedRows));
    }
    widget.onRowTap?.call(row, index);
  }

  void _handleRowDoubleTap(T row, int index) {
    widget.onRowDoubleTap?.call(row, index);
  }

  void _copySelectedRows() {
    if (!widget.copyable) return;
    final cols = _visibleColumns;
    // Build a key→row map for O(n) lookup.
    final keyToRow = <String, T>{};
    for (var i = 0; i < widget.rows.length; i++) {
      keyToRow[_rowKeyAt(widget.rows[i], i)] = widget.rows[i];
    }
    final buffer = StringBuffer();
    for (final key in _ctrl.selectedRows) {
      final row = keyToRow[key];
      if (row != null) {
        final cells = cols
            .map((c) => c.valueGetter?.call(row) ?? '')
            .join('\t');
        buffer.writeln(cells);
      }
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      explicitChildNodes: true,
      child: KeyboardListener(
        focusNode: FocusNode(),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showColumnManager) _buildColumnManagerBar(),
            _buildHeaderRow(),
            Expanded(child: _buildBody()),
            if (widget.paginationMode == OiTablePaginationMode.pages)
              _buildPaginationFooter(),
            if (widget.showStatusBar) _buildStatusBar(),
          ],
        ),
      ),
    );
  }

  // ── Column manager bar ────────────────────────────────────────────────────

  Widget _buildColumnManagerBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: GestureDetector(
          onTap: _showColumnManager,
          child: const Text('Columns'),
        ),
      ),
    );
  }

  OverlayEntry? _columnManagerOverlay;

  void _showColumnManager() {
    if (_columnManagerOverlay != null) {
      _closeColumnManager();
      return;
    }
    final box = context.findRenderObject()! as RenderBox;
    final offset = box.localToGlobal(Offset.zero);

    _columnManagerOverlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeColumnManager,
            ),
          ),
          Positioned(
            right: 8,
            top: offset.dy + 32,
            child: _ColumnManagerPanel<T>(
              columns: widget.columns,
              visibility: _ctrl.columnVisibility,
              onToggle: (columnId, visible) {
                _ctrl.setColumnVisible(columnId, visible: visible);
                _columnManagerOverlay?.markNeedsBuild();
              },
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_columnManagerOverlay!);
  }

  void _closeColumnManager() {
    _columnManagerOverlay?.remove();
    _columnManagerOverlay?.dispose();
    _columnManagerOverlay = null;
  }

  // ── Header row ────────────────────────────────────────────────────────────

  Widget _buildHeaderRow() {
    final cols = _visibleColumns;
    return ColoredBox(
      key: const Key('oi_table_header'),
      color: const Color(0xFFF1F5F9),
      child: Row(
        children: [
          if (widget.selectable) _buildSelectAllCheckbox(),
          for (var i = 0; i < cols.length; i++)
            _buildDraggableColumnHeader(cols[i], i, cols.length),
        ],
      ),
    );
  }

  /// Wraps a column header with drag-to-reorder when [OiTableColumn.reorderable]
  /// is `true`.
  Widget _buildDraggableColumnHeader(
    OiTableColumn<T> col,
    int displayIndex,
    int totalColumns,
  ) {
    final header = _buildColumnHeader(col);
    if (!col.reorderable) return header;
    return DragTarget<String>(
      key: ValueKey('drop_${col.id}'),
      onWillAcceptWithDetails: (details) => details.data != col.id,
      onAcceptWithDetails: (details) {
        final draggedId = details.data;
        _ensureColumnOrder();
        final oldIdx = _ctrl.columnOrder.indexOf(draggedId);
        final newIdx = _ctrl.columnOrder.indexOf(col.id);
        if (oldIdx >= 0 && newIdx >= 0) {
          _ctrl.reorderColumns(
            oldIdx,
            newIdx > oldIdx ? newIdx + 1 : newIdx,
          );
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isOver = candidateData.isNotEmpty;
        return Draggable<String>(
          data: col.id,
          axis: Axis.horizontal,
          feedback: Opacity(
            opacity: 0.7,
            child: ColoredBox(
              color: const Color(0xFFE2E8F0),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Text(
                  col.header,
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: header),
          child: isOver
              ? DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Color(0xFF2563EB),
                        width: 2,
                      ),
                    ),
                  ),
                  child: header,
                )
              : header,
        );
      },
    );
  }

  /// Ensures [_ctrl.columnOrder] is populated with visible column IDs.
  void _ensureColumnOrder() {
    if (_ctrl.columnOrder.isEmpty) {
      _ctrl.columnOrder.addAll(
        _visibleColumns.map((c) => c.id),
      );
    }
  }

  Widget _buildSelectAllCheckbox() {
    return GestureDetector(
      onTap: () {
        if (_ctrl.selectAll) {
          _ctrl.clearSelection();
        } else {
          final allKeys = <String>{};
          for (var i = 0; i < widget.rows.length; i++) {
            allKeys.add(_rowKeyAt(widget.rows[i], i));
          }
          _ctrl.selectAllRows(allKeys);
        }
        widget.onSelectionChanged?.call(Set<String>.from(_ctrl.selectedRows));
      },
      child: SizedBox(
        width: 40,
        height: _effectiveRowHeight,
        child: Center(child: Text(_ctrl.selectAll ? '☑' : '☐')),
      ),
    );
  }

  /// Arrow-up icon for ascending sort indicator.
  static const _arrowUp = IconData(0xe5c7, fontFamily: 'MaterialIcons');

  /// Arrow-down icon for descending sort indicator.
  static const _arrowDown = IconData(0xe5c5, fontFamily: 'MaterialIcons');

  Widget _buildColumnHeader(OiTableColumn<T> col) {
    final isSorted = _ctrl.sortColumnId == col.id;
    final width = _ctrl.columnWidths[col.id] ?? col.width;
    final innerContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              col.header,
              textAlign: col.textAlign,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isSorted)
            Icon(
              _ctrl.sortAscending ? _arrowUp : _arrowDown,
              size: 16,
            ),
        ],
      ),
    );
    // When no explicit width is set, use a flexible default so the cell
    // fills available space rather than collapsing to zero.
    final resolvedWidth =
        width ?? col.minWidth.clamp(col.minWidth, col.maxWidth);
    final headerContent = GestureDetector(
      onTap: () => _handleHeaderTap(col),
      child: SizedBox(
        height: _effectiveRowHeight,
        child: innerContent,
      ),
    );
    Widget header;
    if (col.resizable) {
      header = OiResizable(
        key: ValueKey('resize_${col.id}'),
        initialWidth: resolvedWidth,
        minWidth: col.minWidth,
        maxWidth: col.maxWidth,
        resizeEdges: const {OiResizeEdge.right},
        onResized: (w, _) => _ctrl.setColumnWidth(col.id, w),
        child: headerContent,
      );
    } else {
      header = SizedBox(width: resolvedWidth, child: headerContent);
    }
    if (col.filterable) {
      header = Column(
        mainAxisSize: MainAxisSize.min,
        children: [header, _buildFilterInput(col)],
      );
    }
    return header;
  }

  Widget _buildFilterInput(OiTableColumn<T> col) {
    return SizedBox(
      width: _ctrl.columnWidths[col.id] ?? col.width ?? 120,
      height: 28,
      child: _FilterField(
        key: ValueKey('filter_${col.id}'),
        initialValue: _ctrl.activeFilters[col.id] ?? '',
        onChanged: (v) {
          if (v.isEmpty) {
            _ctrl.clearFilter(col.id);
          } else {
            _ctrl.setFilter(col.id, v);
          }
          widget.onFilter?.call(Map.unmodifiable(_ctrl.activeFilters));
        },
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (widget.loading) return _buildLoadingState();
    final rows = _displayRows;

    Widget body;
    if (rows.isEmpty && !_ctrl.loading) {
      body = widget.emptyState ?? _buildDefaultEmptyState();
    } else if (widget.groupBy != null || _ctrl.groupByColumnId != null) {
      body = _buildGroupedBody(rows);
    } else {
      body = _buildFlatBody(rows);
    }

    if (_ctrl.loading) {
      return Stack(
        children: [
          body,
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _OiTableLoadingBar(),
          ),
        ],
      );
    }

    return body;
  }

  Widget _buildLoadingState() {
    return const Center(key: Key('oi_table_loading'), child: _OiTableSpinner());
  }

  Widget _buildDefaultEmptyState() {
    return const Center(key: Key('oi_table_empty'), child: Text('No data'));
  }

  Widget _buildFlatBody(List<T> rows) {
    if (widget.reorderable) {
      return _buildReorderableBody(rows);
    }
    return ListView.builder(
      controller: _scrollController,
      itemCount: rows.length + (_loadingMore ? 1 : 0),
      itemBuilder: (ctx, int i) {
        if (i == rows.length) {
          return const Center(
            key: Key('oi_table_load_more_indicator'),
            child: _OiTableSpinner(),
          );
        }
        return _buildRow(rows[i], i);
      },
    );
  }

  Widget _buildReorderableBody(List<T> rows) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverReorderableList(
          itemCount: rows.length,
          onReorder: (oldIndex, newIndex) {
            widget.onRowReordered?.call(oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            return ReorderableDragStartListener(
              key: ValueKey('reorderable_row_$index'),
              index: index,
              child: _buildRow(
                rows[index],
                index,
                key: ValueKey('reorderable_row_$index'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGroupedBody(List<T> rows) {
    final groupColId =
        _ctrl.groupByColumnId ?? widget.groupBy ?? widget.columns.first.id;
    final col = _columnById(groupColId);
    // Group rows by their valueGetter value.
    final groups = <String, List<T>>{};
    for (final row in rows) {
      final key = col?.valueGetter?.call(row) ?? '';
      groups.putIfAbsent(key, () => []).add(row);
    }
    final items = <Widget>[];
    for (final entry in groups.entries) {
      final groupKey = entry.key;
      final groupRows = entry.value;
      final expanded = _ctrl.expandedGroups.contains(groupKey);
      // Group header.
      final header = widget.groupHeaderBuilder != null
          ? widget.groupHeaderBuilder!(context, groupKey, groupRows)
          : _buildDefaultGroupHeader(groupKey, groupRows.length, expanded);
      items.add(
        GestureDetector(
          key: ValueKey('group_$groupKey'),
          onTap: () => _ctrl.toggleGroup(groupKey),
          child: header,
        ),
      );
      if (expanded) {
        for (var i = 0; i < groupRows.length; i++) {
          items.add(_buildRow(groupRows[i], i));
        }
      }
    }
    return ListView(controller: _scrollController, children: items);
  }

  Widget _buildDefaultGroupHeader(String groupKey, int count, bool expanded) {
    return ColoredBox(
      key: ValueKey('group_header_$groupKey'),
      color: const Color(0xFFE2E8F0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Text(expanded ? '▼' : '▶'),
            const SizedBox(width: 8),
            Text('$groupKey ($count)'),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(T row, int index, {Key? key}) {
    final isSelected = _ctrl.selectedRows.contains(_rowKeyAt(row, index));
    final isEven = index.isEven;
    Color? bg;
    if (isSelected) {
      bg = const Color(0xFFDBEAFE);
    } else if (widget.striped && isEven) {
      bg = const Color(0xFFF8FAFC);
    }
    final rowContent = Row(
      children: [
        if (widget.selectable)
          SizedBox(
            width: 40,
            height: _effectiveRowHeight,
            child: Center(child: Text(isSelected ? '☑' : '☐')),
          ),
        for (final col in _visibleColumns) _buildCell(row, index, col),
      ],
    );
    return GestureDetector(
      key: key ?? ValueKey('row_$index'),
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleRowTap(row, index),
      onDoubleTap: () => _handleRowDoubleTap(row, index),
      child: bg != null ? ColoredBox(color: bg, child: rowContent) : rowContent,
    );
  }

  Widget _buildCell(T row, int rowIndex, OiTableColumn<T> col) {
    final width = _ctrl.columnWidths[col.id] ?? col.width;
    Widget content;
    if (col.cellBuilder != null) {
      content = col.cellBuilder!(context, row, rowIndex);
    } else {
      final text = col.valueGetter?.call(row) ?? '';
      content = Text(text, textAlign: col.textAlign);
    }
    if (widget.onCellChanged != null) {
      content = _CellFrame<T>(
        row: row,
        rowIndex: rowIndex,
        columnId: col.id,
        child: content,
        onChanged: (value) =>
            widget.onCellChanged!(row, rowIndex, col.id, value),
      );
    }
    final resolvedWidth =
        width ?? col.minWidth.clamp(col.minWidth, col.maxWidth);
    return SizedBox(
      width: resolvedWidth,
      height: _effectiveRowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Align(
          alignment: _alignmentFromTextAlign(col.textAlign),
          child: content,
        ),
      ),
    );
  }

  // ── Pagination footer ─────────────────────────────────────────────────────

  Widget _buildPaginationFooter() {
    return _PaginationBar(
      key: const Key('oi_table_pagination'),
      pagination: _ctrl.pagination,
      pageSizeOptions: widget.pageSizeOptions,
      onPageSizeChanged: widget.onPageSizeChanged,
    );
  }

  // ── Status bar ────────────────────────────────────────────────────────────

  Widget _buildStatusBar() {
    final totalShown = _displayRows.length;
    final selected = _ctrl.selectedRows.length;
    return ColoredBox(
      key: const Key('oi_table_status_bar'),
      color: const Color(0xFFF1F5F9),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Text('$totalShown rows'),
            if (selected > 0) ...[
              const SizedBox(width: 16),
              Text('$selected selected'),
            ],
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  double get _effectiveRowHeight =>
      widget.rowHeight ?? (widget.dense ? 32 : 48);

  static AlignmentGeometry _alignmentFromTextAlign(TextAlign align) {
    return switch (align) {
      TextAlign.center => Alignment.center,
      TextAlign.end || TextAlign.right => AlignmentDirectional.centerEnd,
      _ => AlignmentDirectional.centerStart,
    };
  }
}

// ── _CellFrame ────────────────────────────────────────────────────────────────

/// Internal widget that wraps a table cell and handles the transition between
/// display mode and edit mode.
class _CellFrame<T> extends StatefulWidget {
  const _CellFrame({
    required this.row,
    required this.rowIndex,
    required this.columnId,
    required this.child,
    required this.onChanged,
    super.key,
  });

  final T row;
  final int rowIndex;
  final String columnId;
  final Widget child;
  final void Function(dynamic value) onChanged;

  @override
  State<_CellFrame<T>> createState() => _CellFrameState<T>();
}

class _CellFrameState<T> extends State<_CellFrame<T>> {
  bool _editing = false;
  final TextEditingController _textCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _startEdit() {
    setState(() => _editing = true);
  }

  void _commit() {
    widget.onChanged(_textCtrl.text);
    setState(() => _editing = false);
  }

  void _cancel() {
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: EditableText(
              controller: _textCtrl,
              focusNode: FocusNode()..requestFocus(),
              style: const TextStyle(fontSize: 14),
              cursorColor: const Color(0xFF2563EB),
              backgroundCursorColor: const Color(0xFFD1D5DB),
            ),
          ),
          GestureDetector(onTap: _commit, child: const Text('✓')),
          GestureDetector(onTap: _cancel, child: const Text('✗')),
        ],
      );
    }
    return GestureDetector(
      key: const Key('cell_display'),
      onDoubleTap: _startEdit,
      child: widget.child,
    );
  }
}

// ── _FilterField ──────────────────────────────────────────────────────────────

class _FilterField extends StatefulWidget {
  const _FilterField({
    required this.initialValue,
    required this.onChanged,
    super.key,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_FilterField> createState() => _FilterFieldState();
}

class _FilterFieldState extends State<_FilterField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditableText(
      controller: _ctrl,
      focusNode: FocusNode(),
      style: const TextStyle(fontSize: 12),
      cursorColor: const Color(0xFF2563EB),
      backgroundCursorColor: const Color(0xFFD1D5DB),
      onChanged: widget.onChanged,
    );
  }
}

// ── _PaginationBar ────────────────────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.pagination,
    this.pageSizeOptions = const [10, 25, 50, 100],
    this.onPageSizeChanged,
    super.key,
  });

  final OiPaginationController pagination;
  final List<int> pageSizeOptions;
  final ValueChanged<int>? onPageSizeChanged;

  /// Computes which page numbers to display, using `null` for ellipsis gaps.
  ///
  /// Pages are zero-based. When [totalPages] <= 7 all pages are shown.
  /// Otherwise first, last, current, and immediate neighbors are shown
  /// with ellipsis for gaps.
  static List<int?> computeVisiblePages(int currentPage, int totalPages) {
    const maxVisible = 7;
    if (totalPages <= maxVisible) {
      return List<int>.generate(totalPages, (i) => i);
    }

    final pages = <int>{0, totalPages - 1};
    for (var i = currentPage - 1; i <= currentPage + 1; i++) {
      if (i >= 0 && i < totalPages) pages.add(i);
    }

    final sorted = pages.toList()..sort();
    final result = <int?>[];

    for (var i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) {
        result.add(null); // ellipsis
      }
      result.add(sorted[i]);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: pagination,
      builder: (_, __) {
        final total = pagination.totalItems;
        final start = total == 0 ? 0 : pagination.startIndex + 1;
        final end = pagination.endIndex;
        final visiblePages = computeVisiblePages(
          pagination.currentPage,
          pagination.totalPages,
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              // Left: row range text
              Flexible(
                child: Text(
                  key: const Key('pagination_showing'),
                  'Showing $start\u2013$end of $total rows',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              // Middle: page size selector
              const Text('Rows per page: '),
              _PageSizeSelector(
                currentSize: pagination.pageSize,
                options: pageSizeOptions,
                onChanged: (size) {
                  pagination.setPageSize(size);
                  onPageSizeChanged?.call(size);
                },
              ),
              const SizedBox(width: 16),
              // Right: navigation controls
              _navButton(
                key: const Key('pagination_first'),
                label: '«',
                enabled: pagination.hasPreviousPage,
                onTap: pagination.firstPage,
              ),
              _navButton(
                key: const Key('pagination_prev'),
                label: '‹',
                enabled: pagination.hasPreviousPage,
                onTap: pagination.previousPage,
              ),
              for (var i = 0; i < visiblePages.length; i++)
                if (visiblePages[i] == null)
                  Padding(
                    key: Key('pagination_ellipsis_$i'),
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: const Text('\u2026'),
                  )
                else
                  _pageButton(visiblePages[i]!),
              _navButton(
                key: const Key('pagination_next'),
                label: '›',
                enabled: pagination.hasNextPage,
                onTap: pagination.nextPage,
              ),
              _navButton(
                key: const Key('pagination_last'),
                label: '»',
                enabled: pagination.hasNextPage,
                onTap: pagination.lastPage,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _navButton({
    required Key key,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          label,
          style: TextStyle(
            color: enabled
                ? const Color(0xFF1F2937)
                : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }

  Widget _pageButton(int page) {
    final isCurrent = page == pagination.currentPage;
    return GestureDetector(
      key: Key('pagination_page_$page'),
      onTap: isCurrent ? null : () => pagination.goToPage(page),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: isCurrent
            ? BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(4),
              )
            : null,
        child: Text(
          '${page + 1}',
          style: TextStyle(
            color: isCurrent
                ? const Color(0xFFFFFFFF)
                : const Color(0xFF1F2937),
            fontWeight: isCurrent ? FontWeight.bold : null,
          ),
        ),
      ),
    );
  }
}

// ── _PageSizeSelector ─────────────────────────────────────────────────────────

class _PageSizeSelector extends StatefulWidget {
  const _PageSizeSelector({
    required this.currentSize,
    required this.options,
    required this.onChanged,
  });

  final int currentSize;
  final List<int> options;
  final ValueChanged<int> onChanged;

  @override
  State<_PageSizeSelector> createState() => _PageSizeSelectorState();
}

class _PageSizeSelectorState extends State<_PageSizeSelector> {
  OverlayEntry? _overlayEntry;

  void _toggle() {
    if (_overlayEntry != null) {
      _closeOverlay();
    } else {
      _openOverlay();
    }
  }

  void _openOverlay() {
    final box = context.findRenderObject()! as RenderBox;
    final offset = box.localToGlobal(Offset.zero);

    final entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeOverlay,
            ),
          ),
          Positioned(
            left: offset.dx,
            top: 0,
            height: offset.dy,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: IntrinsicWidth(
                child: Container(
                  key: const Key('pagination_page_size_dropdown'),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final size in widget.options)
                        GestureDetector(
                          key: Key('page_size_option_$size'),
                          onTap: () {
                            widget.onChanged(size);
                            _closeOverlay();
                          },
                          behavior: HitTestBehavior.opaque,
                          child: ColoredBox(
                            color: size == widget.currentSize
                                ? const Color(0xFFEFF6FF)
                                : const Color(0x00000000),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Text('$size'),
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
    );
    _overlayEntry = entry;
    Overlay.of(context).insert(entry);
  }

  void _closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _closeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('pagination_page_size'),
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${widget.currentSize}'),
            const SizedBox(width: 4),
            const Text('\u25be', style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ── _OiTableLoadingBar ────────────────────────────────────────────────────

/// An indeterminate loading bar shown when [OiTableController.loading] is
/// `true`. Renders a thin animated bar across the top of the table body.
class _OiTableLoadingBar extends StatefulWidget {
  const _OiTableLoadingBar();

  @override
  State<_OiTableLoadingBar> createState() => _OiTableLoadingBarState();
}

class _OiTableLoadingBarState extends State<_OiTableLoadingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          key: const Key('oi_table_loading_bar'),
          painter: _LoadingBarPainter(progress: _ctrl.value),
          size: const Size(double.infinity, 3),
        );
      },
    );
  }
}

class _LoadingBarPainter extends CustomPainter {
  const _LoadingBarPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // Background track.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFE5E7EB),
    );
    // Animated bar segment.
    final barWidth = size.width * 0.3;
    final start = (size.width + barWidth) * progress - barWidth;
    canvas.drawRect(
      Rect.fromLTWH(start, 0, barWidth, size.height),
      Paint()..color = const Color(0xFF2563EB),
    );
  }

  @override
  bool shouldRepaint(_LoadingBarPainter old) => old.progress != progress;
}

// ── _OiTableSpinner ───────────────────────────────────────────────────────────

class _OiTableSpinner extends StatefulWidget {
  const _OiTableSpinner();

  @override
  State<_OiTableSpinner> createState() => _OiTableSpinnerState();
}

class _OiTableSpinnerState extends State<_OiTableSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CustomPaint(painter: _SpinnerPainter()),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      0,
      4.2,
      false,
      Paint()
        ..color = const Color(0xFF2563EB)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => false;
}

// ── _ColumnManagerPanel ────────────────────────────────────────────────────────

/// Overlay panel that lets the user toggle column visibility.
class _ColumnManagerPanel<T> extends StatelessWidget {
  const _ColumnManagerPanel({
    required this.columns,
    required this.visibility,
    required this.onToggle,
  });

  final List<OiTableColumn<T>> columns;
  final Map<String, bool> visibility;
  final void Function(String columnId, bool visible) onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('oi_table_column_manager'),
      constraints: const BoxConstraints(maxWidth: 240),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Text(
              'Columns',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          for (final col in columns)
            GestureDetector(
              key: Key('col_manager_${col.id}'),
              behavior: HitTestBehavior.opaque,
              onTap: () {
                final currentlyVisible = visibility[col.id] ?? true;
                onToggle(col.id, !currentlyVisible);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Text((visibility[col.id] ?? true) ? '☑' : '☐'),
                    const SizedBox(width: 8),
                    Expanded(child: Text(col.header)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
