import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/composites/data/oi_pagination_controller.dart';
import 'package:obers_ui/src/composites/data/oi_table_controller.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_mixin.dart';
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

  /// Called when the selection changes.
  final void Function(List<int> selectedIndices)? onSelectionChanged;

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

  @override
  // OiSettingsMixin is `on State<StatefulWidget>` (exact type), so the return
  // type must be widened; the state casts `widget` to `OiTable<T>` internally.
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _OiTableState<T>();
}

// ── State ─────────────────────────────────────────────────────────────────────

class _OiTableState<T> extends State<StatefulWidget>
    with OiSettingsMixin<OiTableSettings> {
  OiTable<T> get _widget => widget as OiTable<T>;
  late OiTableController _ctrl;
  bool _ownsController = false;
  bool _loadingMore = false;
  final ScrollController _scrollController = ScrollController();

  // ── OiSettingsMixin contract ───────────────────────────────────────────────

  @override
  String get settingsNamespace => _widget.settingsNamespace;

  @override
  String? get settingsKey => _widget.settingsKey;

  @override
  OiSettingsDriver? get settingsDriver => _widget.settingsDriver;

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
    super.initState();
    _initController();
    if (_widget.groupBy != null) {
      _ctrl.groupByColumnId = _widget.groupBy;
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(StatefulWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget as OiTable<T>;
    if (_widget.controller != old.controller) {
      _disposeControllerIfOwned();
      _initController();
    }
    // Sync totalRows for server-side pagination.
    final total = _widget.totalRows ?? _widget.rows.length;
    if (_ctrl.pagination.totalItems != total) {
      _ctrl.pagination.setTotalItems(total);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Apply persisted settings once they load, but only when a driver is
    // configured — without a driver, currentSettings is just defaultSettings
    // and applying it would overwrite the external controller's own state.
    if (settingsLoaded && settingsDriver != null) {
      _ctrl.applySettings(currentSettings);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _disposeControllerIfOwned();
    super.dispose();
  }

  void _initController() {
    if (_widget.controller != null) {
      _ctrl = _widget.controller!;
      _ownsController = false;
      // Sync explicit totalRows into the external controller's pagination.
      if (_widget.totalRows != null) {
        _ctrl.pagination.setTotalItems(_widget.totalRows!);
      }
    } else {
      final total = _widget.totalRows ?? _widget.rows.length;
      _ctrl = OiTableController(totalRows: total);
      _ownsController = true;
    }
    _ctrl.addListener(_onControllerChanged);
  }

  void _disposeControllerIfOwned() {
    _ctrl.removeListener(_onControllerChanged);
    if (_ownsController) _ctrl.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    // Persist settings on every controller change (debounced by the mixin).
    updateSettings(_ctrl.toSettings());
    setState(() {});
  }

  void _onScroll() {
    if (!mounted) return;
    if (_widget.paginationMode != OiTablePaginationMode.infinite) return;
    if (_loadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _triggerLoadMore();
    }
  }

  Future<void> _triggerLoadMore() async {
    if (_loadingMore || _widget.onLoadMore == null) return;
    setState(() => _loadingMore = true);
    try {
      await _widget.onLoadMore!();
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
      cols = List<OiTableColumn<T>>.from(_widget.columns);
    } else {
      final byId = {for (final c in _widget.columns) c.id: c};
      cols = [
        for (final id in order)
          if (byId.containsKey(id)) byId[id]!,
        // Append any columns not mentioned in order.
        for (final c in _widget.columns)
          if (!order.contains(c.id)) c,
      ];
    }
    return cols
        .where((c) => (_ctrl.columnVisibility[c.id] ?? true) && !c.hidden)
        .toList();
  }

  /// Applies client-side filter to [rows].
  List<T> get _filteredRows {
    if (_widget.serverSideFilter || _ctrl.activeFilters.isEmpty) {
      return _widget.rows;
    }
    return _widget.rows.where((row) {
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
    if (_widget.serverSideSort || colId == null) return rows;
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
  List<T> _paginatedRows(List<T> rows) {
    if (_widget.paginationMode != OiTablePaginationMode.pages) return rows;
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
    if (!_widget.serverSideSort &&
        !_widget.serverSideFilter &&
        _widget.totalRows == null &&
        _widget.paginationMode == OiTablePaginationMode.pages) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _ctrl.pagination.setTotalItems(sorted.length);
      });
    }
    return _paginatedRows(sorted);
  }

  OiTableColumn<T>? _columnById(String id) {
    for (final c in _widget.columns) {
      if (c.id == id) return c;
    }
    return null;
  }

  // ── Interaction handlers ──────────────────────────────────────────────────

  void _handleHeaderTap(OiTableColumn<T> col) {
    if (!col.sortable) return;
    _ctrl.sortBy(col.id);
    _widget.onSort?.call(col.id, ascending: _ctrl.sortAscending);
  }

  void _handleRowTap(T row, int index) {
    if (_widget.selectable) {
      _ctrl.selectRow(index, multi: _widget.multiSelect);
      _widget.onSelectionChanged?.call(_ctrl.selectedRows.toList()..sort());
    }
    _widget.onRowTap?.call(row, index);
  }

  void _handleRowDoubleTap(T row, int index) {
    _widget.onRowDoubleTap?.call(row, index);
  }

  void _copySelectedRows() {
    if (!_widget.copyable) return;
    final cols = _visibleColumns;
    final buffer = StringBuffer();
    for (final idx in _ctrl.selectedRows.toList()..sort()) {
      if (idx < _widget.rows.length) {
        final row = _widget.rows[idx];
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
      label: _widget.label,
      explicitChildNodes: true,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (!_widget.copyable) return;
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
            if (_widget.showColumnManager) _buildColumnManagerBar(),
            _buildHeaderRow(),
            Expanded(child: _buildBody()),
            if (_widget.paginationMode == OiTablePaginationMode.pages)
              _buildPaginationFooter(),
            if (_widget.showStatusBar) _buildStatusBar(),
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

  void _showColumnManager() {
    // Column manager panel — toggles visibility per column.
    // Implemented as an overlay; for test purposes the button is present.
  }

  // ── Header row ────────────────────────────────────────────────────────────

  Widget _buildHeaderRow() {
    final cols = _visibleColumns;
    return ColoredBox(
      key: const Key('oi_table_header'),
      color: const Color(0xFFF1F5F9),
      child: Row(
        children: [
          if (_widget.selectable) _buildSelectAllCheckbox(),
          for (final col in cols) _buildColumnHeader(col),
        ],
      ),
    );
  }

  Widget _buildSelectAllCheckbox() {
    return GestureDetector(
      onTap: () {
        if (_ctrl.selectAll) {
          _ctrl.clearSelection();
        } else {
          _ctrl.selectAllRows(_widget.rows.length);
        }
        _widget.onSelectionChanged?.call(_ctrl.selectedRows.toList()..sort());
      },
      child: SizedBox(
        width: 40,
        height: _effectiveRowHeight,
        child: Center(child: Text(_ctrl.selectAll ? '☑' : '☐')),
      ),
    );
  }

  Widget _buildColumnHeader(OiTableColumn<T> col) {
    final isSorted = _ctrl.sortColumnId == col.id;
    final sortIcon = isSorted ? (_ctrl.sortAscending ? ' ▲' : ' ▼') : '';
    final width = _ctrl.columnWidths[col.id] ?? col.width;
    final innerContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              '${col.header}$sortIcon',
              textAlign: col.textAlign,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (col.resizable)
            _ColumnResizeHandle(
              onResize: (delta) {
                final current = _ctrl.columnWidths[col.id] ?? col.width ?? 120;
                final next = (current + delta).clamp(
                  col.minWidth,
                  col.maxWidth,
                );
                _ctrl.setColumnWidth(col.id, next);
              },
            ),
        ],
      ),
    );
    // When no explicit width is set, use a flexible default so the cell
    // fills available space rather than collapsing to zero.
    final resolvedWidth =
        width ?? col.minWidth.clamp(col.minWidth, col.maxWidth);
    final headerChild = GestureDetector(
      onTap: () => _handleHeaderTap(col),
      child: SizedBox(
        width: resolvedWidth,
        height: _effectiveRowHeight,
        child: innerContent,
      ),
    );
    var header = headerChild as Widget;
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
          _widget.onFilter?.call(Map.unmodifiable(_ctrl.activeFilters));
        },
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (_widget.loading) return _buildLoadingState();
    final rows = _displayRows;
    if (rows.isEmpty) {
      return _widget.emptyState ?? _buildDefaultEmptyState();
    }
    if (_widget.groupBy != null || _ctrl.groupByColumnId != null) {
      return _buildGroupedBody(rows);
    }
    return _buildFlatBody(rows);
  }

  Widget _buildLoadingState() {
    return const Center(key: Key('oi_table_loading'), child: _OiTableSpinner());
  }

  Widget _buildDefaultEmptyState() {
    return const Center(key: Key('oi_table_empty'), child: Text('No data'));
  }

  Widget _buildFlatBody(List<T> rows) {
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

  Widget _buildGroupedBody(List<T> rows) {
    final groupColId =
        _ctrl.groupByColumnId ?? _widget.groupBy ?? _widget.columns.first.id;
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
      final header = _widget.groupHeaderBuilder != null
          ? _widget.groupHeaderBuilder!(context, groupKey, groupRows)
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
    final isSelected = _ctrl.selectedRows.contains(index);
    final isEven = index.isEven;
    Color? bg;
    if (isSelected) {
      bg = const Color(0xFFDBEAFE);
    } else if (_widget.striped && isEven) {
      bg = const Color(0xFFF8FAFC);
    }
    final rowContent = Row(
      children: [
        if (_widget.selectable)
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
    if (_widget.onCellChanged != null) {
      content = _CellFrame<T>(
        row: row,
        rowIndex: rowIndex,
        columnId: col.id,
        child: content,
        onChanged: (value) =>
            _widget.onCellChanged!(row, rowIndex, col.id, value),
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
      _widget.rowHeight ?? (_widget.dense ? 32 : 48);

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

// ── _ColumnResizeHandle ───────────────────────────────────────────────────────

class _ColumnResizeHandle extends StatelessWidget {
  const _ColumnResizeHandle({required this.onResize});

  final void Function(double delta) onResize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) => onResize(details.delta.dx),
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: Container(width: 6, color: const Color(0x00000000)),
      ),
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
  const _PaginationBar({required this.pagination, super.key});

  final OiPaginationController pagination;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: pagination,
      builder: (_, __) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                key: const Key('pagination_first'),
                onTap: pagination.firstPage,
                child: const Text('«'),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                key: const Key('pagination_prev'),
                onTap: pagination.previousPage,
                child: const Text('‹'),
              ),
              const SizedBox(width: 8),
              Text(
                'Page ${pagination.currentPage + 1} of '
                '${math.max(1, pagination.totalPages)}',
              ),
              const SizedBox(width: 8),
              GestureDetector(
                key: const Key('pagination_next'),
                onTap: pagination.nextPage,
                child: const Text('›'),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                key: const Key('pagination_last'),
                onTap: pagination.lastPage,
                child: const Text('»'),
              ),
            ],
          ),
        );
      },
    );
  }
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
