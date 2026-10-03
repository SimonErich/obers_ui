# Responsive Design

ObersUI adapts to screen size through a small set of tools. You classify the
screen into one of five breakpoints, then let values and layouts change per
breakpoint. This page covers the breakpoints, the `OiResponsive<T>` value type,
the `BuildContext` helpers, and how `OiGrid`, `OiRow`, and `OiColumn` respond.

## Breakpoints

A breakpoint is a named width tier. The library ships five standard tiers as
constants on `OiBreakpoint`. Each one activates at a minimum viewport width.

| Breakpoint | Min width (dp) | Typical device |
| --- | --- | --- |
| `OiBreakpoint.compact` | 0 | Phones in portrait |
| `OiBreakpoint.medium` | 600 | Large phones, small tablets |
| `OiBreakpoint.expanded` | 840 | Tablets, small desktops |
| `OiBreakpoint.large` | 1200 | Desktops |
| `OiBreakpoint.extraLarge` | 1600 | Wide monitors |

A tier stays active until the next one starts. So `medium` covers 600 to 839,
and `large` covers 1200 to 1599. The `compact` tier is the base, and it always
starts at width 0.

The five tiers live in `OiBreakpointScale.defaultScale`, which every layout
primitive uses by default. You can define your own scale and pass it in with a
`scale:` parameter, but most apps use the standard one.

## OiResponsive

`OiResponsive<T>` holds a value that can change per breakpoint. Any responsive
parameter, like a grid's column count or a row's gap, takes one of these. You
build it in one of two ways.

A static value is the same at every breakpoint.

```dart
const OiResponsive(3); // always 3
```

A per-breakpoint value uses the `breakpoints` constructor. Give it a map from
breakpoint to value.

```dart
OiResponsive.breakpoints({
  OiBreakpoint.compact: 1,
  OiBreakpoint.medium: 2,
  OiBreakpoint.expanded: 3,
  OiBreakpoint.large: 4,
});
```

Values cascade upward from smaller tiers. If you set only `compact` and
`expanded`, then `medium` inherits from `compact`, and `large` and `extraLarge`
inherit from `expanded`. This is mobile-first: you define the smallest layout,
then override it as space grows.

### Shorthand extensions

A map of breakpoints has a `.responsive` getter for inline use.

```dart
{
  OiBreakpoint.compact: 1,
  OiBreakpoint.expanded: 3,
}.responsive
```

Plain numbers and bools also have a `.responsive` getter that wraps them in a
static `OiResponsive`.

```dart
3.responsive     // OiResponsive<int>(3)
16.0.responsive  // OiResponsive<double>(16.0)
```

### Constructors and members

| Member | Type | Description |
| --- | --- | --- |
| `OiResponsive(value)` | constructor | Same value at every breakpoint. |
| `OiResponsive.breakpoints(map, {defaultValue})` | constructor | Per-breakpoint values with mobile-first cascade. `defaultValue` is a base fallback. |
| `resolve(breakpoint, scale)` | `T` | The value for a given breakpoint. |
| `isStatic` | `bool` | Whether the value is the same everywhere. |

!!! tip
    Resolve a responsive value once at the page level, then pass the concrete
    result down. `context.responsive(myValue)` does this in one call.

## Reading the breakpoint

The active breakpoint depends on the viewport width. Read it and related
helpers from `BuildContext`. These need an `OiApp` or `OiTheme` ancestor, which
your app already has at the root.

```dart
final bp = context.breakpoint;      // the active OiBreakpoint
final width = context.viewportWidth; // raw width in logical pixels
```

Boolean getters tell you the current tier. Each one is true only when that
exact tier is active.

```dart
context.isCompact   // true on phones (0 to 599)
context.isMedium    // true from 600 to 839
context.isExpanded  // true from 840 to 1199
context.isLarge     // true from 1200 to 1599
```

For "this tier or wider" checks, use the `OrWider` getters or `atLeast`.

```dart
if (context.isExpandedOrWider) {
  // 840dp and up
}

if (context.atLeast(OiBreakpoint.large)) {
  // 1200dp and up
}
```

To resolve a responsive value against the current screen, call
`context.responsive`.

```dart
final columns = context.responsive(OiResponsive.breakpoints({
  OiBreakpoint.compact: 1,
  OiBreakpoint.medium: 2,
  OiBreakpoint.large: 4,
}));
```

| Getter or method | Returns | Description |
| --- | --- | --- |
| `breakpoint` | `OiBreakpoint` | The active tier. |
| `viewportWidth` | `double` | Raw width in logical pixels. |
| `isCompact` / `isMedium` / `isExpanded` / `isLarge` / `isExtraLarge` | `bool` | True when that exact tier is active. |
| `isMediumOrWider` / `isExpandedOrWider` / `isLargeOrWider` | `bool` | True at that tier and wider. |
| `atLeast(bp)` | `bool` | True when the active tier is at least as wide as `bp`. |
| `responsive(value)` | `T` | Resolves an `OiResponsive` for the current screen. |

## OiGrid

`OiGrid` lays out children in columns. Set `columns` to an `OiResponsive<int>`
so the count changes with screen size. The grid needs a `breakpoint`. Resolve
it once with `context.breakpoint` and pass it down.

```dart
OiGrid(
  breakpoint: context.breakpoint,
  gap: 16.0.responsive,
  columns: OiResponsive.breakpoints({
    OiBreakpoint.compact: 1,
    OiBreakpoint.medium: 2,
    OiBreakpoint.expanded: 3,
    OiBreakpoint.large: 4,
  }),
  children: cards,
)
```

Instead of a fixed count, you can set `minColumnWidth`. The grid then fits as
many columns as the width allows, each at least that wide. Pass either
`columns` or `minColumnWidth`, not both.

```dart
OiGrid(
  breakpoint: context.breakpoint,
  minColumnWidth: 240.0.responsive,
  gap: 16.0.responsive,
  children: cards,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `breakpoint` | `OiBreakpoint` | **required** | The active tier. Use `context.breakpoint`. |
| `children` | `List<Widget>` | **required** | The grid items. |
| `columns` | `OiResponsive<int>?` | `null` | Column count per breakpoint. |
| `minColumnWidth` | `OiResponsive<double>?` | `null` | Minimum column width. Fits as many as possible. |
| `gap` | `OiResponsive<double>` | `0` | Horizontal spacing between columns. |
| `rowGap` | `OiResponsive<double>?` | `null` | Vertical spacing. Falls back to `gap`. |
| `stretchRows` | `bool` | `false` | Stretch cells in a row to equal height. |
| `scale` | `OiBreakpointScale` | `defaultScale` | The breakpoint scale to resolve against. |

## OiRow and OiColumn

`OiRow` and `OiColumn` lay children out with a responsive `gap`. Both take a
required `breakpoint`. Both can collapse to the other axis at small sizes.

Set `collapse` on an `OiRow` to a breakpoint. When the active tier is at or
below that breakpoint, the row renders as a column. This turns a side-by-side
layout into a stacked one on phones.

```dart
OiRow(
  breakpoint: context.breakpoint,
  gap: 16.0.responsive,
  collapse: OiBreakpoint.medium, // stacks at medium and below
  children: [
    OiButton.primary(label: 'Save', onTap: save),
    OiButton.outline(label: 'Cancel', onTap: cancel),
  ],
)
```

`OiColumn` works the other way. When you set `collapse`, the column renders as a
row once the active tier is at or above that breakpoint.

```dart
OiColumn(
  breakpoint: context.breakpoint,
  gap: 12.0.responsive,
  collapse: OiBreakpoint.expanded, // becomes a row at expanded and up
  children: [
    OiLabel.body('First'),
    OiLabel.body('Second'),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `breakpoint` | `OiBreakpoint` | **required** | The active tier. Use `context.breakpoint`. |
| `children` | `List<Widget>` | **required** | The items to lay out. |
| `gap` | `OiResponsive<double>` | `0` | Spacing between children. |
| `collapse` | `OiBreakpoint?` | `null` | The tier at which the layout switches axis. |
| `mainAxisAlignment` | `MainAxisAlignment` | `start` | Alignment along the main axis. |
| `crossAxisAlignment` | `CrossAxisAlignment` | `center` | Alignment across the main axis. |
| `mainAxisSize` | `MainAxisSize` | `min` | How much main-axis space to take. |
| `scale` | `OiBreakpointScale` | `defaultScale` | The breakpoint scale to resolve against. |

## A phone-to-desktop layout

Here is a screen that changes shape between phone and desktop. On a phone it
stacks the sidebar above the content. On a desktop it places them side by side
and widens the card grid. Resolve the breakpoint once at the top, then branch.

```dart
class Dashboard extends StatelessWidget {
  const Dashboard({super.key, required this.cards});

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    final bp = context.breakpoint;

    final grid = OiGrid(
      breakpoint: bp,
      gap: 16.0.responsive,
      columns: OiResponsive.breakpoints({
        OiBreakpoint.compact: 1,
        OiBreakpoint.medium: 2,
        OiBreakpoint.large: 3,
      }),
      children: cards,
    );

    final sidebar = OiSurface(
      color: context.colors.surface,
      child: OiColumn(
        breakpoint: bp,
        gap: 8.0.responsive,
        children: [
          OiLabel.h3('Filters'),
          OiLabel.body('Narrow the results shown on the right.'),
        ],
      ),
    );

    // Side by side on wide screens, stacked on phones.
    return OiRow(
      breakpoint: bp,
      gap: 24.0.responsive,
      collapse: OiBreakpoint.medium,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [sidebar, grid],
    );
  }
}
```

The row collapses to a column at `medium` and below, so the sidebar sits above
the grid on phones. The grid grows from one column to three as the screen
widens. You wrote the breakpoint logic once, and every child read the same
resolved tier.

!!! note
    A common mistake is to read `context.breakpoint` inside every child widget.
    Resolve it once at the page level and pass it down. That keeps the layout
    consistent and avoids repeated `MediaQuery` reads.

## Related

- [Theming](theming.md) for `context.colors`, spacing, and radius tokens.
- [Flex Layouts](../layout/flex.md) for `OiRow` and `OiColumn` in full.
- [Layout System](../layout/index.md) for the full set of layout primitives.
