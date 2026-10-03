# Typography

ObersUI ships one type scale with 14 named text styles. You do not build
`TextStyle` objects by hand. You render text with `OiLabel`, and each variant
reads its style from the active theme. This keeps every heading, paragraph, and
caption consistent, in light mode and dark mode.

## The type scale

`OiTextTheme` holds the 14 styles. Each one maps to an `OiLabelVariant` value
and to a named `OiLabel` constructor.

| Variant | Constructor | Size | Weight | Typical use |
| --- | --- | --- | --- | --- |
| `display` | `OiLabel.display()` | 56 | 700 | Hero and marketing text |
| `h1` | `OiLabel.h1()` | 40 | 700 | Page titles |
| `h2` | `OiLabel.h2()` | 32 | 600 | Section titles |
| `h3` | `OiLabel.h3()` | 24 | 600 | Subsection titles |
| `h4` | `OiLabel.h4()` | 20 | 600 | Card titles, group headers |
| `body` | `OiLabel.body()` | 16 | 400 | Default paragraph text |
| `bodyStrong` | `OiLabel.bodyStrong()` | 16 | 600 | Emphasized body text |
| `small` | `OiLabel.small()` | 14 | 400 | Secondary and helper text |
| `smallStrong` | `OiLabel.smallStrong()` | 14 | 600 | Emphasized small text |
| `tiny` | `OiLabel.tiny()` | 12 | 400 | Timestamps, dense UI |
| `caption` | `OiLabel.caption()` | 12 | 400 | Image captions, form hints |
| `code` | `OiLabel.code()` | 14 | 400 | Monospace code and IDs |
| `overline` | `OiLabel.overline()` | 11 | 600 | All-caps section markers |
| `link` | `OiLabel.link()` | 16 | 400 | Hyperlink-styled text |

!!! note
    The `display`, `h1`, and `h2` variants scale up on wider screens. They
    render at 1.0x on compact widths, 1.1x on medium, and 1.2x on expanded and
    larger. You get a bigger hero on desktop without any extra code.

## OiLabel

`OiLabel` is the primitive you use for all text. Reach for it instead of
Flutter's `Text`. It picks the right style, applies the theme text color, and
handles light and dark mode for you.

Use the named constructor that matches the variant you want.

```dart
OiColumn(
  children: [
    OiLabel.h1('Welcome'),
    OiLabel.body('This is the standard paragraph style.'),
    OiLabel.caption('A short note under the content.'),
  ],
)
```

### Named constructors

There is one constructor per variant. The text is the first positional
argument.

```dart
OiLabel.display('Hero line')
OiLabel.h1('Page title')
OiLabel.h2('Section header')
OiLabel.h3('Subsection header')
OiLabel.h4('Card title')
OiLabel.body('Paragraph text')
OiLabel.bodyStrong('Emphasized body')
OiLabel.small('Secondary text')
OiLabel.smallStrong('Emphasized small')
OiLabel.tiny('Dense UI text')
OiLabel.caption('Image caption')
OiLabel.code('const x = 1;')
OiLabel.overline('SECTION LABEL')
OiLabel.link('Read more')
```

### Pick a variant at runtime

Use `OiLabel.variant` when the style is chosen at runtime, for example from
configuration or user input. Pass the variant with the named `variant`
argument.

```dart
OiLabel.variant('Dynamic title', variant: OiLabelVariant.h3)
```

### Copyable values

Use `OiLabel.copyable` for read-only values a user often copies, like IDs, API
keys, URLs, or error codes. The text is selectable, and a copy affordance shows
on hover on desktop or long-press on mobile. It always renders in the `body`
style.

```dart
OiLabel.copyable('api_key_abc123')
```

!!! tip
    For a monospace look on a copyable ID, keep the value short and pair it with
    a nearby `OiLabel.code` heading. `OiLabel.copyable` itself is fixed to the
    `body` style. If you need selectable code text without the copy button, use
    `OiLabel.code('...', selectable: true)`.

### Attributes

These apply to every variant constructor. `OiLabel.copyable` accepts the same
set minus `decoration`, `decorationColor`, and `selectable`, which it sets for
you.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `String` | **required** | The text to render. First positional argument. |
| `variant` | `OiLabelVariant` | **required** for `OiLabel.variant` | The style token. Named constructors set it for you. |
| `maxLines` | `int?` | `null` | Line limit before overflow handling. |
| `overflow` | `TextOverflow?` | `null` | How to clip or fade overflowing text. |
| `textAlign` | `TextAlign?` | `null` | Horizontal alignment. |
| `copyable` | `bool` | `false` | Tap to copy the text to the clipboard. |
| `selectable` | `bool` | `false` | Let the user select and copy the text. |
| `semanticsLabel` | `String?` | `null` | Screen-reader text if it differs from `text`. |
| `color` | `Color?` | `null` | Overrides the variant text color. Use `context.colors`. |
| `decoration` | `TextDecoration?` | `null` | For example `TextDecoration.lineThrough`. |
| `decorationColor` | `Color?` | `null` | Color of the decoration. Only used with `decoration`. |

Color overrides come from the theme, never a hardcoded value.

```dart
OiLabel.body(
  'Deleted item',
  color: context.colors.error.base,
  decoration: TextDecoration.lineThrough,
)
```

## Reading a style directly

Most of the time you use `OiLabel`. When you need the raw `TextStyle`, read it
from the theme. Use `context.textTheme` for a named style, or `styleFor` to
look one up by variant.

```dart
final headingStyle = context.textTheme.h1;
final dynamicStyle = context.textTheme.styleFor(OiLabelVariant.h2);
```

## Setting the fonts

Pass `fontFamily` and `monoFontFamily` to the theme factory. `fontFamily`
applies to every style except `code`. `monoFontFamily` applies to `code` only.
When you omit them, both fall back to system defaults.

```dart
OiApp(
  theme: OiThemeData.light(
    fontFamily: 'Poppins',
    monoFontFamily: 'Fira Code',
  ),
  home: const HomeScreen(),
)
```

The same two arguments work on `OiThemeData.dark` and `OiThemeData.fromBrand`.

## Overriding individual styles

Build the standard scale, then use `copyWith` on `OiTextTheme` to replace single
styles. Pass the result to `OiThemeData`. This lets you keep the default scale
and change just the headings.

```dart
final base = OiThemeData.light();

final theme = base.copyWith(
  textTheme: OiTextTheme.standard(fontFamily: 'Inter').copyWith(
    h1: const TextStyle(
      fontFamily: 'Playfair Display',
      fontSize: 48,
      fontWeight: FontWeight.w700,
      height: 1.1,
    ),
  ),
);
```

`OiTextTheme.copyWith` accepts every one of the 14 styles as a named argument,
so you can override as few or as many as you need.

## Variant guidance

- Use `display` for hero sections. Use one per screen at most.
- Use `h1` for the page title, `h2` and `h3` for sections, and `h4` for card
  titles.
- Use `body` as the default. Use `bodyStrong` only to emphasize inside body
  copy.
- Use `small` and `smallStrong` for helper text. Use `tiny` only in dense UI.
- Use `overline` for compact all-caps labels and `caption` for media
  descriptions.
- Use `code` for inline code, tokens, and IDs. Use `link` for hyperlink text.

## Related

- [Color System](color-system.md) for the color scheme you pass to `color` overrides.
- [Design Tokens](tokens.md) for spacing, radius, and the rest of the theme.
- [Dark Mode](dark-mode.md) for switching brightness at runtime.

## Exact typography and inheritance

`OiTextTheme` accepts complete `TextStyle` values, including `fontVariations` and
`fontFeatures`. `OiTheme` now supplies a matching `DefaultTextStyle` to its subtree,
so ordinary text inside shared controls inherits the chosen font. Component text
styles merge over semantic typography; button and text-input themes can supply
specific value styles without losing variable-font axes.

Display/h1/h2 labels preserve their historic responsive scaling when
`headingScale` is omitted (1 below medium, 1.1 at medium, 1.2 at expanded). For an
exact authored scale, use `headingScale: const OiResponsive<double>(1)`. Other
explicit responsive scales use `OiResponsive.breakpoints`. System accessibility
text scaling continues to apply independently.

Per-size button heights are configurable through `smallHeight`, `mediumHeight`
and `largeHeight`; `height` remains a universal override. Text input `textStyle`,
height, content padding, radius and border states resolve through the component
theme. Explicit widget values take precedence over component theme values, which
fall back to semantic defaults.

With variable fonts, an explicit `FontVariation('wght', ...)` overrides
`TextStyle.fontWeight`, including later `copyWith(fontWeight: ...)` calls.
Use `fontWeight` alone for ordinary hundred-step weights so components can
apply semantic emphasis. Reserve the `wght` axis for exact intermediate weights
such as 560; width and other axes can remain explicit independently.
