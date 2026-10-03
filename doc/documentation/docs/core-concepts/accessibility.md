# Accessibility

ObersUI builds accessibility into the widgets, so you get a lot for free. This
page explains what happens automatically and what you still have to do. The rule
of thumb: the library handles touch targets, contrast, reduced motion, and focus.
You handle labels and announcements.

## What is automatic

You do not opt in to any of these. They apply as soon as you use ObersUI widgets
inside an `OiApp`.

| Concern | What the library does |
| --- | --- |
| Touch targets | Interactive widgets enforce a 48dp minimum hit area on touch devices. |
| Contrast | Default theme colors are picked to meet WCAG AA contrast. |
| Reduced motion | Animations shorten to zero when the OS asks for reduced motion. |
| Focus | Buttons, inputs, tabs, and menus are focusable and keyboard-operable. |
| Focus trapping | Dialogs and panels keep focus inside while they are open. |

## What you provide

Two things need your input on every screen.

1. A `label` or `semanticLabel` on each interactive widget. Screen readers read
   this text aloud. Without it, a control is announced as an unnamed button.
2. An announcement when something changes off-screen, like a save that finished
   or an error that appeared. Use `OiA11y.announce`.

## Labels on interactive widgets

Every button, input, and control takes an accessibility label. Visible text
counts as the label. When a control shows only an icon, pass a `semanticLabel` so
it is still announced.

```dart
// Text is visible, so the label is covered.
OiButton.primary(label: 'Save', onTap: save)

// Icon only. semanticLabel is the screen-reader text.
OiIconButton(
  icon: OiIcons.edit,
  semanticLabel: 'Edit',
  onTap: edit,
)
```

!!! warning
    An icon-only control with no `semanticLabel` is announced as "button" with no
    name. Always set one. `OiIconButton` and `OiToggleButton` make `semanticLabel`
    required so you cannot forget.

Overlays take a label too. Named dialog constructors require `label`. The
`showOiDialog` helper accepts `semanticLabel`.

```dart
OiDialog.confirm(
  label: 'Delete confirmation',
  title: 'Delete this file?',
  content: OiLabel.body('This action cannot be undone.'),
  actions: [
    OiButton.outline(label: 'Cancel', onTap: () {}),
    OiButton.destructive(label: 'Delete', onTap: () {}),
  ],
)
```

## Touch targets

On touch devices, interactive widgets grow to a 48dp minimum hit area. The visual
size can stay smaller. The extra area is invisible and only responds to taps. This
is the WCAG recommended minimum. On pointer devices (mouse and trackpad) there is
no minimum, so dense desktop layouts stay compact.

`OiTappable`, the base for interactive widgets, applies this for you. If you build
a custom tappable area, wrap it in `OiTouchTarget`.

```dart
// Reads the platform minimum: 48dp on touch, 0 on pointer.
OiTouchTarget(
  child: myCustomControl,
)

// Force a specific minimum instead.
OiTouchTarget.custom(
  minSize: 44,
  child: myCustomControl,
)
```

To read the current minimum yourself, call `OiA11y.minTouchTarget(context)`. It
returns `48` on touch and `0` on pointer.

## Screen-reader announcements

Some changes have no visible widget to focus, so a screen reader never hears about
them. A background save, a validation error, a count that updates. Announce these
with `OiA11y.announce`.

```dart
// Polite: waits for the screen reader to finish the current phrase.
OiA11y.announce(context, 'File uploaded');

// Assertive: interrupts and speaks now. Use for errors and urgent updates.
OiA11y.announce(context, 'Upload failed', assertive: true);
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `BuildContext` | **required** | Locates the view and text direction. |
| `message` | `String` | **required** | The text to speak. |
| `assertive` | `bool` | `false` | `true` interrupts the current speech. |

!!! tip
    Keep messages short and specific. "Saved" is better than "Your changes have
    been saved successfully". Use `assertive: true` only for errors, since it cuts
    off whatever the user is hearing.

## Reduced motion

If a user turns on reduced motion in their OS, ObersUI shortens animation
durations to zero. Transitions become instant instead of sliding or fading. You do
not opt in. The library reads the system setting through
`MediaQuery.disableAnimationsOf`.

If you write your own animation, check the same flag first.

```dart
final duration = OiA11y.reducedMotion(context)
    ? Duration.zero
    : const Duration(milliseconds: 200);
```

## Focus and keyboard navigation

Interactive widgets are focusable and respond to the keyboard.

- **Tab** and **Shift+Tab** move focus forward and back.
- **Enter** and **Space** activate buttons and controls.
- **Escape** closes overlays.
- **Arrow keys** move within lists, grids, tabs, and menus.

Dialogs and panels wrap their content in `OiFocusTrap`. Focus stays inside the
open surface, so Tab does not wander behind it. When the surface closes, focus
returns to where it was. You get this by using `OiDialog` and `OiPanel`. Reach for
`OiFocusTrap` directly only when you build a custom modal surface.

```dart
OiFocusTrap(
  onEscape: closeMyPopover,
  child: myPopoverContent,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The subtree that holds focus. |
| `initialFocus` | `bool` | `true` | Focus the first focusable child after the first frame. |
| `restoreFocus` | `bool` | `true` | Return focus to the prior widget when the trap is removed. |
| `onEscape` | `VoidCallback?` | `null` | Called on Escape or the Android back button. |

## Contrast from the theme

The default light and dark themes use color pairs that meet WCAG AA contrast. When
you read colors from the theme, foreground and background stay readable together.

```dart
OiSurface(
  color: context.colors.primary.base,
  child: OiLabel.body(
    'Readable on the fill',
    color: context.colors.primary.foreground,
  ),
)
```

Each color swatch carries a matching `foreground` value for text and icons drawn
on top of it. Use it instead of guessing a color. If you ship a custom brand
color, check its contrast against the foreground it pairs with.

## Links carry link semantics

For text that acts as a hyperlink, use `OiLabel.link`. It marks the text as a
link, so assistive technology announces "link" and not "button". Do not style a
button to look like a link.

```dart
OiLabel.link(
  'Read the terms',
  semanticsLabel: 'Read the terms of service',
)
```

## Reading accessibility state

`OiA11y` exposes the current settings so you can adapt your own widgets.

```dart
final reducedMotion = OiA11y.reducedMotion(context); // bool
final highContrast  = OiA11y.highContrast(context);  // bool
final textScale     = OiA11y.textScale(context);     // double
final boldText      = OiA11y.boldText(context);       // bool
final minTarget     = OiA11y.minTouchTarget(context); // 48 or 0
```

| Method | Returns | What it tells you |
| --- | --- | --- |
| `reducedMotion(context)` | `bool` | The user asked to reduce motion. |
| `highContrast(context)` | `bool` | High-contrast mode is on. |
| `textScale(context)` | `double` | The current text scale factor. |
| `boldText(context)` | `bool` | The user prefers bold text. |
| `minTouchTarget(context)` | `double` | The touch-target minimum, 48 or 0. |

These methods live on `OiA11y` and read from context. `OiApp` sets up the
`OiA11yScope` they need, so they work anywhere inside your app.

## Related

- [Theming](theming.md) for the color swatches and foreground pairs.
- [Buttons & Actions](../widgets/buttons.md) for label and `semanticLabel` rules.
- [Overlays & Menus](../widgets/overlays.md) for dialogs, panels, and focus traps.
