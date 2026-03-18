import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/oi_span.dart';

/// A non-scrolling grid layout that arranges [children] into a fixed number
/// of equal-width columns.
///
/// Provide either [columns] for a fixed column count or [minColumnWidth] to
/// compute the column count automatically from the available width. If both
/// are omitted, a single column is used.
///
/// Children wrapped with [OiSpan] (via the `.span()` extension) are placed
/// according to their [OiSpanData]:
///
/// * **columnSpan** — how many columns the child occupies (default 1).
/// * **columnStart** — which column the child starts at (1-indexed, default
///   auto-placed).
/// * **columnOrder** — visual ordering; lower values render first (default
///   source order, treated as 0).
///
/// When no children carry span metadata the grid uses a simple [Wrap]-based
/// layout that does not require an [OiTheme] ancestor.
///
/// {@category Primitives}
class OiGrid extends StatelessWidget {
  /// Creates an [OiGrid].
  const OiGrid({
    required this.children,
    this.columns,
    this.minColumnWidth,
    this.gap = 0,
    this.rowGap,
    this.breakpoint,
    super.key,
  }) : assert(
         columns == null || minColumnWidth == null,
         'Provide either columns or minColumnWidth, not both.',
       );

  /// Fixed number of columns. Mutually exclusive with [minColumnWidth].
  final int? columns;

  /// Minimum column width in logical pixels used to auto-compute the column
  /// count. Mutually exclusive with [columns].
  final double? minColumnWidth;

  /// Horizontal gap between columns and (when [rowGap] is null) the vertical
  /// gap between rows, in logical pixels.
  final double gap;

  /// Vertical gap between rows. When null, [gap] is used for both axes.
  final double? rowGap;

  /// The active breakpoint, resolved at the layout level.
  ///
  /// When null, falls back to `context.breakpoint` (implicit context lookup).
  /// Only accessed when at least one child carries [OiSpan] metadata.
  final OiBreakpoint? breakpoint;

  /// The child widgets to place in the grid.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // When placed inside an unconstrained-width parent (e.g. a Row),
        // fall back to a single-column vertical layout so the widget
        // composes without overflow.
        if (!constraints.hasBoundedWidth) {
          final effectiveRowGap = rowGap ?? gap;
          final spaced = <Widget>[];
          for (var i = 0; i < children.length; i++) {
            spaced.add(children[i]);
            if (i < children.length - 1 && effectiveRowGap > 0) {
              spaced.add(SizedBox(height: effectiveRowGap));
            }
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: spaced,
          );
        }

        final availableWidth = constraints.maxWidth;
        final effectiveRowGap = rowGap ?? gap;

        // Compute column count.
        int cols;
        if (columns != null) {
          cols = columns!;
        } else if (minColumnWidth != null && minColumnWidth! > 0) {
          cols = math.max(1, (availableWidth / minColumnWidth!).floor());
        } else {
          cols = 1;
        }

        // Unit column width = (total width − gap × (cols − 1)) / cols.
        final unitWidth = cols <= 1
            ? availableWidth
            : (availableWidth - gap * (cols - 1)) / cols;

        // Fast path: no span children → simple Wrap (no context needed).
        if (!children.any((c) => c is OiSpan)) {
          return Wrap(
            spacing: gap,
            runSpacing: effectiveRowGap,
            children: children
                .map((child) => SizedBox(width: unitWidth, child: child))
                .toList(),
          );
        }

        // ── Span-aware placement ────────────────────────────────────────
        final active = breakpoint ?? context.breakpoint;
        final scale = context.breakpointScale;

        // Build item list with resolved span data.
        final items = <_GridItem>[];
        for (var i = 0; i < children.length; i++) {
          final child = children[i];
          final spanData = OiSpan.maybeOf(child);

          var colSpan = spanData?.resolveColumnSpan(active, scale) ?? 1;
          if (colSpan == fullSpanSentinel) colSpan = cols;
          colSpan = colSpan.clamp(1, cols);

          items.add(_GridItem(
            index: i,
            child: child,
            columnSpan: colSpan,
            columnStart: spanData?.resolveColumnStart(active, scale),
            columnOrder: spanData?.resolveColumnOrder(active, scale),
          ));
        }

        // Stable sort by columnOrder (null → 0, matching CSS Grid convention).
        items.sort((a, b) {
          final oa = a.columnOrder ?? 0;
          final ob = b.columnOrder ?? 0;
          if (oa != ob) return oa.compareTo(ob);
          return a.index.compareTo(b.index);
        });

        // Place items into rows.
        final rows = <List<_PlacedItem>>[];
        var currentRow = <_PlacedItem>[];
        var cursor = 0; // 0-indexed current column position

        for (final item in items) {
          var colSpan = item.columnSpan;
          final rawStart = item.columnStart;

          if (rawStart != null) {
            // Explicit start (1-indexed → 0-indexed).
            var targetCol = (rawStart - 1).clamp(0, cols - 1);
            colSpan = math.min(colSpan, cols - targetCol);

            if (targetCol < cursor) {
              // Target is behind cursor — flush current row, start new one.
              if (currentRow.isNotEmpty) {
                rows.add(currentRow);
                currentRow = [];
              }
              cursor = 0;
            }

            // Insert spacer columns if needed.
            if (targetCol > cursor) {
              currentRow.add(_PlacedItem.spacer(targetCol - cursor));
              cursor = targetCol;
            }
          }

          // If the item doesn't fit on the current row, start a new one.
          if (cursor + colSpan > cols) {
            if (currentRow.isNotEmpty) {
              rows.add(currentRow);
              currentRow = [];
            }
            cursor = 0;

            // Re-apply columnStart on the new row.
            if (rawStart != null) {
              final targetCol = (rawStart - 1).clamp(0, cols - 1);
              colSpan = math.min(colSpan, cols - targetCol);
              if (targetCol > 0) {
                currentRow.add(_PlacedItem.spacer(targetCol));
                cursor = targetCol;
              }
            }
          }

          currentRow.add(_PlacedItem(item.child, colSpan));
          cursor += colSpan;
        }
        if (currentRow.isNotEmpty) rows.add(currentRow);

        // ── Render rows ─────────────────────────────────────────────────
        final rowWidgets = <Widget>[];
        for (var r = 0; r < rows.length; r++) {
          final row = rows[r];
          final cells = <Widget>[];
          var isFirst = true;

          for (final placed in row) {
            if (!isFirst && gap > 0) {
              cells.add(SizedBox(width: gap));
            }
            isFirst = false;

            final width = placed.columnSpan * unitWidth +
                math.max(0, placed.columnSpan - 1) * gap;

            if (placed.isSpacer) {
              cells.add(SizedBox(width: width));
            } else {
              cells.add(SizedBox(width: width, child: placed.child));
            }
          }

          rowWidgets.add(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cells,
          ));

          if (r < rows.length - 1 && effectiveRowGap > 0) {
            rowWidgets.add(SizedBox(height: effectiveRowGap));
          }
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowWidgets,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _GridItem {
  _GridItem({
    required this.index,
    required this.child,
    required this.columnSpan,
    this.columnStart,
    this.columnOrder,
  });

  final int index;
  final Widget child;
  final int columnSpan;
  final int? columnStart;
  final int? columnOrder;
}

class _PlacedItem {
  _PlacedItem(this.child, this.columnSpan) : isSpacer = false;
  _PlacedItem.spacer(this.columnSpan) : child = null, isSpacer = true;

  final Widget? child;
  final int columnSpan;
  final bool isSpacer;
}
