## Overview

Type-safe stateful form package (`obers_ui_forms`) wrapping existing OiForm. Enum-keyed controllers, sync+async validation, computed fields, InheritedWidget scope for auto-binding input widgets.

**Spec**: `./forms-spec.md` (read this file for full requirements)

## Context

- **Structure**: Layer-first, 4-tier (Foundation → Primitives → Components → Composites). Separate package under `packages/`.
- **State management**: ChangeNotifier + InheritedWidget (no Provider/Riverpod/Bloc)
- **Reference implementations**:
  - `lib/src/composites/forms/oi_form.dart` — existing form controller + widget to wrap
  - `lib/src/foundation/theme/oi_theme.dart` — InheritedWidget scope pattern (of/maybeOf)
  - `packages/obers_ui_charts/` — satellite package structure (pubspec, barrel, tiers)
  - `lib/src/components/_internal/oi_input_frame.dart` — error/label rendering
  - `lib/src/components/inputs/oi_select.dart` — OiSelectScope InheritedNotifier pattern
- **Assumptions/Gaps**:
  - Wrapping, not replacing, existing OiForm — new package builds on top
  - `obers_ui_forms` depends on `obers_ui` via `path: ../../`
  - Existing input widgets need minor modifications to detect OiFormScope ancestor (opt-in auto-binding)
  - Existing form uses `Map<String, dynamic>` internally — new package uses typed `Map<E, OiFormInputController>`, `Map<String, dynamic>` only at `json()` boundary

## Plan

### Phase 1: Package scaffold + OiFormInputController<T>

- **Goal**: Standalone field controller with value, dirty, enabled, required, sync validation — fully unit-testable pure Dart
- [x] `packages/obers_ui_forms/pubspec.yaml` — create package; depend on `obers_ui` via path, same SDK constraints, very_good_analysis
- [x] `packages/obers_ui_forms/analysis_options.yaml` — extend very_good_analysis
- [x] `packages/obers_ui_forms/lib/obers_ui_forms.dart` — barrel file (library declaration, exports)
- [x] `packages/obers_ui_forms/lib/src/validation/oi_form_validator.dart` — `OiFormValidator` sealed class with `validate(value, controller)` returning `String?`; `OiAsyncFormValidator` subclass returning `Future<String?>`
- [x] `packages/obers_ui_forms/lib/src/validation/oi_form_validation.dart` — static factories: `min`, `max`, `minLength`, `maxLength`, `email`, `url`, `regex`, `securePassword`, `equals`, `required`, `custom`
- [x] `packages/obers_ui_forms/lib/src/validation/oi_form_watch_mode.dart` — `OiFormWatchMode` enum: `onChange`, `onInit`, `onSubmit`, `onDirty`, `onValid`, `onInvalid`
- [x] `packages/obers_ui_forms/lib/src/controllers/oi_form_input_controller.dart` — `OiFormInputController<T>` (ChangeNotifier): value, initialValue, required, validation list, getter/setter transformers, options, optionQuery, initFetch, watch, watchMode, save flag, enabled, errors list, isDirty, isValid, isValidating (async loading), validate(), reset(), dispose()
- [x] TDD: set value on input controller → get returns same typed value
- [x] TDD: required=true + null value → isValid false
- [x] TDD: required=true + non-null value → isValid true
- [x] TDD: isDirty false initially, true after setValue
- [x] TDD: reset() restores initialValue, clears dirty+errors
- [x] TDD: getter transforms value on read; setter transforms on write
- [x] TDD: enabled=false → field reports disabled state
- [x] TDD: min(5) validator passes for "hello", fails for "hi" with error message
- [x] TDD: email() passes "a@b.c", fails "notanemail"
- [x] TDD: securePassword with uppercase+specialChar flags validates correctly
- [x] TDD: regex validator passes/fails based on pattern match
- [x] TDD: custom validator receives value, returns null (pass) or String (error)
- [x] TDD: required() validator fails for null/empty, passes for non-empty
- [x] Verify: `cd packages/obers_ui_forms && dart analyze && dart test`

### Phase 2: OiFormController<E extends Enum>

- **Goal**: Enum-keyed form controller orchestrating multiple field controllers — get/set/validate/reset/submit/enable/disable globally and per-field
- [x] `packages/obers_ui_forms/lib/src/controllers/oi_form_controller.dart` — `OiFormController<E extends Enum>` (ChangeNotifier): abstract `Map<E, OiFormInputController> inputs()`, field registration on init, get<T>(key), set<T>(key, value), setMultiple(), getData() (excludes save:false), getInitial(), json(), validate(), reset(), submit(onSubmit), enable/disable(), enableField/disableField(key), isValid, isDirty, isFieldValid(key), isFieldDirty(key), getError(key), setError(key, msg), getErrors(), overwriteInputController(key), getInputController(key), dispose()
- [x] TDD: create controller with 2 fields → get/set typed values round-trip
- [x] TDD: register required field, leave empty → isValid false; fill → isValid true
- [x] TDD: isDirty false initially; set any field → isDirty true
- [x] TDD: reset() restores all fields to initial, clears dirty+errors
- [x] TDD: getData() excludes fields with save:false
- [x] TDD: json() returns Map<String, dynamic> keyed by enum name
- [x] TDD: validate() runs all field validators, collects errors into getErrors()
- [x] TDD: setError(key, msg) injects error; getError(key) retrieves it
- [x] TDD: equals(otherKey) validator compares against other field's current value
- [x] TDD: enable/disable form → all fields reflect state; enableField/disableField per-field
- [x] TDD: overwriteInputController replaces field controller, preserves registration
- [x] TDD: getInputController returns current field controller
- [x] TDD: setMultiple updates multiple fields, notifies once
- [x] TDD: getInitial() returns initial values map
- [x] Verify: `cd packages/obers_ui_forms && dart analyze && dart test`

### Phase 3: Async validation + computed fields

- **Goal**: Async validators with debounce/cancellation/loading + computed fields with watch dependencies
- [x] Extend `OiFormInputController` — async validation runner: debounce timer, cancellation token, isValidating state
- [x] `packages/obers_ui_forms/lib/src/validation/oi_form_validation.dart` — add `asyncCustom((value, controller) => Future<String?>, {debounce: Duration})` factory
- [x] Computed field logic in `OiFormController` — detect `watch` list on registration, subscribe to watched fields, invoke `value` callback on change per `watchMode`
- [x] Circular dependency detection at registration — topological sort or visited-set check, throw descriptive error
- [x] TDD: async validator resolves → field error updates
- [x] TDD: rapid value changes → only latest async validator result applied (previous cancelled)
- [x] TDD: debounce delays async validation by configured duration (inject Duration.zero in tests)
- [x] TDD: isValidating true during async run, false after resolve
- [x] TDD: async validator throws → caught, generic error displayed
- [x] TDD: computed field updates when watched field changes (watchMode.onChange)
- [x] TDD: watchMode.onInit computes value at registration time
- [x] TDD: circular watch dependency → throws at registration with descriptive message
- [x] TDD: computed field with save:false excluded from getData()
- [x] TDD: submit() while async in flight → waits for completion then proceeds
- [x] Verify: `cd packages/obers_ui_forms && dart analyze && dart test`

### Phase 4: Widget layer — OiFormScope + OiFormElement + OiFormSubmitButton

- **Goal**: InheritedWidget scope, form element wrapper with label/error/conditional visibility, submit button with auto-disable, error summary widget
- [x] `packages/obers_ui_forms/lib/src/widgets/oi_form_scope.dart` — `OiFormScope<E>` InheritedWidget with static `of<E>(context)` and `maybeOf<E>(context)`, wraps child with ListenableBuilder on controller
- [x] `packages/obers_ui_forms/lib/src/extensions/oi_form_context_ext.dart` — `context.formController<E>()` extension
- [x] `packages/obers_ui_forms/lib/src/widgets/oi_form_element.dart` — `OiFormElement<E>`: label (OiLabel), child input widget, error display below input, `hideIf`/`showIf` callbacks, `revalidateOnChangeOf` list, key binding to OiFormScope controller
- [x] `packages/obers_ui_forms/lib/src/widgets/oi_form_submit_button.dart` — `OiFormSubmitButton`: wraps OiButton, auto-disables when !isValid or isValidating, onSubmit callback
- [x] `packages/obers_ui_forms/lib/src/widgets/oi_form_error_summary.dart` — `OiFormErrorSummary<E>`: lists all field errors, configurable position (top/bottom), collapsible, uses OiLabel + context.colors.error
- [x] TDD: OiFormScope provides controller to descendant — child reads controller via context
- [x] TDD: OiFormElement renders label + child input, binds value/error from controller
- [x] TDD: OiFormElement displays error message when field has validation error
- [x] TDD: hideIf callback hides field when condition returns true
- [x] TDD: showIf takes precedence over hideIf when both present
- [x] TDD: revalidateOnChangeOf triggers re-validation when dependency field changes
- [x] TDD: OiFormSubmitButton disabled when isValid=false; enabled when isValid=true
- [x] TDD: OiFormSubmitButton disabled during async validation (isValidating)
- [x] TDD: OiFormErrorSummary lists all field errors from controller
- [x] TDD: no OiFormScope ancestor → OiFormElement renders child standalone (no crash)
- [x] TDD: errors clear when field value changes (clearErrorOnChange default behavior)
- [x] Verify: `cd packages/obers_ui_forms && flutter analyze && flutter test`

### Phase 5: UX polish — keyboard, focus, accessibility, disabled propagation

- **Goal**: Enter-to-submit, tab order, auto-focus on error, disabled state propagation, semantic labels
- [x] Enter-to-submit logic in OiFormElement: detect single-line text input → KeyboardListener for Enter → trigger controller.submit()
- [x] Tab order management: OiFormScope tracks field declaration order, manages FocusTraversalGroup
- [x] Auto-focus first invalid field on validation failure (controller.validate() returns first error key, OiFormElement requests focus)
- [x] Disabled state propagation: controller.disable() → all OiFormElements disable their child inputs
- [x] Accessibility: error messages wrapped in Semantics(liveRegion: true), required fields get semantic suffix, OiFormErrorSummary navigable by screen reader
- [x] TDD: enter on single-line text field triggers form submit
- [x] TDD: enter on multiline text field inserts newline (does not submit)
- [x] TDD: tab moves focus to next field in declaration order
- [x] TDD: validation failure auto-focuses first invalid field
- [x] TDD: disabled form prevents all input interaction
- [x] TDD: error messages have liveRegion semantics
- [x] TDD: required fields have semantic label suffix
- [x] Verify: `cd packages/obers_ui_forms && flutter analyze && flutter test`

### Phase 6: Documentation + example

- **Goal**: AI_README.md update, doc/ site update, example signup form
- [x] `AI_README.md` — add obers_ui_forms section: package overview, OiFormController API, OiFormInputController API, OiFormValidation catalog, OiFormScope/OiFormElement/OiFormSubmitButton usage, complete signup form example
- [x] `doc/documentation/docs/` — add forms documentation page(s) matching existing doc structure
- [x] `example/` — add form showcase page with signup form demonstrating: enum keys, typed controller, sync+async validation, computed fields, conditional visibility, cross-field validation, submit/reset/getData
- [x] `packages/obers_ui_forms/README.md` — package README with quick start
- [x] Verify: example app runs (`cd example && flutter run`), all tests pass across entire repo (`flutter test`), `dart analyze` clean

## Risks / Out of scope

**Risks:**
- Input widget auto-binding requires modifications to existing obers_ui input widgets (OiTextInput, OiCheckbox, etc.) to detect OiFormScope — scope changes carefully to avoid regressions
- Async validation race conditions — mitigated by cancellation token + debounce pattern with deterministic timer injection in tests
- Generic type erasure at runtime may complicate `OiFormScope.of<E>(context)` lookup — test with multiple form types in same tree

**Out of scope:**
- Multi-step form wizard integration (existing OiWizard handles this separately)
- Server-side rendering / SSR concerns
- Form persistence to local storage (can be built on top via json() export)
- Replacing existing OiForm — new package wraps/extends, does not replace
- File upload progress within form fields
