import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/composites/data/oi_pagination_controller.dart';
import 'package:obers_ui/src/models/settings/oi_table_settings.dart';

/// Controls the interactive state of an [OiTable].
///
/// Manages sort, selection, filtering, column visibility/widths/order,
/// grouping, and delegates pagination to an [OiPaginationController].
/// Notifies listeners on every state mutation.
///
/// Create one externally and pass it to [OiTable] to retain state across
/// rebuilds, or let [OiTable] manage its own internal instance.
///
/// {@category Composites}
class OiTableController extends ChangeNotifier {
  /// Creates an [OiTableController].
  OiTableController({int pageSize = 25, int totalRows = 0})
    : pagination = OiPaginationController(
        pageSize: pageSize,
        totalItems: totalRows,
      ) {
    pagination.addListener(notifyListeners);
  }

  // ── Sort ──────────────────────────────────────────────────────────────────

  /// The column ID currently used for sorting, or `null` when unsorted.
  String? sortColumnId;

  /// Whether the active sort is ascending. Ignored when [sortColumnId] is null.
  bool sortAscending = true;

  // ── Selection ─────────────────────────────────────────────────────────────

  /// The set of currently selected row indices.
  final Set<int> selectedRows = {};

  /// Whether all rows are selected (driven externally, not computed).
  bool selectAll = false;

  // ── Filters ───────────────────────────────────────────────────────────────

  /// Active filter values keyed by column ID.
  final Map<String, String> activeFilters = {};

  // ── Column state ──────────────────────────────────────────────────────────

  /// Visibility flag per column ID. Absent means visible.
  final Map<String, bool> columnVisibility = {};

  /// Width in logical pixels per column ID.
  final Map<String, double> columnWidths = {};

  /// Column IDs in display order.
  List<String> columnOrder = [];

  // ── Grouping ──────────────────────────────────────────────────────────────

  /// Column ID to group rows by, or `null` when grouping is disabled.
  String? groupByColumnId;

  /// The set of currently expanded group keys.
  final Set<String> expandedGroups = {};

  // ── Pagination ────────────────────────────────────────────────────────────

  /// The pagination controller used by this table.
  final OiPaginationController pagination;

  // ── Sort API ──────────────────────────────────────────────────────────────

  /// Sorts by [columnId].
  ///
  /// If [ascending] is omitted and the column is already the active sort
  /// column, the direction is toggled. Otherwise [ascending] defaults to
  /// `true`.
  void sortBy(String columnId, {bool? ascending}) {
    if (ascending == null) {
      if (sortColumnId == columnId) {
        sortAscending = !sortAscending;
      } else {
        sortColumnId = columnId;
        sortAscending = true;
      }
    } else {
      sortColumnId = columnId;
      sortAscending = ascending;
    }
    notifyListeners();
  }

  /// Removes any active sort.
  void clearSort() {
    if (sortColumnId == null) return;
    sortColumnId = null;
    sortAscending = true;
    notifyListeners();
  }

  // ── Selection API ─────────────────────────────────────────────────────────

  /// Selects the row at [index].
  ///
  /// When [multi] is `false` (the default), any previous selection is cleared
  /// first. When [multi] is `true`, the row is added to the existing selection.
  void selectRow(int index, {bool multi = false}) {
    if (!multi) selectedRows.clear();
    selectedRows.add(index);
    selectAll = false;
    notifyListeners();
  }

  /// Removes [index] from the current selection.
  void deselectRow(int index) {
    if (!selectedRows.remove(index)) return;
    selectAll = false;
    notifyListeners();
  }

  /// Selects all rows up to [totalCount].
  void selectAllRows(int totalCount) {
    selectedRows
      ..clear()
      ..addAll(Iterable<int>.generate(totalCount));
    selectAll = true;
    notifyListeners();
  }

  /// Clears the entire selection.
  void clearSelection() {
    if (selectedRows.isEmpty && !selectAll) return;
    selectedRows.clear();
    selectAll = false;
    notifyListeners();
  }

  // ── Filter API ────────────────────────────────────────────────────────────

  /// Sets the filter value for [columnId] and resets to page 0.
  void setFilter(String columnId, String value) {
    activeFilters[columnId] = value;
    pagination.goToPage(0);
    notifyListeners();
  }

  /// Removes the filter for [columnId].
  void clearFilter(String columnId) {
    if (!activeFilters.containsKey(columnId)) return;
    activeFilters.remove(columnId);
    notifyListeners();
  }

  /// Removes all active filters.
  void clearAllFilters() {
    if (activeFilters.isEmpty) return;
    activeFilters.clear();
    notifyListeners();
  }

  // ── Column management API ─────────────────────────────────────────────────

  /// Shows or hides [columnId].
  void setColumnVisible(String columnId, {required bool visible}) {
    if (columnVisibility[columnId] == visible) return;
    columnVisibility[columnId] = visible;
    notifyListeners();
  }

  /// Sets the width of [columnId] to [width] logical pixels.
  void setColumnWidth(String columnId, double width) {
    if (columnWidths[columnId] == width) return;
    columnWidths[columnId] = width;
    notifyListeners();
  }

  /// Moves the column at [oldIndex] to [newIndex] within [columnOrder].
  ///
  /// Both indices must be valid positions within [columnOrder].
  void reorderColumns(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    if (oldIndex < 0 || oldIndex >= columnOrder.length) return;
    final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final id = columnOrder.removeAt(oldIndex);
    columnOrder.insert(adjusted, id);
    notifyListeners();
  }

  /// Resets column order, visibility, and widths to their initial empty state.
  void resetColumns() {
    columnOrder.clear();
    columnVisibility.clear();
    columnWidths.clear();
    notifyListeners();
  }

  // ── Grouping API ──────────────────────────────────────────────────────────

  /// Groups rows by [columnId], or clears grouping when `null`.
  void groupBy(String? columnId) {
    if (groupByColumnId == columnId) return;
    groupByColumnId = columnId;
    expandedGroups.clear();
    notifyListeners();
  }

  /// Toggles the expanded state of the group identified by [groupKey].
  void toggleGroup(String groupKey) {
    if (expandedGroups.contains(groupKey)) {
      expandedGroups.remove(groupKey);
    } else {
      expandedGroups.add(groupKey);
    }
    notifyListeners();
  }

  // ── Settings persistence ──────────────────────────────────────────────────

  /// Returns a snapshot of the current controller state as [OiTableSettings].
  OiTableSettings toSettings() {
    return OiTableSettings(
      columnOrder: List<String>.from(columnOrder),
      columnVisibility: Map<String, bool>.from(columnVisibility),
      columnWidths: Map<String, double>.from(columnWidths),
      sortColumnId: sortColumnId,
      sortAscending: sortAscending,
      activeFilters: Map<String, String>.from(activeFilters),
      pageSize: pagination.pageSize,
      pageIndex: pagination.currentPage,
      groupByColumnId: groupByColumnId,
    );
  }

  /// Applies [settings] to this controller, replacing all mutable state.
  void applySettings(OiTableSettings settings) {
    columnOrder
      ..clear()
      ..addAll(settings.columnOrder);
    columnVisibility
      ..clear()
      ..addAll(settings.columnVisibility);
    columnWidths
      ..clear()
      ..addAll(settings.columnWidths);
    sortColumnId = settings.sortColumnId;
    sortAscending = settings.sortAscending;
    activeFilters
      ..clear()
      ..addAll(settings.activeFilters);
    groupByColumnId = settings.groupByColumnId;
    pagination
      ..setPageSize(settings.pageSize)
      ..goToPage(settings.pageIndex);
    notifyListeners();
  }

  @override
  void dispose() {
    pagination
      ..removeListener(notifyListeners)
      ..dispose();
    super.dispose();
  }
}
