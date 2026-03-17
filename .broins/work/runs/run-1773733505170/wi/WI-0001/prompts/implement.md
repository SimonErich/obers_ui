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

## Work Item: WI-0001 — Accessibility Enforcement (Part 1/6)

## Requirement Atoms

- [ ] REQ-0018: **OiImage** requires `alt`. Use `OiImage.decorative()` to explicitly opt out.
- [ ] REQ-0019: **OiButton** (all variants including `.icon()`) requires `label`.
- [ ] REQ-0020: **OiIcon** requires `label`. Use `OiIcon.decorative()` to opt out.

Every item above must be verified individually. Do not skip any.

## Plan

---

## Implementation Plan: WI-0001 — Accessibility Enforcement (Part 1/6)

---

### Concept

This work item enforces compile-time accessibility contracts on three UI primitives: `OiImage`, `OiButton`, and `OiIcon`. Callers are forced to supply meaningful labels or explicitly opt out via a named constructor, eliminating the class of accessibility bugs where interactive/informative widgets are silently invisible to screen readers.

---

### Current State Assessment (from code audit)

| Atom | Component | Status |
|---|---|---|
| REQ-0018 | `OiImage` | ✅ Already implemented — `required String alt`, `.decorative()` exists, tests pass |
| REQ-0019 | `OiButton` (standard variants) | ✅ All six standard variants + split/countdown/confirm already have `required String label` |
| REQ-0019 | `OiButton.icon()` | ❌ **Gap** — `semanticLabel` is `String?` (optional), no label enforced |
| REQ-0020 | `OiIcon` | ✅ Already implemented — `required String label`, `.decorative()` exists, tests pass |

The only source change needed is in `OiButton.icon()`: rename the parameter from optional `String? semanticLabel` to required `String label`.

---

### Sub-tasks

- **ST1:** Modify `OiButton.icon()` constructor — change `String? semanticLabel` to `required String label`, delegate to private constructor as `semanticLabel: label`
- **ST2:** Update `oi_button_test.dart` — fix two existing call sites that omit a label for `.icon()`, add a new semantic label test for the icon variant
- **ST3:** Audit `obers_ui.dart` exports to confirm all three classes are exported (no change expected)
- **ST4:** Verify REQ-0018 and REQ-0020 tests are present and sufficient (read-only confirmation, no changes expected)

---

### Method signatures

```dart
// MODIFIED — OiButton.icon() (lib/src/components/buttons/oi_button.dart:282)
const OiButton.icon({
  required IconData icon,
  required String label,          // was: String? semanticLabel
  VoidCallback? onTap,
  OiButtonSize size = OiButtonSize.medium,
  bool enabled = true,
  OiButtonVariant variant = OiButtonVariant.ghost,
  Key? key,
})
```

Everything else (`OiImage`, `OiIcon`, their named constructors, `_buildIconButton`) is unchanged in signature.

---

### Edge cases and fallbacks

| Case | Behaviour |
|---|---|
| `OiButton.icon()` called without `label` | Compile-time error — `required` parameter prevents build |
| Empty string passed as `label` | Accepted at runtime (caller's responsibility); Dart `required` does not enforce non-empty |
| Existing call sites without `label` | Will fail `dart analyze` / `flutter test` — fixed in ST2 |
| `OiImage` used with `alt: ''` | Accepted (caller chose empty alt for non-decorative use); enforcement is presence, not value |

---

### UX / requirement matching

- **REQ-0018 (OiImage):** Already satisfied — `required String alt` in default constructor; `OiImage.decorative()` for opt-out. Verified by existing tests `wraps in Semantics with alt label`, `decorative image uses ExcludeSemantics`.
- **REQ-0019 (OiButton):** Standard variants already satisfied. Gap is `OiButton.icon()` — making `label` required closes it. The `label` is forwarded as `semanticLabel` to `OiTappable`, which announces it to screen readers.
- **REQ-0020 (OiIcon):** Already satisfied — `required String label` in default constructor; `OiIcon.decorative()` for opt-out. Verified by existing tests `semantic icon has Semantics node with label`, `decorative icon has no labelled Semantics node`.

---

### Test cases

**Tests to add in `oi_button_test.dart`:**
1. `OiButton.icon passes semantic label to accessibility tree` — pump `OiButton.icon(icon: _kIcon, label: 'Close')`, verify a `Semantics` node exists with `label == 'Close'` (or verify via `OiTappable`'s semanticLabel propagation)

**Tests to update in `oi_button_test.dart`:**
1. Line 171: `OiButton.icon(icon: _kIcon, onTap: () => count++)` → add `label: 'Add'`
2. Line 184: `OiButton.icon(icon: _kIcon)` → add `label: 'Add'`

**Existing tests that continue to pass unchanged:**
- All `oi_image_test.dart` tests (REQ-0018 fully covered)
- All `oi_icon_test.dart` tests (REQ-0020 fully covered)
- All other `oi_button_test.dart` tests (standard variant labels already required)

---

### Design decisions and rationale

**Why `required String label` rather than `required String semanticLabel`?**  
Consistency with `OiIcon` and `OiImage` which both use `label`/`alt` as the public accessibility parameter name. The private constructor field (`semanticLabel`) remains internal; the delegation `semanticLabel: label` bridges the naming.

**Why not add an `OiButton.iconDecorative()` opt-out?**  
Icon buttons are by definition interactive. An interactive control without an accessible label is an accessibility violation with no legitimate opt-out — WCAG 2.1 SC 4.1.2 (Name, Role, Value, Level A) requires all interactive components to have a name.

**Why no runtime assertion for empty strings?**  
Dart's `required` enforces presence at compile time. Runtime non-empty validation would add noise for edge cases (e.g., labels sourced from i18n that are verified by other means). This is consistent with how `OiImage.alt` and `OiIcon.label` behave today.

---

### Potential risks and mitigations

| Risk | Mitigation |
|---|---|
| Downstream code using `OiButton.icon()` without a label | Breaking change is intentional and caught at compile time — migration path is trivial (add `label:`) |
| Tests instantiating `OiButton.icon()` without label fail before fix | ST2 is listed after ST1; tests are updated as part of this work item |
| `OiTappable` may not surface `semanticLabel` in the widget tree in a way widget tests can query | If `OiTappable` uses `Semantics(label: semanticLabel)`, the test can find it directly; if it wraps differently, test can use `tester.getSemantics()` with `SemanticsFlag.isButton` |

---

### Files to create or modify (MANDATORY)

1. [ ] `lib/src/components/buttons/oi_button.dart` — Change `OiButton.icon()` parameter from `String? semanticLabel` to `required String label`; update delegation to pass `semanticLabel: label`
2. [ ] `test/src/components/buttons/oi_button_test.dart` — Fix 2 broken call sites; add 1 new test for icon-button semantic label

No changes to:
- `lib/src/primitives/display/oi_image.dart` (REQ-0018 already complete)
- `lib/src/primitives/display/oi_icon.dart` (REQ-0020 already complete)
- `test/src/primitives/display/oi_image_test.dart` (coverage already sufficient)
- `test/src/primitives/display/oi_icon_test.dart` (coverage already sufficient)
- `lib/obers_ui.dart` (all three classes already exported)

---

### Commands to run in check phase

```
flutter analyze
flutter test test/src/components/buttons/oi_button_test.dart
flutter test test/src/primitives/display/oi_image_test.dart
flutter test test/src/primitives/display/oi_icon_test.dart
flutter test
```

---

### Definition of done checklist

- [ ] **REQ-0018:** `OiImage` default constructor has `required String alt`; `OiImage.decorative()` named constructor exists — confirmed in source, no change needed
- [ ] **REQ-0018:** Tests verify `Semantics(label: alt, image: true)` for non-decorative and `ExcludeSemantics` for decorative — confirmed in `oi_image_test.dart`
- [ ] **REQ-0019:** All `OiButton` standard variants (`primary`, `secondary`, `outline`, `ghost`, `destructive`, `soft`) have `required String label` — confirmed in source, no change needed
- [ ] **REQ-0019:** `OiButton.icon()` has `required String label` — **IMPLEMENTED in ST1**
- [ ] **REQ-0019:** Test added verifying icon button exposes semantic label — **ADDED in ST2**
- [ ] **REQ-0020:** `OiIcon` default constructor has `required String label`; `OiIcon.decorative()` exists — confirmed in source, no change needed
- [ ] **REQ-0020:** Tests verify semantics label and decorative exclusion — confirmed in `oi_icon_test.dart`
- [ ] `flutter analyze` passes with zero issues
- [ ] `flutter test` passes — all existing + new tests green
- [ ] No placeholders or TODO comments introduced

---

### Cross-atom dependencies

REQ-0018 and REQ-0020 are independent and already fully resolved; they share no state or files with each other or with REQ-0019.

REQ-0019 (ST1 + ST2) is self-contained to `oi_button.dart` and `oi_button_test.dart`. The only ordering constraint is: **ST1 (source change) must precede ST2 (test fix)**, since fixing tests before the source change would compile against the old optional-parameter signature and the accessibility test would not compile against the new required one.Now I have a complete picture. Let me produce the implementation plan.

---

## Implementation Plan: WI-0001 — Accessibility Enforcement (Part 1/6)

---

### Concept

This work item enforces compile-time accessibility contracts on three UI primitives: `OiImage`, `OiButton`, and `OiIcon`. Callers are forced to supply meaningful labels or explicitly opt out via a named constructor, eliminating the class of accessibility bugs where interactive/informative widgets are silently invisible to screen readers.

---

### Current State Assessment (from code audit)

| Atom | Component | Status |
|---|---|---|
| REQ-0018 | `OiImage` | ✅ Already implemented — `required String alt`, `.decorative()` exists, tests pass |
| REQ-0019 | `OiButton` (standard variants) | ✅ All six standard variants + split/countdown/confirm already have `required String label` |
| REQ-0019 | `OiButton.icon()` | ❌ **Gap** — `semanticLabel` is `String?` (optional), no label enforced |
| REQ-0020 | `OiIcon` | ✅ Already implemented — `required String label`, `.decorative()` exists, tests pass |

The only source change needed is in `OiButton.icon()`: rename the parameter from optional `String? semanticLabel` to required `String label`.

---

### Sub-tasks

- **ST1:** Modify `OiButton.icon()` constructor — change `String? semanticLabel` to `required String label`, delegate to private constructor as `semanticLabel: label`
- **ST2:** Update `oi_button_test.dart` — fix two existing call sites that omit a label for `.icon()`, add a new semantic label test for the icon variant
- **ST3:** Audit `obers_ui.dart` exports to confirm all three classes are exported (no change expected)
- **ST4:** Verify REQ-0018 and REQ-0020 tests are present and sufficient (read-only confirmation, no changes expected)

---

### Method signatures

```dart
// MODIFIED — OiButton.icon() (lib/src/components/buttons/oi_button.dart:282)
const OiButton.icon({
  required IconData icon,
  required String label,          // was: String? semanticLabel
  VoidCallback? onTap,
  OiButtonSize size = OiButtonSize.medium,
  bool enabled = true,
  OiButtonVariant variant = OiButtonVariant.ghost,
  Key? key,
})
```

Everything else (`OiImage`, `OiIcon`, their named constructors, `_buildIconButton`) is unchanged in signature.

---

### Edge cases and fallbacks

| Case | Behaviour |
|---|---|
| `OiButton.icon()` called without `label` | Compile-time error — `required` parameter prevents build |
| Empty string passed as `label` | Accepted at runtime (caller's responsibility); Dart `required` does not enforce non-empty |
| Existing call sites without `label` | Will fail `dart analyze` / `flutter test` — fixed in ST2 |
| `OiImage` used with `alt: ''` | Accepted (caller chose empty alt for non-decorative use); enforcement is presence, not value |

---

### UX / requirement matching

- **REQ-0018 (OiImage):** Already satisfied — `required String alt` in default constructor; `OiImage.decorative()` for opt-out. Verified by existing tests `wraps in Semantics with alt label`, `decorative image uses ExcludeSemantics`.
- **REQ-0019 (OiButton):** Standard variants already satisfied. Gap is `OiButton.icon()` — making `label` required closes it. The `label` is forwarded as `semanticLabel` to `OiTappable`, which announces it to screen readers.
- **REQ-0020 (OiIcon):** Already satisfied — `required String label` in default constructor; `OiIcon.decorative()` for opt-out. Verified by existing tests `semantic icon has Semantics node with label`, `decorative icon has no labelled Semantics node`.

---

### Test cases

**Tests to add in `oi_button_test.dart`:**
1. `OiButton.icon passes semantic label to accessibility tree` — pump `OiButton.icon(icon: _kIcon, label: 'Close')`, verify a `Semantics` node exists with `label == 'Close'` (or verify via `OiTappable`'s semanticLabel propagation)

**Tests to update in `oi_button_test.dart`:**
1. Line 171: `OiButton.icon(icon: _kIcon, onTap: () => count++)` → add `label: 'Add'`
2. Line 184: `OiButton.icon(icon: _kIcon)` → add `label: 'Add'`

**Existing tests that continue to pass unchanged:**
- All `oi_image_test.dart` tests (REQ-0018 fully covered)
- All `oi_icon_test.dart` tests (REQ-0020 fully covered)
- All other `oi_button_test.dart` tests (standard variant labels already required)

---

### Design decisions and rationale

**Why `required String label` rather than `required String semanticLabel`?**  
Consistency with `OiIcon` and `OiImage` which both use `label`/`alt` as the public accessibility parameter name. The private constructor field (`semanticLabel`) remains internal; the delegation `semanticLabel: label` bridges the naming.

**Why not add an `OiButton.iconDecorative()` opt-out?**  
Icon buttons are by definition interactive. An interactive control without an accessible label is an accessibility violation with no legitimate opt-out — WCAG 2.1 SC 4.1.2 (Name, Role, Value, Level A) requires all interactive components to have a name.

**Why no runtime assertion for empty strings?**  
Dart's `required` enforces presence at compile time. Runtime non-empty validation would add noise for edge cases (e.g., labels sourced from i18n that are verified by other means). This is consistent with how `OiImage.alt` and `OiIcon.label` behave today.

---

### Potential risks and mitigations

| Risk | Mitigation |
|---|---|
| Downstream code using `OiButton.icon()` without a label | Breaking change is intentional and caught at compile time — migration path is trivial (add `label:`) |
| Tests instantiating `OiButton.icon()` without label fail before fix | ST2 is listed after ST1; tests are updated as part of this work item |
| `OiTappable` may not surface `semanticLabel` in the widget tree in a way widget tests can query | If `OiTappable` uses `Semantics(label: semanticLabel)`, the test can find it directly; if it wraps differently, test can use `tester.getSemantics()` with `SemanticsFlag.isButton` |

---

### Files to create or modify (MANDATORY)

1. [ ] `lib/src/components/buttons/oi_button.dart` — Change `OiButton.icon()` parameter from `String? semanticLabel` to `required String label`; update delegation to pass `semanticLabel: label`
2. [ ] `test/src/components/buttons/oi_button_test.dart` — Fix 2 broken call sites; add 1 new test for icon-button semantic label

No changes to:
- `lib/src/primitives/display/oi_image.dart` (REQ-0018 already complete)
- `lib/src/primitives/display/oi_icon.dart` (REQ-0020 already complete)
- `test/src/primitives/display/oi_image_test.dart` (coverage already sufficient)
- `test/src/primitives/display/oi_icon_test.dart` (coverage already sufficient)
- `lib/obers_ui.dart` (all three classes already exported)

---

### Commands to run in check phase

```
flutter analyze
flutter test test/src/components/buttons/oi_button_test.dart
flutter test test/src/primitives/display/oi_image_test.dart
flutter test test/src/primitives/display/oi_icon_test.dart
flutter test
```

---

### Definition of done checklist

- [ ] **REQ-0018:** `OiImage` default constructor has `required String alt`; `OiImage.decorative()` named constructor exists — confirmed in source, no change needed
- [ ] **REQ-0018:** Tests verify `Semantics(label: alt, image: true)` for non-decorative and `ExcludeSemantics` for decorative — confirmed in `oi_image_test.dart`
- [ ] **REQ-0019:** All `OiButton` standard variants (`primary`, `secondary`, `outline`, `ghost`, `destructive`, `soft`) have `required String label` — confirmed in source, no change needed
- [ ] **REQ-0019:** `OiButton.icon()` has `required String label` — **IMPLEMENTED in ST1**
- [ ] **REQ-0019:** Test added verifying icon button exposes semantic label — **ADDED in ST2**
- [ ] **REQ-0020:** `OiIcon` default constructor has `required String label`; `OiIcon.decorative()` exists — confirmed in source, no change needed
- [ ] **REQ-0020:** Tests verify semantics label and decorative exclusion — confirmed in `oi_icon_test.dart`
- [ ] `flutter analyze` passes with zero issues
- [ ] `flutter test` passes — all existing + new tests green
- [ ] No placeholders or TODO comments introduced

---

### Cross-atom dependencies

REQ-0018 and REQ-0020 are independent and already fully resolved; they share no state or files with each other or with REQ-0019.

REQ-0019 (ST1 + ST2) is self-contained to `oi_button.dart` and `oi_button_test.dart`. The only ordering constraint is: **ST1 (source change) must precede ST2 (test fix)**, since fixing tests before the source change would compile against the old optional-parameter signature and the accessibility test would not compile against the new required one.

## Implementation Checklist (MANDATORY — implement ALL)

1. [ ] `OiButton.icon()`
2. [ ] `OiImage.decorative()`
3. [ ] `OiIcon.decorative()`
4. [ ] `OiButton.icon(icon: _kIcon, label: 'Close')`
5. [ ] `OiButton.icon(icon: _kIcon)`
6. [ ] `OiButton.iconDecorative()`
7. [ ] `Semantics(label: semanticLabel)`
8. [ ] `tester.getSemantics()`
9. [ ] `Semantics(label: alt, image: true)`

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
6. When finished, write 'DONE: WI-0001' to the sentinel file at `.broins/work/runs/run-1773733505170/sentinel_WI-0001.txt`
7. Write an `implement.json` file to `.broins/work/runs/run-1773733505170/wi/WI-0001/results/implement.json` with:
   - `filesChanged`: list of files you modified
   - `commandsRun`: list of shell commands you executed
   - `notes`: any implementation notes
