# obers_ui — skill (agents)

Progressive reference: read this file first, then open only the detail pages that match your task. Each detail page maps **names → `lib/src/...` paths** (or autoforms package paths) with one-line roles. For parameter-level API docs and long-form guides, see the root [AI_README.md](../../../AI_README.md) or [doc/documentation/docs/advanced/ai-readme.md](../../../doc/documentation/docs/advanced/ai-readme.md).

## How to use

1. Skim **Overview** and **Rules** below.
2. Pick one or more **Detail files** by workflow (forms vs tables vs shell vs theme).
3. Jump to the listed Dart files in the repo for constructors, parameters, and behavior.

## Overview

**obers_ui** is a Flutter UI kit: themed primitives through full modules, with optional **Shop** and **Admin** widgets where paths include `components/shop`, `components/admin`, `composites/shop`, or `modules` names such as checkout. Apps import a single barrel: [lib/obers_ui.dart](../../../lib/obers_ui.dart).

**Tiers (prefer higher when it fits):**

| Tier | Folder | Role |
|------|--------|------|
| 0 — Foundation | `lib/src/foundation/` | Theme, `OiApp`, overlays, responsive, persistence, routes, a11y |
| 1 — Primitives | `lib/src/primitives/` | Layout, motion, low-level interaction |
| 2 — Components | `lib/src/components/` | Reusable controls and display |
| 3 — Composites | `lib/src/composites/` | Multi-part patterns (tables, shells, editors) |
| 4 — Modules | `lib/src/modules/` | Near-complete screens and flows |

**Source tree (high level):**

```
lib/obers_ui.dart          # public exports
lib/src/foundation/
lib/src/primitives/
lib/src/components/
lib/src/composites/
lib/src/modules/
lib/src/models/
lib/src/tools/
lib/src/utils/
```

## Rules (non-negotiable)

- Use **`import 'package:obers_ui/obers_ui.dart';`** — do not pull Material/Cupertino app chrome (`MaterialApp`, `Scaffold`, `AppBar`, etc.).
- **Text:** `OiLabel` variants, not raw `Text`.
- **Color/spacing:** theme (`context.colors`, `context.spacing`, …), not hardcoded palette values for UI.
- **Tiers:** use the highest-tier widget that matches; do not recompose a module from primitives when a composite exists.
- **Planned / missing:** if something is marked planned in legacy docs, verify it exists in `lib/src` before using.

## Detail files

| File | Open when you… |
|------|----------------|
| [foundation.md](references/foundation.md) | Configure theme, `OiApp`, responsiveness, overlays, settings persistence, navigation transitions |
| [primitives.md](references/primitives.md) | Lay out pages, motion, scroll, gestures, copy/paste, low-level hit targets |
| [components-inputs-actions.md](references/components-inputs-actions.md) | Build forms: buttons, fields, inline edit, selection helpers, shop/admin inputs |
| [components-display-content.md](references/components-display-content.md) | Read-only UI: cards, lists, media, metrics, markdown, skeletons, banners, file dialogs |
| [components-navigation-chrome.md](references/components-navigation-chrome.md) | App chrome: tabs, rails, drawers, dialogs/sheets/toasts, panels |
| [composites-data.md](references/composites-data.md) | Tables, grids, trees, grouped lists, detail layouts, reorderable lists, shop data summaries |
| [composites-patterns.md](references/composites-patterns.md) | Wizards, rich editors, files, media, search, scheduling, workflow, onboarding, shell layout |
| [modules.md](references/modules.md) | Drop-in screens: dashboard, chat, file explorer, settings, checkout, auth, etc. |
| [models-tools-icons.md](references/models-tools-icons.md) | Shared models, settings DTOs, dev tools, utilities, icon registry |
| [autoforms.md](references/autoforms.md) | **`obers_ui_autoforms`** package: `OiAf*` controller-driven forms |

## Related packages

- **`obers_ui_charts`**: chart widgets live in a sibling package (not listed path-by-path here); see package exports and [AI_README.md](../../../AI_README.md) tag `chart` if present.
