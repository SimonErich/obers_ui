# ObersUI — Developer Context

## Project Overview

**obers_ui** is a comprehensive Flutter UI library with 160+ widgets organized in a 4-tier architecture (Foundation → Primitives → Components → Composites → Modules). It has **zero Material/Cupertino dependency** — all widgets are built from scratch.

## Single Import

```dart
import 'package:obers_ui/obers_ui.dart';
```

All public APIs are exported through this single barrel file.

## Key Conventions

- **Oi prefix** — All public classes use the `Oi` prefix (e.g., `OiButton`, `OiCard`, `OiTable`)
- **Factory constructors** — Variants use named constructors (e.g., `OiButton.primary()`, `OiBadge.soft()`)
- **Theme-driven styling** — Never hardcode colors. Use `context.colors`, `context.spacing`, `context.radius`
- **OiLabel instead of Text** — All text display uses `OiLabel.variant()`, never raw `Text()`
- **OiRow/OiColumn instead of Row/Column** — Layout primitives with responsive gap and collapse
- **Required accessibility labels** — Every interactive widget requires a `label` or `semanticLabel`

## AI Integration Guide

**Read `AI_README.md` for the complete widget catalog and integration reference.** This file documents every widget, its parameters, usage patterns, best practices, anti-patterns, and a searchable tags index. Keep this file in sync whenever widgets are added, modified, or removed.

## Documentation Sync

**Keep the `doc/` folder documentation in sync** when components change, are updated, or are removed. The documentation site lives in `doc/documentation/docs/` and is built with MkDocs.

## Build & Test Commands

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/src/components/buttons/oi_button_test.dart

# Run tests with coverage
flutter test --coverage

# Analyze code
dart analyze

# Format code
dart format .

# Generate API docs
dart doc

# Run the example app
cd example && flutter run

# Run the widgetbook
cd widgetbook && flutter run
```

## Test Conventions

- Test files mirror source: `lib/src/components/buttons/oi_button.dart` → `test/src/components/buttons/oi_button_test.dart`
- Use `pumpObers(widget)` helper to wrap widgets in `OiApp` for testing
- Use `pumpTouchApp()` / `pumpPointerApp()` for platform-specific tests
- Use `pumpAtBreakpoint()` for responsive tests
- Golden tests go in `test/src/golden/`
- Model tests go in `test/src/models/`

## Dependencies

- Flutter >=3.41.0, Dart >=3.11.0
- `file_picker`, `intl`, `shared_preferences`, `web`
- Dev: `golden_toolkit`, `mocktail`, `very_good_analysis`

## Architecture

```
Tier 0: Foundation    — OiApp, theme, overlays, responsive, persistence
Tier 1: Primitives    — OiLabel, OiSurface, OiTappable, OiGrid, OiRow, OiColumn, ...
Tier 2: Components    — OiButton, OiTextInput, OiCard, OiDialog, OiTabs, ...
Tier 3: Composites    — OiTable, OiForm, OiSidebar, OiCalendar, OiGantt, ...
Tier 4: Modules       — OiListView, OiKanban, OiChat, OiFileExplorer, OiDashboard, ...
```

Each tier only imports from the tier below. No circular dependencies.
