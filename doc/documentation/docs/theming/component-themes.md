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

## Available component themes

| Widget | Theme class |
|---|---|
| `OiButton` | `OiButtonThemeData` |
| `OiTextInput` | `OiTextInputThemeData` |
| `OiSelect` | `OiSelectThemeData` |
| `OiCard` | `OiCardThemeData` |
| `OiDialog` | `OiDialogThemeData` |
| `OiToast` | `OiToastThemeData` |
| `OiTooltip` | `OiTooltipThemeData` |
| `OiTable` | `OiTableThemeData` |
| `OiTabs` | `OiTabsThemeData` |
| `OiBadge` | `OiBadgeThemeData` |
| `OiCheckbox` | `OiCheckboxThemeData` |
| `OiSwitch` | `OiSwitchThemeData` |
| `OiSheet` | `OiSheetThemeData` |
| `OiAvatar` | `OiAvatarThemeData` |
| `OiProgress` | `OiProgressThemeData` |
| `OiSidebar` | `OiSidebarThemeData` |
| `OiFileExplorer` | `OiFileExplorerThemeData` |
| `OiDialogShell` | `OiDialogShellThemeData` |
| `OiRefreshIndicator` | `OiRefreshIndicatorThemeData` |
| `OiNavigationRail` | `OiNavigationRailThemeData` |
| `OiSliverHeader` | `OiSliverHeaderThemeData` |
| `OiFormSelect` | `OiFormSelectThemeData` |
| `OiSwitchTile` | `OiSwitchTileThemeData` |
| `OiSegmentedControl` | `OiSegmentedControlThemeData` |
| `OiTabView` | `OiTabViewThemeData` |
| `OiReorderableList` | `OiReorderableListThemeData` |
| `OiDatePickerField` | `OiDatePickerFieldThemeData` |
| `OiDataGrid` | `OiDataGridThemeData` |

## Accessing component themes

```dart
final buttonTheme = context.components.button;
```

## When to use component themes

- **Global button restyling** — "All buttons should have 8dp radius"
- **Brand-specific input styling** — "Inputs should have a bottom-border-only style"
- **Feature-flagged UI** — Different themes for different user tiers

## When NOT to use component themes

If you just need to style a single instance, use the widget's own props instead:

```dart
// Prefer this for one-off styling:
OiButton(label: 'Save', variant: OiButtonVariant.primary)

// Rather than creating a whole component theme for one button
```

Component themes are for **systematic, app-wide overrides** — not individual tweaks.
