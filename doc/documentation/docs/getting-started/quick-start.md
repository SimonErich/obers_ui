# Your First App

Let's get something on screen. This page builds a small ObersUI app step by
step. You start with the smallest app that runs, add a brand color, then grow it
into a real screen. Every step uses widgets you will reach for every day.

## The mental model

`OiApp` sits at the root of your app. It injects the theme into the widget tree.
Every widget below it reads its colors, spacing, and corner radius from that
theme. So you set your colors once at the top, and the whole app stays
consistent. You never pass a color down by hand.

## The smallest app

Three widgets get you running. `OiApp` at the root, an `OiPage` for the layout,
and some content inside it.

```dart
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

void main() {
  runApp(
    OiApp(
      theme: OiThemeData.light(),
      home: OiPage(
        breakpoint: OiBreakpoint.compact,
        padding: const OiResponsive(EdgeInsets.all(24)),
        gap: const OiResponsive(16),
        children: [
          OiLabel.h1('Hello, ObersUI'),
          OiButton.primary(
            label: 'Get started',
            onTap: () {},
          ),
        ],
      ),
    ),
  );
}
```

`OiApp` replaces `MaterialApp` and `CupertinoApp`. There is no `MaterialApp`
anywhere in an ObersUI app.

!!! note "OiButton has only named constructors"
    There is no unnamed `OiButton(...)`. Pick a variant: `OiButton.primary`,
    `OiButton.secondary`, `OiButton.outline`, `OiButton.ghost`,
    `OiButton.destructive`, or `OiButton.soft`. The tap callback is `onTap`, not
    `onPressed`.

### OiPage

`OiPage` is your outermost layout widget. It stacks its `children` in a column,
adds optional `padding` and `gap`, and fills the space it is given. It asks for a
`breakpoint` so the layout is explicit. Resolve it once with `context.breakpoint`
and pass it down, or use a fixed value like `OiBreakpoint.compact` while you get
started.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `breakpoint` | `OiBreakpoint` | **required** | The active breakpoint. `compact`, `medium`, or `expanded`. |
| `children` | `List<Widget>` | **required** | The widgets to stack vertically. |
| `gap` | `OiResponsive<double>` | `0` | Vertical space between children. |
| `padding` | `OiResponsive<EdgeInsetsGeometry>?` | `null` | Padding around the content. |
| `crossAxisAlignment` | `CrossAxisAlignment` | `stretch` | How children align across the page width. |
| `mainAxisSize` | `MainAxisSize` | `max` | `max` fills the height. Use `min` when nesting. |

!!! tip
    `gap` and `padding` take `OiResponsive` values so they can change per
    breakpoint. Wrap a single value like `OiResponsive(16)` when you want the
    same value everywhere.

## Add a brand color

You do not have to configure every color. Pass one brand color to
`OiThemeData.fromBrand` and it builds a full theme around it.

```dart
OiApp(
  theme: OiThemeData.fromBrand(color: Color(0xFF8B6914)),
  home: OiPage(
    breakpoint: OiBreakpoint.compact,
    padding: const OiResponsive(EdgeInsets.all(24)),
    gap: const OiResponsive(16),
    children: [
      OiLabel.h1('Hello, ObersUI'),
      OiButton.primary(label: 'Get started', onTap: () {}),
    ],
  ),
)
```

`fromBrand` sets your color as the primary swatch. It derives the `light`,
`dark`, `muted`, and `foreground` variants for you. It also uses your color for
the focus ring and interactive-state effects. The other semantic swatches
(`accent`, `success`, `warning`, `error`, `info`) keep their defaults. Override
them through the [Color System](../theming/color-system.md) if you need brand
values there too.

This is one of the few places you write a raw `Color`. Everywhere else, colors
come from the theme.

## A slightly richer screen

Now put some content in a card. `OiCard` groups related content on a surface.
Inside it, `OiColumn` stacks a few labels and a button. `OiColumn` also needs a
`breakpoint`, so resolve it once at the top of `build` and reuse it.

```dart
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bp = context.breakpoint;

    return OiPage(
      breakpoint: bp,
      padding: const OiResponsive(EdgeInsets.all(24)),
      children: [
        OiCard(
          title: OiLabel.h3('Welcome'),
          child: OiColumn(
            breakpoint: bp,
            gap: const OiResponsive(12),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OiLabel.body('This card reads its colors and padding from the theme.'),
              OiLabel.small('Change the brand color once and everything updates.'),
              OiButton.primary(label: 'Continue', onTap: () {}),
            ],
          ),
        ),
      ],
    );
  }
}
```

`OiCard.title` takes a widget, so pass an `OiLabel`, not a plain string. Use
`OiLabel` for every piece of text. It picks the right size, weight, and color
from the theme.

## Read the theme in your own widgets

Inside any widget under `OiApp`, reach for theme tokens through `BuildContext`
extensions. You get colors, text styles, and spacing without threading anything
through constructors.

```dart
@override
Widget build(BuildContext context) {
  final colors = context.colors;   // OiColorScheme
  final space = context.spacing;   // OiSpacingScale

  return Padding(
    padding: EdgeInsets.all(space.md),   // 16dp
    child: OiLabel.h2(
      'Smooth like Obers',
      color: colors.primary.base,
    ),
  );
}
```

The most common getters:

| Extension | Returns |
| --- | --- |
| `context.colors` | `OiColorScheme` |
| `context.textTheme` | `OiTextTheme` |
| `context.spacing` | `OiSpacingScale` |
| `context.radius` | `OiRadiusScale` |
| `context.breakpoint` | `OiBreakpoint` |
| `context.components` | `OiComponentThemes` |

## Add dark mode

Give `OiApp` both a light and a dark theme, then let the system pick.

```dart
OiApp(
  theme: OiThemeData.fromBrand(color: Color(0xFF8B6914)),
  darkTheme: OiThemeData.fromBrand(
    color: Color(0xFF8B6914),
    brightness: Brightness.dark,
  ),
  themeMode: OiThemeMode.system,
  home: const WelcomeScreen(),
)
```

`themeMode` takes `OiThemeMode.light`, `OiThemeMode.dark`, or
`OiThemeMode.system`. The default is `system`. When you leave `darkTheme` out,
`OiApp` uses `theme` for both modes.

## Run the example app

The repository ships an example app. It is the fastest way to see the widgets
running.

```bash
cd example
flutter run
```

## Related

- [Project Structure](project-structure.md) for how the code is organized.
- [Color System](../theming/color-system.md) for the full set of color tokens.
- [Buttons & Actions](../widgets/buttons.md) for every button variant.
