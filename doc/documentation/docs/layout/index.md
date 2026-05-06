# Layout System

ObersUI provides a set of responsive layout primitives built on top of
Flutter's `Row`, `Column`, and `Wrap`. They share a consistent contract:

- Every primitive takes an explicit `breakpoint` (the library's **zero magic**
  rule — resolve `context.breakpoint` once at the page level and pass it down).
- Numeric / edge-inset values that vary by breakpoint use
  `OiResponsive<T>` — either `OiResponsive(value)` for a static value or
  `OiResponsive.breakpoints({...})` for per-breakpoint values.

## Layout widgets

| Widget | Purpose | Guide |
| --- | --- | --- |
| `OiContainer` | Max-width, centered content wrapper with responsive padding | [Container](#max-width-container) |
| `OiPage` | Vertical page-level layout with responsive gap and padding | [Page & Section](page-and-section.md) |
| `OiSection` | Accessible, semantically-labeled vertical region | [Page & Section](page-and-section.md) |
| `OiGrid` | Responsive multi-column grid with span control | [Grid](grid.md) |
| `OiMasonry` | Pinterest-style masonry layout | [Grid](grid.md) |
| `OiRow` | Horizontal flex with responsive gap; optional collapse to `Column` | [Flex](flex.md) |
| `OiColumn` | Vertical flex with responsive gap; optional expand to `Row` | [Flex](flex.md) |
| `OiWrapLayout` | Flow/wrap layout with responsive spacing | [Flex](flex.md) |

## Max-width container

`OiContainer` is the equivalent of a Tailwind `container` / Bootstrap
`.container` — it constrains its child to a responsive `maxWidth` and
optionally centers it horizontally:

```dart
OiContainer(
  breakpoint: context.breakpoint,
  maxWidth: OiResponsive.breakpoints({
    OiBreakpoint.compact: double.infinity,
    OiBreakpoint.expanded: 960,
    OiBreakpoint.large: 1200,
  }),
  padding: OiResponsive.breakpoints({
    OiBreakpoint.compact: EdgeInsets.all(16),
    OiBreakpoint.expanded: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
  }),
  child: /* your page content */,
)
```

`centered` defaults to `true` (the child is wrapped in a `Center`). Set it
to `false` if you want the constraint without horizontal centering.

## Quick example

A typical responsive page — container for max-width gutters, page for
top-level vertical rhythm, sections for accessible regions, and a grid for
the content inside:

```dart
OiContainer(
  breakpoint: context.breakpoint,
  maxWidth: OiResponsive.breakpoints({
    OiBreakpoint.compact: double.infinity,
    OiBreakpoint.expanded: 1120,
  }),
  padding: OiResponsive.breakpoints({
    OiBreakpoint.compact: EdgeInsets.all(16),
    OiBreakpoint.expanded: EdgeInsets.all(32),
  }),
  child: OiPage(
    breakpoint: context.breakpoint,
    gap: const OiResponsive<double>(24),
    children: [
      OiSection(
        breakpoint: context.breakpoint,
        semanticLabel: 'Dashboard',
        children: [
          OiGrid(
            breakpoint: context.breakpoint,
            columns: OiResponsive.breakpoints({
              OiBreakpoint.compact: 1,
              OiBreakpoint.medium: 2,
              OiBreakpoint.large: 3,
            }),
            gap: const OiResponsive<double>(16),
            children: [
              MetricCard(title: 'Users', value: '1,234'),
              MetricCard(title: 'Revenue', value: '\$56k'),
              MetricCard(title: 'Growth', value: '+12%'),
            ],
          ),
        ],
      ),
    ],
  ),
)
```

Visible titles, descriptions, and action rows aren't built into `OiSection`
— compose them as children. See [Page & Section](page-and-section.md) for
the full `OiSection` contract.
