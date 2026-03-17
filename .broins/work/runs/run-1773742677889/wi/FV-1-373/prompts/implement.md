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

Also consider the perspective of these specialists: DevOps / SRE. Apply their domain expertise where relevant.

# Implementation Phase

## Work Item: FV-1-373 — Fix: Package Structure

## Requirement Atoms

- [ ] REQ-0002: [Package Structure](#package-structure)

Every item above must be verified individually. Do not skip any.

## Plan

## Plan

### Concept
Remove three empty placeholder directories (`lib/src/layouts/`, `lib/src/theme/`, `lib/src/widgets/`) that exist in git via `.gitkeep` files but have no Dart content and are absent from the spec-defined hierarchy (foundation, primitives, components, composites, modules, tools, utils). Removing them aligns the on-disk package structure exactly with the spec, resolving the only outstanding structural issue.

### Key Design Decisions & Rationale

| Decision | Rationale |
|---|---|
| Delete `.gitkeep` files, not move/rename | The spec hierarchy omits layouts/, theme/, widgets/ entirely — no stub barrel needed |
| Leave `persistence/` and `oi_platform.dart` untouched | Marked "additive, not breaking" in the work item; removal would be a breaking API change |
| No barrel-export changes | `lib/obers_ui.dart` has no sections for layouts, top-level theme, or widgets — no import cleanup required |

**Potential risk:** If any future EPIC adds layouts/widgets/theme tiers, the directories will need to be re-created. Mitigation: that is a separate work item; out of scope here.

---

### Sub-tasks
- **ST1:** Delete `lib/src/layouts/.gitkeep` — removes the empty `layouts/` placeholder
- **ST2:** Delete `lib/src/theme/.gitkeep` — removes the empty top-level `theme/` placeholder (distinct from `lib/src/foundation/theme/` which is populated)
- **ST3:** Delete `lib/src/widgets/.gitkeep` — removes the empty `widgets/` placeholder
- **ST4:** Run `dart analyze lib/` to confirm zero new errors introduced

---

### Method signatures
No new classes or methods. No existing signatures changed.

---

### Edge cases and fallbacks

| Edge case | Handling |
|---|---|
| Git still shows empty dir after `.gitkeep` removal | Git auto-prunes untracked empty dirs; no manual action needed |
| Another file accidentally in those dirs | Check with `ls` before deletion; abort ST if dir is non-empty |
| `lib/obers_ui.dart` references removed dirs | Pre-check with grep; none exist — safe to proceed |

---

### UX / requirement matching

- **REQ-0002 – Package Structure:** `lib/src/` will contain exactly the spec-defined top-level directories (foundation, primitives, components, composites, modules, tools, utils) plus the non-breaking additive extras (models/, persistence/, oi_platform.dart). No empty placeholder dirs remain. Implementation rises from 92% → 100%.

---

### Test cases
1. `dart analyze lib/` — must exit 0 with no new issues
2. Directory listing of `lib/src/` — must not contain `layouts/`, `theme/`, or `widgets/` entries
3. `grep -r "src/layouts\|src/theme\|src/widgets" lib/obers_ui.dart` — must return no matches (confirms barrel export is unaffected)

---

### Definition of done checklist
- [ ] REQ-0002: `lib/src/layouts/`, `lib/src/theme/`, `lib/src/widgets/` no longer exist on disk
- [ ] `lib/obers_ui.dart` unchanged — no removed exports
- [ ] `dart analyze lib/` exits clean
- [ ] No placeholder comments or TODO stubs introduced

---

### Files to create or modify (MANDATORY)
1. [ ] `lib/src/layouts/.gitkeep` — **delete** (removes empty placeholder directory)
2. [ ] `lib/src/theme/.gitkeep` — **delete** (removes empty placeholder directory)
3. [ ] `lib/src/widgets/.gitkeep` — **delete** (removes empty placeholder directory)

---

### Commands to run in check phase
```
dart analyze lib/
```## Plan

### Concept
Remove three empty placeholder directories (`lib/src/layouts/`, `lib/src/theme/`, `lib/src/widgets/`) that exist in git via `.gitkeep` files but have no Dart content and are absent from the spec-defined hierarchy (foundation, primitives, components, composites, modules, tools, utils). Removing them aligns the on-disk package structure exactly with the spec, resolving the only outstanding structural issue.

### Key Design Decisions & Rationale

| Decision | Rationale |
|---|---|
| Delete `.gitkeep` files, not move/rename | The spec hierarchy omits layouts/, theme/, widgets/ entirely — no stub barrel needed |
| Leave `persistence/` and `oi_platform.dart` untouched | Marked "additive, not breaking" in the work item; removal would be a breaking API change |
| No barrel-export changes | `lib/obers_ui.dart` has no sections for layouts, top-level theme, or widgets — no import cleanup required |

**Potential risk:** If any future EPIC adds layouts/widgets/theme tiers, the directories will need to be re-created. Mitigation: that is a separate work item; out of scope here.

---

### Sub-tasks
- **ST1:** Delete `lib/src/layouts/.gitkeep` — removes the empty `layouts/` placeholder
- **ST2:** Delete `lib/src/theme/.gitkeep` — removes the empty top-level `theme/` placeholder (distinct from `lib/src/foundation/theme/` which is populated)
- **ST3:** Delete `lib/src/widgets/.gitkeep` — removes the empty `widgets/` placeholder
- **ST4:** Run `dart analyze lib/` to confirm zero new errors introduced

---

### Method signatures
No new classes or methods. No existing signatures changed.

---

### Edge cases and fallbacks

| Edge case | Handling |
|---|---|
| Git still shows empty dir after `.gitkeep` removal | Git auto-prunes untracked empty dirs; no manual action needed |
| Another file accidentally in those dirs | Check with `ls` before deletion; abort ST if dir is non-empty |
| `lib/obers_ui.dart` references removed dirs | Pre-check with grep; none exist — safe to proceed |

---

### UX / requirement matching

- **REQ-0002 – Package Structure:** `lib/src/` will contain exactly the spec-defined top-level directories (foundation, primitives, components, composites, modules, tools, utils) plus the non-breaking additive extras (models/, persistence/, oi_platform.dart). No empty placeholder dirs remain. Implementation rises from 92% → 100%.

---

### Test cases
1. `dart analyze lib/` — must exit 0 with no new issues
2. Directory listing of `lib/src/` — must not contain `layouts/`, `theme/`, or `widgets/` entries
3. `grep -r "src/layouts\|src/theme\|src/widgets" lib/obers_ui.dart` — must return no matches (confirms barrel export is unaffected)

---

### Definition of done checklist
- [ ] REQ-0002: `lib/src/layouts/`, `lib/src/theme/`, `lib/src/widgets/` no longer exist on disk
- [ ] `lib/obers_ui.dart` unchanged — no removed exports
- [ ] `dart analyze lib/` exits clean
- [ ] No placeholder comments or TODO stubs introduced

---

### Files to create or modify (MANDATORY)
1. [ ] `lib/src/layouts/.gitkeep` — **delete** (removes empty placeholder directory)
2. [ ] `lib/src/theme/.gitkeep` — **delete** (removes empty placeholder directory)
3. [ ] `lib/src/widgets/.gitkeep` — **delete** (removes empty placeholder directory)

---

### Commands to run in check phase
```
dart analyze lib/
```

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
6. When finished, write 'DONE: FV-1-373' to the sentinel file at `.broins/work/runs/run-1773742677889/sentinel_FV-1-373.txt`
7. Write an `implement.json` file to `.broins/work/runs/run-1773742677889/wi/FV-1-373/results/implement.json` with:
   - `filesChanged`: list of files you modified
   - `commandsRun`: list of shell commands you executed
   - `notes`: any implementation notes
