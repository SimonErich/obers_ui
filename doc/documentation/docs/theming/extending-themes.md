# Extending Themes

This is the full-control path. You start from a built-in theme and override
exactly the tokens you want. Everything else keeps its default. You can also
swap the theme for one part of the tree, and read the whole theme back in code.

Reach for this page when `OiThemeData.fromBrand` (see [Quick Brand
Setup](quick-brand.md)) does not give you enough control. For example when you
need exact brand colors, a custom font, or tighter spacing.

## The three levels

ObersUI themes come in three levels of effort. This page covers level three.

```dart
// Level 1: the defaults.
OiThemeData.light()
OiThemeData.dark()

// Level 2: one brand color, full palette derived for you.
OiThemeData.fromBrand(color: Color(0xFF8B6914))

// Level 3: full control, override any token.
OiThemeData.light().copyWith(
  colors: OiColorScheme.light().copyWith(primary: myPrimary),
  textTheme: OiTextTheme.standard(fontFamily: 'Inter'),
)
```

## copyWith on OiThemeData

`OiThemeData` is immutable. To change it, call `copyWith` and pass only the
tokens you want to replace. Each token you leave out keeps its current value.

```dart
final theme = OiThemeData.light().copyWith(
  spacing: OiSpacingScale.standard(),
  radius: OiRadiusScale.forPreference(OiRadiusPreference.rounded),
);
```

`copyWith` is shallow. It replaces a whole token object, not a field inside it.
To change one color, you build a new `OiColorScheme` first, then pass it. The
next sections show how.

| Parameter | Type | Description |
| --- | --- | --- |
| `brightness` | `Brightness` | Light or dark. |
| `colors` | `OiColorScheme` | All color tokens. |
| `textTheme` | `OiTextTheme` | The type scale. |
| `spacing` | `OiSpacingScale` | Spacing tokens. |
| `radius` | `OiRadiusScale` | Corner radius tokens. |
| `shadows` | `OiShadowScale` | Elevation shadows. |
| `animations` | `OiAnimationConfig` | Durations and curves. |
| `effects` | `OiEffectsTheme` | Hover, focus, and active states. |
| `decoration` | `OiDecorationTheme` | Borders and gradients. |
| `components` | `OiComponentThemes` | Per-widget overrides. See [Component Themes](component-themes.md). |
| `fontFamily` | `String?` | Default font family. |
| `monoFontFamily` | `String?` | Monospace font family. |

## Replacing colors

Colors live in `OiColorScheme`. Start from `OiColorScheme.light()` or
`OiColorScheme.dark()`, then call its own `copyWith`. Feed the result into the
theme's `copyWith`.

### Keep semantic decorations consistent

Token groups are independent. `copyWith(colors: ...)` preserves existing
`decoration`, `effects` and component overrides, including their explicit
colors. When replacing a complete palette, derive these groups together:

```dart
final base = OiThemeData.light();
final colors = base.colors.copyWith(
  primary: myPrimary,
  error: myError,
  borderFocus: myFocusColor,
);
final theme = base.copyWith(
  colors: colors,
  decoration: OiDecorationTheme.standard(
    primaryColor: colors.primary.base,
    errorColor: colors.error.base,
  ),
  effects: OiEffectsTheme.standard(
    primaryColor: colors.primary.base,
    focusColor: colors.borderFocus,
  ),
);
```

If you already have custom border geometry or gradients, use
`base.decoration.copyWith(errorBorder: ...)` to replace only the relevant
semantic border. Component overrides such as
`OiTextInputThemeData.validationErrorColor` retain priority. `fromBrand`
constructs the palette and its standard decorations/effects together.

### One color from a hex value

A swatch is one semantic color with five shades: `base`, `light`, `dark`,
`muted`, and `foreground`. Use `OiColorSwatch.from` to derive all five from a
single brand color. This is the common case.

```dart
final theme = OiThemeData.light().copyWith(
  colors: OiColorScheme.light().copyWith(
    primary: OiColorSwatch.from(const Color(0xFF8B6914)),
  ),
);
```

`OiColorSwatch.from` computes `light` and `dark` by shifting lightness, `muted`
by desaturating, and picks a `foreground` (black or white) that stays readable
on `base`.

### Exact shades

When your brand kit gives you every shade, pass them yourself with the
`OiColorSwatch` constructor. Nothing is derived.

```dart
const brandPrimary = OiColorSwatch(
  base: Color(0xFF8B6914),
  light: Color(0xFFB8923D),
  dark: Color(0xFF5E460D),
  muted: Color(0xFFD9C79A),
  foreground: Color(0xFFFFFFFF),
);

final theme = OiThemeData.light().copyWith(
  colors: OiColorScheme.light().copyWith(primary: brandPrimary),
);
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `base` | `Color` | **required** | The main shade. |
| `light` | `Color` | **required** | Lighter variant, for backgrounds and hover. |
| `dark` | `Color` | **required** | Darker variant, for pressed and active. |
| `muted` | `Color` | **required** | Desaturated variant, for disabled or subtle use. |
| `foreground` | `Color` | **required** | Text or icon color that sits on `base`. |

### Surfaces and text colors

`OiColorScheme` also holds flat `Color` tokens for surfaces, text, borders, and
the chart palette. Override them the same way.

```dart
final colors = OiColorScheme.light().copyWith(
  background: const Color(0xFFFAF7F0),
  surface: const Color(0xFFFFFFFF),
  border: const Color(0xFFE6DFCF),
  chart: const [
    Color(0xFF8B6914),
    Color(0xFF3D6B7A),
    Color(0xFF7A9D54),
  ],
);
```

See [Color System](color-system.md) for the full token list.

!!! note
    Hardcoded `Color(0x...)` values belong in theme setup, like the examples
    above. Inside widgets, always read colors from `context.colors`, never a
    literal.

## Replacing the font

`OiTextTheme.standard` builds the full type scale. Pass `fontFamily` to set the
font for every text style, and `monoFontFamily` for code text.

```dart
final theme = OiThemeData.light().copyWith(
  textTheme: OiTextTheme.standard(
    fontFamily: 'Inter',
    monoFontFamily: 'JetBrains Mono',
  ),
);
```

To change one style and keep the rest, call `copyWith` on the text theme with a
plain `TextStyle`.

```dart
final textTheme = OiTextTheme.standard(fontFamily: 'Inter').copyWith(
  h1: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700, height: 1.1),
);
```

See [Typography](typography.md) for the list of variants.

## Nested token scales

Spacing and radius are token scales too. Build a new scale, then pass it to
`copyWith`. This example tightens the base spacing grid.

```dart
final theme = OiThemeData.light().copyWith(
  spacing: const OiSpacingScale(
    xs: 2,
    sm: 6,
    md: 12,
    lg: 20,
    xl: 28,
    xxl: 40,
    pageGutterCompact: 12,
    pageGutterMedium: 20,
    pageGutterExpanded: 28,
    pageGutterLarge: 36,
    pageGutterExtraLarge: 44,
  ),
);
```

Radius has three presets. Pick one with `OiRadiusScale.forPreference`, or build
an `OiRadiusScale` by hand for full control.

```dart
// A preset: sharp, medium, or rounded.
OiRadiusScale.forPreference(OiRadiusPreference.rounded)

// Every corner set by hand.
const OiRadiusScale(
  none: BorderRadius.zero,
  xs: BorderRadius.all(Radius.circular(3)),
  sm: BorderRadius.all(Radius.circular(6)),
  md: BorderRadius.all(Radius.circular(10)),
  lg: BorderRadius.all(Radius.circular(14)),
  xl: BorderRadius.all(Radius.circular(20)),
  full: BorderRadius.all(Radius.circular(9999)),
)
```

See [Design Tokens](tokens.md) for the meaning of each step.

## A complete branded theme

Here is a full light theme for one brand: a custom primary, a matching accent,
softer surfaces, a custom font, and rounded corners. Pass it to `OiApp`.

```dart
OiThemeData brandTheme() {
  final colors = OiColorScheme.light().copyWith(
    primary: OiColorSwatch.from(const Color(0xFF8B6914)),
    accent: OiColorSwatch.from(const Color(0xFF3D6B7A)),
    background: const Color(0xFFFAF7F0),
    surfaceSubtle: const Color(0xFFF3EEE2),
    border: const Color(0xFFE6DFCF),
  );

  return OiThemeData.light().copyWith(
    colors: colors,
    textTheme: OiTextTheme.standard(fontFamily: 'Inter'),
    radius: OiRadiusScale.forPreference(OiRadiusPreference.rounded),
  );
}

// Wire it up at the root.
OiApp(
  theme: brandTheme(),
  darkTheme: OiThemeData.dark(),
  themeMode: OiThemeMode.system,
  home: const HomeScreen(),
)
```

## Overriding the theme for a subtree

Sometimes one section needs a different theme. A partner panel, a preview pane,
or a marketing hero. Wrap that part of the tree in `OiThemeScope`. Everything
inside it uses the new theme. The rest of the app stays on the app theme.

```dart
OiThemeScope(
  data: brandTheme(),
  child: const PartnerPanel(),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `OiThemeData` | **required** | The theme for the subtree. |
| `child` | `Widget` | **required** | The subtree that receives it. |

A common pattern is to read the current theme, tweak it, and scope the result.
This keeps the section in step with the app while changing one thing.

```dart
OiThemeScope(
  data: OiTheme.of(context).copyWith(
    colors: OiTheme.of(context).colors.copyWith(
      primary: OiColorSwatch.from(const Color(0xFF3D6B7A)),
    ),
  ),
  child: const PreviewPane(),
)
```

`OiThemeScope` wraps `OiTheme`, the inherited widget that carries the theme. You
can use `OiTheme` directly if you prefer, but `OiThemeScope` reads clearer.

```dart
OiTheme(
  data: brandTheme(),
  child: const PartnerPanel(),
)
```

## Reading the theme in code

Inside a widget, read the whole theme with `OiTheme.of(context)`. It returns the
nearest `OiThemeData`, which is the app theme or the closest scope override.

```dart
@override
Widget build(BuildContext context) {
  final theme = OiTheme.of(context);

  return OiColumn(
    children: [
      OiLabel.h3('Current mode: ${theme.isDark ? 'dark' : 'light'}'),
      OiRow(
        children: [
          OiButton.primary(label: 'Save', onTap: save),
          OiButton.outline(label: 'Cancel', onTap: cancel),
        ],
      ),
    ],
  );
}
```

For a single token, the `context` getters are shorter. They call
`OiTheme.of(context)` for you.

```dart
final colors = context.colors;     // OiColorScheme
final spacing = context.spacing;   // OiSpacingScale
final radius = context.radius;     // OiRadiusScale
final text = context.textTheme;    // OiTextTheme

OiSurface(
  color: context.colors.surface,
  borderRadius: context.radius.md,
  child: OiLabel.body('Inside a themed surface'),
)
```

!!! tip
    Reach for `context.colors` and friends in day-to-day widget code. Reach for
    `OiTheme.of(context)` when you need several tokens at once, or a top-level
    value like `brightness`, `isDark`, or `fontFamily`.

## Related

- [Quick Brand Setup](quick-brand.md) for the one-color shortcut.
- [Color System](color-system.md) for every color token.
- [Design Tokens](tokens.md) for spacing, radius, and shadow scales.
- [Typography](typography.md) for the text variants.
- [Component Themes](component-themes.md) for per-widget overrides.
- [Dark Mode](dark-mode.md) for light and dark switching.
