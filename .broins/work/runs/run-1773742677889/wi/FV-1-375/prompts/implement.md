## Software Engineer Role

You are the **Software Engineer** implementing this task.

Your responsibilities:
- Write clean, well-structured code that follows project conventions.
- Implement the solution according to the architect's design.
- Write unit tests alongside production code (TDD when appropriate).
- Handle edge cases, error conditions, and boundary values.
- Ensure code passes static analysis and formatting checks.
- Keep functions short, focused, and at a single level of abstraction.

Guidelines:
- Follow Dart/Flutter style guide and project-specific lint rules.
- Use strong typing — avoid `dynamic` and prefer `final`/`const`.
- Prefer immutable data structures and value types.
- Write self-documenting code; add comments only for non-obvious logic.
- Use meaningful names: verbs for functions, nouns for classes.
- Handle errors explicitly — no silent swallowing of exceptions.

Required Output:
- Complete implementation code — every method from the plan must have a full body.
- Unit tests for all new public methods.
- No stubs, placeholders, or to-do comments in delivered code.


**Frontend/UX focus:**
- Build responsive widgets with proper layout constraints.
- Use `const` constructors to minimise rebuilds.
- Implement proper loading, error, and empty states.
- Follow accessibility guidelines (semantic labels, contrast).


**Feature/Bugfix focus:**
- Isolate the fix to the minimum necessary change set.
- Add regression tests covering the specific bug or feature path.
- Respect existing patterns — don't refactor unrelated code.
- Ensure backward compatibility with existing callers.


## Specialist Considerations

Also consider the perspective of these specialists: UX/UI Expert, DevOps / SRE. Apply their domain expertise where relevant.

# Implementation Phase

## Work Item: FV-1-375 — Fix: Theming System

## Requirement Atoms

- [ ] REQ-0003: [Theming System](#theming-system)

Every item above must be verified individually. Do not skip any.

## Plan

## Plan

### Concept
Fix the 4 identified gaps in the theming system to reach 100% completion: add `OiButtonThemeScope`, rename/alias the BuildContext extension to `OiThemeExt`, wire `OiPerformanceConfig` into `OiThemeData` and `OiApp`, and add `chart` field to `OiColorScheme`.

### Sub-tasks
- ST1: Add `chart` field (`List<Color>`) to `OiColorScheme` with defaults in `light()` and `dark()` factories, update `copyWith`, `lerp`, and `merge`
- ST2: Add `OiThemeExt` as a type alias or rename `OiBuildContextThemeExt` to `OiThemeExt` (or expose both)
- ST3: Add `performanceConfig` field to `OiThemeData`, wire it through `light()`, `dark()`, `fromBrand()`, `copyWith()`, `merge()`, `lerp()`
- ST4: Expose `performanceConfig` via `OiApp` constructor parameter
- ST5: Add `OiButtonThemeScope` widget to `oi_component_themes.dart` (or its own file) with `theme: OiButtonThemeData` and `child` parameters

### Method signatures
```dart
// ST1 - OiColorScheme
final List<Color> chart;
OiColorScheme.light({List<Color>? chart})
OiColorScheme.dark({List<Color>? chart})
OiColorScheme copyWith({List<Color>? chart})
OiColorScheme lerp(OiColorScheme other, double t)

// ST2 - extension alias
extension OiThemeExt on BuildContext { ... }  // alias or rename

// ST3 - OiThemeData
final OiPerformanceConfig performanceConfig;
OiThemeData.light({OiPerformanceConfig? performanceConfig})
OiThemeData.dark({OiPerformanceConfig? performanceConfig})
OiThemeData.fromBrand({OiPerformanceConfig? performanceConfig})
OiThemeData copyWith({OiPerformanceConfig? performanceConfig})
OiThemeData merge(OiThemeData other)
OiThemeData lerp(OiThemeData other, double t)

// ST4 - OiApp
OiApp({OiPerformanceConfig? performanceConfig})

// ST5 - OiButtonThemeScope
class OiButtonThemeScope extends InheritedWidget {
  const OiButtonThemeScope({required OiButtonThemeData theme, required Widget child})
  static OiButtonThemeData? of(BuildContext context)
}
```

### Edge cases and fallbacks
- `chart` list defaults: provide sensible default colors (6–8 distinct chart colors) if not specified
- `OiThemeExt` vs `OiBuildContextThemeExt`: keep `OiBuildContextThemeExt` to avoid breaking existing code, expose `OiThemeExt` as additional extension or type alias
- `OiPerformanceConfig` in `lerp`: lerp between configs using `t < 0.5 ? a : b` for non-numeric fields
- `OiButtonThemeScope.of()` returns `null` if no ancestor scope — callers fall back to `OiThemeData.components.button`

### UX / requirement matching
- **REQ-0003 Theming System**: All 4 spec gaps resolved → implementation reaches 100%
  - Spec: `OiButtonThemeScope(theme: OiButtonThemeData(height: 48), child: MyArea())` → ST5 satisfies
  - Spec: `context.oiTheme` via `OiThemeExt` → ST2 satisfies
  - Spec: `OiPerformanceConfig` wired into `OiThemeData.components` or `OiApp` → ST3+ST4 satisfy
  - Spec: `OiColorScheme.chart` field → ST1 satisfies

### Test cases
- `OiColorScheme.light()` has non-empty `chart` list
- `OiColorScheme.copyWith(chart: [...])` replaces chart colors
- `OiColorScheme.lerp()` interpolates chart list length
- `OiThemeData.light()` has `performanceConfig` field
- `OiThemeData.copyWith(performanceConfig: ...)` works
- `OiButtonThemeScope` provides `OiButtonThemeData` to descendants
- `OiButtonThemeScope.of(context)` returns `null` when no ancestor
- `context.oiTheme` accessible via `OiThemeExt`

### Definition of done checklist
- [ ] `OiColorScheme` has `chart: List<Color>` field with defaults
- [ ] `OiThemeExt` extension on `BuildContext` is publicly exported
- [ ] `OiThemeData` has `performanceConfig: OiPerformanceConfig` field, wired end-to-end
- [ ] `OiApp` accepts optional `performanceConfig` parameter
- [ ] `OiButtonThemeScope` widget exists and matches spec usage
- [ ] No existing public APIs broken (backward compatible)
- [ ] All test cases pass

### Files to create or modify (MANDATORY)
1. [ ] `lib/src/foundation/theme/oi_color_scheme.dart` — add `chart` field, update factories/copyWith/lerp/merge
2. [ ] `lib/src/foundation/theme/oi_theme.dart` — add `OiThemeExt` extension alias alongside `OiBuildContextThemeExt`
3. [ ] `lib/src/foundation/theme/oi_theme_data.dart` — add `performanceConfig` field, update all factories/copyWith/lerp/merge
4. [ ] `lib/src/foundation/theme/oi_component_themes.dart` — add `OiButtonThemeScope` widget class
5. [ ] `lib/src/modules/oi_app.dart` (or wherever `OiApp` is defined) — add `performanceConfig` parameter
6. [ ] `lib/src/foundation/theme/oi_theme_exports.dart` (or barrel file) — ensure `OiButtonThemeScope` and `OiThemeExt` are exported
7. [ ] `test/src/foundation/theme/oi_theming_test.dart` — new test file covering all 4 fixes

### Commands to run in check phase
```
flutter test test/src/foundation/theme/oi_theming_test.dart
```

### Key design decisions
- **Keep `OiBuildContextThemeExt` intact** and add `OiThemeExt` as a second extension with the same methods — avoids breaking existing callers while satisfying the spec name
- **`OiPerformanceConfig` on `OiThemeData`** (not nested under `components`) — matches spec language "OiThemeData.components or OiApp constructor"
- **`OiButtonThemeScope` as `InheritedWidget`** — consistent with Flutter theming patterns and how `OiThemeScope` works

### Cross-atom dependencies
REQ-0003 is a single atom covering all 4 fixes. ST1–ST5 are independent of each other but all contribute to the same atom. ST3 (OiThemeData) must be done before ST4 (OiApp) since OiApp depends on OiThemeData. All other sub-tasks are parallelizable.## Plan

### Concept
Fix the 4 identified gaps in the theming system to reach 100% completion: add `OiButtonThemeScope`, rename/alias the BuildContext extension to `OiThemeExt`, wire `OiPerformanceConfig` into `OiThemeData` and `OiApp`, and add `chart` field to `OiColorScheme`.

### Sub-tasks
- ST1: Add `chart` field (`List<Color>`) to `OiColorScheme` with defaults in `light()` and `dark()` factories, update `copyWith`, `lerp`, and `merge`
- ST2: Add `OiThemeExt` as a type alias or rename `OiBuildContextThemeExt` to `OiThemeExt` (or expose both)
- ST3: Add `performanceConfig` field to `OiThemeData`, wire it through `light()`, `dark()`, `fromBrand()`, `copyWith()`, `merge()`, `lerp()`
- ST4: Expose `performanceConfig` via `OiApp` constructor parameter
- ST5: Add `OiButtonThemeScope` widget to `oi_component_themes.dart` (or its own file) with `theme: OiButtonThemeData` and `child` parameters

### Method signatures
```dart
// ST1 - OiColorScheme
final List<Color> chart;
OiColorScheme.light({List<Color>? chart})
OiColorScheme.dark({List<Color>? chart})
OiColorScheme copyWith({List<Color>? chart})
OiColorScheme lerp(OiColorScheme other, double t)

// ST2 - extension alias
extension OiThemeExt on BuildContext { ... }  // alias or rename

// ST3 - OiThemeData
final OiPerformanceConfig performanceConfig;
OiThemeData.light({OiPerformanceConfig? performanceConfig})
OiThemeData.dark({OiPerformanceConfig? performanceConfig})
OiThemeData.fromBrand({OiPerformanceConfig? performanceConfig})
OiThemeData copyWith({OiPerformanceConfig? performanceConfig})
OiThemeData merge(OiThemeData other)
OiThemeData lerp(OiThemeData other, double t)

// ST4 - OiApp
OiApp({OiPerformanceConfig? performanceConfig})

// ST5 - OiButtonThemeScope
class OiButtonThemeScope extends InheritedWidget {
  const OiButtonThemeScope({required OiButtonThemeData theme, required Widget child})
  static OiButtonThemeData? of(BuildContext context)
}
```

### Edge cases and fallbacks
- `chart` list defaults: provide sensible default colors (6–8 distinct chart colors) if not specified
- `OiThemeExt` vs `OiBuildContextThemeExt`: keep `OiBuildContextThemeExt` to avoid breaking existing code, expose `OiThemeExt` as additional extension or type alias
- `OiPerformanceConfig` in `lerp`: lerp between configs using `t < 0.5 ? a : b` for non-numeric fields
- `OiButtonThemeScope.of()` returns `null` if no ancestor scope — callers fall back to `OiThemeData.components.button`

### UX / requirement matching
- **REQ-0003 Theming System**: All 4 spec gaps resolved → implementation reaches 100%
  - Spec: `OiButtonThemeScope(theme: OiButtonThemeData(height: 48), child: MyArea())` → ST5 satisfies
  - Spec: `context.oiTheme` via `OiThemeExt` → ST2 satisfies
  - Spec: `OiPerformanceConfig` wired into `OiThemeData.components` or `OiApp` → ST3+ST4 satisfy
  - Spec: `OiColorScheme.chart` field → ST1 satisfies

### Test cases
- `OiColorScheme.light()` has non-empty `chart` list
- `OiColorScheme.copyWith(chart: [...])` replaces chart colors
- `OiColorScheme.lerp()` interpolates chart list length
- `OiThemeData.light()` has `performanceConfig` field
- `OiThemeData.copyWith(performanceConfig: ...)` works
- `OiButtonThemeScope` provides `OiButtonThemeData` to descendants
- `OiButtonThemeScope.of(context)` returns `null` when no ancestor
- `context.oiTheme` accessible via `OiThemeExt`

### Definition of done checklist
- [ ] `OiColorScheme` has `chart: List<Color>` field with defaults
- [ ] `OiThemeExt` extension on `BuildContext` is publicly exported
- [ ] `OiThemeData` has `performanceConfig: OiPerformanceConfig` field, wired end-to-end
- [ ] `OiApp` accepts optional `performanceConfig` parameter
- [ ] `OiButtonThemeScope` widget exists and matches spec usage
- [ ] No existing public APIs broken (backward compatible)
- [ ] All test cases pass

### Files to create or modify (MANDATORY)
1. [ ] `lib/src/foundation/theme/oi_color_scheme.dart` — add `chart` field, update factories/copyWith/lerp/merge
2. [ ] `lib/src/foundation/theme/oi_theme.dart` — add `OiThemeExt` extension alias alongside `OiBuildContextThemeExt`
3. [ ] `lib/src/foundation/theme/oi_theme_data.dart` — add `performanceConfig` field, update all factories/copyWith/lerp/merge
4. [ ] `lib/src/foundation/theme/oi_component_themes.dart` — add `OiButtonThemeScope` widget class
5. [ ] `lib/src/modules/oi_app.dart` (or wherever `OiApp` is defined) — add `performanceConfig` parameter
6. [ ] `lib/src/foundation/theme/oi_theme_exports.dart` (or barrel file) — ensure `OiButtonThemeScope` and `OiThemeExt` are exported
7. [ ] `test/src/foundation/theme/oi_theming_test.dart` — new test file covering all 4 fixes

### Commands to run in check phase
```
flutter test test/src/foundation/theme/oi_theming_test.dart
```

### Key design decisions
- **Keep `OiBuildContextThemeExt` intact** and add `OiThemeExt` as a second extension with the same methods — avoids breaking existing callers while satisfying the spec name
- **`OiPerformanceConfig` on `OiThemeData`** (not nested under `components`) — matches spec language "OiThemeData.components or OiApp constructor"
- **`OiButtonThemeScope` as `InheritedWidget`** — consistent with Flutter theming patterns and how `OiThemeScope` works

### Cross-atom dependencies
REQ-0003 is a single atom covering all 4 fixes. ST1–ST5 are independent of each other but all contribute to the same atom. ST3 (OiThemeData) must be done before ST4 (OiApp) since OiApp depends on OiThemeData. All other sub-tasks are parallelizable.

## Implementation Checklist (MANDATORY — implement ALL)

1. [ ] `light()`
2. [ ] `dark()`
3. [ ] `fromBrand()`
4. [ ] `copyWith()`
5. [ ] `merge()`
6. [ ] `lerp()`
7. [ ] `OiButtonThemeScope.of()`
8. [ ] `OiColorScheme.light()`
9. [ ] `OiColorScheme.copyWith(chart: [...])`
10. [ ] `OiColorScheme.lerp()`
11. [ ] `OiThemeData.light()`
12. [ ] `OiThemeData.copyWith(performanceConfig: ...)`
13. [ ] `OiButtonThemeScope.of(context)`

You MUST implement every item above with a complete method body. Incomplete implementation will fail verification.

## Instructions

Implement the work item according to the plan above. Implement the full requirement only: no stubs, placeholders, or TODO comments. Every requirement atom must be completely implemented and verifiable with evidence.

For each requirement atom: implement every sub-bullet and every mentioned UI element, button, link, section, and state. If the requirement lists multiple items (e.g. A) X, B) Y, C) Z), implement all of them. Partial implementation will fail verification.

1. Implement each step from the plan in order
2. Write clean, well-documented code
3. Include appropriate error handling
4. Write tests for all new functionality
5. Ensure all definition of done criteria are met

CRITICAL: You must implement ALL methods and classes mentioned in your plan. Do not just add enum values, registry entries, or type definitions — write the full method bodies with complete logic. If your plan mentions methods like previewX() and executeX(), those methods MUST appear in your code with real implementations.

Be concise and focused. Write code, not explanations. Do not narrate what you are doing — just do it. Minimize file reads: only read files you need to edit or that are direct dependencies of files you edit.
6. When finished, write 'DONE: FV-1-375' to the sentinel file at `.broins/work/runs/run-1773742677889/sentinel_FV-1-375.txt`
7. Write an `implement.json` file to `.broins/work/runs/run-1773742677889/wi/FV-1-375/results/implement.json` with:
   - `filesChanged`: list of files you modified
   - `commandsRun`: list of shell commands you executed
   - `notes`: any implementation notes
