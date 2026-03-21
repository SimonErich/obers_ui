import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/oi_span.dart';

// ---------------------------------------------------------------------------
// OiContainerBreakpoint — InheritedWidget for container-relative grids
// ---------------------------------------------------------------------------

/// An [InheritedWidget] that propagates a container's width for
/// container-relative breakpoint resolution.
///
/// Published by the outermost [OiGrid.containerRelative] so that nested
/// container-relative grids use the same width for breakpoint resolution
/// (REQ-1089).
///
/// {@category Primitives}
class OiContainerBreakpoint extends InheritedWidget {
  /// Creates an [OiContainerBreakpoint] with the given container [width].
  const OiContainerBreakpoint({
    required this.width,
    required super.child,
    super.key,
  });

  /// The container width used for breakpoint resolution.
  final double width;

  /// Returns the container width from the nearest [OiContainerBreakpoint]
  /// ancestor, or null if none exists.
  static double? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<OiContainerBreakpoint>()
        ?.width;
  }

  @override
  bool updateShouldNotify(OiContainerBreakpoint oldWidget) {
    return width != oldWidget.width;
  }
}

// ---------------------------------------------------------------------------
// OiGrid
// ---------------------------------------------------------------------------

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
/// For container-relative grids, use [OiGrid.containerRelative] instead.
/// These grids resolve their breakpoint from layout constraints rather than
/// an explicit value, re-layout when their container resizes (REQ-1087),
/// and do not listen to [MediaQuery] (REQ-1088).
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
/// **Performance Architecture (REQ-1090/1091/1092):** Responsive values are
/// resolved inside the [RenderBox] during `performLayout`, not at the widget
/// level. This means a constraint change triggers only a relayout — not a
/// full widget-tree rebuild.
///
/// Internally uses a custom [RenderBox] with [ContainerRenderObjectMixin] for
/// column-start and column-span control without relying on [Wrap] or
/// [GridView].
///
/// {@category Primitives}
class OiGrid extends StatelessWidget {
  /// Creates an [OiGrid] with an explicit [breakpoint].
  const OiGrid({
    required OiBreakpoint this.breakpoint,
    required this.children,
    this.columns,
    this.minColumnWidth,
    this.gap = const OiResponsive<double>(0),
    this.rowGap,
    this.scale = OiBreakpointScale.defaultScale,
    super.key,
  }) : _containerRelative = false,
       assert(
         columns == null || minColumnWidth == null,
         'Provide either columns or minColumnWidth, not both.',
       );

  /// Creates a container-relative [OiGrid] that resolves its breakpoint
  /// from layout constraints instead of an explicit value.
  ///
  /// The grid re-layouts when its own constraints change (REQ-1087) and
  /// does **not** listen to [MediaQuery] — no unnecessary rebuilds when
  /// the window resizes but the grid's own width stays the same (REQ-1088).
  ///
  /// Nested container-relative grids use the outermost container-relative
  /// grid's width as their viewport for breakpoint resolution (REQ-1089).
  /// Non-container-relative grids inside a container-relative grid fall
  /// back to the real viewport via their explicit [breakpoint] parameter.
  const OiGrid.containerRelative({
    required this.children,
    this.columns,
    this.minColumnWidth,
    this.gap = const OiResponsive<double>(0),
    this.rowGap,
    this.scale = OiBreakpointScale.defaultScale,
    super.key,
  }) : breakpoint = null,
       _containerRelative = true,
       assert(
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

  /// The active breakpoint. Null when [_containerRelative] is true.
  ///
  /// For the default constructor this is required — resolve once at the
  /// layout level and pass down explicitly.
  final OiBreakpoint? breakpoint;

  /// Whether this grid resolves its breakpoint from layout constraints.
  final bool _containerRelative;

  /// The breakpoint scale used to resolve responsive values.
  ///
  /// Defaults to [OiBreakpointScale.defaultScale] (the standard 5-tier scale).
  /// Zero magic: no context lookup — pass an explicit scale if you use a
  /// custom breakpoint configuration.
  final OiBreakpointScale scale;

  /// The child widgets to place in the grid.
  final List<Widget> children;

  /// Whether this grid is container-relative.
  bool get containerRelative => _containerRelative;

  @override
  Widget build(BuildContext context) {
    if (_containerRelative) {
      return _buildContainerRelative(context);
    }
    return _buildGrid(breakpoint: breakpoint);
  }

  /// Builds a container-relative grid.
  ///
  /// Responsive value resolution is deferred to the render object's
  /// `performLayout` (REQ-1090/1091/1092). The widget layer only handles
  /// [OiContainerBreakpoint] propagation for nested grids (REQ-1089).
  Widget _buildContainerRelative(BuildContext context) {
    // REQ-1089: Check for an ancestor container-relative grid.
    final ancestorWidth = OiContainerBreakpoint.maybeOf(context);

    final grid = _buildGrid(
      containerRelative: true,
      ancestorContainerWidth: ancestorWidth,
    );

    // Only the outermost container-relative grid publishes its width
    // via OiContainerBreakpoint so nested grids share the same viewport.
    if (ancestorWidth == null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return OiContainerBreakpoint(
            width: constraints.maxWidth,
            child: grid,
          );
        },
      );
    }
    return grid;
  }

  /// Builds the grid internals, passing responsive values through to the
  /// render object for resolution during layout (REQ-1090/1091/1092).
  Widget _buildGrid({
    OiBreakpoint? breakpoint,
    bool containerRelative = false,
    double? ancestorContainerWidth,
  }) {
    // Wrap each child in a _OiGridSlot ParentDataWidget carrying the
    // responsive span metadata. The render object resolves these during
    // performLayout — no per-child widget rebuilds on breakpoint change.
    final wrappedChildren = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final spanData = OiSpan.maybeOf(child);

      wrappedChildren.add(
        _OiGridSlot(
          index: i,
          responsiveColumnSpan: spanData?.columnSpan,
          responsiveColumnStart: spanData?.columnStart,
          responsiveColumnOrder: spanData?.columnOrder,
          responsiveRowSpan: spanData?.rowSpan,
          child: child,
        ),
      );
    }

    return _OiGridLayout(
      columns: columns,
      minColumnWidth: minColumnWidth,
      gap: gap,
      rowGap: rowGap,
      scale: scale,
      breakpoint: breakpoint,
      containerRelative: containerRelative,
      ancestorContainerWidth: ancestorContainerWidth,
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

  /// Responsive column span. Resolved during `performLayout`.
  OiResponsive<int>? responsiveColumnSpan;

  /// Responsive column start. Resolved during `performLayout`.
  OiResponsive<int>? responsiveColumnStart;

  /// Responsive column order. Resolved during `performLayout`.
  OiResponsive<int>? responsiveColumnOrder;

  /// Responsive row span. Resolved during `performLayout`.
  OiResponsive<int>? responsiveRowSpan;
}

// ---------------------------------------------------------------------------
// ParentDataWidget — sets span metadata on each child
// ---------------------------------------------------------------------------

/// Applies responsive [OiSpanData] to the child's [_OiGridParentData].
///
/// Span values are stored as [OiResponsive] objects and resolved by the
/// render object during layout (REQ-1092), eliminating widget-level
/// resolution overhead.
class _OiGridSlot extends ParentDataWidget<_OiGridParentData> {
  const _OiGridSlot({
    required this.index,
    required this.responsiveColumnSpan,
    required this.responsiveColumnStart,
    required this.responsiveColumnOrder,
    required this.responsiveRowSpan,
    required super.child,
  });

  final int index;
  final OiResponsive<int>? responsiveColumnSpan;
  final OiResponsive<int>? responsiveColumnStart;
  final OiResponsive<int>? responsiveColumnOrder;
  final OiResponsive<int>? responsiveRowSpan;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData! as _OiGridParentData;
    var needsLayout = false;

    if (parentData.index != index) {
      parentData.index = index;
      needsLayout = true;
    }
    if (parentData.responsiveColumnSpan != responsiveColumnSpan) {
      parentData.responsiveColumnSpan = responsiveColumnSpan;
      needsLayout = true;
    }
    if (parentData.responsiveColumnStart != responsiveColumnStart) {
      parentData.responsiveColumnStart = responsiveColumnStart;
      needsLayout = true;
    }
    if (parentData.responsiveColumnOrder != responsiveColumnOrder) {
      parentData.responsiveColumnOrder = responsiveColumnOrder;
      needsLayout = true;
    }
    if (parentData.responsiveRowSpan != responsiveRowSpan) {
      parentData.responsiveRowSpan = responsiveRowSpan;
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
///
/// Passes responsive values through to the render object for resolution
/// during layout (REQ-1090/1091/1092).
class _OiGridLayout extends MultiChildRenderObjectWidget {
  const _OiGridLayout({
    required this.columns,
    required this.minColumnWidth,
    required this.gap,
    required this.rowGap,
    required this.scale,
    required this.breakpoint,
    required this.containerRelative,
    required this.ancestorContainerWidth,
    required super.children,
  });

  final OiResponsive<int>? columns;
  final OiResponsive<double>? minColumnWidth;
  final OiResponsive<double> gap;
  final OiResponsive<double>? rowGap;
  final OiBreakpointScale scale;
  final OiBreakpoint? breakpoint;
  final bool containerRelative;
  final double? ancestorContainerWidth;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderOiGrid(
      columns: columns,
      minColumnWidth: minColumnWidth,
      gap: gap,
      rowGap: rowGap,
      scale: scale,
      breakpoint: breakpoint,
      containerRelative: containerRelative,
      ancestorContainerWidth: ancestorContainerWidth,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderOiGrid renderObject) {
    renderObject
      ..columns = columns
      ..minColumnWidth = minColumnWidth
      ..gap = gap
      ..rowGap = rowGap
      ..scale = scale
      ..breakpoint = breakpoint
      ..containerRelative = containerRelative
      ..ancestorContainerWidth = ancestorContainerWidth;
  }
}

// ---------------------------------------------------------------------------
// RenderBox — the layout engine
// ---------------------------------------------------------------------------

/// Custom render object that implements CSS Grid–style row-packing.
///
/// **Performance Architecture (REQ-1090/1091/1092):**
///
/// 1. **REQ-1090** — Receives `constraints` in `performLayout()`.
/// 2. **REQ-1091** — Resolves the breakpoint from constraints
///    (container-relative) or uses the cached viewport breakpoint.
/// 3. **REQ-1092** — Resolves all responsive values (columns, gaps, and
///    per-child spans) during layout, not at the widget level.
///
/// This architecture means a constraint change triggers only a relayout —
/// not a full widget-tree rebuild. Widget-level code passes responsive
/// [OiResponsive] objects through; the render object resolves them using
/// the active breakpoint computed from its own constraints.
class _RenderOiGrid extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _OiGridParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _OiGridParentData> {
  _RenderOiGrid({
    required OiResponsive<int>? columns,
    required OiResponsive<double>? minColumnWidth,
    required OiResponsive<double> gap,
    required OiResponsive<double>? rowGap,
    required OiBreakpointScale scale,
    required OiBreakpoint? breakpoint,
    required bool containerRelative,
    required double? ancestorContainerWidth,
  }) : _columns = columns,
       _minColumnWidth = minColumnWidth,
       _gap = gap,
       _rowGap = rowGap,
       _scale = scale,
       _breakpoint = breakpoint,
       _containerRelative = containerRelative,
       _ancestorContainerWidth = ancestorContainerWidth;

  // ── Responsive properties ─────────────────────────────────────────────

  OiResponsive<int>? get columns => _columns;
  OiResponsive<int>? _columns;
  set columns(OiResponsive<int>? value) {
    if (_columns == value) return;
    _columns = value;
    markNeedsLayout();
  }

  OiResponsive<double>? get minColumnWidth => _minColumnWidth;
  OiResponsive<double>? _minColumnWidth;
  set minColumnWidth(OiResponsive<double>? value) {
    if (_minColumnWidth == value) return;
    _minColumnWidth = value;
    markNeedsLayout();
  }

  OiResponsive<double> get gap => _gap;
  OiResponsive<double> _gap;
  set gap(OiResponsive<double> value) {
    if (_gap == value) return;
    _gap = value;
    markNeedsLayout();
  }

  OiResponsive<double>? get rowGap => _rowGap;
  OiResponsive<double>? _rowGap;
  set rowGap(OiResponsive<double>? value) {
    if (_rowGap == value) return;
    _rowGap = value;
    markNeedsLayout();
  }

  // ── Breakpoint properties ─────────────────────────────────────────────

  OiBreakpointScale get scale => _scale;
  OiBreakpointScale _scale;
  set scale(OiBreakpointScale value) {
    if (_scale == value) return;
    _scale = value;
    markNeedsLayout();
  }

  OiBreakpoint? get breakpoint => _breakpoint;
  OiBreakpoint? _breakpoint;
  set breakpoint(OiBreakpoint? value) {
    if (_breakpoint == value) return;
    _breakpoint = value;
    markNeedsLayout();
  }

  bool get containerRelative => _containerRelative;
  bool _containerRelative;
  set containerRelative(bool value) {
    if (_containerRelative == value) return;
    _containerRelative = value;
    markNeedsLayout();
  }

  double? get ancestorContainerWidth => _ancestorContainerWidth;
  double? _ancestorContainerWidth;
  set ancestorContainerWidth(double? value) {
    if (_ancestorContainerWidth == value) return;
    _ancestorContainerWidth = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _OiGridParentData) {
      child.parentData = _OiGridParentData();
    }
  }

  // ── Breakpoint resolution (REQ-1091) ──────────────────────────────────

  /// Resolves the active breakpoint from [width].
  ///
  /// REQ-1091: For container-relative grids, uses [ancestorContainerWidth]
  /// (if available) or the given [width] from constraints. For viewport-based
  /// grids, returns the cached [breakpoint].
  OiBreakpoint _resolveActiveBreakpoint(double width) {
    if (!_containerRelative) return _breakpoint!;
    final effectiveWidth = _ancestorContainerWidth ?? width;
    if (!effectiveWidth.isFinite) return _scale.values.first;
    return _scale.resolve(effectiveWidth);
  }

  // ── Column count resolution ─────────────────────────────────────────────

  /// Resolves the column count from the available [width] and resolved layout
  /// values.
  ///
  /// Called **once** at the start of each layout pass (REQ-1077).
  static int _resolveColumnCount(
    double width,
    int? resolvedColumns,
    double? resolvedMinColumnWidth,
  ) {
    if (resolvedColumns != null) return math.max(1, resolvedColumns);
    if (resolvedMinColumnWidth != null && resolvedMinColumnWidth > 0) {
      return math.max(1, (width / resolvedMinColumnWidth).floor());
    }
    return 1;
  }

  // ── Layout (REQ-1090) ─────────────────────────────────────────────────

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

    // REQ-1090: Receives constraints in performLayout().
    final availableWidth = constraints.maxWidth;

    // REQ-1091: Resolve the breakpoint from constraints (container-relative)
    // or cached viewport breakpoint.
    final active = _resolveActiveBreakpoint(availableWidth);

    // REQ-1092: Resolve all responsive values (columns, gaps).
    final resolvedGap = _gap.resolve(active, _scale);
    final effectiveRowGap = _rowGap?.resolve(active, _scale) ?? resolvedGap;
    final resolvedColumns = _columns?.resolve(active, _scale);
    final resolvedMinColumnWidth = _minColumnWidth?.resolve(active, _scale);

    // REQ-1077: column count resolved once per layout pass.
    final cols = _resolveColumnCount(
      availableWidth,
      resolvedColumns,
      resolvedMinColumnWidth,
    );

    // Unit column width = (total − gaps) / cols.
    final unitWidth = cols <= 1
        ? availableWidth
        : (availableWidth - resolvedGap * (cols - 1)) / cols;

    // REQ-1092 + REQ-1079: Collect children (resolving per-child spans)
    // and sort by columnOrder (null → 0).
    final entries = _collectChildren(cols, active)..sort(_compareByOrder);

    // REQ-1076: CSS Grid row-packing algorithm.
    final placements = _packRows(entries, cols);

    // Determine row count (accounts for rowSpan).
    var rowCount = 0;
    for (final p in placements) {
      final lastRow = p.row + p.rowSpan;
      if (lastRow > rowCount) rowCount = lastRow;
    }
    if (rowCount == 0) rowCount = 1;

    // First pass: layout each child with its computed width.
    for (final p in placements) {
      final childWidth =
          p.effectiveSpan * unitWidth +
          math.max(0, p.effectiveSpan - 1) * resolvedGap;

      p.renderBox.layout(
        BoxConstraints.tightFor(width: childWidth),
        parentUsesSize: true,
      );
    }

    // Compute row heights — single-row children contribute directly;
    // multi-row children are distributed after single-row heights are known.
    final rowHeights = List<double>.filled(rowCount, 0);

    // Pass 1: single-row children set initial row heights.
    for (final p in placements) {
      if (p.rowSpan == 1) {
        final h = p.renderBox.size.height;
        if (h > rowHeights[p.row]) rowHeights[p.row] = h;
      }
    }

    // Pass 2: multi-row children — ensure the spanned rows can accommodate.
    for (final p in placements) {
      if (p.rowSpan <= 1) continue;
      final childHeight = p.renderBox.size.height;
      // Sum of the rows this child spans + intermediate row gaps.
      var spannedHeight = 0.0;
      for (var r = p.row; r < p.row + p.rowSpan; r++) {
        spannedHeight += rowHeights[r];
        if (r < p.row + p.rowSpan - 1) spannedHeight += effectiveRowGap;
      }
      if (childHeight > spannedHeight) {
        // Distribute extra height evenly across spanned rows.
        final extra = childHeight - spannedHeight;
        final perRow = extra / p.rowSpan;
        for (var r = p.row; r < p.row + p.rowSpan; r++) {
          rowHeights[r] += perRow;
        }
      }
    }

    // Position children.
    for (final p in placements) {
      final pd = p.renderBox.parentData! as _OiGridParentData;
      final x = p.column * (unitWidth + resolvedGap);
      var y = 0.0;
      for (var r = 0; r < p.row; r++) {
        y += rowHeights[r] + effectiveRowGap;
      }
      pd.offset = Offset(x, y);
    }

    // Total height.
    var totalHeight = 0.0;
    for (var r = 0; r < rowCount; r++) {
      totalHeight += rowHeights[r];
      if (r < rowCount - 1) totalHeight += effectiveRowGap;
    }

    size = constraints.constrain(Size(availableWidth, totalHeight));
  }

  /// Unbounded-width fallback (e.g. when placed inside a [Row]).
  ///
  /// Lays out children at their natural width and positions them using
  /// the same grid packing algorithm.
  void _performUnboundedLayout() {
    // REQ-1091: Resolve breakpoint.
    final active = _resolveActiveBreakpoint(double.infinity);

    // REQ-1092: Resolve responsive values.
    final resolvedGap = _gap.resolve(active, _scale);
    final effectiveRowGap = _rowGap?.resolve(active, _scale) ?? resolvedGap;
    final resolvedColumns = _columns?.resolve(active, _scale);

    final cols = resolvedColumns != null ? math.max(1, resolvedColumns) : 1;

    // REQ-1092: Collect children with resolved per-child spans.
    final entries = _collectChildren(cols, active)..sort(_compareByOrder);
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

    // Compute row heights (rowSpan-aware).
    var rowCount = 0;
    for (final p in placements) {
      final lastRow = p.row + p.rowSpan;
      if (lastRow > rowCount) rowCount = lastRow;
    }
    if (rowCount == 0) rowCount = 1;

    final rowHeights = List<double>.filled(rowCount, 0);
    for (final p in placements) {
      if (p.rowSpan == 1) {
        final h = p.renderBox.size.height;
        if (h > rowHeights[p.row]) rowHeights[p.row] = h;
      }
    }
    for (final p in placements) {
      if (p.rowSpan <= 1) continue;
      final childHeight = p.renderBox.size.height;
      var spannedHeight = 0.0;
      for (var r = p.row; r < p.row + p.rowSpan; r++) {
        spannedHeight += rowHeights[r];
        if (r < p.row + p.rowSpan - 1) spannedHeight += effectiveRowGap;
      }
      if (childHeight > spannedHeight) {
        final extra = childHeight - spannedHeight;
        final perRow = extra / p.rowSpan;
        for (var r = p.row; r < p.row + p.rowSpan; r++) {
          rowHeights[r] += perRow;
        }
      }
    }

    // Position children.
    var totalWidth = 0.0;
    for (final p in placements) {
      final pd = p.renderBox.parentData! as _OiGridParentData;

      var x = 0.0;
      for (var c = 0; c < p.column; c++) {
        x += colWidths[c] + resolvedGap;
      }

      var y = 0.0;
      for (var r = 0; r < p.row; r++) {
        y += rowHeights[r] + effectiveRowGap;
      }

      pd.offset = Offset(x, y);

      final right = x + p.renderBox.size.width;
      if (right > totalWidth) totalWidth = right;
    }

    var totalHeight = 0.0;
    for (var r = 0; r < rowCount; r++) {
      totalHeight += rowHeights[r];
      if (r < rowCount - 1) totalHeight += effectiveRowGap;
    }

    size = constraints.constrain(Size(totalWidth, totalHeight));
  }

  // ── Child collection (REQ-1092) ───────────────────────────────────────

  /// Collects all children into a list, resolving responsive span values
  /// inline using the [active] breakpoint.
  ///
  /// REQ-1092: Per-child responsive spans are resolved here during layout,
  /// not at the widget level. This method has no side effects on parentData.
  /// REQ-1080: Resolves columnSpan — default 1, [fullSpanSentinel] → [cols].
  List<_ChildEntry> _collectChildren(int cols, OiBreakpoint active) {
    final entries = <_ChildEntry>[];
    var child = firstChild;
    while (child != null) {
      final pd = child.parentData! as _OiGridParentData;

      // REQ-1092 + REQ-1080: Resolve responsive columnSpan.
      var colSpan = pd.responsiveColumnSpan?.resolve(active, _scale) ?? 1;
      if (colSpan == fullSpanSentinel) colSpan = cols;
      colSpan = colSpan.clamp(1, cols);

      // REQ-1092 + REQ-1084: Resolve responsive rowSpan.
      final rSpan = math.max(
        1,
        pd.responsiveRowSpan?.resolve(active, _scale) ?? 1,
      );

      entries.add(
        _ChildEntry(
          renderBox: child,
          index: pd.index,
          columnSpan: colSpan,
          rowSpan: rSpan,
          columnStart: pd.responsiveColumnStart?.resolve(active, _scale),
          columnOrder: pd.responsiveColumnOrder?.resolve(active, _scale),
        ),
      );
      child = pd.nextSibling;
    }
    return entries;
  }

  /// REQ-1079: Comparison for stable sort by columnOrder (null → 0).
  static int _compareByOrder(_ChildEntry a, _ChildEntry b) {
    final oa = a.columnOrder ?? 0;
    final ob = b.columnOrder ?? 0;
    if (oa != ob) return oa.compareTo(ob);
    return a.index.compareTo(b.index);
  }

  // ── CSS Grid row-packing ────────────────────────────────────────────────

  /// CSS Grid row-packing algorithm with explicit cursor tracking.
  ///
  /// REQ-1078: Maintains a cursor `(row, column)` starting at `(0, 0)`.
  /// REQ-1079: Processes children sorted by columnOrder.
  /// REQ-1080: Uses resolved columnSpan (default 1, sentinel → all cols).
  ///
  /// For each child, find the first available cell that satisfies its
  /// columnSpan and columnStart. The cursor advances forward after each
  /// auto-placed child and never scans backward.
  List<_Placement> _packRows(List<_ChildEntry> entries, int cols) {
    final placements = <_Placement>[];
    // Track occupied cells: row index → set of occupied column indices.
    final occupied = <int, Set<int>>{};

    // REQ-1078: Maintain a cursor (row, column) starting at (0, 0).
    var cursorRow = 0;
    var cursorCol = 0;

    bool canFit(int row, int startCol, int colSpan, int rowSpan) {
      if (startCol + colSpan > cols) return false;
      for (var r = row; r < row + rowSpan; r++) {
        final rowSet = occupied[r];
        if (rowSet == null) continue;
        for (var c = startCol; c < startCol + colSpan; c++) {
          if (rowSet.contains(c)) return false;
        }
      }
      return true;
    }

    void occupy(int row, int startCol, int colSpan, int rowSpan) {
      for (var r = row; r < row + rowSpan; r++) {
        final rowSet = occupied.putIfAbsent(r, () => <int>{});
        for (var c = startCol; c < startCol + colSpan; c++) {
          rowSet.add(c);
        }
      }
    }

    // REQ-1079: For each child (sorted by columnOrder if specified).
    for (final entry in entries) {
      // REQ-1080: columnSpan already resolved (default 1, sentinel → cols).
      final span = entry.columnSpan;
      // REQ-1084: rowSpan already resolved (default 1, minimum 1).
      final rSpan = entry.rowSpan;
      final requestedStart = entry.columnStart;

      if (requestedStart != null) {
        // Explicit column start (1-indexed → 0-indexed).
        final startCol = (requestedStart - 1).clamp(0, cols - 1);
        final effectiveSpan = math.min(span, cols - startCol);

        // Find the first row where those cells are free.
        for (var row = 0; ; row++) {
          if (canFit(row, startCol, effectiveSpan, rSpan)) {
            occupy(row, startCol, effectiveSpan, rSpan);
            placements.add(
              _Placement(
                renderBox: entry.renderBox,
                row: row,
                column: startCol,
                effectiveSpan: effectiveSpan,
                rowSpan: rSpan,
              ),
            );
            break;
          }
        }
      } else {
        // Auto-placement: scan forward from cursor position.
        var row = cursorRow;
        var col = cursorCol;

        while (true) {
          if (col + span > cols) {
            // Span doesn't fit in remaining columns — advance to next row.
            row++;
            col = 0;
            continue;
          }
          if (canFit(row, col, span, rSpan)) {
            occupy(row, col, span, rSpan);
            placements.add(
              _Placement(
                renderBox: entry.renderBox,
                row: row,
                column: col,
                effectiveSpan: span,
                rowSpan: rSpan,
              ),
            );
            // Advance cursor past this placement.
            cursorCol = col + span;
            cursorRow = row;
            if (cursorCol >= cols) {
              cursorRow++;
              cursorCol = 0;
            }
            break;
          } else {
            col++;
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
    // Resolve responsive column count for intrinsic computation.
    final active = _resolveActiveBreakpoint(double.infinity);
    final resolvedCols = _columns?.resolve(active, _scale) ?? 1;
    final resolvedGap = _gap.resolve(active, _scale);

    var maxChildWidth = 0.0;
    var child = firstChild;
    while (child != null) {
      final w = child.getMaxIntrinsicWidth(height);
      if (w > maxChildWidth) maxChildWidth = w;
      child = (child.parentData! as _OiGridParentData).nextSibling;
    }
    return maxChildWidth * resolvedCols +
        resolvedGap * math.max(0, resolvedCols - 1);
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

    // REQ-1091/1092: Resolve breakpoint and responsive values for intrinsics.
    final active = _resolveActiveBreakpoint(width);
    final resolvedGap = _gap.resolve(active, _scale);
    final effectiveRowGap = _rowGap?.resolve(active, _scale) ?? resolvedGap;
    final resolvedColumns = _columns?.resolve(active, _scale);
    final resolvedMinColumnWidth = _minColumnWidth?.resolve(active, _scale);

    final cols = width.isFinite
        ? _resolveColumnCount(width, resolvedColumns, resolvedMinColumnWidth)
        : 1;
    final unitWidth = (cols <= 1 || !width.isFinite)
        ? width
        : (width - resolvedGap * (cols - 1)) / cols;

    final entries = _collectChildren(cols, active)..sort(_compareByOrder);
    final placements = _packRows(entries, cols);

    var rowCount = 0;
    for (final p in placements) {
      final lastRow = p.row + p.rowSpan;
      if (lastRow > rowCount) rowCount = lastRow;
    }
    if (rowCount == 0) return 0;

    final rowHeights = List<double>.filled(rowCount, 0);
    // Pass 1: single-row children.
    for (final p in placements) {
      if (p.rowSpan != 1) continue;
      final childWidth =
          p.effectiveSpan * unitWidth +
          math.max(0, p.effectiveSpan - 1) * resolvedGap;

      final h = useMin
          ? p.renderBox.getMinIntrinsicHeight(childWidth)
          : p.renderBox.getMaxIntrinsicHeight(childWidth);

      if (h > rowHeights[p.row]) rowHeights[p.row] = h;
    }
    // Pass 2: multi-row children.
    for (final p in placements) {
      if (p.rowSpan <= 1) continue;
      final childWidth =
          p.effectiveSpan * unitWidth +
          math.max(0, p.effectiveSpan - 1) * resolvedGap;

      final h = useMin
          ? p.renderBox.getMinIntrinsicHeight(childWidth)
          : p.renderBox.getMaxIntrinsicHeight(childWidth);

      var spannedHeight = 0.0;
      for (var r = p.row; r < p.row + p.rowSpan; r++) {
        spannedHeight += rowHeights[r];
        if (r < p.row + p.rowSpan - 1) spannedHeight += effectiveRowGap;
      }
      if (h > spannedHeight) {
        final extra = h - spannedHeight;
        final perRow = extra / p.rowSpan;
        for (var r = p.row; r < p.row + p.rowSpan; r++) {
          rowHeights[r] += perRow;
        }
      }
    }

    var totalHeight = 0.0;
    for (var r = 0; r < rowCount; r++) {
      totalHeight += rowHeights[r];
      if (r < rowCount - 1) totalHeight += effectiveRowGap;
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

    // REQ-1091/1092: Resolve breakpoint and responsive values for dry layout.
    final active = _resolveActiveBreakpoint(availableWidth);
    final resolvedGap = _gap.resolve(active, _scale);
    final effectiveRowGap = _rowGap?.resolve(active, _scale) ?? resolvedGap;
    final resolvedColumns = _columns?.resolve(active, _scale);
    final resolvedMinColumnWidth = _minColumnWidth?.resolve(active, _scale);

    final cols = _resolveColumnCount(
      availableWidth,
      resolvedColumns,
      resolvedMinColumnWidth,
    );
    final unitWidth = cols <= 1
        ? availableWidth
        : (availableWidth - resolvedGap * (cols - 1)) / cols;

    final entries = _collectChildren(cols, active)..sort(_compareByOrder);
    final placements = _packRows(entries, cols);

    var rowCount = 0;
    for (final p in placements) {
      final lastRow = p.row + p.rowSpan;
      if (lastRow > rowCount) rowCount = lastRow;
    }
    if (rowCount == 0) return constraints.constrain(Size(availableWidth, 0));

    final rowHeights = List<double>.filled(rowCount, 0);
    // Pass 1: single-row children.
    for (final p in placements) {
      if (p.rowSpan != 1) continue;
      final childWidth =
          p.effectiveSpan * unitWidth +
          math.max(0, p.effectiveSpan - 1) * resolvedGap;

      final childSize = p.renderBox.getDryLayout(
        BoxConstraints.tightFor(width: childWidth),
      );
      if (childSize.height > rowHeights[p.row]) {
        rowHeights[p.row] = childSize.height;
      }
    }
    // Pass 2: multi-row children.
    for (final p in placements) {
      if (p.rowSpan <= 1) continue;
      final childWidth =
          p.effectiveSpan * unitWidth +
          math.max(0, p.effectiveSpan - 1) * resolvedGap;

      final childSize = p.renderBox.getDryLayout(
        BoxConstraints.tightFor(width: childWidth),
      );
      var spannedHeight = 0.0;
      for (var r = p.row; r < p.row + p.rowSpan; r++) {
        spannedHeight += rowHeights[r];
        if (r < p.row + p.rowSpan - 1) spannedHeight += effectiveRowGap;
      }
      if (childSize.height > spannedHeight) {
        final extra = childSize.height - spannedHeight;
        final perRow = extra / p.rowSpan;
        for (var r = p.row; r < p.row + p.rowSpan; r++) {
          rowHeights[r] += perRow;
        }
      }
    }

    var totalHeight = 0.0;
    for (var r = 0; r < rowCount; r++) {
      totalHeight += rowHeights[r];
      if (r < rowCount - 1) totalHeight += effectiveRowGap;
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
    required this.rowSpan,
    this.columnStart,
    this.columnOrder,
  });

  final RenderBox renderBox;
  final int index;
  final int columnSpan;
  final int rowSpan;
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
    required this.rowSpan,
  });

  final RenderBox renderBox;
  final int row;
  final int column;
  final int effectiveSpan;
  final int rowSpan;
}
