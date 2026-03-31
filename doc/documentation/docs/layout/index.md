# Layout System

ObersUI provides a set of layout primitives that make building responsive, well-structured pages straightforward. No need to wrestle with raw `Row`, `Column`, and `Expanded` — the layout widgets handle gaps, responsive behavior, and semantic grouping for you.

## Layout widgets

| Widget | Purpose | Guide |
| --- | --- | --- |
| `OiGrid` | Responsive multi-column grid with span control | [Grid](grid.md) |
| `OiPage` | Max-width centered page container | [Page & Section](page-and-section.md) |
| `OiSection` | Content group with header, aside layout, collapse | [Page & Section](page-and-section.md) |
| `OiRow` | Horizontal flex with gap | [Flex](flex.md) |
| `OiColumn` | Vertical flex with gap | [Flex](flex.md) |
| `OiFlex` | Advanced flex with grow/fixed children | [Flex](flex.md) |
| `OiWrapLayout` | Flow/wrap layout | [Flex](flex.md) |
| `OiMasonry` | Pinterest-style masonry layout | [Grid](grid.md) |

## Quick example

A typical responsive page layout:

```dart
OiPage(
  children: [
    OiSection(
      title: 'Dashboard',
      description: 'Overview of your project metrics',
      child: OiGrid(
        columns: OiResponsive({
          OiBreakpoint.compact: 1,
          OiBreakpoint.medium: 2,
          OiBreakpoint.large: 3,
        }),
        gap: context.spacing.md,
        children: [
          MetricCard(title: 'Users', value: '1,234'),
          MetricCard(title: 'Revenue', value: '\$56k'),
          MetricCard(title: 'Growth', value: '+12%'),
        ],
      ),
    ),
  ],
)
```
