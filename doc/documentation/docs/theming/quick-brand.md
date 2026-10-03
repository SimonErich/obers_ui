# Quick Brand Setup

The fastest way to a branded app. Give ObersUI one brand color and it generates
a full palette for you. This page shows that one-line setup, how to get light and
dark from the same color, and the factory options you can pass along the way.

## Three levels of control

You theme an ObersUI app at one of three levels. Pick the smallest one that does
the job.

| Level | Call | When you use it |
| --- | --- | --- |
| Just works | `OiThemeData.light()` / `OiThemeData.dark()` | You want the default look and no branding yet. |
| Brand it | `OiThemeData.fromBrand(color: ...)` | You have a brand color and want everything to match it. |
| Full control | `OiThemeData.light().copyWith(...)` | You need to set individual tokens by hand. |

The rest of this page covers the first two. For the third, see
[Extending Themes](extending-themes.md).

## Level 1: light() and dark()

`OiThemeData.light()` and `OiThemeData.dark()` build the standard themes. No
arguments needed. Pass them to `OiApp` and you are done.

```dart
OiApp(
  theme: OiThemeData.light(),
  darkTheme: OiThemeData.dark(),
  themeMode: OiThemeMode.system,
  home: const MyHomePage(),
)
```

This gives you the neutral ObersUI palette. Reach for it while you prototype, or
when the default look is fine as-is.

## Level 2: fromBrand()

`OiThemeData.fromBrand` takes your brand color and builds the rest around it. It
sets the color as the primary swatch, generates the light, dark, muted, and
foreground variants, and derives the focus border color to match. The other
semantic colors (success, warning, error, info) keep their defaults.

```dart
final theme = OiThemeData.fromBrand(color: Color(0xFF8B6914));
```

That single call is the whole setup. From here, every widget reads its colors
from the theme, so they all match your brand without extra work.

```dart
OiColumn(
  children: [
    OiLabel.title('Welcome'),
    OiButton.primary(label: 'Get started', onTap: () {}),
  ],
)
```

The button above is filled with your brand color. You did not pass a color to it.
It read `context.colors.primary.base` from the theme.

### Light and dark from one color

`fromBrand` defaults to `Brightness.light`. Pass `brightness: Brightness.dark`
for the dark variant. Use the same brand color for both and ObersUI handles the
surfaces, text colors, and contrast for each mode.

```dart
OiApp(
  theme: OiThemeData.fromBrand(
    color: Color(0xFF8B6914),
  ),
  darkTheme: OiThemeData.fromBrand(
    color: Color(0xFF8B6914),
    brightness: Brightness.dark,
  ),
  themeMode: OiThemeMode.system,
  home: const MyHomePage(),
)
```

### Factory options

`fromBrand` accepts the same optional parameters as `light()` and `dark()`. The
three you reach for most are the corner style and the two font families.

```dart
OiThemeData.fromBrand(
  color: Color(0xFF8B6914),
  radiusPreference: OiRadiusPreference.rounded,
  fontFamily: 'Poppins',
  monoFontFamily: 'Fira Code',
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `color` | `Color` | **required** | Your brand color. Becomes the primary swatch. |
| `brightness` | `Brightness` | `Brightness.light` | Set `Brightness.dark` for the dark theme. |
| `radiusPreference` | `OiRadiusPreference` | `medium` | Corner style. `sharp`, `medium`, or `rounded`. |
| `fontFamily` | `String?` | `null` | Font family for text. Uses the default when `null`. |
| `monoFontFamily` | `String?` | `null` | Font family for code and monospace text. |
| `components` | `OiComponentThemes?` | `null` | Per-widget theme overrides. |
| `performanceConfig` | `OiPerformanceConfig?` | `null` | Blur, shadow, and animation tuning. |
| `breakpoints` | `OiBreakpointScale?` | `null` | Custom responsive breakpoints. |

### Corner styles

`radiusPreference` controls the corner radius across every widget. Three levels:

```dart
OiThemeData.fromBrand(color: brand, radiusPreference: OiRadiusPreference.sharp)   // square corners
OiThemeData.fromBrand(color: brand, radiusPreference: OiRadiusPreference.medium)  // the default
OiThemeData.fromBrand(color: brand, radiusPreference: OiRadiusPreference.rounded) // pill-shaped
```

!!! note
    `fontFamily` and `monoFontFamily` name a font. They do not load it. Register
    the font in your `pubspec.yaml` (or through your platform) so Flutter can find
    it.

## When to go further

`fromBrand` derives every color from one input. If you need a specific success
green, a custom warning amber, or hand-tuned tokens, that is Level 3. Start from
`light()` or `dark()` and use `copyWith`. See
[Extending Themes](extending-themes.md) for the full walkthrough.

## Related

- [Color System](color-system.md) for the semantic color tokens and swatches.
- [Dark Mode](dark-mode.md) for switching modes at runtime.
- [Typography](typography.md) for text styles and font setup.
- [Extending Themes](extending-themes.md) for full token control with `copyWith`.
