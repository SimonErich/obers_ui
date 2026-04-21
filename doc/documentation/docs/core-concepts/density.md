# Density

Density controls how much information fits on screen. ObersUI adapts padding, sizing, and spacing based on three density modes.

## Modes

`OiDensity` is a three-value enum defined in [oi_app.dart](lib/src/foundation/oi_app.dart):

| Mode | Default on | Typical use |
| --- | --- | --- |
| `OiDensity.comfortable` | Touch devices (iOS, Android) | Consumer apps, mobile |
| `OiDensity.compact` | Desktop, web | Standard desktop apps |
| `OiDensity.dense` | — (explicit only) | Data-heavy dashboards |

Density controls sizing and padding only. Touch targets are a separate accessibility concern — see [Accessibility](accessibility.md).

## Auto-detection

`OiApp` detects the best density automatically based on platform:

- **iOS / Android** → `comfortable`
- **Web / macOS / Windows / Linux** → `compact`

You can override this:

```dart
OiApp(
  density: OiDensity.dense,  // Force dense mode
  theme: OiThemeData.light(),
  home: const MyHomePage(),
)
```

## Reading density

```dart
final density = OiDensityScope.of(context);

if (density == OiDensity.comfortable) {
  // Extra padding for touch users
}
```

## How it affects components

Density changes padding and sizing, not functionality:

- **Buttons** get taller in comfortable mode
- **Table rows** have more vertical padding in comfortable mode
- **List tiles** expand to accommodate touch targets
- **Input fields** adjust their height

The key principle: density controls information density, not accessibility. On touch devices, [OiA11y.minTouchTarget(context)](lib/src/foundation/oi_accessibility.dart) enforces a 48dp tap area regardless of the active density — `OiTappable` uses this internally.
