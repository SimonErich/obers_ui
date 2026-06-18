part of '../oi_table.dart';

// ── Body rendering ───────────────────────────────────────────────────────────

extension _OiTableBody<T> on _OiTableState<T> {
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
      itemBuilder: (ctx, i) {
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
      final animCtrl = _groupControllerFor(groupKey);
      // Group header.
      final header = widget.groupHeaderBuilder != null
          ? widget.groupHeaderBuilder!(context, groupKey, groupRows)
          : _buildDefaultGroupHeader(groupKey, groupRows.length, expanded);
      items
        ..add(
          GestureDetector(
            key: ValueKey('group_$groupKey'),
            onTap: () {
              final willExpand = !_ctrl.expandedGroups.contains(groupKey);
              if (willExpand) {
                unawaited(animCtrl.forward());
              } else {
                unawaited(animCtrl.reverse());
              }
              _ctrl.toggleGroup(groupKey);
            },
            child: header,
          ),
        )
        // Animated group rows.
        ..add(
          AnimatedBuilder(
            key: ValueKey('group_body_$groupKey'),
            animation: animCtrl,
            builder: (context, child) {
              if (animCtrl.isDismissed) return const SizedBox.shrink();
              return SizeTransition(
                sizeFactor: CurvedAnimation(
                  parent: animCtrl,
                  curve: Curves.easeInOut,
                ),
                axisAlignment: -1,
                child: child,
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < groupRows.length; i++)
                  _buildRow(groupRows[i], i),
              ],
            ),
          ),
        );
    }
    return ListView(controller: _scrollController, children: items);
  }

  Widget _buildDefaultGroupHeader(String groupKey, int count, bool expanded) {
    final colors = context.colors;
    return Padding(
      key: ValueKey('group_header_$groupKey'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          AnimatedRotation(
            turns: expanded ? 0.25 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Icon(
              OiIcons.chevronRight,
              size: 16,
              color: colors.textSubtle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$groupKey ($count)',
            style: TextStyle(fontWeight: FontWeight.w600, color: colors.text),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(T row, int index, {Key? key}) {
    final isSelected = _ctrl.selectedRows.contains(_rowKeyAt(row, index));
    final isHovered = _hoveredRowIndex == index;
    final isEven = index.isEven;
    Color? bg;
    if (isSelected) {
      bg = context.colors.primary.muted.withValues(alpha: 0.3);
    } else if (isHovered) {
      bg = context.colors.surfaceHover;
    } else if (widget.striped && isEven) {
      bg = context.colors.surfaceSubtle;
    }
    final rowContent = Row(
      children: [
        if (widget.selectable)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final key = _rowKeyAt(row, index);
              _ctrl.toggleRow(key);
              _lastSelectedIndex = index;
              widget.onSelectionChanged?.call(
                Set<String>.from(_ctrl.selectedRows),
              );
            },
            child: SizedBox(
              width: 40,
              height: _effectiveRowHeight,
              child: Center(
                child: Icon(
                  isSelected ? OiIcons.squareCheckBig : OiIcons.square,
                  size: 16,
                  color: isSelected
                      ? context.colors.primary.base
                      : context.colors.textMuted,
                ),
              ),
            ),
          ),
        for (final col in _visibleColumns)
          if (_isFlexColumn(col))
            Expanded(child: _buildCell(row, index, col))
          else
            _buildCell(row, index, col),
      ],
    );
    return MouseRegion(
      onEnter: (_) => _setHoveredRow(index),
      onExit: (_) => _setHoveredRow(null),
      cursor: (widget.onRowTap != null || widget.selectable)
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        key: key ?? ValueKey('row_$index'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _handleRowTap(row, index),
        onDoubleTap: () => _handleRowDoubleTap(row, index),
        child: ColoredBox(
          color: bg ?? const Color(0x00000000),
          child: rowContent,
        ),
      ),
    );
  }

  Widget _buildCell(T row, int rowIndex, OiTableColumn<T> col) {
    final width = _ctrl.columnWidths[col.id] ?? col.width;
    Widget content;
    if (col.cellBuilder != null) {
      content = col.cellBuilder!(context, row, rowIndex);
    } else {
      final text = col.valueGetter?.call(row) ?? '';
      content = Text(
        text,
        textAlign: col.textAlign,
        style: TextStyle(color: context.colors.text),
      );
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
    final isFlex = _isFlexColumn(col);
    final resolvedWidth = isFlex
        ? null
        : (width ?? col.minWidth.clamp(col.minWidth, col.maxWidth));
    return SizedBox(
      width: resolvedWidth,
      height: _effectiveRowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Align(
          alignment: _OiTableStatus._alignmentFromTextAlign(col.textAlign),
          child: content,
        ),
      ),
    );
  }
}

// ── _CellFrame ───────────────────────────────────────────────────────────────

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
  final FocusNode _editFocusNode = FocusNode();

  @override
  void dispose() {
    _textCtrl.dispose();
    _editFocusNode.dispose();
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
    final colors = context.colors;
    if (_editing) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: EditableText(
              controller: _textCtrl,
              focusNode: _editFocusNode..requestFocus(),
              style: const TextStyle(fontSize: 14),
              cursorColor: colors.primary.base,
              backgroundCursorColor: colors.borderSubtle,
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
