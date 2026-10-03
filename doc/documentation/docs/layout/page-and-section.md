# Page & Section

These primitives frame a screen. `OiPage` is the outermost vertical layout.
`OiSection` groups related content with spacing. `OiContainer` limits how wide
the content grows. `OiAspectRatio` locks a child to a fixed shape.

All four follow the library's zero magic rule. The active `breakpoint` is a
required parameter. Resolve it once at the top of your screen with
`context.breakpoint`, then pass it down to every layout primitive.

| Widget | What it does |
| --- | --- |
| `OiPage` | The outermost vertical layout for a screen. Fills its parent. |
| `OiSection` | Groups children vertically with a gap and an optional semantic label. |
| `OiContainer` | Caps content width and centers it, with optional padding. |
| `OiAspectRatio` | Forces a child to a width-to-height ratio. |

## OiPage

The outermost layout for a screen. It stacks its `children` in a column and
inserts a responsive `gap` between them. Reach for it as the root of a screen
body.

```dart
OiPage(
  breakpoint: context.breakpoint,
  gap: const OiResponsive<double>(24),
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

`OiPage` fills its parent by default (`mainAxisSize: MainAxisSize.max`) and
stretches children to the full width (`crossAxisAlignment:
CrossAxisAlignment.stretch`). Set `mainAxisSize` to `MainAxisSize.min` when you
nest a page inside another layout.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `breakpoint` | `OiBreakpoint` | **required** | The active breakpoint. Pass `context.breakpoint`. |
| `children` | `List<Widget>` | **required** | The widgets to stack vertically. |
| `gap` | `OiResponsive<double>` | `OiResponsive<double>(0)` | Space inserted between children. |
| `padding` | `OiResponsive<EdgeInsetsGeometry>?` | `null` | Padding around the content. |
| `crossAxisAlignment` | `CrossAxisAlignment` | `stretch` | How children align across the page. |
| `mainAxisSize` | `MainAxisSize` | `max` | Use `min` when nesting inside another layout. |
| `scale` | `OiBreakpointScale` | `defaultScale` | The scale used to resolve responsive values. |

!!! note
    `OiPage` does not scroll on its own, and it does not cap content width. Wrap
    it in a `SingleChildScrollView` for scrolling. Wrap it in an `OiContainer`
    to cap the width.

## OiSection

Groups a set of related widgets. It stacks `children` in a column with a
responsive `gap` and renders a `Semantics` container. Pass `semanticLabel` so
assistive technology can announce the group.

```dart
OiSection(
  breakpoint: context.breakpoint,
  semanticLabel: 'Account details',
  gap: const OiResponsive<double>(16),
  children: [
    OiLabel.h3('Account details'),
    OiTextInput(label: 'Email'),
    OiTextInput(label: 'Display name'),
  ],
)
```

`OiSection` shrink-wraps its children by default (`mainAxisSize:
MainAxisSize.min`), so it nests inside other layouts without unbounded-height
errors. It aligns children to the start of the cross axis.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `breakpoint` | `OiBreakpoint` | **required** | The active breakpoint. |
| `children` | `List<Widget>` | **required** | The widgets to stack vertically. |
| `gap` | `OiResponsive<double>` | `OiResponsive<double>(0)` | Space inserted between children. |
| `padding` | `OiResponsive<EdgeInsetsGeometry>?` | `null` | Padding around the section. |
| `crossAxisAlignment` | `CrossAxisAlignment` | `start` | How children align across the section. |
| `mainAxisSize` | `MainAxisSize` | `min` | Shrink-wraps children so the section nests safely. |
| `semanticLabel` | `String?` | `null` | Label announced by screen readers. |
| `scale` | `OiBreakpointScale` | `defaultScale` | The scale used to resolve responsive values. |

!!! note
    `OiSection` does not draw a visible header, title, icon, or divider. It is a
    structural and semantic group. Build a visible heading from `OiLabel.h2` or
    `OiLabel.h3` as the first child.

## OiContainer

Caps how wide the content grows and centers it. Use it around an `OiPage` so
text and forms stay readable on wide screens. It is a layout wrapper, not a
themed box.

```dart
OiContainer(
  breakpoint: context.breakpoint,
  maxWidth: OiResponsive.breakpoints({
    OiBreakpoint.compact: double.infinity,
    OiBreakpoint.expanded: 960,
    OiBreakpoint.large: 1200,
  }),
  child: OiPage(
    breakpoint: context.breakpoint,
    children: [/* ... */],
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `breakpoint` | `OiBreakpoint` | **required** | The active breakpoint. |
| `child` | `Widget?` | `null` | The content to constrain. |
| `maxWidth` | `OiResponsive<double>?` | `null` | Maximum content width per breakpoint. |
| `padding` | `OiResponsive<EdgeInsetsGeometry>?` | `null` | Padding around the child. |
| `centered` | `bool` | `true` | Center the child horizontally. Set `false` to align left. |
| `scale` | `OiBreakpointScale` | `defaultScale` | The scale used to resolve responsive values. |

## OiAspectRatio

Forces a child to a width-to-height ratio. It wraps Flutter's `AspectRatio` with
a named `ratio` parameter. Reach for it around images, video, and map tiles.

```dart
OiAspectRatio(
  breakpoint: context.breakpoint,
  ratio: OiResponsive.breakpoints({
    OiBreakpoint.compact: 4 / 3,
    OiBreakpoint.expanded: 16 / 9,
  }),
  child: OiSurface(
    color: context.colors.surfaceSubtle,
    child: const SizedBox.expand(),
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `breakpoint` | `OiBreakpoint` | **required** | The active breakpoint. |
| `ratio` | `OiResponsive<double>` | **required** | Width divided by height, for example `16 / 9`. |
| `child` | `Widget` | **required** | The widget to constrain. |
| `scale` | `OiBreakpointScale` | `defaultScale` | The scale used to resolve responsive values. |

## A full screen

Here is a screen assembled from the pieces above. `OiContainer` caps the width.
`SingleChildScrollView` handles scrolling. `OiPage` stacks the sections. Each
`OiSection` groups one block of content.

```dart
@override
Widget build(BuildContext context) {
  final breakpoint = context.breakpoint;

  return SingleChildScrollView(
    child: OiContainer(
      breakpoint: breakpoint,
      maxWidth: OiResponsive.breakpoints({
        OiBreakpoint.compact: double.infinity,
        OiBreakpoint.expanded: 1040,
      }),
      padding: OiResponsive.breakpoints({
        OiBreakpoint.compact: EdgeInsets.all(16),
        OiBreakpoint.expanded: EdgeInsets.all(32),
      }),
      child: OiPage(
        breakpoint: breakpoint,
        gap: const OiResponsive<double>(24),
        children: [
          OiSection(
            breakpoint: breakpoint,
            semanticLabel: 'Header',
            gap: const OiResponsive<double>(8),
            children: [
              OiRow(
                breakpoint: breakpoint,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OiLabel.h1('Projects'),
                  OiButton.primary(label: 'New project', onTap: createProject),
                ],
              ),
              OiLabel.body('Everything your team is working on.'),
            ],
          ),
          OiSection(
            breakpoint: breakpoint,
            semanticLabel: 'Project grid',
            gap: const OiResponsive<double>(16),
            children: [
              OiGrid(
                breakpoint: breakpoint,
                columns: OiResponsive.breakpoints({
                  OiBreakpoint.compact: 1,
                  OiBreakpoint.medium: 2,
                  OiBreakpoint.expanded: 3,
                }),
                gap: const OiResponsive<double>(16),
                children: [
                  for (final project in projects)
                    OiCard(
                      title: project.name,
                      child: OiLabel.body(project.summary),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
```

## Related

- [Grid](grid.md) for multi-column layouts inside a section.
- [Flex](flex.md) for `OiRow` and `OiColumn`.
