import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/oi_span.dart';

/// A masonry-style layout that distributes [children] across [columns] vertical
/// columns, interleaving items by index (item 0 → column 0, item 1 → column 1,
/// …, item n → column n % columns).
///
/// [columns] and [gap] accept [OiResponsive] values so they can vary across
/// breakpoints:
///
/// ```dart
/// OiMasonry(
///   breakpoint: context.breakpoint,
///   columns: OiResponsive.breakpoints({
///     OiBreakpoint.compact: 2,
///     OiBreakpoint.expanded: 4,
///   }),
///   gap: OiResponsive.breakpoints({
///     OiBreakpoint.compact: 8,
///     OiBreakpoint.expanded: 16,
///   }),
///   children: [...],
/// )
/// ```
///
/// Children wrapped with [OiSpan] (via the `.span()` extension) are placed
/// according to their [OiSpanData]:
///
/// * **columnSpan** — how many columns the child occupies. Items with span > 1
///   are rendered as horizontal breakers between masonry sections (default 1).
/// * **columnStart** — which column the child is placed into (1-indexed,
///   default auto-placed via round-robin).
/// * **columnOrder** — visual ordering; lower values are distributed first
///   (default source order, treated as 0).
///
/// **Zero magic:** [breakpoint] is required so every masonry layout is
/// self-contained with explicit props. Resolve the breakpoint once at the
/// page/layout level (e.g. `context.breakpoint`) and pass it down as a
/// concrete value.
///
/// {@category Primitives}
class OiMasonry extends StatelessWidget {
  /// Creates an [OiMasonry].
  const OiMasonry({
    required this.breakpoint,
    required this.children,
    this.columns = const OiResponsive<int>(2),
    this.gap = const OiResponsive<double>(0),
    this.scale = OiBreakpointScale.defaultScale,
    super.key,
  });

  /// Number of vertical columns.
  final OiResponsive<int> columns;

  /// Horizontal and vertical gap between columns / items in logical pixels.
  final OiResponsive<double> gap;

  /// The active breakpoint. Required — resolve once at the layout level
  /// and pass down explicitly.
  final OiBreakpoint breakpoint;

  /// The breakpoint scale used to resolve responsive values.
  ///
  /// Defaults to [OiBreakpointScale.defaultScale] (the standard 5-tier scale).
  /// Zero magic: no context lookup — pass an explicit scale if you use a
  /// custom breakpoint configuration.
  final OiBreakpointScale scale;

  /// The child widgets to distribute across columns.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Resolve responsive values — breakpoint is explicit, no context
        // lookup for it.
        final active = breakpoint;
        final resolvedScale = scale;
        final resolvedColumns = math.max(
          1,
          columns.resolve(active, resolvedScale),
        );
        final resolvedGap = gap.resolve(active, resolvedScale);

        final hasBoundedWidth = constraints.hasBoundedWidth;

        // Column width — shared by both paths.
        double? columnWidth;
        if (hasBoundedWidth) {
          final availableWidth = constraints.maxWidth;
          columnWidth = resolvedColumns <= 1
              ? availableWidth
              : (availableWidth - resolvedGap * (resolvedColumns - 1)) /
                    resolvedColumns;
        }

        // Fast path: no span children → original round-robin distribution.
        if (!children.any((c) => c is OiSpan)) {
          return _buildMasonryRow(
            children,
            resolvedColumns,
            resolvedGap,
            hasBoundedWidth,
            columnWidth,
          );
        }

        // ── Span-aware placement ────────────────────────────────────────

        // Build item list with resolved span data.
        final items = <_MasonryItem>[];
        for (var i = 0; i < children.length; i++) {
          final child = children[i];
          final spanData = OiSpan.maybeOf(child);

          var colSpan = spanData?.resolveColumnSpan(active, resolvedScale) ?? 1;
          if (colSpan == fullSpanSentinel) colSpan = resolvedColumns;
          colSpan = colSpan.clamp(1, resolvedColumns);

          items.add(
            _MasonryItem(
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

        // Partition into masonry groups (span 1) and spanning breakers,
        // rendering each segment as we go.
        final output = <Widget>[];
        var currentGroup = <_MasonryItem>[];
        var hasOutput = false;

        void flushGroup() {
          if (currentGroup.isEmpty) return;
          if (hasOutput && resolvedGap > 0) {
            output.add(SizedBox(height: resolvedGap));
          }
          output.add(
            _buildMasonryRowFromItems(
              currentGroup,
              resolvedColumns,
              resolvedGap,
              hasBoundedWidth,
              columnWidth,
            ),
          );
          currentGroup = [];
          hasOutput = true;
        }

        for (final item in items) {
          if (item.columnSpan > 1) {
            flushGroup();
            if (hasOutput && resolvedGap > 0) {
              output.add(SizedBox(height: resolvedGap));
            }

            // Render spanning breaker.
            if (columnWidth != null) {
              final spanW =
                  item.columnSpan * columnWidth +
                  math.max(0, item.columnSpan - 1) * resolvedGap;
              output.add(SizedBox(width: spanW, child: item.child));
            } else {
              output.add(item.child);
            }
            hasOutput = true;
          } else {
            currentGroup.add(item);
          }
        }
        flushGroup();

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: output,
        );
      },
    );
  }

  /// Builds a masonry row from a flat list of widgets (fast path).
  static Widget _buildMasonryRow(
    List<Widget> items,
    int resolvedColumns,
    double resolvedGap,
    bool boundedWidth,
    double? columnWidth,
  ) {
    final cols = List.generate(resolvedColumns, (_) => <Widget>[]);
    for (var i = 0; i < items.length; i++) {
      cols[i % resolvedColumns].add(items[i]);
    }
    return _renderColumns(
      cols,
      resolvedColumns,
      resolvedGap,
      boundedWidth,
      columnWidth,
    );
  }

  /// Builds a masonry row from items with columnStart support (span path).
  static Widget _buildMasonryRowFromItems(
    List<_MasonryItem> items,
    int resolvedColumns,
    double resolvedGap,
    bool boundedWidth,
    double? columnWidth,
  ) {
    final cols = List.generate(resolvedColumns, (_) => <Widget>[]);
    var robin = 0;

    for (final item in items) {
      if (item.columnStart != null) {
        final col = (item.columnStart! - 1).clamp(0, resolvedColumns - 1);
        cols[col].add(item.child);
      } else {
        cols[robin % resolvedColumns].add(item.child);
        robin++;
      }
    }

    return _renderColumns(
      cols,
      resolvedColumns,
      resolvedGap,
      boundedWidth,
      columnWidth,
    );
  }

  /// Renders per-column child lists as a Row with gap spacing.
  static Widget _renderColumns(
    List<List<Widget>> cols,
    int resolvedColumns,
    double resolvedGap,
    bool boundedWidth,
    double? columnWidth,
  ) {
    final columnWidgets = <Widget>[];
    for (var c = 0; c < resolvedColumns; c++) {
      final items = cols[c];
      final spacedItems = <Widget>[];
      for (var i = 0; i < items.length; i++) {
        spacedItems.add(items[i]);
        if (i < items.length - 1 && resolvedGap > 0) {
          spacedItems.add(SizedBox(height: resolvedGap));
        }
      }

      Widget col = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: boundedWidth
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.start,
        children: spacedItems,
      );

      if (columnWidth != null) {
        col = SizedBox(width: columnWidth, child: col);
      }

      columnWidgets.add(col);
      if (c < resolvedColumns - 1 && resolvedGap > 0) {
        columnWidgets.add(SizedBox(width: resolvedGap));
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columnWidgets,
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _MasonryItem {
  _MasonryItem({
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
