# Rows & Columns

`OiRow` and `OiColumn` are the layout primitives you reach for every day. They
place children in a row or a column with a gap between them. The gap can change
per breakpoint, and both can swap their axis on small screens. `OiWrapLayout`
handles chip and tag layouts that flow onto more than one line. `OiSpacer`
gives you a flexible or fixed gap inside a row or column.

Use these instead of raw `Row` and `Column`. You get a theme-friendly gap
between children, so you stop scattering `SizedBox(height: 16)` between every
child. You also get responsive spacing and axis-swap behavior with no extra
wiring.

| Widget | What it does |
| --- | --- |
| `OiRow` | Horizontal layout with a gap. Can stack into a column on small screens. |
| `OiColumn` | Vertical layout with a gap. Can expand into a row on wide screens. |
| `OiWrapLayout` | Flows children onto multiple lines. For chips, tags, and pills. |
| `OiSpacer` | A flexible or fixed gap between children in a row or column. |

## The breakpoint parameter

Every widget on this page takes a required `breakpoint`. This is by design.
Each layout is self-contained, with no hidden context lookup. Resolve the
active breakpoint once at the top of your page, then pass it down.

```dart
final breakpoint = context.breakpoint;
```

Spacing values use `OiResponsive<double>`. Pass a single value for a fixed gap,
or a map to vary the gap across breakpoints.

```dart
// Same gap everywhere.
const OiResponsive<double>(16)

// Different gap per breakpoint.
OiResponsive.breakpoints({
  OiBreakpoint.compact: 8,
  OiBreakpoint.expanded: 16,
})
```

## OiRow

A horizontal layout. It places children in a row with `gap` logical pixels
between them. Reach for it to group buttons, icons, and labels side by side.

```dart
OiRow(
  breakpoint: context.breakpoint,
  gap: const OiResponsive<double>(12),
  children: [
    OiButton.ghost(label: 'Cancel', onTap: () {}),
    OiButton.primary(label: 'Save', onTap: () {}),
  ],
)
```

The gap can respond to the breakpoint. A tighter gap on small screens, a wider
one on large screens.

```dart
OiRow(
  breakpoint: context.breakpoint,
  gap: OiResponsive.breakpoints({
    OiBreakpoint.compact: 8,
    OiBreakpoint.expanded: 12,
  }),
  children: [
    OiIconButton(icon: OiIcons.edit, semanticLabel: 'Edit', onTap: () {}),
    OiIconButton(icon: OiIcons.share, semanticLabel: 'Share', onTap: () {}),
  ],
)
```

`OiRow` defaults to `MainAxisSize.min`, so it shrink-wraps its children. That
lets it nest inside other layouts without unbounded-constraint errors.

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `breakpoint` | `OiBreakpoint` | **required** | The active breakpoint. Resolve once, pass down. |
| `children` | `List<Widget>` | **required** | The children to lay out. |
| `gap` | `OiResponsive<double>` | `0` | Space between children in logical pixels. |
| `mainAxisAlignment` | `MainAxisAlignment` | `start` | Alignment along the horizontal axis. |
| `crossAxisAlignment` | `CrossAxisAlignment` | `center` | Alignment along the vertical axis. |
| `mainAxisSize` | `MainAxisSize` | `min` | Set to `max` to fill the available width. |
| `collapse` | `OiBreakpoint?` | `null` | Stack into a column at or below this breakpoint. See below. |
| `scale` | `OiBreakpointScale` | `defaultScale` | The scale used to resolve responsive values. |

## OiColumn

A vertical layout. It places children in a column with `gap` between them.
Reach for it to stack form fields, list rows, and card content.

```dart
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

Like `OiRow`, it defaults to `MainAxisSize.min` and takes the same alignment
parameters.

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `breakpoint` | `OiBreakpoint` | **required** | The active breakpoint. Resolve once, pass down. |
| `children` | `List<Widget>` | **required** | The children to lay out. |
| `gap` | `OiResponsive<double>` | `0` | Space between children in logical pixels. |
| `mainAxisAlignment` | `MainAxisAlignment` | `start` | Alignment along the vertical axis. |
| `crossAxisAlignment` | `CrossAxisAlignment` | `center` | Alignment along the horizontal axis. |
| `mainAxisSize` | `MainAxisSize` | `min` | Set to `max` to fill the available height. |
| `collapse` | `OiBreakpoint?` | `null` | Expand into a row at or above this breakpoint. See below. |
| `scale` | `OiBreakpointScale` | `defaultScale` | The scale used to resolve responsive values. |

## Collapsing on small screens

Both widgets take an optional `collapse` breakpoint. It swaps the axis at a
threshold. The gap is kept, so it becomes spacing in the new direction. The
`collapse` value names the threshold where the axis flips, not the resulting
direction.

`OiRow` stacks into a column when the active breakpoint is at or below
`collapse`. Use it for side-by-side panels that should stack on phones.

```dart
OiRow(
  breakpoint: context.breakpoint,
  collapse: OiBreakpoint.medium, // Stack vertically at medium and below.
  gap: const OiResponsive<double>(16),
  children: [
    SidePanel(),
    MainContent(),
  ],
)
```

`OiColumn` expands into a row when the active breakpoint is at or above
`collapse`. Use it for label and value pairs that sit side by side on wide
screens.

```dart
OiColumn(
  breakpoint: context.breakpoint,
  collapse: OiBreakpoint.expanded, // Side by side at expanded and up.
  gap: const OiResponsive<double>(16),
  children: [
    OiLabel.caption('Status'),
    OiLabel.body('Active'),
  ],
)
```

!!! tip
    Pick the widget that matches the default layout of your content. Start with
    `OiRow` if the content is a row most of the time. Start with `OiColumn` if
    it is a column most of the time. Then set `collapse` for the other case.

## OiWrapLayout

A layout that flows children onto more than one line. When a child does not fit
on the current line, it moves to the next. Reach for it to lay out tags, chips,
badges, and filter pills.

```dart
OiWrapLayout(
  breakpoint: context.breakpoint,
  spacing: const OiResponsive<double>(8),    // Gap between children in a line.
  runSpacing: const OiResponsive<double>(8), // Gap between lines.
  children: tags
      .map((tag) => OiBadge.soft(label: tag, color: OiBadgeColor.neutral))
      .toList(),
)
```

`spacing` is the gap between children along the main axis. `runSpacing` is the
gap between the lines (runs). Both accept responsive values. Set
`direction: Axis.vertical` to flow children top to bottom and wrap into
columns.

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `breakpoint` | `OiBreakpoint` | **required** | The active breakpoint. |
| `children` | `List<Widget>` | **required** | The children to wrap. |
| `spacing` | `OiResponsive<double>` | `0` | Gap between children within a line. |
| `runSpacing` | `OiResponsive<double>` | `0` | Gap between lines. |
| `alignment` | `WrapAlignment` | `start` | Alignment of children within a line. |
| `runAlignment` | `WrapAlignment` | `start` | Alignment of the lines along the cross axis. |
| `crossAxisAlignment` | `WrapCrossAlignment` | `start` | Cross-axis alignment of children within a line. |
| `direction` | `Axis` | `horizontal` | The primary axis. |
| `scale` | `OiBreakpointScale` | `defaultScale` | The scale used to resolve responsive values. |

## OiSpacer

A gap inside a row or column. Use it to push children apart, or to add a fixed
gap that changes per breakpoint. It is the theme-aware version of `Spacer` and
`SizedBox`.

With no size and no flex, it fills the available space like `Spacer`. This
pushes the two labels to opposite ends of the row.

```dart
OiRow(
  breakpoint: context.breakpoint,
  mainAxisSize: MainAxisSize.max,
  children: [
    OiLabel.body('Total'),
    OiSpacer(breakpoint: context.breakpoint),
    OiLabel.body('\$42.00'),
  ],
)
```

Use the `flex` constructor to divide space by a factor. A spacer with `flex: 2`
takes twice the space of a spacer with `flex: 1`.

```dart
OiSpacer.flex()        // flex: 1
OiSpacer.flex(flex: 2) // twice the space
```

Pass a `size` for a fixed gap. Set `axis` to match the direction of the parent.
Use `Axis.horizontal` inside an `OiRow` and `Axis.vertical` inside an
`OiColumn`.

```dart
OiSpacer(
  breakpoint: context.breakpoint,
  axis: Axis.horizontal,
  size: OiResponsive.breakpoints({
    OiBreakpoint.compact: 8,
    OiBreakpoint.expanded: 24,
  }),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `breakpoint` | `OiBreakpoint` | **required** | The active breakpoint. |
| `size` | `OiResponsive<double>?` | `null` | Fixed gap in logical pixels. Used when `flex` is null. |
| `flex` | `int?` | `null` | Flex factor for a flexible gap. Takes precedence over `size`. |
| `axis` | `Axis` | `vertical` | The axis a fixed-size spacer expands along. Ignored when `flex` is set. |
| `scale` | `OiBreakpointScale` | `defaultScale` | The scale used to resolve responsive values. |

!!! note
    A flex spacer only works inside a flex parent, such as an `OiRow` or
    `OiColumn`. The parent must have room to give, so set its `mainAxisSize` to
    `MainAxisSize.max` when you want the spacer to push children apart.

## When to use which

| Widget | Use for |
| --- | --- |
| `OiRow` | Horizontal groups: buttons, icons, labels. Side-by-side panels that stack on small screens via `collapse`. |
| `OiColumn` | Vertical groups: form fields, list rows. Label and value pairs that expand into a row on wide screens via `collapse`. |
| `OiWrapLayout` | Tags, chips, badges, filter pills. Content that wraps onto more than one line. |
| `OiSpacer` | A flexible or fixed gap inside a row or column. |
| `OiGrid` | Fixed-column layouts with per-child span and start control. See [Grid](grid.md). |

For multi-column layouts, dashboard cards, and product grids, reach for
`OiGrid` instead of nesting rows and columns. It gives you `columnSpan`,
`columnStart`, and `rowSpan` control.

## Related

- [Grid](grid.md) for multi-column and dashboard layouts.
- [Buttons & Actions](../widgets/buttons.md) for the buttons you group in a row.
