# Overlays & Menus

Overlays are the surfaces that float above your page: dialogs, sheets, menus, and
notifications. ObersUI shows them through one z-ordered overlay service, so a
dialog always sits above a panel, and a toast always sits above a dialog. Reach
for these when you need to interrupt, confirm, or notify without leaving the
current screen.

| Widget | What it does |
| --- | --- |
| `OiDialog` | A modal dialog with five variants for confirms, alerts, forms, and full screen. |
| `OiSheet` | A panel that slides in from any edge. Good for filters and mobile detail views. |
| `OiContextMenu` | A right-click or long-press menu, with sub-menus and keyboard nav. |
| `OiMenuItem` | The item model that fills a context menu or menu bar. |
| `OiToast` | An auto-dismissing corner notification with a severity level. |
| `OiSnackBar` | A bottom or top bar for brief action feedback like "Undo". |
| `OiSelectionOverlay` | A rubber-band rectangle for drag-to-select in lists and grids. |
| `OiOverlays` | The service behind all of the above. Use it to show custom overlays. |

## OiDialog

A modal panel centered on screen, with a scrim behind it and keyboard focus
trapped inside. It has no default constructor. You pick a variant with a named
constructor. Each variant takes a required `label` for screen readers.

```dart
OiDialog.confirm(
  label: 'Delete file',
  title: 'Delete this file?',
  content: OiLabel.body('This cannot be undone.'),
  actions: [
    OiButton.outline(label: 'Cancel', onTap: () {}),
    OiButton.destructive(label: 'Delete', onTap: () {}),
  ],
)
```

### Variants

Five named constructors cover the common shapes.

```dart
OiDialog.standard(label: 'Settings')     // general purpose, arbitrary actions
OiDialog.alert(label: 'Heads up')        // simple info message
OiDialog.confirm(label: 'Confirm')       // cancel / confirm choice
OiDialog.form(label: 'Edit')             // scrollable body for form inputs
OiDialog.fullScreen(label: 'Editor')     // fills the whole screen
```

### Showing a dialog

`OiDialog` only renders the dialog body. To present it, use one of the static
helpers. Most of the time you want a value back, so prefer the async paths.

```dart
// Fire-and-forget. Returns an OiOverlayHandle you can dismiss() later.
OiDialog.show(
  context,
  label: 'Delete file',
  dialog: OiDialog.confirm(label: 'Delete file', title: 'Delete this file?'),
);

// Await a result. Completes with null if the user dismisses it.
final ok = await OiDialog.showAsync<bool>(
  context,
  label: 'Delete file',
  title: 'Delete this file?',
  content: OiLabel.body('This cannot be undone.'),
);
```

For a fully custom body, use the top-level `showOiDialog`. Its builder hands you
a `close` callback. Call `close(result)` to dismiss and return a value.

```dart
final name = await showOiDialog<String>(
  context,
  builder: (context, close) => OiDialog.form(
    label: 'Rename',
    title: 'Rename item',
    content: OiTextInput(label: 'Name', onSubmitted: (value) => close(value)),
    actions: [
      OiButton.primary(label: 'Save', onTap: () => close('done')),
    ],
  ),
);
```

!!! note
    `showOiDialog<T>()` is the ObersUI replacement for Material's `showDialog()`.
    There is no Material dependency here, so use this instead.

### Attributes

Shared by the variant constructors:

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label read by screen readers. |
| `title` | `String?` | `null` | Heading text at the top of the dialog. |
| `content` | `Widget?` | `null` | The body of the dialog. |
| `actions` | `List<Widget>?` | `null` | Footer buttons, laid out on the trailing edge. |
| `onClose` | `VoidCallback?` | `null` | Called on Escape or scrim tap. |
| `dismissible` | `bool` | `true` | Set `false` to block scrim-tap dismiss. |

`OiDialog.fullScreen` adds two more:

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `onSave` | `VoidCallback?` | `null` | Save callback, usually wired to a header button. |
| `unsavedChanges` | `bool` | `false` | When `true`, Escape and scrim tap are suppressed so edits are not lost by accident. |

**Theme:** `context.components.dialog` → `OiDialogThemeData`

!!! tip "When to reach for something else"
    Use `OiToast` for non-blocking messages. Use `OiSheet` for side content or
    mobile detail panels. Use `OiDialog` only when you need to interrupt the user.

## OiSheet

A panel that slides in from an edge. Use it for filters, detail views, or forms,
especially on mobile where a centered dialog feels cramped. You control
visibility with the `open` flag and close it in `onClose`.

```dart
bool _open = false;

OiSheet(
  label: 'Filters',
  open: _open,
  side: OiPanelSide.right,
  size: 360,
  onClose: () => setState(() => _open = false),
  child: filterForm,
)
```

### Showing a sheet imperatively

Like dialogs, sheets have static helpers. `OiSheet.show` is fire-and-forget and
returns a handle. `OiSheet.showAsync` awaits a result through a `close` callback.

```dart
// Fire-and-forget.
OiSheet.show(context, label: 'Filters', child: filterForm, side: OiPanelSide.bottom);

// Await a result.
final range = await OiSheet.showAsync<DateRange>(
  context,
  label: 'Pick range',
  side: OiPanelSide.bottom,
  dragHandle: true,
  builder: (close) => OiButton.primary(
    label: 'This week',
    onTap: () => close(thisWeek),
  ),
);
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label. |
| `child` | `Widget` | **required** | The sheet content. |
| `open` | `bool` | **required** | Whether the sheet is showing. Drives the slide animation. |
| `onClose` | `VoidCallback?` | `null` | Called on scrim tap or drag-dismiss. |
| `side` | `OiPanelSide` | `bottom` | `top`, `bottom`, `left`, or `right`. |
| `size` | `double?` | `null` | Height for top/bottom, width for left/right. Sizes to content when null. |
| `dismissible` | `bool` | `true` | Whether tapping the scrim closes the sheet. |
| `initialFocus` | `bool` | `true` | Request focus in the sheet when opened; set false to preserve caller focus. |
| `dragHandle` | `bool` | `false` | Show a pill handle on the near edge. |
| `snapPoints` | `List<double>?` | `null` | Drag snap fractions, for example `[0.3, 0.7, 1.0]`. |

**Theme:** `context.components.sheet` → `OiSheetThemeData`

!!! note
    `snapPoints` values are fractions of the screen dimension, from `0.0` to
    `1.0`. Dragging below the smallest snap point closes the sheet.

## OiContextMenu

Wraps a widget and opens a menu on right-click (pointer) or long-press (touch).
The menu clamps to the screen edge, supports arrow-key navigation, and nests
sub-menus. Set `openOnTap: true` for a normal click, which suits a "⋮" trigger in
a table row.

```dart
OiContextMenu(
  label: 'File options',
  items: [
    OiMenuItem(label: 'Cut', shortcut: 'Cmd+X', onTap: cut),
    OiMenuItem(label: 'Copy', shortcut: 'Cmd+C', onTap: copy),
    const OiMenuDivider(),
    OiMenuItem(label: 'Delete', destructive: true, onTap: remove),
  ],
  child: fileRow,
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label. |
| `child` | `Widget` | **required** | The trigger widget. |
| `items` | `List<OiMenuItem>` | **required** | The menu items. |
| `enabled` | `bool` | `true` | Set `false` to disable the trigger. |
| `openOnTap` | `bool` | `false` | Open on a normal left click or tap, not just right-click or long-press. |

**Theme:** `context.components.contextMenu` → `OiContextMenuThemeData`

## OiMenuItem

The item model for a context menu or menu bar. It is plain data, not a widget.
Give it a `label`, and optionally an `icon`, a `shortcut` hint, `children` for a
sub-menu, and flags for `checked` or `destructive`. Use `OiMenuDivider()` for a
separator line.

```dart
OiMenuItem(
  label: 'Share',
  icon: OiIcons.share,
  children: [
    OiMenuItem(label: 'Email', onTap: shareEmail),
    OiMenuItem(label: 'Copy link', shortcut: 'Cmd+L', onTap: copyLink),
  ],
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | The row text. |
| `icon` | `IconData?` | `null` | Leading icon before the label. |
| `shortcut` | `String?` | `null` | Display-only shortcut hint. It does not bind a key. |
| `onTap` | `VoidCallback?` | `null` | Called when the item is tapped. |
| `enabled` | `bool` | `true` | Set `false` to grey it out and block taps. |
| `checked` | `bool?` | `null` | `true` shows a checkmark, `false` reserves aligned space, `null` shows neither. |
| `children` | `List<OiMenuItem>?` | `null` | Sub-menu items. Shows a chevron when set. |
| `semanticLabel` | `String?` | `null` | Screen-reader text. Falls back to `label`. |
| `destructive` | `bool` | `false` | Render the label in the error color. |

!!! note
    `shortcut` is a hint only. It draws the key combo next to the label, but you
    still have to register the actual binding yourself, for example with
    `OiShortcutScope`.

## OiToast

A notification that appears in a screen corner and dismisses itself. Use it for
passive feedback: a save confirmation, a copy notice, or an error that does not
block work. Toasts stack within each requested position. Concurrent requests
keep their own six-position anchors and preserve insertion order per group.

```dart
OiToast.show(
  context,
  message: 'Changes saved',
  level: OiToastLevel.success,
);
```

The `OiToast` widget also exists if you build a custom overlay, but `OiToast.show`
is the usual entry point. It returns an `OiOverlayHandle` you can dismiss early.

If no `OiOverlays` service exists, `show` uses the nearest native Flutter
`Overlay`. Outside `OiApp`, provide the usual theme, density, platform,
media-query and text-direction scopes yourself; the fallback is not an
environment-free host.

Stacks that exceed the available height scroll while retaining every entry and
action. Top stacks initially show the oldest entry; bottom stacks show the
newest. The returned handle's `isDismissed` also reflects removal by expiry or
the close control. Calling `handle.dismiss()` removes immediately without the
close animation or `onDismiss` callback. Close/expiry callbacks run once; a
throwing callback still removes its queued entry and propagates the exception.

Service-level `OiOverlays.of(context).dismissAll()` immediately marks the handles
belonging to that toast overlay dismissed, without invoking their callbacks,
including a close/expiry callback pending its final animation frame. The next
`show` discards that old generation instead of reviving it. The queue is shared;
separate `OiApp` hosts do not provide isolated toast queues.

Adding or removing another position preserves surviving timer, hover and scroll
state. Spatially separated overflow groups scroll independently. This is not an
adaptive collision/overflow partitioning policy for top/bottom groups sharing
the same horizontal anchor; fixed-width cards can geometrically overlap across
neighboring groups on narrow viewports.

### Attributes

For `OiToast.show`:

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `message` | `String` | **required** | The notification text. |
| `level` | `OiToastLevel` | `info` | `info`, `success`, `warning`, or `error`. Sets the accent and icon. |
| `position` | `OiToastPosition` | `bottomRight` | One of six corners or centers. |
| `duration` | `Duration?` | `4s` | How long before it dismisses; null leaves expiry to the owner. |
| `pauseOnHover` | `bool` | `true` | Pause the dismiss timer while hovered. |
| `dismissible` | `bool` | `true` | Show a button for manual dismissal. |
| `dismissLabel` | `String` | `Dismiss` | Localized accessible name for the dismiss button. |
| `action` | `Widget?` | `null` | An action widget shown to the right of the message. |
| `onDismiss` | `VoidCallback?` | `null` | Called for close/expiry, not handle or service dismissal. |

The `OiToast` widget constructor also requires a `label` for accessibility. The
`show` helper derives one for you.
When `duration` is null, `onPauseRequested` and `onResumeRequested` let the widget
pause and resume an external expiry timer without maintaining a second timer.

**Theme:** `context.components.toast` → `OiToastThemeData`

The toast theme controls background, radius, physical padding, icon size, gap
and shadow. Message foreground comes from `context.colors.text`, not a toast-
specific foreground field.

!!! tip "Toast or snack bar?"
    Use `OiToast` for corner notifications that may stack. Use `OiSnackBar` for a
    single bottom bar with one action, like "Item deleted. Undo".

## OiSnackBar

A single bar at the bottom (or top) of the screen with one optional action.
Showing a new one replaces any current bar, so only one is visible at a time. It
auto-dismisses and can be swiped away.

```dart
OiSnackBar.show(
  context,
  message: 'Item deleted',
  actionLabel: 'Undo',
  onAction: () => undoDelete(),
);
```

### Attributes

For `OiSnackBar.show`:

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `message` | `String` | **required** | The bar text. |
| `actionLabel` | `String?` | `null` | Label for a text action button. |
| `onAction` | `VoidCallback?` | `null` | Called when the action label is tapped. |
| `action` | `Widget?` | `null` | A custom action widget. Overrides `actionLabel`. |
| `duration` | `Duration` | `4s` | Time before auto-dismiss. |
| `onDismissed` | `VoidCallback?` | `null` | Called when the bar goes away. |
| `leading` | `Widget?` | `null` | Widget shown before the message, such as an icon. |
| `position` | `OiSnackBarPosition` | `bottom` | `bottom` or `top`. |

**Avoid when:** you need rich or stacking notifications. Use `OiToast`. For
anything that must block the user, use `OiDialog`.

## OiSelectionOverlay

Wraps a scrollable area and lets the user click-and-drag on empty space to draw a
selection rectangle. Items whose bounds fall inside the rectangle get selected.
It is the lasso behind file explorers and card grids. You own the selection
logic; this widget just reports the rectangle.

```dart
OiSelectionOverlay(
  onSelectionStart: () => beginSelection(),
  onSelectionRect: (rect) => selectItemsIn(rect),
  onSelectionEnd: () => endSelection(),
  child: fileGrid,
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The area that holds selectable items. |
| `onSelectionStart` | `VoidCallback` | **required** | Fires when the drag begins. |
| `onSelectionRect` | `ValueChanged<Rect>` | **required** | Fires continuously with the current rectangle. |
| `onSelectionEnd` | `VoidCallback` | **required** | Fires when the drag ends. |
| `enabled` | `bool` | `true` | Set `false` to turn off drag selection. |
| `selectionColor` | `Color?` | `null` | Override the fill color of the rectangle. |
| `borderColor` | `Color?` | `null` | Override the border color of the rectangle. |

## OiOverlays

The service that powers every overlay above. It keeps a single z-ordered stack,
so layers always paint in the right order. You rarely call it directly, since
`OiDialog`, `OiSheet`, `OiToast`, and `OiContextMenu` each wrap it. Reach for it
when you need a custom floating surface of your own.

```dart
final handle = OiOverlays.of(context).show(
  label: 'Custom popover',
  zOrder: OiOverlayZOrder.dropdown,
  builder: (context) => myPopover,
);

// Later, close it.
handle.dismiss();
```

`show` returns an `OiOverlayHandle`. Call `handle.dismiss()` to close the overlay
and `handle.update()` to rebuild its content. Check `handle.isDismissed` before
acting on a handle you have held for a while.

### Z-order levels

Overlays paint in this order, lowest first. Pick the level that matches your
surface so a dialog never hides under a dropdown.

```
base < dropdown < tooltip < panel < dialog < toast < critical
```

### show attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Announced by screen readers when the overlay appears. |
| `builder` | `WidgetBuilder` | **required** | Builds the overlay content. |
| `zOrder` | `OiOverlayZOrder` | `base` | Which stack layer to paint on. |
| `dismissible` | `bool` | `true` | Whether a tap outside dismisses it. |
| `dismissOnScroll` | `bool` | `false` | Dismiss when a scrollable in the tree scrolls. Good for dropdowns, not for dialogs. |
| `onDismiss` | `VoidCallback?` | `null` | Called when the overlay is dismissed. |

!!! tip
    Prefer the widget-specific helpers (`OiDialog.show`, `OiToast.show`,
    `OiSheet.show`) over calling `OiOverlays.of(context).show` by hand. They set
    the right z-order and scrim for you.

## Related

- [Buttons & Actions](buttons.md) for the buttons that go in dialog footers and menus.
