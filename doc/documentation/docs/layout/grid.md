# Grid System

`OiGrid` is the primary layout widget for multi-column layouts. It behaves like CSS Grid — you define columns, and children fill them in order with optional span control.

## Basic grid

```dart
OiGrid(
  columns: 3,
  gap: context.spacing.md,
  children: [
    CardWidget(),
    CardWidget(),
    CardWidget(),
    CardWidget(),  // Wraps to second row
  ],
)
```

## Responsive columns

Use `OiResponsive` to change the column count at different breakpoints:

```dart
OiGrid(
  columns: OiResponsive({
    OiBreakpoint.compact: 1,
    OiBreakpoint.medium: 2,
    OiBreakpoint.expanded: 3,
    OiBreakpoint.large: 4,
  }),
  gap: context.spacing.md,
  children: cards,
)
```

Values cascade upward — define `compact` and `expanded`, and medium inherits from compact while large inherits from expanded.

## Spanning columns

Use `OiSpan` to make a child span multiple columns:

```dart
OiGrid(
  columns: 3,
  gap: context.spacing.md,
  children: [
    OiSpan(
      columnSpan: 2,  // Spans 2 of 3 columns
      child: WideCard(),
    ),
    NarrowCard(),
    OiSpan(
      columnSpan: 3,  // Full width
      child: FullWidthBanner(),
    ),
  ],
)
```

## Span options

`OiSpan` supports:

| Property | Description |
|---|---|
| `columnSpan` | Number of columns to span |
| `columnStart` | Explicit column start position |
| `columnOrder` | Override visual order |
| `rowSpan` | Number of rows to span |

All properties accept `OiResponsive` values for per-breakpoint control.

## Masonry layout

For content with variable heights (images, cards), use `OiMasonry`:

```dart
OiMasonry(
  columns: OiResponsive({
    OiBreakpoint.compact: 2,
    OiBreakpoint.expanded: 3,
  }),
  gap: context.spacing.md,
  children: imageCards,
)
```

Unlike `OiGrid`, masonry fills columns top-to-bottom by shortest column, avoiding empty gaps.
