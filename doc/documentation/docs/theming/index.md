# Theming

ObersUI's theming system is designed with a simple philosophy: **easy to start, powerful when you need it.** Like a good Obers — smooth by default, whippable into anything.

## Choose your level

| Level | Effort | For whom |
| --- | --- | --- |
| [**Quick Brand Setup**](quick-brand.md) | One line | "Just make it match my brand color" |
| [**Color System**](color-system.md) | Token overrides | "I want specific colors" |
| [**Typography**](typography.md) | Font swap | "I want my own fonts" |
| [**Tokens**](tokens.md) | Scale adjustments | "I want different spacing or radius" |
| [**Component Themes**](component-themes.md) | Per-widget | "I want this specific button to look different" |
| [**Dark Mode**](dark-mode.md) | Light/dark | "My app needs both modes" |

## Architecture at a glance

```text
OiThemeData
├── OiColorScheme        (semantic colors)
├── OiTextTheme          (14 text styles)
├── OiSpacingScale       (6 spacing values + page gutters)
├── OiRadiusScale        (border radii)
├── OiShadowScale        (elevation shadows)
├── OiAnimationConfig    (durations + reduced motion)
├── OiEffectsTheme       (hover, focus, active feedback)
├── OiDecorationTheme    (border styles)
└── OiComponentThemes    (per-widget overrides)
```

All tokens are immutable. Use `copyWith` to derive modified versions.
