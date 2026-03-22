# Plan: Migrate from old UIKit/Material to UIKit Obers

## Context

The Qatery Flutter app is migrating from an old shadcn-based UIKit (`lib/uikit/`) and direct Material widget usage to the new obers_ui-based UIKit Obers (`lib/uikit_obers/`). The import migration from old uikit barrel is complete (0 feature/core files import old uikit), but **809 feature files** still import `flutter/material.dart` and use Material widgets directly. The old `uikit/` directory (200 files) still exists. Additionally, 95 files inside `uikit_obers/` itself use full `material.dart` imports instead of selective ones, and 26 test files still reference old uikit.

**Goal**: Zero references to old `lib/uikit/`, zero direct Material widget usage in feature code, all visual elements use `uikit_obers`, then 0 flutter analyze issues, and all patrol tests pass.

---

## Scope Summary

| Area | File Count | Work Type |
|------|-----------|-----------|
| Feature files with `flutter/material.dart` | 809 | Replace Material widgets with uikit_obers equivalents |
| Core files with `flutter/material.dart` | 11 | Selective imports for ThemeMode, Navigator etc. |
| uikit_obers internal `material.dart` | 95 | Convert to selective `show` imports |
| Test files importing old `uikit/` | 26 | Switch imports to `uikit_obers` |
| Old `uikit/` directory | 200 files | Delete entirely |
| Documentation | CLAUDE.md + new skill | Update rules and create skill |

---

## Phase 0: Documentation & Tooling (do first)

### 0A. Update CLAUDE.md
- Replace all `lib/uikit/` references with `lib/uikit_obers/`
- Replace shadcn_uikit.txt reference with `OBERS_UI_LIBRARY_AI_DOCS.md`
- Rewrite "UIKit Only" section → "UIKit Obers Only" with architecture: `feature code → uikit_obers → obers_ui`
- Add rule: always check `OBERS_UI_LIBRARY_AI_DOCS.md` before creating/extending uikit_obers widgets
- Add "Widget Size and Composition" section (max 300 lines, extract sub-widgets)
- Update Anti-Patterns: add "NEVER import obers_ui directly in feature code", "NEVER exceed 300 lines per widget"
- Update accessibility key file paths to uikit_obers paths

### 0B. Create skill `.claude/skills/uikit-obers/SKILL.md`
- Three-layer architecture explanation (feature → uikit_obers → obers_ui)
- `_obers_imports.dart` abstraction barrier
- How to create components (wrapping obers_ui) vs widgets (composed)
- Templates with correct import patterns
- 300-line max rule and sub-widget extraction
- Design token quick reference
- Handling missing obers_ui primitives (create TODO)
- Pre-flight checklist

---

## Phase 1: Expand UiIcons (blocks Phase 3)

**File**: `qatery_flutter/lib/uikit_obers/utils/ui_icons.dart`

Currently has ~149 icon constants but features use `Icons.xxx` extensively (potentially 2,000+ unique icons). Strategy:
1. Extract all unique `Icons.xxx` names used across the codebase
2. Auto-generate corresponding `UiIcons.xxx` constants (same IconData code points, `MaterialIcons` font family)
3. Split into multiple files if >500 lines (e.g., `ui_icons_navigation.dart`, `ui_icons_action.dart`, etc.)

This is fully automatable with a Dart/shell script.

---

## Phase 2: Delete Old UIKit

Since 0 feature/core files import old uikit (only self-references and 26 test files):
1. Update 26 test files: change `import 'package:qatery_flutter/uikit/` → `import 'package:qatery_flutter/uikit_obers/`
2. `git rm -r qatery_flutter/lib/uikit/` — removes 200 files
3. Remove any old uikit references in pubspec, analysis_options, etc.
4. Run `flutter analyze` to verify no breakage

---

## Phase 3: Feature Code Material Migration (809 files)

### Strategy: Three-tier approach

**Tier 1 — Automated (estimated ~500 files)**: Files where material.dart is imported only for base types or simple widget usage
- Script: Replace `import 'package:flutter/material.dart'` with `import 'package:flutter/widgets.dart'`
- Script: Replace `Icons.xxx` → `UiIcons.xxx` (after Phase 1)
- Script: Replace `Colors.xxx` → `UiDesignColors.xxx` or literal `Color(0xFFxxxxxx)`
- Run in batches per feature directory, `flutter analyze` after each batch

**Tier 2 — Semi-automated (~200 files)**: Files using common Material widgets with direct uikit_obers equivalents
- `Card(...)` → `UiCard(...)`
- `Divider()` → `UiDivider()`
- `IconButton(...)` → `UiIconButton(...)`
- `Switch(...)` → `UiSwitch(...)`
- `Checkbox(...)` → `UiCheckbox(...)`
- `Radio(...)` → `UiRadio(...)`
- `TextField(...)` / `TextFormField(...)` → `UiTextField(...)`
- `Dialog(...)` → `UiDialogShell(...)`
- `InkWell(...)` → `GestureDetector(...)` (from widgets.dart) or `UiTappable(...)`

**Tier 3 — Manual/AI-assisted (~109 files)**: Complex patterns requiring per-file review
- `DropdownButtonFormField` / `DropdownButton` + `DropdownMenuItem` → `UiComboSearch<T>` or new `UiSelect<T>`
- `showDialog(...)` → keep with selective `show` import: `import 'package:flutter/material.dart' show showDialog, Navigator;`
- `showDatePicker(...)` → `UiDateRangePicker` or selective import
- `TabBarView` / `DefaultTabController` → `UiTabBar` or selective import
- `DataTable` / `DataRow` / `DataCell` → `UiDataTable`
- `InputDecoration` → remove (handled internally by UiTextField)
- `Material(...)` wrapper → remove or use `UiSurface`

### Selective Material Imports (acceptable pattern)
For Material-only functions with no pure-widgets equivalent:
```dart
import 'package:flutter/material.dart' show Navigator, showDialog, showDatePicker;
import 'package:flutter/widgets.dart';
```
This is the established pattern already used in uikit_obers (see `ui_confirm_dialog.dart`).

### Missing uikit_obers Widgets (create with TODO)
When no uikit_obers equivalent exists and we can't compose from obers_ui:
1. Create widget in `uikit_obers/widgets/`
2. Add large TODO comment explaining what obers_ui element is needed
3. Export from `uikit_obers.dart` barrel

---

## Phase 4: UIKit Obers Internal Cleanup (95 files)

95 files inside `uikit_obers/` itself use full `material.dart` imports. Convert each to:
- `import 'package:flutter/widgets.dart'` for base types
- `import 'package:flutter/material.dart' show X, Y;` only for Material-specific types that have no obers_ui equivalent
- Import obers_ui through `_obers_imports.dart` only

---

## Phase 5: Core + Main Files (11 files)

- Theme files (6): Keep `material.dart` with selective `show ThemeMode`
- Navigation route screens (2): Keep `show Navigator` if needed
- `global_error_boundary.dart`, `auth_state_listener.dart`, `order_status_mapper.dart`: Audit and apply selective imports

---

## Phase 6: Widget Size Compliance

After migration is complete, audit widgets > 300 lines:
1. `find` all .dart files > 300 lines in `lib/features/` and `lib/uikit_obers/`
2. For each, extract sub-build methods into private `_SubWidget` classes
3. Priority: largest files first (admin screens are 2,000-3,000 lines)

---

## Phase 7: Verification

1. `dart fix --apply` across all packages
2. `dart format --set-exit-if-changed` across all packages
3. `flutter analyze` → must be 0 errors, 0 warnings, 0 infos
4. `dart analyze` on qatery_server and qatery_client → 0 issues
5. Grep verification: `rg "import 'package:flutter/material\.dart'" qatery_flutter/lib/features/` should return ONLY selective `show` imports
6. `bash scripts/verification/verify_wi_0018.sh` must pass
7. `flutter test` → all pass
8. Start Docker services, run patrol tests via patrol script with Chrome

---

## Execution Order

1. **Phase 0**: CLAUDE.md + skill (no code dependencies)
2. **Phase 1**: Expand UiIcons (enables Tier 1 of Phase 3)
3. **Phase 2**: Delete old uikit/ (26 test file updates)
4. **Phase 3 Tier 1**: Automated import swaps (~500 files)
5. **Phase 3 Tier 2**: Semi-automated widget replacements (~200 files)
6. **Phase 3 Tier 3**: Manual complex migrations (~109 files)
7. **Phase 4**: uikit_obers internal cleanup (95 files)
8. **Phase 5**: Core + main files (11 files)
9. **Phase 6**: Widget size compliance (separate pass)
10. **Phase 7**: Full verification pipeline

---

## Critical Files

- `qatery_flutter/lib/uikit_obers/utils/ui_icons.dart` — expand icon constants
- `qatery_flutter/lib/uikit_obers/_obers_imports.dart` — import abstraction layer
- `qatery_flutter/lib/uikit_obers/uikit_obers.dart` — barrel file for new exports
- `qatery_flutter/lib/uikit_obers/theme/ui_design_tokens.dart` — color/spacing tokens
- `qatery_flutter/lib/uikit_obers/widgets/ui_confirm_dialog.dart` — reference pattern for selective material imports
- `CLAUDE.md` — update documentation
- `.claude/skills/uikit-obers/SKILL.md` — new skill to create
- `scripts/verification/verify_wi_0018.sh` — final verification script

---

## Key Decisions

1. **`flutter/material.dart` selective `show` imports are acceptable** for Navigator, showDialog, showDatePicker, ThemeMode, DefaultTabController — these have no pure-widgets equivalent
2. **All `Icons.xxx` → `UiIcons.xxx`** — even though they use the same MaterialIcons font, the abstraction through UiIcons is required
3. **All `Colors.xxx` → `UiDesignColors.xxx`** or `Color(0xFF...)` literals for non-semantic colors
4. **Feature code must NEVER import obers_ui directly** — always through uikit_obers
5. **Widget > 300 lines must be refactored** — but as a separate pass after the migration to avoid merge conflicts
