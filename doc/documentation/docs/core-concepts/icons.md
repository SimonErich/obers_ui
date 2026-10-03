# Icons

ObersUI ships with [Lucide](https://lucide.dev) v0.577.0, an open-source icon set
of 1,950+ glyphs embedded as a font. There are no external dependencies and no
network requests. You reach for icons through two things: the `OiIcons` class,
which holds every glyph as a named constant, and the `OiIcon` widget, which draws
one on screen.

| Piece | What it does |
| --- | --- |
| `OiIcons` | A static class of 1,950+ `IconData` constants. You never draw it, you pick from it. |
| `OiIcon` | The widget that renders a glyph with the right size, color, and accessibility semantics. |

## OiIcons

`OiIcons` is a static class. Every icon is a `static const` field on it, so you
reference glyphs by name and let the compiler catch typos.

```dart
OiIcon(icon: OiIcons.search, label: 'Search')
```

Names use camelCase, converted from Lucide's kebab-case. Numbers in a Lucide name
stay in the constant.

```dart
OiIcons.chevronLeft   // chevron-left
OiIcons.arrowRight    // arrow-right
OiIcons.fileText      // file-text
OiIcons.circleCheck   // circle-check
OiIcons.trash2        // trash-2
```

There are too many icons to list here. Browse the full catalog at
[lucide.dev/icons](https://lucide.dev/icons), find the name you want, and convert
it to camelCase.

!!! warning "Always use OiIcons.xxx, never Material Icons.xxx"
    ObersUI has zero Material dependency. Material's `Icons.xxx` glyphs are not
    available and will not render. Every icon you use comes from `OiIcons`. This
    is the single most common icon mistake, so check your imports.

### Categories

The constants are grouped by purpose. These are a few from each group to give you
a feel for the naming. The full set is far larger.

| Category | A few constants |
| --- | --- |
| Arrows and navigation | `chevronLeft`, `chevronRight`, `arrowUp`, `arrowDown`, `externalLink`, `undo2`, `redo2` |
| Actions | `plus`, `minus`, `x`, `check`, `search`, `download`, `upload`, `copy`, `trash2`, `squarePen` |
| Files and folders | `file`, `fileText`, `filePlus`, `folder`, `folderOpen`, `archive`, `clipboardList` |
| Media and communication | `image`, `video`, `music`, `play`, `mail`, `messageSquare`, `phone`, `bell` |
| Users and people | `user`, `users`, `userPlus`, `circleUser` |
| Status and feedback | `circleCheck`, `circleAlert`, `triangleAlert`, `info`, `circleHelp`, `ban` |
| Layout and display | `menu`, `layoutGrid`, `columns3`, `table`, `list`, `slidersHorizontal`, `ellipsis` |
| Data and charts | `barChart3`, `pieChart`, `trendingUp`, `trendingDown`, `presentation` |
| Devices and hardware | `monitor`, `server`, `database`, `cpu`, `hardDrive` |
| Appearance | `sun`, `moon`, `eye`, `eyeOff`, `sparkles`, `palette` |
| Objects and symbols | `star`, `heart`, `house`, `mapPin`, `shoppingCart`, `creditCard`, `tag`, `rocket`, `zap` |

## OiIcon

`OiIcon` draws a single glyph. Reach for it any time you show an icon on its own.
It takes a `label` for screen readers, so a meaningful icon is never silent to
assistive tech. For a purely visual glyph, use the `OiIcon.decorative` constructor
instead, which drops the label and hides the icon from the accessibility tree.

```dart
// Meaningful icon: announced by screen readers.
OiIcon(icon: OiIcons.lock, label: 'Locked')

// Decorative icon: hidden from the accessibility tree.
OiIcon.decorative(icon: OiIcons.chevronRight)
```

### Size and color

`size` is in logical pixels. When you leave it out, `OiIcon` uses the body font
size from the active theme, so icons line up with body text by default. `color`
defaults to `context.colors.text`. Pull any override from the theme, do not
hardcode a hex value.

```dart
OiIcon(
  icon: OiIcons.star,
  label: 'Favorite',
  size: 24,
  color: context.colors.primary.base,
)
```

You can lay icons out like any other widget.

```dart
OiRow(
  children: [
    OiIcon(icon: OiIcons.circleCheck, label: 'Done', color: context.colors.success.base),
    OiLabel.body('Task complete'),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `icon` | `OiIconData` | **required** | The glyph to draw. Use a constant from `OiIcons`. `OiIconData` is a typedef for `IconData`. |
| `label` | `String` | **required** | Screen-reader text. Not shown on screen. Omitted by `OiIcon.decorative`. |
| `size` | `double?` | `null` | Size in logical pixels. Falls back to the theme body font size. |
| `color` | `Color?` | `null` | Glyph color. Falls back to `context.colors.text`. |

!!! note
    `OiIcon.decorative` takes the same `icon`, `size`, and `color`, but no
    `label`. Use it for glyphs that repeat a nearby text label, like a chevron in
    an accordion header.

## Icons in other widgets

Most ObersUI widgets that take an icon accept a raw `OiIcons` constant, not an
`OiIcon` widget. The widget builds the `OiIcon` for you and sizes it to match.

Buttons take an `icon` parameter directly.

```dart
OiButton.primary(
  label: 'Download',
  icon: OiIcons.download,
  onTap: () {},
)

// Icon-only button. The label becomes the screen-reader text.
OiIconButton(
  icon: OiIcons.settings,
  semanticLabel: 'Settings',
  onTap: () {},
)
```

Text inputs place a glyph on the leading or trailing edge. The `leading` and
`trailing` slots take a widget, so pass an `OiIcon`. The `OiTextInput.search`
constructor already puts a search glyph in the leading slot for you.

```dart
// Built-in search field with a leading OiIcons.search.
OiTextInput.search(
  onChanged: (value) => runSearch(value),
)

// A custom leading glyph on a labeled field.
OiTextInput(
  label: 'Email',
  leading: OiIcon.decorative(icon: OiIcons.mail),
  onChanged: (value) => setEmail(value),
)
```

## Related

- [Buttons and Actions](../widgets/buttons.md) for `OiButton` and `OiIconButton`.
- [Theming](theming.md) for `context.colors` and the values `OiIcon` reads.

## Theme-selected vector sources

Every built-in icon renders through `OiIcon`, including shell, input and button
icons. Existing `IconData` tokens and `OiIcons` constants remain valid. Set
`components.icon` to `OiIconThemeData(sources: {...})` to replace tokens with local
`OiIconSource.svg(markup)`, `OiIconSource.asset(path, package: ...)`, or
`OiIconSource.font(glyph)` sources. Unmapped tokens keep their font glyphs.

SVG sources retain their authored geometry (including stroke width), resolve
`currentColor`, and receive the component's size/color. The shared renderer uses
`flutter_svg`; applications do not need custom painters or per-control adapters.
Use non-const maps for `IconData` keys, while source values can be const. Decorative
icons stay outside the accessibility tree; meaningful icons retain their labels.
