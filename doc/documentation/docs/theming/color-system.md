# Color System

ObersUI colors are named by purpose, not by appearance. You reach for `primary`
when you mean the brand action, not "blue". This keeps your UI consistent and
makes light mode, dark mode, and rebranding a one-line change. Every color lives
in `OiColorScheme` and you read it from `context.colors`.

## OiColorScheme

`OiColorScheme` holds the full color palette for a theme. It has three kinds of
tokens: six semantic swatches, a set of flat surface, text, and border colors,
and an ordered list of chart colors. You rarely build one by hand. You use a
built-in factory and override the parts you care about.

```dart
// Read any color from the current theme.
Container(
  color: context.colors.surface,
  child: OiLabel.body(
    'On brand',
    color: context.colors.primary.base,
  ),
)
```

Two factories give you a ready palette:

```dart
OiColorScheme.light()   // light background, dark text
OiColorScheme.dark()    // near-black background, light text
```

!!! warning
    Never hardcode a `Color(0x...)` in a widget. Read from `context.colors` so
    your widget follows the theme and switches with dark mode. The only place a
    raw color belongs is when authoring theme tokens or passing a brand color into
    a swatch, shown below.

## Semantic swatches

Six swatches carry meaning. Pick one by intent.

| Swatch | Use it for |
| --- | --- |
| `primary` | Brand color, main actions, links, active states. |
| `accent` | Secondary emphasis and highlights. |
| `success` | Positive states and confirmations. |
| `warning` | Caution and attention. |
| `error` | Errors and destructive actions. |
| `info` | Neutral, informational feedback. |

Each swatch is an `OiColorSwatch`. That gives you five shades of one color:

```dart
context.colors.primary.base        // the main color
context.colors.primary.light       // lighter tint, for hover and backgrounds
context.colors.primary.dark        // darker shade, for pressed states
context.colors.primary.muted       // desaturated, for disabled or subtle fills
context.colors.primary.foreground  // black or white, readable on top of base
```

A common pattern is a colored chip with readable text on it. Use `base` for the
fill and `foreground` for the text, and they stay legible in any theme.

```dart
Container(
  padding: pad8,
  color: context.colors.success.base,
  child: OiLabel.small(
    'Paid',
    color: context.colors.success.foreground,
  ),
)
```

### OiColorSwatch

A single color with five shades. Build one from a base color and it derives the
rest. `light` and `dark` shift lightness by 20 percent, `muted` desaturates and
lightens, and `foreground` picks black or white for contrast.

```dart
final gold = OiColorSwatch.from(const Color(0xFF8B6914));
// gold.light, gold.dark, gold.muted, gold.foreground are filled in for you.
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `base` | `Color` | **required** | The main shade. |
| `light` | `Color` | **required** | Lighter tint for backgrounds and hover. |
| `dark` | `Color` | **required** | Darker shade for pressed and active states. |
| `muted` | `Color` | **required** | Desaturated shade for disabled or subtle fills. |
| `foreground` | `Color` | **required** | Black or white, readable over `base`. |

The `from` factory fills all five from one color:

| Constructor | Description |
| --- | --- |
| `OiColorSwatch.from(Color base)` | Derives `light`, `dark`, `muted`, and `foreground` from `base` using HSL math. |
| `OiColorSwatch.lerp(a, b, t)` | Interpolates between two swatches. Used by theme animation. |

You can also start from a derived swatch and fix one shade with `copyWith`:

```dart
final swatch = OiColorSwatch.from(const Color(0xFF8B6914))
    .copyWith(foreground: const Color(0xFFFFFFFF));
```

## Perceptual color arithmetic

`OiOklab`, `OiOklch`, `OiColorMix`, and `OiHueInterpolation` are opt-in numeric
helpers, exported by `package:obers_ui/obers_ui.dart`. They do not change the HSL
`OiColorSwatch.from` factory, `OiThemeData.fromBrand`, or existing theme defaults.

```dart
const violet = OiOklch(lightness: 0.525, chroma: 0.118, hue: 283);
final white = OiOklch.fromColor(const Color(0xFFFFFFFF));
final softened = OiColorMix.oklch(violet, white, secondPercent: 20);
final displayColor = softened.toSrgbClipped();

final lab = violet.toOklab();
final xyz = lab.toXyzD65(); // named record: x, y, z; D65 reference white Y=1
final luminance = lab.relativeLuminance; // uncomposited XYZ Y, not alpha-weighted
final dimmed = lab.scaleLuminance(0.5); // scales all XYZ axes, preserves opacity
```

Lightness is conventionally 0–1, but raw conversions retain out-of-gamut values.
Chroma is nonnegative. Constructors assert finite coordinates and opacity in
0–1. Hue is in degrees and may be any finite angle; `null` represents missing
hue. Converting an achromatic Oklab value to OKLCH gives a missing hue when its
chroma is at most 0.000004. An explicitly authored numeric hue is kept, including
at zero chroma. Mixing carries a single missing hue from the other color.

`OiColorMix.oklch` defaults to the shorter hue arc; choose `longer`, `increasing`,
or `decreasing` through `OiHueInterpolation`. It premultiplies lightness and
chroma by alpha, but not hue. `OiColorMix.oklab` premultiplies all three axes;
`OiColorMix.srgb` works in gamma-encoded sRGB, not linear-light RGB. Display P3
inputs are converted before sRGB mixing or Oklab conversion.

Percentages are 0–100. Omitting both gives 50/50; omitting one complements the
other. A sum above 100 is normalized; a sum below 100 additionally reduces the
result's alpha. Invalid percentages and negative/nonfinite luminance factors
throw `ArgumentError`. A 0%/0% sum returns a transparent midpoint as specified
by the current [CSS Color 5 draft](https://www.w3.org/TR/css-color-5/#color-mix);
older browser implementations may still reject that CSS declaration.

`toColor()` returns extended sRGB without clipping. `toSrgbClipped()` explicitly
clips each RGB channel to 0–1 while retaining alpha. Channel clipping is not the
perceptual display-gamut mapping described by
[CSS Color 4](https://www.w3.org/TR/css-color-4/#gamut-mapping); do not clip
intermediate values before mixing or luminance scaling. These are numeric
helpers, not a CSS parser: only hue has a missing-component representation.
Conversion matrices, transfer functions, and alpha/hue interpolation follow
[CSS Color 4](https://www.w3.org/TR/css-color-4/#color-conversion-code).

## Explicit semantic groups and generic branding

`OiThemeData.semanticColors` is an optional, immutable `OiSemanticColors`.
Current widgets continue reading `colors`; adding semantic metadata does not
change a component or a legacy default. Opt-in applications read
`theme.resolvedSemanticColors`, which projects the current legacy scheme when
no explicit groups are present.

| Group | Explicit roles |
| --- | --- |
| `OiSurfaceColors` | `canvas`, `sheet`, `well`, `overlaySurface`, `line`, `lineStrong`, `border`, `hoverWash`, `pressedWash`, `scrim`, `inverse` |
| `OiInkColors` | `primary`, `muted`, `subtle`, `onInverse`, `inverseMuted` |
| `OiRoleColors` | `base`, `onColor`, `ink`, `soft`; optional `hover`, `pressed`, `softHover` |
| `OiRailColors` | `surface`, `ink`, `hoverWash`, `line`, `active`, `onActive`, `badge`, `onBadge` |
| `OiChartColors` | six named categorical slots, `muted`, `positive`, `middle`, `negative`; optional `sequential` |
| `OiSemanticColors` | the groups above, primary/secondary/highlight/info roles, `focus`, optional `focusHalo` |

`overlaySurface` is a content surface, never a backdrop. The legacy
`OiColorScheme.overlay` remains the translucent `scrim`. In the fallback,
`textSubtle` maps to semantic `inks.muted` and `textMuted` to `inks.subtle`.
`OiLegacySemanticColors.fromScheme` maps legacy accent to both secondary and
highlight, swatch dark/muted to ink/soft, and light/dark to hover/pressed.
Legacy surface hover/active values are retained, even when opaque. An absent
sequential ramp or focus halo remains absent. Short chart lists are snapshotted
with primary/accent/success/warning/error/info filling absent slots.

All groups have const constructors, value equality, `copyWith`, and named
`lerp` constructors with exact endpoints and finite 0–1 fractions. `OiColorRamp`
stores six named colors, not a mutable list. Its `colors` view and chart
`categorical` view are unmodifiable. Optional fields remain unchanged when
omitted; explicit clear flags remove them and take precedence over supplied
values. Theme `merge` retains semantic metadata when the incoming theme has none.

`OiBrandPalette.derive` is a separate, pure, opt-in perceptual engine. It derives
the three brand roles, tinted neutral surfaces/inks/info, a dark rail, focus
ink/halo, three categorical slots, a six-color sequential ramp and positive/
middle/muted chart colors. It does not generate success/warning/error swatches,
categorical slots four–six, divergent negative, shadows or a focus-ring recipe.
It is not a substitute for a hand-tuned preset.
`OiBrandCharts.derive` exposes the same chart-only subset independently.

```dart
final base = OiThemeData.light();
final brand = OiBrandPalette.derive(
  primary: const OiOklch(lightness: 0.525, chroma: 0.118, hue: 283),
  secondary: const OiOklch(lightness: 0.8, chroma: 0.058, hue: 222),
  highlight: const OiOklch(lightness: 0.87, chroma: 0.078, hue: 76),
  tint: const OiOklch(lightness: 0.5, chroma: 0.03, hue: 280),
  brightness: Brightness.light,
);
final themed = base.copyWith(
  semanticColors: brand.applyTo(base.resolvedSemanticColors),
);
final panel = themed.resolvedSemanticColors.surfaces.overlaySurface;
final legacyAgain = themed.copyWith(clearSemanticColors: true);
```

RGB and XYZ enter through `OiOklch.fromColor` and
`OiOklab.fromXyzD65(...).toOklch()`. Derived values are raw extended sRGB, not
automatically gamut mapped or composited. Relative recipes inherit the source's
opacity; washes and halos have explicit opacity. Tint defaults to primary;
numeric authored hue survives zero chroma. Missing hue becomes numeric zero
only when conversion to RGB requires it. Neutral info fill/soft are tinted,
but `applyTo` preserves the base info foreground/ink/interaction colors.
Secondary/highlight interaction colors, chart slots four–six and the negative
divergent endpoint are also preserved from the explicitly supplied base.

The engine uses uncomposited XYZ-D65 luminance. Its threshold helper is
`clamp(v * 100000, 0, 1)`, a continuous 1e-5 transition, not a Boolean test.
Primary hover/press use OKLab interpolation toward exact D65
XYZ `(0.95047, 1, 1.08883)` or black. Light ink caps chroma before luminance
scaling; dark ink scales first, then caps. No intermediate channel clipping
is performed. Numerical source vectors and browser probes use explicit
tolerances: browser matrix/8-bit rounding can differ by a byte near boundaries.

`OiSemanticColors.lerp` mixes raw gamma-encoded sRGB with premultiplied alpha.
It returns exact endpoints, carries a sole authored optional color/ramp, and
rejects fractions outside finite 0–1. Theme interpolation uses this path only
when either endpoint has semantic metadata; two legacy themes retain their
existing interpolation and null metadata.

## Surface, text, and border tokens

These are flat `Color` values, not swatches. They cover backgrounds, text, and
lines. Read them the same way, for example `context.colors.background`.

| Token | Type | Use it for |
| --- | --- | --- |
| `background` | `Color` | The page background behind everything. |
| `surface` | `Color` | Card, panel, and container fills. |
| `surfaceHover` | `Color` | A surface under the pointer. |
| `surfaceActive` | `Color` | A surface being pressed. |
| `surfaceSubtle` | `Color` | Faint fills like zebra rows and sidebars. |
| `overlay` | `Color` | The semi-transparent backdrop behind modals and drawers. |
| `text` | `Color` | Primary text, the highest contrast. |
| `textSubtle` | `Color` | Secondary text. |
| `textMuted` | `Color` | Placeholders and captions. |
| `textInverse` | `Color` | Text on an inverted surface. |
| `textOnPrimary` | `Color` | Text placed directly on `primary.base`. |
| `border` | `Color` | Default borders and dividers. |
| `borderSubtle` | `Color` | Lighter borders. |
| `borderFocus` | `Color` | The keyboard focus ring. |
| `borderError` | `Color` | A field border in an error state. |
| `glassBackground` | `Color` | The fill for frosted-glass surfaces. |
| `glassBorder` | `Color` | The border for frosted-glass surfaces. |

A plain card uses `surface` for the fill, `border` for the edge, and `text` for
the content:

```dart
Container(
  padding: pad16,
  decoration: BoxDecoration(
    color: context.colors.surface,
    border: Border.all(color: context.colors.border),
    borderRadius: BorderRadius.circular(8),
  ),
  child: OiColumn(
    children: [
      OiLabel.h4('Card title', color: context.colors.text),
      OiLabel.small('Details', color: context.colors.textSubtle),
    ],
  ),
)
```

## Chart colors

`chart` is an ordered `List<Color>` with eight categorical colors. Use it to
color series in charts and data views, in order, so the first series always gets
the same color.

```dart
final colors = context.colors.chart;
// colors[0], colors[1], ... up to colors[7]

for (var i = 0; i < series.length; i++) {
  paintSeries(series[i], colors[i % colors.length]);
}
```

!!! tip
    Cycle with the modulo operator (`i % colors.length`) so more than eight
    series still get a color instead of an out-of-range error.

## Overriding colors

Change a scheme with `copyWith`. You pass only the tokens you want to replace.
Everything else stays as it was. The most common change is swapping the brand
color for your own.

```dart
OiThemeData.light().copyWith(
  colors: OiColorScheme.light().copyWith(
    primary: OiColorSwatch.from(const Color(0xFF8B6914)),
    background: const Color(0xFFFFFBF5),
  ),
)
```

`copyWith` on `OiColorScheme` accepts every token: the six swatches, all surface,
text, and border colors, `glassBackground`, `glassBorder`, and `chart`. Swatches
take an `OiColorSwatch`. The flat tokens take a `Color`. `chart` takes a
`List<Color>`.

```dart
OiColorScheme.dark().copyWith(
  error: OiColorSwatch.from(const Color(0xFFD48A66)),
  border: const Color(0xFF374151),
  chart: const [
    Color(0xFF7AB8E0),
    Color(0xFFF0D86A),
    Color(0xFF92C4AA),
  ],
)
```

To brand a whole app in one place, override `primary` and `accent` on both the
light and dark schemes, then pass them into `OiApp`. See
[Quick Brand](quick-brand.md) for the shortest path.

## Related

- [Design Tokens](tokens.md) for spacing, radius, and elevation.
- [Typography](typography.md) for the text styles you pair with these colors.
- [Dark Mode](dark-mode.md) for how the two schemes swap at runtime.
- [Quick Brand](quick-brand.md) for the fastest way to apply your brand color.
