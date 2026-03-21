import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

/// Visual variant for [OiPagination].
///
/// {@category Components}
enum OiPaginationVariant {
  /// Shows numbered page buttons with ellipsis for large ranges.
  pages,

  /// Shows a compact `X / Y` indicator with prev/next arrows.
  compact,
}

/// A standalone pagination control for navigating paged data.
///
/// Renders page numbers, prev/next arrows, an items-per-page selector,
/// and a total count. Supports [pages] and [compact] variants, plus a
/// [loadMore] factory for infinite-scroll patterns.
///
/// Composes [OiButton.ghost], [OiSelect], [OiLabel], and [OiIcon].
///
/// {@category Components}
///
/// Coverage: REQ-0003
class OiPagination extends StatefulWidget {
  /// Creates an [OiPagination] with the [pages] variant by default.
  ///
  /// [currentPage] is zero-based. [totalItems] is the total data count.
  const OiPagination({
    required this.totalItems,
    required this.currentPage,
    this.label,
    this.perPage = 25,
    this.perPageOptions = const [10, 25, 50, 100],
    this.onPageChange,
    this.onPerPageChange,
    this.showPerPage = true,
    this.showTotal = true,
    this.showFirstLast = true,
    this.siblingCount = 1,
    this.variant = OiPaginationVariant.pages,
    super.key,
  }) : _isLoadMore = false,
       _loadedCount = 0,
       _onLoadMore = null,
       _loading = false;

  /// Creates a compact pagination showing `X / Y` with arrows only.
  const OiPagination.compact({
    required this.totalItems,
    required this.currentPage,
    this.label,
    this.perPage = 25,
    this.onPageChange,
    this.showFirstLast = true,
    super.key,
  }) : variant = OiPaginationVariant.compact,
       perPageOptions = const [10, 25, 50, 100],
       onPerPageChange = null,
       showPerPage = false,
       showTotal = true,
       siblingCount = 1,
       _isLoadMore = false,
       _loadedCount = 0,
       _onLoadMore = null,
       _loading = false;

  /// Creates a load-more button for infinite-scroll patterns.
  ///
  /// Shows a "Load more" button with [loadedCount] / [totalItems] progress.
  /// When [loading] is true, displays a loading indicator instead.
  /// Hides entirely when [loadedCount] >= [totalItems].
  const OiPagination.loadMore({
    required int loadedCount,
    required this.totalItems,
    VoidCallback? onLoadMore,
    bool loading = false,
    super.key,
  }) : _isLoadMore = true,
       _loadedCount = loadedCount,
       _onLoadMore = onLoadMore,
       _loading = loading,
       currentPage = 0,
       label = null,
       perPage = 25,
       perPageOptions = const [10, 25, 50, 100],
       onPageChange = null,
       onPerPageChange = null,
       showPerPage = false,
       showTotal = true,
       showFirstLast = false,
       siblingCount = 1,
       variant = OiPaginationVariant.pages;

  /// Total number of data items across all pages.
  final int totalItems;

  /// Zero-based index of the current page.
  final int currentPage;

  /// Optional descriptive label (e.g. 'Rows', 'Items').
  final String? label;

  /// Number of items shown per page.
  final int perPage;

  /// Available page-size options for the per-page selector.
  final List<int> perPageOptions;

  /// Called when the user navigates to a different page (zero-based).
  final ValueChanged<int>? onPageChange;

  /// Called when the user selects a different per-page option.
  final ValueChanged<int>? onPerPageChange;

  /// Whether to show the per-page size selector.
  final bool showPerPage;

  /// Whether to show the total item count.
  final bool showTotal;

  /// Whether to show first/last page navigation buttons.
  final bool showFirstLast;

  /// Number of sibling pages shown around the current page.
  final int siblingCount;

  /// The visual variant.
  final OiPaginationVariant variant;

  final bool _isLoadMore;
  final int _loadedCount;
  final VoidCallback? _onLoadMore;
  final bool _loading;

  // ── Page computation ───────────────────────────────────────────────────────

  /// Computes which page numbers to display, using `null` for ellipsis gaps.
  ///
  /// Pages are zero-based. [siblingCount] determines how many pages are shown
  /// on each side of [currentPage]. When all pages fit, every page is shown.
  static List<int?> computeVisiblePages(
    int currentPage,
    int totalPages,
    int siblingCount,
  ) {
    final effectiveSiblings = math.max(0, siblingCount);
    // Always show first, last, current, and siblings.
    // Max visible = 1 (first) + 1 (last) + 1 (current) + 2*siblings + 2 (possible ellipsis boundaries)
    final maxVisible = 5 + 2 * effectiveSiblings;
    if (totalPages <= maxVisible) {
      return List<int>.generate(totalPages, (i) => i);
    }

    final pages = <int>{0, totalPages - 1};
    for (
      var i = currentPage - effectiveSiblings;
      i <= currentPage + effectiveSiblings;
      i++
    ) {
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
  State<OiPagination> createState() => _OiPaginationState();
}

class _OiPaginationState extends State<OiPagination> {
  final FocusNode _focusNode = FocusNode();

  // ── Computed ──────────────────────────────────────────────────────────────

  int get _totalPages =>
      widget.totalItems == 0 ? 0 : (widget.totalItems / widget.perPage).ceil();

  int get _effectivePerPage {
    final options = _effectivePerPageOptions;
    if (options.contains(widget.perPage)) return widget.perPage;
    return options.first;
  }

  List<int> get _effectivePerPageOptions =>
      widget.perPageOptions.isEmpty ? const [25] : widget.perPageOptions;

  int get _clampedPage {
    if (_totalPages == 0) return 0;
    return widget.currentPage.clamp(0, _totalPages - 1);
  }

  bool get _hasPrev => _clampedPage > 0;
  bool get _hasNext => _totalPages > 0 && _clampedPage < _totalPages - 1;

  // ── Keyboard ──────────────────────────────────────────────────────────────

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft && _hasPrev) {
      widget.onPageChange?.call(_clampedPage - 1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight && _hasNext) {
      widget.onPageChange?.call(_clampedPage + 1);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget._isLoadMore) return _buildLoadMore(context);

    switch (widget.variant) {
      case OiPaginationVariant.pages:
        return _buildPagesVariant(context);
      case OiPaginationVariant.compact:
        return _buildCompactVariant(context);
    }
  }

  Widget _buildPagesVariant(BuildContext context) {
    final colors = context.colors;
    final visiblePages = OiPagination.computeVisiblePages(
      _clampedPage,
      _totalPages,
      widget.siblingCount,
    );

    return Semantics(
      label: 'Pagination navigation',
      container: true,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              if (widget.showTotal) Flexible(child: _buildTotalLabel()),
              if (widget.showTotal) const SizedBox(width: 12),
              if (widget.showPerPage) ...[
                _buildPerPageSelector(context),
                const SizedBox(width: 16),
              ],
              if (widget.showFirstLast)
                _buildNavButton(
                  key: const Key('oi_pagination_first'),
                  icon: const IconData(0xe5dc, fontFamily: 'MaterialIcons'),
                  label: 'First page',
                  enabled: _hasPrev,
                  onTap: () => widget.onPageChange?.call(0),
                  colors: colors,
                ),
              _buildNavButton(
                key: const Key('oi_pagination_prev'),
                icon: const IconData(0xe5cb, fontFamily: 'MaterialIcons'),
                label: 'Previous page',
                enabled: _hasPrev,
                onTap: () => widget.onPageChange?.call(_clampedPage - 1),
                colors: colors,
              ),
              for (var i = 0; i < visiblePages.length; i++)
                if (visiblePages[i] == null)
                  Padding(
                    key: Key('oi_pagination_ellipsis_$i'),
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: const OiLabel.small('\u2026'),
                  )
                else
                  _buildPageButton(visiblePages[i]!, colors),
              _buildNavButton(
                key: const Key('oi_pagination_next'),
                icon: const IconData(0xe5cc, fontFamily: 'MaterialIcons'),
                label: 'Next page',
                enabled: _hasNext,
                onTap: () => widget.onPageChange?.call(_clampedPage + 1),
                colors: colors,
              ),
              if (widget.showFirstLast)
                _buildNavButton(
                  key: const Key('oi_pagination_last'),
                  icon: const IconData(0xe5dd, fontFamily: 'MaterialIcons'),
                  label: 'Last page',
                  enabled: _hasNext,
                  onTap: () => widget.onPageChange?.call(_totalPages - 1),
                  colors: colors,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactVariant(BuildContext context) {
    final colors = context.colors;
    final displayPage = _totalPages == 0 ? 0 : _clampedPage + 1;

    return Semantics(
      label: 'Pagination navigation',
      container: true,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showFirstLast)
                _buildNavButton(
                  key: const Key('oi_pagination_first'),
                  icon: const IconData(0xe5dc, fontFamily: 'MaterialIcons'),
                  label: 'First page',
                  enabled: _hasPrev,
                  onTap: () => widget.onPageChange?.call(0),
                  colors: colors,
                ),
              _buildNavButton(
                key: const Key('oi_pagination_prev'),
                icon: const IconData(0xe5cb, fontFamily: 'MaterialIcons'),
                label: 'Previous page',
                enabled: _hasPrev,
                onTap: () => widget.onPageChange?.call(_clampedPage - 1),
                colors: colors,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: OiLabel.body(
                  '$displayPage / $_totalPages',
                  key: const Key('oi_pagination_compact_label'),
                ),
              ),
              _buildNavButton(
                key: const Key('oi_pagination_next'),
                icon: const IconData(0xe5cc, fontFamily: 'MaterialIcons'),
                label: 'Next page',
                enabled: _hasNext,
                onTap: () => widget.onPageChange?.call(_clampedPage + 1),
                colors: colors,
              ),
              if (widget.showFirstLast)
                _buildNavButton(
                  key: const Key('oi_pagination_last'),
                  icon: const IconData(0xe5dd, fontFamily: 'MaterialIcons'),
                  label: 'Last page',
                  enabled: _hasNext,
                  onTap: () => widget.onPageChange?.call(_totalPages - 1),
                  colors: colors,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMore(BuildContext context) {
    if (widget._loadedCount >= widget.totalItems) {
      return const SizedBox.shrink();
    }

    return Semantics(
      label: 'Pagination navigation',
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OiLabel.small(
              '${widget._loadedCount} of ${widget.totalItems} loaded',
            ),
            const SizedBox(height: 8),
            OiButton.ghost(
              key: const Key('oi_pagination_load_more'),
              label: 'Load more',
              loading: widget._loading,
              onTap: widget._loading ? null : widget._onLoadMore,
            ),
          ],
        ),
      ),
    );
  }

  // ── Sub-builders ─────────────────────────────────────────────────────────

  Widget _buildNavButton({
    required Key key,
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    required OiColorScheme colors,
  }) {
    return OiButton.ghost(
      key: key,
      label: label,
      icon: icon,
      size: OiButtonSize.small,
      enabled: enabled,
      onTap: enabled ? onTap : null,
    );
  }

  Widget _buildPageButton(int page, OiColorScheme colors) {
    final isCurrent = page == _clampedPage;
    return Semantics(
      button: true,
      label: 'Page ${page + 1}',
      selected: isCurrent,
      child: Focus(
        child: GestureDetector(
          key: Key('oi_pagination_page_$page'),
          onTap: isCurrent ? null : () => widget.onPageChange?.call(page),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: isCurrent
                ? BoxDecoration(
                    color: colors.primary.base,
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: isCurrent
                ? OiLabel.bodyStrong(
                    '${page + 1}',
                    color: colors.primary.foreground,
                  )
                : OiLabel.body('${page + 1}', color: colors.text),
          ),
        ),
      ),
    );
  }

  Widget _buildPerPageSelector(BuildContext context) {
    final options = _effectivePerPageOptions;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const OiLabel.small('Per page:'),
        const SizedBox(width: 4),
        SizedBox(
          width: 80,
          child: OiSelect<int>(
            key: const Key('oi_pagination_per_page'),
            options: [
              for (final opt in options)
                OiSelectOption<int>(value: opt, label: '$opt'),
            ],
            value: _effectivePerPage,
            onChanged: (val) {
              if (val != null) widget.onPerPageChange?.call(val);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTotalLabel() {
    final itemLabel = widget.label ?? 'items';
    if (widget.totalItems == 0) {
      return OiLabel.small(
        '0 $itemLabel',
        key: const Key('oi_pagination_total'),
        overflow: TextOverflow.ellipsis,
      );
    }

    final start = _clampedPage * _effectivePerPage + 1;
    final end = math.min(
      (_clampedPage + 1) * _effectivePerPage,
      widget.totalItems,
    );
    return OiLabel.small(
      '$start\u2013$end of ${widget.totalItems} $itemLabel',
      key: const Key('oi_pagination_total'),
      overflow: TextOverflow.ellipsis,
    );
  }
}
