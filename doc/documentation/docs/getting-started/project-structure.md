# Structuring Your App

This page shows how to organize an app that uses ObersUI. It covers how the
library is built, then gives practical advice for laying out your own code.

## One import

Everything comes from a single barrel file:

```dart
import 'package:obers_ui/obers_ui.dart';
```

That is the only import you need. All widgets, theme tokens, models, and
utilities are exported from here.

## How the library is built

ObersUI is built in five layers. Foundation sits underneath, and each UI tier
builds on the one below it. A tier only imports from the tier under it.

| Layer | What lives here | Example |
| --- | --- | --- |
| Foundation | Theme, `OiApp`, overlays, responsive, accessibility, persistence | `OiThemeData`, `OiApp` |
| Primitives | Single-purpose building blocks | `OiLabel`, `OiSurface`, `OiRow`, `OiGrid` |
| Components | Standard interactive widgets | `OiButton`, `OiTextInput`, `OiDialog` |
| Composites | Multi-component patterns | `OiTable`, `OiForm`, `OiCalendar` |
| Modules | Full-feature screens | `OiKanban`, `OiChat`, `OiFileExplorer` |

You do not need to memorize the tiers. The rule that matters when you build a
screen is this: pick the highest tier that fits. If a Module does the whole job,
use it. If you need a Composite, use that. Drop down to Primitives only when
nothing higher matches.

## Set the theme once

Wrap your app in `OiApp` and set the theme there. Every `Oi` widget reads its
colors, spacing, and radius from this theme, so you set it in one place and the
whole app stays consistent.

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

To brand the app, generate a full palette from one color:

```dart
OiApp(
  theme: OiThemeData.fromBrand(color: Color(0xFF8B6914)),
  home: const HomeScreen(),
)
```

Passing a brand color to `OiThemeData.fromBrand` is the one place a raw `Color`
belongs. Everywhere else, read colors from the theme with `context.colors`.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `home` | `Widget` | **required** | The root widget. Use `OiApp.router` instead for declarative routing. |
| `theme` | `OiThemeData?` | `null` | The light theme. Falls back to `OiThemeData.light()`. |
| `darkTheme` | `OiThemeData?` | `null` | The dark theme. When null, `theme` is used for both modes. |
| `themeMode` | `OiThemeMode` | `system` | Which theme to use: `light`, `dark`, or `system`. |
| `settingsDriver` | `OiSettingsDriver?` | `null` | Global persistence driver for widgets that store settings. |
| `title` | `String` | `''` | The app title. |

!!! note
    Use `OiApp.router` when you wire up a router such as `go_router`. Pass your
    `RouterConfig` as `routerConfig`. All the theme parameters work the same way.

## Build screens from OiPage and OiSection

`OiPage` is the outer layout for a screen. `OiSection` groups related content
inside it. Both space their children with a `gap` and both need the active
breakpoint, which you read once with `context.breakpoint` and pass down.

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OiPage(
      breakpoint: context.breakpoint,
      gap: const OiResponsive<double>(24),
      children: [
        OiLabel.h1('Dashboard'),
        OiSection(
          breakpoint: context.breakpoint,
          semanticLabel: 'Recent activity',
          gap: const OiResponsive<double>(12),
          children: [
            OiLabel.h2('Recent activity'),
            OiLabel.body('Nothing new today.'),
          ],
        ),
      ],
    );
  }
}
```

`OiPage` stretches its children to full width by default. `OiSection` shrink-wraps
its children, so it nests inside other layouts without constraint errors.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `breakpoint` | `OiBreakpoint` | **required** | Active breakpoint. Read it with `context.breakpoint`. |
| `children` | `List<Widget>` | **required** | The content, spaced by `gap`. |
| `gap` | `OiResponsive<double>` | `0` | Space between children in logical pixels. |
| `padding` | `OiResponsive<EdgeInsetsGeometry>?` | `null` | Padding around the content. |
| `semanticLabel` | `String?` | `null` | `OiSection` only. Announced by screen readers. |

## Reach for a Module first

Before you hand-build a feature, check the Modules tier. A Module is a full
feature in one widget. A chat view, a Kanban board, a file explorer, a data list.
If one fits, you save a lot of wiring and you get theming and accessibility for
free.

Work down from there. If no Module fits, look at Composites like `OiTable` or
`OiForm`. If none of those fit, compose Components and Primitives yourself.

## Keep to the Oi widgets

Stay inside the ObersUI widget set so theming stays consistent.

- Use `OiLabel` for text, never raw `Text`.
- Use `OiRow`, `OiColumn`, and `OiGrid` for layout, never raw `Row` or `Column`.
- Read colors from `context.colors`, spacing from `context.spacing`, radius from
  `context.radius`. Never hardcode a color.
- Give every interactive widget a `label` or `semanticLabel`.

```dart
OiRow(
  breakpoint: context.breakpoint,
  gap: const OiResponsive<double>(8),
  children: [
    OiButton.primary(label: 'Save', onTap: () => save()),
    OiButton.outline(label: 'Cancel', onTap: () => cancel()),
  ],
)
```

When you mix raw Flutter widgets into a screen, they stop following the theme.
Colors and spacing drift, and dark mode breaks. Staying with the `Oi` widgets
keeps the whole screen in sync.

## A folder layout for your app

ObersUI does not dictate your app structure. A feature-first layout works well
and keeps related code together:

```text
lib/
├── main.dart                 # runApp(OiApp(...))
├── app/
│   ├── theme.dart            # your OiThemeData setup
│   └── router.dart           # routes, if you use a router
└── features/
    ├── dashboard/
    │   ├── dashboard_screen.dart
    │   └── widgets/          # small OiSection-based pieces
    └── settings/
        ├── settings_screen.dart
        └── widgets/
```

Keep the theme in one file under `app/`. Give each feature its own folder. Put
screen-level widgets at the feature root and smaller pieces under `widgets/`.

## Related

- [Component Tiers](../core-concepts/component-tiers.md) for how the tiers fit together.
- [Core Concepts](../core-concepts/index.md) for theming and responsiveness.
- [Buttons & Actions](../widgets/buttons.md) for the everyday action widgets.
