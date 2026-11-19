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

`OiApp` is the entry point. It installs the theme, the overlay host and the accessibility scopes; no `MaterialApp` is involved.

```dart
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

void main() => runApp(
  OiApp(
    title: 'My App',
    theme: OiThemeData.light(),
    darkTheme: OiThemeData.dark(),
    themeMode: OiThemeMode.system,
    home: Builder(
      builder: (context) => OiPage(
        breakpoint: context.breakpoint,
        children: [
          OiLabel.h1('Hello'),
          OiButton.primary(label: 'Go', onTap: () {}),
        ],
      ),
    ),
  ),
);
```

Inside the tree, read design tokens from the context: `context.colors`, `context.textTheme`, `context.spacing`, `context.radius`, `context.animations` and `context.breakpoint`.

## Components

The library is layered; each layer builds on the ones above it. The table lists a few entry points per layer, [AI_README.md](AI_README.md) has the full catalog.

| Layer | Examples |
| ----- | -------- |
| **Foundation** | `OiApp`, `OiThemeData`, `OiColorScheme`, `OiTextTheme`, `OiSpacingScale`, `OiRadiusScale`, `OiShadowScale`, `OiAnimationConfig`, `OiBreakpointScale`, `OiResponsive<T>` |
| **Primitives** | `OiLabel`, `OiIcon`, `OiSurface`, `OiDivider`, `OiSpacer`, `OiRow`, `OiColumn`, `OiGrid`, `OiPage`, `OiTappable` |
| **Components** | `OiButton`, `OiIconButton`, `OiTextInput`, `OiSelect`, `OiCheckbox`, `OiSwitch`, `OiCard`, `OiAvatar`, `OiBadge`, `OiDialog`, `OiSheet`, `OiPopover`, `OiProgress`, `OiSkeletonGroup`, `OiEmptyState` |
| **Composites** | `OiTable`, `OiCalendar`, `OiGantt`, `OiWizard`, `OiSidebar`, `OiRichEditor`, `OiErrorPage` |
| **Modules** | `OiAppShell`, `OiAuthPage`, `OiChat`, `OiCheckout`, `OiDashboard`, `OiFileExplorer`, `OiKanban` |

## Packages

The repository contains two opt-in packages that build on `obers_ui`:

| Package | Purpose |
| ------- | ------- |
| [`obers_ui_charts`](packages/obers_ui_charts/README.md) | Chart foundation and chart widgets (`OiLineChart`, `OiBarChart`, `OiPieChart`, ...), maps and dashboard modules |
| [`obers_ui_autoforms`](packages/obers_ui_autoforms/README.md) | Controller-first form handling (`OiAfForm`, `OiAfController`) with field wrappers and validation |

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
