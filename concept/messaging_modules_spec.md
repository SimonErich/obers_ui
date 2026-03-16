# obers_ui — Messaging & Comments Module Specification

> **Date:** 2026-03-16
> **Extends:** `base_concept.md`
> **Scope:** Tier 2 additions + Tier 4 modules for chat, comments, threads, and reactions.
> **Principle:** Every widget below composes from existing obers_ui primitives and components. Zero new rendering primitives.

---

## Table of Contents

- [Overview & Composition Map](#overview--composition-map)
- [New Tier 2 Components](#new-tier-2-components)
  - [OiRelativeTime](#oirelativetime)
  - [OiTimestamp](#oitimestamp)
  - [OiUnreadIndicator](#oiunreadindicator)
  - [OiMessageBubble](#oimessagebubble)
  - [OiReplyPreview](#oireplypreview)
  - [OiThreadSummary](#oithreadsummary)
  - [OiReactionPicker](#oireactionpicker)
  - [OiMessageActions](#oimessageactions)
  - [OiComposeBar](#oicomposebar)
- [New Tier 4 Modules](#new-tier-4-modules)
  - [OiChat (v2 — replaces existing)](#oichat-v2)
  - [OiThread](#oithread)
  - [OiComments (v2 — replaces existing)](#oicomments-v2)
- [Data Models](#data-models)
- [Theme Extensions](#theme-extensions)
- [Testing Strategy](#testing-strategy)

---

# Overview & Composition Map

This specification adds **9 Tier 2 components** and **3 Tier 4 modules** to obers_ui. The modules serve two use-cases with the same building blocks:

1. **Chat** — Real-time messaging (Slack, Discord, Teams). Messages flow bottom-to-top, own messages are visually distinct, threads open in a side panel or inline expansion.
2. **Comments** — Threaded discussion on a document/entity (GitHub, Notion, Figma). Messages flow top-to-bottom, all messages are styled equally, threads are inline-expandable.

Both share the same data model (`OiMessageData`) and compose from the same Tier 2 components. The modules differ only in layout, scroll direction, and styling defaults.

```
Composition Tree (new widgets marked with ★)

★ OiRelativeTime                   (Tier 2 — display)
★ OiTimestamp                      (Tier 2 — display, wraps OiRelativeTime)
★ OiUnreadIndicator                (Tier 2 — display)
★ OiReplyPreview                   (Tier 2 — display)
★ OiThreadSummary                  (Tier 2 — display)
★ OiReactionPicker                 (Tier 2 — feedback)
★ OiMessageActions                 (Tier 2 — interaction)
★ OiComposeBar                     (Tier 2 — input)
★ OiMessageBubble                  (Tier 2 — display)
   ├── OiAvatar           (existing)
   ├── OiLabel            (existing)
   ├── OiTimestamp         ★
   ├── OiReactionBar      (existing, now delegates picker to ★ OiReactionPicker)
   ├── OiReplyPreview      ★
   ├── OiThreadSummary     ★
   ├── OiMessageActions    ★
   ├── OiMarkdown         (existing, for rich content)
   └── OiImage            (existing, for attachments)

OiChat (v2, Tier 4)
   ├── OiVirtualList       (existing, reverse)
   ├── OiInfiniteScroll    (existing, top-load)
   ├── OiMessageBubble     ★
   ├── OiComposeBar        ★
   ├── OiTypingIndicator   (existing)
   ├── OiUnreadIndicator   ★ (separator + badge)
   ├── OiThread            ★ (side panel or inline)
   └── OiPanel / OiSheet   (existing, for thread panel)

OiThread (Tier 4)
   ├── OiVirtualList       (existing)
   ├── OiMessageBubble     ★ (root message)
   ├── OiMessageBubble     ★ (replies)
   ├── OiComposeBar        ★
   ├── OiTypingIndicator   (existing)
   └── OiDivider           (existing)

OiComments (v2, Tier 4)
   ├── OiVirtualList       (existing)
   ├── OiMessageBubble     ★
   ├── OiComposeBar        ★
   ├── OiThread            ★ (inline expansion)
   ├── OiUnreadIndicator   ★
   └── OiEmptyState        (existing)
```

---

# New Tier 2 Components

---

## OiRelativeTime

**What it is:** A text widget that displays a `DateTime` as a human-readable relative string ("just now", "2m ago", "3h ago", "Yesterday at 14:32", "Mar 3, 2026"). Auto-refreshes on a timer so "just now" transitions to "1m ago" without rebuild. This is a pure display primitive — no interactivity.

**Composes:** `OiLabel` (text output)

```dart
OiRelativeTime({
  required DateTime dateTime,
  OiRelativeTimeStyle style = OiRelativeTimeStyle.short,
  bool capitalize = false,
  bool live = true,
  Duration refreshInterval = const Duration(seconds: 30),
  String Function(DateTime)? formatAbsolute,
  String? semanticsLabel,
})

enum OiRelativeTimeStyle {
  /// "2m", "3h", "1d"
  narrow,
  /// "2m ago", "3h ago", "yesterday"
  short,
  /// "2 minutes ago", "3 hours ago", "yesterday at 14:32"
  long,
}
```

**Refresh strategy:**
- `live: true` starts an internal `Timer.periodic` that triggers `setState` to recalculate the relative string. Timer is disposed on widget disposal.
- Refresh interval adapts automatically: every 10s for the first minute, every 30s up to 1 hour, every 5min up to 24h, then stops (date won't change).
- `live: false` computes once and never updates. Useful for static lists.

**Formatting rules (all localizable):**
| Elapsed | narrow | short | long |
|---------|--------|-------|------|
| < 10s | "now" | "just now" | "just now" |
| < 60s | "30s" | "30s ago" | "30 seconds ago" |
| < 60m | "5m" | "5m ago" | "5 minutes ago" |
| < 24h | "3h" | "3h ago" | "3 hours ago" |
| < 48h | "1d" | "yesterday" | "yesterday at 14:32" |
| < 7d | "3d" | "3d ago" | "3 days ago" |
| same year | "Mar 3" | "Mar 3" | "March 3 at 14:32" |
| other year | "Mar 3 '25" | "Mar 3, 2025" | "March 3, 2025 at 14:32" |

**Accessibility:**
- `semanticsLabel` overrides the announced text. When null, the full `long`-style string is used for semantics regardless of visual style. This ensures screen readers always say "5 minutes ago" even when the visual shows "5m".

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Renders "just now" for DateTime.now() | Correct string for < 10s |
| Renders "5m ago" for 5 minutes past | Short style formatting |
| Renders "5 minutes ago" for long style | Long style formatting |
| Renders "5m" for narrow style | Narrow style formatting |
| Yesterday shows time for long style | "yesterday at 14:32" |
| Cross-year shows year | "Mar 3, 2025" |
| live=true auto-updates from "just now" to "1m ago" | Timer triggers rebuild |
| live=false does not update | No timer created |
| Timer disposes on widget removal | No leaks, pump(Duration) after dispose |
| Timer adapts interval | 10s initially, 30s after 1min |
| capitalize=true uppercases first letter | "Just now" not "just now" |
| Custom formatAbsolute overrides date format | Callback used for absolute dates |
| Semantics always uses long form | Screen reader announces "5 minutes ago" even for narrow |
| Golden: all styles, light + dark | Visual regression |

---

## OiTimestamp

**What it is:** An interactive timestamp that shows relative time by default and reveals absolute time in a tooltip on hover/focus. Intended for messages, comments, and activity feeds.

**Composes:** `OiRelativeTime` (display), `OiTooltip` (absolute time on hover), `OiTappable` (optional tap action)

```dart
OiTimestamp({
  required DateTime dateTime,
  OiRelativeTimeStyle style = OiRelativeTimeStyle.short,
  bool showTooltip = true,
  String Function(DateTime)? formatTooltip,
  VoidCallback? onTap,
  bool live = true,
  String? semanticsLabel,
})
```

**Behavior:**
- Renders `OiRelativeTime` as visible text.
- On hover or keyboard focus, an `OiTooltip` appears with the full absolute datetime: `"Monday, March 16, 2026 at 14:32:05"` (or custom via `formatTooltip`).
- `onTap` is optional — when provided, wraps in `OiTappable` (use-case: jump to message by timestamp in chat).
- Inherits `live` behavior from `OiRelativeTime`.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Renders relative time text | Correct OiRelativeTime output |
| Hover shows tooltip with absolute time | Tooltip appears with full date |
| Focus shows tooltip | Keyboard accessible |
| onTap fires on click | Callback invoked |
| No OiTappable wrapper when onTap is null | Clean DOM |
| Custom formatTooltip used | Callback overrides tooltip text |
| Semantics: full date announced | Screen reader reads absolute |

---

## OiUnreadIndicator

**What it is:** A visual separator and/or badge indicating unread content. Two modes: (1) as an inline separator in a message list ("3 new messages" divider), (2) as a dot/count badge on an external element (channel name, thread summary).

**Composes:** `OiDivider` (separator mode), `OiLabel` (count text), `OiBadge.count` / `OiBadge.dot` (badge mode), `OiSurface` (separator pill)

```dart
/// Inline separator — renders as a full-width divider with a centered label.
OiUnreadIndicator.separator({
  required int count,
  String Function(int count)? formatLabel,
  VoidCallback? onMarkRead,
  String? semanticsLabel,
})

/// Badge — renders as a dot or count badge for overlaying on other widgets.
OiUnreadIndicator.badge({
  required int count,
  bool dot = false,
  bool pulsing = false,
  OiBadgeColor color = OiBadgeColor.primary,
})
```

**Separator behavior:**
- Full-width line (uses `OiDivider`) with a centered pill containing "N new messages" (or `formatLabel(count)`).
- The pill uses `OiSurface` with the theme's `primary` color (subtle background, bold text).
- `onMarkRead` renders a small "Mark as read" button on the trailing side.
- When `count` is 0, the widget renders `SizedBox.shrink()`.

**Badge behavior:**
- Delegates to `OiBadge.count` or `OiBadge.dot` based on `dot` flag.
- `pulsing` activates `OiPulse` animation on the dot.
- This is a thin convenience wrapper — consumers who want full badge control can use `OiBadge` directly.

**Accessibility:**
- Separator: `Semantics(liveRegion: true)` so screen readers announce new messages automatically.
- Badge: `Semantics(label: "$count unread")`.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Separator renders divider with "3 new messages" | Correct layout |
| count=0 renders nothing | SizedBox.shrink |
| count=1 says "1 new message" (singular) | Pluralization |
| Custom formatLabel overrides text | Callback used |
| onMarkRead shows button | Button renders and fires |
| Badge shows count | OiBadge.count rendered |
| Badge dot mode | OiBadge.dot rendered |
| Pulsing dot animates | OiPulse active |
| Separator is a live region | Semantics liveRegion=true |
| Badge announces count | Semantics label present |
| Golden: separator light + dark | Visual regression |
| Golden: badge variants | Visual regression |

---

## OiMessageBubble

**What it is:** A single message display widget. The core building block for both chat and comments. Renders sender info, content, timestamp, reactions, reply preview, thread summary, and hover actions. Highly configurable via named constructors for chat vs. comment styling.

**Composes:** `OiAvatar` (sender), `OiLabel` (sender name, content), `OiMarkdown` (when rich content), `OiTimestamp` (time), `OiReactionBar` (reactions), `OiReplyPreview` (quoted reply), `OiThreadSummary` (thread info), `OiMessageActions` (hover toolbar), `OiImage` (attachments), `OiSurface` (bubble background), `OiTappable` (whole message tap)

```dart
OiMessageBubble({
  required OiMessageData message,
  required String currentUserId,
  OiMessageBubbleStyle style = OiMessageBubbleStyle.bubble,
  OiMessageBubbleAlignment alignment = OiMessageBubbleAlignment.byAuthor,
  bool showAvatar = true,
  bool showSenderName = true,
  bool showTimestamp = true,
  bool showReactions = true,
  bool showThreadSummary = true,
  OiAvatarSize avatarSize = OiAvatarSize.sm,
  // Callbacks
  void Function(OiMessageData message, String emoji)? onReact,
  void Function(OiMessageData message, String emoji)? onRemoveReact,
  ValueChanged<OiMessageData>? onReply,
  ValueChanged<OiMessageData>? onThreadOpen,
  ValueChanged<OiMessageData>? onEdit,
  ValueChanged<OiMessageData>? onDelete,
  ValueChanged<OiMessageData>? onCopy,
  ValueChanged<OiMessageData>? onReplyPreviewTap,
  VoidCallback? onTap,
  // Custom builders
  Widget Function(OiMessageData)? contentBuilder,
  List<OiMessageAction>? extraActions,
  String? semanticsLabel,
})

/// Chat style: bubbles, own-on-right, others-on-left, colored backgrounds.
OiMessageBubble.chat({...}) // same params, defaults: style=bubble, alignment=byAuthor

/// Comment style: flat, full-width, no alignment difference, muted background.
OiMessageBubble.comment({...}) // same params, defaults: style=flat, alignment=start, showAvatar=true

enum OiMessageBubbleStyle {
  /// Rounded bubble with colored background (chat-like).
  bubble,
  /// Flat full-width with subtle border-bottom (comment-like).
  flat,
  /// Compact: no background, inline layout (activity-feed-like).
  compact,
}

enum OiMessageBubbleAlignment {
  /// Own messages on end (right in LTR), others on start (left).
  byAuthor,
  /// All messages aligned to start.
  start,
}
```

**Layout (bubble style):**
```
┌─────────────────────────────────────────────────────────┐
│  ┌──┐  Sender Name · 5m ago                     [···]  │  ← hover shows OiMessageActions
│  │AV│  ┌──────────────────────────┐                     │
│  └──┘  │  ▸ Replying to Alice:    │  ← OiReplyPreview   │
│        │    "Original message..." │                     │
│        └──────────────────────────┘                     │
│        Message content goes here.                       │
│        Could be multiple lines or                       │
│        rich markdown content.                           │
│                                                         │
│        📎 document.pdf (2.4 MB)      ← attachments     │
│                                                         │
│        👍 3  ❤️ 1  😂 2  [+]         ← OiReactionBar   │
│        💬 5 replies · Last reply 2h ago                 │
│           ┌──┐┌──┐┌──┐              ← OiThreadSummary  │
│           │A1││A2││A3│                                  │
│           └──┘└──┘└──┘                                  │
└─────────────────────────────────────────────────────────┘
```

**Layout (flat/comment style):**
```
┌─────────────────────────────────────────────────────────┐
│  ┌──┐  Sender Name · 5m ago                     [···]  │
│  │AV│  Message content goes here.                       │
│  └──┘                                                   │
│        👍 3  ❤️ 1  [+]                                  │
│        💬 5 replies                                      │
├─────────────────────────────────────────────────────────┤  ← OiDivider
```

**Hover behavior:**
- On mouse hover (desktop), `OiMessageActions` toolbar slides in at the top-right corner of the bubble, overlaying the bubble edge.
- On long-press (mobile), `OiContextMenu` appears with the same actions.
- `OiMessageActions` fades in with a 100ms animation. On hover-exit, fades out after 200ms delay (prevents flicker when moving between message and toolbar).

**Own-message styling (when `alignment=byAuthor` and `message.senderId == currentUserId`):**
- Bubble aligned to end (right in LTR).
- Background uses `colors.primary.s100` (subtle tint).
- Avatar hidden by default (configurable).
- Sender name hidden by default (configurable).
- Actions include "Edit" and "Delete" in addition to standard actions.

**Content rendering:**
- Plain text: `OiLabel` with selectable text.
- Rich text (`message.richContent != null`): `OiMarkdown` renderer.
- `contentBuilder` overrides both — full custom rendering.
- Links are auto-detected and rendered as tappable with underline.

**Accessibility:**
- Each message is a `Semantics` node with: sender name, time, message content.
- Reactions are announced: "3 thumbs up, 1 heart, 2 laughing".
- Thread summary: "5 replies, last reply 2 hours ago".
- Actions accessible via keyboard: Tab focuses the message, Enter opens context menu or first action.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Renders sender name, avatar, content, timestamp | Core layout |
| Own message aligned right with tinted background | byAuthor alignment |
| Other message aligned left | byAuthor alignment |
| Flat style has no bubble, full-width | Comment mode |
| Compact style has minimal chrome | Activity feed mode |
| Avatar hidden when showAvatar=false | No OiAvatar rendered |
| Sender name hidden when showSenderName=false | No name label |
| Timestamp hidden when showTimestamp=false | No OiTimestamp |
| Reactions render via OiReactionBar | Reactions visible |
| onReact fires when reaction tapped | Callback invoked |
| Reply preview shows when message.replyTo != null | OiReplyPreview visible |
| onReplyPreviewTap fires on preview tap | Callback invoked |
| Thread summary shows when message.threadInfo != null | OiThreadSummary visible |
| onThreadOpen fires on thread summary tap | Callback invoked |
| Hover shows OiMessageActions toolbar | Desktop hover |
| Long-press shows context menu | Mobile gesture |
| onReply fires from action | Callback invoked |
| onEdit fires from action (own message only) | Callback invoked |
| onDelete fires from action (own message only) | Callback invoked |
| onCopy fires from action | Callback invoked |
| contentBuilder overrides default content | Custom widget rendered |
| extraActions appear in action menu | Custom actions visible |
| Rich content renders via OiMarkdown | Markdown parsed |
| Attachments render with file info | File name + size shown |
| Image attachments render inline | OiImage displayed |
| Pending message shows muted style + spinner | Pending state |
| Failed message shows error style + retry button | Error state |
| Deleted message shows "[deleted]" placeholder | Deleted state |
| Edited message shows "(edited)" label | Edited indicator |
| Links in content are tappable | Auto-link detection |
| Semantics: full message announced | Screen reader reads all parts |
| Reduced motion: no hover animation | Instant show/hide |
| Golden: bubble style, own/other, light + dark | Visual regression |
| Golden: flat style, light + dark | Visual regression |
| Golden: compact style, light + dark | Visual regression |
| Golden: with reactions, thread, reply preview | Visual regression |

---

## OiReplyPreview

**What it is:** A compact preview of a message being replied to. Shows a vertical accent bar, sender name, and a single-line truncation of the original message. Used inside `OiMessageBubble` and inside `OiComposeBar` (when composing a reply).

**Composes:** `OiSurface` (background), `OiLabel` (sender name, content preview), `OiAvatar` (optional small avatar), `OiIconButton` (dismiss in compose mode), `OiTappable` (tap to scroll to original)

```dart
OiReplyPreview({
  required String senderName,
  required String contentPreview,
  String? senderAvatar,
  Color? accentColor,
  bool showAvatar = false,
  bool dismissible = false,
  VoidCallback? onDismiss,
  VoidCallback? onTap,
  String? semanticsLabel,
})

/// Convenience: build from an OiMessageData
OiReplyPreview.fromMessage({
  required OiMessageData message,
  bool dismissible = false,
  VoidCallback? onDismiss,
  VoidCallback? onTap,
})
```

**Layout:**
```
┌──────────────────────────────────────────┐
│ ▎ Alice                             [×]  │  ← accent bar (left), dismiss (compose only)
│ ▎ Original message truncated to one...   │
└──────────────────────────────────────────┘
```

- Accent bar is 3px wide, uses `accentColor` or auto-derived from sender name hash.
- Content preview is single-line with ellipsis overflow.
- `dismissible=true` shows a close button (used in compose bar to cancel reply).
- `onTap` scrolls to the original message in the list (handled by parent module).

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Renders sender name and truncated content | Core layout |
| Accent bar visible on left edge | Colored bar |
| Long content truncates with ellipsis | Overflow handled |
| onTap fires | Callback invoked |
| dismissible shows close button | OiIconButton visible |
| onDismiss fires on close tap | Callback invoked |
| fromMessage factory extracts data correctly | Convenience constructor |
| Semantics: "Reply to Alice: message..." | Screen reader |
| Golden: light + dark, with/without dismiss | Visual regression |

---

## OiThreadSummary

**What it is:** A compact summary of a thread, shown below a root message. Displays reply count, participant avatars (stacked), last reply time, and an unread indicator.

**Composes:** `OiAvatarStack` (participants), `OiLabel` (reply count, last reply time), `OiRelativeTime` (last reply), `OiUnreadIndicator.badge` (unread), `OiTappable` (tap to open thread)

```dart
OiThreadSummary({
  required OiThreadInfo threadInfo,
  VoidCallback? onTap,
  bool compact = false,
  String? semanticsLabel,
})

class OiThreadInfo {
  final int replyCount;
  final int unreadCount;
  final DateTime? lastReplyAt;
  final List<OiParticipant> participants;
}

class OiParticipant {
  final String id;
  final String name;
  final String? avatarUrl;
}
```

**Layout:**
```
Default:
💬 5 replies · ┌──┐┌──┐┌──┐ · Last reply 2h ago  🔵
               │A1││A2││A3│
               └──┘└──┘└──┘

Compact:
💬 5  ┌──┐┌──┐ · 2h ago
      │A1││A2│
      └──┘└──┘
```

- `replyCount` formatted: "1 reply" / "5 replies" / "99+ replies".
- `participants` shown as `OiAvatarStack` with `maxVisible: 3`, size `xs`.
- `lastReplyAt` via `OiRelativeTime.short`.
- `unreadCount > 0` shows `OiUnreadIndicator.badge` at trailing edge.
- `onTap` opens the thread (callback handled by parent module).

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Shows reply count text | "5 replies" |
| Singular "1 reply" | Pluralization |
| Shows avatar stack of participants | OiAvatarStack visible |
| Shows last reply relative time | OiRelativeTime rendered |
| Unread badge shows when unreadCount > 0 | OiUnreadIndicator.badge visible |
| No unread badge when unreadCount == 0 | Nothing rendered |
| onTap fires | Callback invoked |
| Compact mode renders smaller | Reduced layout |
| Semantics: "5 replies, 2 unread, last reply 2 hours ago" | Screen reader |
| Golden: default + compact, light + dark | Visual regression |

---

## OiReactionPicker

**What it is:** A quick-access emoji picker that appears on hover or tap of a reaction "+" button. Shows a row of frequently-used emojis with a "more" button that opens the full `OiEmojiPicker`.

**Composes:** `OiPopover` (container), `OiTappable` (each quick emoji), `OiEmojiPicker` (full picker), `OiLabel` (emoji display), `OiIconButton` (trigger "+" button)

```dart
OiReactionPicker({
  required ValueChanged<String> onSelect,
  List<String> quickEmojis = const ['👍', '❤️', '😂', '😮', '😢', '🎉'],
  bool showFullPicker = true,
  Widget? trigger,
  String? semanticsLabel,
})
```

**Behavior:**
- Default trigger is `OiIconButton` with a "+" or smiley icon.
- On tap/click, a `OiPopover` appears with a single row of `quickEmojis`.
- Each emoji is an `OiTappable` with hover scale animation (1.0 → 1.3).
- If `showFullPicker`, a "..." or "more" button at the end opens `OiEmojiPicker` in the same popover.
- Selecting any emoji fires `onSelect` and closes the popover.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Tap trigger opens popover | Popover visible |
| Quick emojis render in row | 6 emojis displayed |
| Tap emoji fires onSelect with emoji string | Callback invoked |
| Popover closes after selection | Popover hidden |
| "More" button opens full OiEmojiPicker | Picker visible |
| Selecting from full picker fires onSelect | Callback invoked |
| Custom quickEmojis list | Provided emojis shown |
| Custom trigger widget | Replaces default button |
| Hover scales emoji up | Animation plays |
| Keyboard: arrows navigate, Enter selects | Keyboard accessible |
| Semantics: "Add reaction" on trigger | Screen reader |
| Golden: popover open, light + dark | Visual regression |

---

## OiMessageActions

**What it is:** A floating toolbar that appears on message hover (desktop) or via long-press (mobile). Contains icon buttons for common message actions: react, reply, thread, edit, delete, copy, and custom actions.

**Composes:** `OiSurface` (toolbar background), `OiIconButton` (each action), `OiTooltip` (action labels), `OiReactionPicker` (inline quick reactions)

```dart
OiMessageActions({
  required OiMessageData message,
  required String currentUserId,
  void Function(String emoji)? onReact,
  VoidCallback? onReply,
  VoidCallback? onThreadOpen,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
  VoidCallback? onCopy,
  VoidCallback? onPin,
  VoidCallback? onBookmark,
  List<OiMessageAction>? extraActions,
  OiMessageActionsLayout layout = OiMessageActionsLayout.horizontal,
})

class OiMessageAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool destructive;
}

enum OiMessageActionsLayout {
  /// Icon buttons in a horizontal row (desktop hover toolbar).
  horizontal,
  /// Vertical list items (mobile context menu / long-press).
  vertical,
}
```

**Behavior:**
- Horizontal layout: Renders as a compact row of `OiIconButton` widgets inside an `OiSurface` with elevation. Each button has an `OiTooltip`.
- Vertical layout: Renders as a list of labeled rows (icon + text) for context menu use.
- **Visibility rules by action:**
  - React, Reply, Copy, Pin, Bookmark: always shown (when callback provided).
  - Thread: shown when callback provided.
  - Edit: shown only when `message.senderId == currentUserId` and `onEdit != null`.
  - Delete: shown only when `message.senderId == currentUserId` and `onDelete != null`, styled as destructive (red).
- `onReact` integrates `OiReactionPicker` inline — the first button is a smiley that opens the picker.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Horizontal layout renders icon buttons | Correct layout |
| Vertical layout renders labeled rows | Context menu style |
| React button opens OiReactionPicker | Picker appears |
| Reply button fires onReply | Callback invoked |
| Edit hidden for non-own messages | Not rendered |
| Edit shown for own messages | Rendered |
| Delete styled as destructive | Red color |
| Extra actions appended | Custom actions visible |
| Tooltips show on hover | OiTooltip visible |
| Keyboard: Tab through actions | Focus management |
| Semantics: actions announced | Screen reader |
| Golden: horizontal + vertical, light + dark | Visual regression |

---

## OiComposeBar

**What it is:** A message input bar with text input, send button, attachment button, emoji picker, reply preview, and optional rich text. Used in both chat and comments.

**Composes:** `OiTextInput` or `OiRichEditor` (input field), `OiIconButton` (send, attach, emoji), `OiReplyPreview` (when replying), `OiReactionPicker` (emoji insertion), `OiFileInput` (attachment picker), `OiSurface` (bar background)

```dart
OiComposeBar({
  required String label,
  ValueChanged<String>? onSend,
  ValueChanged<OiComposePayload>? onSendRich,
  bool enableAttachments = true,
  bool enableEmoji = true,
  bool enableRichText = false,
  bool enableMentions = false,
  String placeholder = 'Write a message...',
  int maxLines = 5,
  OiMessageData? replyingTo,
  VoidCallback? onCancelReply,
  ValueChanged<List<OiFileData>>? onAttach,
  List<String>? allowedFileExtensions,
  int? maxFileSize,
  bool autofocus = false,
  bool disabled = false,
  Widget? leading,
  Widget? trailing,
})

class OiComposePayload {
  final String text;
  final String? richContent;
  final List<OiFileData> attachments;
  final OiMessageData? replyTo;
  final List<String> mentionedUserIds;
}
```

**Layout:**
```
┌──────────────────────────────────────────────────────────┐
│  ▎ Replying to Alice                               [×]  │  ← OiReplyPreview (when replyingTo != null)
│  ▎ Original message text...                              │
├──────────────────────────────────────────────────────────┤
│  📎  😀  │  Type a message...                       ➤   │
│          │                                               │
│          │                                          ➤   │
└──────────────────────────────────────────────────────────┘
     ↑         ↑                                      ↑
  attach    emoji                                   send
```

**Behavior:**
- Send button is disabled when text is empty and no attachments are present.
- Send button becomes active (primary color) when content is available.
- **Enter** sends (unless Shift+Enter for newline when `maxLines > 1`).
- When `replyingTo` is set, `OiReplyPreview` appears above the input with `dismissible: true`.
- `onCancelReply` fires when the reply preview is dismissed.
- Emoji button opens `OiReactionPicker` which inserts the emoji at cursor position.
- Attachment button opens file picker; selected files show as small chips below the input.
- `enableMentions` activates `@` mention suggestions via `OiSmartInput` patterns.
- Input auto-grows up to `maxLines`, then scrolls.
- `onSend` fires with plain text. `onSendRich` fires with full payload including attachments and reply reference.

**Accessibility:**
- Label is required for the input field's semantics.
- Send button has `Semantics(label: "Send message")`.
- Attach button: `Semantics(label: "Attach file")`.
- Emoji button: `Semantics(label: "Insert emoji")`.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Renders input field with placeholder | Core layout |
| Send button disabled when empty | Disabled state |
| Send button enabled when text present | Active state |
| Enter key fires onSend | Keyboard send |
| Shift+Enter inserts newline | Multiline support |
| onSend receives trimmed text | Whitespace handling |
| Input clears after send | Reset state |
| Reply preview shows when replyingTo set | OiReplyPreview visible |
| Dismiss reply preview fires onCancelReply | Callback invoked |
| Emoji button opens picker | OiReactionPicker visible |
| Emoji inserts at cursor | Text contains emoji |
| Attach button opens file picker | File picker triggered |
| Selected files show as chips | Chip list visible |
| Remove file chip removes attachment | Chip removed |
| onSendRich includes attachments and replyTo | Full payload |
| Rich text mode renders OiRichEditor | Editor visible |
| Mention support shows suggestions | Popover with names |
| Auto-grow up to maxLines | Height increases |
| Scrolls after maxLines | Scrollable |
| disabled=true prevents all input | Disabled state |
| autofocus=true focuses on mount | Input focused |
| Semantics: all buttons labeled | Screen reader |
| Golden: empty, typing, with reply, with attachments | Visual regression |

---

# New Tier 4 Modules

---

## OiChat (v2)

**What it is:** A complete chat/messaging interface. Replaces the existing `OiChat` module from the base concept with full threading, reply-to, reactions, unread indicators, and configurable layout.

**Composes:** `OiVirtualList` (messages, reverse scroll), `OiInfiniteScroll` (load older messages), `OiMessageBubble.chat` (each message), `OiComposeBar` (input), `OiTypingIndicator` (typing status), `OiUnreadIndicator.separator` (new message divider), `OiThread` (thread panel/expansion), `OiPanel` or `OiSheet` (thread container), `OiSurface` (background)

```dart
OiChat({
  required List<OiMessageData> messages,
  required String currentUserId,
  required String label,
  // Send
  ValueChanged<String>? onSend,
  ValueChanged<OiComposePayload>? onSendRich,
  // Reactions
  void Function(OiMessageData, String emoji)? onReact,
  void Function(OiMessageData, String emoji)? onRemoveReact,
  // Threading
  void Function(OiMessageData parent, String reply)? onThreadReply,
  ValueChanged<OiMessageData>? onThreadOpen,
  OiChatThreadMode threadMode = OiChatThreadMode.panel,
  // Message actions
  ValueChanged<OiMessageData>? onEdit,
  ValueChanged<OiMessageData>? onDelete,
  // Loading
  VoidCallback? onLoadOlder,
  bool hasOlderMessages = false,
  bool loadingOlder = false,
  // Unread
  int? unreadSeparatorIndex,
  VoidCallback? onMarkAllRead,
  // Presence
  List<String>? typingUsers,
  List<OiParticipant>? typingUserDetails,
  // Display options
  bool showAvatars = true,
  bool showTimestamps = true,
  bool enableReactions = true,
  bool enableAttachments = true,
  bool enableRichText = false,
  bool enableThreads = true,
  bool groupConsecutive = true,
  Duration consecutiveThreshold = const Duration(minutes: 2),
  // Attachments
  ValueChanged<List<OiFileData>>? onAttach,
  List<String>? allowedFileExtensions,
  // Compose
  String composePlaceholder = 'Write a message...',
  bool composeAutofocus = false,
  // Builders
  Widget Function(OiMessageData)? messageBuilder,
  Widget Function(DateTime)? dateSeparatorBuilder,
})

enum OiChatThreadMode {
  /// Thread opens in a side panel (like Slack).
  panel,
  /// Thread expands inline below the message (like Discord).
  inline,
  /// No threading — replies are flat in the main channel.
  disabled,
}
```

**Layout:**

```
┌──────────────────────────────────────────────────────────┐
│  Chat: #general                                          │
│                                                          │
│  ─────── March 15, 2026 ───────                          │  ← date separator
│                                                          │
│  ┌──┐ Alice · 2:30 PM                                   │
│  │AV│ Hey everyone!                                      │
│  └──┘ 👍 2  💬 3 replies                                 │
│                                                          │
│       Did you see the new designs?                       │  ← grouped (same sender, < 2min)
│                                                          │
│  ─────── 3 new messages ───────                          │  ← OiUnreadIndicator.separator
│                                                          │
│  ┌──┐ Bob · 2:45 PM                                     │
│  │AV│ ▸ Replying to Alice                                │  ← OiReplyPreview
│  └──┘   "Hey everyone!"                                  │
│       Looks great!                                       │
│                                                          │
│                                    I agree! ┌──┐         │  ← own message (right-aligned)
│                                             │ME│         │
│                                             └──┘         │
│                                                          │
│  Alice is typing...                                      │  ← OiTypingIndicator
├──────────────────────────────────────────────────────────┤
│  📎  😀  │  Write a message...                      ➤   │  ← OiComposeBar
└──────────────────────────────────────────────────────────┘
```

**Thread panel mode (Slack-like):**
```
┌────────────────────────────┬────────────────────────────┐
│  Main Channel              │  Thread                    │
│                            │                            │
│  messages...               │  ┌──┐ Alice · 2:30 PM     │  ← root message
│                            │  │AV│ Hey everyone!        │
│                            │  └──┘                      │
│                            │  ─────────────────         │
│                            │  ┌──┐ Bob · 2:45 PM       │  ← replies
│                            │  │AV│ Looks great!         │
│                            │  └──┘                      │
│                            │  ┌──┐ Carol · 2:50 PM     │
│                            │  │AV│ +1                   │
│                            │  └──┘                      │
│                            ├────────────────────────────┤
│                            │  Reply in thread...   ➤   │
│ ──────────────────         │                            │
│  📎 😀 │ Message...   ➤   │                            │
└────────────────────────────┴────────────────────────────┘
```

**Consecutive message grouping:**
- When `groupConsecutive=true`, consecutive messages from the same sender within `consecutiveThreshold` are grouped.
- First message in a group shows avatar and sender name.
- Subsequent messages show only content (no avatar, no name), with reduced top spacing.
- Timestamp shows on hover for grouped messages.

**Date separators:**
- Automatically inserted between messages on different calendar days.
- Format: "Today", "Yesterday", "March 15, 2026".
- `dateSeparatorBuilder` overrides the default.

**Unread separator:**
- When `unreadSeparatorIndex` is set, an `OiUnreadIndicator.separator` is inserted at that position.
- Count is `messages.length - unreadSeparatorIndex`.
- `onMarkAllRead` button appears on the separator.

**Scroll behavior:**
- Reverse virtual list — newest messages at bottom, scroll up for history.
- Auto-scrolls to bottom on new message if user is already at bottom.
- If user has scrolled up, a "↓ N new messages" floating badge appears at bottom.
- `onLoadOlder` fires when scrolling to top (via `OiInfiniteScroll`).
- `loadingOlder` shows a shimmer/spinner at the top.

**Reply flow:**
1. User clicks "Reply" action on a message.
2. `OiComposeBar` enters reply mode: `OiReplyPreview` appears above input.
3. User types and sends. `onSendRich` payload includes `replyTo`.
4. Reply preview dismissible via close button (fires `onCancelReply` internally, clears state).

**Thread flow (panel mode):**
1. User clicks thread summary or "Thread" action.
2. `OiPanel` slides in from the right with `OiThread` inside.
3. Thread has its own `OiComposeBar`.
4. `onThreadReply` fires when user sends a reply in the thread.
5. Panel can be dismissed (fires no callback — state managed by consumer or internally).

**Thread flow (inline mode):**
1. User clicks thread summary.
2. Thread expands inline below the root message with indented replies.
3. A compact `OiComposeBar` appears at the bottom of the expanded thread.
4. `onThreadReply` fires on send.
5. Clicking again collapses.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Messages render in order (newest at bottom) | Reverse list |
| Own messages aligned right | byAuthor alignment |
| Other messages aligned left | byAuthor alignment |
| Avatars show when showAvatars=true | OiAvatar visible |
| Timestamps show when showTimestamps=true | OiTimestamp visible |
| Consecutive messages from same sender grouped | Reduced chrome on subsequent |
| Grouped messages show timestamp on hover | Hover reveals time |
| Date separator between different days | Separator visible |
| "Today" / "Yesterday" labels correct | Date formatting |
| Unread separator at correct index | OiUnreadIndicator.separator visible |
| Unread count correct | "3 new messages" |
| Mark all read button fires callback | onMarkAllRead invoked |
| Typing indicator shows typing users | OiTypingIndicator visible |
| Send button fires onSend | Callback invoked |
| Reply action puts compose bar in reply mode | OiReplyPreview appears |
| Cancel reply clears reply state | Preview dismissed |
| Sent reply includes replyTo in payload | Correct data |
| Reply preview shows on message with replyTo | OiReplyPreview in bubble |
| Tap reply preview scrolls to original (if visible) | Scroll animation |
| Reactions show on messages | OiReactionBar visible |
| React fires onReact with message + emoji | Callback invoked |
| Thread summary shows on messages with threads | OiThreadSummary visible |
| Thread summary tap opens panel (panel mode) | OiPanel slides in |
| Thread panel renders root message + replies | Full thread |
| Thread compose bar fires onThreadReply | Callback invoked |
| Thread inline mode expands below message | Indented replies |
| Thread inline collapse | Replies hidden |
| Scroll to bottom on new message (when at bottom) | Auto-scroll |
| "N new messages" badge when scrolled up | Floating badge |
| Tap floating badge scrolls to bottom | Scroll animation |
| onLoadOlder fires when scrolling to top | Callback invoked |
| loadingOlder shows spinner | Loading state |
| hasOlderMessages=false hides load trigger | No trigger |
| Attachments in compose bar | File chips visible |
| Edit action on own message fires onEdit | Callback invoked |
| Delete action on own message fires onDelete | Callback invoked |
| messageBuilder overrides default bubble | Custom widget |
| dateSeparatorBuilder overrides default | Custom separator |
| Keyboard: Enter sends, Shift+Enter newline | Keyboard handling |
| Keyboard: Tab navigates messages | Focus management |
| Semantics: message list labeled | Screen reader |
| Semantics: live region for new messages | Announced automatically |
| Performance: 10,000 messages, <16ms frame | Virtual list perf |
| Golden: full chat, light + dark | Visual regression |

---

## OiThread

**What it is:** A standalone thread view. Shows a root message, a divider, then a list of reply messages with its own compose bar. Can be embedded in an `OiPanel` (for chat thread panels) or rendered inline (for comment threads).

**Composes:** `OiMessageBubble` (root + replies), `OiVirtualList` (reply list), `OiComposeBar` (reply input), `OiDivider` (separator), `OiTypingIndicator`, `OiLabel` (reply count header)

```dart
OiThread({
  required OiMessageData rootMessage,
  required List<OiMessageData> replies,
  required String currentUserId,
  required String label,
  ValueChanged<String>? onReply,
  ValueChanged<OiComposePayload>? onReplyRich,
  void Function(OiMessageData, String emoji)? onReact,
  void Function(OiMessageData, String emoji)? onRemoveReact,
  ValueChanged<OiMessageData>? onEdit,
  ValueChanged<OiMessageData>? onDelete,
  List<String>? typingUsers,
  VoidCallback? onClose,
  bool showCloseButton = true,
  OiMessageBubbleStyle messageStyle = OiMessageBubbleStyle.flat,
  bool enableReactions = true,
  bool enableAttachments = true,
  String composePlaceholder = 'Reply in thread...',
  VoidCallback? onLoadOlderReplies,
  bool hasOlderReplies = false,
})
```

**Layout:**
```
┌──────────────────────────────────────────────┐
│  Thread                                 [×]  │  ← header with close button
├──────────────────────────────────────────────┤
│  ┌──┐ Alice · 2:30 PM                       │  ← root message (emphasized)
│  │AV│ Hey everyone! Check out the new        │
│  └──┘ designs for the landing page.          │
│       👍 3  ❤️ 1                              │
├──────────────────────────────────────────────┤  ← divider
│  5 replies                                   │  ← reply count header
│                                              │
│  ┌──┐ Bob · 2:45 PM                         │
│  │AV│ Looks great!                           │
│  └──┘                                        │
│                                              │
│  ┌──┐ Carol · 2:50 PM                       │
│  │AV│ Love the color palette.                │
│  └──┘ 👍 1                                    │
│                                              │
│  Bob is typing...                            │
├──────────────────────────────────────────────┤
│  Reply in thread...                     ➤    │  ← OiComposeBar
└──────────────────────────────────────────────┘
```

**Behavior:**
- Root message is rendered with `OiMessageBubble` but with a slightly larger/emphasized style (thicker border or subtle background).
- Replies are `OiMessageBubble` in flat style by default (no bubble alignment — all start-aligned).
- Reply count header updates reactively.
- `onClose` and close button are for panel usage. When embedded inline, set `showCloseButton: false`.
- Supports all message interactions: reactions, edit (own), delete (own), copy.
- Does NOT support nested threads (replies to replies). All replies are flat within the thread.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Root message renders with emphasis | Emphasized style |
| Replies render below divider | Correct order |
| Reply count header accurate | "5 replies" |
| onReply fires on compose send | Callback invoked |
| Reply added to list | New message visible |
| Close button fires onClose | Callback invoked |
| showCloseButton=false hides it | Not rendered |
| Reactions on root and replies | OiReactionBar visible |
| Edit/delete on own replies | Actions available |
| Typing indicator in thread | OiTypingIndicator visible |
| Load older replies | OiInfiniteScroll |
| Semantics: thread labeled | Screen reader |
| Golden: thread panel, light + dark | Visual regression |

---

## OiComments (v2)

**What it is:** A threaded comment system for documents, issues, posts, or any entity. Comments flow top-to-bottom. Each top-level comment can have an expandable thread. Replaces the existing `OiComments` stub from the base concept.

**Composes:** `OiVirtualList` (comment list), `OiMessageBubble.comment` (each comment), `OiThread` (inline thread expansion), `OiComposeBar` (new comment input), `OiUnreadIndicator` (unread comments), `OiEmptyState` (no comments)

```dart
OiComments({
  required List<OiCommentThread> threads,
  required String currentUserId,
  required String label,
  // Actions
  ValueChanged<String>? onComment,
  ValueChanged<OiComposePayload>? onCommentRich,
  void Function(OiCommentThread thread, String reply)? onReply,
  void Function(OiMessageData, String emoji)? onReact,
  void Function(OiMessageData, String emoji)? onRemoveReact,
  ValueChanged<OiMessageData>? onEdit,
  ValueChanged<OiMessageData>? onDelete,
  // Display
  bool enableReactions = true,
  bool enableRichText = false,
  bool enableAttachments = false,
  bool autoExpandThreads = false,
  int previewReplyCount = 2,
  // Sorting
  OiCommentSort sortBy = OiCommentSort.newest,
  ValueChanged<OiCommentSort>? onSortChange,
  // Unread
  int? unreadCount,
  VoidCallback? onMarkAllRead,
  // Loading
  VoidCallback? onLoadMore,
  bool hasMore = false,
  bool loading = false,
  // Empty
  String emptyTitle = 'No comments yet',
  String emptyDescription = 'Be the first to share your thoughts.',
  // Builders
  Widget Function(OiMessageData)? commentBuilder,
  String composePlaceholder = 'Write a comment...',
})

class OiCommentThread {
  final OiMessageData rootComment;
  final List<OiMessageData> replies;
  final OiThreadInfo threadInfo;
  final bool expanded;
}

enum OiCommentSort { newest, oldest, mostReacted }
```

**Layout:**
```
┌──────────────────────────────────────────────────────────┐
│  Comments (12)                    Sort: Newest ▾   🔵 3  │  ← header, sort, unread badge
├──────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──┐ Alice · 5h ago                             [···]  │
│  │AV│ This looks amazing! Great work on the hover        │
│  └──┘ states and transitions.                            │
│       👍 5  ❤️ 2  [+]                                    │
│       💬 3 replies · ┌──┐┌──┐ · 2h ago                   │  ← OiThreadSummary
│                      │B ││C │                            │
│                      └──┘└──┘                            │
│                                                          │
│  ┌──┐ Bob · 3h ago                               [···]  │
│  │AV│ I think the border radius should be smaller        │
│  └──┘ on the cards. What do you think?                   │
│       💬 7 replies · ┌──┐┌──┐┌──┐ · 30m ago  🔵          │  ← unread in thread
│                      │A ││C ││D │                        │
│                      └──┘└──┘└──┘                        │
│                                                          │
│  ┌──┐ Carol · 1h ago                             [···]  │  ← NEW (unread)
│  │AV│ @Bob Agreed, maybe 8px instead of 12px?            │
│  └──┘                                                    │
│                                                          │
├──────────────────────────────────────────────────────────┤
│  Write a comment...                                 ➤    │  ← OiComposeBar
└──────────────────────────────────────────────────────────┘
```

**Expanded thread (inline):**
```
│  ┌──┐ Alice · 5h ago                                    │
│  │AV│ This looks amazing!                                │
│  └──┘ 👍 5  ❤️ 2  [+]                                    │
│       ┌ 3 replies ─────────────────── [collapse] ────┐   │
│       │  ┌──┐ Bob · 4h ago                           │   │
│       │  │AV│ Thanks! The hover states were tricky.   │   │
│       │  └──┘                                        │   │
│       │  ┌──┐ Carol · 3h ago                         │   │
│       │  │AV│ The transitions are smooth.             │   │
│       │  └──┘ 👍 1                                    │   │
│       │  ┌──┐ Alice · 2h ago                         │   │
│       │  │AV│ Glad you like them!                     │   │
│       │  └──┘                                        │   │
│       ├──────────────────────────────────────────────┤   │
│       │  Reply...                                ➤   │   │
│       └──────────────────────────────────────────────┘   │
```

**Thread expansion:**
- Clicking `OiThreadSummary` expands the thread inline.
- `autoExpandThreads` expands all threads on render.
- `previewReplyCount` shows the last N replies when collapsed (0 = show only summary, never preview).
- Expanded thread renders via `OiThread` with `showCloseButton: false` and `messageStyle: flat`.
- A "Collapse" button appears in the expanded header.

**Sort:**
- `sortBy` controls root-level comment order.
- `onSortChange` fires when the sort dropdown changes. Consumer re-sorts and provides new `threads` list.
- Thread replies are always chronological (oldest first).

**Unread indicators:**
- Top-level `unreadCount` badge in the header.
- Per-thread unread badge on `OiThreadSummary` (via `OiThreadInfo.unreadCount`).
- New (unread) comments can have a subtle highlight background (via `OiMessageData.unread`).
- `onMarkAllRead` button in header (when `unreadCount > 0`).

**Empty state:**
- When `threads` is empty, renders `OiEmptyState` with `emptyTitle` and `emptyDescription`.
- Compose bar still visible below empty state.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Comments render top-to-bottom | Correct order |
| All comments use flat/comment bubble style | No chat-style alignment |
| Thread summary shows on comments with replies | OiThreadSummary visible |
| Thread summary tap expands inline | Thread visible |
| Expanded thread shows all replies | Replies rendered |
| Expanded thread has its own compose bar | OiComposeBar visible |
| onReply fires on thread reply send | Callback invoked |
| Collapse button hides thread | Thread hidden |
| autoExpandThreads=true expands all | All threads open |
| previewReplyCount shows last N collapsed | Preview replies visible |
| Sort dropdown changes order | onSortChange fires |
| Newest sort: most recent first | Correct order |
| Oldest sort: oldest first | Correct order |
| mostReacted sort: highest reaction count first | Correct order |
| Unread count badge in header | Badge visible |
| Per-thread unread badge | OiUnreadIndicator.badge on summary |
| Unread comment has highlight background | Subtle tint |
| Mark all read button fires callback | onMarkAllRead invoked |
| New comment fires onComment | Callback invoked |
| onCommentRich includes full payload | Rich payload |
| Reactions on comments | OiReactionBar visible |
| Edit/delete on own comments | Actions visible |
| Empty state when no comments | OiEmptyState visible |
| Compose bar visible below empty state | Input available |
| loading=true shows skeleton | Loading state |
| Load more button fires onLoadMore | Callback invoked |
| commentBuilder overrides default | Custom widget |
| Keyboard: Tab through comments, actions | Focus management |
| Semantics: comment list labeled | Screen reader |
| Semantics: unread announced as live region | Announced |
| Performance: 5,000 comments with threads, <16ms | Virtual list perf |
| Golden: comments with threads, light + dark | Visual regression |
| Golden: empty state, light + dark | Visual regression |

---

# Data Models

All models are immutable (`@immutable` annotation). Constructors use `const` where possible.

```dart
@immutable
class OiMessageData {
  const OiMessageData({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.senderAvatar,
    this.richContent,
    this.reactions = const [],
    this.attachments = const [],
    this.replyTo,
    this.threadInfo,
    this.status = OiMessageStatus.sent,
    this.editedAt,
    this.unread = false,
    this.metadata,
  });

  /// Unique identifier for this message.
  final Object id;

  /// ID of the sender. Compared with `currentUserId` to determine own messages.
  final String senderId;

  /// Display name of the sender.
  final String senderName;

  /// Avatar URL of the sender. Falls back to initials derived from `senderName`.
  final String? senderAvatar;

  /// Plain text content. Always present even when `richContent` is set (used for
  /// previews, search, accessibility).
  final String content;

  /// Optional rich/markdown content. When present, rendered via `OiMarkdown`.
  /// `content` still holds the plain-text fallback.
  final String? richContent;

  /// When this message was created.
  final DateTime timestamp;

  /// When this message was last edited. Shows "(edited)" indicator when non-null.
  final DateTime? editedAt;

  /// Reactions on this message.
  final List<OiReactionData> reactions;

  /// File attachments.
  final List<OiFileData> attachments;

  /// If this message is a reply, the message being replied to.
  /// Used to render `OiReplyPreview`.
  final OiReplyToData? replyTo;

  /// Thread info. When non-null, indicates this message is a thread root
  /// and shows `OiThreadSummary`.
  final OiThreadInfo? threadInfo;

  /// Message delivery status.
  final OiMessageStatus status;

  /// Whether this message is unread by the current user.
  final bool unread;

  /// Arbitrary metadata for consumer use (e.g., message type, custom data).
  final Map<String, dynamic>? metadata;

  /// Returns true if `senderId` matches the provided `currentUserId`.
  bool isOwn(String currentUserId) => senderId == currentUserId;

  /// Creates a copy with the specified fields overridden.
  OiMessageData copyWith({...});
}

enum OiMessageStatus {
  /// Message is being sent (optimistic UI).
  pending,
  /// Message was sent and confirmed by the server.
  sent,
  /// Message failed to send.
  failed,
  /// Message was deleted.
  deleted,
}

@immutable
class OiReplyToData {
  const OiReplyToData({
    required this.messageId,
    required this.senderName,
    required this.contentPreview,
    this.senderAvatar,
  });

  final Object messageId;
  final String senderName;
  /// Truncated preview of the original message (max ~100 chars).
  final String contentPreview;
  final String? senderAvatar;
}

@immutable
class OiThreadInfo {
  const OiThreadInfo({
    required this.replyCount,
    this.unreadCount = 0,
    this.lastReplyAt,
    this.participants = const [],
  });

  final int replyCount;
  final int unreadCount;
  final DateTime? lastReplyAt;
  final List<OiParticipant> participants;
}

@immutable
class OiParticipant {
  const OiParticipant({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String? avatarUrl;
}

@immutable
class OiComposePayload {
  const OiComposePayload({
    required this.text,
    this.richContent,
    this.attachments = const [],
    this.replyTo,
    this.mentionedUserIds = const [],
  });

  final String text;
  final String? richContent;
  final List<OiFileData> attachments;
  final OiReplyToData? replyTo;
  final List<String> mentionedUserIds;
}
```

---

# Theme Extensions

Add to `OiComponentThemes`:

```dart
class OiComponentThemes {
  // ... existing fields ...

  final OiMessageBubbleThemeData? messageBubble;
  final OiComposeBarThemeData? composeBar;
  final OiThreadThemeData? thread;
  final OiTimestampThemeData? timestamp;
  final OiUnreadIndicatorThemeData? unreadIndicator;
}

@immutable
class OiMessageBubbleThemeData {
  const OiMessageBubbleThemeData({
    this.ownBubbleColor,
    this.otherBubbleColor,
    this.ownTextColor,
    this.otherTextColor,
    this.bubbleRadius,
    this.bubblePadding,
    this.senderNameStyle,
    this.contentTextStyle,
    this.hoverActionsElevation,
    this.groupedSpacing,
    this.ungroupedSpacing,
  });

  /// Background color for own messages. Defaults to `colors.primary.s100`.
  final Color? ownBubbleColor;
  /// Background color for other messages. Defaults to `colors.surface.s200`.
  final Color? otherBubbleColor;
  final Color? ownTextColor;
  final Color? otherTextColor;
  /// Border radius for bubbles. Defaults to `radius.lg`.
  final BorderRadius? bubbleRadius;
  final EdgeInsets? bubblePadding;
  final TextStyle? senderNameStyle;
  final TextStyle? contentTextStyle;
  /// Elevation of the hover actions toolbar. Defaults to `shadow.sm`.
  final double? hoverActionsElevation;
  /// Vertical spacing between grouped messages. Defaults to `spacing.xs`.
  final double? groupedSpacing;
  /// Vertical spacing between ungrouped messages. Defaults to `spacing.md`.
  final double? ungroupedSpacing;
}

@immutable
class OiComposeBarThemeData {
  const OiComposeBarThemeData({
    this.backgroundColor,
    this.borderColor,
    this.inputTextStyle,
    this.placeholderStyle,
    this.sendButtonColor,
    this.replyPreviewBackgroundColor,
    this.replyPreviewAccentColor,
  });

  final Color? backgroundColor;
  final Color? borderColor;
  final TextStyle? inputTextStyle;
  final TextStyle? placeholderStyle;
  final Color? sendButtonColor;
  final Color? replyPreviewBackgroundColor;
  final Color? replyPreviewAccentColor;
}

@immutable
class OiThreadThemeData {
  const OiThreadThemeData({
    this.panelWidth,
    this.rootMessageBackgroundColor,
    this.dividerColor,
    this.replyIndent,
  });

  /// Width of the thread side panel. Defaults to 400.
  final double? panelWidth;
  /// Background tint for the root message. Defaults to `colors.surface.s100`.
  final Color? rootMessageBackgroundColor;
  final Color? dividerColor;
  /// Left indent for inline thread replies. Defaults to `spacing.xl`.
  final double? replyIndent;
}

@immutable
class OiTimestampThemeData {
  const OiTimestampThemeData({
    this.textStyle,
    this.hoverTextStyle,
  });

  final TextStyle? textStyle;
  final TextStyle? hoverTextStyle;
}

@immutable
class OiUnreadIndicatorThemeData {
  const OiUnreadIndicatorThemeData({
    this.separatorColor,
    this.separatorTextStyle,
    this.highlightColor,
  });

  /// Color of the separator line and pill. Defaults to `colors.primary`.
  final Color? separatorColor;
  final TextStyle? separatorTextStyle;
  /// Background highlight for unread messages. Defaults to `colors.primary.s50`.
  final Color? highlightColor;
}
```

---

# Package Structure Additions

```
src/
  components/
    display/
      oi_relative_time.dart          ★ NEW
      oi_timestamp.dart              ★ NEW
      oi_unread_indicator.dart       ★ NEW
      oi_message_bubble.dart         ★ NEW
      oi_reply_preview.dart          ★ NEW
      oi_thread_summary.dart         ★ NEW
    feedback/
      oi_reaction_picker.dart        ★ NEW
    interaction/
      oi_message_actions.dart        ★ NEW
    inputs/
      oi_compose_bar.dart            ★ NEW

  modules/
    oi_chat.dart                     ★ REPLACED (v2)
    oi_thread.dart                   ★ NEW
    oi_comments.dart                 ★ REPLACED (v2)

  models/
    oi_message_data.dart             ★ NEW
    oi_reply_to_data.dart            ★ NEW
    oi_thread_info.dart              ★ NEW
    oi_participant.dart              ★ NEW
    oi_compose_payload.dart          ★ NEW
    oi_message_status.dart           ★ NEW
```

---

# Testing Strategy

## Unit Tests

- `OiRelativeTime` formatting: all elapsed ranges × all styles produce correct strings.
- `OiRelativeTime` timer: adapts interval from 10s → 30s → 5min.
- `OiRelativeTime` singular/plural: "1 minute ago" vs "2 minutes ago".
- `OiMessageData.isOwn()`: returns `true` when senderId matches, `false` otherwise.
- `OiMessageData.copyWith()`: preserves unmodified fields, overrides specified ones.
- `OiThreadInfo` participant deduplication: no duplicate IDs.
- `OiComposePayload` from plain text: richContent null, attachments empty.
- Unread separator index calculation: correct count from index to end.
- Consecutive message grouping logic: same sender + within threshold → grouped.
- Date separator insertion: different calendar days produce separators.
- Comment sort comparators: newest, oldest, mostReacted produce correct order.

## Widget Tests

Every component section above includes a detailed test table. Summary:

- **Per component:** All visual states (default, hover, focus, active, disabled, loading, error), all variants, all sizes.
- **Interaction:** Every callback fires with correct arguments. Keyboard navigation works. Touch gestures work.
- **Accessibility:** Every component has `Semantics` labels. Live regions announce new content. Focus order is logical.
- **Theming:** Every component renders correctly with both default and custom theme overrides.
- **Reduced motion:** Every animation respects `MediaQuery.disableAnimations`.

## Golden Tests

- `OiMessageBubble`: bubble/flat/compact × own/other × with-reactions/without × with-reply/without × with-thread/without × light/dark = 48 goldens.
- `OiReplyPreview`: with/without dismiss × light/dark = 4 goldens.
- `OiThreadSummary`: default/compact × with-unread/without × light/dark = 8 goldens.
- `OiUnreadIndicator`: separator/badge × light/dark = 4 goldens.
- `OiComposeBar`: empty/typing/with-reply/with-attachments × light/dark = 8 goldens.
- `OiChat`: full chat layout × light/dark = 2 goldens.
- `OiThread`: thread panel × light/dark = 2 goldens.
- `OiComments`: comments with threads expanded × light/dark = 2 goldens.

## Integration Tests

- **Chat send flow:** Type message → tap send → message appears at bottom → input clears.
- **Chat reply flow:** Tap reply action → reply preview appears in compose bar → type → send → message with reply preview appears.
- **Chat thread flow (panel):** Tap thread summary → panel slides in → type reply → send → reply appears in thread → thread summary count updates in main view.
- **Chat thread flow (inline):** Tap thread summary → thread expands → reply → collapse.
- **Chat unread flow:** Receive new messages while scrolled up → floating badge appears → tap badge → scrolls to bottom → unread separator visible.
- **Chat load history:** Scroll to top → loading spinner → older messages appear above.
- **Comment thread flow:** Post comment → comment appears → reply to comment → thread expands → reply visible.
- **Comment sort flow:** Change sort to oldest → comments reorder → change to mostReacted → comments reorder.
- **Reaction flow:** Hover message → tap reaction → reaction appears on message → tap own reaction → reaction removed.
- **Edit flow:** Hover own message → tap edit → message becomes editable → modify → save → "(edited)" appears.
- **Delete flow:** Hover own message → tap delete → confirmation dialog → confirm → "[deleted]" placeholder.

## Performance Tests

- `OiChat` with 100,000 messages: <16ms frame time (virtual list).
- `OiComments` with 5,000 comment threads (avg 10 replies each): <16ms frame time.
- `OiRelativeTime` with 1,000 instances (live=true): no timer leak, <1ms total tick overhead.
- Rapid thread open/close (100 cycles): no memory leak.
- Rapid reaction add/remove (100 cycles per message, 50 messages): smooth animation.

---

End of specification.
