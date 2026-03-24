<goal>
Build `obers_ui_forms` — a type-safe, stateful form management package that wraps the existing OiForm composite and adds enum-keyed field controllers, declarative validation (sync + async), computed/virtual fields, and rich form lifecycle management.

**Who benefits:** Developers using obers_ui who need stateful forms with type-safe data access, cross-field validation, and minimal boilerplate. The package makes complex multi-field forms (signup, checkout, settings) trivial to implement.

**Why it matters:** The existing OiForm provides declarative field rendering but lacks type-safe field access, advanced validation, computed fields, and fine-grained state control. This package closes that gap while remaining fully opt-in — all input widgets continue to work standalone.
</goal>

<background>
**Tech stack:** Flutter >=3.41.0, Dart >=3.11.0. Zero Material/Cupertino dependency.

**Project context:** obers_ui is a 160+ widget UI kit with 4-tier architecture (Foundation → Primitives → Components → Composites → Modules). All public classes use `Oi` prefix. Theme access via `context.colors`, `context.spacing`, etc. Text via `OiLabel.variant()`. Layout via `OiRow`/`OiColumn`.

**Existing form system:** `lib/src/composites/forms/oi_form.dart` provides `OiForm`, `OiFormField`, `OiFormSection`, `OiFormController` (ChangeNotifier). The new package wraps/extends this system.

**Existing input widgets (20+):** OiTextInput, OiNumberInput, OiDateInput, OiTimeInput, OiDateTimeInput, OiSelect, OiFormSelect, OiCheckbox, OiSwitch, OiRadio, OiSegmentedControl, OiSlider, OiTagInput, OiColorInput, OiFileInput, OiArrayInput, OiDatePickerField, OiTimePickerField, OiDateRangePickerField, OiSwitchTile, OiCheckboxTile, OiRadioTile.

**Package location:** `./packages/obers_ui_forms/` (sibling to existing `packages/obers_ui_charts/`)

**Dependency direction:** `obers_ui_forms` depends on `obers_ui` (imports its widgets and theme).

Files to examine:
- @lib/src/composites/forms/oi_form.dart — existing form system to wrap
- @lib/src/composites/forms/oi_form_dialog.dart — form dialog patterns
- @lib/src/composites/forms/oi_wizard.dart — multi-step form patterns
- @lib/src/components/inputs/ — all input widget APIs
- @lib/src/components/_internal/oi_input_frame.dart — input frame rendering
- @lib/src/foundation/theme/oi_theme.dart — InheritedWidget/context patterns
- @lib/src/models/oi_field_type.dart — OiFieldType enum
- @packages/obers_ui_charts/ — reference for separate package structure
</background>

<user_flows>
**Primary flow — Developer builds a type-safe form:**
1. Define an enum listing all form field keys (e.g., `SignupFields { name, email, password }`)
2. Create a controller class extending `OiFormController<SignupFields>`, defining `OiFormInputController<T>` for each field with validation rules, defaults, and options
3. Instantiate the controller in the widget, optionally passing initial values
4. Wrap the UI in `OiForm<SignupFields>(controller: controller, ...)` which provides the controller to descendants via `OiFormScope` InheritedWidget
5. Use `OiFormElement` wrappers for each input, passing the enum key — the widget auto-discovers its `OiFormInputController`, binds value/onChange/error display
6. Add `OiFormSubmitButton` which auto-disables when form is invalid
7. Handle submission via `onSubmit` callback receiving typed data + controller

**Alternative flow — External controller access:**
1. Developer creates controller and `OiFormInputController` instances outside the widget tree
2. Overrides specific field controllers via `formController.overwriteInputController(key, controller)`
3. Reads/writes field values programmatically: `formController.get<String>(SignupFields.name)`
4. Listens to form state changes via ChangeNotifier

**Alternative flow — Standalone input widgets (no form):**
1. All existing input widgets (OiTextInput, OiCheckbox, etc.) continue to work without OiForm
2. When no `OiFormScope` is in the ancestor tree, widgets use their own local state
3. Zero behavioral change from current standalone usage

**Alternative flow — Computed/virtual fields:**
1. Developer defines a field with `watch: [SignupFields.name]` and a `value` callback
2. When watched fields change, the computed field auto-updates
3. Computed fields can have `save: false` to exclude from form data export

**Error flow — Validation failure on submit:**
1. User taps submit button
2. All fields validate synchronously, then async validators run
3. Failed fields display inline error messages (below the input via `OiFormElement`)
4. A global error summary appears at the form level (configurable position)
5. First invalid field receives focus
6. Submit callback is NOT invoked

**Error flow — Async validation (e.g., email uniqueness check):**
1. User types in a field with an async validator
2. After debounce period, async validator fires
3. Field shows loading indicator during validation
4. On failure: inline error appears; on success: loading indicator clears
5. If user types again before async completes, previous async is cancelled

**Error flow — Cross-field revalidation:**
1. User changes password field
2. passwordRepeat field has `revalidateOnChangeOf: [SignupFields.password]`
3. passwordRepeat re-runs its `equals` validator against new password value
4. Error clears or appears accordingly
</user_flows>

<requirements>
**Functional:**
1. Separate Dart package at `./packages/obers_ui_forms/` with its own `pubspec.yaml`, depending on `obers_ui`
2. `OiFormController<E extends Enum>` base class (extends ChangeNotifier) with enum-keyed field map
3. `OiFormInputController<T>` per-field controller with: `required`, `validation`, `getter`, `setter`, `options`, `optionQuery`, `initFetch`, `watch`, `watchMode`, `value` (computed), `save`
4. Type-safe field access: `controller.get<T>(EnumKey)`, `controller.set<T>(EnumKey, value)`, `controller.getError(EnumKey)`, `controller.setError(EnumKey, message)`
5. Bulk operations: `controller.setMultiple(map)`, `controller.getData()`, `controller.getInitial()`, `controller.json()`
6. Form lifecycle: `controller.validate()`, `controller.reset()`, `controller.submit()`, `controller.enable()`, `controller.disable()`, `controller.enableField(key)`, `controller.disableField(key)`
7. State queries: `controller.isValid`, `controller.isDirty`, `controller.isFieldValid(key)`, `controller.isFieldDirty(key)`
8. `OiFormScope<E>` InheritedWidget providing controller to descendant widgets
9. `OiFormElement<E>` wrapper widget: renders label, connects input to controller via key, displays field-level error, supports `hideIf`/`showIf` callbacks, `revalidateOnChangeOf` list
10. `OiFormSubmitButton` auto-disables when form is invalid or during async validation
11. Input widget integration: existing obers_ui input widgets auto-discover their `OiFormInputController` from `OiFormScope` when a matching key is provided
12. Conditional field visibility: `hideIf` and `showIf` callbacks receiving the form controller, re-evaluated on controller changes
13. Computed/virtual fields: fields with `watch` + `value` callback auto-update when dependencies change
14. `OiFormWatchMode` enum: `onChange`, `onInit`, `onSubmit`, `onDirty`, `onValid`, `onInvalid`
15. Controller override: `controller.overwriteInputController(key, newController)` and `controller.getInputController(key)`
16. `save: false` flag on `OiFormInputController` to exclude transient fields (e.g., passwordRepeat) from `getData()` and `json()`
17. Getter/setter transformers on `OiFormInputController` for value transformation on read/write

**Validation:**
18. `OiFormValidation` class with static factory methods returning validator objects
19. Built-in sync validators: `min(int)`, `max(int)`, `minLength(int)`, `maxLength(int)`, `email()`, `url()`, `regex(String)`, `securePassword(...)`, `equals(EnumKey)`, `required()`, `custom((value, formController) => String?)`
20. Built-in async validators: `asyncCustom((value, formController) => Future<String?>)` with debounce duration parameter
21. Validators receive the current field value AND the full form controller for cross-field validation
22. Validation triggers: on submit (always), on change (configurable per field), on blur (configurable per field)
23. Async validation: debounce support, cancellation of in-flight requests, loading state per field

**Error Handling:**
24. Field-level error messages displayed inline below the input (via `OiFormElement`)
25. Global error summary at form level (configurable: top or bottom, collapsible)
26. `controller.getErrors()` returns all current errors as `Map<E, List<String>>`
27. Manual error injection: `controller.setError(key, message)` for server-side errors
28. Errors clear when field value changes (configurable: `clearErrorOnChange: true` default)

**UX:**
29. Enter-to-submit on single-line text fields (skip for multiline, select, etc.)
30. Tab order follows field declaration order by default, overridable per field
31. First invalid field auto-focuses on validation failure
32. Form-level and field-level disabled state propagates to input widgets
33. Loading state on async validation shown via input trailing indicator

**Edge Cases:**
34. Empty form (no fields) renders nothing, submit returns empty data
35. All-optional form is always valid when empty
36. Rapid value changes during async validation cancel previous requests
37. Form reset restores initial values and clears all errors
38. Disposing form controller cleans up all listeners and async operations
39. Nested forms (OiForm inside OiForm) — inner form uses its own scope, no conflict
40. Hot reload preserves form state (controller is external to widget tree)

**Accessibility:**
41. Error messages linked to inputs via semantics (announced by screen readers)
42. Required fields indicated with semantic label suffix
43. Form-level error summary navigable by screen reader
44. All form interactions keyboard-accessible (tab, enter, escape)
</requirements>

<boundaries>
**Edge cases:**
- Field with both `hideIf` and `showIf`: `showIf` takes precedence; if both return false, field is hidden
- Computed field with circular watch dependencies: detect at registration time, throw descriptive error
- `equals` validator referencing a non-existent field: throw at validation time with field key in message
- `optionQuery` returning empty results: show empty state message in select dropdown
- Form with no required fields and no values: `isValid` returns true, `isDirty` returns false
- Setting a value on a disabled field: value changes but no UI update until re-enabled
- Calling `submit()` while async validation is in flight: wait for completion, then proceed

**Error scenarios:**
- Duplicate enum keys in `inputs()` map: compile-time error (Dart map literal constraint)
- Type mismatch: `OiFormInputController<String>` bound to OiCheckbox (bool widget) — runtime assertion with descriptive message in debug mode
- Network failure during `optionQuery`: surface error via field-level error message, allow retry
- Validator throwing unhandled exception: catch, display generic error, log in debug mode

**Limits:**
- Maximum fields per form: no hard limit, but warn in docs about performance above 50 fields
- Async validator debounce: minimum 300ms default, configurable per validator
- Option query results: recommend pagination for >100 items via virtual scrolling (existing OiSelect capability)
</boundaries>

<implementation>
**Package structure:**
```
packages/obers_ui_forms/
├── lib/
│   ├── obers_ui_forms.dart              # barrel file
│   └── src/
│       ├── controllers/
│       │   ├── oi_form_controller.dart   # OiFormController<E>
│       │   └── oi_form_input_controller.dart  # OiFormInputController<T>
│       ├── validation/
│       │   ├── oi_form_validation.dart   # OiFormValidation static factories
│       │   ├── oi_form_validator.dart    # OiFormValidator base class (sync + async)
│       │   └── oi_form_watch_mode.dart   # OiFormWatchMode enum
│       ├── widgets/
│       │   ├── oi_form_scope.dart        # OiFormScope InheritedWidget
│       │   ├── oi_form_element.dart      # OiFormElement wrapper
│       │   ├── oi_form_submit_button.dart # OiFormSubmitButton
│       │   └── oi_form_error_summary.dart # Global error summary widget
│       └── extensions/
│           └── oi_form_context_ext.dart  # context.formController<E>() extension
├── test/
│   └── src/
│       ├── controllers/
│       │   ├── oi_form_controller_test.dart
│       │   └── oi_form_input_controller_test.dart
│       ├── validation/
│       │   ├── oi_form_validation_test.dart
│       │   └── oi_form_validator_test.dart
│       └── widgets/
│           ├── oi_form_scope_test.dart
│           ├── oi_form_element_test.dart
│           └── oi_form_submit_button_test.dart
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

**Patterns to use:**
- ChangeNotifier for `OiFormController` and `OiFormInputController` (consistent with existing obers_ui)
- InheritedWidget (`OiFormScope`) for context-based controller injection (consistent with `OiTheme`)
- Static factory methods on `OiFormValidation` for validator creation (declarative API)
- Constructor injection for all dependencies (testability)
- Generic type parameter `<E extends Enum>` on controller and scope for compile-time key safety

**What to avoid:**
- `Map<String, dynamic>` for field storage — use typed `OiFormInputController<T>` map keyed by enum. Only `json()` export produces `Map<String, dynamic>` at the boundary
- Material/Cupertino widgets — use OiLabel, OiSurface, OiRow, OiColumn, OiButton, etc.
- Global state or singletons — controller is instantiated and owned by the developer
- Provider/Riverpod/Bloc — use only ChangeNotifier + InheritedWidget (consistent with codebase)
- Hardcoded colors/spacing — use `context.colors`, `context.spacing`, `context.radius`
</implementation>

<stages>
**Phase 1: Core controllers and validation engine**
- `OiFormInputController<T>` with value storage, dirty tracking, enabled/disabled, required flag
- `OiFormController<E>` with field registration, get/set/reset, isDirty/isValid, getData/json
- `OiFormValidation` with all sync validators (min, max, email, regex, securePassword, equals, custom)
- `OiFormValidator` base class with sync/async contract
- Verify: all controller unit tests pass, `dart analyze` clean

**Phase 2: Async validation and computed fields**
- Async validator support with debounce, cancellation, loading state
- Computed/virtual fields with `watch`, `watchMode`, `value` callback
- Getter/setter transformers
- `save: false` transient field support
- Verify: async validation tests pass including cancellation and race conditions

**Phase 3: Widget layer**
- `OiFormScope<E>` InheritedWidget
- `OiFormElement<E>` with label, error display, hideIf/showIf, revalidateOnChangeOf
- `OiFormSubmitButton` with auto-disable
- `OiFormErrorSummary` global error display
- `context.formController<E>()` extension
- Input widget integration: existing obers_ui inputs auto-bind when key matches
- Verify: widget tests pass, form renders and submits correctly

**Phase 4: UX polish and accessibility**
- Enter-to-submit, tab order, auto-focus on validation failure
- Semantic labels for errors, required indicators
- Screen reader announcements for error summary
- Form enable/disable propagation
- Verify: accessibility tests pass, keyboard navigation works end-to-end

**Phase 5: Documentation and example**
- AI_README.md update with full form system documentation
- doc/ folder documentation update
- Example app form showcase (signup form as per requirements)
- Verify: example app runs, docs build, all tests pass
</stages>

<validation>
**Test strategy: TDD vertical-slice discipline**

Each phase follows strict RED → GREEN → REFACTOR cycles. One test at a time. Tests exercise public interfaces only.

**Testability seams:**
- `OiFormController<E>` accepts `OiFormInputController` map via `inputs()` override — testable without widgets
- `OiFormValidation` validators are pure functions/objects — testable in isolation
- Async validators accept injected `Duration` for debounce — deterministic in tests (use `Duration.zero`)
- `OiFormScope` is an InheritedWidget — testable with `pumpObers()` helper
- Clock/timer dependencies injected for async cancellation testing

**Behavior-first test slices (ordered by risk):**

*Phase 1 — Controllers:*
1. Happy path: create controller, set value, get value returns same type
2. Happy path: register field with required=true, empty value → isValid returns false
3. Happy path: fill all required fields → isValid returns true
4. Edge: isDirty returns false initially, true after set
5. Edge: reset() restores initial values, clears dirty
6. Edge: getData() excludes `save: false` fields
7. Edge: json() returns Map<String, dynamic> with all saved fields
8. Error: get<wrong type> → assertion error in debug

*Phase 1 — Sync validation:*
1. Happy path: min(5) passes for string length >= 5
2. Happy path: email() passes for valid email
3. Edge: min(5) fails for length 4, returns error message
4. Edge: equals(otherKey) compares against other field's current value
5. Edge: securePassword with all flags validates correctly
6. Edge: custom validator receives value + form controller
7. Error: regex with invalid pattern → descriptive error

*Phase 2 — Async validation:*
1. Happy path: async validator resolves, field error updates
2. Edge: rapid changes cancel previous async, only latest runs
3. Edge: debounce delays validation by configured duration
4. Edge: field shows loading during async validation
5. Error: async validator throws → caught, generic error displayed

*Phase 2 — Computed fields:*
1. Happy path: computed field updates when watched field changes
2. Edge: watchMode.onInit computes value at registration
3. Edge: circular watch dependency → throws at registration
4. Edge: computed field with save:false excluded from getData()

*Phase 3 — Widgets:*
1. Happy path: OiFormElement renders label and input, binds to controller
2. Happy path: OiFormElement displays error message from controller
3. Happy path: OiFormSubmitButton disables when isValid is false
4. Edge: hideIf callback hides field when condition met
5. Edge: revalidateOnChangeOf triggers revalidation on dependency change
6. Edge: no OiFormScope ancestor → input works standalone (no crash)
7. Error: OiFormErrorSummary lists all field errors

*Phase 4 — UX:*
1. Happy path: enter key on single-line text field triggers submit
2. Happy path: tab moves focus to next field in declaration order
3. Edge: enter key on multiline text field inserts newline (no submit)
4. Edge: validation failure auto-focuses first invalid field
5. Edge: disabled form prevents all input interaction

**Widget tests:** Use `pumpObers()` helper. Test form rendering, submission, error display, conditional visibility, keyboard interaction.

**Unit tests:** Controllers, validators, computed field logic — all pure Dart, no widget dependency.

**Mocking policy:** Prefer fakes over mocks. Only mock true external boundaries (e.g., `optionQuery` API calls). Use `FakeOiFormInputController` for widget tests that need pre-configured field state.
</validation>

<done_when>
1. `packages/obers_ui_forms/` package exists with clean `dart analyze`
2. All 5 phases complete with passing tests
3. `OiFormController<E>` supports: get/set/reset/validate/submit/enable/disable per-field and globally
4. Sync validators (min, max, email, regex, securePassword, equals, custom) all work
5. Async validators work with debounce, cancellation, and loading state
6. Computed fields update when watched dependencies change
7. `OiFormElement` renders labels, errors, and conditional visibility
8. `OiFormSubmitButton` auto-disables when form is invalid
9. Input widgets work standalone (no OiFormScope) with zero behavioral change
10. All existing obers_ui tests continue to pass (no regressions)
11. Example app demonstrates a complete signup form as described in requirements
12. AI_README.md updated with form system documentation
13. doc/ folder documentation updated
</done_when>
