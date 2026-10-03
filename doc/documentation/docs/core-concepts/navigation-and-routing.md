# Navigation & Routing

ObersUI has no Material dependency, so it does not give you `MaterialPageRoute` or
`MaterialApp`. Instead you run your app with `OiApp`, and you move between screens
with `OiPageRoute` or, when you use a router package, with `OiTransitionPage`. This
page shows both setups and the transitions you can pick from.

| Piece | What it does |
| --- | --- |
| `OiApp` | The root widget. Use `home` for simple apps. |
| `OiApp.router` | The root widget for go_router or auto_route. |
| `OiPageRoute` | A page route with five transitions, for `Navigator.push`. |
| `OiTransitionPage` | A `Page` you return from a go_router route. |
| `OiPageTransitionType` | The enum of transition styles. |
| `OiBackButton` | The back chevron for your screen headers. |

## Two ways to run the app

You pick how routing works when you create `OiApp`. There are two constructors.

For a simple app, pass a `home` widget. You then navigate with `Navigator`.

```dart
void main() {
  runApp(
    OiApp(
      theme: OiThemeData.light(),
      darkTheme: OiThemeData.dark(),
      themeMode: OiThemeMode.system,
      home: const HomeScreen(),
    ),
  );
}
```

For a router package like go_router or auto_route, use `OiApp.router` and pass a
`routerConfig`. Everything else, theme, density, locale, works the same.

```dart
final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/details', builder: (context, state) => const DetailsScreen()),
  ],
);

void main() {
  runApp(
    OiApp.router(
      theme: OiThemeData.light(),
      routerConfig: _router,
    ),
  );
}
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `home` | `Widget` | **required** (default constructor) | The first screen. |
| `routerConfig` | `RouterConfig<Object>` | **required** (`.router` constructor) | Your router, for example a `GoRouter`. |
| `theme` | `OiThemeData?` | `OiThemeData.light()` | The light theme. |
| `darkTheme` | `OiThemeData?` | `null` | The dark theme. Falls back to `theme` when null. |
| `themeMode` | `OiThemeMode` | `system` | `light`, `dark`, or `system`. |
| `density` | `OiDensity?` | auto-detected | `comfortable`, `compact`, or `dense`. |
| `locale` | `Locale?` | `null` | The active locale. Drives text direction. |
| `supportedLocales` | `Iterable<Locale>` | `[Locale('en', 'US')]` | Locales your app supports. |
| `title` | `String` | `''` | The app title. |

!!! note
    `home` and `routerConfig` are mutually exclusive. Each constructor sets the
    other to `null` for you, so you never pass both.

## OiPageRoute

A page route with configurable transitions and no Material dependency. Reach for it
when you navigate imperatively with `Navigator.push` and no router package.

```dart
Navigator.of(context).push(
  OiPageRoute<void>(
    builder: (context) => const DetailsScreen(),
    transition: OiPageTransitionType.slideHorizontal,
  ),
);
```

To read the default transition and duration from the theme, use the `OiPageRoute.of`
factory instead of the constructor. It looks up the nearest `OiTheme` and pulls the
values from `OiAnimationConfig`.

```dart
Navigator.of(context).push(
  OiPageRoute.of(
    context: context,
    builder: (context) => const DetailsScreen(),
  ),
);
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `builder` | `Widget Function(BuildContext)` | **required** | Builds the page content. |
| `transition` | `OiPageTransitionType` | `fade` | The transition style. |
| `transitionDuration` | `Duration?` | `250 ms` | Forward transition length. |
| `reverseTransitionDuration` | `Duration?` | `200 ms` | Reverse transition length. |
| `maintainState` | `bool` | `true` | Keep the route in memory when hidden. |
| `fullscreenDialog` | `bool` | `false` | Present as a full-screen dialog. |
| `barrierColor` | `Color?` | `null` | Color behind the page during the transition. |
| `barrierDismissible` | `bool` | `false` | Whether a tap outside pops the route. |

!!! note
    When the platform has "reduce motion" turned on, every transition falls back to
    an instant swap. You do not handle that yourself.

## OiTransitionPage

A `Page` subclass that builds an `OiPageRoute` under the hood. Return it from a
go_router route when you want a custom transition on that route.

```dart
GoRoute(
  path: '/details',
  pageBuilder: (context, state) => const OiTransitionPage<void>(
    child: DetailsScreen(),
    transition: OiPageTransitionType.slideVertical,
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | **required** | The page content. |
| `transition` | `OiPageTransitionType` | `fade` | The transition style. |
| `transitionDuration` | `Duration?` | `250 ms` | Forward transition length. |
| `reverseTransitionDuration` | `Duration?` | `200 ms` | Reverse transition length. |
| `maintainState` | `bool` | `true` | Keep the route in memory when hidden. |
| `fullscreenDialog` | `bool` | `false` | Present as a full-screen dialog. |

## OiPageTransitionType

The enum that names the transition. Both `OiPageRoute` and `OiTransitionPage` take it.

```dart
OiPageTransitionType.fade             // cross-fade, the default
OiPageTransitionType.slideHorizontal  // slides in from the side, flips for RTL
OiPageTransitionType.slideVertical    // slides up from the bottom
OiPageTransitionType.scaleUp          // fades in while scaling up
OiPageTransitionType.none             // instant swap, no animation
```

The defaults for a route come from the theme. `OiAnimationConfig` holds
`defaultPageTransition` and `pageTransitionDuration`. Set them once on your
`OiThemeData` and every `OiPageRoute.of` call follows suit.

## OiBackButton

The back affordance for your screen headers. It draws a chevron that points left,
and flips to point right in right-to-left layouts. Wire `onPressed` to pop the route.

```dart
OiRow(
  children: [
    OiBackButton(
      onPressed: () => Navigator.of(context).pop(),
      semanticLabel: 'Go back',
    ),
    OiLabel.h2('Details'),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `onPressed` | `VoidCallback` | **required** | Called on tap. |
| `semanticLabel` | `String` | **required** | Screen-reader text. |
| `color` | `Color?` | `null` | Overrides the icon color. |
| `size` | `double` | `24.0` | Icon size in logical pixels. |

## Related

- [Theming](theming.md) for `OiAnimationConfig` and transition defaults.
- [Buttons & Actions](../widgets/buttons.md) for `OiBackButton` and other navigation controls.
- [Responsive](responsive.md) for adapting screens across breakpoints.
