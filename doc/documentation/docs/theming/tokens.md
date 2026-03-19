# Tokens: Spacing, Radius, Shadows, Effects & Animations

Beyond colors and typography, ObersUI provides tokens for every visual dimension.

## Spacing

The spacing scale follows a **4dp base grid** with doubling progression:

| Token | Value | Use case |
|---|---|---|
| `xs` | 4dp | Tight internal gaps |
| `sm` | 8dp | Element gaps, compact padding |
| `md` | 16dp | Default padding, standard gaps |
| `lg` | 24dp | Section padding |
| `xl` | 32dp | Card padding, section separators |
| `xxl` | 48dp | Major section separators |

```dart
Padding(
  padding: EdgeInsets.all(context.spacing.md),  // 16dp
  child: ...,
)
```

Page gutters adapt per breakpoint (16dp on compact up to 48dp on extra-large).

### Custom spacing

```dart
OiThemeData.light().copyWith(
  spacing: OiSpacingScale.standard().copyWith(
    md: 12,   // Tighter default spacing
    lg: 20,
  ),
)
```

## Border radius

Radius tokens come in a scale with a **preference** that shifts the entire scale:

| Preference | Effect |
|---|---|
| `OiRadiusPreference.sharp` | Minimal rounding |
| `OiRadiusPreference.medium` | Balanced (default) |
| `OiRadiusPreference.rounded` | Generous rounding |

```dart
// Set globally
OiThemeData.light(radiusPreference: OiRadiusPreference.rounded)

// Access in widgets
final r = context.radius;
Container(
  decoration: BoxDecoration(borderRadius: r.md),
)
```

## Shadows

Elevation-based shadow tokens:

```dart
Container(
  decoration: BoxDecoration(
    boxShadow: context.shadows.md,  // Medium elevation
  ),
)
```

Shadows automatically reduce:

- **25%** on compact/touch devices
- **15% opacity** reduction at 1x pixel density

## Effects

`OiEffectsTheme` controls interactive state feedback:

- **Hover** — background overlay on mouse-over
- **Focus** — focus ring color and width
- **Active** — pressed / active state
- **Dragging** — drag state visual
- **Disabled** — 0.4 opacity

These are consumed automatically by `OiTappable` and all interactive widgets. You rarely need to read them directly.

## Animations

`OiAnimationConfig` provides duration tokens:

| Token | Duration | Use case |
|---|---|---|
| `fast` | 150ms | Micro-interactions (hover, toggle) |
| `normal` | 250ms | Standard transitions |
| `slow` | 400ms | Complex animations (page transitions) |

```dart
AnimatedContainer(
  duration: context.animations.normal,
  // ...
)
```

When `reducedMotion` is enabled, all durations become `Duration.zero`.
