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


**DX/Refactor focus:**
- Preserve public API contracts during refactoring.
- Move in small, atomic steps — each commit should compile.
- Update imports and re-exports to reflect new structure.
- Remove dead code and unused dependencies.


## Specialist Considerations

Also consider the perspective of these specialists: DevOps / SRE, UX/UI Expert. Apply their domain expertise where relevant.

# Implementation Phase

## Work Item: WI-0064 — Naming Conventions (Part 1/2)

## Requirement Atoms

- [ ] REQ-0012: Name by what it _is_ in the UI. `OiTable`, `OiButton`, `OiSidebar`.
- [ ] REQ-0013: Props read like English. `multiSelect: true`, `reorderColumns: true`, `stickyHeader: true`.
- [ ] REQ-0014: Required props enforce correctness. Images require `alt`, buttons require `label`.

Every item above must be verified individually. Do not skip any.

## Plan

Now I have enough context to write a comprehensive implementation plan. Let me produce it.

---

## Implementation Plan: WI-0064 — Naming Conventions (Part 1/2)

---

### Concept

This work item establishes and enforces a uniform naming convention across the Obers UI library: every public widget is named `OiXxx` after what it represents in the UI, every boolean prop reads as natural English without `is`/`has` prefixes, and structural props on image/button widgets are required to prevent accessibility errors at compile time.

---

### Sub-tasks

- **ST1** — Audit all public widget class names for `Oi` prefix compliance; produce a coverage note (no code changes expected; current state is 100% compliant)
- **ST2** — Rename all `is`/`has`-prefixed boolean props on public widget and data-model constructors across the library
- **ST3** — Audit all button-like widgets (`OiButton`, `OiIconButton`, `OiToggleButton`, `OiButtonGroup`) to verify `label`/`semanticLabel` is `required`; fix any gaps
- **ST4** — Audit all image-like widgets (`OiImage`, `OiAvatar`) to verify `alt` or equivalent accessibility string is `required`; fix any gaps
- **ST5** — Run `dart analyze` and all project checks; fix any cascade failures from renames

---

### Method signatures

Each rename below is a field declaration on a public API class. Changed signatures use the final name:

```dart
// OiButtonGroup - ST2
final bool selected;           // was isSelected

// OiTree data model - ST2
final bool leaf;               // was isLeaf

// OiDiffView line descriptor - ST2
final bool added;              // was isAdded
final bool removed;            // was isRemoved
final bool unchanged;          // was isContext (avoids collision with BuildContext)

// OiStateDiagram node descriptor - ST2
final bool initial;            // was isInitial
final bool terminal;           // was isFinal  (final is a Dart keyword — must rename)

// OiTimeline item descriptor - ST2
final bool leftAligned;        // was isLeft
final bool last;               // was isLast

// OiTour step descriptor - ST2
final bool lastStep;           // was isLastStep

// OiInfiniteScroll - ST2
final bool moreAvailable;      // was hasMore

// OiComboBox - ST2
final bool moreAvailable;      // was hasMore

// OiActivityFeed - ST2
final bool moreAvailable;      // was hasMore  (all three occurrences)
final bool last;               // was isLast

// OiChat - ST2
final bool olderMessagesAvailable;  // was hasOlderMessages

// OiListView - ST2
final bool moreAvailable;      // was hasMore

// OiPlatform - ST2
final bool keyboardVisible;    // was isKeyboardVisible

// OiDecorationTheme - ST2
final bool linear;             // was isLinear

// OiFileManager item descriptor - ST2
final bool directory;          // was isFolder (folder alone as a bool field name is ambiguous)

// OiIconButton - ST3 (fix if semanticLabel is currently optional)
required final String semanticLabel;

// OiToggleButton - ST3 (fix if label is currently optional)
required final String label;   // or semanticLabel — confirm after reading file
```

---

### Edge cases and fallbacks

| Edge case | Handling |
|-----------|----------|
| `isFinal` in `OiStateDiagram` — `final` is a Dart keyword | Rename to `terminal`; update all call sites |
| `isContext` in `OiDiffView` — `context` collides with Flutter's `BuildContext` | Rename to `unchanged` |
| `isFolder` alone is ambiguous as a bool | Rename to `directory` for clarity |
| Public API breaking change — existing consumers will get compile errors | Documented in migration guide section; this is an intentional breaking change for DX |
| `OiButton._()` private constructor retains optional `label` | Leave private constructor unchanged; public factory constructors already enforce `required String label` |
| `hasMore` appears 3× in `OiActivityFeed` (widget field, callback param, model field) | Rename all consistently to `moreAvailable` |
| `OiPlatform.isKeyboardVisible` may be used in platform detection logic internally | Rename consistently, update all internal references |

---

### UX / requirement matching

- **REQ-0012** — Confirmed: all 182+ widget files already use `OiXxx` prefix naming exactly what each widget represents in the UI (`OiTable`, `OiButton`, `OiSidebar`, etc.). Plan documents this compliance as evidence, adds no new widget renames.
- **REQ-0013** — 20 boolean props currently use `is`/`has` prefixes. ST2 renames all of them so every prop reads as natural English: `leaf: true`, `selected: true`, `moreAvailable: true`, `keyboardVisible: true`, etc.
- **REQ-0014** — `OiImage` already requires `alt`; `OiIcon` already requires `label`; `OiButton` public factories already require `label`. ST3/ST4 audit and fix `OiIconButton`, `OiToggleButton`, `OiAvatar` to close any remaining gaps.

---

### Test cases

*(Project has no automated test runner configured in Check Commands; `dart analyze` is the primary check.)*

1. `dart analyze` — zero errors after all renames and `required` additions
2. `dart format --output=none --set-exit-if-changed .` — no format violations
3. Manual smoke: all renamed props compile in the example app (`example/` directory)
4. Static proof of REQ-0014: each `OiImage`, `OiIcon`, `OiIconButton`, `OiAvatar`, `OiButton` constructor call site in the example app must compile without providing the required label/alt

---

### Definition of done checklist

- [ ] **REQ-0012**: Audit confirms 100% `Oi`-prefixed widget names; at least 20 examples cited as evidence
- [ ] **REQ-0013**: All 20 `is`/`has`-prefixed bool props renamed; every rename verified in its file
- [ ] **REQ-0014**: `OiImage.alt`, `OiIcon.label`, `OiButton.label` (public factories), `OiIconButton.semanticLabel`, `OiAvatar.alt` (if applicable) are all `required`; confirmed by constructor signatures
- [ ] `dart analyze` passes with zero errors
- [ ] `dart format` passes with zero changes
- [ ] Example app compiles
- [ ] No placeholders or TODO markers left in modified files
- [ ] Coverage ledger updated for REQ-0012, REQ-0013, REQ-0014

---

### Files to create or modify (MANDATORY)

1. [ ] `lib/src/components/buttons/oi_button_group.dart` — rename `isSelected` → `selected`
2. [ ] `lib/src/components/buttons/oi_icon_button.dart` — verify/add `required` on `semanticLabel`
3. [ ] `lib/src/components/buttons/oi_toggle_button.dart` — verify/add `required` on `label`
4. [ ] `lib/src/components/display/oi_diff_view.dart` — rename `isAdded` → `added`, `isRemoved` → `removed`, `isContext` → `unchanged`
5. [ ] `lib/src/composites/data/oi_tree.dart` — rename `isLeaf` → `leaf`
6. [ ] `lib/src/composites/onboarding/oi_tour.dart` — rename `isLastStep` → `lastStep`
7. [ ] `lib/src/composites/scheduling/oi_timeline.dart` — rename `isLeft` → `leftAligned`, `isLast` → `last`
8. [ ] `lib/src/composites/workflow/oi_state_diagram.dart` — rename `isInitial` → `initial`, `isFinal` → `terminal`
9. [ ] `lib/src/composites/search/oi_combo_box.dart` — rename `hasMore` → `moreAvailable`
10. [ ] `lib/src/primitives/scroll/oi_infinite_scroll.dart` — rename `hasMore` → `moreAvailable`
11. [ ] `lib/src/foundation/oi_platform.dart` — rename `isKeyboardVisible` → `keyboardVisible`
12. [ ] `lib/src/foundation/theme/oi_decoration_theme.dart` — rename `isLinear` → `linear`
13. [ ] `lib/src/modules/oi_file_manager.dart` — rename `isFolder` → `directory`
14. [ ] `lib/src/modules/oi_activity_feed.dart` — rename `hasMore` → `moreAvailable` (3 sites), `isLast` → `last`
15. [ ] `lib/src/modules/oi_chat.dart` — rename `hasOlderMessages` → `olderMessagesAvailable`
16. [ ] `lib/src/modules/oi_list_view.dart` — rename `hasMore` → `moreAvailable`
17. [ ] *(All call sites in `lib/` and `example/` that reference any of the above props — updated during ST2/ST3)*

---

### Commands to run in check phase

```bash
dart analyze
dart format --output=none --set-exit-if-changed .
cd example && dart analyze
```

---

### Key design decisions and rationale

| Decision | Rationale |
|----------|-----------|
| Remove `is`/`has` prefixes entirely, not just standardise them | Aligns with the requirement's examples (`multiSelect`, `stickyHeader`). Flutter's own API uses this pattern (`enabled`, `obscureText`, `scrollable`). |
| `isFinal` → `terminal` (not `final`) | `final` is a Dart reserved word and cannot be used as a field name. `terminal` is the accepted UML/FSM term for an accepting state. |
| `isContext` → `unchanged` (not `context`) | `context` shadows `BuildContext` in widget scopes and confuses readers. `unchanged` is a self-documenting diff-view term. |
| `isFolder` → `directory` (not `folder`) | `folder: bool` is semantically ambiguous (which folder?). `directory: true` reads clearly: "this item is a directory." |
| `hasMore` → `moreAvailable` (not `more`) | `more: true` alone is too terse; `moreAvailable` reads clearly in context (`moreAvailable: true` = "more items are available to load"). |
| Leave `OiButton._()` private constructor as-is | The `._()` constructor is internal scaffolding; public API factories already require `label`. Changing the private constructor adds risk with no public-API benefit. |

---

### Potential risks with mitigation

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Missed call site in a large module file | Medium | Use `dart analyze` cascade — compiler will fail on every missing rename; also `grep` for old names after changes |
| `terminal` semantics unfamiliar to some developers | Low | Add a brief doc comment: `/// Whether this state is a terminal (accepting) state in the diagram.` |
| `OiToggleButton` or `OiIconButton` already have internal widget tests that reference old prop names | Low | Search test/ directory for usages of renamed props before committing |
| Renaming `isKeyboardVisible` in `OiPlatform` may affect platform-detection subscribers outside lib/ | Low | Check example/ and any downstream usages; the compiler will surface them |

---

### Cross-atom dependencies

```
REQ-0012 (naming audit)
    │
    └─► No code changes; evidence gathering only. Run first to establish baseline.

REQ-0014 (required props)
    │
    └─► Depends on knowing which widgets exist (from REQ-0012 audit).
        Implement after REQ-0012 is confirmed.
        Touches: OiButton, OiIconButton, OiToggleButton, OiImage, OiAvatar.

REQ-0013 (English-readable props)
    │
    └─► Independent of REQ-0014 — touches different files (data models, modules).
        Can proceed in parallel with REQ-0014 once REQ-0012 is confirmed.
        Rename order: leaf/data model classes first (no widget dependencies),
        then widget-level bools (OiButtonGroup.selected, OiInfiniteScroll.moreAvailable),
        then module-level (OiChat, OiActivityFeed, OiListView) last because they
        may internally compose the widget-level classes.

Shared files: none — each atom owns a distinct file set.
```Now I have enough context to write a comprehensive implementation plan. Let me produce it.

---

## Implementation Plan: WI-0064 — Naming Conventions (Part 1/2)

---

### Concept

This work item establishes and enforces a uniform naming convention across the Obers UI library: every public widget is named `OiXxx` after what it represents in the UI, every boolean prop reads as natural English without `is`/`has` prefixes, and structural props on image/button widgets are required to prevent accessibility errors at compile time.

---

### Sub-tasks

- **ST1** — Audit all public widget class names for `Oi` prefix compliance; produce a coverage note (no code changes expected; current state is 100% compliant)
- **ST2** — Rename all `is`/`has`-prefixed boolean props on public widget and data-model constructors across the library
- **ST3** — Audit all button-like widgets (`OiButton`, `OiIconButton`, `OiToggleButton`, `OiButtonGroup`) to verify `label`/`semanticLabel` is `required`; fix any gaps
- **ST4** — Audit all image-like widgets (`OiImage`, `OiAvatar`) to verify `alt` or equivalent accessibility string is `required`; fix any gaps
- **ST5** — Run `dart analyze` and all project checks; fix any cascade failures from renames

---

### Method signatures

Each rename below is a field declaration on a public API class. Changed signatures use the final name:

```dart
// OiButtonGroup - ST2
final bool selected;           // was isSelected

// OiTree data model - ST2
final bool leaf;               // was isLeaf

// OiDiffView line descriptor - ST2
final bool added;              // was isAdded
final bool removed;            // was isRemoved
final bool unchanged;          // was isContext (avoids collision with BuildContext)

// OiStateDiagram node descriptor - ST2
final bool initial;            // was isInitial
final bool terminal;           // was isFinal  (final is a Dart keyword — must rename)

// OiTimeline item descriptor - ST2
final bool leftAligned;        // was isLeft
final bool last;               // was isLast

// OiTour step descriptor - ST2
final bool lastStep;           // was isLastStep

// OiInfiniteScroll - ST2
final bool moreAvailable;      // was hasMore

// OiComboBox - ST2
final bool moreAvailable;      // was hasMore

// OiActivityFeed - ST2
final bool moreAvailable;      // was hasMore  (all three occurrences)
final bool last;               // was isLast

// OiChat - ST2
final bool olderMessagesAvailable;  // was hasOlderMessages

// OiListView - ST2
final bool moreAvailable;      // was hasMore

// OiPlatform - ST2
final bool keyboardVisible;    // was isKeyboardVisible

// OiDecorationTheme - ST2
final bool linear;             // was isLinear

// OiFileManager item descriptor - ST2
final bool directory;          // was isFolder (folder alone as a bool field name is ambiguous)

// OiIconButton - ST3 (fix if semanticLabel is currently optional)
required final String semanticLabel;

// OiToggleButton - ST3 (fix if label is currently optional)
required final String label;   // or semanticLabel — confirm after reading file
```

---

### Edge cases and fallbacks

| Edge case | Handling |
|-----------|----------|
| `isFinal` in `OiStateDiagram` — `final` is a Dart keyword | Rename to `terminal`; update all call sites |
| `isContext` in `OiDiffView` — `context` collides with Flutter's `BuildContext` | Rename to `unchanged` |
| `isFolder` alone is ambiguous as a bool | Rename to `directory` for clarity |
| Public API breaking change — existing consumers will get compile errors | Documented in migration guide section; this is an intentional breaking change for DX |
| `OiButton._()` private constructor retains optional `label` | Leave private constructor unchanged; public factory constructors already enforce `required String label` |
| `hasMore` appears 3× in `OiActivityFeed` (widget field, callback param, model field) | Rename all consistently to `moreAvailable` |
| `OiPlatform.isKeyboardVisible` may be used in platform detection logic internally | Rename consistently, update all internal references |

---

### UX / requirement matching

- **REQ-0012** — Confirmed: all 182+ widget files already use `OiXxx` prefix naming exactly what each widget represents in the UI (`OiTable`, `OiButton`, `OiSidebar`, etc.). Plan documents this compliance as evidence, adds no new widget renames.
- **REQ-0013** — 20 boolean props currently use `is`/`has` prefixes. ST2 renames all of them so every prop reads as natural English: `leaf: true`, `selected: true`, `moreAvailable: true`, `keyboardVisible: true`, etc.
- **REQ-0014** — `OiImage` already requires `alt`; `OiIcon` already requires `label`; `OiButton` public factories already require `label`. ST3/ST4 audit and fix `OiIconButton`, `OiToggleButton`, `OiAvatar` to close any remaining gaps.

---

### Test cases

*(Project has no automated test runner configured in Check Commands; `dart analyze` is the primary check.)*

1. `dart analyze` — zero errors after all renames and `required` additions
2. `dart format --output=none --set-exit-if-changed .` — no format violations
3. Manual smoke: all renamed props compile in the example app (`example/` directory)
4. Static proof of REQ-0014: each `OiImage`, `OiIcon`, `OiIconButton`, `OiAvatar`, `OiButton` constructor call site in the example app must compile without providing the required label/alt

---

### Definition of done checklist

- [ ] **REQ-0012**: Audit confirms 100% `Oi`-prefixed widget names; at least 20 examples cited as evidence
- [ ] **REQ-0013**: All 20 `is`/`has`-prefixed bool props renamed; every rename verified in its file
- [ ] **REQ-0014**: `OiImage.alt`, `OiIcon.label`, `OiButton.label` (public factories), `OiIconButton.semanticLabel`, `OiAvatar.alt` (if applicable) are all `required`; confirmed by constructor signatures
- [ ] `dart analyze` passes with zero errors
- [ ] `dart format` passes with zero changes
- [ ] Example app compiles
- [ ] No placeholders or TODO markers left in modified files
- [ ] Coverage ledger updated for REQ-0012, REQ-0013, REQ-0014

---

### Files to create or modify (MANDATORY)

1. [ ] `lib/src/components/buttons/oi_button_group.dart` — rename `isSelected` → `selected`
2. [ ] `lib/src/components/buttons/oi_icon_button.dart` — verify/add `required` on `semanticLabel`
3. [ ] `lib/src/components/buttons/oi_toggle_button.dart` — verify/add `required` on `label`
4. [ ] `lib/src/components/display/oi_diff_view.dart` — rename `isAdded` → `added`, `isRemoved` → `removed`, `isContext` → `unchanged`
5. [ ] `lib/src/composites/data/oi_tree.dart` — rename `isLeaf` → `leaf`
6. [ ] `lib/src/composites/onboarding/oi_tour.dart` — rename `isLastStep` → `lastStep`
7. [ ] `lib/src/composites/scheduling/oi_timeline.dart` — rename `isLeft` → `leftAligned`, `isLast` → `last`
8. [ ] `lib/src/composites/workflow/oi_state_diagram.dart` — rename `isInitial` → `initial`, `isFinal` → `terminal`
9. [ ] `lib/src/composites/search/oi_combo_box.dart` — rename `hasMore` → `moreAvailable`
10. [ ] `lib/src/primitives/scroll/oi_infinite_scroll.dart` — rename `hasMore` → `moreAvailable`
11. [ ] `lib/src/foundation/oi_platform.dart` — rename `isKeyboardVisible` → `keyboardVisible`
12. [ ] `lib/src/foundation/theme/oi_decoration_theme.dart` — rename `isLinear` → `linear`
13. [ ] `lib/src/modules/oi_file_manager.dart` — rename `isFolder` → `directory`
14. [ ] `lib/src/modules/oi_activity_feed.dart` — rename `hasMore` → `moreAvailable` (3 sites), `isLast` → `last`
15. [ ] `lib/src/modules/oi_chat.dart` — rename `hasOlderMessages` → `olderMessagesAvailable`
16. [ ] `lib/src/modules/oi_list_view.dart` — rename `hasMore` → `moreAvailable`
17. [ ] *(All call sites in `lib/` and `example/` that reference any of the above props — updated during ST2/ST3)*

---

### Commands to run in check phase

```bash
dart analyze
dart format --output=none --set-exit-if-changed .
cd example && dart analyze
```

---

### Key design decisions and rationale

| Decision | Rationale |
|----------|-----------|
| Remove `is`/`has` prefixes entirely, not just standardise them | Aligns with the requirement's examples (`multiSelect`, `stickyHeader`). Flutter's own API uses this pattern (`enabled`, `obscureText`, `scrollable`). |
| `isFinal` → `terminal` (not `final`) | `final` is a Dart reserved word and cannot be used as a field name. `terminal` is the accepted UML/FSM term for an accepting state. |
| `isContext` → `unchanged` (not `context`) | `context` shadows `BuildContext` in widget scopes and confuses readers. `unchanged` is a self-documenting diff-view term. |
| `isFolder` → `directory` (not `folder`) | `folder: bool` is semantically ambiguous (which folder?). `directory: true` reads clearly: "this item is a directory." |
| `hasMore` → `moreAvailable` (not `more`) | `more: true` alone is too terse; `moreAvailable` reads clearly in context (`moreAvailable: true` = "more items are available to load"). |
| Leave `OiButton._()` private constructor as-is | The `._()` constructor is internal scaffolding; public API factories already require `label`. Changing the private constructor adds risk with no public-API benefit. |

---

### Potential risks with mitigation

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Missed call site in a large module file | Medium | Use `dart analyze` cascade — compiler will fail on every missing rename; also `grep` for old names after changes |
| `terminal` semantics unfamiliar to some developers | Low | Add a brief doc comment: `/// Whether this state is a terminal (accepting) state in the diagram.` |
| `OiToggleButton` or `OiIconButton` already have internal widget tests that reference old prop names | Low | Search test/ directory for usages of renamed props before committing |
| Renaming `isKeyboardVisible` in `OiPlatform` may affect platform-detection subscribers outside lib/ | Low | Check example/ and any downstream usages; the compiler will surface them |

---

### Cross-atom dependencies

```
REQ-0012 (naming audit)
    │
    └─► No code changes; evidence gathering only. Run first to establish baseline.

REQ-0014 (required props)
    │
    └─► Depends on knowing which widgets exist (from REQ-0012 audit).
        Implement after REQ-0012 is confirmed.
        Touches: OiButton, OiIconButton, OiToggleButton, OiImage, OiAvatar.

REQ-0013 (English-readable props)
    │
    └─► Independent of REQ-0014 — touches different files (data models, modules).
        Can proceed in parallel with REQ-0014 once REQ-0012 is confirmed.
        Rename order: leaf/data model classes first (no widget dependencies),
        then widget-level bools (OiButtonGroup.selected, OiInfiniteScroll.moreAvailable),
        then module-level (OiChat, OiActivityFeed, OiListView) last because they
        may internally compose the widget-level classes.

Shared files: none — each atom owns a distinct file set.
```

## Implementation Checklist (MANDATORY — implement ALL)

1. [ ] `OiButton._()`

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
6. When finished, write 'DONE: WI-0064' to the sentinel file at `.broins/work/runs/run-1773733505170/sentinel_WI-0064.txt`
7. Write an `implement.json` file to `.broins/work/runs/run-1773733505170/wi/WI-0064/results/implement.json` with:
   - `filesChanged`: list of files you modified
   - `commandsRun`: list of shell commands you executed
   - `notes`: any implementation notes
