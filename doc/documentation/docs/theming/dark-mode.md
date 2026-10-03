# Dark Mode

ObersUI ships a light theme and a dark theme as a matched pair. Every design
token has a dark equivalent, so when you provide a dark theme, every widget
adapts on its own. You set the two themes once on `OiApp` and pick how they
switch.

## Basic setup

Give `OiApp` a light theme, a dark theme, and a mode. The mode decides which one
shows.

```dart
OiApp(
  theme: OiThemeData.light(),
  darkTheme: OiThemeData.dark(),
  themeMode: OiThemeMode.system,
  home: const MyHomePage(),
)
```

You do not restyle any widgets. Colors come from `context.colors`, and the color
scheme swaps with the theme. A screen written like this reads correctly in both
modes:

```dart
OiColumn(
  gap: OiResponsive(context.spacing.md),
  children: [
    OiLabel.h2('Settings'),
    OiLabel.body('Pick how the app looks.'),
    OiButton.primary(label: 'Save', onTap: () => save()),
  ],
)
```

!!! note
    If you leave `darkTheme` null, `OiApp` uses the light theme for both modes.
    Provide a dark theme to get real dark mode.

### OiApp theme parameters

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `theme` | `OiThemeData?` | `OiThemeData.light()` | The light theme. |
| `darkTheme` | `OiThemeData?` | `null` | The dark theme. Falls back to `theme` when null. |
| `themeMode` | `OiThemeMode` | `OiThemeMode.system` | Which theme to use. |

## Theme modes

`OiThemeMode` has three values. `system` is the default.

| Mode | Behavior |
| --- | --- |
| `OiThemeMode.light` | Always use the light theme. |
| `OiThemeMode.dark` | Always use the dark theme. |
| `OiThemeMode.system` | Follow the OS brightness setting. |

## OiThemeData.dark

`OiThemeData.dark()` builds the standard dark theme. It shares the structure of
`OiThemeData.light()`, with a dark color scheme and reduced shadow intensity.

```dart
OiApp(
  theme: OiThemeData.light(),
  darkTheme: OiThemeData.dark(),
  themeMode: OiThemeMode.dark,
  home: const MyHomePage(),
)
```

Both factories take the same optional arguments, so you can keep fonts and corner
radius the same across modes.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `fontFamily` | `String?` | `null` | Font family for text styles. |
| `monoFontFamily` | `String?` | `null` | Font family for code text. |
| `radiusPreference` | `OiRadiusPreference` | `medium` | Corner radius scale. |
| `components` | `OiComponentThemes?` | `null` | Per-component overrides. |
| `performanceConfig` | `OiPerformanceConfig?` | `high` | Blur, shadow, and animation config. |
| `breakpoints` | `OiBreakpointScale?` | `standard` | Responsive breakpoints. |

## Brand colors in both modes

`OiThemeData.fromBrand` derives a full theme from one brand color. Pass
`brightness: Brightness.dark` for the dark variant. Use the same `color` for both
so your brand stays consistent across modes.

```dart
const brand = Color(0xFF6D28D9);

OiApp(
  theme: OiThemeData.fromBrand(color: brand),
  darkTheme: OiThemeData.fromBrand(
    color: brand,
    brightness: Brightness.dark,
  ),
  themeMode: OiThemeMode.system,
  home: const MyHomePage(),
)
```

The library derives the other semantic colors from the brand color and adjusts
surfaces, text contrast, and swatch variants for each brightness.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `color` | `Color` | **required** | The brand color used as the primary swatch. |
| `brightness` | `Brightness` | `Brightness.light` | Light or dark variant. |
| `fontFamily` | `String?` | `null` | Font family for text styles. |
| `monoFontFamily` | `String?` | `null` | Font family for code text. |
| `radiusPreference` | `OiRadiusPreference` | `medium` | Corner radius scale. |
| `components` | `OiComponentThemes?` | `null` | Per-component overrides. |

!!! note
    This is the one place you pass a raw `Color`. It is a brand input for the
    theme, not a value you hardcode in a widget. In widgets, read colors from
    `context.colors`.

## OiThemeToggle

`OiThemeToggle` is a user-facing switch for the theme mode. It shows a sun for
light, a moon for dark, and a monitor for system. You hold the current mode and
update it in `onModeChange`.

```dart
OiThemeMode _mode = OiThemeMode.system;

OiThemeToggle(
  currentMode: _mode,
  onModeChange: (mode) => setState(() => _mode = mode),
)
```

Feed `_mode` back into `OiApp.themeMode` so the toggle drives the whole app.

By default, tapping opens a popover with all three options. Set
`showSystemOption: false` to cycle between light and dark on each tap instead.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `currentMode` | `OiThemeMode` | **required** | The active theme mode. |
| `onModeChange` | `ValueChanged<OiThemeMode>?` | `null` | Fires with the chosen mode. `null` disables the toggle. |
| `label` | `String` | `'Toggle theme'` | Accessibility label and tooltip text. |
| `showSystemOption` | `bool` | `true` | Show a three-option popover, or cycle light and dark only. |

## Checking the current mode

Read the resolved theme from the context. This tells you which brightness is live
right now, after `system` has resolved.

```dart
final isDark = context.theme.isDark;
final isLight = context.theme.isLight;
```

## Scoped override

Need a dark section inside a light app, or the reverse? Wrap that subtree in
`OiThemeScope`. It overrides the theme for its children and leaves the rest of the
app alone.

```dart
OiThemeScope(
  data: OiThemeData.dark(),
  child: const MySidebar(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `OiThemeData` | **required** | The theme for the subtree. |
| `child` | `Widget` | **required** | The widgets that receive it. |

## Animated transitions

`OiThemeData.lerp` interpolates between two themes. Pass a `t` from `0` to `1`.
Use it to animate a custom switch between light and dark.

```dart
final mid = OiThemeData.lerp(
  OiThemeData.light(),
  OiThemeData.dark(),
  0.5,
);
```

## Related

- [Color System](color-system.md) for the color scheme and `context.colors`.
- [Tokens](tokens.md) for spacing, radius, shadows, and the rest.
- [Quick Brand](quick-brand.md) for building a theme from one brand color.
- [Component Themes](component-themes.md) for per-component overrides.
- [Navigation](../widgets/navigation.md) for where `OiThemeToggle` fits in a header.
