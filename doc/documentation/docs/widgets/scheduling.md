# Scheduling & Calendars

These widgets place events, tasks, and history on a time axis. Reach for them
when your app deals with dates, appointments, project plans, or activity logs.
Each one reads its colors and spacing from the theme, and each takes a required
`label` for screen readers.

| Widget | What it does |
| --- | --- |
| `OiCalendar` | Day, week, or month event calendar with a built-in view switcher. |
| `OiGantt` | Horizontal task bars on a timeline, with dependencies and zoom. |
| `OiScheduler` | A day or week time grid for appointments and bookings. |
| `OiTimeline` | A vertical list of events in chronological order. |

## OiCalendar

An event calendar with day, week, and month views. It draws its own navigation
header and a view switcher, so a user can move between periods and modes without
extra widgets from you. Reach for it when you show scheduled events on a grid.

```dart
OiCalendar(
  label: 'Team calendar',
  events: [
    OiCalendarEvent(
      key: 'standup',
      title: 'Standup',
      start: DateTime(2026, 7, 2, 9),
      end: DateTime(2026, 7, 2, 10),
    ),
  ],
  onEventTap: (event) => openEvent(event),
)
```

Give it a fixed height. `OiCalendar` fills its parent, so wrap it in a
`SizedBox`, an `Expanded`, or a card with a set height.

### Events

Every event is an `OiCalendarEvent`. The `key` must be unique. Set `allDay` for
banner-style entries that show in the all-day row.

```dart
OiCalendarEvent(
  key: 'launch',
  title: 'Launch day',
  start: DateTime(2026, 7, 4),
  end: DateTime(2026, 7, 4),
  allDay: true,
  color: context.colors.success.base,
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `events` | `List<OiCalendarEvent>` | **required** | The events to display. |
| `label` | `String` | **required** | Accessibility label. |
| `mode` | `OiCalendarMode` | `month` | `day`, `week`, or `month`. |
| `initialDate` | `DateTime?` | `null` | The date to focus. Defaults to today. |
| `onEventTap` | `ValueChanged<OiCalendarEvent>?` | `null` | Fires when an event is tapped. |
| `onDateTap` | `ValueChanged<DateTime>?` | `null` | Fires when a date cell is tapped. |
| `onEventMove` | `void Function(OiCalendarEvent, DateTime start, DateTime end)?` | `null` | Fires when an event moves to a new range. |
| `onEventResize` | `void Function(OiCalendarEvent, DateTime newEnd)?` | `null` | Fires when an event is resized. |
| `showWeekNumbers` | `bool` | `false` | Show ISO week numbers in the month grid. |
| `showAllDayRow` | `bool` | `true` | Show the all-day event row. |
| `firstDayOfWeek` | `int` | `DateTime.monday` | First weekday, `1` (Monday) to `7` (Sunday). |
| `settingsDriver` | `OiSettingsDriver?` | `null` | Persists the chosen view mode. `null` means no persistence. |
| `settingsKey` | `String?` | `null` | Scopes saved settings within the namespace. |

!!! tip "When to reach for something else"
    Use `OiGantt` for project plans with dependencies. Use `OiScheduler` when
    you only need a day or week time grid for appointments. Use `OiTimeline` for
    a chronological log rather than a grid.

## OiGantt

A Gantt chart. It shows each task as a horizontal bar on a shared timeline, with
a label column on the left. It can draw dependency arrows, shade weekends, mark
today, and group tasks. Reach for it to plan projects and see task overlap.

```dart
OiGantt(
  label: 'Release plan',
  tasks: [
    OiGanttTask(
      key: 'design',
      label: 'Design',
      start: DateTime(2026, 7, 1),
      end: DateTime(2026, 7, 10),
      progress: 0.6,
    ),
    OiGanttTask(
      key: 'build',
      label: 'Build',
      start: DateTime(2026, 7, 8),
      end: DateTime(2026, 7, 25),
      dependsOn: ['design'],
    ),
  ],
  onTaskTap: (task) => openTask(task),
)
```

### Tasks

Each bar is an `OiGanttTask`. `progress` runs from `0.0` to `1.0` and fills the
bar. `dependsOn` lists the keys of tasks that must finish first, and draws an
arrow between them.

### Zoom and grouping

`zoom` sets the column scale from day down to quarter. Pass `groupBy` to bucket
tasks under headers, and `groupHeader` to render your own header widget.

```dart
OiGantt(
  label: 'Roadmap',
  tasks: tasks,
  zoom: OiGanttZoom.month,
  groupBy: (task) => task.group ?? 'Ungrouped',
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tasks` | `List<OiGanttTask>` | **required** | The tasks to display. |
| `label` | `String` | **required** | Accessibility label. |
| `viewStart` | `DateTime?` | `null` | Start of the visible range. Defaults to the earliest task. |
| `viewEnd` | `DateTime?` | `null` | End of the visible range. Defaults to the latest task. |
| `zoom` | `OiGanttZoom` | `week` | Column scale: `day`, `week`, `month`, or `quarter`. |
| `onTaskTap` | `ValueChanged<OiGanttTask>?` | `null` | Fires when a task bar is tapped. |
| `onTaskMove` | `void Function(OiGanttTask, DateTime start, DateTime end)?` | `null` | Fires when a task moves. |
| `onTaskResize` | `void Function(OiGanttTask, DateTime newEnd)?` | `null` | Fires when a task is resized. |
| `showDependencies` | `bool` | `true` | Draw dependency arrows. |
| `showToday` | `bool` | `true` | Draw a vertical line at today. |
| `showWeekends` | `bool` | `true` | Shade weekend columns. |
| `groupBy` | `Object Function(OiGanttTask)?` | `null` | Extract a group key per task. |
| `groupHeader` | `Widget Function(Object key)?` | `null` | Build a custom group header. |
| `settingsDriver` | `OiSettingsDriver?` | `null` | Persists the horizontal scroll position. |

## OiScheduler

A day or week time grid for appointments. It shows hour rows between `startHour`
and `endHour` and places each slot in its hour. It carries its own header and
day/week switcher. Reach for it for booking screens and daily agendas.

```dart
OiScheduler(
  label: 'Room bookings',
  slots: [
    OiScheduleSlot(
      key: 'call',
      title: 'Client call',
      start: DateTime(2026, 7, 2, 10),
      end: DateTime(2026, 7, 2, 11),
    ),
  ],
  onTimeSlotTap: (time) => createBooking(time),
  onSlotTap: (slot) => openBooking(slot),
)
```

Set `startHour` and `endHour` to the working hours you want. The grid only draws
those rows, so an 8-to-18 day stays compact.

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `slots` | `List<OiScheduleSlot>` | **required** | The appointments to display. |
| `label` | `String` | **required** | Accessibility label. |
| `date` | `DateTime?` | `null` | The date to focus. Defaults to today. |
| `mode` | `OiSchedulerMode` | `day` | `day` or `week`. |
| `startHour` | `int` | `8` | First hour shown in the grid. |
| `endHour` | `int` | `18` | Last hour shown, exclusive. |
| `onSlotTap` | `ValueChanged<OiScheduleSlot>?` | `null` | Fires when a slot is tapped. |
| `onTimeSlotTap` | `ValueChanged<DateTime>?` | `null` | Fires when an empty cell is tapped. |
| `onSlotMove` | `void Function(OiScheduleSlot, DateTime start, DateTime end)?` | `null` | Fires when a slot moves. |

!!! note
    `OiScheduler` and `OiCalendar` overlap. Use `OiScheduler` for a focused
    working-hours grid. Use `OiCalendar` when you also need a month view.

## OiTimeline

A vertical list of events in time order. Each event is a card with a dot on a
connecting line. Reach for it for activity logs, changelogs, and milestone
history, not for a grid.

```dart
OiTimeline(
  label: 'Activity',
  events: [
    OiTimelineEvent(
      timestamp: DateTime(2026, 7, 1, 9, 30),
      title: 'Ticket opened',
      description: 'Reported by a customer.',
    ),
    OiTimelineEvent(
      timestamp: DateTime(2026, 7, 2, 14),
      title: 'Resolved',
      icon: OiIcons.check,
      color: context.colors.success.base,
    ),
  ],
)
```

Events take an optional `description`, a custom `content` widget, an `icon` on
the dot, and a `color`. Set `alternating: true` to zig-zag cards left and right,
and `collapsible: true` to let a user fold each card.

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `events` | `List<OiTimelineEvent>` | **required** | The events, in the order you pass them. |
| `label` | `String` | **required** | Accessibility label. |
| `showTimestamps` | `bool` | `true` | Show a timestamp beside each event. |
| `alternating` | `bool` | `false` | Alternate cards left and right of the line. |
| `collapsible` | `bool` | `false` | Let each card fold and unfold. |
| `onEventTap` | `ValueChanged<OiTimelineEvent>?` | `null` | Fires when an event is tapped. |

!!! note
    `OiTimeline` does not sort for you. Pass `events` already ordered by
    `timestamp`.

## Related

- [Forms & Inputs](forms.md) for `OiDatePicker`, `OiTimePicker`, and date ranges.
- [Data Display](display.md) for tables and lists that pair with a plan.
- [Feedback & Status](feedback.md) for `OiRelativeTime` next to a timeline entry.
