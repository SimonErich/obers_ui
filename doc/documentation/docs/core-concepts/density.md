# Density

Density controls how much information fits on screen. ObersUI adapts padding, sizing, and spacing based on three density modes.

## Modes

| Mode | Default on | Touch target | Typical use |
|---|---|---|---|
| **comfortable** | Touch devices (iOS, Android) | 48dp | Consumer apps, mobile |
| **compact** | Desktop, web | 44dp | Standard desktop apps |
| **dense** | — (explicit) | 44dp | Data-heavy dashboards |

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

The key principle: even in `dense` mode, touch targets never go below 44dp on touch devices. Density is about information density, not about breaking accessibility.
