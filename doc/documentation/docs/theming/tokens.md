# Design Tokens

Design tokens are the shared units behind every widget. They cover spacing,
corner radius, shadows, motion, interactive effects, and borders. Widgets read
these tokens from the theme, so a change in one place updates the whole app.
This page lists every token family and shows how to read it.

You reach tokens in two ways. Most of the time you read them from the theme with
`context.spacing`, `context.radius`, `context.shadows`, and friends. These
respect any per-theme override. For fixed layout code that has no `BuildContext`,
obers_ui also ships a set of top-level constants like `s16` and `gapH16`. The
last section covers those.

| Family | Access | Type |
| --- | --- | --- |
| Spacing | `context.spacing` | `OiSpacingScale` |
| Radius | `context.radius` | `OiRadiusScale` |
| Shadows | `context.shadows` | `OiShadowScale` |
| Animations | `context.animations` | `OiAnimationConfig` |
| Effects | `context.effects` | `OiEffectsTheme` |
| Decoration | `context.decoration` | `OiDecorationTheme` |

## Spacing

The spacing scale follows a 4dp base grid. Each step roughly doubles the last.
Use it for padding, margins, and gaps.

| Token | Value | Use case |
| --- | --- | --- |
| `xs` | 4dp | Tight internal gaps, icon spacing |
| `sm` | 8dp | Element gaps, compact padding |
| `md` | 16dp | Default padding, standard gaps |
| `lg` | 24dp | Section padding |
| `xl` | 32dp | Page sections, large separators |
| `xxl` | 48dp | Major section separators, hero spacing |

Read a value from the theme with `context.spacing`.

```dart
Padding(
  padding: EdgeInsets.all(context.spacing.md), // 16dp
  child: OiLabel.body('Padded content'),
)
```

The scale also holds page gutter values that change per breakpoint. They run
from `pageGutterCompact` (16dp) up to `pageGutterExtraLarge` (48dp). Layout
widgets use these to keep page margins consistent across screen sizes.

### Custom spacing

Override single steps with `copyWith` when you build the theme.

```dart
OiThemeData.light().copyWith(
  spacing: OiSpacingScale.standard().copyWith(
    md: 12, // tighter default spacing
    lg: 20,
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `xs` | `double` | `4` | Extra-small gap. |
| `sm` | `double` | `8` | Small gap. |
| `md` | `double` | `16` | Medium gap. Default padding. |
| `lg` | `double` | `24` | Large gap. |
| `xl` | `double` | `32` | Extra-large gap. |
| `xxl` | `double` | `48` | Double extra-large gap. |
| `pageGutterCompact` | `double` | `16` | Page margin below 600dp. |
| `pageGutterMedium` | `double` | `24` | Page margin 600 to 840dp. |
| `pageGutterExpanded` | `double` | `32` | Page margin 840 to 1200dp. |
| `pageGutterLarge` | `double` | `40` | Page margin 1200 to 1600dp. |
| `pageGutterExtraLarge` | `double` | `48` | Page margin above 1600dp. |

## Radius

Radius tokens come as a scale. One preference shifts the whole scale at once, so
you set the app's overall roundness in a single place. Each token resolves to a
`BorderRadius`.

Set the preference when you build the theme.

```dart
OiThemeData.light(radiusPreference: OiRadiusPreference.rounded)
```

The three preferences map to these values:

| Token | `sharp` | `medium` (default) | `rounded` |
| --- | --- | --- | --- |
| `none` | 0 | 0 | 0 |
| `xs` | 0 | 2 | 4 |
| `sm` | 0 | 4 | 8 |
| `md` | 0 | 8 | 12 |
| `lg` | 0 | 12 | 20 |
| `xl` | 0 | 16 | 24 |
| `full` | 0 | 9999 | 9999 |

The `full` token gives a pill shape. Use it for badges, tags, and toggle pills.
Note that under `sharp` every token is `0`, including `full`, so everything has
square corners.

Read a value from the theme with `context.radius`.

```dart
Container(
  decoration: BoxDecoration(
    color: context.colors.surface.base,
    borderRadius: context.radius.md,
  ),
  child: OiLabel.body('Rounded box'),
)
```

!!! tip
    Set the preference once and let it flow. Do not hardcode a `Radius.circular`
    value per widget. That breaks the single roundness setting.

## Shadows

Shadow tokens give depth by elevation. Each key resolves to a
`List<BoxShadow>`. The scale has a light and a dark variant, so shadows stay
visible on both backgrounds. The active theme picks the right one for you.

| Token | Use case |
| --- | --- |
| `none` | No shadow. An empty list. |
| `xs` | Subtle lift for small interactive elements. |
| `sm` | Dropdowns and tooltips. |
| `md` | Default for cards and inputs. |
| `lg` | Modals and popovers. |
| `xl` | Full-screen overlays and side sheets. |
| `glass` | Soft ambient shadow for frosted-glass surfaces. |

Read a value from the theme with `context.shadows`.

```dart
Container(
  decoration: BoxDecoration(
    color: context.colors.surface.base,
    borderRadius: context.radius.md,
    boxShadow: context.shadows.md,
  ),
  child: OiLabel.body('Card with medium elevation'),
)
```

## Animations

`OiAnimationConfig` holds motion tokens. It covers three named durations plus
the settings for page transitions.

| Token | Value | Use case |
| --- | --- | --- |
| `fast` | 150ms | Micro-interactions like hover and toggle. |
| `normal` | 250ms | Standard transitions. |
| `slow` | 400ms | Large layout changes. |

Read a duration from the theme with `context.animations`.

```dart
AnimatedContainer(
  duration: context.animations.normal,
  color: context.colors.primary.base,
)
```

### Page transitions

The same config sets how routes animate. `OiPageRoute` reads these values.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `defaultPageTransition` | `OiPageTransitionType` | `fade` | The transition used by `OiPageRoute`. |
| `pageTransitionDuration` | `Duration` | `250ms` | How long the transition runs. |
| `pageEntryCurve` | `Curve` | `Curves.easeOutCubic` | Curve for the incoming page. |
| `pageExitCurve` | `Curve` | `Curves.easeInCubic` | Curve for the outgoing page. |

`OiPageTransitionType` has five values: `fade`, `slideHorizontal`,
`slideVertical`, `scaleUp`, and `none`.

### Reduced motion

`reducedMotion` collapses `fast`, `normal`, `slow`, and the page transition to
`Duration.zero`. It is a constructor argument, not runtime magic. Wire it up
yourself when you build the theme, usually from
`MediaQuery.of(context).disableAnimations`.

```dart
OiAnimationConfig.standard(
  reducedMotion: MediaQuery.of(context).disableAnimations,
)
```

## Effects

`OiEffectsTheme` describes the visual feedback for each interactive state. Every
state maps to an `OiInteractiveStyle`, which holds a background overlay, an
optional halo glow, and a scale transform. `OiTappable` and all interactive
widgets read these, so you rarely touch them directly.

| State | When it applies |
| --- | --- |
| `hover` | Pointer is over the widget. |
| `focus` | Widget has keyboard focus. |
| `active` | Widget is pressed. Scales to 0.97 by default. |
| `selected` | Widget is selected or checked. Used by toggles and lists. |
| `dragging` | Widget is being dragged. |
| `disabled` | Widget is disabled. |

The theme also holds a `focusRing`. The focus ring always renders on keyboard
focus, on its own, so no config can hide it. That keeps keyboard users able to
see where they are.

You get the effects theme from `context.effects`. Most apps only override it to
change the halo color, and even that flows from the primary color by default.

```dart
OiThemeData.light().copyWith(
  effects: OiEffectsTheme.standard(
    primaryColor: context.colors.primary.base,
  ),
)
```

## Decoration

`OiDecorationTheme` holds the border and gradient styles. Inputs and containers
read the three border states from it. The gradients map holds named gradients
that components can pull by key.

| Field | Type | Description |
| --- | --- | --- |
| `defaultBorder` | `OiBorderStyle` | Border on unfocused, non-error elements. |
| `focusBorder` | `OiBorderStyle` | Border when an element has focus. |
| `errorBorder` | `OiBorderStyle` | Border when an element has a validation error. |
| `gradients` | `Map<String, OiGradientStyle>` | Named gradients, keyed by name. |

`OiBorderStyle` has named factories: `solid`, `dashed`, `dotted`, `gradient`,
and `none`. Each takes a color and width. `OiGradientStyle` has `linear` and
`radial` factories that take a list of colors.

```dart
OiThemeData.light().copyWith(
  decoration: OiDecorationTheme.standard(
    primaryColor: context.colors.primary.base,
    errorColor: context.colors.error.base,
  ).copyWith(
    defaultBorder: OiBorderStyle.solid(
      context.colors.border.base,
      1,
      borderRadius: context.radius.md,
    ),
  ),
)
```

## Quick-access constants

For layout code that runs without a `BuildContext`, obers_ui ships top-level
`const` values. The number in each name is the dp value. These do not respond to
theme overrides. They are fixed.

| Family | Constants | Expands to | Example |
| --- | --- | --- | --- |
| Sizes | `s0` to `s128` | a `double` | `SizedBox(width: s64)` |
| Vertical gaps | `gapH0` to `gapH64` | `SizedBox(height: n)` | `gapH16` between column children |
| Horizontal gaps | `gapW0` to `gapW64` | `SizedBox(width: n)` | `gapW8` between row children |
| Padding, all sides | `pad4` to `pad48` | `EdgeInsets.all(n)` | `Padding(padding: pad16, ...)` |
| Padding, horizontal | `padX4` to `padX32` | `EdgeInsets.symmetric(horizontal: n)` | `Padding(padding: padX24, ...)` |
| Padding, vertical | `padY4` to `padY32` | `EdgeInsets.symmetric(vertical: n)` | `Padding(padding: padY16, ...)` |
| Shrink | `shrink` | `SizedBox.shrink()` | A zero-size box. |

Available sizes: `s0` `s1` `s2` `s4` `s6` `s8` `s10` `s12` `s14` `s16` `s20`
`s24` `s28` `s32` `s36` `s40` `s44` `s48` `s56` `s64` `s72` `s80` `s96` `s128`.

The gap widgets use these sizes. Use a vertical gap between column children and a
horizontal gap between row children.

```dart
OiColumn(
  children: [
    header,
    gapH16,
    body,
    gapH24,
    footer,
  ],
)
```

Some constants line up with the spacing scale. The mapping is `s4` = xs,
`s8` = sm, `s16` = md, `s24` = lg, `s32` = xl, `s48` = xxl. The gap and padding
families follow the same numbers, so `gapH16` and `pad16` also match `md`.

### Which one to use

- Use `context.spacing.md` when spacing should follow per-theme overrides. This
  is the default choice inside widgets.
- Use `s16`, `gapH16`, or `pad16` for fixed layout that never changes with the
  theme, and for `const` widget trees where you have no `BuildContext`.

!!! note
    The constants are handy, but they skip the theme. If you build a design that
    users can retheme, prefer `context.spacing` so their overrides take effect.

## Related

- [Color System](color-system.md) for the color scheme and swatches.
- [Typography](typography.md) for the text theme and `OiLabel`.
- [Component Themes](component-themes.md) for per-widget visual overrides.
