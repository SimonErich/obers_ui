# Primitives

Primitives are single-purpose, low-level widgets. They're the building blocks that components and composites are made of. Most users won't use them directly — but they're available when you need fine-grained control.

## Layout

| Widget | Description |
|---|---|
| `OiGrid` | Responsive CSS Grid-like layout with column spans |
| `OiRow` | Horizontal flex with gap |
| `OiColumn` | Vertical flex with gap |
| `OiFlex` | Flex layout with `.grow()` and `.fixed()` children |
| `OiSection` | Content group with optional header, aside layout, collapse |
| `OiFieldset` | Bordered group with legend |
| `OiPage` | Max-width centered page with responsive gutters |
| `OiContainer` | Constrained box |
| `OiMasonry` | Masonry (Pinterest-style) layout |
| `OiAspectRatio` | Fixed aspect ratio container |
| `OiSpacer` | Flexible space |
| `OiWrapLayout` | Flow/wrap layout |
| `OiShow` / `OiHide` | Show/hide children at specific breakpoints |
| `OiSpan` | Per-child grid span configuration |

### OiGrid

The most powerful layout primitive. Behaves like CSS Grid:

```dart
OiGrid(
  columns: OiResponsive({
    OiBreakpoint.compact: 1,
    OiBreakpoint.medium: 2,
    OiBreakpoint.expanded: 3,
  }),
  gap: context.spacing.md,
  children: [
    OiSpan(columnSpan: 2, child: HeaderWidget()),
    CardWidget(),
    CardWidget(),
    CardWidget(),
  ],
)
```

See [Layout > Grid](../layout/grid.md) for the full guide.

## Display

| Widget | Description |
|---|---|
| `OiDivider` | Horizontal or vertical separator line |
| `OiIcon` | Icon display with semantic sizing |
| `OiLabel` | Text display using theme text styles |
| `OiSurface` | Container with background, border, radius, shadow |

### OiSurface

The base container for styled boxes:

```dart
OiSurface(
  color: context.colors.surface,
  borderRadius: context.radius.md,
  elevation: 1,
  child: Padding(
    padding: EdgeInsets.all(context.spacing.md),
    child: Text('Content'),
  ),
)
```

## Interaction

| Widget | Description |
|---|---|
| `OiTappable` | Tap handler with hover, focus, press feedback — foundation for all interactive widgets |
| `OiTouchTarget` | Ensures 48x48dp minimum touch area on touch devices |
| `OiFocusTrap` | Confines keyboard focus within a subtree (for dialogs, panels) |

### OiTappable

The interaction primitive. All buttons, inputs, and interactive widgets use it:

```dart
OiTappable(
  onTap: () => print('Tapped'),
  borderRadius: context.radius.sm,
  child: Padding(
    padding: EdgeInsets.all(context.spacing.sm),
    child: Text('Tap me'),
  ),
)
```

Automatically handles: hover overlay, focus ring, press scale, disabled state (0.4 opacity), touch target enforcement.

## Animation

| Widget | Description |
|---|---|
| `OiAnimatedList` | List item entry/exit animations |
| `OiMorph` | Shape morphing animation |
| `OiPulse` | Pulsing scale animation |
| `OiShimmer` | Loading shimmer effect |
| `OiSpring` | Spring physics animation |
| `OiStagger` | Staggered entry animation for lists |

All animations respect `reducedMotion` automatically.

## Scroll

| Widget | Description |
|---|---|
| `OiVirtualList` | Virtualized scrollable list (for 10k+ items) |
| `OiVirtualGrid` | Virtualized scrollable grid |
| `OiInfiniteScroll` | Infinite scroll trigger at list end |
| `OiScrollbar` | Platform-adaptive scrollbar |

## Drag & Drop

| Widget | Description |
|---|---|
| `OiDraggable` | Makes any widget draggable |
| `OiDropZone` | Drop target area |
| `OiDragGhost` | Custom drag preview |
| `OiReorderable` | Reorderable list |

## Gesture

| Widget | Description |
|---|---|
| `OiDoubleTap` | Double-tap handler |
| `OiLongPressMenu` | Long-press context menu (mobile alternative to right-click) |
| `OiPinchZoom` | Pinch-to-zoom and pan |
| `OiSwipeable` | Swipe gesture handling |

## Clipboard

| Widget | Description |
|---|---|
| `OiCopyable` | Wraps content with copy-on-tap |
| `OiCopyButton` | One-click copy button |
| `OiPasteZone` | Paste target area |

## Overlay

| Widget | Description |
|---|---|
| `OiFloating` | Floating action button / element |
| `OiPortal` | Overlay portal for tooltips, popovers |
| `OiVisibility` | Visibility wrapper |
