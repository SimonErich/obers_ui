# obers_ui

[![CI](https://github.com/simonerich/obers_ui/actions/workflows/ci.yml/badge.svg)](https://github.com/simonerich/obers_ui/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A comprehensive Flutter UI kit with design tokens, responsive utilities, and accessible components. It ships 250+ widgets across five tiers, from low-level primitives to full-screen modules, plus a charts package and an auto-forms package. It has zero Material or Cupertino dependency. Every widget is built from scratch and styled by one theme.

*"Obers"* is the Austrian word for cream. The idea is the same: pour it in and everything gets a little smoother.

## Highlights

- **250+ widgets** across primitives, components, composites, and modules.
- **Design tokens** for color, typography, spacing, radius, shadows, and motion.
- **Responsive** with 5 breakpoints, adaptive layouts, and density modes.
- **Accessible** by default: required labels, 48dp touch targets, reduced-motion support.
- **Persistent settings** through pluggable drivers (column widths, sort, filters, layout).
- **Charts** in the companion `obers_ui_charts` package (30+ chart types).
- **No Material required.** You use `OiApp`, not `MaterialApp`.

## Installation

Add `obers_ui` to your `pubspec.yaml` as a git dependency:

```yaml
dependencies:
  obers_ui:
    git:
      url: https://github.com/simonerich/obers_ui.git
```

For local development, use a path instead:

```yaml
dependencies:
  obers_ui:
    path: ../obers_ui
```

Requires Flutter 3.41.0 or newer and Dart 3.11.0 or newer.

## Quick start

One import gives you the whole library:

```dart
import 'package:obers_ui/obers_ui.dart';

void main() {
  runApp(
    OiApp(
      theme: OiThemeData.fromBrand(color: Color(0xFF8B6914)),
      home: OiPage(
        breakpoint: OiBreakpoint.compact,
        children: [
          OiLabel.h1('Hello, ObersUI'),
          OiButton.primary(
            label: 'Get started',
            onTap: () {},
          ),
        ],
      ),
    ),
  );
}
```

`OiApp` sits at the root and provides the theme, overlays, responsive info, and more. Every widget below it reads colors and spacing from the theme, so your app stays consistent without extra wiring.

## A few conventions

- Every public class uses the `Oi` prefix (`OiButton`, `OiCard`, `OiTable`).
- Variants come from named constructors (`OiButton.primary()`, `OiBadge.soft()`).
- Use `OiLabel.body('...')` instead of `Text('...')`.
- Use `OiRow` / `OiColumn` / `OiGrid` instead of `Row` / `Column` / `GridView`.
- Read colors and spacing from the theme (`context.colors`, `context.spacing`), never hardcode them.
- Interactive widgets take a `label` or `semanticLabel` for accessibility.

## Documentation

Full documentation lives in [`doc/documentation`](doc/documentation) and is built with MkDocs.

```bash
cd doc/documentation
pip install mkdocs-material mkdocs-minify-plugin
mkdocs serve
```

Then open <http://127.0.0.1:8000>.

The [`AI_README.md`](AI_README.md) at the repo root is a single-file reference tuned for AI coding assistants. It lists every widget with parameters, tags, and usage rules.

## Packages

- `obers_ui` — the core library (this package).
- [`packages/obers_ui_charts`](packages/obers_ui_charts) — 30+ chart types built on the same theme.
- [`packages/obers_ui_autoforms`](packages/obers_ui_autoforms) — controller-first, schema-driven forms.

## Example and widgetbook

```bash
cd example && flutter run       # the example gallery app
cd widgetbook && flutter run    # component workbench
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for setup and guidelines.

## License

MIT License. See [LICENSE](LICENSE).
