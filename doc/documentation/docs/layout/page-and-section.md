# Page & Section

`OiPage` and `OiSection` are simple, explicit vertical-layout primitives that
structure content into well-organized, responsive pages.

Both widgets follow the library's **zero magic** principle: the active
`breakpoint` is a required parameter — resolve it once at the page/layout level
(e.g. `context.breakpoint`) and pass it down explicitly.

## OiPage

A full-page vertical layout that arranges `children` in a `Column` with
optional responsive `gap` and `padding`:

```dart
OiPage(
  breakpoint: context.breakpoint,
  gap: OiResponsive.breakpoints({
    OiBreakpoint.compact: 16,
    OiBreakpoint.expanded: 24,
  }),
  padding: OiResponsive.breakpoints({
    OiBreakpoint.compact: EdgeInsets.all(16),
    OiBreakpoint.expanded: EdgeInsets.all(32),
  }),
  children: [
    OiSection(breakpoint: context.breakpoint, children: [/* ... */]),
    OiSection(breakpoint: context.breakpoint, children: [/* ... */]),
  ],
)
```

**What it does:**

- Lays out `children` in a `Column` that fills available space by default
  (`mainAxisSize: MainAxisSize.max`).
- Inserts responsive `gap` spacing between children.
- Optionally applies responsive `padding` around the content.
- Defaults `crossAxisAlignment` to `CrossAxisAlignment.stretch` so children
  fill the page width.

### Parameters

| Parameter | Type | Description |
| --- | --- | --- |
| `breakpoint` | `OiBreakpoint` | **Required.** The active breakpoint. |
| `children` | `List<Widget>` | **Required.** The children to lay out vertically. |
| `gap` | `OiResponsive<double>` | Spacing between children. Defaults to `0`. |
| `padding` | `OiResponsive<EdgeInsetsGeometry>?` | Optional padding around the content. |
| `crossAxisAlignment` | `CrossAxisAlignment` | Defaults to `CrossAxisAlignment.stretch`. |
| `mainAxisSize` | `MainAxisSize` | Defaults to `MainAxisSize.max`. Use `MainAxisSize.min` for nesting. |
| `scale` | `OiBreakpointScale` | Defaults to `OiBreakpointScale.defaultScale`. |

`OiPage` is **not** scrollable on its own. Wrap it in a `SingleChildScrollView`
(or place it inside a scrolling parent) if you need scrolling.

## OiSection

A semantic grouping widget that arranges `children` vertically with optional
responsive `gap` and `padding`. It renders a `Semantics` container so assistive
technologies can announce section boundaries.

```dart
OiSection(
  breakpoint: context.breakpoint,
  semanticLabel: 'Notifications',
  gap: OiResponsive.breakpoints({
    OiBreakpoint.compact: 8,
    OiBreakpoint.expanded: 16,
  }),
  padding: OiResponsive.breakpoints({
    OiBreakpoint.compact: EdgeInsets.all(16),
    OiBreakpoint.expanded: EdgeInsets.all(32),
  }),
  children: [
    // ...
  ],
)
```

### Parameters

| Parameter | Type | Description |
| --- | --- | --- |
| `breakpoint` | `OiBreakpoint` | **Required.** The active breakpoint. |
| `children` | `List<Widget>` | **Required.** The children to lay out vertically. |
| `gap` | `OiResponsive<double>` | Spacing between children. Defaults to `0`. |
| `padding` | `OiResponsive<EdgeInsetsGeometry>?` | Optional padding around the content. |
| `crossAxisAlignment` | `CrossAxisAlignment` | Defaults to `CrossAxisAlignment.start`. |
| `mainAxisSize` | `MainAxisSize` | Defaults to `MainAxisSize.min` — shrink-wraps its children. |
| `semanticLabel` | `String?` | Optional label announced by assistive technologies. |
| `scale` | `OiBreakpointScale` | Defaults to `OiBreakpointScale.defaultScale`. |

`OiSection` does **not** render a visible header, title, icon, description,
actions, or collapsible affordance — it is a structural/semantic primitive
only. Compose visible headings from your own widgets as children.

## Section with grid

Combine sections with [`OiGrid`](./grid) for form layouts:

```dart
OiSection(
  breakpoint: context.breakpoint,
  gap: const OiResponsive<double>(16),
  children: [
    OiGrid(
      breakpoint: context.breakpoint,
      columns: OiResponsive.breakpoints({
        OiBreakpoint.compact: 1,
        OiBreakpoint.medium: 2,
      }),
      gap: const OiResponsive<double>(16),
      children: [
        const OiTextInput(label: 'First Name'),
        const OiTextInput(label: 'Last Name'),
        const OiTextInput(label: 'Email').span(
          columnSpan: OiResponsive<int>(2),
        ),
      ],
    ),
  ],
)
```

Children can be positioned in the grid using the `.span()` extension (or the
`OiSpan` widget) — see the [Grid documentation](./grid) for details on
`columnSpan`, `columnStart`, `columnOrder`, and `rowSpan`.
