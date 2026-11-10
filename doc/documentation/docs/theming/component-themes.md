# Component Themes

Component themes let you restyle one widget family across your whole app. You set
them once on the theme, and every widget of that type picks up the override. Use
them when a global visual rule, like "all buttons have an 8px radius", would be
tedious to repeat on each widget.

`OiComponentThemes` holds one optional field per widget family. Every field is
nullable. A `null` field means the widget uses its built-in defaults. Every theme
data class also has a `copyWith` method, so you can start from one and change a
few values.

## How it works

`OiThemeData.light()` and `OiThemeData.dark()` take a `components` parameter. Pass
an `OiComponentThemes` with the fields you want to override.

```dart
OiApp(
  theme: OiThemeData.light(
    components: OiComponentThemes(
      button: OiButtonThemeData(
        borderRadius: BorderRadius.circular(8),
      ),
      card: OiCardThemeData(
        elevation: 2,
        padding: EdgeInsets.all(20),
      ),
    ),
  ),
  home: const MyHomePage(),
)
```

You can also start from an existing theme and add components with `copyWith`. This
is handy when you already have a theme object.

```dart
final base = OiThemeData.light();

final themed = base.copyWith(
  components: OiComponentThemes(
    button: OiButtonThemeData(borderRadius: BorderRadius.circular(8)),
  ),
);
```

Use `OiComponentThemes.empty()` for a value with every field set to `null`. That is
also the default when you do not pass `components`.

## Reading a component theme

Read the active overrides from the theme with `context.components`. It returns the
`OiComponentThemes` for the current theme. Each field is the theme data or `null`.

```dart
final buttonTheme = context.components.button;

if (buttonTheme?.borderRadius != null) {
  // A button radius override is set.
}
```

Widgets read their own theme field for you. You rarely need `context.components`
in app code. Reach for it when you build a custom widget that should honor an
override.

## Available component themes

`OiComponentThemes` exposes a field per widget family. The tables
below group them by area.

### Buttons and actions

| Field | Type |
| --- | --- |
| `button` | `OiButtonThemeData` |
| `segmentedControl` | `OiSegmentedControlThemeData` |
| `actionBar` | `OiActionBarThemeData` |

### Inputs

| Field | Type |
| --- | --- |
| `textInput` | `OiTextInputThemeData` |
| `select` | `OiSelectThemeData` |
| `formSelect` | `OiFormSelectThemeData` |
| `checkbox` | `OiCheckboxThemeData` |
| `radio` | `OiRadioThemeData` |
| `radioTile` | `OiRadioTileThemeData` |
| `switchTheme` | `OiSwitchThemeData` |
| `switchTile` | `OiSwitchTileThemeData` |
| `slider` | `OiSliderThemeData` |
| `datePickerField` | `OiDatePickerFieldThemeData` |
| `dateRangePicker` | `OiDateRangePickerThemeData` |

!!! note
    The switch field is named `switchTheme`, not `switch`. `switch` is a reserved
    word in Dart, so the field uses a different name.

### Display

| Field | Type |
| --- | --- |
| `card` | `OiCardThemeData` |
| `badge` | `OiBadgeThemeData` |
| `avatar` | `OiAvatarThemeData` |
| `progress` | `OiProgressThemeData` |
| `keyValue` | `OiKeyValueThemeData` |
| `fieldDisplay` | `OiFieldDisplayThemeData` |
| `pagination` | `OiPaginationThemeData` |
| `indexBar` | `OiIndexBarThemeData` |
| `weekStrip` | `OiWeekStripThemeData` |
| `chart` | `OiChartThemeData` |

### Feedback and overlays

| Field | Type |
| --- | --- |
| `dialog` | `OiDialogThemeData` |
| `dialogShell` | `OiDialogShellThemeData` |
| `sheet` | `OiSheetThemeData` |
| `toast` | `OiToastThemeData` |
| `tooltip` | `OiTooltipThemeData` |
| `contextMenu` | `OiContextMenuThemeData` |
| `banner` | `OiBannerThemeData` |
| `refreshIndicator` | `OiRefreshIndicatorThemeData` |

### Navigation

| Field | Type |
| --- | --- |
| `tabs` | `OiTabsThemeData` |
| `tabView` | `OiTabViewThemeData` |
| `sidebar` | `OiSidebarThemeData` |
| `navigationRail` | `OiNavigationRailThemeData` |
| `sliverHeader` | `OiSliverHeaderThemeData` |
| `accountSwitcher` | `OiAccountSwitcherThemeData` |

### Data and files

| Field | Type |
| --- | --- |
| `table` | `OiTableThemeData` |
| `dataGrid` | `OiDataGridThemeData` |
| `reorderableList` | `OiReorderableListThemeData` |
| `groupedList` | `OiGroupedListThemeData` |
| `fileExplorer` | `OiFileExplorerThemeData` |

## OiButtonThemeData

Overrides the shape, spacing, and per-variant colors of every `OiButton`. Set
`borderRadius`, `height`, and the gap and size of icons. For color, pass an
`OiButtonVariantStyle` to the matching `...Style` field.

```dart
OiButtonThemeData(
  borderRadius: BorderRadius.circular(8),
  height: 44,
  iconGap: 6,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `borderRadius` | `BorderRadius?` | `null` | Corner radius of the button shape. |
| `padding` | `EdgeInsets?` | `null` | Internal padding. |
| `textStyle` | `TextStyle?` | `null` | Label text style. |
| `fontSizes` | `OiButtonFontSizeScale?` | `null` | Per-size font sizes and weights. Overrides the 12/14/16, w500 defaults. |
| `height` | `double?` | `null` | Fixed height. Ignores the size and density calculation. |
| `minWidth` | `double?` | `null` | Minimum width. |
| `iconSize` | `double?` | `null` | Icon dimension. |
| `iconGap` | `double?` | `null` | Gap between icon and label. |
| `primaryStyle` | `OiButtonVariantStyle?` | `null` | Color overrides for the primary variant. |
| `secondaryStyle` | `OiButtonVariantStyle?` | `null` | Color overrides for the secondary variant. |
| `outlineStyle` | `OiButtonVariantStyle?` | `null` | Color overrides for the outline variant. |
| `ghostStyle` | `OiButtonVariantStyle?` | `null` | Color overrides for the ghost variant. |
| `destructiveStyle` | `OiButtonVariantStyle?` | `null` | Color overrides for the destructive variant. |
| `softStyle` | `OiButtonVariantStyle?` | `null` | Color overrides for the soft variant. |

Each `OiButtonVariantStyle` holds background, foreground, and border colors for the
default, hover, pressed, and disabled states. Every field is nullable. A `null`
color falls back to the derived swatch color.

```dart
OiButtonThemeData(
  primaryStyle: OiButtonVariantStyle(
    background: context.colors.primary.base,
    backgroundHover: context.colors.primary.hover,
  ),
)
```

## OiCardThemeData

Overrides the surface of every `OiCard`. Set the radius, elevation, padding, and
border. Pass an explicit `shadow` list when you want full control over the drop
shadow.

```dart
OiCardThemeData(
  borderRadius: BorderRadius.circular(12),
  elevation: 1,
  padding: EdgeInsets.all(16),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `borderRadius` | `BorderRadius?` | `null` | Corner radius of the card surface. |
| `elevation` | `double?` | `null` | Shadow depth. |
| `padding` | `EdgeInsets?` | `null` | Internal padding of the content area. |
| `backgroundColor` | `Color?` | `null` | Card surface color. |
| `borderColor` | `Color?` | `null` | Border color for outlined cards. |
| `borderWidth` | `double?` | `null` | Border width for outlined cards. |
| `shadow` | `List<BoxShadow>?` | `null` | Explicit shadow. Takes precedence over `elevation`. |

## Scoped button overrides

Component themes apply to the whole app. For a single subtree, wrap it in
`OiButtonThemeScope`. Buttons inside the scope use its theme. Buttons elsewhere
keep the global `OiComponentThemes.button`.

```dart
OiButtonThemeScope(
  theme: OiButtonThemeData(height: 48),
  child: OiColumn(
    children: [
      OiButton.primary(label: 'Save', onTap: () {}),
      OiButton.secondary(label: 'Cancel', onTap: () {}),
    ],
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `theme` | `OiButtonThemeData` | **required** | The button theme for the subtree. |
| `child` | `Widget` | **required** | The subtree that reads the override. |

## When to use component themes

- App-wide shape rules, like "every button has an 8px radius".
- Brand input styling, like a bottom-border-only text field look.
- Different themes per user tier or feature flag.

## When not to use them

For a one-off tweak, set the widget's own props or pick a variant constructor. Do
not define a component theme for a single widget.

```dart
// Prefer this for one instance:
OiButton.primary(label: 'Save', onTap: () {})
```

Component themes are for systematic overrides, not individual widgets.

## Compact navigation and data controls

`OiSidebarThemeData.plainBadges` displays counts as text instead of filled
badges. `badgeTextStyle`, `labelGap`, and `itemSpacing` control their typography
and spacing. `selectedIconColor` and `selectedBorderColor` style the active
destination independently of its label and background.

`OiPaginationThemeData.distributed` places the range, page buttons, and page-size
control in three aligned areas when space permits; compact widths still wrap.
`showFirstLast` and `siblingCount` control which page buttons appear.
`buttonSize`, `buttonSpacing`, `buttonRadius`, `perPageWidth`, and `padding`
control density. `activeBackground`, `activeForeground`, `pageStyle`,
`activePageStyle`, and `labelStyle` control the colors and text. Page buttons
retain focus indication and keyboard activation.

`OiTabsThemeData.tabSpacing` separates scrollable underline or filled tabs.
Each `OiTabItem` can provide a `trailing` widget, such as a count, and a combined
`semanticLabel` so its visual parts remain one accessible destination.

`OiSegmentedControlThemeData.inset` adds padding inside a shared track without
increasing its configured `height`. With a positive inset, `innerRadius` rounds
each segment independently, creating an inset selection pill. The default zero
inset preserves joined segments; focus and arrow-key selection work in both.

`OiSwitchThemeData.width` and `height` control the switch track; the widget's
`labelLeading` option moves its label before the track. `OiDateInput.leadingIcon`
moves the calendar icon before the value, while `semanticLabel` names a compact
input that does not have a visible label. Both preserve keyboard operation.

## Related

- [Color System](color-system.md) for the swatches you pass to variant styles.
- [Design Tokens](tokens.md) for spacing, radius, and shadow scales.
- [Buttons and Actions](../widgets/buttons.md) for the buttons `OiButtonThemeData` styles.
- [Display](../widgets/display.md) for the cards `OiCardThemeData` styles.

## Radio choices and selectable cards

`OiRadioThemeData` controls the indicator diameter, center dot, outline width and
selected colors. `OiRadio` and `OiRadioTile` share the same indicator. A tile uses
only the indicator, so a hidden empty radio label cannot introduce extra spacing
or another keyboard stop. `labelStyle` styles option labels; `groupLabelStyle`
lets form renderers use one theme for headings above choice groups.
`groupLabelSpacing` controls the heading-to-options gap independently of gaps
between individual options.

`OiRadioTileThemeData` controls card padding, minimum height, radius, normal and
selected fills and outlines. Card outlines paint over the surface and do not
consume layout space: changing the selected outline from 1px to 2px never moves
text or changes the card height. A minimum height leaves multiline options free
to grow. Widget-specific content padding still overrides the theme.

```dart
OiComponentThemes(
  radio: OiRadioThemeData(
    size: 16,
    dotSize: 6,
    borderWidth: 1,
    selectedFillColor: colors.surface,
    selectedDotColor: colors.primary.base,
  ),
  radioTile: OiRadioTileThemeData(
    minHeight: 48,
    borderRadius: BorderRadius.circular(10),
    padding: const EdgeInsets.all(12),
    borderWidth: 1,
    selectedBorderWidth: 2,
  ),
)
```


## Field labels and capacity values

`OiTextInputThemeData.labelStyle`, `labelGap` and `supportingGap` let a theme
configure headings and helper/error spacing together. `OiFieldLabel` uses this
heading role and can display `labelMarkerColor` with an accessible
`labelMarkerDescription`. The owner provides the marker's state; the widget
stores no draft or history. Inputs already expose their field name separately,
so standalone group headings can keep their own semantics with
`excludeLabelSemantics: false`.

`OiCapacityIndicator.valueStyle` overrides its ratio typography independently
of `labelStyle`. Without a value override, an explicit label style retains its
legacy precedence over the capacity theme's value style. This makes existing
custom capacity rendering stable while permitting separate label/value roles.


`OiButtonThemeData.smallIconGap` optionally overrides the icon-to-label gap for
small buttons. Null retains the global `iconGap` or built-in spacing; medium
and large buttons continue using the global gap. Icon-only buttons gain no
label gap. This separates compact toolbar spacing from ordinary form actions.

`OiButtonThemeData.iconLabelPadding` optionally separates the icon-side and
label-side insets of regular icon-and-label buttons. Its directional start
represents the icon side, so a trailing icon reverses the start/end insets.
Small, icon-only and plain-label buttons retain ordinary `padding`; null keeps
all existing padding behavior. This permits asymmetric action insets without
changing compact toolbar sizing.
