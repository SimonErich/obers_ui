# Extending Themes

ObersUI includes tools for dynamic theming, theme export, and visual preview — useful for apps that let users customize their experience.

## OiDynamicTheme

Generate a complete theme from a single brand color at runtime:

```dart
// User picks a color from a color picker
final userColor = Color(0xFF8B6914);

// Generate full theme
final theme = OiThemeData.fromBrand(
  color: userColor,
  brightness: Brightness.light,
);
```

This is the same factory used in [Quick Brand Setup](../theming/quick-brand.md), but called dynamically — great for apps where the end user chooses their brand color.

## OiThemeExporter

Serialize a theme to JSON or Dart code:

```dart
// Export to JSON (for saving to a database or file)
final json = OiThemeExporter.toJson(myTheme);

// Export to Dart code (for generating theme files)
final dartCode = OiThemeExporter.toDart(myTheme);
```

Useful for:

- Saving user theme preferences to a backend
- Generating theme files for white-label apps
- Sharing themes between projects

## OiThemePreview

A visual component gallery that renders all token categories for review:

```dart
OiThemePreview(theme: myCustomTheme)
```

Displays swatches, typography samples, spacing visualization, radius samples, and shadow levels. Great for theme review during design handoff.

## OiPlayground

An internal storybook-like tool (not exported from the barrel file). Available in the `tools/` directory for development use:

```dart
// Run directly from the tools directory
import 'package:obers_ui/src/tools/oi_playground.dart';
```

## Theme scope overrides

For apps with multiple brands or themed sections:

```dart
OiThemeScope(
  data: OiThemeData.fromBrand(color: partnerBrandColor),
  child: PartnerSection(),
)
```

Everything inside `PartnerSection` uses the partner's theme. The rest of the app is unaffected.

## Animated theme transitions

`OiThemeData.lerp` enables smooth interpolation:

```dart
// Animate between themes
final t = animationController.value;
final interpolated = OiThemeData.lerp(themeA, themeB, t);
```

Colors and typography interpolate smoothly; discrete values (spacing, radius) snap at `t = 0.5`.
