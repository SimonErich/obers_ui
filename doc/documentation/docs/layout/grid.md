# Grid System

`OiGrid` lays children out in equal-width columns. You set a column count, or a
minimum column width, and children flow into the columns in source order. Both
the column count and the gaps can change per breakpoint, so one grid adapts from
phone to desktop. For tiles with uneven heights, reach for `OiMasonry`.

| Widget | What it does |
| --- | --- |
| `OiGrid` | Multi-column layout with a fixed or responsive column count. |
| `OiMasonry` | Pinterest-style columns for tiles of different heights. |

Both take responsive values through `OiResponsive<T>`. A static value is
`OiResponsive(3)`. A per-breakpoint value is `OiResponsive.breakpoints({...})`.
The breakpoints, from smallest to largest, are `compact`, `medium`, `expanded`,
`large`, and `extraLarge`.

## OiGrid

The everyday grid. Pass the active `breakpoint`, a column count, and a gap. Give
it a list of `children` and they fill the columns left to right, wrapping to the
next row when a row is full.

```dart
OiGrid(
  breakpoint: context.breakpoint,
  columns: const OiResponsive<int>(3),
  gap: const OiResponsive<double>(16),
  children: [
    OiCard(child: OiLabel.body('One')),
    OiCard(child: OiLabel.body('Two')),
    OiCard(child: OiLabel.body('Three')),
    OiCard(child: OiLabel.body('Four')), // wraps to the second row
  ],
)
```

`breakpoint` is required. Resolve it once at the top of your page with
`context.breakpoint` and pass it down. This keeps the grid self-contained and
avoids hidden context lookups during layout.

### Responsive columns

To change the column count per screen size, pass `OiResponsive.breakpoints`. Show
one column on a phone and three on a wide screen.

```dart
OiGrid(
  breakpoint: context.breakpoint,
  columns: OiResponsive.breakpoints({
    OiBreakpoint.compact: 1,
    OiBreakpoint.medium: 2,
    OiBreakpoint.large: 3,
  }),
  gap: const OiResponsive<double>(16),
  children: products
      .map((p) => OiCard(
            title: p.name,
            child: OiLabel.body(p.price),
          ))
      .toList(),
)
```

Values cascade down. The grid walks from the active breakpoint toward smaller
ones and uses the first value it finds. With only `compact` and `large` set,
`medium` and `expanded` both resolve to the `compact` value, and `extraLarge`
resolves to `large`.

### Gap and row gap

`gap` sets the space between columns and, by default, between rows too. Pass
`rowGap` when you want a different vertical spacing.

```dart
OiGrid(
  breakpoint: context.breakpoint,
  columns: const OiResponsive<int>(3),
  gap: const OiResponsive<double>(16),    // horizontal
  rowGap: const OiResponsive<double>(24), // vertical
  children: cards,
)
```

Gaps are responsive as well. Use a smaller gap on compact screens.

```dart
gap: OiResponsive.breakpoints({
  OiBreakpoint.compact: 8,
  OiBreakpoint.expanded: 16,
}),
```

### Sizing columns by width

Instead of a fixed count, let the grid decide how many columns fit. Set
`minColumnWidth` and the grid packs in as many columns as it can while keeping
each column at least that wide. This is handy for card galleries that should
stay readable at any width.

```dart
OiGrid(
  breakpoint: context.breakpoint,
  minColumnWidth: const OiResponsive<double>(240),
  gap: const OiResponsive<double>(16),
  children: cards,
)
```

`columns` and `minColumnWidth` are mutually exclusive. Set one, not both. If you
set neither, the grid uses a single column.

### Making cards the same height

By default each row is as tall as its tallest child. Cards in the same row can
end up different heights. Set `stretchRows: true` to pull every child in a row up
to the row height, so a card grid lines up cleanly.

```dart
OiGrid(
  breakpoint: context.breakpoint,
  columns: const OiResponsive<int>(3),
  gap: const OiResponsive<double>(16),
  stretchRows: true,
  children: cards,
)
```

### Spanning columns

A child can occupy more than one column. Wrap it with the `.span()` extension.
Use `spanFull()` as a shorthand for spanning every column.

```dart
OiGrid(
  breakpoint: context.breakpoint,
  columns: const OiResponsive<int>(3),
  gap: const OiResponsive<double>(16),
  children: [
    OiCard(child: OiLabel.body('Wide')).span(
      columnSpan: const OiResponsive<int>(2),
    ),
    OiCard(child: OiLabel.body('Narrow')),
    OiCard(child: OiLabel.body('Full-width banner')).spanFull(),
  ],
)
```

`.span()` takes four responsive values. Placement can change per breakpoint.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `columnSpan` | `OiResponsive<int>?` | `1` | How many columns the child covers. |
| `columnStart` | `OiResponsive<int>?` | auto | Explicit start column, 1-indexed. `null` auto-places. |
| `columnOrder` | `OiResponsive<int>?` | source order | Lower values render first. |
| `rowSpan` | `OiResponsive<int>?` | `1` | How many rows the child covers. |

```dart
OiCard(child: OiLabel.body('Hero')).span(
  columnSpan: OiResponsive.breakpoints({
    OiBreakpoint.compact: 1,
    OiBreakpoint.medium: 2,
  }),
)
```

### Container-relative grids

The default constructor reads the breakpoint from the viewport. Inside a panel or
a split view, the viewport width is not what you want. `OiGrid.containerRelative`
resolves the breakpoint from the grid's own width instead. It re-lays out when
that width changes and ignores unrelated viewport changes.

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

Note that this constructor does not take a `breakpoint`. It computes one from
constraints.

### OiGrid attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `breakpoint` | `OiBreakpoint` | **required** | The active breakpoint. Not used by `containerRelative`. |
| `children` | `List<Widget>` | **required** | The items to place. |
| `columns` | `OiResponsive<int>?` | `null` | Fixed column count. Exclusive with `minColumnWidth`. |
| `minColumnWidth` | `OiResponsive<double>?` | `null` | Minimum column width in logical pixels. |
| `gap` | `OiResponsive<double>` | `0` | Space between columns, and rows when `rowGap` is null. |
| `rowGap` | `OiResponsive<double>?` | `null` | Vertical gap. Falls back to `gap`. |
| `stretchRows` | `bool` | `false` | Force every child in a row to the row height. |
| `scale` | `OiBreakpointScale` | `defaultScale` | Breakpoint scale for resolving responsive values. |

!!! note
    Use `OiGrid` for a small, non-scrolling set of items that fit on screen. For
    long, scrolling lists of thousands of items, reach for a virtualized grid
    instead.

## OiMasonry

`OiMasonry` places children in vertical columns of unequal height. Each column
flows on its own, so tiles pack tightly without matching heights. Reach for it
with image galleries and note cards, where every tile has a different size.

```dart
OiMasonry(
  breakpoint: context.breakpoint,
  columns: OiResponsive.breakpoints({
    OiBreakpoint.compact: 2,
    OiBreakpoint.expanded: 3,
  }),
  gap: const OiResponsive<double>(12),
  children: photos
      .map((p) => OiCard(child: OiLabel.body(p.caption)))
      .toList(),
)
```

Items are handed out across the columns round-robin. Item 0 goes to column 0,
item 1 to column 1, and so on. A child with `columnStart` set drops into that
column instead.

A child with `columnSpan` greater than 1 is not placed inside a column. It
renders as a full-width band between the masonry sections above and below it. Use
that for a heading or a featured card that should break the flow.

```dart
OiMasonry(
  breakpoint: context.breakpoint,
  columns: const OiResponsive<int>(3),
  gap: const OiResponsive<double>(12),
  children: [
    OiCard(child: OiLabel.body('Tile')),
    OiLabel.h2('Featured').span(columnSpan: const OiResponsive<int>(3)),
    OiCard(child: OiLabel.body('Another tile')),
  ],
)
```

### OiMasonry attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `breakpoint` | `OiBreakpoint` | **required** | The active breakpoint. |
| `children` | `List<Widget>` | **required** | The tiles to distribute. |
| `columns` | `OiResponsive<int>` | `2` | Number of vertical columns. |
| `gap` | `OiResponsive<double>` | `0` | Space between columns and between tiles. |
| `scale` | `OiBreakpointScale` | `defaultScale` | Breakpoint scale for resolving responsive values. |

!!! tip
    Use `OiGrid` when rows should line up and cells share a height. Use
    `OiMasonry` when heights vary and you want tight vertical packing.

## Related

- [Flex Layout](flex.md) for `OiRow` and `OiColumn` with responsive gaps.
- [Page and Section](page-and-section.md) for the outer page wrapper and content groups.
- [Display](../widgets/display.md) for `OiCard` and other tiles you place in a grid.
