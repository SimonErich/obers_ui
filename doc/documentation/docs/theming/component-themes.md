# Component Themes

For fine-grained control, ObersUI supports **per-component theme overrides**. This lets you restyle individual widget types without affecting the rest of the system.

## How it works

`OiComponentThemes` holds optional theme data for specific widgets:

```dart
OiThemeData.light(
  components: OiComponentThemes(
    button: OiButtonThemeData(
      // Override button-specific styles
    ),
    textInput: OiTextInputThemeData(
      // Override text input styles
    ),
  ),
)
```

Use `OiComponentThemes.empty()` to start from all defaults, or pass only
the fields you want to override.

## Available component themes

`OiComponentThemes` currently exposes **40** component-theme fields.
Grouped by area:

### Buttons & actions

| Widget | Theme class |
| --- | --- |
| `OiButton` (+ variants, split, icon) | `OiButtonThemeData` |
| `OiSegmentedControl` | `OiSegmentedControlThemeData` |
| `OiActionBar` | `OiActionBarThemeData` |

### Inputs

| Widget | Theme class |
| --- | --- |
| `OiTextInput` | `OiTextInputThemeData` |
| `OiSelect` | `OiSelectThemeData` |
| `OiFormSelect` | `OiFormSelectThemeData` |
| `OiCheckbox` | `OiCheckboxThemeData` |
| `OiSwitch` | `OiSwitchThemeData` *(field name: `switchTheme` — `switch` is a reserved word in Dart)* |
| `OiSwitchTile` | `OiSwitchTileThemeData` |
| `OiSlider` | `OiSliderThemeData` |
| `OiDatePickerField` | `OiDatePickerFieldThemeData` |
| `OiDateRangePicker` | `OiDateRangePickerThemeData` |

### Display

| Widget | Theme class |
| --- | --- |
| `OiCard` | `OiCardThemeData` |
| `OiBadge` | `OiBadgeThemeData` |
| `OiAvatar` | `OiAvatarThemeData` |
| `OiProgress` | `OiProgressThemeData` |
| `OiKeyValue` | `OiKeyValueThemeData` |
| `OiFieldDisplay` | `OiFieldDisplayThemeData` |
| `OiPagination` | `OiPaginationThemeData` |
| `OiIndexBar` | `OiIndexBarThemeData` |
| `OiWeekStrip` | `OiWeekStripThemeData` |
| Chart palette | `OiChartThemeData` |

### Feedback & overlays

| Widget | Theme class |
| --- | --- |
| `OiDialog` | `OiDialogThemeData` |
| `OiDialogShell` | `OiDialogShellThemeData` |
| `OiSheet` | `OiSheetThemeData` |
| `OiToast` | `OiToastThemeData` |
| `OiTooltip` | `OiTooltipThemeData` |
| `OiContextMenu` | `OiContextMenuThemeData` |
| `OiBanner` | `OiBannerThemeData` |
| `OiRefreshIndicator` | `OiRefreshIndicatorThemeData` |

### Navigation

| Widget | Theme class |
| --- | --- |
| `OiTabs` | `OiTabsThemeData` |
| `OiTabView` | `OiTabViewThemeData` |
| `OiSidebar` | `OiSidebarThemeData` |
| `OiNavigationRail` | `OiNavigationRailThemeData` |
| `OiSliverHeader` | `OiSliverHeaderThemeData` |
| `OiAccountSwitcher` | `OiAccountSwitcherThemeData` |

### Data & files

| Widget | Theme class |
| --- | --- |
| `OiTable` | `OiTableThemeData` |
| `OiDataGrid` | `OiDataGridThemeData` |
| `OiReorderableList` | `OiReorderableListThemeData` |
| `OiGroupedList` | `OiGroupedListThemeData` |
| `OiFileExplorer` | `OiFileExplorerThemeData` |

For the exact field list see
[lib/src/foundation/theme/oi_component_themes.dart](../../../lib/src/foundation/theme/oi_component_themes.dart).

## Accessing component themes

```dart
final buttonTheme = context.components.button;
```

## When to use component themes

- **Global button restyling** — "All buttons should have 8dp radius"
- **Brand-specific input styling** — "Inputs should have a bottom-border-only style"
- **Feature-flagged UI** — Different themes for different user tiers

## When NOT to use component themes

If you just need to style a single instance, use the widget's own props
(or the widget's variant constructor) instead of defining a theme:

```dart
// Prefer this for one-off styling:
OiButton.primary(label: 'Save', onTap: () {})

// Rather than creating a whole component theme for one button
```

Component themes are for **systematic, app-wide overrides** — not
individual tweaks.

## Scoped overrides

Some themes (like `OiButtonThemeData`) also support **scoped overrides**
via an inherited-widget wrapper — e.g. `OiButtonThemeScope` applies a
theme just to its subtree without affecting the rest of the app:

```dart
OiButtonThemeScope(
  theme: OiButtonThemeData(height: 48),
  child: MyButtonArea(),
)
```

Buttons inside the scope pick up the override; buttons elsewhere keep the
global `OiComponentThemes.button`.
