# Contributing to obers_ui

## Development Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/simonerich/obers_ui.git
   cd obers_ui
   ```

2. Install dependencies. The Flutter version is pinned in `.tool-versions`; CI reads it from there.

   ```bash
   flutter pub get
   ```

3. Run the example app:

   ```bash
   cd example
   flutter pub get
   flutter run
   ```

## Repository Layout

| Path | Content |
| ---- | ------- |
| `lib/` | The `obers_ui` package |
| `packages/obers_ui_charts/` | Charts, maps and dashboard modules |
| `packages/obers_ui_autoforms/` | Controller-first form handling |
| `example/` | Showcase app |
| `doc/` | Commit guidelines, dartdoc category pages and the MkDocs site |

Each package has its own `pubspec.yaml` and `analysis_options.yaml`, so run `flutter pub get`, `dart analyze` and `flutter test` inside the package you change.

## Code Style

This project uses [very_good_analysis](https://pub.dev/packages/very_good_analysis) for strict linting. Run analysis and the formatter before submitting:

```bash
dart analyze --fatal-infos
dart format .
```

Commit messages follow [doc/commits.md](doc/commits.md).

## Testing

### Run the tests

Golden tests carry the `golden` tag (declared in `dart_test.yaml`) and run separately from the other tests:

```bash
flutter test --exclude-tags golden
flutter test --tags golden
```

The sub-packages have their own suites:

```bash
cd packages/obers_ui_charts && flutter test
cd packages/obers_ui_autoforms && flutter test
```

### Run with coverage

```bash
flutter test --coverage --exclude-tags golden
```

### Update golden files

Only the machine-independent CI goldens (`goldens/ci/`) are committed. Update them when a visual change is intended:

```bash
flutter test --tags golden --update-goldens
```

## Adding a New Widget

The library is layered. Pick the layer first, then the category folder inside it:

| Layer | Folder | Content |
| ----- | ------ | ------- |
| Foundation | `lib/src/foundation/` | Theme, tokens, app-level services |
| Primitives | `lib/src/primitives/<category>/` | Low-level building blocks (`display`, `layout`, `interaction`, ...) |
| Components | `lib/src/components/<category>/` | Single-purpose widgets (`buttons`, `inputs`, `display`, `overlays`, ...) |
| Composites | `lib/src/composites/<category>/` | Multi-component patterns (`data`, `forms`, `scheduling`, ...) |
| Modules | `lib/src/modules/` | Screen-level features |
| Models | `lib/src/models/` | Plain data classes |

All widgets follow this pattern:

1. **File**: `lib/src/<layer>/<category>/oi_<name>.dart`, for example `lib/src/components/display/oi_badge.dart`.
2. **Class**: `Oi<Name>` with a public `const` constructor.
3. **Variants**: Where a widget has semantic variants, add named constructors next to the default one (e.g. `OiButton.primary()`, `OiLabel.h1()`).
4. **No Material**: Import `package:flutter/widgets.dart`, not `material.dart`. The library has its own design system.
5. **Theming**: All visual values come from theme tokens: `context.colors`, `context.textTheme`, `context.spacing`, `context.radius`, `context.animations` and `context.components`. No colour, size or duration literals.
6. **Strings**: User-visible strings go in an `Oi<Name>Labels` class passed as `labels:` with English defaults (model: `lib/src/modules/oi_checkout_labels.dart`).
7. **Docs**: Dartdoc with a description, a usage example and a `{@category ...}` tag that names the layer (`Components`, `Composites`, ...).
8. **Export**: Add the file to the `lib/obers_ui.dart` barrel file, in the section of its layer and category.
9. **Test**: Widget test at the mirrored path, `test/src/<layer>/<category>/oi_<name>_test.dart`. Use `tester.pumpObers(widget)` from `test/helpers/pump_app.dart`, which wraps the widget in `OiApp`.
10. **Golden**: Golden test with alchemist's `goldenTest` and `obersGoldenGroup` from `test/helpers/golden_helper.dart`, either in `test/src/golden/oi_<name>_golden_test.dart` or next to the widget test.
11. **Size**: Files over about 500 lines are split into `part` files in a sibling folder (`oi_<name>/oi_<name>_<concern>.part.dart`); see `.cursor/rules/widget-decomposition.mdc`.

### Widget template

```dart
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A brief description of the widget.
///
/// ```dart
/// OiExample(
///   child: OiLabel.body('Hello'),
/// )
/// ```
///
/// {@category Components}
class OiExample extends StatelessWidget {
  /// Creates an [OiExample].
  const OiExample({
    required this.child,
    super.key,
  });

  /// The content of this widget.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.spacing.md),
      child: child,
    );
  }
}
```

## Pull Request Requirements

- All tests pass (`flutter test --exclude-tags golden`, `flutter test --tags golden`, and `flutter test` in each sub-package you touched)
- Analysis passes (`dart analyze --fatal-infos`)
- Code is formatted (`dart format .`)
- Golden files updated if visuals changed
- New widgets have widget tests and golden tests
- Public APIs have dartdoc comments
- `CHANGELOG.md` has an entry under `Unreleased` for user-visible changes
