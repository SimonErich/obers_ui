# Overlays & Z-Order

Dialogs, sheets, toasts, tooltips, and menus all float above your normal widget
tree. ObersUI routes them through one service so they stack in a predictable
order and never fight over who sits on top. This page explains that service and
the preferred ways to show things.

## The overlay service

`OiOverlays` is a single service that manages a z-ordered stack of overlays.
`OiApp` sets it up for you, so every screen inside an `OiApp` can show overlays.
You reach the service with `OiOverlays.of(context)`.

Each entry is placed at a z-order level. Higher levels render above lower ones.
The levels, from bottom to top:

| Level | Used for |
| --- | --- |
| `base` | Anchored dropdowns and tooltips. |
| `dropdown` | Floating dropdowns and select menus. |
| `tooltip` | Tooltip overlays. |
| `panel` | Side panels and sheets. |
| `dialog` | Modal dialogs. |
| `toast` | Toast notifications. |
| `critical` | System-level overlays, like permission prompts. |

This ordering is why a toast still shows over an open dialog, and a dialog shows
over a slide-in sheet. You rarely set the level yourself. The widget-specific
show helpers pick the right one.

## Show overlays the easy way

Do not call the low-level service by hand for common cases. Each overlay widget
has a static `show` method that picks the correct z-order and handles the scrim,
focus, and dismissal for you.

```dart
// A modal dialog.
OiDialog.show(
  context,
  label: 'Delete file',
  dialog: OiDialog.confirm(
    label: 'Delete file',
    title: 'Delete this file?',
    content: OiLabel.body('This cannot be undone.'),
  ),
);

// A toast notification.
OiToast.show(
  context,
  message: 'Saved',
  level: OiToastLevel.success,
);

// A slide-in sheet.
OiSheet.show(
  context,
  label: 'Filters',
  side: OiPanelSide.right,
  child: myFilterPanel,
);
```

Each of these returns an `OiOverlayHandle` (see below), so you can dismiss the
overlay in code later.

### OiDialog.show

Pushes a dialog onto the stack at the `dialog` level. Pass a built `OiDialog`
variant as the `dialog` argument.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `BuildContext` | **required** | Locates the overlay service. |
| `label` | `String` | **required** | Announced by screen readers when the dialog opens. |
| `dialog` | `Widget` | **required** | The dialog body, usually an `OiDialog` variant. |
| `dismissible` | `bool` | `true` | Whether tapping the scrim closes the dialog. |

### OiToast.show

Queues a toast at the `toast` level. Toasts stack within each requested position
and auto-dismiss when a duration is supplied. Concurrent positions retain their
own anchors; no adaptive cross-group collision partitioning is promised.

Without an `OiOverlays` service, `show` inserts into the nearest native Flutter
`Overlay`. That host still needs the usual theme, density, platform, media-query
and text-direction scopes. `OiApp` normally provides this environment.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `BuildContext` | **required** | Locates the overlay service or native Overlay fallback. |
| `message` | `String` | **required** | The toast text. |
| `level` | `OiToastLevel` | `info` | `info`, `success`, `warning`, or `error`. |
| `position` | `OiToastPosition` | `bottomRight` | One of six screen corners or edges. |
| `duration` | `Duration?` | `4s` | How long before it fades; null leaves expiry to the owner. |
| `pauseOnHover` | `bool` | `true` | Pause the auto-dismiss timer while hovered. |
| `dismissible` | `bool` | `true` | Show the dismiss button. |
| `dismissLabel` | `String` | `Dismiss` | Localized accessible name for the dismiss button. |
| `action` | `Widget?` | `null` | An optional action widget, like an undo button. |
| `onDismiss` | `VoidCallback?` | `null` | Close/expiry callback, not called by handle or service dismissal. |

The returned handle reflects close/expiry removal. `handle.dismiss()` removes
immediately without a close animation or callback. `OiOverlays.of(context).dismissAll()`
also immediately invalidates the handles belonging to that toast overlay and
suppresses its pending close/expiry callbacks. The next toast starts a clean
queue generation; it does not revive dismissed entries. The toast queue is
currently shared, not isolated per `OiApp` host.

### OiSheet.show

Slides a panel in from an edge at the `panel` level.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `BuildContext` | **required** | Locates the overlay service. |
| `label` | `String` | **required** | Announced by screen readers when the sheet opens. |
| `child` | `Widget` | **required** | The sheet content. |
| `side` | `OiPanelSide` | `bottom` | `top`, `bottom`, `left`, or `right`. |
| `size` | `double?` | `null` | Fixed width or height. Defaults to a sensible size. |
| `dismissible` | `bool` | `true` | Whether tapping the scrim closes the sheet. |
| `dragHandle` | `bool` | `false` | Show a drag handle at the top. |
| `snapPoints` | `List<double>?` | `null` | Optional snap positions for dragging. |
| `onClose` | `VoidCallback?` | `null` | Called when the sheet closes. |

## Get a result back with async variants

The `show` methods above are fire and forget. When you need to wait for the user
to answer, use the async variants. They return a `Future` that completes when
the overlay closes, with the value you passed to `close`.

```dart
// A custom dialog that returns a value.
final confirmed = await showOiDialog<bool>(
  context,
  builder: (context, close) => OiDialog.confirm(
    label: 'Discard changes',
    title: 'Discard your changes?',
    content: OiLabel.body('Unsaved edits will be lost.'),
    actions: [
      OiButton.ghost(label: 'Keep editing', onTap: () => close(false)),
      OiButton.destructive(label: 'Discard', onTap: () => close(true)),
    ],
  ),
);

if (confirmed == true) {
  discard();
}
```

`OiDialog.showAsync<T>()` is a shorthand for the standard variant when you do not
need a fully custom body.

```dart
final result = await OiDialog.showAsync<String>(
  context,
  label: 'Rename',
  title: 'Rename file',
  content: myRenameField,
  actions: [
    OiButton.primary(label: 'Save', onTap: () {}),
  ],
);
```

`OiSheet.showAsync<T>()` works the same way for sheets. The builder receives a
`close` callback that completes the future.

```dart
final choice = await OiSheet.showAsync<String>(
  context,
  label: 'Pick a color',
  side: OiPanelSide.bottom,
  builder: (close) => OiColumn(
    children: [
      OiButton.ghost(label: 'Red', onTap: () => close('red')),
      OiButton.ghost(label: 'Blue', onTap: () => close('blue')),
    ],
  ),
);
```

!!! note
    The `close` callback takes an optional result: `close()` completes with
    `null`, `close(value)` completes with your value. If the user dismisses the
    overlay by tapping the scrim, the future completes with `null`.

## Dismiss and update with the handle

Every non-async show call returns an `OiOverlayHandle`. Hold onto it when you
need to close the overlay yourself, for example after a background task finishes.

```dart
final toast = OiToast.show(
  context,
  message: 'Uploading...',
  duration: const Duration(days: 1), // stays until you close it
);

await upload();

if (!toast.isDismissed) {
  toast.dismiss();
}
```

| Member | Type | Description |
| --- | --- | --- |
| `dismiss()` | `void` | Removes the overlay from the screen. Safe to call twice. |
| `isDismissed` | `bool` | `true` once the overlay has been removed. |
| `update()` | `void` | Rebuilds the overlay content. |

## Show a custom overlay

For a one-off overlay that is not a dialog, toast, or sheet, call the service
directly. Pick the z-order level that fits.

```dart
final handle = OiOverlays.of(context).show(
  label: 'Color picker',
  zOrder: OiOverlayZOrder.dropdown,
  dismissOnScroll: true,
  builder: (context) => OiSurface(
    child: OiLabel.body('Custom content'),
  ),
);
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Announced by screen readers when the overlay appears. |
| `builder` | `WidgetBuilder` | **required** | Builds the overlay content. |
| `zOrder` | `OiOverlayZOrder` | `base` | The stacking level. |
| `dismissible` | `bool` | `true` | Tap outside to close. |
| `dismissOnScroll` | `bool` | `false` | Close when the content behind it scrolls. Good for dropdowns, not for dialogs. |
| `onDismiss` | `VoidCallback?` | `null` | Called when the overlay closes. |

!!! tip
    Reach for `dismissOnScroll: true` on lightweight, anchored overlays like
    dropdowns and context menus. Leave it off for modal dialogs and toasts,
    which should stay put while the user scrolls.

You can close everything at once with `OiOverlays.of(context).dismissAll()`.

## Related

- [Overlays & Menus](../widgets/overlays.md) for the dialog, sheet, toast, and menu widgets.
- [Buttons & Actions](../widgets/buttons.md) for the buttons that open these overlays.
- [Accessibility](accessibility.md) for the labels every overlay needs.
