part of '../oi_table.dart';

// ── Data pipeline ────────────────────────────────────────────────────────────

extension _OiTableData<T> on _OiTableState<T> {
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

  /// Returns the resolved width for [col], or `null` when the column should
  /// flex to fill remaining space.
  double? _resolvedColumnWidth(OiTableColumn<T> col) =>
      _ctrl.columnWidths[col.id] ?? col.width;

  /// Whether [col] is a flex column (no explicit or user-set width).
  bool _isFlexColumn(OiTableColumn<T> col) =>
      !_needsHorizontalScroll && _resolvedColumnWidth(col) == null;

  double _computeTotalColumnsWidth() {
    var total = 0.0;
    if (widget.selectable) total += 40; // checkbox column
    for (final col in _visibleColumns) {
      final w = _ctrl.columnWidths[col.id] ?? col.width;
      total += w ?? col.minWidth.clamp(col.minWidth, col.maxWidth);
    }
    return total;
  }

  /// Applies client-side filter to rows.
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

  /// Returns rows after filter → sort → paginate pipeline.
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
}
