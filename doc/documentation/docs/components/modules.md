# Modules

Modules are complete, feature-rich screens you can drop into your app. They compose composites and components into full experiences with complex interactions, keyboard shortcuts, and settings persistence built in.

Think of modules as the "just add data" layer — the cream on top.

## Overview

| Module | Description |
|---|---|
| `OiFileExplorer` | Full file browser with sidebar, toolbar, grid/list views, search, drag-drop |
| `OiFileManager` | File operations UI (move, copy, delete, upload) |
| `OiDashboard` | Draggable, resizable widget grid |
| `OiKanban` | Kanban board with drag-and-drop columns |
| `OiChat` | Messaging interface with threads, reactions, typing indicators |
| `OiComments` | Threaded discussion system |
| `OiActivityFeed` | Chronological activity stream |
| `OiListView` | Complete list screen with sort, filter, pagination |
| `OiMetadataEditor` | Key-value metadata editor |
| `OiNotificationCenter` | Notification panel |
| `OiPermissions` | Role-based permission matrix |

---

## OiFileExplorer

A complete file browser — the Swiss Army knife of file UIs.

```dart
OiFileExplorer(
  roots: [rootNode],
  onOpen: (file) => openFile(file),
  onDelete: (files) async => await api.delete(files),
  onRename: (file, name) async => await api.rename(file, name),
  onMove: (files, destination) async => await api.move(files, destination),
  onUpload: (destination) async => await pickAndUpload(destination),
)
```

**Includes:** sidebar folder tree, toolbar, path bar, search, view mode toggle (grid/list), sort, context menus, keyboard shortcuts, drag-and-drop, file previews, favorites, and settings persistence.

---

## OiDashboard

A draggable, resizable widget grid — like a home screen for data:

```dart
OiDashboard(
  cards: [
    OiDashboardCard(
      id: 'revenue',
      title: 'Revenue',
      defaultSpan: OiGridSpan(columns: 2, rows: 1),
      child: RevenueChart(),
    ),
    OiDashboardCard(
      id: 'users',
      title: 'Active Users',
      child: UserMetric(),
    ),
  ],
)
```

Card positions and sizes persist automatically.

---

## OiKanban

Kanban board with columns, cards, and drag-and-drop:

```dart
OiKanban(
  columns: [
    OiKanbanColumn(id: 'todo', title: 'To Do', cards: todoCards),
    OiKanbanColumn(id: 'progress', title: 'In Progress', cards: progressCards),
    OiKanbanColumn(id: 'done', title: 'Done', cards: doneCards),
  ],
  onCardMoved: (card, fromColumn, toColumn, index) async {
    await api.moveCard(card.id, toColumn, index);
  },
)
```

**Features:** column reordering, card drag between columns, WIP limits, collapsed columns, settings persistence.

---

## OiChat

Full messaging interface with threads and reactions:

```dart
OiChat(
  messages: messages,
  currentUser: currentUser,
  onSend: (payload) async => await api.sendMessage(payload),
  onReact: (messageId, emoji) async => await api.react(messageId, emoji),
  onThreadOpen: (messageId) => openThread(messageId),
)
```

**Features:** reverse scroll, infinite message loading, message bubbles (bubble/flat/compact), reply quotes, thread summaries, reactions, typing indicators, compose bar with attachments and mentions.

---

## OiComments

Threaded discussion — like GitHub issue comments:

```dart
OiComments(
  comments: comments,
  currentUser: currentUser,
  onPost: (payload) async => await api.postComment(payload),
  onReply: (parentId, payload) async => await api.reply(parentId, payload),
)
```

---

## OiListView

A complete list screen with sort, filter, and pagination:

```dart
OiListView<Project>(
  items: projects,
  itemBuilder: (project) => OiListTile(
    title: Text(project.name),
    subtitle: Text(project.description),
  ),
  sortOptions: [
    OiSortOption(label: 'Name', comparator: (a, b) => a.name.compareTo(b.name)),
    OiSortOption(label: 'Created', comparator: (a, b) => a.createdAt.compareTo(b.createdAt)),
  ],
)
```

---

## Settings persistence

All modules that support persistence auto-save user preferences when you provide a `settingsDriver` to `OiApp`:

| Module | What's persisted |
|---|---|
| `OiFileExplorer` | View mode, sort, sidebar state, favorites, recent paths |
| `OiKanban` | Column order, collapsed columns, WIP limits |
| `OiDashboard` | Card positions and sizes |
| `OiListView` | Layout mode, sort, filters, page size |
| `OiTable` | Column order, widths, visibility, sort, filters, page size |

No extra configuration needed — just wrap your app with a settings driver and it works. See [Settings](../settings/index.md) for details.
