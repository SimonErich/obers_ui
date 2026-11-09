# Installation

ObersUI is a Flutter UI library with no Material or Cupertino dependency. This
page shows how to add it to a project, which versions you need, and how to wrap
your app in `OiApp` instead of `MaterialApp`.

## Requirements

| Requirement | Minimum version |
| --- | --- |
| Flutter | 3.41.0 |
| Dart | 3.11.0 |

These are the floors from the package `pubspec.yaml`. Older SDKs will not
resolve.

## Add the dependency

ObersUI ships as a Git dependency. Add it to your `pubspec.yaml` and replace the
URL with your organization's remote.

```yaml
dependencies:
  obers_ui:
    git:
      url: https://github.com/simonerich/obers_ui.git
```

Then fetch packages:

```bash
flutter pub get
```

To pin a tag or commit, add a `ref` field. Pinning keeps builds reproducible.

```yaml
dependencies:
  obers_ui:
    git:
      url: https://github.com/simonerich/obers_ui.git
      ref: v0.1.2 # a tag or a commit hash
```

### Local path

Use a path dependency when you work on ObersUI itself, or when you keep it
checked out next to your app.

```yaml
dependencies:
  obers_ui:
    path: ../obers_ui
```

## Single import

Everything public is exported through one barrel file. Import it and you have
the full catalog.

```dart
import 'package:obers_ui/obers_ui.dart';
```

## Wrap your app in OiApp

ObersUI has zero Material dependency, so you do not use `MaterialApp`. `OiApp` is
the root widget. It replaces `WidgetsApp`, `MaterialApp`, or `CupertinoApp`, and
it injects the theme, overlays, density, accessibility scope, and other services
into the tree.

```dart
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

void main() {
  runApp(
    OiApp(
      theme: OiThemeData.light(),
      darkTheme: OiThemeData.dark(),
      themeMode: OiThemeMode.system,
      home: const HomePage(),
    ),
  );
}
```

Inside the app, read colors from the theme, show text with `OiLabel`, and lay
out with `OiRow`, `OiColumn`, or `OiGrid`. Interactive widgets take a `label` or
`semanticLabel`.

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return OiColumn(
      children: [
        OiLabel.h1('Hello, ObersUI'),
        OiButton.primary(
          label: 'Get started',
          onTap: () {},
        ),
      ],
    );
  }
}
```

For an app that uses a declarative router such as go_router, use `OiApp.router`
and pass a `routerConfig`.

```dart
OiApp.router(
  routerConfig: myGoRouter,
  theme: OiThemeData.light(),
  darkTheme: OiThemeData.dark(),
  themeMode: OiThemeMode.system,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `home` | `Widget` | **required** | The root widget. Use the default constructor. |
| `routerConfig` | `RouterConfig<Object>` | **required** | Router config for `OiApp.router`. |
| `theme` | `OiThemeData?` | `OiThemeData.light()` | The light theme. |
| `darkTheme` | `OiThemeData?` | `null` | The dark theme. Falls back to `theme` when null. |
| `themeMode` | `OiThemeMode` | `system` | `light`, `dark`, or `system`. |
| `density` | `OiDensity?` | auto | Layout density. Auto-detected per platform when null. |
| `supportedLocales` | `Iterable<Locale>` | `[en_US]` | The locales the app supports. |
| `settingsDriver` | `OiSettingsDriver?` | `null` | Global persistence driver for widgets that store settings. |

!!! note
    `home` is required on the default `OiApp`, and `routerConfig` is required on
    `OiApp.router`. Use one constructor or the other, not both.

## Supported platforms

ObersUI runs on every Flutter target:

- Web
- iOS
- Android
- macOS
- Windows
- Linux

Density is auto-detected. Touch platforms (iOS, Android) default to a
comfortable density with larger touch targets. Pointer platforms (macOS,
Windows, Linux, web) default to a compact density.

## Optional: obers_ui_autoforms

A separate package, `obers_ui_autoforms`, adds a controller-driven forms layer
on top of ObersUI. It lives under `packages/obers_ui_autoforms` in this repo.
Add it only if you want that layer. It has its own import.

```dart
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';
```

## Related

- [Quick Start](quick-start.md) for a first screen end to end.
- [Project Structure](project-structure.md) for how the library is organized.
