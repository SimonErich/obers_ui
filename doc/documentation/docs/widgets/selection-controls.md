# Selection Controls

Selection controls let people pick values: flip a setting, choose one option from
a few, tick items in a list, or drag a value along a range. ObersUI gives you a
set of controls for each of those jobs. Every one reads its colors, sizing, and
corner radius from the theme, so they match without extra work.

| Widget | What it does |
| --- | --- |
| `OiCheckbox` | A checkbox with checked, unchecked, and indeterminate states. |
| `OiRadio` | A group of radio buttons for picking one option. |
| `OiSwitch` | An on/off toggle for settings. |
| `OiSwitchTile` | A full-width list row with a switch on the right. |
| `OiSlider` | A draggable track for a single value or a range. |
| `OiSegmentedControl` | Two to five connected segments, one selected at a time. |
| `OiSelect` | A dropdown you pick one option from. |
| `OiFormSelect` | `OiSelect` wired into a `Form` for validation. |
| `OiComboBox` | A searchable dropdown for large or async option lists. |

## OiCheckbox

A single checkbox. Reach for it for boolean fields, multi-select lists, and terms
acceptance. The `value` is a `bool?`: `false` is unchecked, `true` is checked, and
`null` shows a dash for the indeterminate state. You own the value and update it in
`onChanged`, which fires with `true` when the new state is checked.

```dart
bool _agree = false;

OiCheckbox(
  value: _agree,
  label: 'I accept the terms',
  onChanged: (checked) => setState(() => _agree = checked),
)
```

Pass `null` to show the indeterminate dash, handy for a "select all" box when only
some children are checked.

```dart
OiCheckbox(
  value: null,
  label: 'Select all',
  onChanged: (checked) => setAll(checked),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `bool?` | **required** | `true` checked, `false` unchecked, `null` indeterminate. |
| `onChanged` | `ValueChanged<bool>?` | `null` | Fires with the next checked state. `null` disables the box. |
| `label` | `String?` | `null` | Optional text shown to the right of the box. |
| `labelStyle` | `TextStyle?` | `null` | Overrides the label text style. |
| `enabled` | `bool` | `true` | Set `false` to disable. |

**Theme:** `context.components.checkbox` → `OiCheckboxThemeData`

!!! tip
    For a checkbox with a title, subtitle, and a tappable full-width row, use
    `OiCheckboxTile` instead of pairing `OiCheckbox` with your own layout.

## OiRadio

A group of radio buttons for choosing one option from a short, visible list. You
pass a list of `OiRadioOption`, the currently selected `value`, and an `onChanged`
that fires with the picked value. Use it for two to five mutually exclusive choices.

```dart
String _plan = 'free';

OiRadio<String>(
  value: _plan,
  onChanged: (value) => setState(() => _plan = value),
  options: const [
    OiRadioOption(value: 'free', label: 'Free'),
    OiRadioOption(value: 'pro', label: 'Pro'),
    OiRadioOption(value: 'team', label: 'Team'),
  ],
)
```

Set `direction` to `Axis.horizontal` to lay the options out in a row.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | `List<OiRadioOption<T>>` | **required** | The choices. Each has `value`, `label`, and `enabled`. |
| `value` | `T?` | `null` | The currently selected value. |
| `onChanged` | `ValueChanged<T>?` | `null` | Fires with the selected value. `null` disables the group. |
| `enabled` | `bool` | `true` | Set `false` to disable every option. |
| `direction` | `Axis` | `Axis.vertical` | Lay out in a column or a row. |

!!! note
    For more than five options, use `OiSelect`. For a plain on/off, use `OiSwitch`.
    For radio rows with subtitles, use `OiRadioTile`.

## OiSwitch

An animated on/off toggle. Reach for it in settings and preferences to enable or
disable a feature. You own the `value` and update it in `onChanged`.

```dart
bool _notifications = true;

OiSwitch(
  value: _notifications,
  label: 'Email notifications',
  onChanged: (on) => setState(() => _notifications = on),
)
```

Three sizes are available through the `size` parameter.

```dart
OiSwitch(value: _v, size: OiSwitchSize.small, onChanged: onChange)   // 28x16
OiSwitch(value: _v, size: OiSwitchSize.medium, onChanged: onChange)  // 40x22, default
OiSwitch(value: _v, size: OiSwitchSize.large, onChanged: onChange)   // 52x28
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `bool` | **required** | Whether the switch is on. |
| `onChanged` | `ValueChanged<bool>?` | `null` | Fires with the next state. `null` disables the switch. |
| `size` | `OiSwitchSize` | `medium` | `small`, `medium`, or `large`. |
| `label` | `String?` | `null` | Optional text shown to the right. |
| `enabled` | `bool` | `true` | Set `false` to disable. |

**Theme:** `context.components.switchTheme` → `OiSwitchThemeData`

!!! tip
    Use `OiSwitch` for a setting that takes effect right away. For a value that is
    saved with the rest of a form, prefer `OiCheckbox`. For a formatting toolbar
    toggle like bold, use `OiToggleButton`.

## OiSwitchTile

A full-width list row with a title, an optional subtitle, and an `OiSwitch` on the
right. Tapping anywhere on the row toggles the switch. This is the row you want on
a settings screen.

```dart
bool _sync = true;

OiSwitchTile(
  title: 'Background sync',
  subtitle: 'Keep data up to date automatically',
  value: _sync,
  onChanged: (on) => setState(() => _sync = on),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `String` | **required** | The primary text. |
| `value` | `bool` | **required** | Whether the switch is on. |
| `onChanged` | `ValueChanged<bool>` | **required** | Fires with the next state. |
| `subtitle` | `String?` | `null` | Secondary text below the title. |
| `leading` | `Widget?` | `null` | Widget at the start of the row, often an icon. |
| `enabled` | `bool` | `true` | `false` dims the row and blocks taps. |
| `dense` | `bool` | `false` | Reduces vertical padding. |
| `contentPadding` | `EdgeInsetsGeometry?` | `null` | Custom padding around the row. |
| `semanticLabel` | `String?` | `null` | Screen-reader text. Falls back to `title`. |

!!! note
    For a bare toggle with no descriptive row, use `OiSwitch`. For a tappable row
    with a checkbox or radio instead of a switch, use `OiCheckboxTile` or
    `OiRadioTile`.

## OiSlider

A draggable track for picking a number in a range. It works in single-thumb mode
and dual-thumb (range) mode. Set `min`, `max`, and the current `value`, and read
changes from `onChanged`.

```dart
double _volume = 40;

OiSlider(
  value: _volume,
  min: 0,
  max: 100,
  label: 'Volume',
  showLabels: true,
  onChanged: (value) => setState(() => _volume = value),
)
```

For a range, pass `secondaryValue` for the upper thumb. In range mode
`onRangeChanged` fires instead of `onChanged`, giving you both ends at once.

```dart
double _start = 20;
double _end = 80;

OiSlider(
  value: _start,
  secondaryValue: _end,
  min: 0,
  max: 100,
  label: 'Price range',
  showLabels: true,
  onRangeChanged: (start, end) => setState(() {
    _start = start;
    _end = end;
  }),
)
```

Set `divisions` to snap the thumb to evenly spaced steps, and `showTicks` to draw
the tick marks.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `double` | **required** | The primary (or lower-range) thumb value. |
| `min` | `double` | **required** | The lowest selectable value. |
| `max` | `double` | **required** | The highest selectable value. |
| `secondaryValue` | `double?` | `null` | Set for a second thumb and range mode. |
| `divisions` | `int?` | `null` | Snap to this many discrete steps. `null` is continuous. |
| `onChanged` | `ValueChanged<double>?` | `null` | Fires in single-thumb mode. |
| `onRangeChanged` | `void Function(double start, double end)?` | `null` | Fires in range mode. |
| `label` | `String?` | `null` | Optional label above the slider. |
| `showLabels` | `bool` | `false` | Show the current value above each thumb. |
| `showTicks` | `bool` | `false` | Draw tick marks at division positions. |
| `enabled` | `bool` | `true` | Set `false` to disable dragging. |

**Theme:** `context.components.slider` → `OiSliderThemeData`

## OiSegmentedControl

Two to five connected segments with exactly one selected at a time. It reads like a
compact toggle for switching between views, such as Day/Week/Month or List/Grid.
You pass a list of `OiSegment`, the `selected` value, and an `onChanged`.

```dart
String _view = 'week';

OiSegmentedControl<String>(
  selected: _view,
  onChanged: (value) => setState(() => _view = value),
  segments: const [
    OiSegment(value: 'day', label: 'Day'),
    OiSegment(value: 'week', label: 'Week'),
    OiSegment(value: 'month', label: 'Month'),
  ],
)
```

Each segment takes an optional `icon`. Set `expand: true` to stretch the control to
the full width with equal-width segments.

Use `showLabels: false` for an icon-only view switch. Segments with icons become
square controls. Each segment exposes one button with its accessible name,
selection and enabled state. `semanticLabel` can override the visible label
without duplicating it for assistive technology. Segments without icons keep
their visible text.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `segments` | `List<OiSegment<T>>` | **required** | Two to five segments. Each has `value`, `label`, `icon`, `enabled`, `semanticLabel`. |
| `selected` | `T` | **required** | The currently selected value. |
| `onChanged` | `ValueChanged<T>` | **required** | Fires with the selected value. |
| `enabled` | `bool` | `true` | Set `false` to disable the whole control. |
| `size` | `OiSegmentedControlSize` | `medium` | `small` (28dp), `medium` (36dp), or `large` (44dp). |
| `expand` | `bool` | `false` | Stretch to full width with equal-width segments. |
| `semanticLabel` | `String?` | `null` | Accessibility label for the group. |

**Theme:** `context.components.segmentedControl` → `OiSegmentedControlThemeData`

!!! note
    For more than five options, use `OiTabs` or `OiSelect`. For non-exclusive
    toggles where several can be on at once, use `OiButtonGroup`.

## OiSelect

A dropdown you pick one option from. Pass a list of `OiSelectOption`, the current
`value`, and an `onChanged`. It shows the selected label (or the `placeholder`) and
opens a list on tap.

```dart
String? _country;

OiSelect<String>(
  label: 'Country',
  placeholder: 'Choose a country',
  value: _country,
  onChanged: (value) => setState(() => _country = value),
  options: const [
    OiSelectOption(value: 'us', label: 'United States'),
    OiSelectOption(value: 'de', label: 'Germany'),
    OiSelectOption(value: 'jp', label: 'Japan'),
  ],
)
```

Set `searchable: true` to add a filter field at the top of the dropdown. On mobile,
`bottomSheetOnCompact: true` opens the list as a bottom sheet.

There is also an `OiSelect.inline` constructor. It renders just the label and a
chevron with no input frame, for use inside toolbars and headers.

```dart
OiSelect<String>.inline(
  value: _sort,
  placeholder: 'Sort',
  onChanged: (value) => setState(() => _sort = value),
  options: const [
    OiSelectOption(value: 'name', label: 'Name'),
    OiSelectOption(value: 'date', label: 'Date'),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | `List<OiSelectOption<T>>` | **required** | The choices. Each has `value`, `label`, `enabled`. |
| `value` | `T?` | `null` | The currently selected value. |
| `onChanged` | `ValueChanged<T?>?` | `null` | Fires with the selected value. |
| `label` | `String?` | `null` | Label above the frame. |
| `hint` | `String?` | `null` | Hint text below the frame. |
| `error` | `String?` | `null` | Error message below the frame. |
| `placeholder` | `String?` | `null` | Text shown when nothing is selected. |
| `enabled` | `bool` | `true` | Set `false` to disable. |
| `searchable` | `bool` | `false` | Show a filter field in the dropdown. |
| `bottomSheetOnCompact` | `bool` | `false` | Open as a bottom sheet on compact breakpoints. |

**Theme:** `context.components.select` → `OiSelectThemeData`

!!! tip
    For a large or async option list, use `OiComboBox`. For a dropdown inside a
    `Form` that needs validation, use `OiFormSelect`.

## OiFormSelect

`OiSelect` wired into a `Form`. Give it a `validator` and it wraps itself in a
`FormField`, so it takes part in `Form.validate`, `Form.save`, and auto-validation.
With no `validator` it renders a plain `OiSelect`. Instead of `OiSelectOption`, you
pass raw values plus a `labelOf` function that turns each value into its label.

```dart
OiFormSelect<String>(
  label: 'Role',
  placeholder: 'Select a role',
  options: const ['admin', 'editor', 'viewer'],
  labelOf: (role) => role[0].toUpperCase() + role.substring(1),
  value: _role,
  onChanged: (value) => setState(() => _role = value),
  validator: (value) => value == null ? 'Pick a role' : null,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | `List<T>` | **required** | The values to choose from. |
| `labelOf` | `String Function(T)` | **required** | Turns a value into its display label. |
| `value` | `T?` | `null` | The currently selected value. |
| `onChanged` | `ValueChanged<T?>?` | `null` | Fires with the selected value. |
| `validator` | `String? Function(T?)?` | `null` | Returns an error string, or `null` when valid. Enables form wrapping. |
| `onSaved` | `void Function(T?)?` | `null` | Called by `Form.save()`. |
| `autovalidateMode` | `AutovalidateMode?` | `null` | Controls when validation runs. |
| `label` | `String?` | `null` | Label above the frame. |
| `hint` | `String?` | `null` | Hint text below the frame. |
| `placeholder` | `String?` | `null` | Text shown when nothing is selected. |
| `error` | `String?` | `null` | Manual error. Takes precedence over the validator error. |
| `enabled` | `bool` | `true` | Set `false` to disable. |
| `searchable` | `bool` | `false` | Show a filter field in the dropdown. |
| `bottomSheetOnCompact` | `bool` | `false` | Open as a bottom sheet on compact breakpoints. |
| `semanticLabel` | `String?` | `null` | Accessibility label. |

!!! note
    For a standalone dropdown with no form validation, use `OiSelect` directly.
    For large or async lists, use `OiComboBox`.

## OiComboBox

A searchable dropdown for large or async option lists, like user or entity pickers.
The user types to filter, and the list shows matches. Unlike `OiSelect`, it takes
raw items plus a `labelOf` function, and `label` is required for accessibility.

```dart
OiComboBox<User>(
  label: 'Assignee',
  placeholder: 'Search people',
  items: users,
  labelOf: (user) => user.name,
  value: _assignee,
  onSelect: (user) => setState(() => _assignee = user),
)
```

Pass a `search` function to load options asynchronously as the user types. Turn on
`multiSelect` to let the user pick several values, and read them from
`onMultiSelect`.

```dart
OiComboBox<User>(
  label: 'Reviewers',
  labelOf: (user) => user.name,
  search: (query) => api.searchUsers(query),
  multiSelect: true,
  selectedValues: _reviewers,
  onMultiSelect: (users) => setState(() => _reviewers = users),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label. |
| `labelOf` | `String Function(T)` | **required** | Turns an item into its display label. |
| `items` | `List<T>` | `[]` | Static items to filter locally. |
| `value` | `T?` | `null` | The selected value in single-select mode. |
| `onSelect` | `ValueChanged<T?>?` | `null` | Fires on select or clear. `null` clears. |
| `search` | `Future<List<T>> Function(String)?` | `null` | Async search. Overrides local filtering of `items`. |
| `onCreate` | `ValueChanged<String>?` | `null` | Fires when the typed text matches no option, to create a new item. |
| `placeholder` | `String?` | `null` | Text shown when nothing is selected. |
| `clearable` | `bool` | `true` | Show a clear control on the selection. |
| `enabled` | `bool` | `true` | Set `false` to disable. |
| `hint` | `String?` | `null` | Hint text below the input. |
| `error` | `String?` | `null` | Error text below the input. Replaces the hint. |
| `multiSelect` | `bool` | `false` | Allow selecting several values. |
| `selectedValues` | `List<T>` | `[]` | Selected values in multi-select mode. |
| `onMultiSelect` | `ValueChanged<List<T>>?` | `null` | Fires with the selected values in multi-select mode. |
| `groupBy` | `String Function(T)?` | `null` | Group options under headers. |
| `recentItems` | `List<T>?` | `null` | Items shown in a recent section. |
| `favoriteItems` | `List<T>?` | `null` | Items shown in a favorites section. |
| `virtualScroll` | `bool` | `false` | Virtualize the list for large option sets. |
| `loadMore` | `Future<List<T>> Function()?` | `null` | Load the next page of results. |
| `moreAvailable` | `bool` | `false` | Whether more items can be loaded. |
| `optionBuilder` | `Widget Function(T, {bool highlighted, bool selected})?` | `null` | Custom rendering for each option. |

!!! tip
    For a small, static list of fewer than 20 options, use `OiSelect`. `OiComboBox`
    earns its keep when options are many, remote, or need type-ahead search.

## Related

- [Text Inputs](text-inputs.md) for text, number, date, and file fields.
- [Buttons & Actions](buttons.md) for `OiToggleButton` and `OiButtonGroup`.
- [Forms](forms.md) for putting these controls inside a validated `OiForm`.
- [Search & Command](search-command.md) for command palettes and full-page search.
