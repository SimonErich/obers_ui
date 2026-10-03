# Chat, Comments & Notifications

These modules are the surfaces where people talk to each other, talk to an
assistant, and keep up with what happened. Each one takes a list of typed models
and a set of callbacks. You own the data, the module renders it and tells you
when the user acts.

| Widget | What it does |
| --- | --- |
| `OiChat` | Real-time messaging. Newest message at the bottom, input bar below. |
| `OiChatWindow` | An LLM chat with streaming, suggestion chips, and a provider selector. |
| `OiComments` | Threaded discussion. Newest thread reads top to bottom. |
| `OiActivityFeed` | An event log with category filters and infinite scroll. |
| `OiNotificationCenter` | A notification inbox with read and unread state and bulk actions. |

!!! note "Chat vs Comments"
    Both show messages, but they flow in opposite directions. `OiChat` is a
    live conversation. It uses a reversed list, so the newest message sits at
    the bottom and the input bar is right below it. `OiComments` is a
    discussion thread. It reads top to bottom, with the input bar at the
    bottom for a new top-level comment. Reach for `OiChat` for direct messages
    and rooms. Reach for `OiComments` for replies under a post, a document, or
    a task.

## OiChat

A messaging interface for real-time conversations. It shows the current user's
messages on the right and everyone else's on the left, with an input bar,
optional avatars, reactions, attachments, and a typing indicator. The list is
reversed, so the newest message is at the bottom.

You pass every message as an `OiChatMessage`. Each message needs a `key`, the
sender, the content, and a timestamp. Set `currentUserId` so the module knows
which bubbles to align right.

```dart
OiChat(
  label: 'Team chat',
  currentUserId: 'me',
  messages: [
    OiChatMessage(
      key: '1',
      senderId: 'ada',
      senderName: 'Ada',
      content: 'Ready for the demo?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    OiChatMessage(
      key: '2',
      senderId: 'me',
      senderName: 'You',
      content: 'Yes, joining now.',
      timestamp: DateTime.now(),
    ),
  ],
  onSend: (text) => sendMessage(text),
)
```

Turn on the extras with the callbacks. `onReact` fires with the message and an
emoji when the user long-presses a bubble. `onAttach` fires with picked files.
`onLoadOlder` runs when the user scrolls up and `olderMessagesAvailable` is
`true`.

```dart
OiChat(
  label: 'Team chat',
  currentUserId: 'me',
  messages: messages,
  typingUsers: const ['Ada'],
  onSend: (text) => sendMessage(text),
  onAttach: (files) => uploadFiles(files),
  onReact: (message, emoji) => react(message, emoji),
  onLoadOlder: loadOlderPage,
  olderMessagesAvailable: hasMore,
)
```

### OiChatMessage

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `Object` | **required** | Unique identifier for the message. |
| `senderId` | `String` | **required** | ID of the sender. Match against `currentUserId`. |
| `senderName` | `String` | **required** | Display name shown above the bubble. |
| `content` | `String` | **required** | The message text. |
| `timestamp` | `DateTime` | **required** | When the message was sent. |
| `senderAvatar` | `String?` | `null` | Optional avatar URL. |
| `reactions` | `List<OiReactionData>?` | `null` | Emoji reactions on the message. |
| `attachments` | `List<OiFileData>?` | `null` | File attachments. |
| `pending` | `bool` | `false` | Dims the bubble while the message is still sending. |

An `OiReactionData` holds an `emoji`, a `count`, and a `reacted` flag. An
`OiFileData` holds a `name`, a `size` in bytes, and optional `mimeType`,
`bytes`, and `url`.

### OiChat attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `messages` | `List<OiChatMessage>` | **required** | The conversation. |
| `currentUserId` | `String` | **required** | Aligns this user's messages to the right. |
| `label` | `String` | **required** | Accessibility label for the chat. |
| `onSend` | `ValueChanged<String>?` | `null` | Fires with the composed text. |
| `onAttach` | `ValueChanged<List<OiFileData>>?` | `null` | Fires with attached files. |
| `onReact` | `void Function(OiChatMessage, String emoji)?` | `null` | Fires on a reaction. |
| `onLoadOlder` | `Future<void> Function()?` | `null` | Loads an older page on scroll. |
| `olderMessagesAvailable` | `bool` | `false` | Whether more history exists. |
| `typingUsers` | `List<String>?` | `null` | Names shown in the typing indicator. |
| `showAvatars` | `bool` | `true` | Show sender avatars. |
| `showTimestamps` | `bool` | `true` | Show per-message timestamps. |
| `enableReactions` | `bool` | `true` | Allow emoji reactions. |
| `enableAttachments` | `bool` | `true` | Show the attach button. |
| `groupConsecutive` | `bool` | `true` | Group back-to-back messages from one sender. |
| `consecutiveThreshold` | `Duration` | `2 minutes` | Max gap for grouping messages. |

## OiChatWindow

A chat built for LLM and AI assistants. It renders Markdown message content,
streams the assistant reply as it arrives, and shows suggestion chips under
assistant messages. It also supports inline reactions, copy to clipboard,
message editing, and a slot for a provider selector.

Messages are `OiChatWindowMessage` objects. The `role` string, usually `'user'`
or `'assistant'`, decides the alignment. To stream a reply, set `streaming` to
`true` and feed the partial text through `streamingContent`.

```dart
OiChatWindow(
  label: 'Assistant',
  messages: [
    OiChatWindowMessage(
      id: '1',
      role: 'user',
      content: 'Summarize the release notes.',
      timestamp: DateTime.now().subtract(const Duration(seconds: 8)),
    ),
    OiChatWindowMessage(
      id: '2',
      role: 'assistant',
      content: 'Here is a short summary...',
      timestamp: DateTime.now(),
    ),
  ],
  onSendMessage: (text) => askAssistant(text),
)
```

Stream the reply and offer follow-up chips. `submitOnEnter` controls whether
Enter sends, or whether Cmd/Ctrl plus Enter is required.

```dart
OiChatWindow(
  label: 'Assistant',
  messages: messages,
  streaming: isStreaming,
  streamingContent: partialReply,
  submitOnEnter: true,
  providerSelector: providerDropdown,
  onSendMessage: (text) => askAssistant(text),
  onSuggestionTap: (message, suggestion) => pick(message, suggestion),
  onMessageReaction: (message, emoji) => rate(message, emoji),
  onNewSession: () => startNewChat(),
)
```

### OiChatWindowMessage

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `id` | `String` | **required** | Unique identifier for the message. |
| `role` | `String` | **required** | Sender role, e.g. `'user'` or `'assistant'`. |
| `content` | `String` | **required** | Message content in Markdown. |
| `timestamp` | `DateTime` | **required** | When the message was sent. |
| `suggestions` | `List<OiChatSuggestion>?` | `null` | Suggestion chips under the bubble. |
| `selectedSuggestionIds` | `List<String>?` | `null` | IDs of chosen suggestions. |
| `error` | `bool` | `false` | Marks the message as an error. |
| `attachments` | `List<OiChatAttachment>?` | `null` | Images or files above the bubble. |
| `reactions` | `Map<String, int>?` | `null` | Emoji to reaction count. |

An `OiChatSuggestion` has an `id`, a `text`, a `type` (`single` or `multi`),
and a `selected` flag.

### OiChatWindow attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `messages` | `List<OiChatWindowMessage>` | **required** | The conversation. |
| `label` | `String` | **required** | Accessibility label for the window. |
| `onSendMessage` | `void Function(String text)?` | `null` | Fires with the composed text. |
| `streamingContent` | `String?` | `null` | Partial assistant text while streaming. |
| `streaming` | `bool` | `false` | Whether the assistant is streaming now. |
| `inputPlaceholder` | `String` | `'Type a message...'` | Placeholder for the input. |
| `inputActions` | `List<Widget>?` | `null` | Extra widgets beside the input. |
| `inputMaxLines` | `int` | `6` | Max input lines before it scrolls. |
| `providerSelector` | `Widget?` | `null` | Slot for a model or provider picker. |
| `onNewSession` | `VoidCallback?` | `null` | Starts a new session. |
| `autoScrollToBottom` | `bool` | `true` | Follow the latest message. |
| `onScrollToTop` | `VoidCallback?` | `null` | Fires when the user reaches the top. |
| `onSuggestionTap` | `void Function(OiChatWindowMessage, OiChatSuggestion)?` | `null` | Fires on a chip tap. |
| `onMessageReaction` | `void Function(OiChatWindowMessage, String emoji)?` | `null` | Fires on a reaction. |
| `onMessageEdit` | `void Function(OiChatWindowMessage, String newContent)?` | `null` | Fires when a user edit is confirmed. |
| `submitOnEnter` | `bool` | `false` | Enter sends when `true`, else Cmd/Ctrl plus Enter. |

!!! tip "Which chat do I want?"
    Use `OiChatWindow` for an assistant that streams Markdown and offers
    follow-up suggestions. Use `OiChat` for person-to-person messaging with
    avatars, reactions, and attachments.

## OiComments

A threaded comment section. It reads top to bottom, indents nested replies up to
`maxDepth`, and shows a text input at the bottom for a new top-level comment.
Reach for this under a post, a document, or a task, not for live chat.

Each comment is an `OiComment`. Replies live in the `replies` list on the parent
comment, so the tree is nested, not flat.

```dart
OiComments(
  label: 'Comments',
  currentUserId: 'me',
  comments: [
    OiComment(
      key: '1',
      authorId: 'ada',
      authorName: 'Ada',
      content: 'Great write-up.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      replies: [
        OiComment(
          key: '2',
          authorId: 'me',
          authorName: 'You',
          content: 'Thanks!',
          timestamp: DateTime.now(),
        ),
      ],
    ),
  ],
  onComment: (text) => postComment(text),
  onReply: (parent, text) => postReply(parent, text),
  onEdit: (comment, text) => editComment(comment, text),
  onDelete: (comment) => deleteComment(comment),
  onReact: (comment, emoji) => react(comment, emoji),
)
```

### OiComment

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `Object` | **required** | Unique identifier for the comment. |
| `authorId` | `String` | **required** | ID of the author. |
| `authorName` | `String` | **required** | Display name of the author. |
| `content` | `String` | **required** | The comment text. |
| `timestamp` | `DateTime` | **required** | When the comment was posted. |
| `authorAvatar` | `String?` | `null` | Optional avatar URL. |
| `reactions` | `List<OiReactionData>?` | `null` | Emoji reactions on the comment. |
| `replies` | `List<OiComment>?` | `null` | Nested replies. |
| `edited` | `bool` | `false` | Shows an "(edited)" marker. |

### OiComments attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `comments` | `List<OiComment>` | **required** | The top-level comments. |
| `currentUserId` | `String` | **required** | The authenticated user's ID. |
| `label` | `String` | **required** | Accessibility label for the section. |
| `onComment` | `ValueChanged<String>?` | `null` | Fires on a new top-level comment. |
| `onReply` | `void Function(OiComment parent, String content)?` | `null` | Fires on a reply. |
| `onEdit` | `void Function(OiComment, String newContent)?` | `null` | Fires on an edit. |
| `onDelete` | `ValueChanged<OiComment>?` | `null` | Fires on a delete. |
| `onReact` | `void Function(OiComment, String emoji)?` | `null` | Fires on a reaction. |
| `maxDepth` | `int` | `5` | Max reply nesting depth. |
| `showAvatars` | `bool` | `true` | Show author avatars. |
| `showTimestamps` | `bool` | `true` | Show relative timestamps. |
| `emptyTitle` | `String` | `'No comments yet'` | Empty-state title. |
| `emptyDescription` | `String` | `'Be the first to share your thoughts.'` | Empty-state text. |

## OiActivityFeed

A timeline of events. Use it for an audit log, a "recent activity" panel, or a
history view. It shows each event with a leading icon indicator, an optional
description and timestamp, an optional category filter bar, and infinite scroll.

Events are `OiActivityEvent` objects. Only `key` and `title` are required. Add a
`category` to make an event filterable.

```dart
OiActivityFeed(
  label: 'Recent activity',
  events: [
    OiActivityEvent(
      key: '1',
      title: 'Ada deployed v2.1',
      description: 'Production build finished in 4m.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      icon: OiIcons.check,
      category: 'Deploys',
    ),
    OiActivityEvent(
      key: '2',
      title: 'Lin opened a pull request',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      icon: OiIcons.gitPullRequest,
      category: 'Code',
    ),
  ],
  onEventTap: (event) => openEvent(event),
)
```

Add the category bar and paging by passing `categories`, `activeCategory`, and
the callbacks. `onCategoryChange` passes `null` when the user taps the active
category again to clear the filter.

```dart
OiActivityFeed(
  label: 'Recent activity',
  events: events,
  categories: const ['Deploys', 'Code'],
  activeCategory: activeCategory,
  onCategoryChange: (value) => setState(() => activeCategory = value),
  moreAvailable: hasMore,
  loading: isLoading,
  onLoadMore: loadNextPage,
)
```

### OiActivityEvent

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `Object` | **required** | Unique identifier for the event. |
| `title` | `String` | **required** | Primary event text. |
| `description` | `String?` | `null` | Longer detail below the title. |
| `timestamp` | `DateTime?` | `null` | When the event happened. |
| `icon` | `IconData?` | `null` | Icon in the timeline indicator. |
| `leading` | `Widget?` | `null` | Custom indicator, replaces the icon. |
| `category` | `String?` | `null` | Category used by the filter bar. |

### OiActivityFeed attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `events` | `List<OiActivityEvent>` | **required** | The events to display. |
| `label` | `String` | **required** | Accessibility label for the feed. |
| `onEventTap` | `ValueChanged<OiActivityEvent>?` | `null` | Fires when an event is tapped. |
| `onLoadMore` | `Future<void> Function()?` | `null` | Loads the next page on scroll. |
| `moreAvailable` | `bool` | `false` | Whether more events exist. |
| `loading` | `bool` | `false` | Shows a progress bar while loading. |
| `emptyState` | `Widget?` | `null` | Custom widget when there are no events. |
| `showTimestamps` | `bool` | `true` | Show per-event timestamps. |
| `categories` | `List<String>?` | `null` | Filter chips shown above the list. |
| `activeCategory` | `String?` | `null` | The selected filter. |
| `onCategoryChange` | `ValueChanged<String?>?` | `null` | Fires with the new filter, or `null` to clear. |

## OiNotificationCenter

A notification inbox. It lists `OiNotification` items, marks unread ones with a
dot and a heavier title, shows an unread count badge in the header, and offers a
"Mark all read" action. Use it in a dropdown panel or a side sheet.

Each notification needs a `key`, a `title`, and a `timestamp`. Set `read` to
control the unread styling. Pass `unreadCount` for the header badge.

```dart
OiNotificationCenter(
  label: 'Notifications',
  unreadCount: 2,
  notifications: [
    OiNotification(
      key: '1',
      title: 'Ada mentioned you',
      body: 'in the design review thread',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      icon: OiIcons.messageSquare,
    ),
    OiNotification(
      key: '2',
      title: 'Build passed',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      read: true,
      icon: OiIcons.check,
    ),
  ],
  onNotificationTap: (item) => open(item),
  onMarkRead: (item) => markRead(item),
  onMarkAllRead: () => markAllRead(),
  onDismiss: (item) => dismiss(item),
)
```

`onMarkAllRead` is what puts the "Mark all read" button in the header. Leave it
`null` to hide the button.

### OiNotification

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `key` | `Object` | **required** | Unique identifier for the notification. |
| `title` | `String` | **required** | The notification title. |
| `timestamp` | `DateTime` | **required** | When it was created. |
| `body` | `String?` | `null` | Optional detail text, clamped to two lines. |
| `read` | `bool` | `false` | Whether it has been read. |
| `icon` | `IconData?` | `null` | Optional leading icon. |
| `leading` | `Widget?` | `null` | Custom leading widget, e.g. an avatar. |
| `category` | `String?` | `null` | Optional group key. |
| `onAction` | `VoidCallback?` | `null` | Optional per-item action. |

### OiNotificationCenter attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `notifications` | `List<OiNotification>` | **required** | The items to list. |
| `label` | `String` | **required** | Accessibility label for the center. |
| `onNotificationTap` | `ValueChanged<OiNotification>?` | `null` | Fires on a tap. |
| `onMarkRead` | `ValueChanged<OiNotification>?` | `null` | Marks one item as read. |
| `onMarkAllRead` | `VoidCallback?` | `null` | Shows and handles "Mark all read". |
| `onSnooze` | `ValueChanged<OiNotification>?` | `null` | Snoozes an item. |
| `onDismiss` | `ValueChanged<OiNotification>?` | `null` | Dismisses an item. |
| `groupBy` | `String Function(OiNotification)?` | `null` | Returns a group key per item. |
| `unreadCount` | `int` | `0` | Count shown in the header badge. |
| `showBadge` | `bool` | `true` | Show the unread badge. |
| `realTime` | `bool` | `false` | Marks the center as live-updating. |

## Related

- [Social](../widgets/social.md) for avatars, presence, and user chips.
- [Feedback & Status](../widgets/feedback.md) for badges, toasts, and progress.
- [Display](../widgets/display.md) for labels, cards, and empty states.
