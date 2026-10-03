# Text & Number Inputs

These are the fields people type into. ObersUI gives you one text field with a
handful of named forms (password, multiline, OTP), a number field with a stepper,
and a few specialized inputs for tags, repeatable rows, and colors. Every field
draws its border, label, hint, and error styling from the theme, so they line up
without extra work.

| Widget | What it does |
| --- | --- |
| `OiTextInput` | The everyday text field. Named forms for search, password, multiline, and OTP. |
| `OiNumberInput` | A numeric field with minus and plus stepper buttons. |
| `OiTagInput` | Enter many string tags as removable chips, with optional suggestions. |
| `OiArrayInput` | A repeatable group of rows you can add, remove, and reorder. |
| `OiColorInput` | A single color picker with a swatch, preset grid, and hex entry. |
| `OiColorPalettePicker` | A row of color slots plus preset palettes, for design-system colors. |

## OiTextInput

The field you will use most for any text entry. You own the value through a
`controller` or the `onChanged` callback. Pass a `label` to name the field and a
`placeholder` for the empty state.

When the design omits the visible label, provide `semanticLabel` for assistive
technology. It stays the same while typing; the placeholder is exposed as a
hint and does not become part of that name. Search, password and multiline
constructors accept the same option.

```dart
OiTextInput(
  label: 'Email',
  placeholder: 'you@example.com',
  keyboardType: TextInputType.emailAddress,
  onChanged: (value) => setState(() => _email = value),
)
```

### Named forms

Four named constructors set up common cases for you. Reach for the default
constructor for everything else.

```dart
// Search box with a leading search icon and a "Search…" placeholder.
OiTextInput.search(
  onChanged: (query) => runSearch(query),
)

// Password field. Text is obscured and a trailing eye icon toggles visibility.
OiTextInput.password(
  label: 'Password',
  onChanged: (value) => _password = value,
)

// Multiline text area. Starts at minLines high and grows to maxLines.
OiTextInput.multiline(
  label: 'Notes',
  minLines: 3,
  maxLines: 8,
  onChanged: (value) => _notes = value,
)

// One-time code. Renders as separate digit boxes and auto-advances focus.
OiTextInput.otp(
  length: 6,
  onCompleted: (code) => verify(code),
)
```

### Validation and counter

Pass a `validator` to join an ancestor `Form`. Set `maxLength` with
`showCounter: true` to show a character count.

```dart
OiTextInput(
  label: 'Bio',
  maxLength: 160,
  showCounter: true,
  validator: (value) =>
      (value == null || value.isEmpty) ? 'Required' : null,
  onChanged: (value) => _bio = value,
)
```

### Attributes

Shared by the default constructor and, where relevant, the named forms:

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `controller` | `TextEditingController?` | `null` | External controller. One is created for you when omitted. |
| `label` | `String?` | `null` | Text rendered above the field. |
| `placeholder` | `String?` | `null` | Text shown inside the empty field. |
| `hint` | `String?` | `null` | Helper text below the field. |
| `error` | `String?` | `null` | Error message. Shows the error border and replaces `hint`. |
| `leading` / `trailing` | `Widget?` | `null` | Widgets pinned to the start and end of the row. |
| `maxLines` | `int?` | `1` | Set higher for a growing field. |
| `minLines` | `int?` | `null` | Minimum visible lines. |
| `maxLength` | `int?` | `null` | Maximum characters. |
| `showCounter` | `bool` | `false` | Show a "3/50" counter. Needs `maxLength`. |
| `keyboardType` | `TextInputType?` | `null` | Soft-keyboard type hint. |
| `textInputAction` | `TextInputAction?` | `null` | The keyboard action button. |
| `onChanged` | `ValueChanged<String>?` | `null` | Fires on every keystroke. |
| `onSubmitted` | `ValueChanged<String>?` | `null` | Fires when the user submits. |
| `enabled` | `bool` | `true` | Set `false` to disable. |
| `readOnly` | `bool` | `false` | Show the value but block editing. |
| `obscureText` | `bool` | `false` | Hide the text. The `password` form sets this for you. |
| `validator` | `String? Function(String?)?` | `null` | Form validation. Return `null` when valid. |
| `autovalidateMode` | `AutovalidateMode?` | `null` | When validation runs automatically. |
| `onSaved` | `void Function(String?)?` | `null` | Called by `Form.save()`. |
| `inputFormatters` | `List<TextInputFormatter>?` | `null` | Per-keystroke formatters. |

The `otp` constructor takes its own set: `length` (**required**), `onCompleted`,
`onChanged`, and `obscure` (default `false`).

**Theme:** `context.components.textInput` → `OiTextInputThemeData`

!!! tip "When to reach for something else"
    Use `OiNumberInput` for numbers, `OiDateInput` for dates, and `OiSelect` for
    a fixed list of choices. `OiTextInput` is for free text.

## OiNumberInput

A numeric field with minus and plus buttons on each side. It clamps the value to
`min` and `max`, steps by `step`, and formats to `decimalPlaces`. You own the
value through `onChanged`.

```dart
OiNumberInput(
  label: 'Quantity',
  value: _qty,
  min: 1,
  max: 99,
  step: 1,
  onChanged: (value) => setState(() => _qty = value ?? 0),
)
```

Set `decimalPlaces` for prices or percentages.

```dart
OiNumberInput(
  label: 'Price',
  value: _price,
  min: 0,
  step: 0.5,
  decimalPlaces: 2,
  onChanged: (value) => setState(() => _price = value),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `double?` | `null` | The current value. `null` shows an empty field. |
| `onChanged` | `ValueChanged<double?>?` | `null` | Fires with the new value, `null` when cleared. |
| `min` | `double?` | `null` | Lowest allowed value. |
| `max` | `double?` | `null` | Highest allowed value. |
| `step` | `double` | `1` | Increment for the stepper buttons. |
| `decimalPlaces` | `int?` | `null` | Fixed decimal count. `null` trims trailing zeros. |
| `label` | `String?` | `null` | Text above the field. |
| `hint` | `String?` | `null` | Helper text below the field. |
| `error` | `String?` | `null` | Error message and border. |
| `enabled` | `bool` | `true` | Set `false` to disable. |
| `minWidth` | `double` | `48` | Minimum field width in logical pixels. |

## OiTagInput

Lets people build a list of string tags. Existing tags show as removable chips.
A field at the end takes new tags, confirmed with Enter or a comma. You hold the
list and update it in `onChanged`.

```dart
List<String> _skills = ['Dart', 'Flutter'];

OiTagInput(
  label: 'Skills',
  tags: _skills,
  placeholder: 'Add a skill…',
  onChanged: (tags) => setState(() => _skills = tags),
)
```

Pass `suggestions` (or `asyncSuggestions`) to show a dropdown of matches as the
user types. Set `allowCustomTags: false` to accept only items from that list.

```dart
OiTagInput(
  label: 'Framework',
  tags: _frameworks,
  suggestions: ['Flutter', 'React', 'Vue', 'Svelte'],
  allowCustomTags: false,
  onChanged: (tags) => setState(() => _frameworks = tags),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `tags` | `List<String>` | **required** | The current tags. |
| `onChanged` | `ValueChanged<List<String>>?` | `null` | Fires with the updated list. |
| `label` | `String?` | `null` | Text above the frame. |
| `hint` | `String?` | `null` | Helper text below the frame. |
| `error` | `String?` | `null` | Error message and border. |
| `placeholder` | `String?` | `null` | Text in the entry field. |
| `enabled` | `bool` | `true` | Set `false` to disable. |
| `maxTags` | `int?` | `null` | Cap on the number of tags. |
| `suggestions` | `List<String>?` | `null` | Static list to filter as the user types. |
| `asyncSuggestions` | `Future<List<String>> Function(String)?` | `null` | Fetches suggestions for a query. |
| `suggestionDebounce` | `Duration` | `300ms` | Delay before firing `asyncSuggestions`. |
| `allowCustomTags` | `bool` | `true` | Set `false` to accept only suggested items. |

## OiArrayInput

A repeatable group of rows. Each row is your own set of fields, built by
`itemBuilder`. Users add rows with the Add button, remove them per row, and drag
to reorder. It is generic over `T`, so a row can hold any value you like.

```dart
OiArrayInput<String>(
  label: 'Phone numbers',
  items: _phones,
  createEmpty: () => '',
  addLabel: 'Add phone',
  onChanged: (items) => setState(() => _phones = items),
  itemBuilder: (context, index, item, onItemChanged) => OiTextInput(
    label: 'Phone ${index + 1}',
    controller: TextEditingController(text: item),
    keyboardType: TextInputType.phone,
    onChanged: onItemChanged,
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Group label and accessibility name. |
| `items` | `List<T>` | **required** | The current rows. |
| `itemBuilder` | `Widget Function(BuildContext, int index, T item, ValueChanged<T> onItemChanged)` | **required** | Builds one row. Call `onItemChanged` to update it. |
| `createEmpty` | `T Function()` | **required** | Returns a blank item for a new row. |
| `onChanged` | `ValueChanged<List<T>>?` | `null` | Fires after any add, remove, reorder, or edit. |
| `reorderable` | `bool` | `true` | Allow drag-to-reorder. |
| `addable` | `bool` | `true` | Show the Add button. |
| `removable` | `bool` | `true` | Show per-row remove buttons. |
| `minItems` | `int?` | `null` | Hide remove buttons at this count. |
| `maxItems` | `int?` | `null` | Hide the Add button at this count. |
| `addLabel` | `String` | `'Add'` | Text on the Add button. |
| `error` | `String?` | `null` | Error message below the list. |

!!! note
    Add, remove, and reorder only work when `onChanged` is set. Without it the
    list is read-only.

## OiColorInput

A single-color picker. It shows a swatch and the hex value, and opens a popover
with a grid of 16 preset colors plus a hex field. You own the color through
`onChanged`.

```dart
OiColorInput(
  label: 'Accent color',
  value: _accent,
  onChanged: (color) => setState(() => _accent = color),
)
```

Turn on `showOpacity` to add an alpha slider in the popover.

```dart
OiColorInput(
  label: 'Background',
  value: _background,
  showOpacity: true,
  onChanged: (color) => setState(() => _background = color),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `Color?` | `null` | The current color. |
| `onChanged` | `ValueChanged<Color?>?` | `null` | Fires with the picked color. |
| `label` | `String?` | `null` | Text above the field. |
| `hint` | `String?` | `null` | Helper text below the field. |
| `error` | `String?` | `null` | Error message and border. |
| `enabled` | `bool` | `true` | Set `false` to disable. |
| `showHex` | `bool` | `true` | Show the hex entry inside the picker. |
| `showOpacity` | `bool` | `false` | Show an opacity slider inside the picker. |

## OiColorPalettePicker

Picks several colors at once. It shows a row of color slots, each a tappable
circle, plus optional preset palettes below. Unset slots show a dashed circle.
Reach for this when you edit a set of related colors, like a theme or brand kit.

Tapping a slot fires `onSlotChanged`. You decide what happens next, usually
opening a color picker and writing the new value back into `slots`.

```dart
OiColorPalettePicker(
  label: 'Brand colors',
  slots: [
    OiColorSlot(id: 'primary', label: 'Primary', value: _primary),
    OiColorSlot(id: 'accent', label: 'Accent'),
  ],
  onSlotChanged: (slotId, color) => editSlot(slotId, color),
)
```

Pass `presets` to offer ready-made palettes. Tapping a card fires
`onPresetSelected` with the whole palette.

```dart
OiColorPalettePicker(
  label: 'Theme',
  slots: _slots,
  onSlotChanged: (slotId, color) => editSlot(slotId, color),
  presets: [
    OiColorPalette(
      id: 'ocean',
      name: 'Ocean',
      colors: {'primary': _oceanPrimary, 'accent': _oceanAccent},
    ),
  ],
  onPresetSelected: (palette) => applyPalette(palette),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `slots` | `List<OiColorSlot>` | **required** | The color slots. Each has `id`, `label`, and an optional `value`. |
| `onSlotChanged` | `void Function(String slotId, Color color)` | **required** | Fires when a slot is tapped. |
| `label` | `String` | **required** | Accessibility label for the whole picker. |
| `compact` | `bool` | `true` | When `true`, hide the label under each circle. |
| `presets` | `List<OiColorPalette>?` | `null` | Preset palettes to show as cards. |
| `onPresetSelected` | `void Function(OiColorPalette)?` | `null` | Fires when a preset card is tapped. |
| `showPresets` | `bool` | `true` | Show the presets section. |
| `lockSlotIds` | `Set<String>` | `{}` | Slot IDs that are read-only and dimmed. |
| `onRandomize` | `VoidCallback?` | `null` | When set, shows a shuffle button next to the slots. |

Companion models:

- `OiColorSlot` has `id` (**required**), `label` (**required**), and `value` (`Color?`).
- `OiColorPalette` has `id` (**required**), `name` (**required**), `colors`
  (`Map<String, Color>`, **required**), and `category` (default `''`). The
  `colors` keys match slot IDs.

!!! note
    `OiColorPalettePicker` does not pick a color itself. It reports which slot was
    tapped. Use `OiColorInput` or your own picker to get the new color, then
    update `slots`.

## Related

- [Forms](forms.md) for validation, layout, and submission.
- [Scheduling](scheduling.md) for date, time, and range inputs.
- [Inline Edit](inline-edit.md) for editing values in place inside tables and lists.
