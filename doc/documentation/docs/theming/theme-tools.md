# Theme Tools

ObersUI ships a few helpers for building and inspecting themes. You export a
theme to JSON or Dart, generate a theme from one brand color, preview a theme
before you ship it, and browse components in a sandbox. These are development
aids. You reach for them in a theme builder, a design tool, or the example app,
not in production screens.

| Tool | What it does |
| --- | --- |
| `OiThemeExporter` | Turns a theme into JSON or Dart code, and reads it back. |
| `OiDynamicTheme` | Builds a full theme from a single brand color at runtime. |
| `OiThemePreview` | Renders sample components so you can eyeball a theme. |
| `OiPlayground` | A component sandbox with a light and dark toggle. |

## OiThemeExporter

A static utility that serializes an `OiThemeData`. Use it to save a theme, share
it, or generate Dart source you paste into a project. It cannot be instantiated.
You call its static methods directly.

```dart
// Theme to JSON string.
final json = OiThemeExporter.toJson(context.theme);

// JSON string back to a theme. Malformed input falls back to the light theme.
final theme = OiThemeExporter.fromJson(json);

// Theme to Dart source code you can paste into a file.
final dart = OiThemeExporter.toDart(context.theme, variableName: 'brandTheme');
```

The JSON covers every token: colors, text styles, spacing, radius, shadows,
animations, effects, and decoration. It does not include per-component theme
overrides. Import rebuilds the theme with `OiComponentThemes.empty()`.

| Method | Returns | Description |
| --- | --- | --- |
| `toJson(theme)` | `String` | Indented JSON for the whole theme. |
| `toMap(theme)` | `Map<String, dynamic>` | The same data as a map. |
| `fromJson(json)` | `OiThemeData` | Parses JSON. Falls back to `OiThemeData.light()` on bad input. |
| `fromMap(map)` | `OiThemeData` | Builds a theme from a map. Missing fields use light defaults. |
| `toDart(theme, {variableName})` | `String` | Valid Dart source that recreates the theme. `variableName` defaults to `'theme'`. |

!!! note
    Round-tripping a theme through the exporter drops component-level overrides.
    Colors, typography, and the other tokens survive.

## OiDynamicTheme

A static utility that builds a complete theme from one brand color. It wraps
`OiThemeData.fromBrand`. Use it when a user picks a color and you want a matching
theme without hand-tuning every token.

```dart
// One color to a full light theme.
final theme = OiDynamicTheme.fromColor(context.colors.primary.base);

// Matching light and dark themes from the same color.
final pair = OiDynamicTheme.fromColorPair(context.colors.accent.base);
// pair.light and pair.dark are both OiThemeData.
```

| Method | Returns | Description |
| --- | --- | --- |
| `fromColor(color, {brightness, fontFamily, radiusPreference})` | `OiThemeData` | One theme from a brand color. |
| `fromColorPair(color, {fontFamily, radiusPreference})` | `({OiThemeData light, OiThemeData dark})` | Light and dark themes as a record. |
| `fromSeedColor(seedColor, {brightness})` | `OiThemeData` | A theme from a seed color. |

The `brightness` parameter defaults to `Brightness.light`. The
`radiusPreference` parameter defaults to `OiRadiusPreference.medium`. The other
options are `sharp` and `rounded`.

```dart
final theme = OiDynamicTheme.fromColor(
  context.colors.primary.base,
  brightness: Brightness.dark,
  radiusPreference: OiRadiusPreference.rounded,
);
```

## OiThemePreview

A widget that renders sample components in a theme you pass in. Use it in a theme
builder to check a theme before you apply it. It wraps its samples in the given
theme, so the preview is independent of the surrounding app theme.

```dart
OiThemePreview(
  theme: OiThemeData.light(),
)
```

You can hide sections you do not care about. Every section flag is on by default.

```dart
OiThemePreview(
  theme: myTheme,
  showColors: true,
  showTypography: true,
  showButtons: true,
  showInputs: false,
  showBadges: false,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `theme` | `OiThemeData` | **required** | The theme to render. |
| `showColors` | `bool` | `true` | Show the color palette section. |
| `showTypography` | `bool` | `true` | Show the type samples section. |
| `showSpacing` | `bool` | `true` | Show the spacing scale section. |
| `showButtons` | `bool` | `true` | Show button variant samples. |
| `showInputs` | `bool` | `true` | Show input samples. |
| `showCards` | `bool` | `true` | Show card variant samples. |
| `showBadges` | `bool` | `true` | Show badge samples. |
| `showProgress` | `bool` | `true` | Show progress indicators. |

## OiPlayground

A widget that browses components by category, with a light and dark toggle in the
header. It is meant for the example app or a local development tool, not a
shipped screen.

```dart
OiPlayground()
```

Pass your own themes and pick the starting category.

```dart
OiPlayground(
  theme: OiThemeData.light(),
  darkTheme: OiThemeData.dark(),
  initialCategory: 'Inputs',
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `theme` | `OiThemeData?` | `OiThemeData.light()` | The light theme to browse. |
| `darkTheme` | `OiThemeData?` | `OiThemeData.dark()` | The theme used when the dark toggle is on. |
| `initialCategory` | `String?` | first category | Which category opens first. |

The categories are `Buttons`, `Inputs`, `Display`, `Feedback`, `Overlays`, and
`Navigation`.

## Related

- [Quick Brand Setup](quick-brand.md) for building a theme from one color.
- [Color System](color-system.md) for the swatches these tools serialize.
- [Design Tokens](tokens.md) for spacing, radius, and the other exported values.
- [Component Themes](component-themes.md) for the overrides the exporter skips.
