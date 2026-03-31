# Color System

ObersUI's color system is built on **semantic tokens** — colors are named by purpose, not by appearance.

## Color scheme structure

`OiColorScheme` contains:

### Semantic swatches

Each swatch is an `OiColorSwatch` with 5 variants:

| Swatch | Purpose | Default (light) |
| --- | --- | --- |
| `primary` | Brand / main actions | Blue (#2563EB) |
| `accent` | Secondary emphasis | Teal (#0D9488) |
| `success` | Positive / success states | Green (#16A34A) |
| `warning` | Caution / attention | Amber (#D97706) |
| `error` | Errors / destructive actions | Red (#DC2626) |
| `info` | Informational highlights | Sky blue (#0284C7) |

### Swatch variants

Each `OiColorSwatch` provides:

```dart
context.colors.primary.base        // Main color
context.colors.primary.light       // Lighter tint
context.colors.primary.dark        // Darker shade
context.colors.primary.muted       // Subdued / background
context.colors.primary.foreground  // Text on base
```

Create a swatch from any color:

```dart
final swatch = OiColorSwatch.from(Color(0xFF8B6914));
// Automatically generates light, dark, muted, foreground
```

### Surface colors

```dart
context.colors.background     // Page background
context.colors.surface        // Card / panel surface
context.colors.surfaceHover   // Hovered surface
context.colors.surfaceActive  // Pressed / active surface
context.colors.surfaceSubtle  // Zebra stripes, sidebars
context.colors.overlay        // Modal backdrop (semi-transparent)
```

### Text colors

```dart
context.colors.text           // Primary text (highest contrast)
context.colors.textSubtle     // Secondary text
context.colors.textMuted      // Placeholders, captions
context.colors.textInverse    // Text on inverted backgrounds
context.colors.textOnPrimary  // Text on primary color
```

### Border colors

```dart
context.colors.border         // Default borders
context.colors.borderSubtle   // Light borders
context.colors.borderFocus    // Focus ring color
context.colors.borderError    // Validation error border
```

### Glass effect

```dart
context.colors.glassBackground  // Frosted glass background
context.colors.glassBorder      // Frosted glass border
```

### Chart palette

```dart
context.colors.chart  // List<Color> — 8 categorical colors for data viz
```

## Customizing colors

Override specific colors using `copyWith`:

```dart
OiThemeData.light().copyWith(
  colors: OiColorScheme.light().copyWith(
    primary: OiColorSwatch.from(Color(0xFF8B6914)),
    success: OiColorSwatch.from(Color(0xFF059669)),
    background: Color(0xFFFFFBF5),  // Warm cream background
  ),
)
```

## Built-in schemes

| Factory | Description |
| --- | --- |
| `OiColorScheme.light()` | Light theme with blue primary, grey surfaces |
| `OiColorScheme.dark()` | Dark theme with blue primary, near-black surfaces |

Both maintain WCAG AA contrast ratios.
