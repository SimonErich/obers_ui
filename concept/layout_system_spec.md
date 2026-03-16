# obers_ui — Responsive Layout System Specification

> **Date:** 2026-03-16
> **Extends:** `base_concept.md`
> **Scope:** Responsive grid, flex, section, and page layout primitives + extensible breakpoint system.
> **Tier:** Foundation (breakpoints) + Primitives (layout widgets)
> **Principle:** Layout is declarative. Responsiveness is a first-class prop, not an afterthought. Every layout widget speaks the same responsive language.

---

## Table of Contents

- [Motivation & Design Goals](#motivation--design-goals)
- [Part 1: Extensible Breakpoint System](#part-1-extensible-breakpoint-system)
- [Part 2: The Responsive Value Type](#part-2-the-responsive-value-type)
- [Part 3: Layout Primitives](#part-3-layout-primitives)
  - [Enhanced OiRow / OiColumn](#enhanced-oirow--oicolumn)
  - [Enhanced OiGrid](#enhanced-oigrid)
  - [OiSection](#oisection)
  - [OiFlex](#oiflex)
  - [OiFieldset](#oifieldset)
  - [OiPage](#oipage)
  - [Responsive Visibility: OiShow / OiHide](#responsive-visibility-oishow--oihide)
- [Part 4: The Span System — Universal Child Positioning](#part-4-the-span-system)
- [Part 5: Container-Relative Layouts](#part-5-container-relative-layouts)
- [Part 6: Performance Architecture](#part-6-performance-architecture)
- [Part 7: Theme Integration](#part-7-theme-integration)
- [Part 8: Package Structure](#part-8-package-structure)
- [Part 9: Usage Examples](#part-9-usage-examples)
- [Part 10: Tests](#part-10-tests)

---

# Motivation & Design Goals

Flutter gives you `Row`, `Column`, `Wrap`, `GridView`, and `LayoutBuilder`. These are powerful but low-level. Building a responsive admin form, dashboard, or settings page requires repetitive boilerplate: check breakpoint → pick column count → calculate widths → wrap in `LayoutBuilder` → rebuild everything.

Filament (PHP) solves this beautifully for the web with its grid/section/flex system. Every layout component has `columns()`, and every child has `columnSpan()`, both accepting responsive breakpoint maps. The result: complex responsive layouts in a few lines of declarative code.

We want this power in Flutter — but adapted to be idiomatic, type-safe, and performant.

**Design goals:**

1. **Declarative responsive props.** Any layout property that should vary by screen size accepts an `OiResponsive<T>` value. One type, one pattern, everywhere.
2. **Extensible breakpoints.** The 5 default breakpoints (`compact`, `medium`, `expanded`, `large`, `extraLarge`) are defined in the theme and can be extended with custom names. No hard-coded enum — a registry.
3. **Span system.** Every child inside a grid-aware parent can declare `columnSpan`, `columnStart`, and `columnOrder` — all responsive. This is a universal contract, not per-widget.
4. **Container queries.** Layouts can measure their own width instead of the viewport, so a grid inside a collapsible sidebar adapts to *its* available space.
5. **Minimal rebuilds.** Breakpoint changes use `InheritedWidget` + fine-grained `shouldNotify`. Layout calculations use `CustomMultiChildLayout` or `RenderBox` directly — no `setState` chains.
6. **Nestable.** Grids inside sections inside flex inside pages. Every layout widget composes with every other. No special rules about what can go where.
7. **Accessible.** `OiSection` has semantic landmarks. Collapsible sections announce state. Visibility changes don't remove from semantics tree unless explicitly told to.
8. **Zero magic.** No context lookups that fail silently. No implicit inheritance of column counts. Every layout widget is self-contained with explicit props. The responsive value is resolved once at the layout level and passed down as concrete values.

---

# Part 1: Extensible Breakpoint System

## Replacing the Enum

The current `OiBreakpoint` enum is closed — you can't add project-specific breakpoints like `tablet`, `wideDesktop`, or `ultraWide`. We replace it with an open, ordered registry defined in the theme.

```dart
/// A named breakpoint with a minimum width threshold.
///
/// Breakpoints are ordered by [minWidth]. The active breakpoint
/// is the largest one whose [minWidth] is <= the current width.
@immutable
class OiBreakpoint implements Comparable<OiBreakpoint> {
  const OiBreakpoint(this.name, this.minWidth);

  /// Human-readable name. Used as the key in [OiResponsive] maps.
  final String name;

  /// Minimum viewport/container width in logical pixels.
  final double minWidth;

  @override
  int compareTo(OiBreakpoint other) => minWidth.compareTo(other.minWidth);

  // Standard breakpoints — accessible as constants for convenience.
  static const compact    = OiBreakpoint('compact', 0);
  static const medium     = OiBreakpoint('medium', 600);
  static const expanded   = OiBreakpoint('expanded', 840);
  static const large      = OiBreakpoint('large', 1200);
  static const extraLarge = OiBreakpoint('extraLarge', 1600);
}
```

## Breakpoint Scale in the Theme

```dart
/// Defines the breakpoint scale for the entire application.
///
/// Stored in [OiThemeData.breakpoints]. Sorted automatically on creation.
/// The first entry must always have minWidth == 0 (the base/default).
@immutable
class OiBreakpointScale {
  /// Creates a breakpoint scale from an unsorted list.
  /// Throws if no breakpoint has minWidth == 0.
  factory OiBreakpointScale(List<OiBreakpoint> breakpoints);

  /// The default 5-tier scale matching Material 3 guidelines.
  factory OiBreakpointScale.standard();

  /// Extended scale — adds `tablet` (480) and `ultraWide` (1920).
  factory OiBreakpointScale.extended();

  /// The sorted list of breakpoints, ascending by minWidth.
  final List<OiBreakpoint> values;

  /// Returns the active breakpoint for the given [width].
  ///
  /// Walks the sorted list in reverse, returning the first
  /// breakpoint whose minWidth <= width.
  OiBreakpoint resolve(double width);

  /// Returns the index of the active breakpoint.
  int resolveIndex(double width);
}
```

**Theme integration:**

```dart
class OiThemeData {
  // ... existing fields ...
  final OiBreakpointScale breakpoints; // ★ NEW — defaults to OiBreakpointScale.standard()
}
```

**Context extension (replaces old `OiResponsiveExt`):**

```dart
extension OiResponsiveExt on BuildContext {
  OiBreakpointScale get breakpointScale => theme.breakpoints;
  OiBreakpoint get breakpoint => breakpointScale.resolve(_viewportWidth);
  double get viewportWidth => MediaQuery.sizeOf(this).width;

  /// Resolves a responsive value for the current viewport breakpoint.
  T responsive<T>(OiResponsive<T> values) => values.resolve(breakpoint, breakpointScale);

  // Convenience getters remain:
  bool get isCompact => breakpoint == OiBreakpoint.compact;
  bool get isMedium => breakpoint == OiBreakpoint.medium;
  bool get isExpanded => breakpoint == OiBreakpoint.expanded;
  bool get isLarge => breakpoint == OiBreakpoint.large;
  bool get isExtraLarge => breakpoint == OiBreakpoint.extraLarge;
  bool get isLargeOrWider => breakpoint.minWidth >= OiBreakpoint.large.minWidth;
}
```

---

# Part 2: The Responsive Value Type

The core abstraction that makes everything work. A single type that can hold either a static value or a breakpoint-keyed map.

```dart
/// A value that may vary across breakpoints.
///
/// There are two ways to construct it:
///
/// 1. **Static** — the same value at all breakpoints:
///    ```dart
///    OiResponsive(2)           // always 2 columns
///    ```
///
/// 2. **Per-breakpoint** — different values at different breakpoints:
///    ```dart
///    OiResponsive.breakpoints({  // 1 on compact, 2 on medium, 4 on large
///      OiBreakpoint.compact: 1,
///      OiBreakpoint.medium: 2,
///      OiBreakpoint.large: 4,
///    })
///    ```
///
/// Resolution: when a breakpoint has no explicit value, it inherits
/// from the nearest smaller breakpoint that does have a value.
///
/// This cascading ("mobile-first") rule means you only define the
/// breakpoints where things *change*.
@immutable
class OiResponsive<T> {
  /// A value that is the same at every breakpoint.
  const OiResponsive(this._defaultValue) : _map = null;

  /// Values keyed by breakpoint, with mobile-first cascading.
  ///
  /// The map MUST contain a key with `minWidth == 0` (typically
  /// [OiBreakpoint.compact]) or provide a base via [defaultValue].
  const OiResponsive.breakpoints(Map<OiBreakpoint, T> map, {T? defaultValue})
      : _map = map,
        _defaultValue = defaultValue;

  final T? _defaultValue;
  final Map<OiBreakpoint, T>? _map;

  /// Whether this is a static (non-responsive) value.
  bool get isStatic => _map == null;

  /// Resolves the value for the given breakpoint.
  ///
  /// Walks breakpoints in descending order from [active], returns
  /// the first mapped value found. Falls back to [_defaultValue].
  T resolve(OiBreakpoint active, OiBreakpointScale scale) {
    if (_map == null) return _defaultValue as T;

    // Walk backwards from the active breakpoint's index.
    final sorted = scale.values;
    final idx = scale.resolveIndex(active.minWidth);
    for (var i = idx; i >= 0; i--) {
      final bp = sorted[i];
      if (_map!.containsKey(bp)) return _map![bp] as T;
    }

    return _defaultValue as T;
  }
}
```

**Convenience constructors and typedef:**

```dart
/// Shorthand — use anywhere a responsive int/double/bool is needed.
///
/// ```dart
/// // Static
/// columns: 3.responsive,
///
/// // Responsive
/// columns: {compact: 1, medium: 2, large: 4}.responsive,
/// ```
extension OiResponsiveIntExt on int {
  OiResponsive<int> get responsive => OiResponsive(this);
}

extension OiResponsiveMapExt<T> on Map<OiBreakpoint, T> {
  OiResponsive<T> get responsive => OiResponsive.breakpoints(this);
}
```

This means any layout prop that varies by screen size has the exact same type pattern. A developer never has to think "how does this particular widget handle responsiveness?" — it's always `OiResponsive<T>`.

---

# Part 3: Layout Primitives

All layout widgets live in `src/primitives/layout/`. Every layout widget that acts as a grid parent accepts `columns` as `OiResponsive<int>`. Every child inside a grid parent can use the span system (Part 4).

---

## Enhanced OiRow / OiColumn

The existing `OiRow` and `OiColumn` gain responsive gap and optional wrap behavior, but remain simple.

```dart
/// A horizontal layout with responsive gap.
///
/// This is obers_ui's replacement for [Row] with a built-in gap.
/// For responsive multi-column grids, use [OiGrid] instead.
///
/// ```dart
/// OiRow(
///   gap: OiResponsive.breakpoints({
///     OiBreakpoint.compact: 8,
///     OiBreakpoint.expanded: 16,
///   }),
///   children: [WidgetA(), WidgetB()],
/// )
/// ```
OiRow({
  required List<Widget> children,
  OiResponsive<double> gap = const OiResponsive(0),
  MainAxisAlignment mainAlign = MainAxisAlignment.start,
  CrossAxisAlignment crossAlign = CrossAxisAlignment.center,
  MainAxisSize mainSize = MainAxisSize.max,
})
```

```dart
/// A vertical layout with responsive gap.
OiColumn({
  required List<Widget> children,
  OiResponsive<double> gap = const OiResponsive(0),
  MainAxisAlignment mainAlign = MainAxisAlignment.start,
  CrossAxisAlignment crossAlign = CrossAxisAlignment.stretch,
  MainAxisSize mainSize = MainAxisSize.max,
})
```

No breaking changes. The `gap` parameter changes from `double` to `OiResponsive<double>`, but `double` implicitly constructs `OiResponsive(double)` via the default constructor, so `gap: 16` still works.

---

## Enhanced OiGrid

The grid is the workhorse. It lays out children in a CSS-Grid-like fashion with responsive column counts, and children can span/start at specific columns.

```dart
/// A responsive grid that arranges children in rows and columns.
///
/// The number of columns can be:
/// - Fixed: `columns: OiResponsive(3)` — always 3 columns.
/// - Responsive: `columns: OiResponsive.breakpoints({compact: 1, medium: 2, large: 4})`
/// - Auto: `minColumnWidth: 200` — calculates columns from available width.
///
/// Children can control their placement via [OiSpan] (see Part 4).
///
/// ## Simple example
/// ```dart
/// OiGrid(
///   columns: OiResponsive.breakpoints({
///     OiBreakpoint.compact: 1,
///     OiBreakpoint.medium: 2,
///     OiBreakpoint.large: 4,
///   }),
///   gap: 16,
///   children: [
///     OiTextInput(label: 'First name'),
///     OiTextInput(label: 'Last name'),
///     OiTextInput(label: 'Email').span(columnSpan: 2),
///     OiTextInput(label: 'Phone'),
///   ],
/// )
/// ```
///
/// ## Auto-column example
/// ```dart
/// OiGrid(
///   minColumnWidth: 280,
///   maxColumns: 4,
///   gap: 16,
///   children: [...],
/// )
/// ```
OiGrid({
  required List<Widget> children,

  /// The number of columns at each breakpoint.
  /// Mutually exclusive with [minColumnWidth].
  OiResponsive<int>? columns,

  /// When set, columns are calculated automatically:
  /// `floor(availableWidth / minColumnWidth)`, clamped to [1, maxColumns].
  /// Mutually exclusive with [columns].
  double? minColumnWidth,

  /// Maximum columns when using [minColumnWidth]. Default: 12.
  int maxColumns = 12,

  /// Gap between both columns and rows.
  OiResponsive<double> gap = const OiResponsive(16),

  /// Separate cross-axis gap. When null, uses [gap] for both.
  OiResponsive<double>? rowGap,

  /// Removes all spacing between children.
  bool dense = false,

  /// How to align children when a row is not fully filled.
  /// Defaults to [WrapAlignment.start] (left-aligned with empty space on right).
  WrapAlignment runAlignment = WrapAlignment.start,
})
```

**Implementation notes:**
- Uses a `CustomMultiChildLayout` delegate (or a custom `RenderBox` with `ContainerRenderObjectMixin`) — NOT `Wrap` or `GridView`, because we need column-start and column-span control.
- Layout algorithm: classic CSS Grid row-packing. Walk children in order, place each into the first available cell that satisfies its `columnSpan` and `columnStart`. Advance to next row when the current row is full.
- The resolved column count is calculated once per layout pass using the current width and breakpoint. This value is then passed to the layout delegate — no per-child rebuilds.

---

## OiSection

A visually grouped region with an optional heading, description, icon, collapse, and its own internal grid columns.

This is the Filament `Section` adapted for Flutter. It serves double duty: visual grouping (card-like surface) AND layout container (internal grid).

```dart
/// A visually distinct region that groups related content.
///
/// Sections are the primary tool for organizing complex forms,
/// settings pages, and detail views into digestible chunks.
///
/// ## Basic
/// ```dart
/// OiSection(
///   label: 'Rate limiting',
///   description: 'Prevent abuse by limiting requests per period',
///   columns: OiResponsive.breakpoints({compact: 1, expanded: 2}),
///   children: [
///     OiNumberInput(label: 'Max requests'),
///     OiSelect(label: 'Time window', items: [...]),
///   ],
/// )
/// ```
///
/// ## Aside layout
/// ```dart
/// OiSection(
///   label: 'Notifications',
///   description: 'Choose how you want to be notified',
///   aside: true, // heading left, content right
///   children: [...],
/// )
/// ```
///
/// ## Collapsible
/// ```dart
/// OiSection(
///   label: 'Advanced',
///   collapsible: true,
///   collapsed: true,
///   children: [...],
/// )
/// ```
OiSection({
  required List<Widget> children,
  required String label,

  /// Subtitle text rendered below the heading.
  String? description,

  /// Icon displayed next to the heading.
  IconData? icon,

  /// Internal grid columns for the section's children.
  /// When null, children are laid out in a single column.
  OiResponsive<int>? columns,

  /// Gap between children inside the section.
  OiResponsive<double> gap = const OiResponsive(16),

  /// When true, heading+description are on the left and
  /// children render in a card on the right. Stacks vertically
  /// on compact breakpoints.
  bool aside = false,

  /// The breakpoint below which aside layout stacks vertically.
  OiBreakpoint asideStackBelow = OiBreakpoint.medium,

  /// Whether the section can be collapsed by the user.
  bool collapsible = false,

  /// Initial collapsed state (only meaningful when [collapsible] is true).
  bool collapsed = false,

  /// Fires when collapsed state changes.
  ValueChanged<bool>? onCollapsedChanged,

  /// When true, collapse state is persisted via the nearest
  /// [OiSettingsDriver]. Requires a unique [label] or explicit [id].
  bool persistCollapsed = false,

  /// Explicit ID for persistence (avoids collisions when multiple
  /// sections share the same label).
  String? id,

  /// More compact internal padding. Useful for nested sections.
  bool compact = false,

  /// Removes the card background, leaving just the heading + content.
  bool contained = true,

  /// Widgets rendered in the header row, after the heading.
  /// Typically action buttons.
  List<Widget>? headerActions,

  /// Widgets rendered in a footer row below the content.
  List<Widget>? footerActions,
})
```

**Composes:** `OiSurface` (card background when `contained`), `OiLabel` (heading, description), `OiIcon`, `OiTappable` (collapse toggle), `OiGrid` or `OiColumn` (internal layout), `AnimatedCrossFade` or `SizeTransition` (collapse animation).

**Semantics:** Wraps content in `Semantics(label: label, container: true)`. Collapsible section announces "collapsed" / "expanded" state.

---

## OiFlex

A flexbox-style layout where children can grow or stay fixed. Think of it as `OiRow` but with explicit grow/shrink semantics and a responsive stacking breakpoint.

```dart
/// A flex layout where children can grow or stay fixed-width.
///
/// Unlike [OiRow] (which gives all children equal flex or intrinsic sizing),
/// [OiFlex] lets each child declare whether it should [grow] to fill
/// available space.
///
/// Below the [stackBelow] breakpoint, children stack vertically.
///
/// ## Sidebar + Content pattern
/// ```dart
/// OiFlex(
///   stackBelow: OiBreakpoint.medium,
///   gap: 24,
///   children: [
///     OiSection(label: 'Main', children: [...]).grow(),
///     OiSection(label: 'Sidebar', children: [...]).fixed(width: 300),
///   ],
/// )
/// ```
OiFlex({
  required List<Widget> children,

  /// Gap between children.
  OiResponsive<double> gap = const OiResponsive(16),

  /// Direction of the flex layout. Default horizontal.
  Axis direction = Axis.horizontal,

  /// Breakpoint below which children stack vertically
  /// (direction becomes [Axis.vertical]).
  /// When null, never stacks.
  OiBreakpoint? stackBelow,

  /// Cross-axis alignment.
  CrossAxisAlignment crossAlign = CrossAxisAlignment.start,
})
```

**Child modifiers (extensions on Widget):**

```dart
extension OiFlexChildExt on Widget {
  /// This child grows to fill available space.
  /// [flex] controls the grow ratio (default 1).
  Widget grow({int flex = 1});

  /// This child has a fixed width and does not grow.
  Widget fixed({double? width});
}
```

These wrap the child in an `OiFlexChild` data widget that `OiFlex` reads during layout.

---

## OiFieldset

A labeled group with a border — the HTML `<fieldset>` equivalent. Simpler than `OiSection` (no card surface, no collapse). Primarily for grouping form fields.

```dart
/// A bordered group with a legend label.
///
/// ```dart
/// OiFieldset(
///   label: 'Shipping address',
///   columns: OiResponsive.breakpoints({compact: 1, medium: 2}),
///   children: [
///     OiTextInput(label: 'Street'),
///     OiTextInput(label: 'City'),
///     OiTextInput(label: 'ZIP'),
///     OiSelect(label: 'Country', items: [...]),
///   ],
/// )
/// ```
OiFieldset({
  required List<Widget> children,
  required String label,

  /// Internal grid columns.
  OiResponsive<int>? columns,

  /// Gap between children.
  OiResponsive<double> gap = const OiResponsive(16),

  /// Removes the border.
  bool contained = true,
})
```

**Composes:** `OiSurface` with border style from theme, `OiLabel` for legend, `OiGrid` or `OiColumn` for internal layout.

---

## OiPage

A page-level layout scaffolding widget that provides max-width centering, responsive gutters, and a structured header/content/footer flow. This is *not* a scaffold with app bar — it's a content area layout.

```dart
/// A max-width centered page layout with responsive gutters.
///
/// Use as the root of a route's content area.
///
/// ```dart
/// OiPage(
///   maxWidth: 1200,
///   children: [
///     OiSection(label: 'Profile', children: [...]),
///     OiSection(label: 'Security', children: [...]),
///   ],
/// )
/// ```
OiPage({
  required List<Widget> children,

  /// Maximum content width. Content is centered when viewport exceeds this.
  double maxWidth = 1200,

  /// Responsive horizontal padding (page gutters).
  /// Defaults to theme-derived values per breakpoint.
  OiResponsive<double>? padding,

  /// Vertical gap between children.
  OiResponsive<double> gap = const OiResponsive(24),

  /// Whether the page scrolls. When false, children fill available space.
  bool scrollable = true,

  /// Scroll controller.
  ScrollController? scrollController,
})
```

**Composes:** `OiContainer` (max-width + centering), `OiColumn` (vertical stacking with gap), `SingleChildScrollView` (when scrollable).

---

## Responsive Visibility: OiShow / OiHide

```dart
/// Shows its child only at or above the given breakpoint.
///
/// ```dart
/// OiShow(
///   above: OiBreakpoint.medium,
///   child: OiLabel(text: 'Desktop only'),
/// )
/// ```
OiShow({
  required Widget child,

  /// Show when viewport is >= this breakpoint.
  OiBreakpoint? above,

  /// Show when viewport is <= this breakpoint.
  OiBreakpoint? below,

  /// When true, hides visually but keeps in semantics tree.
  /// When false, removes from tree entirely (default).
  bool maintainSemantics = false,

  /// Optional replacement widget shown when hidden.
  Widget? replacement,
})

/// Hides its child at or above the given breakpoint.
/// Inverse of [OiShow]. Convenience wrapper.
OiHide({
  required Widget child,
  OiBreakpoint? above,
  OiBreakpoint? below,
  bool maintainSemantics = false,
  Widget? replacement,
})
```

**Implementation:** Uses `Visibility` (when `maintainSemantics`) or conditional build (when not). Reads breakpoint from context — only rebuilds when the relevant breakpoint threshold is crossed, not on every pixel of resize.

---

# Part 4: The Span System — Universal Child Positioning

Any widget placed inside an `OiGrid`, `OiSection(columns: ...)`, or `OiFieldset(columns: ...)` can control its grid placement via the `.span()` extension.

```dart
/// Grid placement metadata for a child widget.
///
/// Applied via the [OiSpanExt] extension method:
/// ```dart
/// OiTextInput(label: 'Bio').span(
///   columnSpan: OiResponsive.breakpoints({compact: 1, medium: 2}),
/// )
/// ```
@immutable
class OiSpanData {
  const OiSpanData({
    this.columnSpan,
    this.columnStart,
    this.columnOrder,
    this.rowSpan,
  });

  /// How many columns this child occupies.
  /// `null` = 1 column (default).
  /// Use `OiSpanData.full` for full-width.
  final OiResponsive<int>? columnSpan;

  /// Which column this child starts at (1-indexed).
  /// `null` = auto-placed (next available slot).
  final OiResponsive<int>? columnStart;

  /// Visual ordering within the grid row.
  /// Lower numbers render first. `null` = source order.
  final OiResponsive<int>? columnOrder;

  /// How many rows this child occupies. Default 1.
  /// Only useful in advanced dashboards — most layouts ignore this.
  final OiResponsive<int>? rowSpan;

  /// Full-width span — fills all columns at every breakpoint.
  static const full = OiSpanData(
    columnSpan: OiResponsive(_fullSpanSentinel),
  );
}

// Sentinel value that the grid interprets as "all columns".
const _fullSpanSentinel = -1;
```

**Extension method on Widget:**

```dart
extension OiSpanExt on Widget {
  /// Wraps this widget with grid placement metadata.
  ///
  /// ```dart
  /// OiTextInput(label: 'Email').span(
  ///   columnSpan: OiResponsive.breakpoints({
  ///     OiBreakpoint.compact: 1,
  ///     OiBreakpoint.expanded: 2,
  ///   }),
  /// )
  /// ```
  Widget span({
    OiResponsive<int>? columnSpan,
    OiResponsive<int>? columnStart,
    OiResponsive<int>? columnOrder,
    OiResponsive<int>? rowSpan,
  }) {
    return OiSpan(
      data: OiSpanData(
        columnSpan: columnSpan,
        columnStart: columnStart,
        columnOrder: columnOrder,
        rowSpan: rowSpan,
      ),
      child: this,
    );
  }

  /// Shorthand: span all columns at every breakpoint.
  Widget spanFull() => OiSpan(data: OiSpanData.full, child: this);
}

/// An InheritedWidget that carries [OiSpanData] for the nearest
/// grid parent to read during layout.
class OiSpan extends SingleChildRenderObjectWidget {
  const OiSpan({required this.data, required Widget child})
      : super(child: child);

  final OiSpanData data;

  // The parent grid reads this via parentData during layout.
}
```

**How the grid reads spans:**

`OiGrid`'s `RenderObject` iterates children. For each child, it checks if the child is an `OiSpan` and reads its `OiSpanData`. It resolves responsive values against the current breakpoint (determined by the grid's own width — see container queries). Then it runs the row-packing algorithm:

1. Maintain a cursor: `(row, column)` starting at `(0, 0)`.
2. For each child (sorted by `columnOrder` if specified):
   - Resolve `columnSpan` (default 1, or `_fullSpanSentinel` → total columns).
   - If `columnStart` is specified, place at that column (may leave gaps).
   - Otherwise, find the next slot where `span` consecutive columns are free.
   - If the child doesn't fit on the current row, advance to next row.
3. Record each child's `(row, column, columnSpan, rowSpan)`.
4. Layout each child with width = `(columnSpan / totalColumns) * (availableWidth - gaps)`.
5. Position children with offsets.

---

# Part 5: Container-Relative Layouts

Sometimes you want a grid to respond to its *own* width rather than the viewport. For example, a form inside a resizable panel should reflow based on panel width, not window width.

```dart
/// Makes this grid use its own width to resolve breakpoints,
/// rather than the viewport width.
///
/// ```dart
/// OiGrid(
///   containerRelative: true,
///   columns: OiResponsive.breakpoints({
///     OiBreakpoint.compact: 1,   // grid < 600px → 1 column
///     OiBreakpoint.medium: 2,    // grid 600-840px → 2 columns
///     OiBreakpoint.expanded: 3,  // grid > 840px → 3 columns
///   }),
///   children: [...],
/// )
/// ```
```

**Implementation:** When `containerRelative: true`, the grid's `RenderBox.performLayout()` uses its own `constraints.maxWidth` (not `MediaQuery.sizeOf(context).width`) to resolve the breakpoint via `OiBreakpointScale.resolve(ownWidth)`. This means:

- The grid re-layouts when its own constraints change (e.g., panel resized).
- It does NOT listen to `MediaQuery` at all — no unnecessary rebuilds when the window resizes but the grid's own width doesn't change.
- Nested grids inside a container-relative grid also use the outer grid's width as their viewport if they're also container-relative, or they fall back to the real viewport if they're not.

This is added as a single `bool` prop on `OiGrid`, `OiSection`, `OiFieldset`, and `OiFlex`:

```dart
/// When true, responsive values resolve against this widget's own
/// width instead of the viewport width.
bool containerRelative = false,
```

---

# Part 6: Performance Architecture

Layout is the hottest path in any UI framework. Here's how we keep it fast.

## 1. Breakpoint-Gated Rebuilds

The `OiBreakpointProvider` (an `InheritedWidget` injected by `OiApp`) only notifies dependents when the *active breakpoint changes*, not on every pixel of window resize.

```dart
class OiBreakpointProvider extends InheritedWidget {
  final OiBreakpoint current;

  @override
  bool updateShouldNotify(OiBreakpointProvider old) =>
      current != old.current; // Only fires on breakpoint change
}
```

A window resize from 1000px → 1050px (both `expanded`) triggers zero rebuilds. A resize from 1195px → 1205px (crossing `large` threshold) triggers one rebuild.

## 2. RenderObject-Level Layout

`OiGrid` does NOT use `LayoutBuilder` + `setState`. It uses a custom `RenderBox` (`RenderOiGrid`) that:

1. Receives `constraints` in `performLayout()`.
2. Resolves the breakpoint from constraints (container-relative) or cached viewport breakpoint.
3. Resolves all responsive values (columns, gaps, per-child spans).
4. Runs the row-packing algorithm.
5. Lays out and positions children in a single pass.

This means:
- No widget rebuild on resize — only relayout.
- No `setState` chains. Changes propagate through the render tree.
- Parent data (`OiSpanData`) is read directly from `RenderBox.parentData`.

## 3. Static Value Fast Path

When `OiResponsive.isStatic == true` (the common case for simple layouts), the resolve method returns immediately without any breakpoint lookup. No map iteration, no comparison.

## 4. Cached Breakpoint Resolution

Each `OiResponsive<T>` caches its last resolved value + breakpoint. If the breakpoint hasn't changed, it returns the cached value. This avoids re-walking the map on every layout pass for responsive values.

## 5. Collapse Animation

`OiSection` collapse uses `SizeTransition` with `AnimatedBuilder` — the collapsed content is wrapped in `Offstage` when fully collapsed, removing it from layout entirely. During animation, it uses `ClipRect` to avoid overflow. When `reducedMotion` is active, collapse is instant (no animation, just `Offstage` toggle).

---

# Part 7: Theme Integration

## OiLayoutThemeData

```dart
/// Theme data for all layout primitives.
///
/// Added to [OiComponentThemes].
@immutable
class OiLayoutThemeData {
  const OiLayoutThemeData({
    this.defaultGap = 16,
    this.denseGap = 8,
    this.sectionPadding,
    this.sectionRadius,
    this.sectionHeaderSpacing = 12,
    this.fieldsetBorder,
    this.pageGutters,
    this.pageMaxWidth = 1200,
  });

  final double defaultGap;
  final double denseGap;
  final EdgeInsets? sectionPadding;
  final BorderRadius? sectionRadius;
  final double sectionHeaderSpacing;
  final OiBorderStyle? fieldsetBorder;
  final OiResponsive<double>? pageGutters;
  final double pageMaxWidth;
}
```

Added to `OiComponentThemes`:

```dart
class OiComponentThemes {
  // ... existing fields ...
  final OiLayoutThemeData? layout; // ★ NEW
}
```

---

# Part 8: Package Structure

```
src/
  foundation/
    theme/
      oi_breakpoint.dart              ★ NEW — OiBreakpoint, OiBreakpointScale
      oi_responsive.dart              ★ REPLACED — OiResponsive<T>, extensions
      oi_breakpoint_provider.dart     ★ NEW — InheritedWidget
      // ... existing theme files ...

  primitives/
    layout/
      oi_row.dart                     ★ ENHANCED — responsive gap
      oi_column.dart                  ★ ENHANCED — responsive gap
      oi_grid.dart                    ★ REPLACED — full grid system
      oi_section.dart                 ★ NEW — visual grouping + grid
      oi_flex.dart                    ★ NEW — grow/fixed flex layout
      oi_fieldset.dart                ★ NEW — bordered group
      oi_page.dart                    ★ NEW — page scaffolding
      oi_span.dart                    ★ NEW — span data + extension
      oi_show.dart                    ★ NEW — responsive visibility
      // existing files unchanged:
      oi_wrap_layout.dart
      oi_masonry.dart
      oi_aspect_ratio.dart
      oi_spacer.dart
      oi_container.dart
```

---

# Part 9: Usage Examples

## Example 1: Simple Responsive Form

```dart
OiSection(
  label: 'Personal information',
  columns: OiResponsive.breakpoints({
    OiBreakpoint.compact: 1,
    OiBreakpoint.expanded: 2,
  }),
  children: [
    OiTextInput(label: 'First name'),
    OiTextInput(label: 'Last name'),
    OiTextInput(label: 'Email').spanFull(),
    OiTextInput(label: 'Phone'),
    OiSelect(label: 'Country', items: countries),
  ],
)
```

On compact: all fields stack. On expanded+: first/last name side by side, email full width, phone/country side by side.

## Example 2: Settings Page with Aside Sections

```dart
OiPage(
  children: [
    OiSection(
      label: 'Notifications',
      description: 'Choose how you want to be notified about updates',
      aside: true,
      children: [
        OiSwitch(label: 'Email notifications', value: emailOn, onChanged: ...),
        OiSwitch(label: 'Push notifications', value: pushOn, onChanged: ...),
        OiSwitch(label: 'SMS notifications', value: smsOn, onChanged: ...),
      ],
    ),
    OiSection(
      label: 'Privacy',
      description: 'Control who can see your profile and activity',
      aside: true,
      columns: OiResponsive.breakpoints({
        OiBreakpoint.compact: 1,
        OiBreakpoint.expanded: 2,
      }),
      children: [
        OiSelect(label: 'Profile visibility', items: visibilityOptions),
        OiSelect(label: 'Activity visibility', items: visibilityOptions),
      ],
    ),
  ],
)
```

## Example 3: Dashboard-Style Grid

```dart
OiGrid(
  columns: OiResponsive.breakpoints({
    OiBreakpoint.compact: 1,
    OiBreakpoint.medium: 2,
    OiBreakpoint.large: 4,
  }),
  gap: 16,
  children: [
    MetricCard(title: 'Revenue', value: '\$12.4M'),
    MetricCard(title: 'Users', value: '84.2K'),
    MetricCard(title: 'Orders', value: '2.1K'),
    MetricCard(title: 'Conversion', value: '3.2%'),
    RevenueChart().span(
      columnSpan: OiResponsive.breakpoints({
        OiBreakpoint.compact: 1,
        OiBreakpoint.medium: 2,
        OiBreakpoint.large: 3,
      }),
    ),
    TopProducts().span(columnSpan: OiResponsive(1)),
  ],
)
```

## Example 4: Flex Layout (Main + Sidebar)

```dart
OiFlex(
  stackBelow: OiBreakpoint.expanded,
  gap: 24,
  children: [
    OiColumn(
      gap: 16,
      children: [
        OiSection(label: 'Details', columns: 2.responsive, children: [...]),
        OiSection(label: 'History', children: [...]),
      ],
    ).grow(),
    OiColumn(
      gap: 16,
      children: [
        OiSection(label: 'Status', children: [...]),
        OiSection(label: 'Tags', children: [...]),
      ],
    ).fixed(width: 320),
  ],
)
```

## Example 5: Container-Relative Form in a Panel

```dart
// Inside a resizable OiPanel
OiSection(
  label: 'Quick edit',
  containerRelative: true,
  columns: OiResponsive.breakpoints({
    OiBreakpoint.compact: 1,   // panel narrow → stack
    OiBreakpoint.medium: 2,    // panel wide → 2 cols
  }),
  children: [
    OiTextInput(label: 'Name'),
    OiTextInput(label: 'Email'),
    OiTextInput(label: 'Notes').spanFull(),
  ],
)
```

## Example 6: Nested Sections

```dart
OiPage(
  children: [
    OiSection(
      label: 'Billing',
      columns: OiResponsive.breakpoints({compact: 1, expanded: 2}),
      children: [
        OiFieldset(
          label: 'Card details',
          children: [
            OiTextInput(label: 'Card number'),
            OiRow(gap: 16, children: [
              Expanded(child: OiTextInput(label: 'Expiry')),
              Expanded(child: OiTextInput(label: 'CVV')),
            ]),
          ],
        ).spanFull(),
        OiFieldset(
          label: 'Billing address',
          columns: OiResponsive.breakpoints({compact: 1, medium: 2}),
          children: [
            OiTextInput(label: 'Street').spanFull(),
            OiTextInput(label: 'City'),
            OiTextInput(label: 'ZIP'),
          ],
        ).spanFull(),
      ],
    ),
  ],
)
```

## Example 7: Custom Breakpoints

```dart
// In your theme setup
OiThemeData(
  breakpoints: OiBreakpointScale([
    OiBreakpoint.compact,
    const OiBreakpoint('tablet', 480),
    OiBreakpoint.medium,
    OiBreakpoint.expanded,
    OiBreakpoint.large,
    const OiBreakpoint('ultraWide', 1920),
    OiBreakpoint.extraLarge,
  ]),
  // ...
)

// Then use everywhere
const tablet = OiBreakpoint('tablet', 480);
const ultraWide = OiBreakpoint('ultraWide', 1920);

OiGrid(
  columns: OiResponsive.breakpoints({
    OiBreakpoint.compact: 1,
    tablet: 2,
    OiBreakpoint.expanded: 3,
    ultraWide: 6,
  }),
  children: [...],
)
```

## Example 8: Responsive Visibility

```dart
OiGrid(
  columns: OiResponsive.breakpoints({compact: 1, expanded: 3}),
  children: [
    OiTextInput(label: 'Name'),
    OiTextInput(label: 'Email'),
    // Only visible on expanded+
    OiShow(
      above: OiBreakpoint.expanded,
      child: OiTextInput(label: 'Department'),
    ),
  ],
)
```

---

# Part 10: Tests

## Unit Tests

| Test | What it verifies |
|------|-----------------|
| `OiBreakpoint.compareTo` sorts by minWidth | Ordering correct |
| `OiBreakpointScale` rejects scale without minWidth=0 | Validation |
| `OiBreakpointScale.resolve(500)` returns compact | 500 < 600 |
| `OiBreakpointScale.resolve(600)` returns medium | Exact boundary |
| `OiBreakpointScale.resolve(1400)` returns large | 1200–1600 range |
| `OiBreakpointScale` with custom breakpoints resolves correctly | Extended scale |
| `OiResponsive(42).resolve(any)` always returns 42 | Static fast path |
| `OiResponsive.breakpoints({compact: 1, large: 4}).resolve(medium)` returns 1 | Cascading fallback |
| `OiResponsive.breakpoints({compact: 1, large: 4}).resolve(large)` returns 4 | Exact match |
| `OiResponsive.breakpoints({compact: 1, large: 4}).resolve(extraLarge)` returns 4 | Cascade up |
| `OiResponsive.isStatic` returns correctly | Type check |
| `OiSpanData.full` resolves to total columns | Sentinel value |
| Grid row-packing: 4 items, 2 columns → 2 rows | Basic packing |
| Grid row-packing: item with columnSpan=2 in 3-col grid → correct placement | Spanning |
| Grid row-packing: item with columnStart=2 in 3-col grid → gap left | Start positioning |
| Grid row-packing: columnOrder reorders visually | Ordering |
| Grid row-packing: span exceeds remaining → wraps to next row | Overflow wrap |

## Widget Tests

### OiGrid

| Test | What it verifies |
|------|-----------------|
| Renders N columns at given width | Column count correct |
| Responsive columns change at breakpoint boundary | Layout updates |
| `minColumnWidth: 200` with 500px width → 2 columns | Auto calculation |
| `maxColumns` caps auto-calculated columns | Cap enforced |
| `gap` applies between children | Spacing correct |
| `rowGap` differs from column gap | Separate gaps |
| `dense: true` reduces gap by 50% | Dense mode |
| Child `.span(columnSpan: 2)` occupies two columns | Span works |
| Child `.spanFull()` occupies all columns | Full span |
| Child `.span(columnStart: 2)` starts at column 2 | Start works |
| Responsive columnSpan changes at breakpoint | Per-child responsiveness |
| `containerRelative: true` uses own width, not viewport | Container queries |
| Container-relative grid inside resizable panel relayouts on resize | Panel integration |
| Empty children list renders nothing (no crash) | Edge case |
| Single child fills first column | Minimal case |
| 100 children render without jank | Performance |

### OiSection

| Test | What it verifies |
|------|-----------------|
| Heading renders | Label visible |
| Description renders | Subtitle visible |
| Icon renders next to heading | Icon placement |
| Children render inside surface | Content visible |
| `columns: 2` creates 2-column grid inside section | Internal grid |
| `aside: true` puts heading left, content right | Aside layout |
| Aside stacks on compact breakpoint | Responsive aside |
| `collapsible: true` shows collapse toggle | Toggle visible |
| Tap collapse toggle hides content | Collapse works |
| Tap again shows content | Expand works |
| `collapsed: true` starts collapsed | Initial state |
| `onCollapsedChanged` fires | Callback |
| `persistCollapsed: true` + driver → persists state | Persistence |
| `compact: true` reduces padding | Compact styling |
| `contained: false` removes card background | Borderless |
| `headerActions` render in header row | Actions slot |
| `footerActions` render below content | Footer slot |
| Semantics label set | Accessibility |
| Collapse state announced to screen reader | A11y announcement |
| Reduced motion: collapse is instant | A11y animation |
| Nested section inside section renders correctly | Nesting |

### OiFlex

| Test | What it verifies |
|------|-----------------|
| Children render horizontally with gap | Basic flex |
| `.grow()` child fills remaining space | Grow works |
| `.fixed(width: 300)` child is exactly 300px | Fixed works |
| Two `.grow()` children share space equally | Equal grow |
| `.grow(flex: 2)` gets twice the space of `.grow(flex: 1)` | Flex ratio |
| `stackBelow: medium` stacks vertically on compact | Responsive stacking |
| Stacked layout has vertical gap | Gap in stacked mode |
| `direction: Axis.vertical` renders vertically | Vertical mode |

### OiFieldset

| Test | What it verifies |
|------|-----------------|
| Border renders around children | Border visible |
| Label renders as legend | Legend text |
| `columns` creates internal grid | Grid inside fieldset |
| `contained: false` removes border | Borderless |
| Semantics: fieldset has group role | A11y |

### OiPage

| Test | What it verifies |
|------|-----------------|
| Content centered when viewport > maxWidth | Centering |
| Full width when viewport < maxWidth | Full bleed |
| Responsive gutters apply | Padding |
| Children stack vertically with gap | Vertical layout |
| `scrollable: true` enables scrolling | Scroll |
| `scrollable: false` fills available height | Fill mode |

### OiShow / OiHide

| Test | What it verifies |
|------|-----------------|
| `OiShow(above: medium)` visible at expanded, hidden at compact | Threshold |
| `OiHide(above: large)` hidden at large, visible at expanded | Inverse |
| `maintainSemantics: true` keeps in semantics tree when hidden | A11y |
| `replacement` widget shown when hidden | Swap |
| Breakpoint change toggles visibility | Reactive |
| Hidden widget not in layout (no space consumed) | No phantom space |

### OiResponsive Context Extension

| Test | What it verifies |
|------|-----------------|
| `context.breakpoint` returns correct value | Extension works |
| `context.responsive(OiResponsive.breakpoints({...}))` resolves | Resolution |
| `isCompact` / `isLargeOrWider` helpers correct | Boolean helpers |

## Golden Tests

| Golden | Variants |
|--------|----------|
| OiGrid: 1-col, 2-col, 4-col layouts | 3 × 2 (light+dark) = 6 |
| OiGrid: child with columnSpan, columnStart | 1 × 2 = 2 |
| OiSection: default, aside, compact, collapsed | 4 × 2 = 8 |
| OiSection: with header/footer actions | 1 × 2 = 2 |
| OiFlex: horizontal, stacked | 2 × 2 = 4 |
| OiFieldset: bordered, borderless | 2 × 2 = 4 |
| OiPage: narrow viewport, wide viewport | 2 × 2 = 4 |
| **Total** | **30 goldens** |

## Integration Tests

| Test | Scenario |
|------|----------|
| **Responsive form reflow** | Set viewport to 500px → all fields stack → resize to 1000px → fields reflow to 2 columns → verify no jank, fields maintain values |
| **Section collapse + persist** | Collapse section → verify content hidden → navigate away → come back → section still collapsed (driver loaded) |
| **Flex + resize panel** | Place OiFlex in resizable panel → narrow panel → children stack → widen → children go horizontal → verify smooth |
| **Container-relative grid** | Grid inside OiSplitPane → drag divider smaller → grid reflows to fewer columns based on own width, not viewport |
| **Nested grids** | Grid(3-col) > Section(2-col) > children with spans → verify inner grid respects its own column count, not parent's |
| **Custom breakpoints** | Configure theme with custom breakpoint → use in grid columns → verify layout changes at custom width |
| **OiShow/OiHide in form** | Form with OiShow(above: medium) wrapping optional field → compact: field hidden, validation skips it → expanded: field visible, validation includes it |
| **Full page composition** | OiPage > OiFlex > [OiColumn.grow > [OiSection, OiSection], OiColumn.fixed > OiSection] → verify at all 5 breakpoints |

## Performance Tests

| Test | Target |
|------|--------|
| OiGrid with 200 children, responsive columns: layout pass | < 4ms |
| Window resize across breakpoint: rebuild time | < 8ms |
| Window resize within same breakpoint: zero rebuilds | 0 widget rebuilds verified |
| OiResponsive.resolve with static value | < 0.001ms (no map lookup) |
| OiSection collapse animation: frame time | < 16ms (60fps) |
| Container-relative OiGrid relayout on panel drag | < 16ms per frame |
| 10 nested OiGrid/OiSection levels: layout pass | < 16ms |

---

End of specification.
