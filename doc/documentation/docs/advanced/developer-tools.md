# Developer Tools

These are the tools you use while building, not the widgets you ship to users.
They help you browse components, look at a theme, export a theme, swap themes at
runtime, and open a debug menu inside a running app. Two companion apps round
things out: the example app and the widgetbook.

| Tool | What it does |
| --- | --- |
| `OiPlayground` | A component sandbox you drop into an app to browse widgets by category. |
| `OiThemePreview` | Renders sample components so you can see a theme at a glance. |
| `OiThemeExporter` | Exports an `OiThemeData` to JSON or to Dart source. |
| `OiDynamicTheme` | Builds a theme from a single brand color at runtime. |
| `OiDevMenu` | An in-app developer overlay with environments, flags, actions, and logs. |

## OiPlayground

A storybook-style panel that lists components by category and shows live
samples. Drop it into a screen in your example app when you want to click
through widgets and flip between light and dark.

```dart
OiPlayground(
  initialCategory: 'Buttons',
)
```

It ships with its own theme toggle, so you do not need to wire one up. Pass your
own light and dark themes if you want to preview your brand instead of the
defaults.

```dart
OiPlayground(
  theme: OiThemeData.light(),
  darkTheme: OiThemeData.dark(),
  initialCategory: 'Inputs',
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `theme` | `OiThemeData?` | `OiThemeData.light()` | The light theme to preview. |
| `darkTheme` | `OiThemeData?` | `OiThemeData.dark()` | The dark theme to preview. |
| `initialCategory` | `String?` | `'Buttons'` | The category shown first. |

The categories are `Buttons`, `Inputs`, `Display`, `Feedback`, `Overlays`, and
`Navigation`.

## OiThemePreview

Renders a scrollable page of sample components in a theme you pass in: colors,
typography, spacing, buttons, inputs, cards, badges, and progress. Reach for it
when you tweak theme tokens and want to see every change in one view.

```dart
OiThemePreview(
  theme: OiThemeData.light(),
)
```

Each section has a flag, so you can narrow the preview to just the parts you
care about.

```dart
OiThemePreview(
  theme: myTheme,
  showColors: true,
  showTypography: true,
  showSpacing: false,
  showButtons: true,
  showInputs: false,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `theme` | `OiThemeData` | **required** | The theme to preview. |
| `showColors` | `bool` | `true` | Show the color palette section. |
| `showTypography` | `bool` | `true` | Show the typography samples. |
| `showSpacing` | `bool` | `true` | Show the spacing scale. |
| `showButtons` | `bool` | `true` | Show button variants. |
| `showInputs` | `bool` | `true` | Show input samples. |
| `showCards` | `bool` | `true` | Show card variants. |
| `showBadges` | `bool` | `true` | Show badge variants. |
| `showProgress` | `bool` | `true` | Show progress indicators. |

`OiThemePreview` wraps its content in an `OiTheme` for you, so the samples always
resolve their tokens from the `theme` you pass, not from the surrounding app.

## OiThemeExporter

A utility class with static methods. It turns an `OiThemeData` into JSON or Dart
source, and reads a theme back from JSON. Use it to save a theme, share it, or
paste a generated theme straight into your codebase. You do not construct it. You
call its static methods.

```dart
final theme = OiThemeData.light();

// Serialize to a JSON string.
final json = OiThemeExporter.toJson(theme);

// Read it back.
final restored = OiThemeExporter.fromJson(json);

// Generate Dart source you can paste into a file.
final dart = OiThemeExporter.toDart(theme, variableName: 'brandTheme');
```

| Method | Signature | Description |
| --- | --- | --- |
| `toJson` | `String toJson(OiThemeData theme)` | Encodes the theme as an indented JSON string. |
| `toMap` | `Map<String, dynamic> toMap(OiThemeData theme)` | Encodes the theme as a JSON-safe map. |
| `fromJson` | `OiThemeData fromJson(String json)` | Reads a theme from JSON. Falls back to the light theme on bad input. |
| `fromMap` | `OiThemeData fromMap(Map<String, dynamic> map)` | Reads a theme from a map. Missing fields fall back to defaults. |
| `toDart` | `String toDart(OiThemeData theme, {String variableName = 'theme'})` | Generates Dart source that recreates the theme. |

!!! note
    `fromJson` never throws on malformed input. If the string does not parse, it
    returns `OiThemeData.light()`. Check the result if you need to know the load
    failed.

## OiDynamicTheme

A utility class that builds a full theme from a single brand color at runtime.
It wraps `OiThemeData.fromBrand`, so you get a matching palette without hand
picking every token. Use it when the brand color is not known until the app runs,
for example a white-label app that themes itself per tenant.

```dart
// One theme from one color.
final theme = OiDynamicTheme.fromColor(
  context.colors.primary.base,
  brightness: Brightness.light,
);
```

Generate a matched light and dark pair in one call. The result is a record with
`light` and `dark` fields.

```dart
final pair = OiDynamicTheme.fromColorPair(context.colors.accent.base);

OiApp(
  theme: pair.light,
  darkTheme: pair.dark,
  home: const HomeScreen(),
)
```

| Method | Signature | Description |
| --- | --- | --- |
| `fromColor` | `OiThemeData fromColor(Color color, {Brightness brightness, String? fontFamily, OiRadiusPreference radiusPreference})` | One theme from one brand color. |
| `fromColorPair` | `({OiThemeData light, OiThemeData dark}) fromColorPair(Color color, {String? fontFamily, OiRadiusPreference radiusPreference})` | A matched light and dark pair. |
| `fromSeedColor` | `OiThemeData fromSeedColor(Color seedColor, {Brightness brightness})` | A theme from a seed color. |

`brightness` defaults to `Brightness.light` and `radiusPreference` defaults to
`OiRadiusPreference.medium`.

## OiDevMenu

An in-app developer overlay. It has four tabs: an environment switcher, feature
flag toggles, custom action buttons, and a searchable log viewer. Use it to flip
staging on, toggle a flag, or read logs without leaving the app.

Two forms exist. The default constructor renders a standalone panel. `OiDevMenu.trigger`
wraps a child and opens the menu when the user taps it three times in a row.

```dart
// Wrap your app. A triple-tap opens the menu.
OiDevMenu.trigger(
  label: 'Developer menu',
  child: const HomeScreen(),
  environments: const [
    OiDevEnvironment(key: 'prod', label: 'Production', url: 'https://api.app.com'),
    OiDevEnvironment(key: 'staging', label: 'Staging', url: 'https://staging.app.com'),
  ],
  currentEnvironment: 'staging',
  onEnvironmentChange: (key) => switchEnvironment(key),
  featureFlags: const [
    OiFeatureFlag(key: 'new_nav', label: 'New navigation', defaultValue: false),
  ],
  featureFlagValues: _flags,
  onFeatureFlagChange: (key, {required value}) =>
      setState(() => _flags[key] = value),
  actions: [
    OiDevAction(label: 'Clear cache', icon: OiIcons.trash, onTap: clearCache),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the menu. |
| `child` | `Widget` | **required** (`.trigger`) | The widget wrapped by the trigger. |
| `tapCount` | `int` | `3` | Taps within 500 ms to open the menu (trigger mode). |
| `environments` | `List<OiDevEnvironment>` | `const []` | Environment options. |
| `currentEnvironment` | `String?` | `null` | The selected environment key. |
| `onEnvironmentChange` | `ValueChanged<String>?` | `null` | Fires with the chosen environment key. |
| `featureFlags` | `List<OiFeatureFlag>` | `const []` | Flags shown as toggles. |
| `featureFlagValues` | `Map<String, bool>` | `const {}` | Current on/off state per flag key. |
| `onFeatureFlagChange` | `void Function(String key, {required bool value})?` | `null` | Fires when a flag is toggled. |
| `actions` | `List<OiDevAction>` | `const []` | Custom action buttons. |
| `logs` | `List<OiLogEntry>` | `const []` | Entries for the log viewer. |
| `onCopyLogs` | `VoidCallback?` | `null` | Fires when the user taps "Copy all logs". |

The tabs read from small data models:

- `OiDevEnvironment(key, label, url)` for the environment list.
- `OiFeatureFlag(key, label, description, defaultValue)` for the flags.
- `OiDevAction(label, onTap, icon, destructive)` for the action buttons. Set
  `destructive: true` to render an action in the error color.
- `OiLogEntry(message, level, timestamp, source)` for the log viewer, where
  `level` is an `OiLogLevel` (`debug`, `info`, `warning`, `error`).

!!! warning
    `OiDevMenu` is a debug surface. Gate it behind a debug build check so it
    never ships to production users.

## The example and widgetbook apps

Two runnable apps live in the repo, separate from the widget library.

The example app under `example/` is a full app built with ObersUI. Run it to see
the widgets working together in real screens.

```bash
cd example && flutter run
```

The widgetbook app under `widgetbook/` is a per-component catalog. Run it to open
each widget in isolation and toggle its knobs.

```bash
cd widgetbook && flutter run
```

## Related

- [Extending Themes](../theming/extending-themes.md) for building and customizing an `OiThemeData`.
- [Custom Modules](custom-modules.md) for composing your own higher-level widgets.
- [Performance](performance.md) for keeping large screens fast.
