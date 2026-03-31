# Quick Start

Let's get something on screen. The entry point for every ObersUI app is `OiApp`.

## The simplest app

```dart
import 'package:obers_ui/obers_ui.dart';

void main() {
  runApp(
    OiApp(
      theme: OiThemeData.light(),
      home: Center(
        child: OiButton(
          label: 'Hello, Obers!',
          onPressed: () {},
        ),
      ),
    ),
  );
}
```

`OiApp` replaces `MaterialApp`. It injects the theme, accessibility services, overlay management, keyboard shortcuts, and more — all in one widget.

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

## Brand it in one line

Don't want to configure every color? Use `fromBrand` — one color in, full theme out:

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

The library derives all semantic colors (primary, accent, success, warning, error) from your brand color automatically.

## Use a router

For apps using declarative routing (like `go_router`):

```dart
OiApp.router(
  theme: OiThemeData.light(),
  darkTheme: OiThemeData.dark(),
  themeMode: OiThemeMode.system,
  routerConfig: goRouter,
)
```

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

All ObersUI widgets are prefixed with **`Oi`** to avoid naming conflicts with Flutter's built-in widgets. `OiButton` instead of `Button`, `OiCard` instead of `Card`, and so on.

## Next step

Now that your app is running, learn [how the project is organized](project-structure.md) or dive into [Core Concepts](../core-concepts/index.md).
