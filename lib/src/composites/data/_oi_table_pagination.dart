part of 'oi_table.dart';

// ── _PaginationBar ────────────────────────────────────────────────────────────

/// Thin adapter that maps [OiPaginationController] state to [OiPagination]
/// props, keeping OiTable's public API unchanged.
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: pagination,
      builder: (_, __) {
        return OiPagination(
          totalItems: pagination.totalItems,
          currentPage: pagination.currentPage,
          label: 'rows',
          perPage: pagination.pageSize,
          perPageOptions: pageSizeOptions,
          onPageChange: (page) => pagination.goToPage(page),
          onPerPageChange: (size) {
            pagination.setPageSize(size);
            onPageSizeChanged?.call(size);
          },
        );
      },
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
    final colors = context.colors;

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
                    color: colors.surface,
                    border: Border.all(color: colors.borderSubtle),
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
                                ? colors.primary.muted.withValues(alpha: 0.15)
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
    final colors = context.colors;
    return GestureDetector(
      key: const Key('pagination_page_size'),
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: colors.borderSubtle),
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
  final void Function(String columnId, {required bool visible}) onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      key: const Key('oi_table_column_manager'),
      constraints: const BoxConstraints(maxWidth: 240),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.borderSubtle),
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
                onToggle(col.id, visible: !currentlyVisible);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
