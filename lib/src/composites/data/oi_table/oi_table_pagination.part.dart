part of '../oi_table.dart';

// ── _PaginationBar ───────────────────────────────────────────────────────────

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
      builder: (_, _) {
        return OiPagination(
          totalItems: pagination.totalItems,
          currentPage: pagination.currentPage,
          label: 'rows',
          perPage: pagination.pageSize,
          perPageOptions: pageSizeOptions,
          onPageChange: pagination.goToPage,
          onPerPageChange: (size) {
            pagination.setPageSize(size);
            onPageSizeChanged?.call(size);
          },
        );
      },
    );
  }
}
