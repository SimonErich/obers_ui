# Inline Editing

Inline editing lets people change a value right where they see it. You show a
plain label, they tap it, and it turns into an input. ObersUI gives you one
generic wrapper plus typed shortcuts for text, numbers, dates, and selects, and
a specialized field for renaming files.

| Widget | What it does |
| --- | --- |
| `OiEditable` | The generic click-to-edit wrapper. You supply the display and edit widgets. |
| `OiEditableText` | Tap a label to edit it as text. |
| `OiEditableNumber` | Tap a number to edit it with a stepper input. |
| `OiEditableDate` | Tap a date to pick a new one. |
| `OiEditableSelect` | Tap a value to choose from a dropdown. |
| `OiRenameField` | A rename input for files and folders, with filename selection and validation. |

## OiEditable

The base wrapper for every inline edit pattern. It holds one value and toggles
between a display widget and an edit widget. Reach for it when the typed
shortcuts below do not fit, for example editing a custom chip or a color swatch.

You build both modes yourself. The display builder gets a `startEdit` callback.
The edit builder gets a `commit` callback to save and a `cancel` callback to
revert.

```dart
OiEditable<String>(
  value: _title,
  onChanged: (next) => setState(() => _title = next),
  displayBuilder: (context, value, startEdit) => OiTappable(
    onTap: startEdit,
    semanticLabel: 'Edit title',
    child: OiLabel.body(value),
  ),
  editBuilder: (context, value, commit, cancel) => OiTextInput(
    autofocus: true,
    controller: TextEditingController(text: value),
    onSubmitted: commit,
    onTapOutside: () => cancel(),
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `T` | **required** | The current value, shown in display mode and passed to the edit builder. |
| `displayBuilder` | `Widget Function(BuildContext, T value, VoidCallback startEdit)` | **required** | Builds the read-only view. Call `startEdit` to enter edit mode. |
| `editBuilder` | `Widget Function(BuildContext, T value, void Function(T) commit, VoidCallback cancel)` | **required** | Builds the editor. Call `commit` to save, `cancel` to revert. |
| `onChanged` | `ValueChanged<T>?` | `null` | Fires when the user commits a new value. |
| `enabled` | `bool` | `true` | Set `false` to lock the value in display mode. |
| `editOnTap` | `bool` | `true` | When `true`, tapping the display widget enters edit mode automatically. |

!!! note
    Committing does not check whether the value changed. `onChanged` fires on
    every commit, so guard against no-op saves in your handler if that matters.

## OiEditableText

Tap a label to edit it inline as text. In display mode it shows an `OiLabel`.
Tapping switches to an auto-focused `OiTextInput`. Enter or losing focus commits,
Escape cancels. This is the one you use most, for table cells, list rows, and
card fields.

```dart
OiEditableText(
  value: _name,
  onChanged: (next) => setState(() => _name = next),
)
```

Pass a `variant` to match the surrounding type, or a `style` to override it.

```dart
OiEditableText(
  value: _title,
  variant: OiLabelVariant.heading,
  onChanged: (next) => setState(() => _title = next),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `String` | **required** | The current text. |
| `onChanged` | `ValueChanged<String>?` | `null` | Fires when the edit is committed. |
| `enabled` | `bool` | `true` | Set `false` to disable editing. |
| `variant` | `OiLabelVariant` | `body` | The type variant used in display mode. |
| `style` | `TextStyle?` | `null` | Optional style override on top of the theme. |

## OiEditableNumber

Tap a number to edit it with a stepper input. Display mode shows the number as
text, formatted without trailing zeros. Editing uses `OiNumberInput`, so you get
the up and down steppers and min/max clamping for free. Committing on blur or
Enter fires `onChanged`.

```dart
OiEditableNumber(
  value: _quantity,
  min: 0,
  max: 99,
  onChanged: (next) => setState(() => _quantity = next),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `double?` | `null` | The current number. `null` shows an em-dash placeholder. |
| `onChanged` | `ValueChanged<double?>?` | `null` | Fires when the value changes. |
| `enabled` | `bool` | `true` | Set `false` to disable editing. |
| `min` | `double?` | `null` | Minimum allowed value. |
| `max` | `double?` | `null` | Maximum allowed value. |
| `step` | `double` | `1` | Increment for the stepper buttons. |

## OiEditableDate

Tap a date to pick a new one. Display mode shows the date as formatted text.
Tapping opens an `OiDateInput` picker, and choosing a date commits right away.

```dart
OiEditableDate(
  value: _dueDate,
  dateFormat: 'yyyy-MM-dd',
  onChanged: (next) => setState(() => _dueDate = next),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `DateTime?` | `null` | The current date. `null` shows an em-dash placeholder. |
| `onChanged` | `ValueChanged<DateTime?>?` | `null` | Fires when a date is picked. |
| `enabled` | `bool` | `true` | Set `false` to disable editing. |
| `dateFormat` | `String?` | `'yyyy-MM-dd'` | Format for the display text. Supports `yyyy`, `MM`, and `dd`. |

## OiEditableSelect

Tap a value to choose from a dropdown. Display mode shows the selected option's
label. Tapping opens an `OiSelect`, and picking an option commits. It is generic
over the option value type, so your `onChanged` gives you back a typed value.

```dart
OiEditableSelect<String>(
  value: _status,
  options: const [
    OiSelectOption(value: 'todo', label: 'To do'),
    OiSelectOption(value: 'doing', label: 'In progress'),
    OiSelectOption(value: 'done', label: 'Done'),
  ],
  onChanged: (next) => setState(() => _status = next),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | `List<OiSelectOption<T>>` | **required** | The dropdown choices. Each has a `value` and a `label`. |
| `value` | `T?` | `null` | The selected value. `null` shows an em-dash placeholder. |
| `onChanged` | `ValueChanged<T?>?` | `null` | Fires when an option is picked. |
| `enabled` | `bool` | `true` | Set `false` to disable editing. |

## OiRenameField

A rename input built for files and folders. It focuses on mount and selects the
name part, so for `report.pdf` it selects `report` and leaves the extension
alone. It blocks illegal path characters and empty names, and reports the error
below the field. Enter confirms, Escape cancels. Unlike the widgets above, this
is always in edit mode. You show it when a rename starts and remove it when it
ends.

```dart
OiRenameField(
  currentName: 'report.pdf',
  onRename: (name) => rename(name),
  onCancel: () => stopRenaming(),
)
```

Set `folder: true` to select the whole name, and `showButtons: true` to add
confirm and cancel icons next to the field.

```dart
OiRenameField(
  currentName: 'Projects',
  folder: true,
  showButtons: true,
  onRename: (name) => rename(name),
  onCancel: () => stopRenaming(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `currentName` | `String` | **required** | The name to edit. |
| `onRename` | `ValueChanged<String>` | **required** | Fires with the new name when the user confirms. |
| `onCancel` | `VoidCallback` | **required** | Fires when the user cancels or presses Escape. |
| `folder` | `bool` | `false` | Select the whole name instead of just the part before the extension. |
| `validate` | `String? Function(String)?` | `null` | Extra validation. Return an error string, or `null` to accept. |
| `showButtons` | `bool` | `false` | Show confirm and cancel icon buttons. |
| `semanticsLabel` | `String?` | `null` | Screen-reader label. Defaults to `'Rename file'`. |

!!! note
    `OiRenameField` already rejects `/ \ : * ? " < > |` and empty names. Use
    `validate` only for extra rules, like blocking a name that already exists.

## Related

- [Inputs & Forms](text-inputs.md) for the `OiTextInput`, `OiNumberInput`, `OiDateInput`, and `OiSelect` these fields wrap.
- [Tables](data-tables.md) for inline editing inside table cells.
- [File Explorer](../modules/files.md) for where `OiRenameField` fits in a file tree.
