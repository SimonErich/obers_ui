# Theming & Configuration

One theme drives the look of your whole app. You can start with a single brand
color and never think about it again, or reach in and control every token when you
need to. Nothing is hardcoded, so a change in one place updates everywhere.

## Start here

- [**Quick Brand Setup**](quick-brand.md) turns one color into a full palette.
- [**Dark Mode**](dark-mode.md) adds a dark theme and a system toggle.

## The token system

- [**Color System**](color-system.md) covers the semantic swatches and the surface and text tokens.
- [**Typography**](typography.md) covers the text styles and `OiLabel`.
- [**Design Tokens**](tokens.md) covers spacing, radius, shadows, and motion.

## Going further

- [**Component Themes**](component-themes.md) restyle individual widgets without touching the rest.
- [**Extending Themes**](extending-themes.md) gives full control with `copyWith` and per-subtree overrides.
- [**Theme Tools**](theme-tools.md) cover exporting, previewing, and hot-swapping themes.

## What lives on the theme

`OiThemeData` holds every token family:

```text
OiThemeData
├── OiColorScheme        semantic colors (primary, accent, success, ...)
├── OiTextTheme          14 text styles, used through OiLabel
├── OiSpacingScale       spacing (xs, sm, md, lg, xl, xxl)
├── OiRadiusScale        corner radii
├── OiShadowScale        elevation shadows
├── OiAnimationConfig    durations, curves, reduced motion
├── OiEffectsTheme       hover, focus, and active feedback
├── OiDecorationTheme    borders and gradients
└── OiComponentThemes    per-widget overrides
```

Every token is immutable. Use `copyWith` to derive a changed version.
