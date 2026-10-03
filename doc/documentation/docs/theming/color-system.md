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
    raw color belongs is when you pass a brand color into a swatch, shown below.

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
