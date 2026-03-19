# Theming Overview

ObersUI uses a **token-based design system**. Every visual decision — color, spacing, font size, border radius, shadow, animation duration — comes from a theme token, not a hardcoded value.

## How it works

1. `OiApp` injects an `OiThemeData` into the widget tree
2. All widgets read their visual properties from this theme
3. You customize the theme — every widget updates automatically

```dart
OiApp(
  theme: OiThemeData.light(),   // or .dark(), or .fromBrand()
  home: const MyHomePage(),
)
```

## Accessing the theme

Inside any widget, use `BuildContext` extensions:

```dart
final colors = context.colors;      // OiColorScheme
final text = context.textTheme;     // OiTextTheme
final space = context.spacing;      // OiSpacingScale
final radii = context.radius;       // OiRadiusScale
```

No `Theme.of(context)` wrappers needed. Just `context.colors`, `context.spacing`, etc.

## What's in a theme?

`OiThemeData` aggregates all design tokens:

| Token | Class | What it controls |
|---|---|---|
| Colors | `OiColorScheme` | Semantic colors (primary, accent, success, warning, error, info), surfaces, text, borders |
| Typography | `OiTextTheme` | 14 text styles (display, h1-h4, body, small, tiny, caption, code, overline, link) |
| Spacing | `OiSpacingScale` | 6 spacing values (xs=4, sm=8, md=16, lg=24, xl=32, xxl=48) + page gutters |
| Radius | `OiRadiusScale` | Border radii with preference (sharp, medium, rounded) |
| Shadows | `OiShadowScale` | Elevation-based shadows |
| Animations | `OiAnimationConfig` | Durations (fast=150ms, normal=250ms, slow=400ms) + reduced motion |
| Effects | `OiEffectsTheme` | Hover, focus, active, press visual feedback |
| Decoration | `OiDecorationTheme` | Border styles (solid, dashed, dotted, gradient) |
| Components | `OiComponentThemes` | Per-widget theme overrides |

## Three levels of customization

### Level 1: Just works (beginner)

Use the built-in light or dark theme:

```dart
OiThemeData.light()
OiThemeData.dark()
```

### Level 2: Brand it (intermediate)

One color in, full theme out:

```dart
OiThemeData.fromBrand(color: Color(0xFF8B6914))
```

### Level 3: Full control (advanced)

Override any token:

```dart
OiThemeData.light().copyWith(
  colors: OiColorScheme.light().copyWith(
    primary: OiColorSwatch.from(Color(0xFF8B6914)),
  ),
  textTheme: OiTextTheme.standard(fontFamily: 'Poppins'),
)
```

For the full theming guide, see [Theming](../theming/index.md).
