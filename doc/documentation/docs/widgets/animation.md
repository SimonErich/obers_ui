# Animation & Motion

These primitives add motion to your UI without you touching an `AnimationController`.
They cover crossfades, loading placeholders, attention pulses, spring physics, and
positioning content in an overlay. Every one of them checks the reduced-motion
setting and skips the animation when the user asks for less movement.

| Widget | What it does |
| --- | --- |
| `OiMorph` | Crossfades between two child states when the child's key changes. |
| `OiPulse` | Loops an opacity and scale pulse to draw attention. |
| `OiShimmer` | Sweeps a gradient across a child as a loading placeholder. |
| `OiSpring` | Drives a builder with spring physics toward a target value. |
| `OiStagger` | Animates a list of children in one after another. |
| `OiVisibility` | Shows or hides a child with a chosen transition. |
| `OiFloating` | Positions floating content next to an anchor in an overlay. |
| `OiPortal` | Renders a child in the nearest overlay so it paints on top. |

All of these share one motion vocabulary, the `OiTransition` enum: `none`, `fade`,
`fadeScale`, `slideUp`, `slideDown`, `slideLeft`, and `slideRight`.

## OiMorph

Crossfades between two versions of a child. Give each state a different `Key`, and
`OiMorph` runs the chosen transition when the key changes. Reach for it when a
region swaps between two contents, like a loading state and its result.

```dart
OiMorph(
  transition: OiTransition.fadeScale,
  child: isLoggedIn
      ? OiLabel.body('Welcome', key: const ValueKey('welcome'))
      : OiLabel.body('Sign in', key: const ValueKey('signin')),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The current state to show. Give each state its own `Key`. |
| `transition` | `OiTransition` | `fade` | How the old child leaves and the new one enters. |
| `duration` | `Duration?` | `null` | Transition length. Falls back to `context.animations.normal` (250 ms). |

!!! warning
    Without a distinct `Key` on each state, `OiMorph` cannot tell the children
    apart and no transition runs. This is the most common mistake here.

!!! note
    For a plain show and hide of one child, use `OiVisibility`. Use `OiMorph` when
    you are swapping between two different widgets.

## OiPulse

Loops an opacity, and optionally a scale, to pull the eye toward something. It is
the motion behind notification dots and live status indicators. Set `active` to
turn the pulse on and off.

```dart
OiPulse(
  active: hasUnread,
  minOpacity: 0.3,
  child: OiIcon.decorative(icon: OiIcons.circle, color: context.colors.primary.base),
)
```

Add a scale component by setting `maxScale` above `1.0`.

```dart
OiPulse(
  active: isLive,
  minScale: 1.0,
  maxScale: 1.2,
  child: OiIcon.decorative(icon: OiIcons.circle, color: context.colors.error.base),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The widget to pulse. |
| `active` | `bool` | `true` | When false, the child renders with no animation wrapper. |
| `minOpacity` | `double` | `0.4` | Opacity at the low point of the pulse. |
| `maxOpacity` | `double` | `1.0` | Opacity at the high point. |
| `minScale` | `double` | `1.0` | Scale at the low point. |
| `maxScale` | `double` | `1.0` | Scale at the high point. Raise above `1.0` for a size pulse. |
| `duration` | `Duration?` | `null` | Length of one full cycle. Defaults to 1000 ms. |

## OiShimmer

Sweeps a light gradient across a child to signal that content is loading. Wrap a
placeholder shape (a box, a bar) and set `active` while data is on its way.

```dart
OiShimmer(
  active: isLoading,
  child: OiSurface(
    width: 200,
    height: 20,
    color: context.colors.surfaceActive,
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The shape the shimmer sweeps over. |
| `active` | `bool` | `true` | When false, the child renders with no shimmer. |
| `baseColor` | `Color?` | `null` | Darker band of the gradient. Defaults to `context.colors.surfaceActive`. |
| `highlightColor` | `Color?` | `null` | Lighter band of the gradient. Defaults to `context.colors.surfaceHover`. |
| `duration` | `Duration?` | `null` | Length of one sweep. Defaults to 1500 ms. |

!!! note
    For a single loading control with no placeholder shape, use `OiProgress` in
    indeterminate mode instead. Shimmer is for skeleton placeholders that match
    the shape of the content to come.

## OiSpring

Drives a `builder` with spring physics toward a target `value`. When `value`
changes, `OiSpring` animates from the current position with natural motion you
tune through `stiffness`, `damping`, and `mass`. You map the animated value onto
any property yourself.

```dart
OiSpring(
  value: _expanded ? 1.0 : 0.0,
  builder: (context, v, child) => Opacity(opacity: v, child: child),
  child: const ExpensiveWidget(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `double` | **required** | Target value the spring animates toward, usually `0.0` to `1.0`. |
| `builder` | `Widget Function(BuildContext, double, Widget?)` | **required** | Called each frame with the current value and the `child` passthrough. |
| `child` | `Widget?` | `null` | Passed to `builder` unchanged, so an expensive subtree is not rebuilt each frame. |
| `stiffness` | `double` | `300.0` | Higher is faster and bouncier. |
| `damping` | `double` | `30.0` | Higher reduces oscillation. |
| `mass` | `double` | `1.0` | Higher is slower and heavier. |

!!! tip
    Put costly widgets in `child`, not inside `builder`. The `child` is built once
    and handed to `builder` on every frame, so it does not rebuild as the value
    animates.

## OiStagger

Animates a column of children in sequence, each one starting a `staggerDelay`
after the last. Good for list entrances on page load or when search results
arrive. It runs on mount by default.

```dart
OiStagger(
  staggerDelay: const Duration(milliseconds: 80),
  transition: OiTransition.slideUp,
  children: [
    OiLabel.body('First'),
    OiLabel.body('Second'),
    OiLabel.body('Third'),
  ],
)
```

To trigger the animation yourself, set `autoPlay` to false and call `play` on the
state through a `GlobalKey<OiStaggerState>`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | **required** | The widgets to animate in, laid out in a column. |
| `staggerDelay` | `Duration` | `80 ms` | Gap between each child's start. |
| `duration` | `Duration` | `300 ms` | Length of each individual child's animation. |
| `transition` | `OiTransition` | `fade` | How each child enters. |
| `autoPlay` | `bool` | `true` | Start on mount. Set false to drive it with `OiStaggerState.play`. |

!!! note
    `OiStagger` lays its children out in a `Column`. For a scrolling or grid
    layout, animate the items another way.

## OiVisibility

Shows and hides a single child with a transition. When `visible` flips to true it
animates in, and when it flips to false it animates out. This is the everyday
choice for revealing panels, hints, and inline messages.

```dart
OiVisibility(
  visible: _isOpen,
  transition: OiTransition.fadeScale,
  child: MyPanel(),
)
```

Use the `OiVisibility.responsive` constructor to pick different transitions on
compact versus wider screens. The `breakpoint` is required, there is no implicit
context lookup.

```dart
OiVisibility.responsive(
  visible: _isOpen,
  breakpoint: context.breakpoint,
  compactTransition: OiTransition.slideUp,
  expandedTransition: OiTransition.fade,
  child: MyPanel(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `visible` | `bool` | **required** | Whether the child is shown. Toggling it runs the transition. |
| `child` | `Widget` | **required** | The content to show or hide. |
| `transition` | `OiTransition` | `fade` | The transition style. Ignored by the responsive constructor. |
| `maintainState` | `bool` | `true` | Keep the child in the tree while hidden. Set false to drop it after the hide finishes. |

Responsive-only parameters:

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `breakpoint` | `OiBreakpoint` | **required** | The current breakpoint. Drives which transition applies. |
| `compactTransition` | `OiTransition` | `slideUp` | Transition used on the compact tier. |
| `expandedTransition` | `OiTransition` | `fade` | Transition used on wider tiers. |

## OiFloating

Positions floating content next to an anchor and renders it in the nearest
overlay, so it paints above sibling widgets. It measures the real child size to
place it, then flips or shifts to stay on screen. This is the base under tooltips,
popovers, and dropdowns.

```dart
OiFloating(
  visible: _open,
  alignment: OiFloatingAlignment.bottomStart,
  anchor: OiButton.secondary(
    label: 'Options',
    onTap: () => setState(() => _open = !_open),
  ),
  onDismiss: () => setState(() => _open = false),
  child: MyPopover(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `anchor` | `Widget` | **required** | The widget the content is positioned against. It stays in the tree. |
| `child` | `Widget` | **required** | The floating content shown in the overlay. |
| `visible` | `bool` | `false` | Whether the floating content shows. |
| `alignment` | `OiFloatingAlignment` | `bottomStart` | Which side of the anchor, and where along it, the content appears. |
| `gap` | `double` | `4` | Space in logical pixels between anchor and content. |
| `overflow` | `OiFloatingOverflow` | `flip` | Off-screen handling: `flip`, `shift`, or `none`. |
| `bottomSheetOnCompact` | `bool` | `false` | On compact screens, render the child as a full-width bottom panel. |
| `offset` | `Offset?` | `null` | Extra nudge applied on top of the computed position. |
| `screenPadding` | `EdgeInsets` | `EdgeInsets.all(8)` | Minimum distance to keep from each screen edge. |
| `onDismiss` | `VoidCallback?` | `null` | When set, a barrier catches outside taps and calls this, enabling click-outside-to-close. |

`OiFloatingAlignment` covers all twelve anchor positions: `topStart`, `topCenter`,
`topEnd`, `bottomStart`, `bottomCenter`, `bottomEnd`, and the `left*` and `right*`
variants.

!!! note
    `autoFlip` still exists for backward compatibility. When it is false, the
    overlay never repositions regardless of `overflow`. Prefer setting `overflow`
    directly.

## OiPortal

Renders its child in the nearest overlay when `active` is true, so the content
paints above everything else in the tree. It is the low-level escape hatch for
lifting menus and tooltips out of their layout position. It needs an `Overlay`
ancestor, which `OiApp` provides.

```dart
OiPortal(
  active: _showMenu,
  child: MenuPanel(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The content rendered in the overlay while active. |
| `active` | `bool` | `false` | Whether the child is inserted into the overlay. |

!!! note
    `OiPortal` does not position the child for you. For anchored, on-screen-aware
    placement, use `OiFloating`, which handles the positioning and overflow.

## Related

- [Overlays & Menus](overlays.md) for tooltips, popovers, and menus built on these primitives.
- [Feedback & Status](feedback.md) for spinners, progress, and skeleton groups.
- [Buttons & Actions](buttons.md) for the anchors that trigger floating content.
