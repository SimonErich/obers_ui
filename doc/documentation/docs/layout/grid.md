# Grid System

`OiGrid` is a CSS-Grid-style multi-column layout. You declare a column count
(or a minimum column width) and children fill the columns in source order,
with optional per-child spans.

All numeric props (`columns`, `minColumnWidth`, `gap`, `rowGap`) use
`OiResponsive<T>` — either a static `OiResponsive(value)` or a per-breakpoint
`OiResponsive.breakpoints({...})`.

## Basic grid

```dart
OiGrid(
  breakpoint: context.breakpoint,
  columns: const OiResponsive<int>(3),
  gap: const OiResponsive<double>(16),
  children: [
    CardWidget(),
    CardWidget(),
    CardWidget(),
    CardWidget(), // Wraps to the second row
  ],
)
```

`gap` controls both horizontal and vertical spacing. Pass `rowGap` to use a
different vertical gap:

```dart
OiGrid(
  breakpoint: context.breakpoint,
  columns: const OiResponsive<int>(3),
  gap: const OiResponsive<double>(16),     // horizontal
  rowGap: const OiResponsive<double>(24),  // vertical
  children: [/* ... */],
)
```

## Responsive columns

Change the column count per breakpoint:

```dart
OiGrid(
  breakpoint: context.breakpoint,
  columns: OiResponsive.breakpoints({
    OiBreakpoint.compact: 1,
    OiBreakpoint.medium: 2,
    OiBreakpoint.expanded: 3,
    OiBreakpoint.large: 4,
  }),
  gap: const OiResponsive<double>(16),
  children: cards,
)
```

Values cascade **down** from the active breakpoint: the grid walks from the
current breakpoint toward smaller breakpoints and picks the first value it
finds. So with only `compact` and `expanded` defined, `medium` resolves to
the `compact` value (next smaller) and `large` resolves to `expanded`.

## Minimum column width

Instead of a fixed count, let the grid compute columns from a minimum width:

```dart
OiGrid(
  breakpoint: context.breakpoint,
  minColumnWidth: const OiResponsive<double>(240),
  gap: const OiResponsive<double>(16),
  children: cards,
)
```

The grid lays out as many columns as fit while respecting `minColumnWidth`.
`columns` and `minColumnWidth` are mutually exclusive.

## Container-relative breakpoints

The default constructor resolves the breakpoint from the viewport. To
resolve from the grid's own constraints (useful inside panels, splits, or
nested layouts), use `OiGrid.containerRelative`:

```dart
OiGrid.containerRelative(
  columns: OiResponsive.breakpoints({
    OiBreakpoint.compact: 1,
    OiBreakpoint.medium: 2,
  }),
  gap: const OiResponsive<double>(16),
  children: cards,
)
```

This variant re-layouts when its own width changes and does **not** rebuild
on unrelated viewport changes.

## Spanning columns

Children opt into grid placement using the `.span()` extension (preferred)
or by wrapping in an `OiSpan` widget directly.

```dart
OiGrid(
  breakpoint: context.breakpoint,
  columns: const OiResponsive<int>(3),
  gap: const OiResponsive<double>(16),
  children: [
    WideCard().span(columnSpan: const OiResponsive<int>(2)),
    NarrowCard(),
    FullWidthBanner().spanFull(), // Shorthand: span all columns
  ],
)
```

`spanFull()` is a shorthand for "span every column at every breakpoint."

## Span options

`.span()` (and the underlying `OiSpanData`) accepts:

| Property | Description |
| --- | --- |
| `columnSpan` | How many columns the child occupies (default 1). |
| `columnStart` | Explicit column start position (1-indexed). `null` = auto-place. |
| `columnOrder` | Visual ordering; lower values render first. `null` = source order. |
| `rowSpan` | How many rows the child occupies (default 1). |

All four take `OiResponsive<int>?` so placement can change per breakpoint:

```dart
HeroCard().span(
  columnSpan: OiResponsive.breakpoints({
    OiBreakpoint.compact: 1,
    OiBreakpoint.medium: 2,
  }),
)
```

## Row stretching

By default, rows fit their tallest child. Set `stretchRows: true` to force
every child in a row to the row's height (useful for card grids with
matching heights):

```dart
OiGrid(
  breakpoint: context.breakpoint,
  columns: const OiResponsive<int>(3),
  gap: const OiResponsive<double>(16),
  stretchRows: true,
  children: cards,
)
```

## Masonry layout

For content with variable heights where you don't want equal-height rows,
use `OiMasonry`. It distributes children across columns round-robin (or
honouring `columnStart`/`columnOrder` via `.span()`) and each column
flows independently.

```dart
OiMasonry(
  breakpoint: context.breakpoint,
  columns: OiResponsive.breakpoints({
    OiBreakpoint.compact: 2,
    OiBreakpoint.expanded: 3,
  }),
  gap: const OiResponsive<double>(12),
  children: imageCards,
)
```

Children with `columnSpan > 1` are rendered as full-width "breakers"
between masonry sections rather than within a column.
