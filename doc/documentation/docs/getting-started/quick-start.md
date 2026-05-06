# Quick Start

Let's get something on screen. The entry point for every ObersUI app is
`OiApp`.

## The simplest app

```dart
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

void main() {
  runApp(
    OiApp(
      theme: OiThemeData.light(),
      home: Center(
        child: OiButton.primary(
          label: 'Hello, Obers!',
          onTap: () {},
        ),
      ),
    ),
  );
}
```

`OiApp` replaces `MaterialApp` / `CupertinoApp`. It injects the theme,
accessibility scope, platform data, input-modality detection, overlay
management, undo stack, keyboard-shortcut scope, tour scope, density
scope, and optional settings persistence — all in one widget.

!!! note "OiButton has only named constructors"
    There is no unnamed `OiButton(...)` constructor. Use
    `OiButton.primary`, `OiButton.secondary`, `OiButton.outline`,
    `OiButton.ghost`, `OiButton.destructive`, or `OiButton.soft`.
    The callback parameter is `onTap:`, not `onPressed:`.

## Add dark mode

Provide both a light and dark theme, and let the system decide:

```dart
OiApp(
  theme: OiThemeData.light(),
  darkTheme: OiThemeData.dark(),
  themeMode: OiThemeMode.system,
  home: const MyHomePage(),
)
```

`themeMode` accepts `OiThemeMode.light`, `OiThemeMode.dark`, or
`OiThemeMode.system` (default).

## Brand it in one line

Don't want to configure every color? Use `fromBrand` — one color in, a
full theme out:

```dart
OiApp(
  theme: OiThemeData.fromBrand(color: Color(0xFF8B6914)),
  darkTheme: OiThemeData.fromBrand(
    color: Color(0xFF8B6914),
    brightness: Brightness.dark,
  ),
  themeMode: OiThemeMode.system,
  home: const MyHomePage(),
)
```

`fromBrand` sets your colour as the **primary swatch** (deriving
`light` / `dark` / `muted` / `foreground` variants automatically) and
uses it for the focus border, interactive-state effects, and decoration
accents. The other semantic swatches (`accent`, `success`, `warning`,
`error`, `info`) keep their factory defaults — override them via
[Color System](../theming/color-system.md) if you need specific brand
values there too.

## Use a router

For apps using declarative routing (e.g. `go_router`), construct `OiApp`
with the router-aware named constructor:

```dart
OiApp.router(
  theme: OiThemeData.light(),
  darkTheme: OiThemeData.dark(),
  themeMode: OiThemeMode.system,
  routerConfig: goRouter,
)
```

The default and `.router` constructors share the same parameters apart
from `home` vs. `routerConfig`.

## Common `OiApp` parameters

Beyond `theme` / `home`, the most useful fields:

| Parameter | Type | Purpose |
| --- | --- | --- |
| `density` | `OiDensity?` | Information density (`comfortable`, `compact`, `dense`). When `null`, auto-detected from the platform. |
| `settingsDriver` | `OiSettingsDriver?` | Enables per-widget persistence (see [Settings Persistence](../settings/index.md)). |
| `performanceConfig` | `OiPerformanceConfig?` | Overrides the theme's performance knobs (animations, effects budget). |
| `undoStackMaxHistory` | `int` | Size of the shared undo stack (default 50). |
| `locale`, `supportedLocales`, `localizationsDelegates` | — | Standard Flutter localisation plumbing. |
| `title` | `String` | App title (for task switchers / tab titles). |

## Access the theme

Inside any widget, use the `BuildContext` extensions:

```dart
@override
Widget build(BuildContext context) {
  final colors = context.colors;    // OiColorScheme
  final text = context.textTheme;   // OiTextTheme
  final space = context.spacing;    // OiSpacingScale

  return Padding(
    padding: EdgeInsets.all(space.md),  // 16dp
    child: Text(
      'Smooth like Obers',
      style: text.h2.copyWith(color: colors.primary.base),
    ),
  );
}
```

All theme tokens are available via these getters:

| Extension | Returns |
| --- | --- |
| `context.theme` | Full `OiThemeData` |
| `context.colors` | `OiColorScheme` |
| `context.textTheme` | `OiTextTheme` |
| `context.spacing` | `OiSpacingScale` |
| `context.radius` | `OiRadiusScale` |
| `context.shadows` | `OiShadowScale` |
| `context.effects` | `OiEffectsTheme` |
| `context.animations` | `OiAnimationConfig` |
| `context.decoration` | `OiDecorationTheme` |
| `context.components` | `OiComponentThemes` |

## The `Oi` prefix

All ObersUI widgets are prefixed with **`Oi`** to avoid naming conflicts
with Flutter's built-in widgets. `OiButton` instead of `Button`, `OiCard`
instead of `Card`, and so on.

## Next step

Now that your app is running, learn [how the project is organized](project-structure.md)
or dive into [Core Concepts](../core-concepts/index.md).
