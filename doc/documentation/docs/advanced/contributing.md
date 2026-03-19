# Contributing

We'd love your help making ObersUI even creamier. Here's how to get started.

## Development setup

```bash
# Clone the repository
git clone https://github.com/simonerich/obers_ui.git
cd obers_ui

# Install dependencies
flutter pub get

# Run tests
flutter test

# Run analysis
dart analyze --fatal-infos
dart format .
```

## Code style

ObersUI uses [very_good_analysis](https://pub.dev/packages/very_good_analysis) for strict linting. The analyzer catches most style issues, but here are the key conventions:

- **Widget prefix**: All widgets start with `Oi`
- **File naming**: `oi_widget_name.dart`
- **Private constructors**: Use `const` primary constructors where possible
- **Variants**: Factory constructors for semantic variants (`OiButton.primary()`)
- **Dartdoc**: Public APIs require documentation with description and usage example

## Adding a new component

1. **Create the widget**: `lib/src/components/<category>/oi_<name>.dart`
2. **Add variants**: Factory constructors for different visual styles
3. **Use theme tokens**: All visual values from `context.theme` — no hardcoded colors or sizes
4. **Add accessibility**: Semantic labels, keyboard navigation, touch targets
5. **Export**: Add to `lib/obers_ui.dart` barrel file
6. **Write tests**: `test/src/components/<category>/oi_<name>_test.dart`
7. **Add golden test**: `test/src/golden/oi_<name>_golden_test.dart`
8. **Add to Widgetbook**: `widgetbook/lib/components/<category>/oi_<name>_use_case.dart`

### Component template

```dart
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

/// A brief description of the widget.
///
/// ```dart
/// OiExample(
///   child: Text('Hello'),
/// )
/// ```
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
    return child;
  }
}
```

## Testing

### Test types

| Type | Location | Purpose |
|---|---|---|
| Widget tests | `test/src/components/` | Behavior, interaction, accessibility |
| Golden tests | `test/src/golden/` | Visual regression (light/dark, all breakpoints) |
| Integration tests | `test/src/integration/` | Multi-component interaction flows |
| Benchmarks | `test/src/benchmarks/` | Frame time and memory profiling |

### Running tests

```bash
# All tests
flutter test

# With coverage (80% minimum)
flutter test --coverage

# Golden tests only
flutter test test/src/golden/

# Update golden files after visual changes
flutter test --update-goldens
```

### Test helpers

ObersUI provides helpers in `test/helpers/`:

```dart
// Pump a widget with touch device simulation
await tester.pumpTouchApp(MyWidget());

// Pump with pointer device simulation
await tester.pumpPointerApp(MyWidget());

// Pump at a specific breakpoint
await tester.pumpAtBreakpoint(MyWidget(), width: kMediumWidth);
```

## Pull request requirements

- [ ] All tests pass (`flutter test`)
- [ ] Analysis passes (`dart analyze --fatal-infos`)
- [ ] Code is formatted (`dart format .`)
- [ ] Golden files updated if visuals changed
- [ ] New components have widget tests and golden tests
- [ ] Public APIs have dartdoc comments

## Project structure

See [Project Structure](../getting-started/project-structure.md) for the full directory layout.

## Questions or issues?

Open an issue on [GitHub](https://github.com/simonerich/obers_ui/issues).
