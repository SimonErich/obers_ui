import 'dart:math' as math;

import 'package:flutter/rendering.dart';
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
/// Internally uses a custom [RenderBox] with [ContainerRenderObjectMixin] for
/// column-start and column-span control without relying on [Wrap] or
/// [GridView].
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
    this.scale = OiBreakpointScale.defaultScale,
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
  /// Defaults to [OiBreakpointScale.defaultScale] (the standard 5-tier scale).
  /// Zero magic: no context lookup — pass an explicit scale if you use a
  /// custom breakpoint configuration.
  final OiBreakpointScale scale;

  /// The child widgets to place in the grid.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // Resolve responsive values once — breakpoint is explicit, no context
    // lookup for it.
    final active = breakpoint;
    final resolvedScale = scale;

    final resolvedGap = gap.resolve(active, resolvedScale);
    final effectiveRowGap =
        rowGap?.resolve(active, resolvedScale) ?? resolvedGap;

    final resolvedColumns = columns?.resolve(active, resolvedScale);
    final resolvedMinColumnWidth = minColumnWidth?.resolve(
      active,
      resolvedScale,
    );

    // Wrap each child in a _OiGridSlot ParentDataWidget carrying the
    // resolved span metadata. This avoids per-child rebuilds — the render
    // object reads span data from parentData during layout.
    final wrappedChildren = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final spanData = OiSpan.maybeOf(child);

      final colSpan = spanData?.resolveColumnSpan(active, resolvedScale) ?? 1;
      final colStart = spanData?.resolveColumnStart(active, resolvedScale);
      final colOrder = spanData?.resolveColumnOrder(active, resolvedScale);

      wrappedChildren.add(
        _OiGridSlot(
          index: i,
          columnSpan: colSpan,
          columnStart: colStart,
          columnOrder: colOrder,
          child: child,
        ),
      );
    }

    return _OiGridLayout(
      columns: resolvedColumns,
      minColumnWidth: resolvedMinColumnWidth,
      gap: resolvedGap,
      rowGap: effectiveRowGap,
      children: wrappedChildren,
    );
  }
}

// ---------------------------------------------------------------------------
// ParentData
// ---------------------------------------------------------------------------

/// Per-child data stored by [_RenderOiGrid] on each child render object.
class _OiGridParentData extends ContainerBoxParentData<RenderBox> {
  /// Source index, used for stable sort tie-breaking.
  int index = 0;

  /// How many columns this child spans (1-based, sentinel -1 = full row).
  int columnSpan = 1;

  /// Explicit column start (1-indexed), or null for auto-placement.
  int? columnStart;

  /// Visual ordering key; lower renders first, null = source order (0).
  int? columnOrder;
}

// ---------------------------------------------------------------------------
// ParentDataWidget — sets span metadata on each child
// ---------------------------------------------------------------------------

/// Applies resolved [OiSpanData] to the child's [_OiGridParentData].
class _OiGridSlot extends ParentDataWidget<_OiGridParentData> {
  const _OiGridSlot({
    required this.index,
    required this.columnSpan,
    required this.columnStart,
    required this.columnOrder,
    required super.child,
  });

  final int index;
  final int columnSpan;
  final int? columnStart;
  final int? columnOrder;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData! as _OiGridParentData;
    var needsLayout = false;

    if (parentData.index != index) {
      parentData.index = index;
      needsLayout = true;
    }
    if (parentData.columnSpan != columnSpan) {
      parentData.columnSpan = columnSpan;
      needsLayout = true;
    }
    if (parentData.columnStart != columnStart) {
      parentData.columnStart = columnStart;
      needsLayout = true;
    }
    if (parentData.columnOrder != columnOrder) {
      parentData.columnOrder = columnOrder;
      needsLayout = true;
    }

    if (needsLayout) {
      final targetParent = renderObject.parent;
      if (targetParent is RenderObject) {
        targetParent.markNeedsLayout();
      }
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => _OiGridLayout;
}

// ---------------------------------------------------------------------------
// MultiChildRenderObjectWidget
// ---------------------------------------------------------------------------

/// The widget that creates and configures [_RenderOiGrid].
class _OiGridLayout extends MultiChildRenderObjectWidget {
  const _OiGridLayout({
    required this.columns,
    required this.minColumnWidth,
    required this.gap,
    required this.rowGap,
    required super.children,
  });

  final int? columns;
  final double? minColumnWidth;
  final double gap;
  final double rowGap;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderOiGrid(
      columns: columns,
      minColumnWidth: minColumnWidth,
      gap: gap,
      rowGap: rowGap,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderOiGrid renderObject) {
    renderObject
      ..columns = columns
      ..minColumnWidth = minColumnWidth
      ..gap = gap
      ..rowGap = rowGap;
  }
}

// ---------------------------------------------------------------------------
// RenderBox — the layout engine
// ---------------------------------------------------------------------------

/// Custom render object that implements CSS Grid–style row-packing.
///
/// The resolved column count is calculated **once per layout pass** from
/// [constraints.maxWidth] and the [columns] / [minColumnWidth] configuration.
/// Children are placed into the first available cell that satisfies their
/// `columnSpan` and `columnStart` constraints, advancing to the next row
/// when the current row is full.
class _RenderOiGrid extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _OiGridParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _OiGridParentData> {
  _RenderOiGrid({
    required int? columns,
    required double? minColumnWidth,
    required double gap,
    required double rowGap,
  }) : _columns = columns,
       _minColumnWidth = minColumnWidth,
       _gap = gap,
       _rowGap = rowGap;

  // ── Properties ──────────────────────────────────────────────────────────

  int? get columns => _columns;
  int? _columns;
  set columns(int? value) {
    if (_columns == value) return;
    _columns = value;
    markNeedsLayout();
  }

  double? get minColumnWidth => _minColumnWidth;
  double? _minColumnWidth;
  set minColumnWidth(double? value) {
    if (_minColumnWidth == value) return;
    _minColumnWidth = value;
    markNeedsLayout();
  }

  double get gap => _gap;
  double _gap;
  set gap(double value) {
    if (_gap == value) return;
    _gap = value;
    markNeedsLayout();
  }

  double get rowGap => _rowGap;
  double _rowGap;
  set rowGap(double value) {
    if (_rowGap == value) return;
    _rowGap = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _OiGridParentData) {
      child.parentData = _OiGridParentData();
    }
  }

  // ── Column count resolution ─────────────────────────────────────────────

  /// Resolves the column count from the available [width].
  ///
  /// Called **once** at the start of each layout pass (REQ-1077).
  int _resolveColumnCount(double width) {
    if (_columns != null) return math.max(1, _columns!);
    if (_minColumnWidth != null && _minColumnWidth! > 0) {
      return math.max(1, (width / _minColumnWidth!).floor());
    }
    return 1;
  }

  // ── Layout ──────────────────────────────────────────────────────────────

  @override
  void performLayout() {
    if (firstChild == null) {
      size = constraints.constrain(Size.zero);
      return;
    }

    final hasBoundedWidth = constraints.hasBoundedWidth;

    if (!hasBoundedWidth) {
      _performUnboundedLayout();
      return;
    }

    final availableWidth = constraints.maxWidth;

    // REQ-1077: column count resolved once per layout pass.
    final cols = _resolveColumnCount(availableWidth);

    // Unit column width = (total − gaps) / cols.
    final unitWidth = cols <= 1
        ? availableWidth
        : (availableWidth - _gap * (cols - 1)) / cols;

    // Collect children with resolved span data from parentData.
    // Stable sort by columnOrder (null → 0, matching CSS Grid convention).
    final entries = _collectChildren(cols)..sort(_compareByOrder);

    // REQ-1076: CSS Grid row-packing algorithm.
    final placements = _packRows(entries, cols);

    // Determine row count.
    var rowCount = 0;
    for (final p in placements) {
      if (p.row >= rowCount) rowCount = p.row + 1;
    }
    if (rowCount == 0) rowCount = 1;

    // Layout each child with its computed width.
    final rowHeights = List<double>.filled(rowCount, 0);

    for (final p in placements) {
      final childWidth =
          p.effectiveSpan * unitWidth + math.max(0, p.effectiveSpan - 1) * _gap;

      p.renderBox.layout(
        BoxConstraints.tightFor(width: childWidth),
        parentUsesSize: true,
      );

      final childHeight = p.renderBox.size.height;
      if (childHeight > rowHeights[p.row]) {
        rowHeights[p.row] = childHeight;
      }
    }

    // Position children.
    for (final p in placements) {
      final pd = p.renderBox.parentData! as _OiGridParentData;
      final x = p.column * (unitWidth + _gap);
      var y = 0.0;
      for (var r = 0; r < p.row; r++) {
        y += rowHeights[r] + _rowGap;
      }
      pd.offset = Offset(x, y);
    }

    // Total height.
    var totalHeight = 0.0;
    for (var r = 0; r < rowCount; r++) {
      totalHeight += rowHeights[r];
      if (r < rowCount - 1) totalHeight += _rowGap;
    }

    size = constraints.constrain(Size(availableWidth, totalHeight));
  }

  /// Unbounded-width fallback (e.g. when placed inside a [Row]).
  ///
  /// Lays out children at their natural width and positions them using
  /// the same grid packing algorithm.
  void _performUnboundedLayout() {
    final cols = _columns != null ? math.max(1, _columns!) : 1;

    final entries = _collectChildren(cols)..sort(_compareByOrder);
    final placements = _packRows(entries, cols);

    // First pass: layout children unconstrained to get natural sizes.
    for (final p in placements) {
      p.renderBox.layout(const BoxConstraints(), parentUsesSize: true);
    }

    // Compute per-column max width.
    final colWidths = List<double>.filled(cols, 0);
    for (final p in placements) {
      if (p.effectiveSpan == 1) {
        final w = p.renderBox.size.width;
        if (w > colWidths[p.column]) colWidths[p.column] = w;
      }
    }

    // Compute row heights.
    var rowCount = 0;
    for (final p in placements) {
      if (p.row >= rowCount) rowCount = p.row + 1;
    }
    if (rowCount == 0) rowCount = 1;

    final rowHeights = List<double>.filled(rowCount, 0);
    for (final p in placements) {
      final h = p.renderBox.size.height;
      if (h > rowHeights[p.row]) rowHeights[p.row] = h;
    }

    // Position children.
    var totalWidth = 0.0;
    for (final p in placements) {
      final pd = p.renderBox.parentData! as _OiGridParentData;

      var x = 0.0;
      for (var c = 0; c < p.column; c++) {
        x += colWidths[c] + _gap;
      }

      var y = 0.0;
      for (var r = 0; r < p.row; r++) {
        y += rowHeights[r] + _rowGap;
      }

      pd.offset = Offset(x, y);

      final right = x + p.renderBox.size.width;
      if (right > totalWidth) totalWidth = right;
    }

    var totalHeight = 0.0;
    for (var r = 0; r < rowCount; r++) {
      totalHeight += rowHeights[r];
      if (r < rowCount - 1) totalHeight += _rowGap;
    }

    size = constraints.constrain(Size(totalWidth, totalHeight));
  }

  // ── Child collection ────────────────────────────────────────────────────

  /// Collects all children into a list with clamped span values.
  List<_ChildEntry> _collectChildren(int cols) {
    final entries = <_ChildEntry>[];
    var child = firstChild;
    while (child != null) {
      final pd = child.parentData! as _OiGridParentData;

      var colSpan = pd.columnSpan;
      if (colSpan == fullSpanSentinel) colSpan = cols;
      colSpan = colSpan.clamp(1, cols);

      entries.add(
        _ChildEntry(
          renderBox: child,
          index: pd.index,
          columnSpan: colSpan,
          columnStart: pd.columnStart,
          columnOrder: pd.columnOrder,
        ),
      );
      child = pd.nextSibling;
    }
    return entries;
  }

  /// Comparison for stable sort by columnOrder (null → 0).
  static int _compareByOrder(_ChildEntry a, _ChildEntry b) {
    final oa = a.columnOrder ?? 0;
    final ob = b.columnOrder ?? 0;
    if (oa != ob) return oa.compareTo(ob);
    return a.index.compareTo(b.index);
  }

  // ── CSS Grid row-packing ────────────────────────────────────────────────

  /// Classic CSS Grid row-packing algorithm.
  ///
  /// Walk children in order. For each child, find the first available cell
  /// that satisfies its [columnSpan] and [columnStart]. Advance to the next
  /// row when the current row is full.
  List<_Placement> _packRows(List<_ChildEntry> entries, int cols) {
    final placements = <_Placement>[];
    // Track occupied cells: row index → set of occupied column indices.
    final occupied = <int, Set<int>>{};

    bool canFit(int row, int startCol, int span) {
      if (startCol + span > cols) return false;
      final rowSet = occupied[row];
      if (rowSet == null) return true;
      for (var c = startCol; c < startCol + span; c++) {
        if (rowSet.contains(c)) return false;
      }
      return true;
    }

    void occupy(int row, int startCol, int span) {
      final rowSet = occupied.putIfAbsent(row, () => <int>{});
      for (var c = startCol; c < startCol + span; c++) {
        rowSet.add(c);
      }
    }

    for (final entry in entries) {
      final span = entry.columnSpan;
      final requestedStart = entry.columnStart;

      if (requestedStart != null) {
        // Explicit column start (1-indexed → 0-indexed).
        final startCol = (requestedStart - 1).clamp(0, cols - 1);
        final effectiveSpan = math.min(span, cols - startCol);

        // Find the first row where those cells are free.
        for (var row = 0; ; row++) {
          if (canFit(row, startCol, effectiveSpan)) {
            occupy(row, startCol, effectiveSpan);
            placements.add(
              _Placement(
                renderBox: entry.renderBox,
                row: row,
                column: startCol,
                effectiveSpan: effectiveSpan,
              ),
            );
            break;
          }
        }
      } else {
        // Auto-placement: scan rows top-to-bottom, columns left-to-right.
        var placed = false;
        for (var row = 0; !placed; row++) {
          for (var col = 0; col <= cols - span; col++) {
            if (canFit(row, col, span)) {
              occupy(row, col, span);
              placements.add(
                _Placement(
                  renderBox: entry.renderBox,
                  row: row,
                  column: col,
                  effectiveSpan: span,
                ),
              );
              placed = true;
              break;
            }
          }
        }
      }
    }

    return placements;
  }

  // ── Intrinsic sizes ─────────────────────────────────────────────────────

  @override
  double computeMinIntrinsicWidth(double height) {
    // The grid can shrink to a single column at its narrowest.
    var maxChildWidth = 0.0;
    var child = firstChild;
    while (child != null) {
      final w = child.getMinIntrinsicWidth(height);
      if (w > maxChildWidth) maxChildWidth = w;
      child = (child.parentData! as _OiGridParentData).nextSibling;
    }
    return maxChildWidth;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    // The grid wants to expand to fill available width.
    var maxChildWidth = 0.0;
    var child = firstChild;
    while (child != null) {
      final w = child.getMaxIntrinsicWidth(height);
      if (w > maxChildWidth) maxChildWidth = w;
      child = (child.parentData! as _OiGridParentData).nextSibling;
    }
    final cols = _columns ?? 1;
    return maxChildWidth * cols + _gap * math.max(0, cols - 1);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _computeIntrinsicHeight(width, useMin: true);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _computeIntrinsicHeight(width, useMin: false);
  }

  double _computeIntrinsicHeight(double width, {required bool useMin}) {
    if (firstChild == null) return 0;

    final cols = width.isFinite ? _resolveColumnCount(width) : 1;
    final unitWidth = (cols <= 1 || !width.isFinite)
        ? width
        : (width - _gap * (cols - 1)) / cols;

    final entries = _collectChildren(cols)..sort(_compareByOrder);
    final placements = _packRows(entries, cols);

    var rowCount = 0;
    for (final p in placements) {
      if (p.row >= rowCount) rowCount = p.row + 1;
    }
    if (rowCount == 0) return 0;

    final rowHeights = List<double>.filled(rowCount, 0);
    for (final p in placements) {
      final childWidth =
          p.effectiveSpan * unitWidth + math.max(0, p.effectiveSpan - 1) * _gap;

      final h = useMin
          ? p.renderBox.getMinIntrinsicHeight(childWidth)
          : p.renderBox.getMaxIntrinsicHeight(childWidth);

      if (h > rowHeights[p.row]) rowHeights[p.row] = h;
    }

    var totalHeight = 0.0;
    for (var r = 0; r < rowCount; r++) {
      totalHeight += rowHeights[r];
      if (r < rowCount - 1) totalHeight += _rowGap;
    }
    return totalHeight;
  }

  // ── Dry layout ──────────────────────────────────────────────────────────

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (firstChild == null) return constraints.constrain(Size.zero);

    if (!constraints.hasBoundedWidth) {
      // Dry layout for unbounded is impractical — return zero.
      return constraints.constrain(Size.zero);
    }

    final availableWidth = constraints.maxWidth;
    final cols = _resolveColumnCount(availableWidth);
    final unitWidth = cols <= 1
        ? availableWidth
        : (availableWidth - _gap * (cols - 1)) / cols;

    final entries = _collectChildren(cols)..sort(_compareByOrder);
    final placements = _packRows(entries, cols);

    var rowCount = 0;
    for (final p in placements) {
      if (p.row >= rowCount) rowCount = p.row + 1;
    }
    if (rowCount == 0) return constraints.constrain(Size(availableWidth, 0));

    final rowHeights = List<double>.filled(rowCount, 0);
    for (final p in placements) {
      final childWidth =
          p.effectiveSpan * unitWidth + math.max(0, p.effectiveSpan - 1) * _gap;

      final childSize = p.renderBox.getDryLayout(
        BoxConstraints.tightFor(width: childWidth),
      );
      if (childSize.height > rowHeights[p.row]) {
        rowHeights[p.row] = childSize.height;
      }
    }

    var totalHeight = 0.0;
    for (var r = 0; r < rowCount; r++) {
      totalHeight += rowHeights[r];
      if (r < rowCount - 1) totalHeight += _rowGap;
    }

    return constraints.constrain(Size(availableWidth, totalHeight));
  }

  // ── Hit testing & painting ──────────────────────────────────────────────

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

/// Collected child data for the placement algorithm.
class _ChildEntry {
  _ChildEntry({
    required this.renderBox,
    required this.index,
    required this.columnSpan,
    this.columnStart,
    this.columnOrder,
  });

  final RenderBox renderBox;
  final int index;
  final int columnSpan;
  final int? columnStart;
  final int? columnOrder;
}

/// A child placed on the grid at a specific row/column.
class _Placement {
  _Placement({
    required this.renderBox,
    required this.row,
    required this.column,
    required this.effectiveSpan,
  });

  final RenderBox renderBox;
  final int row;
  final int column;
  final int effectiveSpan;
}
