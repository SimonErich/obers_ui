# Flex Layouts

ObersUI provides enhanced flex primitives that add responsive gaps and
optional axis-swap behaviour on top of Flutter's built-in layout.

All three primitives require an explicit `breakpoint` and accept
`OiResponsive<T>` values for their spacing.

## OiRow and OiColumn

`OiRow` and `OiColumn` are horizontal and vertical layouts with a `gap`
between children — no more `SizedBox(height: 16)` between every child.

```dart
// Horizontal layout with responsive gap
OiRow(
  breakpoint: context.breakpoint,
  gap: OiResponsive.breakpoints({
    OiBreakpoint.compact: 8,
    OiBreakpoint.expanded: 12,
  }),
  children: [
    OiButton.ghost(label: 'Cancel', onTap: () {}),
    OiButton.primary(label: 'Save', onTap: () {}),
  ],
)

// Vertical layout with a static gap
OiColumn(
  breakpoint: context.breakpoint,
  gap: const OiResponsive<double>(16),
  children: [
    OiTextInput(label: 'Name'),
    OiTextInput(label: 'Email'),
    OiTextInput(label: 'Message', maxLines: 5),
  ],
)
```

Both default to `MainAxisSize.min` so they nest freely inside other layouts
without unbounded-constraint errors.

### Parameters

| Parameter | Type | Description |
| --- | --- | --- |
| `breakpoint` | `OiBreakpoint` | **Required.** The active breakpoint. |
| `children` | `List<Widget>` | **Required.** The children to lay out. |
| `gap` | `OiResponsive<double>` | Spacing between children. Defaults to `0`. |
| `mainAxisAlignment` | `MainAxisAlignment` | Defaults to `start`. |
| `crossAxisAlignment` | `CrossAxisAlignment` | Defaults to `center`. |
| `mainAxisSize` | `MainAxisSize` | Defaults to `MainAxisSize.min`. |
| `collapse` | `OiBreakpoint?` | See below. |
| `scale` | `OiBreakpointScale` | Defaults to `OiBreakpointScale.defaultScale`. |

### Responsive axis swap

Both `OiRow` and `OiColumn` accept an optional `collapse` breakpoint that
swaps their axis at or across that threshold. The gap is preserved — it
becomes horizontal spacing in the swapped direction.

**`OiRow` — collapses into a `Column`** when the active breakpoint is *at or
below* `collapse`:

```dart
OiRow(
  breakpoint: context.breakpoint,
  collapse: OiBreakpoint.medium,  // Stack vertically on compact/medium
  gap: const OiResponsive<double>(16),
  children: [
    SidePanel(),
    MainContent(),
  ],
)
```

**`OiColumn` — expands into a `Row`** when the active breakpoint is *at or
above* `collapse`:

```dart
OiColumn(
  breakpoint: context.breakpoint,
  collapse: OiBreakpoint.expanded, // Side-by-side on expanded and up
  gap: const OiResponsive<double>(16),
  children: [
    LabelWidget(),
    ValueWidget(),
  ],
)
```

Use whichever direction matches the "default" layout of your content — the
`collapse` parameter describes the *threshold* where the axis flips, not the
resulting direction.

## OiWrapLayout

A thin wrapper around Flutter's `Wrap` with responsive spacing:

```dart
OiWrapLayout(
  breakpoint: context.breakpoint,
  spacing: const OiResponsive<double>(8),    // gap along the main axis
  runSpacing: const OiResponsive<double>(8), // gap between runs
  children: tags
      .map((tag) => OiBadge.soft(label: tag, color: OiBadgeColor.neutral))
      .toList(),
)
```

Children flow horizontally (or vertically via `direction: Axis.vertical`)
and wrap to the next run when they run out of space.

### Parameters

| Parameter | Type | Description |
| --- | --- | --- |
| `breakpoint` | `OiBreakpoint` | **Required.** |
| `children` | `List<Widget>` | **Required.** |
| `spacing` | `OiResponsive<double>` | Gap between children within a run. |
| `runSpacing` | `OiResponsive<double>` | Gap between runs. |
| `alignment` | `WrapAlignment` | Main-axis alignment within a run. Defaults to `start`. |
| `runAlignment` | `WrapAlignment` | Cross-axis alignment of runs. Defaults to `start`. |
| `crossAxisAlignment` | `WrapCrossAlignment` | Cross-axis alignment of children within a run. Defaults to `start`. |
| `direction` | `Axis` | Primary axis. Defaults to `Axis.horizontal`. |
| `scale` | `OiBreakpointScale` | |

## When to use which

| Widget | Use for |
| --- | --- |
| `OiGrid` | Multi-column layouts, dashboard cards, form fields |
| `OiRow` | Horizontal groups (buttons, icons, labels); side-by-side panels that stack on compact via `collapse` |
| `OiColumn` | Vertical groups (form fields, list items); label/value pairs that expand into a row on wider screens via `collapse` |
| `OiWrapLayout` | Tags, chips, badges, filter pills — content that should wrap freely |
| `OiMasonry` | Pinterest-style feeds with variable child heights |
| `OiPage` | Top-level page structure |
| `OiSection` | Accessible content regions inside a page |
| `OiContainer` | Max-width / centered wrapper around page content |

For grid-style fixed-column layouts with cross-cutting `columnSpan` /
`columnStart` / `rowSpan` control, reach for `OiGrid` instead — see
[Grid](grid.md).
