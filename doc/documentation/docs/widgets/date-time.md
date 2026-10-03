# Date & Time Pickers

These widgets cover every way a user picks a date, a time, or a range. Some are
inline form fields you drop into a layout. Some are calendars you open in a
dialog. Pick the field-style widgets for forms, and the picker widgets when you
want the calendar itself or a dialog on tap.

| Widget | What it does |
| --- | --- |
| `OiDateInput` | Inline date field with a built-in calendar, no dialog. |
| `OiDateTimeInput` | One field for both a date and a time. |
| `OiTimeInput` | Inline time field for hours, minutes, and seconds. |
| `OiDatePicker` | The calendar itself. Use inline or open with `.show()`. |
| `OiDatePickerField` | Read-only field that opens an `OiDatePicker` dialog on tap. |
| `OiDateRangeInput` | Inline field for a start-to-end date range with presets. |
| `OiDateRangePicker` | Dual-calendar range selector with quick-select presets. |
| `OiDateRangePickerField` | Read-only field that opens a range dialog on tap. |
| `OiTimePicker` | Time selection wheel. Use inline or open with `.show()`. |
| `OiTimePickerField` | Read-only field that opens an `OiTimePicker` dialog on tap. |
| `OiMonthPicker` | Picks a single month and year. |
| `OiCalendarWeekPicker` | Picks an ISO calendar week. |
| `OiWeekStrip` | Compact horizontal 7-day selector for daily planners. |

Time values use `OiTimeOfDay`, a small class with `hour`, `minute`, and an
optional `second`. It has an `OiTimeOfDay.now()` factory. The library uses it
instead of Flutter's `TimeOfDay` so it stays free of Material.

## OiDateInput

An inline date field. It shows the formatted date and opens a small calendar in
place when tapped, so there is no dialog. Reach for it in forms where you want
the calendar attached to the field.

```dart
DateTime? _date;

OiDateInput(
  label: 'Birth date',
  value: _date,
  onChanged: (date) => setState(() => _date = date),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `DateTime?` | `null` | The selected date. |
| `onChanged` | `ValueChanged<DateTime?>?` | `null` | Fires with the picked date. |
| `firstDate` | `DateTime?` | `null` | Earliest selectable date. |
| `lastDate` | `DateTime?` | `null` | Latest selectable date. |
| `label` | `String?` | `null` | Label above the field. |
| `hint` | `String?` | `null` | Hint below the field. |
| `error` | `String?` | `null` | Error message shown under the field. |
| `dateFormat` | `String?` | `null` | Display format pattern, for example `'MMM d, yyyy'`. |
| `enabled` | `bool` | `true` | Set `false` to disable. |

!!! note
    `OiDateInput` uses `firstDate` and `lastDate` to bound the range. The
    dialog-style `OiDatePickerField` uses `minDate` and `maxDate` for the same
    idea. Watch the names when you switch between them.

## OiDateTimeInput

One field that captures both a date and a time. Use it for events, deadlines,
and anything that needs a day plus a clock value in a single control.

```dart
DateTime? _startsAt;

OiDateTimeInput(
  label: 'Starts at',
  value: _startsAt,
  onChanged: (value) => setState(() => _startsAt = value),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Label above the field. |
| `value` | `DateTime?` | `null` | The selected date and time. |
| `onChanged` | `ValueChanged<DateTime?>?` | `null` | Fires with the merged date and time. |
| `min` | `DateTime?` | `null` | Earliest selectable value. |
| `max` | `DateTime?` | `null` | Latest selectable value. |
| `hint` | `String?` | `null` | Hint below the field. |
| `error` | `String?` | `null` | Error message shown under the field. |
| `required` | `bool` | `false` | Shows an asterisk next to the label. |
| `readOnly` | `bool` | `false` | Show the value but block editing. |
| `enabled` | `bool` | `true` | Set `false` to disable. |

!!! tip
    Use `OiDateTimeInput` only when you truly need both parts. For a date alone
    use `OiDateInput`, and for a time alone use `OiTimeInput`.

## OiTimeInput

An inline time field. It edits an `OiTimeOfDay` and supports 24-hour or 12-hour
display.

```dart
OiTimeOfDay? _time;

OiTimeInput(
  label: 'Reminder',
  value: _time,
  onChanged: (time) => setState(() => _time = time),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `OiTimeOfDay?` | `null` | The selected time. |
| `onChanged` | `ValueChanged<OiTimeOfDay?>?` | `null` | Fires with the picked time. |
| `label` | `String?` | `null` | Label above the field. |
| `hint` | `String?` | `null` | Hint below the field. |
| `error` | `String?` | `null` | Error message shown under the field. |
| `use24Hour` | `bool` | `true` | `true` for `14:30`, `false` for `2:30 PM`. |
| `enabled` | `bool` | `true` | Set `false` to disable. |

## OiDatePicker

The calendar widget itself, with month and year navigation. Place it inline when
you want a permanent calendar. Call the static `OiDatePicker.show()` to open it
in a dialog and await the result.

```dart
// Inline calendar.
OiDatePicker(
  value: _date,
  onChanged: (date) => setState(() => _date = date),
)
```

```dart
// As a dialog. Returns null if the user dismisses it.
final picked = await OiDatePicker.show(
  context,
  initialDate: DateTime.now(),
  semanticLabel: 'Pick a delivery date',
);
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `DateTime?` | `null` | The selected date. |
| `onChanged` | `ValueChanged<DateTime?>?` | `null` | Fires when a day is tapped. |
| `firstDate` | `DateTime?` | `null` | Earliest selectable date. |
| `lastDate` | `DateTime?` | `null` | Latest selectable date. |
| `rangeMode` | `bool` | `false` | Select a start and an end instead of one day. |
| `rangeStart` / `rangeEnd` | `DateTime?` | `null` | Current range when `rangeMode` is on. |
| `onRangeChanged` | `void Function(DateTime?, DateTime?)?` | `null` | Fires with the range. |
| `displayMonth` | `DateTime?` | `null` | The month the calendar shows first. |
| `disabledDates` | `Set<DateTime>?` | `null` | Days the user cannot pick. |
| `disabledDaysOfWeek` | `Set<int>?` | `null` | Weekdays to disable, for example weekends. |
| `firstDayOfWeek` | `int?` | `null` | Which weekday starts the row. |

`OiDatePicker.show()` takes `context`, then `initialDate`, `firstDate`,
`lastDate`, and `semanticLabel`. It returns `Future<DateTime?>`.

## OiDatePickerField

A read-only form field that shows a formatted date and a calendar icon. Tapping
it opens an `OiDatePicker` dialog. Use it in forms and filter bars where you want
a normal-looking field, not an always-open calendar.

```dart
OiDatePickerField(
  label: 'Due date',
  value: _due,
  clearable: true,
  onChanged: (date) => setState(() => _due = date),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `DateTime?` | `null` | The selected date. |
| `onChanged` | `ValueChanged<DateTime?>?` | `null` | Fires on selection or clear. |
| `minDate` | `DateTime?` | `null` | Earliest selectable date. |
| `maxDate` | `DateTime?` | `null` | Latest selectable date. |
| `selectableDayPredicate` | `bool Function(DateTime)?` | `null` | Return `false` to disable a day. |
| `label` | `String?` | `null` | Label above the field. |
| `hint` | `String?` | `null` | Hint below the field. |
| `placeholder` | `String?` | `'Select date'` | Text shown when empty. |
| `error` | `String?` | `null` | Manual error. Takes precedence over the validator. |
| `dateFormat` | `String?` | `'MMM d, yyyy'` | Display format pattern. |
| `clearable` | `bool` | `false` | Show a clear icon when a value is set. |
| `enabled` | `bool` | `true` | Set `false` to disable. |
| `readOnly` | `bool` | `false` | Show the value but block the dialog. |
| `validator` | `String? Function(DateTime?)?` | `null` | Form validation. |
| `onSaved` | `void Function(DateTime?)?` | `null` | Called by `Form.save()`. |
| `autovalidateMode` | `AutovalidateMode?` | `null` | When to run the validator. |
| `semanticLabel` | `String?` | `null` | Screen-reader text. |

**Theme:** `context.components.datePickerField` → `OiDatePickerFieldThemeData`

## OiDateRangeInput

An inline field for a start-to-end date range. It shows preset chips (Today,
Last 7 days, and so on) plus a calendar. Use it in filters where the range
should sit directly in the layout.

```dart
DateTime? _start;
DateTime? _end;

OiDateRangeInput(
  label: 'Date range',
  startDate: _start,
  endDate: _end,
  onChanged: (start, end) => setState(() {
    _start = start;
    _end = end;
  }),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label. |
| `startDate` | `DateTime?` | `null` | Start of the range. |
| `endDate` | `DateTime?` | `null` | End of the range. |
| `onChanged` | `void Function(DateTime? start, DateTime? end)?` | `null` | Fires on select or clear. |
| `presets` | `List<OiDateRangePreset>?` | defaults | Quick-select chips. |
| `firstDate` | `DateTime?` | `null` | Earliest selectable date. |
| `lastDate` | `DateTime?` | `null` | Latest selectable date. |
| `hint` | `String?` | `null` | Hint below the field. |
| `error` | `String?` | `null` | Error message shown under the field. |
| `enabled` | `bool` | `true` | Set `false` to disable. |
| `required` | `bool` | `false` | Shows an asterisk next to the label. |
| `clearable` | `bool` | `true` | Show a clear control when a range is set. |
| `displayFormat` | `String?` | `null` | Display format pattern. |
| `semanticLabel` | `String?` | `null` | Screen-reader text. |

An `OiDateRangePreset` has a `label`, a `resolve` callback that returns the
`(DateTime, DateTime)` range, and an optional `icon`. Built-in getters include
`OiDateRangePreset.today`, `.last7Days`, `.last30Days`, `.thisWeek`,
`.thisMonth`, `.lastMonth`, `.thisYear`, and more. `OiDateRangePreset.defaults`
returns the common set.

## OiDateRangePicker

A dual-calendar range selector with a preset panel. It shows two side-by-side
calendars on desktop and one on mobile. It has explicit Apply and Cancel
callbacks, so it works well inside a popover or a custom dialog.

```dart
OiDateRangePicker(
  label: 'Report period',
  startDate: _start,
  endDate: _end,
  onApply: (start, end) => setState(() {
    _start = start;
    _end = end;
  }),
  onCancel: () => closePopover(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label. |
| `startDate` | `DateTime?` | `null` | Current start of the range. |
| `endDate` | `DateTime?` | `null` | Current end of the range. |
| `onApply` | `void Function(DateTime, DateTime)?` | `null` | Fires when the user applies. |
| `onCancel` | `VoidCallback?` | `null` | Fires when the user cancels. |
| `presets` | `List<OiDateRangePreset>?` | defaults | Quick-select presets. |
| `firstDate` | `DateTime?` | `null` | Earliest selectable date. |
| `lastDate` | `DateTime?` | `null` | Latest selectable date. |
| `singleCalendar` | `bool` | `false` | Force a single calendar. |
| `showPresets` | `bool` | `true` | Show or hide the presets panel. |
| `showTimePicker` | `bool` | `false` | Add a time picker to each end. |
| `applyLabel` / `cancelLabel` | `String?` | `null` | Override the button text. |
| `disabledDates` | `Set<DateTime>?` | `null` | Days the user cannot pick. |
| `disabledDaysOfWeek` | `Set<int>?` | `null` | Weekdays to disable. |
| `firstDayOfWeek` | `int?` | `null` | Which weekday starts the row. |
| `semanticLabel` | `String?` | `null` | Screen-reader text. |

**Theme:** `context.components.dateRangePicker` → `OiDateRangePickerThemeData`

!!! tip
    Use `OiDateRangePicker` for the calendar surface itself, for example inside
    an `OiPopover`. Use `OiDateRangePickerField` when you want a field that opens
    that surface on tap.

## OiDateRangePickerField

A read-only field that opens a range dialog on tap. The dialog holds preset
chips, a calendar in range mode, and Cancel and Apply buttons. It shows the
selection formatted like `Mar 1 - Mar 23, 2026`.

```dart
OiDateRangePickerField(
  label: 'Period',
  startDate: _start,
  endDate: _end,
  clearable: true,
  onChanged: (start, end) => setState(() {
    _start = start;
    _end = end;
  }),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `startDate` | `DateTime?` | `null` | Start of the range. |
| `endDate` | `DateTime?` | `null` | End of the range. |
| `onChanged` | `void Function(DateTime start, DateTime end)?` | `null` | Fires when a range is applied. |
| `onCleared` | `VoidCallback?` | `null` | Fires when the range is cleared. |
| `minDate` | `DateTime?` | `null` | Earliest selectable date. |
| `maxDate` | `DateTime?` | `null` | Latest selectable date. |
| `label` | `String?` | `null` | Label above the field. |
| `hint` | `String?` | `null` | Hint below the field. |
| `error` | `String?` | `null` | Manual error. |
| `dateFormat` | `String?` | `'MMM d, yyyy'` | Display format pattern. |
| `clearable` | `bool` | `false` | Show a clear icon when a range is set. |
| `enabled` | `bool` | `true` | Set `false` to disable. |
| `required` | `bool` | `false` | Shows an asterisk next to the label. |
| `presets` | `List<OiDateRangePreset>?` | defaults | Preset chips in the dialog. |
| `showPresets` | `bool` | `true` | Whether to show preset chips. |
| `validator` | `String? Function((DateTime, DateTime)?)?` | `null` | Form validation. |
| `onSaved` | `void Function((DateTime, DateTime)?)?` | `null` | Called by `Form.save()`. |
| `autovalidateMode` | `AutovalidateMode?` | `null` | When to run the validator. |
| `semanticLabel` | `String?` | `null` | Screen-reader text. |

## OiTimePicker

A time selection surface for hours, minutes, and seconds. Place it inline, or
call `OiTimePicker.show()` to open it in a dialog and await an `OiTimeOfDay`.

```dart
// Inline.
OiTimePicker(
  value: _time,
  onChanged: (time) => setState(() => _time = time),
)
```

```dart
// As a dialog.
final picked = await OiTimePicker.show(
  context,
  initialTime: OiTimeOfDay.now(),
  use24Hour: true,
  semanticLabel: 'Pick a start time',
);
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `OiTimeOfDay?` | `null` | The selected time. |
| `onChanged` | `ValueChanged<OiTimeOfDay?>?` | `null` | Fires with the picked time. |
| `use24Hour` | `bool` | `true` | `true` for 24-hour, `false` for AM/PM. |

`OiTimePicker.show()` takes `context`, then `initialTime`, `use24Hour`, and
`semanticLabel`. It returns `Future<OiTimeOfDay?>`.

## OiTimePickerField

A read-only field that shows a formatted time and a clock icon, and opens an
`OiTimePicker` dialog on tap. Use it in forms.

```dart
OiTimePickerField(
  label: 'Start time',
  value: _time,
  onChanged: (time) => setState(() => _time = time),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `OiTimeOfDay?` | `null` | The selected time. |
| `onChanged` | `ValueChanged<OiTimeOfDay?>?` | `null` | Fires on selection or clear. |
| `label` | `String?` | `null` | Label above the field. |
| `hint` | `String?` | `null` | Hint below the field. |
| `placeholder` | `String?` | `'Select time'` | Text shown when empty. |
| `error` | `String?` | `null` | Manual error. Takes precedence over the validator. |
| `use24Hour` | `bool` | `true` | `true` for 24-hour, `false` for AM/PM. |
| `clearable` | `bool` | `false` | Show a clear icon when a value is set. |
| `enabled` | `bool` | `true` | Set `false` to disable. |
| `validator` | `String? Function(OiTimeOfDay?)?` | `null` | Form validation. |
| `onSaved` | `void Function(OiTimeOfDay?)?` | `null` | Called by `Form.save()`. |
| `autovalidateMode` | `AutovalidateMode?` | `null` | When to run the validator. |
| `semanticLabel` | `String?` | `null` | Screen-reader text. |

!!! note
    `minTime`, `maxTime`, and `minuteInterval` exist on the constructor but are
    reserved for future use. Do not rely on them to constrain input yet.

## OiMonthPicker

Picks a single month and year. Place it inline, or call `OiMonthPicker.show()`
to open it in a dialog. The value type is `OiMonth`, which holds a `year` and a
`month`.

```dart
final picked = await OiMonthPicker.show(
  context,
  initialValue: const OiMonth(year: 2026, month: 7),
  minYear: 2020,
  maxYear: 2030,
);
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `OiMonth?` | `null` | The selected month. |
| `onChanged` | `ValueChanged<OiMonth?>?` | `null` | Fires with the picked month. |
| `minYear` | `int` | `1900` | Earliest selectable year. |
| `maxYear` | `int` | `2100` | Latest selectable year. |

`OiMonthPicker.show()` takes `context`, then `initialValue`, `minYear`,
`maxYear`, and `semanticLabel`. It returns `Future<OiMonth?>`.

## OiCalendarWeekPicker

Picks an ISO calendar week. The value type is `OiCalendarWeek`, which holds a
`week` number and a `year`. Use it for reports and planners keyed by week.

```dart
final picked = await OiCalendarWeekPicker.show(
  context,
  initialValue: const OiCalendarWeek(week: 27, year: 2026),
);
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `OiCalendarWeek?` | `null` | The selected week. |
| `onChanged` | `ValueChanged<OiCalendarWeek?>?` | `null` | Fires with the picked week. |
| `highlightedWeeks` | `Set<OiCalendarWeek>?` | `null` | Weeks to mark, for example holidays. |
| `weekFormatter` | `String Function(int week, int year)?` | `null` | Custom label for each week. |

`OiCalendarWeekPicker.show()` takes `context`, then `initialValue`,
`highlightedWeeks`, `weekFormatter`, and `semanticLabel`. It returns
`Future<OiCalendarWeek?>`.

## OiWeekStrip

A compact horizontal row of seven day cells. It is the strip you see at the top
of a daily planner. Days with events show a dot, and prev/next arrows move the
week.

```dart
OiWeekStrip(
  label: 'Planner week',
  selectedDate: _day,
  onDateSelected: (date) => setState(() => _day = date),
  eventCounts: {
    DateTime(2026, 7, 2): 3,
    DateTime(2026, 7, 4): 1,
  },
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `selectedDate` | `DateTime` | **required** | The highlighted day. |
| `onDateSelected` | `ValueChanged<DateTime>` | **required** | Fires when a day is tapped. |
| `label` | `String` | **required** | Accessibility label. |
| `eventCounts` | `Map<DateTime, int>?` | `null` | Days with events show a dot. |
| `eventDotColor` | `Color?` | `null` | Override the dot color. Use `context.colors`. |
| `firstDayOfWeek` | `int` | `DateTime.monday` | Which weekday starts the row. |
| `firstDate` | `DateTime?` | `null` | Earliest navigable date. |
| `lastDate` | `DateTime?` | `null` | Latest navigable date. |
| `disabledDates` | `Set<DateTime>?` | `null` | Days the user cannot pick. |
| `disabledDaysOfWeek` | `Set<int>?` | `null` | Weekdays to disable. |
| `showNavigation` | `bool` | `true` | Show the prev/next arrows. |
| `showMonth` | `bool` | `true` | Show the month name. |
| `showYear` | `bool` | `false` | Show the year alongside the month. |
| `todayLabel` | `String?` | `null` | Text for a jump-to-today button. |
| `compact` | `bool` | `false` | Use smaller cells. |
| `semanticLabel` | `String?` | `null` | Screen-reader text. |

**Theme:** `context.components.weekStrip` → `OiWeekStripThemeData`

!!! tip
    Use `OiWeekStrip` for daily planners and schedulers. For a full month grid
    use `OiCalendar`, and for date entry in a form use `OiDateInput`.

## Related

- [Text Inputs](text-inputs.md) for text, number, and select fields.
- [Overlays & Menus](overlays.md) for the dialogs and popovers these pickers open.
- [Scheduling](scheduling.md) for full calendars, Gantt charts, and timelines.
