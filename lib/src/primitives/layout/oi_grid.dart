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
/// All layout properties ([columns], [minColumnWidth], [gap], [rowGap]) accept
/// [OiResponsive] values so they can vary across breakpoints:
///
/// ```dart
/// OiGrid(
///   breakpoint: context.breakpoint,
///   columns: OiResponsive.breakpoints({
///     OiBreakpoint.compact: 1,
///     OiBreakpoint.medium: 2,
///     OiBreakpoint.large: 4,
///   }),
///   gap: OiResponsive.breakpoints({
///     OiBreakpoint.compact: 8,
///     OiBreakpoint.expanded: 16,
///   }),
///   children: [...],
/// )
/// ```
///
/// **Zero magic:** [breakpoint] is required so every grid is self-contained
/// with explicit props. Resolve the breakpoint once at the page/layout level
/// (e.g. `context.breakpoint`) and pass it down as a concrete value.
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
/// {@category Primitives}
class OiGrid extends StatelessWidget {
  /// Creates an [OiGrid].
  const OiGrid({
    required this.breakpoint,
    required this.children,
    this.columns,
    this.minColumnWidth,
    this.gap = const OiResponsive<double>(0),
    this.rowGap,
    this.scale,
    super.key,
  }) : assert(
         columns == null || minColumnWidth == null,
         'Provide either columns or minColumnWidth, not both.',
       );

  /// Fixed number of columns. Mutually exclusive with [minColumnWidth].
  final OiResponsive<int>? columns;

  /// Minimum column width in logical pixels used to auto-compute the column
  /// count. Mutually exclusive with [columns].
  final OiResponsive<double>? minColumnWidth;

  /// Horizontal gap between columns and (when [rowGap] is null) the vertical
  /// gap between rows, in logical pixels.
  final OiResponsive<double> gap;

  /// Vertical gap between rows. When null, [gap] is used for both axes.
  final OiResponsive<double>? rowGap;

  /// The active breakpoint. Required — resolve once at the layout level
  /// and pass down explicitly.
  final OiBreakpoint breakpoint;

  /// The breakpoint scale used to resolve responsive values.
  ///
  /// When null, read from the nearest [OiTheme] via `context.breakpointScale`.
  final OiBreakpointScale? scale;

  /// The child widgets to place in the grid.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Resolve responsive values — breakpoint is explicit, no context
        // lookup for it.
        final active = breakpoint;
        final resolvedScale = scale ?? context.breakpointScale;

        final resolvedGap = gap.resolve(active, resolvedScale);
        final effectiveRowGap =
            rowGap?.resolve(active, resolvedScale) ?? resolvedGap;

        // When placed inside an unconstrained-width parent (e.g. a Row),
        // use intrinsic sizing if an explicit column count is provided.
        // Fall back to single-column only for minColumnWidth (can't compute
        // column count without available width).
        if (!constraints.hasBoundedWidth) {
          final resolvedCols = columns?.resolve(active, resolvedScale);

          if (resolvedCols == null || resolvedCols <= 0) {
            // minColumnWidth or no column spec — single-column fallback.
            final spaced = <Widget>[];
            for (var i = 0; i < children.length; i++) {
              spaced.add(children[i]);
              if (i < children.length - 1 && effectiveRowGap > 0) {
                spaced.add(SizedBox(height: effectiveRowGap));
              }
            }
            return Column(mainAxisSize: MainAxisSize.min, children: spaced);
          }

          // Explicit columns — render multi-column with intrinsic sizing.
          final cols = resolvedCols;

          // Build item list with span data for ordering.
          final items = <_GridItem>[];
          for (var i = 0; i < children.length; i++) {
            final child = children[i];
            final spanData = OiSpan.maybeOf(child);

            var colSpan =
                spanData?.resolveColumnSpan(active, resolvedScale) ?? 1;
            if (colSpan == fullSpanSentinel) colSpan = cols;
            colSpan = colSpan.clamp(1, cols);

            items.add(
              _GridItem(
                index: i,
                child: child,
                columnSpan: colSpan,
                columnStart: spanData?.resolveColumnStart(
                  active,
                  resolvedScale,
                ),
                columnOrder: spanData?.resolveColumnOrder(
                  active,
                  resolvedScale,
                ),
              ),
            );
          }

          // Stable sort by columnOrder (null → 0).
          items.sort((a, b) {
            final oa = a.columnOrder ?? 0;
            final ob = b.columnOrder ?? 0;
            if (oa != ob) return oa.compareTo(ob);
            return a.index.compareTo(b.index);
          });

          // Place items into rows (capacity = cols).
          final rows = <List<_GridItem>>[];
          var currentRow = <_GridItem>[];
          var cursor = 0;

          for (final item in items) {
            final colSpan = item.columnSpan;
            if (cursor + colSpan > cols) {
              if (currentRow.isNotEmpty) {
                rows.add(currentRow);
                currentRow = [];
              }
              cursor = 0;
            }
            currentRow.add(item);
            cursor += colSpan;
          }
          if (currentRow.isNotEmpty) rows.add(currentRow);

          // Render rows with intrinsic child sizing.
          final rowWidgets = <Widget>[];
          for (var r = 0; r < rows.length; r++) {
            final row = rows[r];
            final cells = <Widget>[];
            for (var i = 0; i < row.length; i++) {
              if (i > 0 && resolvedGap > 0) {
                cells.add(SizedBox(width: resolvedGap));
              }
              cells.add(row[i].child);
            }
            rowWidgets.add(
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: cells,
              ),
            );
            if (r < rows.length - 1 && effectiveRowGap > 0) {
              rowWidgets.add(SizedBox(height: effectiveRowGap));
            }
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowWidgets,
          );
        }

        final availableWidth = constraints.maxWidth;

        // Compute column count.
        final resolvedColumns = columns?.resolve(active, resolvedScale);
        final resolvedMinColumnWidth = minColumnWidth?.resolve(
          active,
          resolvedScale,
        );

        int cols;
        if (resolvedColumns != null) {
          cols = resolvedColumns;
        } else if (resolvedMinColumnWidth != null &&
            resolvedMinColumnWidth > 0) {
          cols = math.max(1, (availableWidth / resolvedMinColumnWidth).floor());
        } else {
          cols = 1;
        }

        // Unit column width = (total width − gap × (cols − 1)) / cols.
        final unitWidth = cols <= 1
            ? availableWidth
            : (availableWidth - resolvedGap * (cols - 1)) / cols;

        // Fast path: no span children → simple Wrap (no context needed).
        if (!children.any((c) => c is OiSpan)) {
          return Wrap(
            spacing: resolvedGap,
            runSpacing: effectiveRowGap,
            children: children
                .map((child) => SizedBox(width: unitWidth, child: child))
                .toList(),
          );
        }

        // ── Span-aware placement ────────────────────────────────────────

        // Build item list with resolved span data.
        final items = <_GridItem>[];
        for (var i = 0; i < children.length; i++) {
          final child = children[i];
          final spanData = OiSpan.maybeOf(child);

          var colSpan = spanData?.resolveColumnSpan(active, resolvedScale) ?? 1;
          if (colSpan == fullSpanSentinel) colSpan = cols;
          colSpan = colSpan.clamp(1, cols);

          items.add(
            _GridItem(
              index: i,
              child: child,
              columnSpan: colSpan,
              columnStart: spanData?.resolveColumnStart(active, resolvedScale),
              columnOrder: spanData?.resolveColumnOrder(active, resolvedScale),
            ),
          );
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
            final targetCol = (rawStart - 1).clamp(0, cols - 1);
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
            if (!isFirst && resolvedGap > 0) {
              cells.add(SizedBox(width: resolvedGap));
            }
            isFirst = false;

            final width =
                placed.columnSpan * unitWidth +
                math.max(0, placed.columnSpan - 1) * resolvedGap;

            if (placed.isSpacer) {
              cells.add(SizedBox(width: width));
            } else {
              cells.add(SizedBox(width: width, child: placed.child));
            }
          }

          rowWidgets.add(
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: cells),
          );

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
