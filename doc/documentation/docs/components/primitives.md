# Primitives

Primitives are single-purpose, low-level widgets. They're the building blocks that components and composites are made of. Most users won't use them directly — but they're available when you need fine-grained control.

## Layout

All layout primitives require an explicit `breakpoint:` — the library's zero-magic rule. Resolve once at the page level with `context.breakpoint` and pass it down.

| Widget | Description |
| --- | --- |
| [OiGrid](lib/src/primitives/layout/oi_grid.dart) | Responsive CSS Grid-like layout with column spans |
| [OiRow](lib/src/primitives/layout/oi_row.dart) | Horizontal flex with responsive gap |
| [OiColumn](lib/src/primitives/layout/oi_column.dart) | Vertical flex with responsive gap |
| [OiSection](lib/src/primitives/layout/oi_section.dart) | Semantic grouping — children, gap, padding, semanticLabel |
| [OiPage](lib/src/primitives/layout/oi_page.dart) | Full-page vertical layout with responsive gap and padding |
| [OiContainer](lib/src/primitives/layout/oi_container.dart) | Max-width centered wrapper |
| [OiMasonry](lib/src/primitives/layout/oi_masonry.dart) | Masonry (Pinterest-style) layout |
| [OiAspectRatio](lib/src/primitives/layout/oi_aspect_ratio.dart) | Fixed aspect ratio container |
| [OiSpacer](lib/src/primitives/layout/oi_spacer.dart) | Flexible space |
| [OiWrapLayout](lib/src/primitives/layout/oi_wrap_layout.dart) | Flow/wrap layout |
| [OiSpan](lib/src/foundation/oi_span.dart) | Per-child grid span (via `.span()` extension on `Widget`) |
| [OiGridZoomControls](lib/src/primitives/layout/oi_grid_zoom_controls.dart) | Wraps `OiGrid` with +/- zoom controls for column count |

### OiGrid

The most powerful layout primitive. Behaves like CSS Grid:

```dart
OiGrid(
  breakpoint: context.breakpoint,
  columns: OiResponsive.breakpoints({
    OiBreakpoint.compact: 1,
    OiBreakpoint.medium: 2,
    OiBreakpoint.expanded: 3,
  }),
  gap: const OiResponsive<double>(16),
  children: [
    const HeaderWidget().span(columnSpan: const OiResponsive(2)),
    const CardWidget(),
    const CardWidget(),
    const CardWidget(),
  ],
)
```

See [Layout > Grid](../layout/grid.md) for the full guide.

### OiGridZoomControls

A wrapper around `OiGrid` that adds +/- zoom controls to change the column count interactively. Ideal for gallery or card views where users want to adjust density.

```dart
OiGridZoomControls(
  breakpoint: context.breakpoint,
  initialColumns: 3,
  minColumns: 1,
  maxColumns: 6,
  onColumnsChanged: (cols) => print('Now $cols columns'),
  gap: OiResponsive<double>(16),
  children: [...],
)
```

## Display

| Widget | Description |
| --- | --- |
| [OiDivider](lib/src/primitives/display/oi_divider.dart) | Horizontal or vertical separator line |
| [OiIcon](lib/src/primitives/display/oi_icon.dart) | Icon display with semantic or decorative variant |
| [OiImage](lib/src/primitives/display/oi_image.dart) | Themed image primitive with loading and error states |
| [OiLabel](lib/src/primitives/display/oi_label.dart) | Text display using theme text styles (includes `.copyable()` constructor) |
| [OiSurface](lib/src/primitives/display/oi_surface.dart) | Container with background, border, radius, shadow (includes `.transparent()`, `.elevated()`) |

### OiLabel

Text display using theme text styles. Use variant constructors like `OiLabel.h1()`, `OiLabel.body()`, `OiLabel.small()`, etc.

**Factory constructor: `.copyable()`**

Creates a field-value display with built-in copy-to-clipboard support. Ideal for read-only data like IDs, API keys, URLs, or error codes. The text is selectable and a copy button is shown on hover (desktop) or via long-press (mobile).

```dart
OiLabel.copyable('sk-proj-abc123xyz')

OiLabel.copyable(
  'https://api.example.com/v1/resource',
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
)
```

### OiSurface

The base container for styled boxes. Accepts `color`, `border` (`OiBorderStyle?`), `borderRadius`, `shadow` (`List<BoxShadow>?`), `padding`, `halo`, `frosted`, `gradient`, and `child`.

```dart
OiSurface(
  color: context.colors.surface,
  borderRadius: context.radius.md,
  shadow: context.shadows.sm,
  padding: EdgeInsets.all(context.spacing.md),
  child: const Text('Content'),
)
```

**Named constructors:**

- `OiSurface.transparent({child, borderRadius})` — a transparent surface that provides clipping and a hit-test boundary without any visual styling. Useful for wrapping overlay content or replacing `Material(color: transparent)`.
- `OiSurface.elevated({required List<BoxShadow> elevation, child, borderRadius})` — a surface with shadow but no background fill. Useful for adding shadow to a transparent container.

```dart
// Transparent clipping surface
OiSurface.transparent(
  borderRadius: context.radius.md,
  child: myOverlayContent,
)

// Shadow-only surface
OiSurface.elevated(
  elevation: context.shadows.md,
  borderRadius: context.radius.lg,
  child: myContent,
)
```

## Interaction

| Widget | Description |
| --- | --- |
| [OiTappable](lib/src/primitives/interaction/oi_tappable.dart) | Tap handler with hover, focus, active feedback — foundation for all interactive widgets |
| [OiTouchTarget](lib/src/primitives/interaction/oi_touch_target.dart) | Ensures 48×48dp minimum touch area on touch devices |
| [OiFocusTrap](lib/src/primitives/interaction/oi_focus_trap.dart) | Confines keyboard focus within a subtree (for dialogs, panels) |

### OiTappable

The interaction primitive. All buttons, inputs, and interactive widgets use it:

```dart
OiTappable(
  onTap: () => print('Tapped'),
  clipBorderRadius: context.radius.sm,
  semanticLabel: 'Tap me',
  child: Padding(
    padding: EdgeInsets.all(context.spacing.sm),
    child: const Text('Tap me'),
  ),
)
```

Automatically handles: hover overlay, focus ring, active/press feedback, disabled state (0.4 opacity), and touch-target enforcement via `OiA11y.minTouchTarget` (48dp on touch platforms, 0 on pointer).

## Animation

| Widget | Description |
| --- | --- |
| [OiAnimatedList](lib/src/primitives/animation/oi_animated_list.dart) | List item entry/exit animations |
| [OiMorph](lib/src/primitives/animation/oi_morph.dart) | Shape morphing animation |
| [OiPulse](lib/src/primitives/animation/oi_pulse.dart) | Pulsing scale animation |
| [OiShimmer](lib/src/primitives/animation/oi_shimmer.dart) | Loading shimmer effect |
| [OiSpring](lib/src/primitives/animation/oi_spring.dart) | Spring physics animation |
| [OiStagger](lib/src/primitives/animation/oi_stagger.dart) | Staggered entry animation for lists |

All animations respect `OiAnimationConfig.reducedMotion` — when the OS has reduce-motion enabled, durations collapse to zero.

## Scroll

| Widget | Description |
| --- | --- |
| [OiVirtualList](lib/src/primitives/scroll/oi_virtual_list.dart) | Virtualized scrollable list (for 10k+ items) |
| [OiVirtualGrid](lib/src/primitives/scroll/oi_virtual_grid.dart) | Virtualized scrollable grid |
| [OiInfiniteScroll](lib/src/primitives/scroll/oi_infinite_scroll.dart) | Infinite scroll trigger at list end |
| [OiScrollbar](lib/src/primitives/scroll/oi_scrollbar.dart) | Platform-adaptive scrollbar |
| [OiSliverList](lib/src/primitives/scroll/oi_sliver_list.dart) | Themed sliver list wrapper with separators and padding |
| [OiSliverGrid](lib/src/primitives/scroll/oi_sliver_grid.dart) | Themed sliver grid wrapper with responsive columns |

### OiSliverList

A themed sliver list that wraps `SliverList` with consistent padding, optional dividers, and accessibility support. Use inside a `CustomScrollView` or any sliver-based scroll view.

```dart
// Builder with separators
OiSliverList(
  itemCount: items.length,
  itemBuilder: (context, index) => OiLabel.body(items[index]),
  separated: true,
  padding: EdgeInsets.all(context.spacing.md),
)

// Static children list
OiSliverList.children(
  padding: EdgeInsets.all(context.spacing.md),
  children: [
    OiLabel.body('First'),
    OiLabel.body('Second'),
    OiLabel.body('Third'),
  ],
)
```

**Key features:**

- Builder pattern for lazy item construction
- `.children()` constructor for short, static lists
- Optional themed dividers between items (`separated: true`)
- Custom separator widget via `separatorBuilder`
- Optional `SliverPadding` wrapper
- Optional semantic label

**Related components:** `OiSliverGrid`, `OiSliverHeader`, `OiVirtualList`

### OiSliverGrid

A themed sliver grid that wraps `SliverGrid` with design-system spacing defaults and responsive column support. Spacing defaults to the theme's `sm` value when not explicitly set.

```dart
// Fixed column count
OiSliverGrid(
  crossAxisCount: 3,
  itemCount: items.length,
  itemBuilder: (context, index) => OiCard(child: OiLabel.body(items[index])),
)

// Auto columns from minimum item width
OiSliverGrid.extent(
  minItemWidth: 200,
  itemCount: items.length,
  itemBuilder: (context, index) => OiCard(child: OiLabel.body(items[index])),
)
```

**Key features:**

- Fixed column count via default constructor
- Auto-calculated columns from `minItemWidth` via `.extent()` constructor
- Theme-derived spacing defaults (`spacing.sm`)
- Configurable `childAspectRatio`, `mainAxisSpacing`, `crossAxisSpacing`
- Optional `SliverPadding` wrapper
- Optional semantic label

**Related components:** `OiSliverList`, `OiSliverHeader`, `OiVirtualGrid`, `OiGrid`

## Drag & Drop

| Widget | Description |
| --- | --- |
| [OiDraggable](lib/src/primitives/drag_drop/oi_draggable.dart) | Makes any widget draggable |
| [OiDropZone](lib/src/primitives/drag_drop/oi_drop_zone.dart) | Drop target area |
| [OiDragGhost](lib/src/primitives/drag_drop/oi_drag_ghost.dart) | Custom drag preview |
| [OiReorderable](lib/src/primitives/drag_drop/oi_reorderable.dart) | Reorderable list primitive |

## Gesture

| Widget | Description |
| --- | --- |
| [OiDoubleTap](lib/src/primitives/gesture/oi_double_tap.dart) | Double-tap handler |
| [OiLongPressMenu](lib/src/primitives/gesture/oi_long_press_menu.dart) | Long-press context menu (mobile alternative to right-click) |
| [OiPinchZoom](lib/src/primitives/gesture/oi_pinch_zoom.dart) | Pinch-to-zoom and pan |
| [OiSwipeable](lib/src/primitives/gesture/oi_swipeable.dart) | Swipe gesture handling |

## Clipboard

| Widget | Description |
| --- | --- |
| [OiCopyable](lib/src/primitives/clipboard/oi_copyable.dart) | Wraps content with copy-on-tap |
| [OiCopyButton](lib/src/primitives/clipboard/oi_copy_button.dart) | One-click copy button |
| [OiPasteZone](lib/src/primitives/clipboard/oi_paste_zone.dart) | Paste target area |

## Input

| Widget | Description |
| --- | --- |
| [OiRawInput](lib/src/primitives/input/oi_raw_input.dart) | Low-level text entry primitive used by higher-level input components |

## Overlay

| Widget | Description |
| --- | --- |
| [OiFloating](lib/src/primitives/overlay/oi_floating.dart) | Floating action button / element |
| [OiPortal](lib/src/primitives/overlay/oi_portal.dart) | Overlay portal for tooltips, popovers |
| [OiVisibility](lib/src/primitives/overlay/oi_visibility.dart) | Visibility wrapper |
