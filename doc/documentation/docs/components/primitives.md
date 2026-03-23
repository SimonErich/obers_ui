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
| `OiLabel` | Text display using theme text styles (includes `.copyable()` constructor) |
| `OiSurface` | Container with background, border, radius, shadow (includes `.transparent()`, `.elevated()`) |

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

**Factory constructors:**

- `OiSurface.transparent()` -- A transparent surface that provides clipping and hit-test boundary without any visual styling. Useful for wrapping overlay content or replacing `Material(color: transparent)`.
- `OiSurface.elevated({required List<BoxShadow> elevation})` -- A surface with elevation shadow but no background fill. Useful for adding shadow to a transparent container.

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
| `OiSliverList` | Themed sliver list wrapper with separators and padding |
| `OiSliverGrid` | Themed sliver grid wrapper with responsive columns |

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
