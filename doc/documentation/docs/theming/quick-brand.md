# Quick Brand Setup

The whipped cream approach — one ingredient, full richness.

## One line, full theme

```dart
final theme = OiThemeData.fromBrand(color: Color(0xFF8B6914));
```

That's it. `fromBrand` takes your brand color and:

- Sets it as the **primary** color swatch
- Generates **light, dark, muted, and foreground** variants automatically
- Derives **focus border** color from your brand
- Keeps all other semantic colors (success, warning, error, info) at their defaults
- Applies matching **effects** (hover, focus, active states)

## Light and dark from one color

```dart
OiApp(
  theme: OiThemeData.fromBrand(
    color: Color(0xFF8B6914),
  ),
  darkTheme: OiThemeData.fromBrand(
    color: Color(0xFF8B6914),
    brightness: Brightness.dark,
  ),
  themeMode: OiThemeMode.system,
  home: const MyHomePage(),
)
```

Same brand color, two themes. The library adjusts surfaces, text colors, and contrast automatically.

## Optional tweaks

`fromBrand` accepts the same optional parameters as the standard factories:

```dart
OiThemeData.fromBrand(
  color: Color(0xFF8B6914),
  fontFamily: 'Poppins',           // Custom font
  monoFontFamily: 'Fira Code',     // Custom code font
  radiusPreference: OiRadiusPreference.rounded, // Rounder corners
)
```

## When to use fromBrand

- You have a brand color and want everything to "just work"
- You're prototyping and don't want to pick colors yet
- You want consistent light/dark themes with minimal effort

## When to go deeper

If you need to control individual semantic colors (like a custom success green or a specific warning amber), head to [Color System](color-system.md).
