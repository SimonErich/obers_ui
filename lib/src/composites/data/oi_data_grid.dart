import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inputs/oi_checkbox.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/animation/oi_shimmer.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// Controls how the header row of an [OiDataGrid] is styled.
///
/// {@category Composites}
enum OiDataGridHeaderStyle {
  /// Header row has a filled background using `colors.surfaceSubtle`.
  filled,

  /// Header row has no background fill, only bottom border.
  plain,

  /// No header row is rendered.
  none,
}

/// Defines a single column in an [OiDataGrid].
///
/// Each column has a unique [id], a [header] label, and a [cellBuilder] that
/// renders the cell widget for a given row. Columns support fixed [width],
/// [minWidth] constraints, flexible [flex] sizing, sort indicators, numeric
/// alignment, and text alignment.
///
/// Use [OiDataGridColumn.text] for simple string-valued columns.
///
/// {@category Composites}
class OiDataGridColumn<T> {
  /// Creates an [OiDataGridColumn] with a custom cell builder.
  const OiDataGridColumn({
    required this.id,
    required this.header,
    required this.cellBuilder,
    this.width,
    this.minWidth,
    this.flex,
    this.sortable = false,
    this.textAlign = TextAlign.start,
    this.numeric = false,
  }) : _valueOf = null,
       _style = null;

  /// Creates a text-only column that extracts a string value from each row.
  ///
  /// The extracted value is displayed as an [OiLabel.body].
  OiDataGridColumn.text({
    required this.id,
    required this.header,
    required String Function(T) valueOf,
    this.sortable = false,
    TextStyle? style,
    this.width,
    this.minWidth,
    this.flex,
    this.textAlign = TextAlign.start,
    this.numeric = false,
  }) : _valueOf = valueOf,
       _style = style,
       cellBuilder = null;

  /// Unique identifier for this column.
  final String id;

  /// Text displayed in the column header.
  final String header;

  /// Builds the cell widget for a given row and row index.
  ///
  /// When null (created via [OiDataGridColumn.text]), the column renders
  /// the value returned by the text extractor.
  final Widget Function(BuildContext context, T row, int rowIndex)? cellBuilder;

  /// Fixed width in logical pixels. When set, [flex] is ignored.
  final double? width;

  /// Minimum width constraint in logical pixels.
  final double? minWidth;

  /// Flex factor for flexible column sizing. Defaults to 1 when neither
  /// [width] nor [flex] is specified.
  final int? flex;

  /// Whether the column can be sorted by tapping its header.
  final bool sortable;

  /// Text alignment within each cell.
  final TextAlign textAlign;

  /// Whether this column contains numeric data.
  ///
  /// Numeric columns default to end-aligned text.
  final bool numeric;

  // Private fields for the text factory.
  final String Function(T)? _valueOf;
  final TextStyle? _style;

  /// Builds the cell widget, using [cellBuilder] if provided or falling
  /// back to the text extractor.
  Widget buildCell(BuildContext context, T row, int rowIndex) {
    if (cellBuilder != null) {
      return cellBuilder!(context, row, rowIndex);
    }
    final value = _valueOf!(row);
    final effectiveAlign = numeric ? TextAlign.end : textAlign;
    if (_style != null) {
      return Text(
        value,
        textAlign: effectiveAlign,
        style: _style,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }
    return OiLabel.body(
      value,
      textAlign: effectiveAlign,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// A lightweight data grid for displaying tabular data with sorting,
/// row selection, striped rows, dense mode, and loading states.
///
/// [OiDataGrid] renders a header row followed by data rows. Each column
/// is defined by an [OiDataGridColumn]. Supports:
///
/// - **Sorting**: sortable columns show chevron indicators in the header.
/// - **Selection**: optional single or multi-select with checkboxes.
/// - **Striped rows**: alternating row backgrounds.
/// - **Dense mode**: compact row height (36dp vs 48dp).
/// - **Border**: optional outer border.
/// - **Loading**: shimmer skeleton rows while data is loading.
/// - **Empty state**: custom or default "No data" message.
///
/// ```dart
/// OiDataGrid<User>(
///   rows: users,
///   columns: [
///     OiDataGridColumn.text(id: 'name', header: 'Name', valueOf: (u) => u.name),
///     OiDataGridColumn.text(id: 'email', header: 'Email', valueOf: (u) => u.email),
///   ],
///   sortColumnId: 'name',
///   sortAscending: true,
///   onSort: (columnId, ascending) { ... },
/// )
/// ```
///
/// {@category Composites}
class OiDataGrid<T> extends StatelessWidget {
  /// Creates an [OiDataGrid].
  const OiDataGrid({
    required this.rows,
    required this.columns,
    this.sortColumnId,
    this.sortAscending = true,
    this.onSort,
    this.selectable = false,
    this.multiSelect = false,
    this.selectedRows,
    this.onSelectionChanged,
    this.onRowTap,
    this.headerStyle = OiDataGridHeaderStyle.filled,
    this.striped = false,
    this.dense = false,
    this.showBorder = true,
    this.emptyState,
    this.loading = false,
    this.semanticLabel,
    super.key,
  });

  /// The data rows to display.
  final List<T> rows;

  /// Column definitions describing each column's header, width, and cell
  /// rendering.
  final List<OiDataGridColumn<T>> columns;

  /// The [OiDataGridColumn.id] of the currently sorted column, or null.
  final String? sortColumnId;

  /// Whether the current sort is ascending.
  final bool sortAscending;

  /// Called when a sortable column header is tapped.
  ///
  /// Receives the column id and the new ascending state.
  final void Function(String columnId, {required bool ascending})? onSort;

  /// Whether rows can be selected.
  final bool selectable;

  /// Whether multiple rows can be selected simultaneously.
  ///
  /// Only effective when [selectable] is `true`.
  final bool multiSelect;

  /// The set of currently selected row indices.
  final Set<int>? selectedRows;

  /// Called when the selection changes.
  final ValueChanged<Set<int>>? onSelectionChanged;

  /// Called when a row is tapped (independent of selection).
  final void Function(T row, int index)? onRowTap;

  /// The visual style of the header row.
  final OiDataGridHeaderStyle headerStyle;

  /// Whether alternate rows have a subtle background tint.
  final bool striped;

  /// Whether to use compact row height (36dp instead of 48dp).
  final bool dense;

  /// Whether to show a border around the grid.
  final bool showBorder;

  /// Widget displayed when [rows] is empty and [loading] is `false`.
  ///
  /// When null, a default "No data" label is shown.
  final Widget? emptyState;

  /// When `true`, shimmer skeleton rows are shown instead of data.
  final bool loading;

  /// Accessibility label for the data grid.
  final String? semanticLabel;

  // ── Helpers ──────────────────────────────────────────────────────────────

  double get _rowHeight => dense ? 36 : 48;

  bool _isSelected(int index) => selectedRows?.contains(index) ?? false;

  bool get _allSelected =>
      rows.isNotEmpty &&
      selectedRows != null &&
      selectedRows!.length == rows.length;

  bool get _someSelected =>
      selectedRows != null &&
      selectedRows!.isNotEmpty &&
      selectedRows!.length < rows.length;

  void _toggleRow(int index) {
    if (onSelectionChanged == null) return;
    final current = Set<int>.of(selectedRows ?? <int>{});
    if (current.contains(index)) {
      current.remove(index);
    } else {
      if (!multiSelect) current.clear();
      current.add(index);
    }
    onSelectionChanged!(current);
  }

  void _toggleAll() {
    if (onSelectionChanged == null) return;
    if (_allSelected) {
      onSelectionChanged!(<int>{});
    } else {
      onSelectionChanged!(Set<int>.of(
        List<int>.generate(rows.length, (i) => i),
      ));
    }
  }

  // ── Column width helpers ─────────────────────────────────────────────────

  Widget _wrapColumn(OiDataGridColumn<T> column, Widget child) {
    if (column.width != null) {
      return SizedBox(
        width: column.width,
        child: child,
      );
    }
    return Expanded(
      flex: column.flex ?? 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: column.minWidth ?? 0,
        ),
        child: child,
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    final cells = <Widget>[
      if (selectable && multiSelect)
        SizedBox(
          width: _rowHeight,
          child: Center(
            child: OiCheckbox(
              value: _allSelected
                  ? true
                  : (_someSelected ? null : false),
              onChanged: (_) => _toggleAll(),
              label: 'Select all',
            ),
          ),
        ),
      for (final column in columns) _buildHeaderCell(context, column),
    ];

    Widget header = Container(
      height: _rowHeight,
      padding: EdgeInsets.symmetric(horizontal: spacing.sm),
      decoration: BoxDecoration(
        color: headerStyle == OiDataGridHeaderStyle.filled
            ? colors.surfaceSubtle
            : null,
        border: Border(
          bottom: BorderSide(color: colors.border),
        ),
      ),
      child: Row(children: cells),
    );

    if (headerStyle == OiDataGridHeaderStyle.none) {
      header = const SizedBox.shrink();
    }

    return header;
  }

  Widget _buildHeaderCell(BuildContext context, OiDataGridColumn<T> column) {
    final colors = context.colors;
    final spacing = context.spacing;
    final isSorted = sortColumnId == column.id;

    Widget label = OiLabel.small(
      column.header,
      color: colors.textSubtle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    if (column.sortable && isSorted) {
      label = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: label),
          SizedBox(width: spacing.xs),
          OiIcon.decorative(
            icon: sortAscending ? OiIcons.chevronUp : OiIcons.chevronDown,
            size: 14,
            color: colors.primary.base,
          ),
        ],
      );
    }

    Widget cell = Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.xs),
      child: Align(
        alignment: _alignmentFor(column),
        child: label,
      ),
    );

    if (column.sortable) {
      cell = OiTappable(
        semanticLabel: 'Sort by ${column.header}',
        onTap: () {
          final ascending = !isSorted || !sortAscending;
          onSort?.call(column.id, ascending: ascending);
        },
        child: cell,
      );
    }

    return _wrapColumn(column, cell);
  }

  // ── Data rows ────────────────────────────────────────────────────────────

  Widget _buildRow(BuildContext context, int index) {
    final colors = context.colors;
    final spacing = context.spacing;
    final row = rows[index];
    final selected = _isSelected(index);

    final cells = <Widget>[
      if (selectable)
        SizedBox(
          width: _rowHeight,
          child: Center(
            child: OiCheckbox(
              value: selected,
              onChanged: (_) => _toggleRow(index),
              label: 'Select row ${index + 1}',
            ),
          ),
        ),
      for (final column in columns) _buildDataCell(context, column, row, index),
    ];

    final isEvenRow = index.isEven;
    final bgColor = selected
        ? colors.primary.muted
        : (striped && !isEvenRow ? colors.surfaceSubtle : null);

    Widget rowWidget = Container(
      height: _rowHeight,
      padding: EdgeInsets.symmetric(horizontal: spacing.sm),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: colors.borderSubtle),
        ),
      ),
      child: Row(children: cells),
    );

    if (onRowTap != null) {
      rowWidget = OiTappable(
        semanticLabel: 'Row ${index + 1}',
        onTap: () => onRowTap!(row, index),
        child: rowWidget,
      );
    }

    return rowWidget;
  }

  Widget _buildDataCell(
    BuildContext context,
    OiDataGridColumn<T> column,
    T row,
    int rowIndex,
  ) {
    final spacing = context.spacing;

    return _wrapColumn(
      column,
      Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.xs),
        child: Align(
          alignment: _alignmentFor(column),
          child: column.buildCell(context, row, rowIndex),
        ),
      ),
    );
  }

  // ── Loading skeleton ─────────────────────────────────────────────────────

  Widget _buildLoadingRows(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    const skeletonRowCount = 5;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(skeletonRowCount, (index) {
        return OiShimmer(
          child: Container(
            height: _rowHeight,
            padding: EdgeInsets.symmetric(horizontal: spacing.sm),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colors.borderSubtle),
              ),
            ),
            child: Row(
              children: [
                for (final column in columns)
                  _wrapColumn(
                    column,
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: spacing.xs,
                        vertical: spacing.sm,
                      ),
                      child: Container(
                        height: dense ? 12 : 16,
                        decoration: BoxDecoration(
                          color: colors.surfaceHover,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Container(
      padding: EdgeInsets.all(spacing.xl),
      alignment: Alignment.center,
      child: emptyState ??
          OiLabel.body(
            'No data',
            color: colors.textMuted,
          ),
    );
  }

  // ── Alignment helper ─────────────────────────────────────────────────────

  AlignmentGeometry _alignmentFor(OiDataGridColumn<T> column) {
    if (column.numeric) return Alignment.centerRight;
    switch (column.textAlign) {
      case TextAlign.center:
        return Alignment.center;
      case TextAlign.right:
      case TextAlign.end:
        return Alignment.centerRight;
      case TextAlign.left:
      case TextAlign.start:
      case TextAlign.justify:
        return Alignment.centerLeft;
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;

    Widget content;

    if (loading) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (headerStyle != OiDataGridHeaderStyle.none) _buildHeader(context),
          _buildLoadingRows(context),
        ],
      );
    } else if (rows.isEmpty) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (headerStyle != OiDataGridHeaderStyle.none) _buildHeader(context),
          _buildEmptyState(context),
        ],
      );
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (headerStyle != OiDataGridHeaderStyle.none) _buildHeader(context),
          for (var i = 0; i < rows.length; i++) _buildRow(context, i),
        ],
      );
    }

    if (showBorder) {
      content = Container(
        decoration: BoxDecoration(
          border: Border.all(color: colors.border),
          borderRadius: radius.md,
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      );
    }

    if (semanticLabel != null) {
      content = Semantics(
        label: semanticLabel,
        container: true,
        child: content,
      );
    }

    return content;
  }
}
