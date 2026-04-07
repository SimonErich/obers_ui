part of '../oi_table.dart';

// ── Interaction handlers ─────────────────────────────────────────────────────

extension _OiTableInteractions<T> on _OiTableState<T> {
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

  void _handleRowTap(T row, int index) {
    if (widget.selectable) {
      final isShift = HardwareKeyboard.instance.isShiftPressed;
      final isCtrlOrMeta =
          HardwareKeyboard.instance.isControlPressed ||
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
    unawaited(Clipboard.setData(ClipboardData(text: buffer.toString())));
  }

  void _onScroll() {
    if (!mounted) return;
    if (widget.paginationMode != OiTablePaginationMode.infinite) return;
    if (_loadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      unawaited(_triggerLoadMore());
    }
  }

  Future<void> _triggerLoadMore() async {
    if (_loadingMore || widget.onLoadMore == null) return;
    _setLoadingMore(loading: true);
    try {
      await widget.onLoadMore!();
    } finally {
      if (mounted) _setLoadingMore(loading: false);
    }
  }
}
