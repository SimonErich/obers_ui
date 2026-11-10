# Gestures & Interaction

These are the low-level primitives that turn a plain widget into something the
user can tap, drag, zoom, copy, or reorder. Most of the time you reach for a
finished component like `OiButton` or `OiListTile`, which already use these
inside. Drop down to these primitives when you build a custom interactive widget
or a gesture that no component covers.

| Widget | What it does |
| --- | --- |
| `OiTappable` | The base for every clickable widget. Handles tap, hover, focus, and press states. |
| `OiTouchTarget` | Pads a small child to a 48 dp minimum touch area on touch devices. |
| `OiFocusTrap` | Keeps keyboard focus inside a subtree, for custom modals. |
| `OiDoubleTap` | Detects double-tap and single-tap on a child. |
| `OiLongPressMenu` | Shows a small context menu when the child is long-pressed. |
| `OiPinchZoom` | Two-finger pinch to zoom and pan, with min and max bounds. |
| `OiSwipeable` | Reveals action tiles when a list item is swiped left or right. |
| `OiDraggable` | Makes a widget draggable and carries typed data to a drop zone. |
| `OiDropZone` | Receives a dragged item and reports its hover state. |
| `OiReorderable` | A list whose items reorder by drag and drop. |
| `OiDragGhost` | The translucent preview shown under the finger while dragging. |
| `OiCopyable` | Copies text to the clipboard when its child is tapped. |
| `OiCopyButton` | A standalone copy button with a checkmark on success. |
| `OiPasteZone` | Detects Ctrl+V / Cmd+V anywhere in its subtree. |
| `OiRawInput` | The unstyled text-editing core used by every styled input. |

## OiTappable

The foundation of every interactive element in ObersUI. It wraps a child and
manages tap, double-tap, long-press, hover, focus, and disabled states, applying
the theme's interaction effects (background overlay, halo, scale) automatically.
Reach for it when you build a custom interactive widget. For a normal button,
use `OiButton` instead.

```dart
OiTappable(
  semanticLabel: 'Open profile',
  onTap: () => openProfile(),
  child: OiLabel.body('View profile'),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The widget to make interactive. |
| `onTap` | `VoidCallback?` | `null` | Called on tap. |
| `onDoubleTap` | `VoidCallback?` | `null` | Called on double tap. |
| `onLongPress` | `VoidCallback?` | `null` | Called on long press. |
| `onHover` | `ValueChanged<bool>?` | `null` | Fires when hover starts or ends (pointer devices only). |
| `onFocusChange` | `ValueChanged<bool>?` | `null` | Fires when keyboard focus enters or leaves. |
| `enabled` | `bool` | `true` | Set `false` to suppress all input and dim to 40% opacity. |
| `focusable` | `bool` | `true` | Whether the widget joins keyboard focus traversal. |
| `dragging` | `bool` | `false` | Set `true` while a parent drags this widget to apply the dragging effect. |
| `semanticLabel` | `String?` | `null` | Screen-reader label announced in place of the child. |
| `cursor` | `MouseCursor?` | `null` | Cursor on hover. Defaults to a click cursor when enabled. |
| `clipBorderRadius` | `BorderRadius?` | `null` | Clips the state overlay to a rounded shape. |

!!! tip
    Pressing Enter or Space while focused fires `onTap`, so keyboard users get
    the same behavior as a mouse click for free.

## OiTouchTarget

Pads a small child so it always has at least a 48 dp hit area on touch devices,
which meets the WCAG minimum. The child's look does not change. The extra area is
transparent and only responds to hit-testing. On pointer devices the minimum is
0 dp, so it becomes a pass-through.

```dart
// Reads the platform minimum from context.
OiTouchTarget(
  child: OiIcon(icon: OiIcons.close, label: 'Close'),
)

// Or force an explicit minimum.
OiTouchTarget.custom(
  minSize: 44,
  child: OiIcon(icon: OiIcons.close, label: 'Close'),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The widget whose hit area is enforced. |
| `minSize` | `double` | **required** (`.custom` only) | Explicit minimum size in logical pixels. |

!!! note
    `OiTappable` already wraps its child in an `OiTouchTarget`, so you rarely add
    this by hand. Use it when you attach a raw `GestureDetector` to a small icon.

## OiFocusTrap

Keeps keyboard focus inside its subtree. Tab and Shift+Tab cycle through the
focusable elements within the trap and wrap around at the ends, so focus never
escapes to the page behind. Use it when you build a custom modal-like widget.
Built-in overlays like `OiDialog` already use it.

```dart
OiFocusTrap(
  onEscape: () => close(),
  child: OiColumn(
    children: [
      OiTextInput(label: 'Name', controller: nameController),
      OiButton.primary(label: 'Save', onTap: save),
    ],
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The subtree that focus is confined to. |
| `initialFocus` | `bool` | `true` | Focus the first focusable child after the first frame. |
| `restoreFocus` | `bool` | `true` | Return focus to the previously focused widget on dispose. |
| `onEscape` | `VoidCallback?` | `null` | Called on Escape or the Android back button. |

## OiDoubleTap

Listens for a double tap, and optionally a single tap, on its child. The single
tap only fires when no double tap follows. Reach for it when double-tap is the
main gesture, like double-tapping an image to like it.

```dart
OiDoubleTap(
  onDoubleTap: () => like(),
  onTap: () => openImage(),
  child: OiImage.network(url: photoUrl, label: 'Photo'),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The widget that receives taps. |
| `onDoubleTap` | `VoidCallback?` | `null` | Called on double tap. |
| `onTap` | `VoidCallback?` | `null` | Called on single tap when no double tap follows. |
| `enabled` | `bool` | `true` | Set `false` to suppress both callbacks. |

## OiLongPressMenu

Shows a small floating menu near the press point when the child is long-pressed.
Tapping an item runs its callback and closes the menu. Tapping outside also
closes it. Good for mobile context actions on a list row or a message bubble.

```dart
OiLongPressMenu(
  items: [
    OiLongPressMenuItem(label: 'Copy', icon: OiIcons.copy, onTap: copy),
    OiLongPressMenuItem(label: 'Share', icon: OiIcons.share, onTap: share),
    OiLongPressMenuItem(label: 'Delete', icon: OiIcons.delete, onTap: remove),
  ],
  child: OiLabel.body('Long press me'),
)
```

Set `direction: Axis.horizontal` for a compact row of choices, handy for an
emoji-reaction style menu.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The widget that triggers the menu on long press. |
| `items` | `List<OiLongPressMenuItem>` | **required** | The menu entries. Each has `label`, `onTap`, and optional `icon`. |
| `enabled` | `bool` | `true` | Set `false` to ignore long presses. |
| `direction` | `Axis` | `vertical` | Lay items out in a column or a row. |
| `trailing` | `Widget?` | `null` | An extra widget appended after the items. |

!!! note
    For a desktop right-click menu, use `OiContextMenu`. Reach for
    `OiLongPressMenu` when long-press is the trigger, mainly on touch.

## OiPinchZoom

Wraps content with two-finger pinch-to-zoom and optional one-finger pan. Zoom is
clamped between `minScale` and `maxScale`. Use it for images, maps, and diagrams.

```dart
OiPinchZoom(
  minScale: 1.0,
  maxScale: 4.0,
  onScaleChanged: (scale) => setState(() => _scale = scale),
  child: OiImage.network(url: mapUrl, label: 'Site map'),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The content to zoom and pan. |
| `minScale` | `double` | `0.5` | Smallest allowed zoom. |
| `maxScale` | `double` | `4.0` | Largest allowed zoom. |
| `initialScale` | `double` | `1.0` | Starting zoom, clamped to the min and max. |
| `panEnabled` | `bool` | `true` | Whether the user can drag to pan while zoomed. |
| `onScaleChanged` | `ValueChanged<double>?` | `null` | Fires with the new scale on every change. |
| `clipBehavior` | `bool` | `true` | Whether content that overflows the bounds is clipped. |

## OiSwipeable

Reveals colored action tiles behind a list item when the user drags it sideways.
A rightward drag shows the leading actions, a leftward drag shows the trailing
ones. Turn on `dismissible` to let a long swipe remove the item.

```dart
OiSwipeable(
  leadingActions: [
    OiSwipeAction(
      label: 'Archive',
      icon: OiIcons.archive,
      color: context.colors.success.base,
      onTap: archive,
    ),
  ],
  trailingActions: [
    OiSwipeAction(
      label: 'Delete',
      icon: OiIcons.delete,
      color: context.colors.error.base,
      onTap: remove,
    ),
  ],
  dismissible: true,
  onDismissed: remove,
  child: OiListTile(title: 'Inbox item', label: 'Inbox item'),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The item content shown over the actions. |
| `leadingActions` | `List<OiSwipeAction>` | `[]` | Actions revealed on a left-to-right swipe. |
| `trailingActions` | `List<OiSwipeAction>` | `[]` | Actions revealed on a right-to-left swipe. |
| `threshold` | `double` | `0.4` | Fraction of the item width to trigger a dismiss. |
| `dismissible` | `bool` | `false` | Whether a full swipe removes the item. |
| `onDismissed` | `VoidCallback?` | `null` | Called when the item is dismissed. Requires `dismissible`. |

Each `OiSwipeAction` takes a `label`, a `color`, an `onTap`, and an optional
`icon`.

## OiDraggable

Makes its child draggable and carries typed `data` to any matching
`OiDropZone` of the same type. On touch devices the drag starts after a long
press. On pointer devices it starts as soon as you press and move. The type
parameter ties a draggable to the drop zones that accept it.

```dart
OiDraggable<Task>(
  data: task,
  onDragCompleted: () => markMoved(task),
  child: OiCard(child: OiLabel.body(task.title)),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `T` | **required** | The value delivered to the drop zone. |
| `child` | `Widget` | **required** | The widget that can be dragged. |
| `childWhenDragging` | `Widget?` | `null` | Shown at the origin during the drag. Defaults to the child staying put. |
| `feedback` | `Widget?` | `null` | The widget under the finger. Defaults to an `OiDragGhost` of the child. |
| `onDragStarted` | `VoidCallback?` | `null` | Called when the drag begins. |
| `onDragEnd` | `VoidCallback?` | `null` | Called when the drag ends, accepted or not. |
| `onDragCompleted` | `VoidCallback?` | `null` | Called only when a drop zone accepts the item. |
| `axis` | `Axis?` | `null` | Constrains movement to one axis. `null` allows any direction. |

## OiDropZone

Receives items dragged from an `OiDraggable` of the same type. Its `builder`
gets the current `OiDropState`, so you can highlight the zone while a compatible
item hovers. Use `onWillAccept` to accept or reject an item before it drops.

```dart
OiDropZone<Task>(
  onWillAccept: (task) => task != null && task.status != 'done',
  onAccept: (task) => moveToDone(task),
  builder: (context, state) => OiSurface(
    color: state == OiDropState.hovering
        ? context.colors.primary.subtle
        : context.colors.surface.base,
    child: OiLabel.body('Drop here'),
  ),
)
```

`OiDropState` is one of `idle`, `hovering`, `accepted`, or `rejected`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `onAccept` | `void Function(T data)` | **required** | Called with the data when a drop is accepted. |
| `builder` | `Widget Function(BuildContext, OiDropState)` | **required** | Builds the zone for the current drop state. |
| `onWillAccept` | `bool Function(T? data)?` | `null` | Returns `true` to accept a hovering item. `null` accepts every item. |

## OiReorderable

A scrolling list whose items reorder by drag and drop. On touch, dragging starts
after a long press. On pointer, it starts right away. Every child needs a unique
`Key` so Flutter can track it across moves. You update your own list in
`onReorder`.

```dart
OiReorderable(
  onReorder: (oldIndex, newIndex) => setState(() {
    final item = _items.removeAt(oldIndex);
    _items.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
  }),
  children: [
    for (final item in _items)
      OiListTile(key: ValueKey(item.id), title: item.name, label: item.name),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | **required** | The items. Each needs a unique `Key`. |
| `onReorder` | `void Function(int oldIndex, int newIndex)` | **required** | Called after a drop with the old and new positions. |
| `scrollDirection` | `Axis` | `vertical` | List scroll and drag direction. |
| `itemsAreFixed` | `bool` | `false` | Set `true` when all items are the same size to speed up rendering. |
| `shrinkWrap` | `bool` | `false` | Set `true` to size the list to its content, for use inside a `Column`. |
| `padding` | `EdgeInsetsGeometry?` | `null` | Padding around the list. |

!!! warning
    The `newIndex` from Flutter is the slot before insertion. When moving an item
    down, subtract 1, as the example does. Skip this and the item lands one slot
    off.

## OiDragGhost

The translucent preview shown under the finger or cursor during a drag. It
applies opacity, a small rotation, and a scale. `OiDraggable` uses it by default,
so you only build one by hand to customize the drag preview.

```dart
OiDraggable<Task>(
  data: task,
  feedback: OiDragGhost(
    opacity: 0.9,
    child: OiCard(child: OiLabel.body(task.title)),
  ),
  child: OiCard(child: OiLabel.body(task.title)),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The widget rendered as the ghost. |
| `scale` | `double?` | `null` | Scale factor. Defaults to `1.0` on touch and `1.05` on pointer. |
| `rotation` | `double?` | `null` | Rotation in radians. Defaults to `0.05` on touch and `0.0` on pointer. |
| `opacity` | `double` | `0.85` | Ghost opacity. |

## OiCopyable

Wraps any widget and copies `value` to the clipboard when the child is tapped, or
on Ctrl+C / Cmd+C when focused. Reach for it to make an ID, a code, or a URL
copyable with a click.

```dart
OiCopyable(
  value: 'ORD-10482',
  onCopied: () => showToast('Copied'),
  child: OiLabel.code('ORD-10482'),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `String` | **required** | The text written to the clipboard. |
| `child` | `Widget` | **required** | The widget that triggers the copy on tap. |
| `enabled` | `bool` | `true` | Set `false` to ignore taps and shortcuts. |
| `onCopied` | `VoidCallback?` | `null` | Called after a successful copy. |

!!! tip
    For a text value that also shows a copy affordance on hover, `OiLabel.copyable`
    is often simpler than wiring up `OiCopyable` yourself.

## OiCopyButton

A standalone copy button. Tapping it copies `value` and swaps its icon to a
checkmark for a moment. By default it renders as an `OiIconButton`, so it gets
hover and press states. Good next to an API key, a code, or an ID.

```dart
OiCopyButton(
  value: 'sk-live-8f2a...',
  semanticLabel: 'Copy API key',
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `String` | **required** | The text written to the clipboard. |
| `semanticLabel` | `String` | **required** | Screen-reader label for the button. |
| `feedbackDuration` | `Duration` | `1500 ms` | How long the checkmark stays before reverting. |
| `icon` | `Widget?` | `null` | Custom idle icon. Providing one opts out of the icon-button styling. |
| `copiedWidget` | `Widget?` | `null` | Custom widget shown right after a copy. |

## OiPasteZone

Detects a paste shortcut (Ctrl+V / Cmd+V) anywhere in its subtree and calls
`onPaste` with the clipboard text. Use it to accept pasted content without a text
field, like a "paste a shared link" drop area. The subtree needs focus first, so
set `autofocus: true` when it should catch paste right away.

```dart
OiPasteZone(
  autofocus: true,
  onPaste: (text) => setState(() => _invite = text),
  child: OiSurface(
    padding: EdgeInsets.all(context.spacing.md),
    child: OiLabel.body('Paste an invite code here'),
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `onPaste` | `ValueChanged<String>` | **required** | Called with the pasted text. |
| `child` | `Widget` | **required** | The subtree that listens for the shortcut. |
| `enabled` | `bool` | `true` | Set `false` to ignore the shortcut. |
| `autofocus` | `bool` | `false` | Request focus on first build so paste works without a click. |

## OiRawInput

The unstyled text-editing core that every styled input in ObersUI is built on.
It wraps `EditableText` with placeholder support, leading and trailing slots, and
scroll-into-view on focus. Reach for it only when you build a completely custom
input. For normal fields, use `OiTextInput`.

```dart
final controller = TextEditingController();
final focusNode = FocusNode();

OiRawInput(
  controller: controller,
  focusNode: focusNode,
  placeholder: 'Type here',
  onChanged: (value) => print(value),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `controller` | `TextEditingController` | **required** | Controls the edited text. |
| `focusNode` | `FocusNode` | **required** | The field's focus node. |
| `placeholder` | `String?` | `null` | Hint shown when the field is empty. |
| `leading` / `trailing` | `Widget?` | `null` | Widgets placed before or after the field. |
| `maxLines` | `int?` | `1` | Line count. `null` allows unlimited lines. |
| `minLines` | `int?` | `null` | Minimum lines the field occupies. |
| `maxLength` | `int?` | `null` | Maximum characters allowed. |
| `keyboardType` | `TextInputType` | `text` | Soft-keyboard type. |
| `textInputAction` | `TextInputAction` | `done` | The soft-keyboard action button. |
| `obscureText` | `bool` | `false` | Hide input, for passwords. |
| `onChanged` | `ValueChanged<String>?` | `null` | Fires when the text changes. |
| `onSubmitted` | `ValueChanged<String>?` | `null` | Fires when the user submits. |
| `enabled` | `bool` | `true` | Whether the field accepts input. |
| `readOnly` | `bool` | `false` | Show text but block edits. |
| `autofocus` | `bool` | `false` | Focus the field on insertion. |
| `inputFormatters` | `List<TextInputFormatter>?` | `null` | Formatters applied before `onChanged`. |

!!! warning
    `OiRawInput` has no border, label, or error display of its own. If you just
    need a text field, use `OiTextInput`, which handles all of that for you.

## Related

- [Buttons & Actions](buttons.md) for ready-made interactive controls.
- [Overlays & Menus](overlays.md) for dialogs, context menus, and popovers.
- [Text Inputs](text-inputs.md) for styled fields built on `OiRawInput`.
