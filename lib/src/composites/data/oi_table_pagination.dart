part of 'oi_table.dart';

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
