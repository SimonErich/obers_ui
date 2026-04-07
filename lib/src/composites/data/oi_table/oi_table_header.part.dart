part of '../oi_table.dart';

// ── Header row rendering ─────────────────────────────────────────────────────

extension _OiTableHeader<T> on _OiTableState<T> {
  /// Arrow-up icon for ascending sort indicator.
  static const IconData _arrowUp = OiIcons.arrowUp;

  /// Arrow-down icon for descending sort indicator.
  static const IconData _arrowDown = OiIcons.arrowDown;

  Widget _buildHeaderRow() {
    final cols = _visibleColumns;
    return ColoredBox(
      key: const Key('oi_table_header'),
      color: context.colors.surfaceSubtle,
      child: Row(
        children: [
          if (widget.selectable) _buildSelectAllCheckbox(),
          for (var i = 0; i < cols.length; i++)
            if (_isFlexColumn(cols[i]))
              Expanded(
                child: _buildDraggableColumnHeader(cols[i], i, cols.length),
              )
            else
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
          _ctrl.reorderColumns(oldIdx, newIdx > oldIdx ? newIdx + 1 : newIdx);
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
              color: context.colors.surfaceActive,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  col.header,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(color: context.colors.text),
                ),
              ),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: header),
          child: isOver
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: context.colors.primary.base,
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

  /// Ensures `_ctrl.columnOrder` is populated with visible column IDs.
  void _ensureColumnOrder() {
    if (_ctrl.columnOrder.isEmpty) {
      _ctrl.columnOrder.addAll(_visibleColumns.map((c) => c.id));
    }
  }

  Widget _buildSelectAllCheckbox() {
    if (!widget.multiSelect) {
      return const SizedBox(width: 40);
    }
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
        height: _headerRowHeight,
        child: Center(
          child: Icon(
            _ctrl.selectAll ? OiIcons.squareCheckBig : OiIcons.square,
            size: 16,
            color: _ctrl.selectAll
                ? context.colors.primary.base
                : context.colors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildColumnHeader(OiTableColumn<T> col) {
    final isSorted = _ctrl.sortColumnId == col.id;
    final width = _ctrl.columnWidths[col.id] ?? col.width;
    final colors = context.colors;

    // Estimate minimum width needed for the header label to avoid cut-off.
    // ~7px per character at fontSize 12 + 16px horizontal padding + sort icon.
    final labelMinWidth = col.header.length * 7.0 + 16 + (isSorted ? 18 : 0);
    final effectiveMinWidth = math.max(col.minWidth, labelMinWidth);

    final innerContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: _HoverText(
              text: col.header,
              textAlign: col.textAlign,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textSubtle,
              ),
              hoverStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.text,
              ),
              sortable: col.sortable,
            ),
          ),
          if (isSorted)
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Icon(
                _ctrl.sortAscending ? _arrowUp : _arrowDown,
                size: 14,
                color: colors.primary.base,
              ),
            ),
        ],
      ),
    );
    final isFlex = _isFlexColumn(col);
    final resolvedWidth = isFlex
        ? null
        : width ?? effectiveMinWidth.clamp(effectiveMinWidth, col.maxWidth);
    final headerContent = GestureDetector(
      onTap: () => _handleHeaderTap(col),
      child: Container(
        height: _headerRowHeight,
        alignment: AlignmentDirectional.centerStart,
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
    } else if (resolvedWidth != null) {
      header = SizedBox(width: resolvedWidth, child: headerContent);
    } else {
      header = headerContent;
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
    final isFlex = _isFlexColumn(col);
    final filterWidth = _ctrl.columnWidths[col.id] ?? col.width;
    final resolvedFilterWidth = isFlex
        ? null
        : (filterWidth ?? col.minWidth.clamp(col.minWidth, col.maxWidth));
    return SizedBox(
      width: resolvedFilterWidth,
      height: 0,
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
}

// ── _HoverText ───────────────────────────────────────────────────────────────

/// A text widget that changes style on hover (used for sortable column headers).
class _HoverText extends StatefulWidget {
  const _HoverText({
    required this.text,
    required this.style,
    required this.hoverStyle,
    this.textAlign = TextAlign.start,
    this.sortable = true,
  });

  final String text;
  final TextStyle style;
  final TextStyle hoverStyle;
  final TextAlign textAlign;
  final bool sortable;

  @override
  State<_HoverText> createState() => _HoverTextState();
}

class _HoverTextState extends State<_HoverText> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = widget.sortable && _hovering
        ? widget.hoverStyle
        : widget.style;

    final child = Text(
      widget.text,
      textAlign: widget.textAlign,
      style: effectiveStyle,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );

    if (!widget.sortable) return child;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: child,
    );
  }
}

// ── _FilterField ─────────────────────────────────────────────────────────────

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
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return EditableText(
      controller: _ctrl,
      focusNode: _focusNode,
      style: const TextStyle(fontSize: 12),
      cursorColor: colors.primary.base,
      backgroundCursorColor: colors.borderSubtle,
      onChanged: widget.onChanged,
    );
  }
}
