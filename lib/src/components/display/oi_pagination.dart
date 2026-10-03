import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';

import 'package:obers_ui/src/foundation/theme/component_themes/oi_text_input_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_scope.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ── Labels ────────────────────────────────────────────────────────────────────

/// User-visible strings for [OiPagination].
///
/// Every field defaults to the English text [OiPagination] has always shown,
/// so omitting this object changes nothing. Supply a localized instance to
/// translate the control — the app's own l10n system owns the translations,
/// this package only accepts finished strings.
///
/// ```dart
/// OiPagination(
///   totalItems: 42,
///   currentPage: 0,
///   label: 'Zeilen',
///   labels: OiPaginationLabels(
///     perPage: 'Pro Seite:',
///     navigation: 'Seitennavigation',
///     firstPage: 'Erste Seite',
///     previousPage: 'Vorherige Seite',
///     nextPage: 'Nächste Seite',
///     lastPage: 'Letzte Seite',
///     loadMore: 'Mehr laden',
///   ),
/// )
/// ```
///
/// {@category Components}
@immutable
class OiPaginationLabels {
  /// Creates an [OiPaginationLabels].
  const OiPaginationLabels({
    this.perPage = 'Per page:',
    this.navigation = 'Pagination navigation',
    this.firstPage = 'First page',
    this.previousPage = 'Previous page',
    this.nextPage = 'Next page',
    this.lastPage = 'Last page',
    this.loadMore = 'Load more',
    this.page,
    this.total,
    this.loadedProgress,
  });

  /// Prefix shown before the per-page size selector.
  final String perPage;

  /// Accessible label announced for the pagination container.
  final String navigation;

  /// Accessible label for the first-page button.
  final String firstPage;

  /// Accessible label for the previous-page button.
  final String previousPage;

  /// Accessible label for the next-page button.
  final String nextPage;

  /// Accessible label for the last-page button.
  final String lastPage;

  /// Label of the load-more button in [OiPagination.loadMore].
  final String loadMore;

  /// Builds the accessible label for a single page button. Receives the
  /// one-based page number. Defaults to `'Page 1'`.
  final String Function(int pageNumber)? page;

  /// Builds the total-count label. Receives the one-based first and last item
  /// index on the current page, the total item count, and the item noun
  /// ([OiPagination.label]).
  ///
  /// Defaults to `'1–25 of 100 rows'`, or `'0 rows'` when there are no items —
  /// in which case the first and last index are both `0`.
  final String Function(
    int start,
    int end,
    int totalItems,
    String itemLabel,
  )?
  total;

  /// Builds the progress label above the load-more button. Receives the number
  /// of items loaded so far, the total, and the item noun
  /// ([OiPagination.label]).
  ///
  /// Defaults to `'25 of 100 rows loaded'`.
  final String Function(int loadedCount, int totalItems, String itemLabel)?
  loadedProgress;
}

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
/// and a total count. Supports [OiPaginationVariant.pages] and
/// [OiPaginationVariant.compact] variants, plus a
/// [OiPagination.loadMore] factory for infinite-scroll patterns.
///
/// Composes [OiButton.ghost], [OiSelect], [OiLabel], and [OiIcon].
///
/// {@category Components}
///
/// Coverage: REQ-0004, REQ-0005, REQ-0006
class OiPagination extends StatefulWidget {
  /// Creates an [OiPagination] with the [OiPaginationVariant.pages] variant by default.
  ///
  /// [currentPage] is zero-based. [totalItems] is the total data count.
  const OiPagination({
    required this.totalItems,
    required this.currentPage,
    required this.label,
    this.perPage = 25,
    this.perPageOptions = const [10, 25, 50, 100],
    this.onPageChange,
    this.onPerPageChange,
    this.showPerPage = true,
    this.showTotal = true,
    this.showFirstLast,
    this.siblingCount,
    this.distributed,
    this.variant = OiPaginationVariant.pages,
    this.labels = const OiPaginationLabels(),
    super.key,
  }) : _isLoadMore = false,
       _loadedCount = 0,
       _onLoadMore = null,
       _loading = false;

  /// Creates a compact pagination showing `X / Y` with arrows only.
  const OiPagination.compact({
    required this.totalItems,
    required this.currentPage,
    required this.label,
    this.perPage = 25,
    this.onPageChange,
    this.showFirstLast,
    this.labels = const OiPaginationLabels(),
    super.key,
  }) : variant = OiPaginationVariant.compact,
       perPageOptions = const [10, 25, 50, 100],
       onPerPageChange = null,
       showPerPage = false,
       showTotal = true,
       siblingCount = 1,
       distributed = false,
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
    required this.label,
    VoidCallback? onLoadMore,
    bool loading = false,
    this.labels = const OiPaginationLabels(),
    super.key,
  }) : _isLoadMore = true,
       _loadedCount = loadedCount,
       _onLoadMore = onLoadMore,
       _loading = loading,
       currentPage = 0,
       perPage = 25,
       perPageOptions = const [10, 25, 50, 100],
       onPageChange = null,
       onPerPageChange = null,
       showPerPage = false,
       showTotal = true,
       showFirstLast = false,
       siblingCount = 1,
       distributed = false,
       variant = OiPaginationVariant.pages;

  /// Total number of data items across all pages.
  final int totalItems;

  /// Zero-based index of the current page.
  final int currentPage;

  /// Descriptive label for the items (e.g. 'rows', 'items', 'products').
  final String label;

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
  final bool? showFirstLast;

  /// Number of sibling pages shown around the current page.
  final int? siblingCount;

  /// Places the range left, page buttons centrally and page size right on wide
  /// layouts. Null follows the pagination theme; narrow layouts always wrap.
  final bool? distributed;

  /// The visual variant.
  final OiPaginationVariant variant;

  /// User-visible strings. Defaults to English.
  final OiPaginationLabels labels;

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

  bool get _showFirstLast =>
      widget.showFirstLast ??
      context.components.pagination?.showFirstLast ??
      true;

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
      widget.siblingCount ?? context.components.pagination?.siblingCount ?? 1,
    );

    return Semantics(
      label: widget.labels.navigation,
      container: true,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: Padding(
          padding:
              context.components.pagination?.padding ??
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 600;

              final pageNav = Wrap(
                alignment: narrow ? WrapAlignment.center : WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 4,
                children: [
                  if (_showFirstLast)
                    _buildNavButton(
                      key: const Key('oi_pagination_first'),
                      icon: OiIcons.chevronsLeft,
                      label: widget.labels.firstPage,
                      enabled: _hasPrev,
                      onTap: () => widget.onPageChange?.call(0),
                      colors: colors,
                    ),
                  _buildNavButton(
                    key: const Key('oi_pagination_prev'),
                    icon: OiIcons.chevronLeft,
                    label: widget.labels.previousPage,
                    enabled: _hasPrev,
                    onTap: () => widget.onPageChange?.call(_clampedPage - 1),
                    colors: colors,
                  ),
                  for (var i = 0; i < visiblePages.length; i++)
                    if (visiblePages[i] == null)
                      Padding(
                        key: Key('oi_pagination_ellipsis_$i'),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: const OiLabel.small('\u2026'),
                      )
                    else
                      _buildPageButton(visiblePages[i]!, colors),
                  _buildNavButton(
                    key: const Key('oi_pagination_next'),
                    icon: OiIcons.chevronRight,
                    label: widget.labels.nextPage,
                    enabled: _hasNext,
                    onTap: () => widget.onPageChange?.call(_clampedPage + 1),
                    colors: colors,
                  ),
                  if (_showFirstLast)
                    _buildNavButton(
                      key: const Key('oi_pagination_last'),
                      icon: OiIcons.chevronsRight,
                      label: widget.labels.lastPage,
                      enabled: _hasNext,
                      onTap: () => widget.onPageChange?.call(_totalPages - 1),
                      colors: colors,
                    ),
                ],
              );

              if (narrow) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    pageNav,
                    if (widget.showTotal || widget.showPerPage) ...[
                      const SizedBox(height: 8),
                      if (widget.showPerPage)
                        Center(child: _buildPerPageSelector(context)),
                      if (widget.showTotal && widget.showPerPage)
                        const SizedBox(height: 8),
                      if (widget.showTotal) _buildTotalLabel(),
                    ],
                  ],
                );
              }

              if (widget.distributed ??
                  context.components.pagination?.distributed ??
                  false) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: widget.showTotal
                          ? _buildTotalLabel()
                          : const SizedBox.shrink(),
                    ),
                    pageNav,
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        widthFactor: 1,
                        heightFactor: 1,
                        child: widget.showPerPage
                            ? _buildPerPageSelector(context)
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                );
              }

              // 3-column layout: left (per page + total), center (page nav),
              // right (empty, balances the row).
              return Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (widget.showPerPage) _buildPerPageSelector(context),
                        if (widget.showTotal) _buildTotalLabel(),
                      ],
                    ),
                  ),
                  pageNav,
                  const Expanded(child: SizedBox.shrink()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCompactVariant(BuildContext context) {
    final colors = context.colors;
    final displayPage = _totalPages == 0 ? 0 : _clampedPage + 1;

    return Semantics(
      label: widget.labels.navigation,
      container: true,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_showFirstLast)
                _buildNavButton(
                  key: const Key('oi_pagination_first'),
                  icon: OiIcons.chevronsLeft,
                  label: widget.labels.firstPage,
                  enabled: _hasPrev,
                  onTap: () => widget.onPageChange?.call(0),
                  colors: colors,
                ),
              _buildNavButton(
                key: const Key('oi_pagination_prev'),
                icon: OiIcons.chevronLeft,
                label: widget.labels.previousPage,
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
                icon: OiIcons.chevronRight,
                label: widget.labels.nextPage,
                enabled: _hasNext,
                onTap: () => widget.onPageChange?.call(_clampedPage + 1),
                colors: colors,
              ),
              if (_showFirstLast)
                _buildNavButton(
                  key: const Key('oi_pagination_last'),
                  icon: OiIcons.chevronsRight,
                  label: widget.labels.lastPage,
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
      label: widget.labels.navigation,
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OiLabel.small(
              widget.labels.loadedProgress?.call(
                    widget._loadedCount,
                    widget.totalItems,
                    widget.label,
                  ) ??
                  '${widget._loadedCount} of ${widget.totalItems} '
                      '${widget.label} loaded',
            ),
            const SizedBox(height: 8),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: OiButton.outline(
                  key: const Key('oi_pagination_load_more'),
                  label: widget.labels.loadMore,
                  fullWidth: true,
                  loading: widget._loading,
                  onTap: widget._loading ? null : widget._onLoadMore,
                ),
              ),
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
    final button = OiButton.icon(
      key: key,
      label: label,
      icon: icon,
      size: OiButtonSize.small,
      enabled: enabled,
      onTap: enabled ? onTap : null,
    );
    final size = context.components.pagination?.buttonSize;
    return size == null
        ? button
        : SizedBox.square(dimension: size, child: button);
  }

  Widget _buildPageButton(int page, OiColorScheme colors) {
    final isCurrent = page == _clampedPage;
    final theme = context.components.pagination;
    final radius = theme?.buttonRadius ?? BorderRadius.circular(4);
    return Semantics(
      selected: isCurrent,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: theme?.buttonSpacing ?? 4),
        child: OiTappable(
          key: Key('oi_pagination_page_$page'),
          semanticLabel:
              widget.labels.page?.call(page + 1) ?? 'Page ${page + 1}',
          onTap: isCurrent ? () {} : () => widget.onPageChange?.call(page),
          clipBorderRadius: radius,
          child: Container(
            constraints: BoxConstraints(
              minWidth: theme?.buttonSize ?? 0,
              minHeight: theme?.buttonSize ?? 0,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: theme?.buttonSize == null ? 10 : 6,
              vertical: 4,
            ),
            decoration: isCurrent
                ? BoxDecoration(
                    color: theme?.activeBackground ?? colors.primary.base,
                    borderRadius: radius,
                  )
                : null,
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                '${page + 1}',
                style:
                    (isCurrent
                            ? context.textTheme.bodyStrong
                            : context.textTheme.body)
                        .merge(
                          isCurrent ? theme?.activePageStyle : theme?.pageStyle,
                        )
                        .copyWith(
                          color: isCurrent
                              ? theme?.activeForeground ??
                                    colors.primary.foreground
                              : colors.text,
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerPageSelector(BuildContext context) {
    final options = _effectivePerPageOptions;
    Widget select = OiSelect<int>(
      key: const Key('oi_pagination_per_page'),
      options: [
        for (final opt in options)
          OiSelectOption<int>(value: opt, label: '$opt'),
      ],
      value: _effectivePerPage,
      onChanged: (val) {
        if (val != null) widget.onPerPageChange?.call(val);
      },
    );
    final size = context.components.pagination?.buttonSize;
    if (size != null) {
      final theme = OiTheme.of(context);
      final input = theme.components.textInput ?? const OiTextInputThemeData();
      final padding =
          input.contentPadding ??
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      // The pagination density applies to its selector without changing inputs
      // elsewhere. This remains a minimum height, so scaled text can still grow.
      select = OiThemeScope(
        data: theme.copyWith(
          components: theme.components.copyWith(
            textInput: input.copyWith(
              height: size,
              contentPadding: padding.copyWith(
                top: math.min(padding.top, 4),
                bottom: math.min(padding.bottom, 4),
              ),
            ),
          ),
        ),
        child: select,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: OiLabel.body(
            widget.labels.perPage,
            style: context.textTheme.small.merge(
              context.components.pagination?.labelStyle,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: context.components.pagination?.perPageWidth ?? 80,
          child: select,
        ),
      ],
    );
  }

  Widget _buildTotalLabel() {
    final itemLabel = widget.label;
    final build = widget.labels.total;

    if (widget.totalItems == 0) {
      return OiLabel.body(
        build?.call(0, 0, 0, itemLabel) ?? '0 $itemLabel',
        key: const Key('oi_pagination_total'),
        style: context.textTheme.small.merge(
          context.components.pagination?.labelStyle,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    final start = _clampedPage * _effectivePerPage + 1;
    final end = math.min(
      (_clampedPage + 1) * _effectivePerPage,
      widget.totalItems,
    );
    return OiLabel.body(
      build?.call(start, end, widget.totalItems, itemLabel) ??
          '$start\u2013$end of ${widget.totalItems} $itemLabel',
      key: const Key('oi_pagination_total'),
      style: context.textTheme.small.merge(
        context.components.pagination?.labelStyle,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
