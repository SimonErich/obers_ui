# Buttons & Actions

Buttons are how people tell your app to do something. ObersUI gives you one main
button with a set of variants, plus a few specialized buttons for toolbars, bulk
actions, sorting, and exporting. Every button reads its colors, spacing, and
corner radius from the theme, so they all match without extra work.

| Widget | What it does |
| --- | --- |
| `OiButton` | The everyday button. Six visual variants plus four special forms. |
| `OiIconButton` | A square, icon-only button with a required accessibility label. |
| `OiToggleButton` | A button that flips between on and off. |
| `OiFilterChip` | A compact filter or facet with an optional value and separate clear action. |
| `OiButtonGroup` | A row of connected buttons, optionally single-select. |
| `OiActionBar` | A toolbar of icon actions with automatic overflow. |
| `OiBulkBar` | The bar that appears when rows are selected ("3 selected, Delete"). |
| `OiSortButton` | A sort control for lists that are not tables. |
| `OiExportButton` | Exports data as CSV, XLSX, JSON, or PDF. |
| `OiBackButton` | A back-navigation chevron that flips for right-to-left. |

## OiButton

The button you will use most. It has no default constructor. You always pick a
variant with a named constructor, and the tap callback is always `onTap`.

```dart
OiButton.primary(
  label: 'Save',
  onTap: () => save(),
)
```

### Variants

Six visual styles cover the usual jobs. Pick by intent, not by color.

```dart
OiButton.primary(label: 'Save', onTap: () {})        // main action
OiButton.secondary(label: 'Details', onTap: () {})   // secondary action
OiButton.outline(label: 'Cancel', onTap: () {})      // bordered, transparent
OiButton.ghost(label: 'Skip', onTap: () {})          // no border, transparent
OiButton.destructive(label: 'Delete', onTap: () {})  // red, dangerous action
OiButton.soft(label: 'Save draft', onTap: () {})     // muted fill
```

### Icons, sizes, and states

Every variant accepts an icon, a size, and loading or disabled states.

```dart
// Icon before the label (the default) or after it.
OiButton.primary(
  label: 'Download',
  icon: OiIcons.download,
  iconPosition: OiIconPosition.leading,
  onTap: () {},
)

// Three sizes: small, medium (default), large.
OiButton.primary(label: 'Small', size: OiButtonSize.small, onTap: () {})

// loading shows a spinner and blocks taps. enabled: false greys it out.
OiButton.primary(label: 'Saving...', loading: true, onTap: () {})
OiButton.primary(label: 'Save', enabled: false, onTap: () {})

// fullWidth stretches to the parent's width, handy on mobile.
OiButton.primary(label: 'Continue', fullWidth: true, onTap: () {})
```

### Special forms

Four named constructors handle patterns that would otherwise need custom code.

```dart
// Icon-only, square. label becomes the screen-reader text.
OiButton.icon(icon: OiIcons.settings, label: 'Settings', onTap: () {})

// Main action plus a dropdown trigger.
OiButton.split(
  label: 'Publish',
  onTap: () => publish(),
  dropdown: myMenu,
)

// Disabled until the timer runs out. Good for "Resend code in 30s".
OiButton.countdown(label: 'Resend', onTap: () => resend(), seconds: 30)

// First tap swaps to confirmLabel, second tap fires onConfirm.
OiButton.confirm(
  label: 'Delete',
  confirmLabel: 'Tap again to confirm',
  onConfirm: () => delete(),
)
```

### Attributes

Common attributes for the variant constructors (`primary`, `secondary`,
`outline`, `ghost`, `destructive`, `soft`), with exceptions noted:

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | The button text. |
| `onTap` | `VoidCallback?` | `null` | Tap callback; null means no action, not an authored disabled state. |
| `size` | `OiButtonSize` | `medium` | `small`, `medium`, or `large`. |
| `icon` | `IconData?` | `null` | Optional leading or trailing icon. |
| `iconPosition` | `OiIconPosition` | `leading` | `leading` or `trailing`. |
| `enabled` | `bool` | `true` | Set `false` to disable. |
| `loading` | `bool` | `false` | Shows a spinner and blocks taps. |
| `fullWidth` | `bool` | `false` | Stretch to the parent's width. |
| `semanticLabel` | `String?` | `null` | Screen-reader text if it differs from `label`. |
| `tooltip` | `String?` | `null` | Hover/long-press message; primary/secondary/outline only. |
| `borderRadius` | `BorderRadius?` | `null` | Explicit radius; ghost/soft only. |

!!! note
    `OiButton.icon` requires `label` too. It is not shown on screen, but it is
    read aloud by screen readers, so icon-only buttons stay accessible.

**Theme:** `context.components.button` → `OiButtonThemeData`

### Opt-in styles per size

Leave `sizeStyles` null to retain legacy rendering, or configure independently
optional small/medium/large values through the theme constructor:

```dart
final buttonTheme = OiButtonThemeData(
  sizeStyles: OiButtonSizeStyles(
    medium: OiButtonSizeStyle(
      textStyle: const TextStyle(fontSize: 14, height: 20 / 14),
      iconSize: 16,
      iconGap: 6,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
      minWidth: 80,
    ),
  ),
);
```

Each field is nullable and falls back independently. Numeric geometry and every
resolved LTR/RTL inset edge are validated as finite and nonnegative in release
builds. Explicit zero is an override, not an absent value.

| Field | Where it applies | Null fallback |
| --- | --- | --- |
| `textStyle` | Normal, split, countdown and confirm labels | Legacy typography. Current state foreground always wins over selected color/Paint. |
| `iconSize` | Label-adjacent glyph and split chevron | Adjacent: global then size; split: size only, retaining its legacy global exclusion. |
| `iconOnlySize` | Icon-only glyph | Selected iconSize, global, then size. Does not change its square target. |
| `iconLabelPadding` | Explicit icon+label insets, including SMALL; trailing swaps start/end | Selected plain padding, then exact legacy insets. |
| `padding` | Content insets, including icon-only interior | Exact legacy global/density resolution. |
| `iconGap` | Directional space between glyph and label, including zero | Legacy absolute left/right gap; its inherited RTL behavior is unchanged. |
| `minWidth` | Textual frames and split main, not its chevron or icon square | Global width only for legacy normal/ghost; old other-form exclusions remain. |

The selected label style merges after legacy typography, preserving authored
line height and font variations. It does not replace interaction-state colors.
There is no new height, disabled-opacity policy or target enlargement. Parent
constraints still govern final layout. The old virtual `OiButtonThemeData.copyWith`
signature remains compatible: it preserves the current size-style group, but
configure a replacement group through the constructor.

!!! tip "When to reach for something else"
    Use `OiToggleButton` for on/off state, not `OiButton`. For navigation links,
    use `OiLabel.link` or your router, not a button styled to look like a link.

## OiIconButton

A convenience wrapper for a square, icon-only button. It is the same as
`OiButton.icon`, with a required `semanticLabel` so it never ships without a
label.

```dart
OiIconButton(
  icon: OiIcons.edit,
  semanticLabel: 'Edit',
  onTap: () => edit(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `icon` | `IconData` | **required** | The icon to show. |
| `semanticLabel` | `String` | **required** | Screen-reader text. |
| `onTap` | `VoidCallback?` | `null` | Called on tap. |
| `size` | `OiButtonSize` | `medium` | Button size. |
| `variant` | `OiButtonVariant` | `ghost` | Visual style. |
| `enabled` | `bool` | `true` | Set `false` to disable. |

## OiToggleButton

A button that shows an on or off state. You own the `selected` value and update
it in `onChanged`.

```dart
bool _bold = false;

OiToggleButton(
  selected: _bold,
  semanticLabel: 'Bold',
  icon: OiIcons.bold,
  onChanged: (value) => setState(() => _bold = value),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `selected` | `bool` | **required** | Whether the button is on. |
| `semanticLabel` | `String` | **required** | Screen-reader text. |
| `label` | `String?` | `null` | Optional visible text. |
| `icon` | `IconData?` | `null` | Optional icon. |
| `onChanged` | `ValueChanged<bool>?` | `null` | Fires with the next state. |
| `size` | `OiButtonSize` | `medium` | Button size. |
| `enabled` | `bool` | `true` | Set `false` to disable. |

!!! tip
    For a settings-style on/off, prefer `OiSwitch`. Use `OiToggleButton` for
    formatting toolbars and similar in-context toggles (bold, favorite, pin).

## OiFilterChip

Use a filter chip for a toolbar filter or a catalog facet. The inactive state
shows a plus and a dashed outline; the selected state uses the theme's soft
primary color. Set `dashed: false` for choices inside a filter form.

```dart
OiFilterChip(
  label: 'Status',
  value: 'Confirmed',
  selected: true,
  onTap: openStatusFilter,
  onRemove: clearStatusFilter,
  removeLabel: 'Clear status filter',
)
```

`onTap` opens or toggles the filter. An optional `onRemove` adds a separate,
named clear button; it never triggers `onTap`. Without a clear action, selected
facets show a checkmark (`showCheckmark: false` hides it). Set `showAddIcon: false`
for inactive choice chips that need no plus symbol. `semanticLabel` can
override the combined label and value. Both actions support Tab, Space, and
Enter, and long values truncate within the available width.

The default height is 32; `height`, `textStyle`, and `borderRadius` can override
the presentation. Colors come from the theme, and the default radius follows
the button component theme.

## OiButtonGroup

A row (or column) of connected buttons. Set `spacing` to `0` for a joined,
segmented look, or a larger value to space them out. Turn on `exclusive` to make
it behave like a single-select toggle.

```dart
OiButtonGroup(
  label: 'View mode',
  exclusive: true,
  selectedIndex: _view,
  onSelect: (index) => setState(() => _view = index),
  items: [
    OiButtonGroupItem(label: 'List', icon: OiIcons.list),
    OiButtonGroupItem(label: 'Grid', icon: OiIcons.grid),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Group accessibility label. |
| `items` | `List<OiButtonGroupItem>` | **required** | The buttons. Each has `label`, `icon`, `onTap`, `enabled`, `semanticLabel`. |
| `exclusive` | `bool` | `false` | Single-select toggle mode. |
| `selectedIndex` | `int?` | `null` | Selected item when `exclusive` is on. |
| `onSelect` | `ValueChanged<int>?` | `null` | Fires with the tapped index. |
| `spacing` | `double` | `0` | `0` joins the buttons, larger values gap them. |
| `direction` | `Axis` | `horizontal` | Lay out in a row or a column. |
| `size` | `OiButtonSize` | `medium` | Button size. |
| `wrap` | `bool` | `true` | Wrap to the next line when space runs out. |

## OiActionBar

A toolbar of icon actions. It measures the space it has and moves extra actions
into an overflow menu, so it never overflows the screen. Good for the top of a
detail view or the header of a panel.

```dart
OiActionBar(
  label: 'Document actions',
  actions: [
    OiActionBarItem(icon: OiIcons.share, label: 'Share', semanticLabel: 'Share', onTap: share),
    OiActionBarItem(icon: OiIcons.download, label: 'Download', semanticLabel: 'Download', onTap: download),
    OiActionBarItem(icon: OiIcons.delete, label: 'Delete', semanticLabel: 'Delete', onTap: remove),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `actions` | `List<OiActionBarItem>` | **required** | The visible actions. |
| `label` | `String` | **required** | Toolbar accessibility label. |
| `overflowActions` | `List<OiActionBarItem>?` | `null` | Actions that always live in the overflow menu. |
| `leading` / `trailing` | `Widget?` | `null` | Fixed widgets pinned to each end. |
| `style` | `OiActionBarStyle` | `flat` | `flat` or a bordered card look. |
| `showLabels` | `bool?` | `null` | Force labels on or off next to icons. |
| `size` | `OiButtonSize` | `medium` | Action button size. |

Each `OiActionBarItem` supports `toggled`, `badge`, `loading`, `confirm`, and
`group`, so you can build sticky toggles and grouped toolbars.

## OiBulkBar

The bar that slides in when a user selects rows or items. It shows the count, a
select-all control, and a set of bulk actions.

```dart
OiBulkBar(
  label: 'Selection',
  selectedCount: selected.length,
  totalCount: items.length,
  allSelected: selected.length == items.length,
  onSelectAll: selectAll,
  onDeselectAll: clearSelection,
  actions: [
    OiBulkAction(label: 'Archive', icon: OiIcons.archive, onTap: archive),
    OiBulkAction(
      label: 'Delete',
      icon: OiIcons.delete,
      variant: OiBulkActionVariant.destructive,
      confirm: true,
      onTap: deleteSelected,
    ),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `selectedCount` | `int` | **required** | How many items are selected. |
| `totalCount` | `int` | **required** | The total item count. |
| `label` | `String` | **required** | Accessibility label. |
| `actions` | `List<OiBulkAction>` | **required** | The bulk actions. |
| `onSelectAll` | `VoidCallback?` | `null` | Select-all handler. |
| `onDeselectAll` | `VoidCallback?` | `null` | Clear-selection handler. |
| `allSelected` | `bool` | `false` | Whether every item is selected. |

Each `OiBulkAction` takes a `variant`, `loading`, and `confirm` flag for
destructive actions that need a second tap.

## OiSortButton

A sort control for lists that are not tables, like card grids and feeds. It shows
the current field and direction, and opens a small popover to change them.

```dart
OiSortButton(
  label: 'Sort by',
  options: [
    OiSortOption(field: 'name', label: 'Name'),
    OiSortOption(field: 'date', label: 'Date'),
    OiSortOption(field: 'size', label: 'Size'),
  ],
  currentSort: _sort,
  onSortChange: (option) => setState(() => _sort = option),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `options` | `List<OiSortOption>` | **required** | Sortable fields. Each has `field`, `label`, `direction`. |
| `currentSort` | `OiSortOption` | **required** | The active sort. |
| `label` | `String` | **required** | Accessibility label. |
| `onSortChange` | `ValueChanged<OiSortOption>` | **required** | Fires with the new field and direction. |

!!! note
    Tables sort with their own column headers. Reach for `OiSortButton` only when
    there is no table header to click.

## OiExportButton

Exports data in one or more formats. With a single format it renders as a plain
button. With several, it becomes a split button with a format menu.

```dart
// One format: a direct action.
OiExportButton(
  label: 'Export',
  onExport: (format) async => downloadFile(format),
)

// Several formats: a dropdown of choices.
OiExportButton(
  label: 'Export',
  formats: [OiExportFormat.csv, OiExportFormat.xlsx, OiExportFormat.json],
  onExport: (format) async => downloadFile(format),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Button text. |
| `onExport` | `Future<void> Function(OiExportFormat)` | **required** | Runs the export. The button shows a spinner while it awaits. |
| `formats` | `List<OiExportFormat>` | `[csv]` | Offered formats. `csv`, `xlsx`, `json`, `pdf`. |
| `loading` | `bool` | `false` | Force the loading state. |

## OiBackButton

A back-navigation chevron. It points left, and flips to point right in
right-to-left layouts, so you do not have to handle that yourself. It is common
as the leading widget in a header.

```dart
OiBackButton(
  onPressed: () => Navigator.of(context).pop(),
  semanticLabel: 'Go back',
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `onPressed` | `VoidCallback` | **required** | Called on tap. |
| `semanticLabel` | `String` | **required** | Screen-reader text. |
| `color` | `Color?` | `null` | Overrides the icon color. |
| `size` | `double` | `24.0` | Icon size in logical pixels. |

## Related

- [Overlays & Menus](overlays.md) for the menus a split button or action item opens.
- [Navigation](navigation.md) for tabs, breadcrumbs, and rails.
- [Feedback & Status](feedback.md) for progress and loading indicators.
