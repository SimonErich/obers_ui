part of '../oi_table.dart';

// ── Status, bulk bar, pagination footer, and layout helpers ──────────────────

extension _OiTableStatus<T> on _OiTableState<T> {
  // ── Bulk bar ──────────────────────────────────────────────────────────────

  Widget _buildBulkBar() {
    final selectedCount = _ctrl.selectedRows.length;
    final totalCount = widget.rows.length;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Center(
        child: OiBulkBar(
          selectedCount: selectedCount,
          totalCount: totalCount,
          label: 'rows',
          actions: widget.bulkActions!,
          allSelected: _ctrl.selectAll,
          onSelectAll: () {
            final allKeys = <String>{};
            for (var i = 0; i < widget.rows.length; i++) {
              allKeys.add(_rowKeyAt(widget.rows[i], i));
            }
            _ctrl.selectAllRows(allKeys);
            widget.onSelectionChanged?.call(
              Set<String>.from(_ctrl.selectedRows),
            );
          },
          onDeselectAll: () {
            _ctrl.clearSelection();
            widget.onSelectionChanged?.call(
              Set<String>.from(_ctrl.selectedRows),
            );
          },
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
      color: context.colors.surfaceSubtle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Text(
              '$totalShown rows',
              style: TextStyle(color: context.colors.textMuted),
            ),
            if (selected > 0) ...[
              const SizedBox(width: 16),
              Text(
                '$selected selected',
                style: TextStyle(color: context.colors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  double get _effectiveRowHeight =>
      widget.rowHeight ?? (widget.dense ? 32 : 48);

  double get _headerRowHeight => widget.dense ? 28 : 36;

  static AlignmentGeometry _alignmentFromTextAlign(TextAlign align) {
    return switch (align) {
      TextAlign.center => Alignment.center,
      TextAlign.end || TextAlign.right => AlignmentDirectional.centerEnd,
      _ => AlignmentDirectional.centerStart,
    };
  }
}
