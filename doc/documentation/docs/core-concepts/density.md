# Density

Density controls how much space a component takes up. It scales heights and paddings across the library so the same widgets can feel touch-friendly on a phone or tight on a data dashboard. You set it once on `OiApp`, and every component reads it from context.

## Modes

`OiDensity` is a three-value enum. Each mode trades screen space for tap comfort.

| Mode | Best for | Feel |
| --- | --- | --- |
| `OiDensity.comfortable` | Touch devices, consumer apps | Larger controls, more padding |
| `OiDensity.compact` | Standard desktop and web apps | Balanced sizing |
| `OiDensity.dense` | Data-heavy dashboards and tables | Minimal padding, most rows per screen |

Density changes sizing and padding only. It does not remove features or change behavior. A dense button still does everything a comfortable one does. It is just shorter.

## Setting density on OiApp

Pass `density` to `OiApp`. This wraps your tree in an `OiDensityScope` that every component reads.

```dart
OiApp(
  density: OiDensity.compact,
  theme: OiThemeData.light(),
  home: const MyHomePage(),
)
```

If you leave `density` as `null`, `OiApp` picks a default from the platform:

- iOS and Android get `comfortable`.
- Web, macOS, Windows, and Linux get `compact`.

```dart
// No density set. OiApp auto-detects from the platform.
OiApp(
  theme: OiThemeData.light(),
  home: const MyHomePage(),
)
```

!!! note
    `dense` is never auto-detected. You opt into it when a screen needs to show
    a lot of data at once, like a report or an admin table.

## Reading density

Call `OiDensityScope.of(context)` to read the active mode. Use it when your own widget needs to adjust its layout to match the rest of the app.

```dart
final density = OiDensityScope.of(context);

if (density == OiDensity.comfortable) {
  // Add extra padding for touch users.
}
```

`OiDensityScope.of` throws if there is no `OiApp` above it in the tree. Wrap your app in `OiApp` and this is handled for you.

| Member | Type | Description |
| --- | --- | --- |
| `OiDensityScope.of(context)` | `OiDensity` | The active density. Throws if no `OiApp` ancestor exists. |
| `density` | `OiDensity` | The mode this scope provides to its descendants. |

## Where density matters

Most components read density and adjust their fixed dimensions. Two places where you notice it most:

### Buttons

A medium `OiButton` changes height with density: 36 in comfortable, 32 in compact, 28 in dense. You do not set this per button. It follows the app-wide mode.

```dart
OiButton.primary(
  label: 'Save',
  onTap: () => save(),
)
```

### Tables

Row height and cell padding shrink as density increases. `dense` fits far more rows on screen, which is the point of a data view.

```dart
OiApp(
  density: OiDensity.dense,
  theme: OiThemeData.light(),
  home: const ReportsPage(),
)
```

List tiles, input fields, and other components follow the same rule. Set the mode once, and the whole screen shifts together.

## Density is not accessibility

This is a common mix-up. Density controls information density. It does not shrink tap areas below a safe size.

On touch devices, `OiTappable` still enforces a minimum tap target through `OiA11y.minTouchTarget(context)`, whatever density is active. A dense button can look short, but its hit area stays large enough to tap. See [Accessibility](accessibility.md) for the details.

## Related

- [Theming](theming.md) for colors, spacing, and radius tokens.
- [Responsive](responsive.md) for breakpoints and adaptive layouts.
- [Accessibility](accessibility.md) for tap targets and screen-reader support.
