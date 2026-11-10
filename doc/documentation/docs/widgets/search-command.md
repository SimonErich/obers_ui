# Search & Command

These widgets help people find things and run actions fast. You get a Spotlight-style
search overlay, a Cmd+K command palette, a bar of filter chips, and a keyboard
shortcut manager with a built-in help dialog.

| Widget | What it does |
| --- | --- |
| `OiAutocomplete` | An asynchronous suggestion input that clears after selecting a result. |
| `OiSearch` | A global search overlay that queries several sources and groups the results. |
| `OiCommandBar` | A Cmd+K command palette with fuzzy search and nested commands. |
| `OiFilterBar` | A row of filter chips that open popovers to refine a data list. |
| `OiShortcuts` | Registers keyboard shortcuts and shows a help dialog on `?`. |

## OiAutocomplete

Use `OiAutocomplete<T>` when an item is added or opened immediately after a pick.
Provide `label`, `placeholder`, `emptyLabel`, `search`, `labelOf` and `onSelect`.
Blank queries skip the search. An older request cannot replace a newer result.
Arrow keys choose a suggestion; the keyboard search action submits the pick and
clears the field. Empty results display the supplied localized message.

```dart
OiAutocomplete<Product>(
  label: 'Product search',
  placeholder: 'Find a product',
  emptyLabel: 'No products found',
  search: repository.search,
  labelOf: (product) => product.name,
  onSelect: addProduct,
)
```

## OiSearch

A search overlay in the style of Spotlight or Alfred. You give it one or more
sources. Each source searches a category and returns results. The overlay groups
results by category, keeps recent picks, and can show a preview pane.

```dart
OiSearch(
  label: 'Global search',
  sources: [
    OiSearchSource(
      category: 'Files',
      icon: OiIcons.file,
      search: (query) async => searchFiles(query),
    ),
    OiSearchSource(
      category: 'People',
      icon: OiIcons.user,
      search: (query) async => searchPeople(query),
    ),
  ],
  onSelect: (result) => openResult(result.id),
  onDismiss: () => closeSearch(),
)
```

Each source returns a list of `OiSearchResult`. A result carries an `id`, a
`title`, and optional `subtitle`, `leading`, `trailing`, and `preview` widgets.

```dart
OiSearchResult(
  id: 'file-42',
  title: 'Quarter report.pdf',
  subtitle: 'Shared folder',
  leading: Icon(OiIcons.file),
)
```

Arrow keys move the highlight, Enter selects, and Escape calls `onDismiss`.

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `sources` | `List<OiSearchSource>` | **required** | The categories to query. |
| `label` | `String` | **required** | Accessibility label for the overlay. |
| `onSelect` | `ValueChanged<OiSearchResult>?` | `null` | Fires when the user picks a result. |
| `onDismiss` | `VoidCallback?` | `null` | Fires on Escape. |
| `showRecent` | `bool` | `true` | Show recent picks when the query is empty. |
| `maxRecent` | `int` | `10` | How many recent items to keep. |
| `showPreview` | `bool` | `true` | Show the preview pane for the highlighted result. |
| `debounce` | `Duration` | `200ms` | Wait after typing before searching. |
| `filters` | `List<OiSearchFilter>?` | `null` | Optional filter chips below the input. |

Each `OiSearchSource` has `category`, `icon`, `search`, and `maxResults` (default
`5`). The `search` function is `Future<List<OiSearchResult>> Function(String query)`,
so async lookups work directly.

!!! note
    `OiSearch` renders the panel only. Put it inside an overlay or dialog yourself,
    or reach for `OiSearchOverlay` if you want the mounting handled for you. See
    [Overlays & Menus](overlays.md).

## OiCommandBar

A command palette like the one in VS Code or Raycast. You pass a flat list of
commands. The bar fuzzy-matches as the user types, groups by category, shows each
command's shortcut, and can drill into nested commands.

```dart
OiCommandBar(
  label: 'Command palette',
  onDismiss: () => closePalette(),
  commands: [
    OiCommand(
      id: 'new-doc',
      label: 'New document',
      icon: OiIcons.plus,
      category: 'File',
      shortcut: OiShortcutActivator.primary(LogicalKeyboardKey.keyN),
      onExecute: () => createDocument(),
    ),
    OiCommand(
      id: 'settings',
      label: 'Open settings',
      icon: OiIcons.settings,
      category: 'App',
      onExecute: () => openSettings(),
    ),
  ],
)
```

### Nested commands

Give a command `children` and it becomes a parent. Selecting it drills into its
children instead of running. Escape or Backspace steps back out.

```dart
OiCommand(
  id: 'theme',
  label: 'Change theme',
  children: [
    OiCommand(id: 'light', label: 'Light', onExecute: () => setLight()),
    OiCommand(id: 'dark', label: 'Dark', onExecute: () => setDark()),
  ],
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `commands` | `List<OiCommand>` | **required** | The available commands. |
| `label` | `String` | **required** | Accessibility label for the bar. |
| `onDismiss` | `VoidCallback?` | `null` | Fires on Escape or when a command runs. |
| `showRecent` | `bool` | `true` | Show recent commands when the query is empty. |
| `fuzzySearch` | `bool` | `true` | Fuzzy match. Set `false` for plain substring match. |
| `previewBuilder` | `Widget Function(OiCommand)?` | `null` | Builds a preview pane for the highlighted command. |
| `contextCommands` | `List<OiCommand> Function(BuildContext)?` | `null` | Supplies extra context-specific commands. |

Each `OiCommand` has `id`, `label`, and optional `description`, `icon`,
`category`, `shortcut`, `onExecute`, `children`, `keywords`, and `priority`. Add
`keywords` to make a command findable by words that are not in its label. Higher
`priority` sorts a command nearer the top.

!!! tip "When to reach for which"
    Use `OiCommandBar` for actions the user runs (create, navigate, toggle). Use
    `OiSearch` for content the user looks up (files, people, records).

## OiFilterBar

A horizontal row of filter chips. Each chip opens a popover with the right input
for its type. Active filters show as filled chips with a remove button. You own
the active-filter map and update it in `onFilterChange`.

```dart
Map<String, OiColumnFilter> _filters = {};

OiFilterBar(
  filters: [
    OiFilterDefinition(
      key: 'status',
      label: 'Status',
      type: OiFilterType.select,
      options: [
        OiSelectOption(value: 'open', label: 'Open'),
        OiSelectOption(value: 'closed', label: 'Closed'),
      ],
    ),
    OiFilterDefinition(
      key: 'created',
      label: 'Created',
      type: OiFilterType.dateRange,
    ),
  ],
  activeFilters: _filters,
  onFilterChange: (next) => setState(() => _filters = next),
)
```

Filter types cover most cases: `text`, `select`, `multiSelect`, `date`,
`dateRange`, `number`, `numberRange`, and `custom`. A `select` or `multiSelect`
filter needs `options`. A `text` filter can take `suggestions`. A `custom` filter
draws its own control through `customBuilder`.

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `filters` | `List<OiFilterDefinition>` | **required** | The available filter chips. |
| `activeFilters` | `Map<String, OiColumnFilter>` | **required** | Currently applied filters, keyed by filter `key`. |
| `onFilterChange` | `ValueChanged<Map<String, OiColumnFilter>>` | **required** | Fires with the updated map on any change. |
| `trailing` | `Widget?` | `null` | Widget after the last chip, such as a "Clear all" button. |
| `settingsDriver` | `OiSettingsDriver?` | `null` | Persist active filters. `null` disables persistence. |
| `settingsKey` | `String?` | `null` | Sub-key scoping this bar's saved settings. |
| `settingsNamespace` | `String` | `'oi_filter_bar'` | Top-level namespace for saved settings. |
| `settingsSaveDebounce` | `Duration` | `500ms` | Wait before auto-saving after a change. |

Each `OiColumnFilter` holds a `value` and an `operator` (`equals`, `contains`,
`greaterThan`, `lessThan`, or `between`). The value type follows the filter type,
so a `dateRange` filter stores a range, a `number` filter stores a number.

!!! note
    `OiFilterBar` only reports filter changes. Apply the filters to your data in
    your own state. Pair it with `OiTable` or `OiListView`.

## OiShortcuts

Wraps a subtree and registers keyboard shortcuts for it. Press `?` (Shift and
Slash) to open a help dialog that lists every shortcut, grouped by category. Use
`OiShortcutActivator.primary` so Ctrl maps to Cmd on macOS without extra code.

```dart
OiShortcuts(
  shortcuts: [
    OiShortcutBinding(
      activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyS),
      label: 'Save',
      category: 'File',
      onInvoke: () => save(),
    ),
    OiShortcutBinding(
      activator: OiShortcutActivator.primary(LogicalKeyboardKey.keyK),
      label: 'Open command bar',
      onInvoke: () => openCommandBar(),
    ),
  ],
  child: MyScreen(),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The subtree the shortcuts apply to. |
| `shortcuts` | `List<OiShortcutBinding>` | **required** | The shortcut bindings to register. |
| `showHelpOnQuestionMark` | `bool` | `true` | Open the help dialog when the user presses `?`. |

Each `OiShortcutBinding` takes an `activator`, a `label`, an `onInvoke` callback,
and optional `description` and `category`. Bindings with no `category` fall under
"General" in the help dialog.

`OiShortcutActivator` is a platform-aware `SingleActivator`. Use `.primary(key)`
for the Ctrl/Cmd modifier, and pass `shift` or `alt` when you need them. Its
`displayLabel` gives you a printable string like `Cmd+S`.

## Related

- [Overlays & Menus](overlays.md) for mounting `OiSearch` and `OiCommandBar` as overlays.
- [Navigation](navigation.md) for sidebars, breadcrumbs, and nav menus.
- [Tables](data-tables.md) for the data lists that `OiFilterBar` refines.
