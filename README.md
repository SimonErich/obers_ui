# obers_ui

[![CI](https://github.com/simonerich/obers_ui/actions/workflows/ci.yml/badge.svg)](https://github.com/simonerich/obers_ui/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A comprehensive Flutter UI kit with design tokens, responsive utilities, and accessible components.

## Installation

Add `obers_ui` to your `pubspec.yaml`:

```yaml
dependencies:
  obers_ui:
    git:
      url: https://github.com/simonerich/obers_ui.git
```

Or for local development:

```yaml
dependencies:
  obers_ui:
    path: ../obers_ui
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';

void main() {
  runApp(
    MaterialApp(
      // Register the obers_ui theme extension
      theme: ThemeData.light().copyWith(
        extensions: const [
          // OiTheme(data: OiThemeData.light()),
        ],
      ),
      darkTheme: ThemeData.dark().copyWith(
        extensions: const [
          // OiTheme(data: OiThemeData.dark()),
        ],
      ),
      home: const MyApp(),
    ),
  );
}
```

## Components

| Category | Widgets |
|----------|---------|
| **Theme** | `OiTheme`, `OiColors`, `OiTypography`, `OiSpacing`, `OiRadius`, `OiShadows`, `OiDurations`, `OiBreakpoints` |
| **Components** | `OiButton`, `OiCard`, `OiText`, `OiInput`, `OiCheckbox`, `OiDivider`, `OiSpacer`, `OiSurface`, `OiIconButton` |
| **Widgets** | `OiAvatar`, `OiBadge`, `OiToggle`, `OiModal`, `OiHoverCard`, `OiEmptyState`, `OiLoadingState`, `OiErrorState` |
| **Layouts** | `OiAppShell`, `OiResponsiveBuilder`, `OiResponsiveWidget` |

## Widget Prefix

All obers_ui widgets use the **`Oi`** prefix to avoid naming conflicts with Flutter's built-in widgets.

## Example

Run the example app to see all components in action:

```bash
cd example
flutter run
```

## Documentation

Generate API documentation:

```bash
dart doc
```

The generated docs will be in `doc/api/`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and guidelines.

## License

MIT License - see [LICENSE](LICENSE) for details.
