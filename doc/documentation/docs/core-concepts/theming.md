# Theming

ObersUI uses a token-based design system. Every visual choice (color, spacing,
font size, corner radius, shadow, motion) comes from a theme token, not a
hardcoded value. Set the theme once, and every widget follows it.

## The short version

You give `OiApp` a theme. The fastest way is one brand color:

```dart
OiApp(
  theme: OiThemeData.fromBrand(color: Color(0xFF8B6914)),
  home: myHome,
)
```

`fromBrand` builds a full palette from that single color. From there, every widget
reads its colors and spacing from the theme.

You read tokens in your own code through context extensions:

```dart
final blue = context.colors.primary.base;
final gap = context.spacing.md;
final round = context.radius.lg;
```

## Where to go next

This page is the quick tour. The [Theming section](../theming/index.md) has the
full detail:

- [Quick Brand Setup](../theming/quick-brand.md) for the one-color path.
- [Color System](../theming/color-system.md) for swatches and surface tokens.
- [Typography](../theming/typography.md) for text styles and `OiLabel`.
- [Design Tokens](../theming/tokens.md) for spacing, radius, shadows, and motion.
- [Component Themes](../theming/component-themes.md) to restyle individual widgets.
- [Dark Mode](../theming/dark-mode.md) for light and dark themes.
- [Extending Themes](../theming/extending-themes.md) for full control with `copyWith`.
