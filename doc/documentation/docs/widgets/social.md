# Social & Presence

These widgets show who else is around. They cover group avatars, live cursors,
typing and selection state, and quoted replies. Reach for them when you build
chat, comments, or a shared surface that more than one person can see at once.

| Widget | What it does |
| --- | --- |
| `OiAvatarStack` | Overlapping avatars with a "+N" overflow badge. |
| `OiTypingIndicator` | The "Alice is typing..." line with animated dots. |
| `OiReplyPreview` | A one-line quote of the message you are replying to. |
| `OiLiveRing` | A pulsing ring around a child to mark it as live. |
| `OiCursorPresence` | Remote users' cursors drawn over a shared surface. |
| `OiSelectionPresence` | Exposes what remote users have selected to descendants. |

## OiAvatarStack

A horizontal row of overlapping avatars. When the list is longer than
`maxVisible`, it caps the row and adds a "+N" badge for the rest. Use it for
team members, participants, or assignees.

```dart
OiAvatarStack(
  users: [
    OiAvatarStackItem(label: 'Alice', initials: 'AL'),
    OiAvatarStackItem(label: 'Bob', imageUrl: 'https://…/bob.png'),
    OiAvatarStackItem(label: 'Carol', initials: 'CA'),
  ],
  onTap: (user) => openProfile(user),
)
```

Each avatar shows a tooltip with the user's `label` on hover. The overflow badge
lists the hidden names in its tooltip.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `users` | `List<OiAvatarStackItem>` | **required** | The users to show. Each has `label`, `imageUrl`, `initials`. |
| `maxVisible` | `int` | `4` | How many avatars to show before the "+N" badge. |
| `size` | `OiAvatarSize` | `sm` | `xs`, `sm`, `md`, `lg`, or `xl`. |
| `overlap` | `double` | `8` | Logical pixels each avatar overlaps the one before it. |
| `onTap` | `ValueChanged<OiAvatarStackItem>?` | `null` | Called with the tapped user. |

!!! note
    `label` on each `OiAvatarStackItem` is required. It is the tooltip text and
    the screen-reader name, so the stack stays accessible.

## OiTypingIndicator

The "typing..." line for chat. Pass the names of who is typing and it phrases the
message for you. The trailing dots animate on a loop.

```dart
OiTypingIndicator(
  typingUsers: ['Alice'],
)
```

It phrases the text by count:

- One user: "Alice is typing..."
- Two users: "Alice and Bob are typing..."
- Three or more: "3 people are typing..."

Pass an empty list and it renders nothing, so you can wire it straight to your
state without guarding it yourself.

Turn on `showAvatars` and pass `userDetails` to show a small avatar per user.

```dart
OiTypingIndicator(
  typingUsers: ['Alice', 'Bob'],
  showAvatars: true,
  userDetails: [
    OiAvatarStackItem(label: 'Alice', initials: 'AL'),
    OiAvatarStackItem(label: 'Bob', initials: 'BO'),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `typingUsers` | `List<String>` | **required** | Names of users typing. Empty renders nothing. |
| `showAvatars` | `bool` | `false` | Show a small avatar per user. |
| `userDetails` | `List<OiAvatarStackItem>?` | `null` | Avatar data used when `showAvatars` is on. |

!!! tip
    The dots stop animating when the user has reduced motion turned on. You do
    not need to handle that yourself.

## OiReplyPreview

A compact, one-line quote of the message being replied to. It shows an accent
bar, the sender name, and a single-line preview that ellipsizes. Common inside a
compose bar, where the user can cancel the reply.

```dart
OiReplyPreview(
  senderName: 'Alice',
  content: 'Are we still on for the 3pm sync?',
  dismissible: true,
  onDismiss: () => cancelReply(),
)
```

If you do not pass `accentColor`, the color is derived from `senderName`, so the
same sender always gets the same color.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `senderName` | `String` | **required** | The original sender's name. |
| `content` | `String` | **required** | The quoted text, shown on one line. |
| `accentColor` | `Color?` | `null` | Accent bar color. Auto-derived from the name when null. |
| `dismissible` | `bool` | `false` | Show a close button to cancel the reply. |
| `onDismiss` | `VoidCallback?` | `null` | Called when the close button is tapped. |
| `label` | `String?` | `null` | Accessibility label. Defaults to "Replying to \<senderName\>". |

## OiLiveRing

Wraps a child in a pulsing ring to mark it as live. Good for an avatar of someone
who is streaming, or a status dot that should draw the eye. The ring uses the
theme's success color by default.

```dart
OiLiveRing(
  child: OiAvatar(semanticLabel: 'Alice', initials: 'AL'),
)
```

Pass a color to match a brand or a status, and toggle `active` to turn the ring
off without swapping widgets.

```dart
OiLiveRing(
  active: isStreaming,
  color: context.colors.danger.base,
  child: OiAvatar(semanticLabel: 'Live channel', initials: 'LV'),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The widget to wrap. |
| `active` | `bool` | `true` | When false, renders `child` with no ring. |
| `color` | `Color?` | `null` | Ring color. Defaults to the theme's success color. |

## OiCursorPresence

Draws remote users' cursors on top of a shared surface. Give it the surface as
`child` and a list of cursors, and it positions each one and labels it with the
user's name. Stale cursors fade out.

```dart
OiCursorPresence(
  cursors: [
    OiRemoteCursor(
      userId: 'u1',
      name: 'Alice',
      color: context.colors.primary.base,
      position: const Offset(120, 80),
      lastMoved: DateTime.now(),
    ),
  ],
  child: myCanvas,
)
```

A cursor that has not moved for longer than `fadeAfter` renders at reduced
opacity, so idle collaborators do not clutter the view.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The shared surface the cursors sit over. |
| `cursors` | `List<OiRemoteCursor>` | **required** | The cursors to draw. See below. |
| `showNames` | `bool` | `true` | Show each user's name next to their cursor. |
| `fadeAfter` | `Duration` | `5s` | Cursors idle longer than this fade to low opacity. |

Each `OiRemoteCursor` takes `userId`, `name`, `color`, `position` (an `Offset`),
and `lastMoved` (a `DateTime`). All are required.

## OiSelectionPresence

Carries what remote users have selected down to descendant widgets. It does not
paint anything itself. You read the selections and draw your own highlights,
which lets it work for text ranges or object selections in a list or canvas.

```dart
OiSelectionPresence(
  selections: [
    OiRemoteSelection(
      userId: 'u1',
      name: 'Alice',
      color: context.colors.primary.base,
      selectedKeys: {'row-42'},
    ),
  ],
  child: myList,
)
```

Use the static helper to find who has a given key selected, then color that item
with each user's color.

```dart
final active = OiSelectionPresence.selectionsOf(selections, 'row-42');
final isSelectedByOthers = active.isNotEmpty;
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The content surface. |
| `selections` | `List<OiRemoteSelection>` | **required** | The remote selections to expose. |

Each `OiRemoteSelection` takes `userId`, `name`, and `color`, plus an optional
`textRange` (a `TextRange`) or `selectedKeys` (a `Set<Object>`). Use one kind of
selection at a time.

!!! note
    `OiSelectionPresence` is a data provider, not a painter. If nothing shows up,
    check that your item widgets actually read `selectionsOf` and draw a
    highlight.

## Related

- [Media](media.md) for `OiAvatar` and other single-user widgets.
- [Feedback & Status](feedback.md) for pulses, status dots, and progress.
