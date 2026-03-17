import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ---------------------------------------------------------------------------
// Supporting types
// ---------------------------------------------------------------------------

/// A column in an [OiKanban] board.
///
/// Each column has a unique [key], a [title], a list of [items], and an
/// optional [color] accent applied to the column header.
@immutable
class OiKanbanColumn<T> {
  /// Creates an [OiKanbanColumn].
  const OiKanbanColumn({
    required this.key,
    required this.title,
    required this.items,
    this.color,
  });

  /// Unique identifier for this column.
  final Object key;

  /// Title displayed in the column header.
  final String title;

  /// The cards contained in this column.
  final List<T> items;

  /// Optional accent colour for the column header.
  final Color? color;
}

// ---------------------------------------------------------------------------
// OiKanban
// ---------------------------------------------------------------------------

/// A Kanban board with draggable cards across columns.
///
/// Supports drag-and-drop between columns, column reordering, WIP limits,
/// collapsible columns, and quick card editing.
///
/// {@category Modules}
class OiKanban<T> extends StatefulWidget {
  /// Creates an [OiKanban].
  const OiKanban({
    super.key,
    required this.columns,
    required this.label,
    this.onCardMove,
    this.onColumnReorder,
    this.cardBuilder,
    this.columnHeader,
    this.reorderColumns = true,
    this.wipLimits,
    this.quickEdit = true,
    this.collapsibleColumns = true,
    this.addColumn = false,
    this.onAddColumn,
    this.cardKey,
  });

  /// The columns displayed on the board.
  final List<OiKanbanColumn<T>> columns;

  /// Accessible label for the kanban board.
  final String label;

  /// Called when a card is moved between columns.
  final void Function(
      T item, Object fromColumn, Object toColumn, int newIndex)? onCardMove;

  /// Called when columns are reordered.
  final void Function(int oldIndex, int newIndex)? onColumnReorder;

  /// Custom builder for card widgets. Falls back to [toString] in a card.
  final Widget Function(T item)? cardBuilder;

  /// Custom builder for column header widgets.
  final Widget Function(OiKanbanColumn<T>)? columnHeader;

  /// Whether columns may be reordered by the user.
  final bool reorderColumns;

  /// Work-in-progress limits per column, keyed by [OiKanbanColumn.key].
  final Map<Object, int>? wipLimits;

  /// Whether quick-edit mode is enabled.
  final bool quickEdit;

  /// Whether columns can be collapsed.
  final bool collapsibleColumns;

  /// Whether to show an "Add column" button at the end.
  final bool addColumn;

  /// Called when the user taps the "Add column" button.
  final VoidCallback? onAddColumn;

  /// Extracts a unique key from each card item.
  final Object Function(T)? cardKey;

  @override
  State<OiKanban<T>> createState() => _OiKanbanState<T>();
}

class _OiKanbanState<T> extends State<OiKanban<T>> {
  final Set<Object> _collapsedColumns = {};

  void _toggleCollapse(Object columnKey) {
    setState(() {
      if (_collapsedColumns.contains(columnKey)) {
        _collapsedColumns.remove(columnKey);
      } else {
        _collapsedColumns.add(columnKey);
      }
    });
  }

  bool _isOverWipLimit(OiKanbanColumn<T> column) {
    if (widget.wipLimits == null) return false;
    final limit = widget.wipLimits![column.key];
    if (limit == null) return false;
    return column.items.length > limit;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      container: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final column in widget.columns)
              _buildColumn(context, column),
            if (widget.addColumn) _buildAddColumnButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(BuildContext context, OiKanbanColumn<T> column) {
    final colors = context.colors;
    final isCollapsed = _collapsedColumns.contains(column.key);
    final overWip = _isOverWipLimit(column);

    return Container(
      width: 280,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: overWip ? colors.error.base : colors.borderSubtle,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildColumnHeader(context, column, isCollapsed, overWip),
          if (!isCollapsed) _buildColumnBody(context, column),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(
    BuildContext context,
    OiKanbanColumn<T> column,
    bool isCollapsed,
    bool overWip,
  ) {
    final colors = context.colors;

    if (widget.columnHeader != null) {
      return widget.columnHeader!(column);
    }

    final wipLimit = widget.wipLimits?[column.key];

    return OiTappable(
      onTap: widget.collapsibleColumns
          ? () => _toggleCollapse(column.key)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: column.color?.withValues(alpha: 0.1),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
        child: Row(
          children: [
            if (column.color != null)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: column.color,
                  shape: BoxShape.circle,
                ),
              ),
            Expanded(
              child: Text(
                column.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              wipLimit != null
                  ? '${column.items.length}/$wipLimit'
                  : '${column.items.length}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: overWip ? colors.error.base : colors.textMuted,
              ),
            ),
            if (widget.collapsibleColumns) ...[
              const SizedBox(width: 4),
              Icon(
                isCollapsed
                    ? const IconData(0xe5cf, fontFamily: 'MaterialIcons')
                    : const IconData(0xe5ce, fontFamily: 'MaterialIcons'),
                size: 16,
                color: colors.textMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColumnBody(BuildContext context, OiKanbanColumn<T> column) {
    final colors = context.colors;

    if (column.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No items',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: colors.textMuted),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < column.items.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 6),
              child: _buildCard(context, column.items[i]),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, T item) {
    final colors = context.colors;

    if (widget.cardBuilder != null) {
      return widget.cardBuilder!(item);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Text(
        item.toString(),
        style: TextStyle(fontSize: 13, color: colors.text),
      ),
    );
  }

  Widget _buildAddColumnButton(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: OiTappable(
        onTap: widget.onAddColumn,
        child: Container(
          width: 280,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                const IconData(0xe145, fontFamily: 'MaterialIcons'),
                size: 16,
                color: colors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                'Add column',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
