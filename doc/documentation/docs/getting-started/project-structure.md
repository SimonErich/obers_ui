# Project Structure

Understanding how ObersUI is organized helps you find what you need quickly.

## Import

Everything is exported from a single barrel file:

```dart
import 'package:obers_ui/obers_ui.dart';
```

That's the only import you need. All widgets, tokens, utilities, and models are available from this single entry point.

## Source layout

```
lib/
├── obers_ui.dart              # Barrel export — import this
└── src/
    ├── foundation/            # Core services & theming
    │   ├── theme/             # Design tokens & theme data
    │   └── persistence/       # Settings drivers
    ├── primitives/            # Tier 1: Low-level building blocks
    ├── components/            # Tier 2: Standard UI components
    ├── composites/            # Tier 3: Multi-component patterns
    ├── modules/               # Tier 4: Full-feature screens
    ├── models/                # Data classes & settings
    ├── tools/                 # Theme preview & export utilities
    └── utils/                 # Helper functions
```

## The four tiers

ObersUI follows a strict composition hierarchy. Each tier builds on the one below:

| Tier | Directory | Purpose | Example |
| --- | --- | --- | --- |
| **Foundation** | `foundation/` | Theme, accessibility, overlays, persistence | `OiThemeData`, `OiA11yScope` |
| **Primitives** | `primitives/` | Single-purpose rendering widgets | `OiTappable`, `OiGrid`, `OiShimmer` |
| **Components** | `components/` | Standard interactive widgets | `OiButton`, `OiTextInput`, `OiDialog` |
| **Composites** | `composites/` | Multi-component combinations | `OiTable`, `OiCalendar`, `OiSearch` |
| **Modules** | `modules/` | Complete feature screens | `OiFileExplorer`, `OiChat`, `OiKanban` |

Learn more in [Component Tiers](../core-concepts/component-tiers.md).

## Component categories

Within each tier, widgets are grouped by function:

- **buttons/** — `OiButton`, `OiIconButton`, `OiToggleButton`, `OiButtonGroup`
- **inputs/** — `OiTextInput`, `OiCheckbox`, `OiSelect`, `OiSlider`, ...
- **display/** — `OiCard`, `OiAvatar`, `OiBadge`, `OiProgress`, ...
- **navigation/** — `OiTabs`, `OiAccordion`, `OiDrawer`, `OiBreadcrumbs`, ...
- **overlays/** — `OiDialog`, `OiSheet`, `OiToast`, `OiContextMenu`
- **panels/** — `OiPanel`, `OiResizable`, `OiSplitPane`
- **feedback/** — `OiStarRating`, `OiSentiment`, `OiThumbs`, ...
- And many more...

## Other directories

| Directory | Purpose |
| --- | --- |
| `widgetbook/` | Interactive component showcase (separate Flutter app) |
| `example/` | Minimal example app |
| `test/` | Widget tests, golden tests, integration tests, benchmarks |
| `doc/` | Generated API docs and this documentation |
| `concept/` | Design specs and requirements |

## Next steps

- [Core Concepts](../core-concepts/index.md) — Architecture, theming, responsiveness
- [Components](../components/index.md) — Browse the full widget catalog
