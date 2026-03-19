# Dark Mode

ObersUI has first-class dark mode support. Both built-in themes (light and dark) are designed as a pair — same structure, inverted palette.

## Basic setup

```dart
OiApp(
  theme: OiThemeData.light(),
  darkTheme: OiThemeData.dark(),
  themeMode: OiThemeMode.system,  // Follow OS setting
  home: const MyHomePage(),
)
```

## Theme modes

| Mode | Behavior |
|---|---|
| `OiThemeMode.light` | Always use light theme |
| `OiThemeMode.dark` | Always use dark theme |
| `OiThemeMode.system` | Follow the OS brightness setting |

## Brand colors in both modes

```dart
OiApp(
  theme: OiThemeData.fromBrand(color: myBrandColor),
  darkTheme: OiThemeData.fromBrand(
    color: myBrandColor,
    brightness: Brightness.dark,
  ),
  themeMode: OiThemeMode.system,
  home: const MyHomePage(),
)
```

The library adjusts surface colors, text contrast, shadow intensity, and swatch variants automatically for dark mode.

## Checking current mode

```dart
final isDark = context.theme.isDark;
final isLight = context.theme.isLight;
```

## What changes in dark mode

| Token | Light | Dark |
|---|---|---|
| Background | `#F9FAFB` (light grey) | `#0A0A0F` (near-black) |
| Surface | `#FFFFFF` (white) | `#111118` (dark grey) |
| Text | `#111827` (dark) | `#F9FAFB` (light) |
| Borders | `#D1D5DB` (grey) | `#374151` (dark grey) |
| Shadows | Standard intensity | Reduced intensity |
| Primary | `#2563EB` (blue) | `#3B82F6` (lighter blue) |

All semantic colors shift to maintain contrast and readability.

## Scoped theme override

Need a dark section inside a light app (or vice versa)?

```dart
OiThemeScope(
  data: OiThemeData.dark(),
  child: MyDarkWidget(),
)
```

`OiThemeScope` overrides the theme for its subtree without affecting the rest of the app.

## Animated theme transitions

`OiThemeData.lerp` supports smooth interpolation between themes:

```dart
final interpolated = OiThemeData.lerp(lightTheme, darkTheme, 0.5);
```

This is useful for custom theme transition animations.
