# Core Ideas

ObersUI has a handful of small conventions that repeat everywhere. Read this page
once and the rest of the docs will make sense. None of it is hard. It is the same
few rules applied to every widget.

| Convention | What it means |
| --- | --- |
| `Oi` prefix | Every public class starts with `Oi`. |
| Named constructors | Variants are named constructors, like `OiButton.primary`. |
| `OiLabel` for text | Show text with `OiLabel`, never raw `Text`. |
| `OiRow` / `OiColumn` / `OiGrid` | Lay out with Oi primitives, not `Row` / `Column` / `GridView`. |
| Theme tokens | Read colors, spacing, and radius from `context`. |
| Accessibility labels | Interactive widgets need a `label` or `semanticLabel`. |
| No Material | No `MaterialApp`, `Scaffold`, or `AppBar`. |

## The Oi prefix

Every public class in the library starts with `Oi`. Buttons, labels, cards,
dialogs, layouts, everything. When you look for a widget, type `Oi` and let
autocomplete show you the options.

```dart
OiButton.primary(label: 'Save', onTap: () {})
OiCard(child: OiLabel.body('Hello'))
OiBadge.soft(label: 'New')
```

If a name does not start with `Oi`, it is not part of the public API.

## Variants are named constructors

Most widgets have no default constructor. You pick a variant with a named
constructor instead. The variant carries the intent, so you do not pass a `type`
or `style` enum yourself.

```dart
OiButton.primary(label: 'Save', onTap: () {})     // main action
OiButton.destructive(label: 'Delete', onTap: () {}) // dangerous action
OiBadge.soft(label: 'Draft')                        // muted badge
OiBadge.filled(label: 'Live')                       // filled badge
```

The same pattern covers text (`OiLabel.h1`, `OiLabel.body`) and many other
widgets. When you want a variant, look for a named constructor first.

## Text uses OiLabel, not Text

Never use the raw `Text` widget. Use `OiLabel` and pick a variant that matches
the role of the text. Each variant pulls its size, weight, and color from the
theme, so headings and body copy stay consistent.

```dart
OiLabel.h1('Account settings')
OiLabel.body('Update your profile and preferences.')
```

The first argument is always the string. Every variant is a named constructor.

### Label variants

| Constructor | Use it for |
| --- | --- |
| `OiLabel.display` | The largest hero text. |
| `OiLabel.h1` to `OiLabel.h4` | Section headings, largest to smallest. |
| `OiLabel.body` | Default paragraph text. |
| `OiLabel.bodyStrong` | Body text with more weight. |
| `OiLabel.small` / `OiLabel.smallStrong` | Secondary and dense text. |
| `OiLabel.tiny` | The smallest readable text. |
| `OiLabel.caption` | Captions under images or fields. |
| `OiLabel.overline` | Short uppercase eyebrow labels. |
| `OiLabel.code` | Inline monospace code. |
| `OiLabel.link` | Tappable link text. |
| `OiLabel.copyable` | Text with a copy affordance. |
| `OiLabel.variant` | Pass an `OiLabelVariant` when the variant is dynamic. |

Common options on every variant:

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `text` | `String` | **required** | The text to show. It is the first positional argument. |
| `maxLines` | `int?` | `null` | Clamp to a number of lines. |
| `overflow` | `TextOverflow?` | `null` | How to handle overflow, such as ellipsis. |
| `textAlign` | `TextAlign?` | `null` | Horizontal alignment. |
| `selectable` | `bool` | `false` | Let the user select the text. |
| `color` | `Color?` | `null` | Override the color. Pass a theme color, not a literal. |
| `semanticsLabel` | `String?` | `null` | Screen-reader text when it differs from `text`. |

## Layout uses OiRow, OiColumn, and OiGrid

Do not use `Row`, `Column`, or `GridView`. Use `OiRow`, `OiColumn`, and `OiGrid`.
They take a `breakpoint` and a responsive `gap`, so spacing adapts to screen size
and you get responsive collapse without extra code.

```dart
OiColumn(
  breakpoint: context.breakpoint,
  gap: const OiResponsive<double>(16),
  children: [
    OiLabel.h2('Profile'),
    OiLabel.body('Manage your account details.'),
  ],
)
```

`OiRow` works the same way, laying children out horizontally. `OiGrid` arranges
children in a responsive grid.

```dart
OiGrid(
  breakpoint: context.breakpoint,
  columns: 3,
  gap: const OiResponsive<double>(12),
  children: [
    OiCard(child: OiLabel.body('One')),
    OiCard(child: OiLabel.body('Two')),
    OiCard(child: OiLabel.body('Three')),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `breakpoint` | `OiBreakpoint` | **required** | The active breakpoint. Usually `context.breakpoint`. |
| `children` | `List<Widget>` | **required** | The items to lay out. |
| `gap` | `OiResponsive<double>` | `OiResponsive<double>(0)` | Space between children, per breakpoint. |
| `columns` | `int?` | `null` | `OiGrid` only. Fixed column count. |
| `minColumnWidth` | `double?` | `null` | `OiGrid` only. Auto-fit columns by width. Use instead of `columns`. |

!!! note
    `context.breakpoint` reads the current breakpoint from the theme and viewport.
    Pass it straight into the `breakpoint` field.

## Theme tokens, never hardcoded values

Read colors, spacing, and corner radius from the theme through `context`. Never
write a `Color(0xFF...)` or a magic number like `16` for a color or padding. The
tokens change with light and dark mode and with your brand, so hardcoded values
break theming.

```dart
OiSurface(
  color: context.colors.surface,
  padding: EdgeInsets.all(context.spacing.md),
  borderRadius: BorderRadius.circular(context.radius.md),
  child: OiLabel.body(
    'Themed panel',
    color: context.colors.text,
  ),
)
```

Three accessors cover the common cases:

| Accessor | Gives you | Example |
| --- | --- | --- |
| `context.colors` | The color scheme. | `context.colors.primary.base`, `context.colors.surface`, `context.colors.text` |
| `context.spacing` | The spacing scale. | `context.spacing.sm`, `context.spacing.md`, `context.spacing.lg` |
| `context.radius` | The corner radius scale. | `context.radius.sm`, `context.radius.md`, `context.radius.full` |

Color swatches like `primary` expose `base`, `light`, `dark`, `muted`, and
`foreground`. Spacing and radius run from `xs` up through `xl` and beyond.

## Interactive widgets need a label

Every widget a user can tap, toggle, or type into needs a `label` or a
`semanticLabel`. This is not optional. It is how screen readers describe the
control. For text buttons the visible `label` doubles as the accessible name. For
icon-only controls you pass a `semanticLabel`, since there is no visible text.

```dart
// Visible text acts as the accessible name.
OiButton.primary(label: 'Save', onTap: () {})

// Icon-only, so the label lives in semanticLabel.
OiIconButton(
  icon: OiIcons.edit,
  semanticLabel: 'Edit',
  onTap: () {},
)
```

If you cannot think of a label, that is usually a sign the control is unclear.

## No Material dependency

ObersUI is built from scratch. It does not depend on Material or Cupertino. So do
not reach for `MaterialApp`, `Scaffold`, `AppBar`, or `BottomNavigationBar`. Wrap
your app in `OiApp` and build screens from Oi widgets.

```dart
OiApp(
  theme: OiThemeData.fromBrand(color: const Color(0xFF8B6914)),
  home: OiPage(
    breakpoint: OiBreakpoint.compact,
    children: [
      OiLabel.h1('Hello, ObersUI'),
      OiButton.primary(label: 'Get started', onTap: () {}),
    ],
  ),
)
```

Use `OiPage` and `OiSection` for screen structure, `OiBottomBar` for bottom
navigation, and page headers for the top bar. There is no Material widget to fall
back on, and you do not need one.

!!! warning
    Do not import `package:flutter/material.dart` for widgets. Importing it pulls
    in a second design system that will not match your theme. The brand color in
    `OiThemeData.fromBrand(color:)` is the one place a raw `Color` is expected.

## Related

- [Quick Start](quick-start.md) for a first running app.
- [Installation](installation.md) to add the package.
- [Project Structure](project-structure.md) for how the library is organized.
- [Flex layout](../layout/flex.md) and [Grid](../layout/grid.md) for more on `OiRow`, `OiColumn`, and `OiGrid`.
- [Buttons & Actions](../widgets/buttons.md) for the button variants in depth.
