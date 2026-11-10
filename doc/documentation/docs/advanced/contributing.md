# Contributing

Thanks for helping improve ObersUI. This page shows you how to set up the
project, run the checks, and follow the conventions the codebase expects. Read
it once before your first pull request.

## Development setup

Clone the repository and install the package dependencies.

```bash
git clone https://github.com/SimonErich/obers_ui.git
cd obers_ui
flutter pub get
```

You need Flutter 3.41.0 or newer and Dart 3.11.0 or newer.

## Run the example app

The example app lives in `example/`. It has its own dependencies, so install
them there before you run it.

```bash
cd example
flutter pub get
flutter run
```

Use the example app to check a widget by hand while you work on it.

## Everyday checks

Run these three commands before you push. They match what the pull request
review expects.

```bash
# Run the full test suite
flutter test

# Analyze with strict lints (very_good_analysis)
dart analyze --fatal-infos

# Format the code
dart format .
```

The analyzer uses [very_good_analysis](https://pub.dev/packages/very_good_analysis).
It catches most style issues on its own. The conventions below cover the rest.

## Conventions

These rules keep every widget consistent. The analyzer does not enforce all of
them, so keep them in mind as you write.

### Use the Oi prefix

Every public class starts with `Oi`. Variants use factory constructors, not a
default constructor.

```dart
OiButton.primary(label: 'Save', onTap: save)
OiBadge.soft(label: 'Draft')
```

File names match: a widget lives in `lib/src/components/<category>/oi_<name>.dart`.

### Show text with OiLabel, not Text

Never use a raw `Text` widget. Use `OiLabel` and its named constructors. They
pull type styles from the theme.

```dart
// Correct
OiLabel.body('Total: 42 items')
OiLabel.heading('Reports')

// Wrong. Do not do this.
Text('Total: 42 items')
```

### Lay out with OiRow, OiColumn, and OiGrid

Use the layout primitives instead of raw `Row` and `Column`. They add responsive
gap and collapse behavior.

```dart
OiRow(
  gap: context.spacing.md,
  children: [
    OiLabel.body('Name'),
    OiButton.ghost(label: 'Edit', onTap: edit),
  ],
)
```

### Read values from the theme

Never hardcode a color, spacing, or radius. Read them from the context
extensions. Hardcoded values break dark mode and custom themes.

```dart
// Correct
final color = context.colors.primary.base;
final gap = context.spacing.md;
final radius = context.radius.lg;

// Wrong. Do not do this.
final color = const Color(0xFF3B82F6);
```

The one exception is passing a brand color into a theme, where a literal color
is the whole point.

### Add an accessibility label to every interactive widget

Every widget a user can tap needs a `label` or a `semanticLabel`. Icon-only
controls always need `semanticLabel`, because they have no visible text.

```dart
OiIconButton(
  icon: OiIcons.edit,
  semanticLabel: 'Edit',
  onTap: edit,
)
```

## Adding a new component

Follow this order when you add a widget.

1. Create the file at `lib/src/components/<category>/oi_<name>.dart`.
2. Write the class as `Oi<Name>` with a `const` primary constructor.
3. Add factory constructors for the visual variants.
4. Read all colors, spacing, and radius from the theme. No hardcoded values.
5. Add a `label` or `semanticLabel` to every interactive part.
6. Write a dartdoc comment with a short usage example.
7. Export the class from `lib/obers_ui.dart`.
8. Add a widget test and a golden test (see below).

### Component template

```dart
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

/// A brief description of the widget.
///
/// ```dart
/// OiExample(
///   child: OiLabel.body('Hello'),
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

Test files mirror the source tree. A widget at
`lib/src/components/buttons/oi_button.dart` has its test at
`test/src/components/buttons/oi_button_test.dart`.

| Type | Location | Purpose |
| --- | --- | --- |
| Widget tests | `test/src/components/` | Behavior, interaction, accessibility |
| Golden tests | `test/src/golden/` | Visual regression across light, dark, and breakpoints |
| Model tests | `test/src/models/` | Data model logic |

### Pump helpers

Tests wrap widgets in `OiApp` with the helpers in `test/helpers/`. Use
`pumpObers` for the common case. It is a `WidgetTester` extension, so you call
it on `tester`.

```dart
testWidgets('renders the label', (tester) async {
  await tester.pumpObers(
    OiButton.primary(label: 'Save', onTap: () {}),
  );

  expect(find.text('Save'), findsOneWidget);
});
```

`pumpObers` takes an optional `theme` and `surfaceSize`.

```dart
// Test in dark mode
await tester.pumpObers(widget, theme: OiThemeData.dark());

// Test at a fixed surface size
await tester.pumpObers(widget, surfaceSize: const Size(400, 800));
```

For platform-specific and responsive tests, use the top-level helpers in
`test/helpers/platform_helpers.dart`. Each one takes the `WidgetTester` as its
first argument.

```dart
// Simulate a touch device
await pumpTouchApp(tester, widget);

// Simulate a pointer device
await pumpPointerApp(tester, widget);

// Pump at a specific breakpoint
await pumpAtBreakpoint(tester, widget, kMediumWidth);
```

### Running tests

```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# A single test file
flutter test test/src/components/buttons/oi_button_test.dart

# Golden tests only
flutter test test/src/golden/

# Update golden files after an intended visual change
flutter test --update-goldens
```

!!! warning
    Only run `--update-goldens` when you meant to change how a widget looks.
    Review the new images in the diff before you commit them.

## Keep the docs in sync

The library ships two sources of documentation. Update both when you add,
change, or remove a widget.

- `AI_README.md` at the repo root is the widget catalog. It lists every widget,
  its parameters, and its usage patterns. Update the widget's entry and the tags
  index when its API changes.
- The docs site under `doc/documentation/docs/` is built with MkDocs. Update the
  relevant page so the public docs match the code.

A pull request that changes a public API but leaves these out of date is not
complete.

## Pull request checklist

- [ ] All tests pass (`flutter test`)
- [ ] Analysis passes (`dart analyze --fatal-infos`)
- [ ] Code is formatted (`dart format .`)
- [ ] Golden files updated if visuals changed
- [ ] New components have widget tests and golden tests
- [ ] Public APIs have dartdoc comments
- [ ] `AI_README.md` and the docs site are in sync

## Questions or issues

Open an issue on [GitHub](https://github.com/SimonErich/obers_ui/issues).

## Related

- [Project Structure](../getting-started/project-structure.md) for the full directory layout.
- [Extending themes](../theming/extending-themes.md) for the theme tokens your widgets read.
- [AI README](ai-readme.md) for the widget catalog you keep in sync.
