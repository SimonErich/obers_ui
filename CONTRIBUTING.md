# Contributing to obers_ui

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/simonerich/obers_ui.git
   cd obers_ui
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the example app:
   ```bash
   cd example
   flutter pub get
   flutter run
   ```

## Code Style

This project uses [very_good_analysis](https://pub.dev/packages/very_good_analysis) for strict linting. Run analysis before submitting:

```bash
dart analyze --fatal-infos
dart format .
```

## Testing

### Run all tests
```bash
flutter test
```

### Run with coverage
```bash
flutter test --coverage
```

### Update golden files
```bash
flutter test --update-goldens
```

## Adding a New Component

All components follow this pattern:

1. **File**: `lib/src/components/oi_<name>.dart`
2. **Class**: `Oi<Name>` with private primary constructor
3. **Variants**: Factory constructors for semantic variants (e.g., `OiButton.primary()`)
4. **Theming**: All visual values from design tokens via `OiTheme.of(context)`
5. **Docs**: Dartdoc with description and usage example
6. **Export**: Add to `lib/obers_ui.dart` barrel file
7. **Test**: Widget test in `test/src/components/oi_<name>_test.dart`
8. **Golden**: Golden test in `test/src/golden/oi_<name>_golden_test.dart`

### Component template

```dart
import 'package:flutter/material.dart';

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

## Pull Request Requirements

- All tests pass (`flutter test`)
- Analysis passes (`dart analyze --fatal-infos`)
- Code is formatted (`dart format .`)
- Golden files updated if visuals changed
- New components have widget tests and golden tests
- Public APIs have dartdoc comments
