# Plan: WI-0003 Architecture & Chart Taxonomy (Delta Fix)

## Concept

Add the missing architecture enforcement test that scans import statements across all tiers and asserts: (1) no file imports from a higher tier, (2) no file imports `package:flutter/material.dart` or `package:flutter/cupertino.dart`. This is the sole remaining gap from the previous iteration — all source code, barrel exports, and tier structure are already in place and correct.

## Sub-tasks

ST1: Create `packages/obers_ui_charts/test/src/architecture/tier_import_test.dart` — a Dart test that reads all `.dart` files under `lib/src/`, classifies each file into its tier (foundation=0, primitives=1, components=2, composites=3, modules=4), extracts `import` statements referencing `package:obers_ui_charts/src/`, maps each imported path to its tier, and asserts the imported tier ≤ the file's own tier. Also asserts zero `material.dart` or `cupertino.dart` imports across all files.

ST2: Run the test to confirm it passes against the current codebase.

ST3: Run full `dart analyze` and `dart format` checks for the charts package.

## Method signatures

- No new public classes or methods. This is a pure test file.
- Test groups:
  - `group('Tier import rules')` — contains one test per tier verifying downward-only imports
  - `group('No Material/Cupertino')` — single test scanning all files for forbidden imports

Helper functions within the test file:
- `int tierForPath(String relativePath)` — returns tier number 0–4 from path segment
- `String tierName(int tier)` — returns human-readable tier name
- `List<String> extractPackageImports(String fileContent)` — parses import lines for `package:obers_ui_charts/src/` paths

## Edge cases and fallbacks

- **Empty modules tier**: The modules directory currently has only `.gitkeep`. The test should handle directories with no `.dart` files gracefully (skip or pass trivially).
- **Relative imports**: Files could use relative imports (`import '../foundation/...'`) instead of package imports. The test must handle both forms.
- **Self-tier imports**: A composites file importing another composites file is allowed (same tier). Only *upward* imports are violations.
- **Non-src imports**: Imports of `dart:*`, `package:flutter/*`, `package:obers_ui/*` are external dependencies and exempt from tier checks (except material/cupertino).
- **barrel file**: `obers_ui_charts.dart` lives outside `src/` and re-exports everything — it should be excluded from tier checks.

## UX / requirement matching

- **REQ-0006**: The test file directly enforces the 5-tier hierarchy rule by scanning every Dart file in the package and asserting no upward tier violations exist. If a developer adds a forbidden import, this test will catch it.
- **REQ-0007**: The test includes an explicit assertion that no file imports `package:flutter/material.dart` or `package:flutter/cupertino.dart`, enforcing zero Material/Cupertino dependency.
- **REQ-0008**: The existing source structure with 5 chart families (cartesian, polar, matrix, hierarchical, flow) under `composites/` is already verified by the tier import test — composites can only import from lower tiers, ensuring family infrastructure stays at the right level.

## Test cases

1. **Foundation (Tier 0) files import no higher tiers** — scan all files in `lib/src/foundation/`, verify none import from `primitives/`, `components/`, `composites/`, or `modules/`.
2. **Primitives (Tier 1) files import only from foundation or same tier** — verify no imports from `components/`, `composites/`, or `modules/`.
3. **Components (Tier 2) files import only from foundation, primitives, or same tier** — verify no imports from `composites/` or `modules/`.
4. **Composites (Tier 3) files import only from tiers 0–3** — verify no imports from `modules/`.
5. **No Material/Cupertino imports** — scan ALL `.dart` files in `lib/`, assert zero `package:flutter/material.dart` and zero `package:flutter/cupertino.dart` imports.
6. **Graceful handling of empty tier** — modules tier (Tier 4) has no `.dart` files, test should pass trivially.

## Definition of done checklist

- [ ] REQ-0006: Architecture test `test/src/architecture/tier_import_test.dart` exists and enforces 5-tier hierarchy via automated import scanning
- [ ] REQ-0007: Test includes explicit check for zero `material.dart` / `cupertino.dart` imports
- [ ] REQ-0008: Existing 5-family structure under composites validated by tier test (composites only import from lower tiers)
- [ ] Architecture test passes (`flutter test test/src/architecture/tier_import_test.dart`)
- [ ] `dart analyze` passes for the charts package
- [ ] `dart format --set-exit-if-changed .` passes for the charts package
- [ ] No existing tests broken

## Files to create or modify

1. [ ] `packages/obers_ui_charts/test/src/architecture/tier_import_test.dart` — NEW: architecture enforcement test scanning imports across all tiers

No other files need modification. All source files, barrel exports, and existing tests are already correct.

## Commands to run in check phase

```bash
cd packages/obers_ui_charts && flutter test test/src/architecture/tier_import_test.dart
cd packages/obers_ui_charts && flutter test
cd packages/obers_ui_charts && dart analyze
cd packages/obers_ui_charts && dart format --set-exit-if-changed .
```

## Key design decisions and rationale

1. **File-system scanning approach**: The test uses `dart:io` to scan the actual file system rather than relying on static analysis. This is simpler, faster, and catches all import forms (package and relative).

2. **Tier classification by path segment**: Using the directory name (`foundation`, `primitives`, `components`, `composites`, `modules`) as the tier classifier is robust because the directory structure is the canonical source of truth for the architecture.

3. **Both package and relative import handling**: Files may use either `import 'package:obers_ui_charts/src/...'` or `import '../...'` — the test normalizes both to a canonical path before tier classification.

4. **Separate test groups**: One group for tier hierarchy (per-tier), one for Material/Cupertino ban. This gives clear failure messages pointing to the exact violation.

## Potential risks and mitigation

- **Risk**: Test could be brittle if directory structure changes → **Mitigation**: Tier mapping is derived from well-known directory names that match the documented architecture.
- **Risk**: Test might miss some import patterns → **Mitigation**: Uses regex that matches both `import '...'` and `import "..."` with optional `as`, `show`, `hide` clauses.

## Cross-atom dependencies

- **REQ-0006 ↔ REQ-0007**: Both are satisfied by the same test file. The tier hierarchy check (REQ-0006) and the Material/Cupertino ban (REQ-0007) share the same file-scanning infrastructure but are in separate test groups.
- **REQ-0008**: The 5-family taxonomy is validated indirectly — all family files live under `composites/` (Tier 3), and the tier test ensures they only import from Tiers 0–2 plus their own tier. No additional test code is needed beyond what REQ-0006 provides.
- **Ordering**: Single sub-task — create the test file, then verify it passes.
