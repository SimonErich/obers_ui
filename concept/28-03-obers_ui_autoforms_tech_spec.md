# obers_ui_autoforms — Complete Technical Specification

> **Package:** `packages/obers_ui_autoforms`
> **Import:** `package:obers_ui_autoforms/obers_ui_autoforms.dart`
> **Prefix:** `OiAf` (e.g., `OiAfForm`, `OiAfTextInput`, `OiAfSelect`)
> **Depends on:** `obers_ui` (core), `collection` (deep equality)
> **Status:** New package. Replaces and supersedes the existing `OiForm`, `OiFormField`, `OiFormSection`, `OiFormController` composites in core obers_ui.

---

## Table of Contents

1. [Design Philosophy](#1-design-philosophy)
2. [Architecture Overview](#2-architecture-overview)
3. [Package Structure](#3-package-structure)
4. [Foundation Types](#4-foundation-types)
5. [Field Key & Enum Convention](#5-field-key--enum-convention)
6. [Field Definitions](#6-field-definitions)
7. [OiAfController — Form Controller](#7-oiafcontroller--form-controller)
8. [OiAfFieldController — Per-Field Runtime](#8-oiaffieldcontroller--per-field-runtime)
9. [Validation System](#9-validation-system)
10. [Derived Fields & Dependency Graph](#10-derived-fields--dependency-graph)
11. [Conditional Visibility & Enabled State](#11-conditional-visibility--enabled-state)
12. [Submit Pipeline](#12-submit-pipeline)
13. [Focus, Tab, Enter & Keyboard UX](#13-focus-tab-enter--keyboard-ux)
14. [Error Presentation](#14-error-presentation)
15. [Initialization, Reset, Patch & Restore](#15-initialization-reset-patch--restore)
16. [Persistence & Draft System](#16-persistence--draft-system)
17. [OiAfForm Widget](#17-oiafform-widget)
18. [OiAf* Field Widgets — Full Catalog](#18-oiaf-field-widgets--full-catalog)
19. [OiAfErrorSummary Widget](#19-oiaferrorsummary-widget)
20. [OiAfSubmitButton Widget](#20-oiafsubmitbutton-widget)
21. [OiAfResetButton Widget](#21-oiafresetbutton-widget)
22. [Internal Widget Binding Layer](#22-internal-widget-binding-layer)
23. [Accessibility](#23-accessibility)
24. [Internationalization](#24-internationalization)
25. [Performance](#25-performance)
26. [Diagnostics & Debug](#26-diagnostics--debug)
27. [Testing Strategy](#27-testing-strategy)
28. [Implementation Order](#28-implementation-order)
29. [Migration from Legacy OiForm](#29-migration-from-legacy-oiform)
30. [Claude Code Rules](#30-claude-code-rules)
31. [Complete Usage Example](#31-complete-usage-example)

---

## 1. Design Philosophy

This package provides **opt-in, controller-first, enum-keyed, context-bound stateful form handling** for obers_ui.

Core rules:

- **Controller defines all data behavior.** Validation, visibility, enabled state, derived fields, required, save/export — all live in the controller.
- **Widgets define all visual behavior.** Label, hint, placeholder, icons, layout, density, spacing — all live on the widget.
- **Enum field keys are the single identity mechanism.** Not widget keys, not strings, not paths.
- **Context propagates state.** `OiAfForm` injects an `OiAfScope` via `InheritedWidget`. Field widgets find their controller through context.
- **Existing obers_ui inputs remain standalone.** `OiAfTextInput` wraps `OiTextInput`; it does not replace it. All core input widgets work without this package.
- **Layout is fully free.** Fields can be placed in any Flutter layout — `OiRow`, `OiColumn`, `OiGrid`, `OiCard`, `OiSection`, dialogs, sheets, tabs, wizards — anywhere inside the `OiAfForm` subtree.
- **No `Map<String, dynamic>` in public API** except for `json()` export and persistence.
- **No exceptions for validation.** Validators return `String?`. Unexpected crashes are caught and normalized.

---

## 2. Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                   Developer's App                    │
│                                                     │
│  ┌──────────────────────────────────────────────┐   │
│  │  SignupFormController                         │   │
│  │  extends OiAfController<SignupField, Data>    │   │
│  │  ─ defineFields() { addTextField(...) }       │   │
│  │  ─ buildData() → SignupFormData               │   │
│  └──────────────────────────────────────────────┘   │
│                        │                             │
│  ┌─────────────────────▼────────────────────────┐   │
│  │  OiAfForm<SignupField, SignupFormData>         │   │
│  │  ─ provides OiAfScope via InheritedWidget     │   │
│  │  ─ manages submit/focus lifecycle             │   │
│  │  ─ child: any Flutter layout                  │   │
│  │    ┌──────────────────────────────────────┐   │   │
│  │    │  OiAfTextInput<SignupField>           │   │   │
│  │    │  ─ field: SignupField.name            │   │   │
│  │    │  ─ wraps OiTextInput                 │   │   │
│  │    │  ─ binds via context                 │   │   │
│  │    └──────────────────────────────────────┘   │   │
│  │    ┌──────────────────────────────────────┐   │   │
│  │    │  OiAfSelect<SignupField, String>      │   │   │
│  │    │  ─ field: SignupField.gender          │   │   │
│  │    │  ─ wraps OiSelect                    │   │   │
│  │    └──────────────────────────────────────┘   │   │
│  │    ┌──────────────────────────────────────┐   │   │
│  │    │  OiAfSubmitButton                    │   │   │
│  │    └──────────────────────────────────────┘   │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

### Tier Placement

- **OiAfForm** — Tier 3 Composite (composes Tier 2 inputs)
- **OiAf* field widgets** — Tier 3 Composite (thin adapters over Tier 2 inputs)
- **OiAfController, definitions, validators** — Non-widget runtime (no tier)

---

## 3. Package Structure

```
packages/
  obers_ui_autoforms/
    lib/
      obers_ui_autoforms.dart              ← Single barrel export
      src/
        foundation/
          oi_af_enums.dart                 ← All enums
          oi_af_typedefs.dart              ← All typedefs
          oi_af_reader.dart                ← OiAfReader<TField> interface
          oi_af_submit_result.dart          ← Sealed submit result classes
          oi_af_option.dart                ← OiAfOption<T> for select/combo
          oi_af_message_resolver.dart       ← i18n message resolver
          oi_af_aggregate_state.dart        ← Aggregate form state model
        definitions/
          oi_af_field_definition.dart       ← Base + all typed subclasses
        runtime/
          controller/
            oi_af_controller.dart          ← Main form controller
            oi_af_field_controller.dart     ← Base per-field runtime
            oi_af_text_field_controller.dart
            oi_af_number_field_controller.dart
            oi_af_bool_field_controller.dart
            oi_af_choice_field_controller.dart
            oi_af_multi_choice_field_controller.dart
            oi_af_date_field_controller.dart
            oi_af_time_field_controller.dart
            oi_af_datetime_field_controller.dart
            oi_af_tag_field_controller.dart
            oi_af_file_field_controller.dart
            oi_af_color_field_controller.dart
            oi_af_slider_field_controller.dart
            oi_af_array_field_controller.dart
          graphs/
            oi_af_dependency_graph.dart     ← Derived field topo-sort
            oi_af_focus_graph.dart          ← Focus traversal order
            oi_af_condition_tracker.dart    ← Proxy-based condition deps
          state/
            oi_af_tracking_reader.dart      ← Proxy reader for auto-deps
        validation/
          oi_af_validation_context.dart
          oi_af_form_validation_context.dart
          oi_af_validators.dart            ← Built-in validator factories
        persistence/
          oi_af_persistence_driver.dart
          oi_af_draft_payload.dart
          oi_af_json_exporter.dart
        widgets/
          root/
            oi_af_form.dart
            oi_af_scope.dart
          fields/
            _oi_af_field_binder.dart        ← Shared binding base (private)
            oi_af_text_input.dart
            oi_af_number_input.dart
            oi_af_checkbox.dart
            oi_af_switch.dart
            oi_af_radio.dart
            oi_af_select.dart
            oi_af_combo_box.dart
            oi_af_date_input.dart
            oi_af_time_input.dart
            oi_af_date_time_input.dart
            oi_af_tag_input.dart
            oi_af_slider.dart
            oi_af_color_input.dart
            oi_af_file_input.dart
            oi_af_array_input.dart
            oi_af_date_picker_field.dart
            oi_af_date_range_picker_field.dart
            oi_af_time_picker_field.dart
            oi_af_segmented_control.dart
            oi_af_rich_editor.dart
          aggregate/
            oi_af_error_summary.dart
            oi_af_submit_button.dart
            oi_af_reset_button.dart
        diagnostics/
          oi_af_observer.dart
          oi_af_debug_overlay.dart
    test/
      unit/
        foundation/
        definitions/
        runtime/
        validation/
        persistence/
      widget/
        fields/
        aggregate/
        integration/
      fixtures/
```

---

## 4. Foundation Types

### Enums

```dart
enum OiAfFieldType {
  text,
  number,
  checkbox,
  switcher,
  radio,
  select,
  multiSelect,
  comboBox,
  date,
  time,
  dateTime,
  datePicker,
  dateRangePicker,
  timePicker,
  tags,
  slider,
  color,
  file,
  array,
  segmentedControl,
  richText,
}

enum OiAfValidateMode {
  disabled,
  onSubmit,
  onBlur,
  onChange,
  onBlurThenChange,  // ← recommended default
  onInit,
}

enum OiAfValidationTrigger {
  init,
  change,
  blur,
  submit,
  manual,
  dependencyChange,
  restore,
}

enum OiAfDeriveMode {
  onChange,
  onInit,
  onSubmit,
}

enum OiAfDerivedOverrideMode {
  alwaysDerived,
  stopAfterUserEdit,    // ← recommended default
  allowManualOverride,
}

enum OiAfResetMode {
  toInitial,
  toCurrentPatchedValues,
  clear,
}

enum OiAfRestoreMode {
  patchCurrent,
  rebaseInitial,
}

enum OiAfValueSource {
  definitionInitial,
  controllerInitialData,
  restore,
  patch,
  user,
  derived,
  reset,
}
```

### Typedefs

```dart
typedef OiAfValidator<TField extends Enum, TValue> =
    FutureOr<String?> Function(OiAfValidationContext<TField, TValue> ctx);

typedef OiAfFormValidator<TField extends Enum> =
    FutureOr<String?> Function(OiAfFormValidationContext<TField> ctx);

typedef OiAfVisibleWhen<TField extends Enum> =
    bool Function(OiAfReader<TField> form);

typedef OiAfEnabledWhen<TField extends Enum> =
    bool Function(OiAfReader<TField> form);

typedef OiAfDerivedValue<TField extends Enum, TValue> =
    TValue? Function(OiAfReader<TField> form);

typedef OiAfValueGetter<TValue> = TValue? Function(Object? raw);
typedef OiAfValueSetter<TValue> = Object? Function(TValue? value);
typedef OiAfValueEquals<TValue> = bool Function(TValue? a, TValue? b);
```

### OiAfReader<TField> — Read-Only Form Interface

```dart
abstract class OiAfReader<TField extends Enum> {
  TValue? get<TValue>(TField field);
  TValue getOr<TValue>(TField field, TValue fallback);
  bool isFieldVisible(TField field);
  bool isFieldEnabled(TField field);
  bool isFieldDirty(TField field);
}
```

### OiAfTrackingReader<TField> — Automatic Dependency Discovery

This is the key to automatic condition dependency tracking. When evaluating `visibleWhen`/`enabledWhen` callbacks, we wrap the real reader in a tracking proxy that records which fields were read.

```dart
class OiAfTrackingReader<TField extends Enum> implements OiAfReader<TField> {
  OiAfTrackingReader(this._delegate);

  final OiAfReader<TField> _delegate;
  final Set<TField> _readFields = {};

  Set<TField> get readFields => Set.unmodifiable(_readFields);

  @override
  TValue? get<TValue>(TField field) {
    _readFields.add(field);
    return _delegate.get<TValue>(field);
  }

  @override
  TValue getOr<TValue>(TField field, TValue fallback) {
    _readFields.add(field);
    return _delegate.getOr<TValue>(field, fallback);
  }

  @override
  bool isFieldVisible(TField field) {
    _readFields.add(field);
    return _delegate.isFieldVisible(field);
  }

  @override
  bool isFieldEnabled(TField field) {
    _readFields.add(field);
    return _delegate.isFieldEnabled(field);
  }

  @override
  bool isFieldDirty(TField field) {
    _readFields.add(field);
    return _delegate.isFieldDirty(field);
  }

  void reset() => _readFields.clear();
}
```

**How condition tracking works:**

1. When a field value changes, the controller checks its cached condition dependency map.
2. For each conditional field whose cached dependencies include the changed field, re-evaluate the condition using a fresh `OiAfTrackingReader`.
3. After evaluation, update the cached dependency set with the newly read fields.
4. If the result (visible/enabled) changed, update the field controller and notify.
5. On first evaluation (no cache yet), evaluate ALL conditional fields and populate cache.

This gives: **automatic discovery, always-correct deps, O(affected_conditions) per field change.** No manual `visibleWhenDependsOn` lists needed. Typical forms (5–30 fields, 2–5 conditional) have negligible overhead.

### Submit Result (Sealed)

```dart
sealed class OiAfSubmitResult<TData> {
  const OiAfSubmitResult();
}

final class OiAfSubmitSuccess<TData> extends OiAfSubmitResult<TData> {
  final TData data;
  const OiAfSubmitSuccess(this.data);
}

final class OiAfSubmitInvalid<TData> extends OiAfSubmitResult<TData> {
  final Map<Enum, List<String>> fieldErrors;
  final List<String> globalErrors;
  const OiAfSubmitInvalid({required this.fieldErrors, required this.globalErrors});
}

final class OiAfSubmitFailure<TData> extends OiAfSubmitResult<TData> {
  final TData? data;
  final Object error;
  final StackTrace stackTrace;
  final List<String> globalErrors;
  const OiAfSubmitFailure({
    required this.error,
    required this.stackTrace,
    required this.globalErrors,
    this.data,
  });
}
```

### OiAfOption<T>

```dart
final class OiAfOption<T> {
  final T value;
  final String label;
  final bool enabled;
  final String? group;

  const OiAfOption({
    required this.value,
    required this.label,
    this.enabled = true,
    this.group,
  });
}
```

---

## 5. Field Key & Enum Convention

Every form defines its fields as an enum:

```dart
enum SignupField {
  name,
  username,
  email,
  password,
  passwordRepeat,
  newsletterSignup,
  source,
  gender,
}
```

The enum is the single identity for: value storage, validation, dependency graph, focus order, error tracking, visibility/enabled state, dirty/touched state, and export mapping.

---

## 6. Field Definitions

### Base Definition

```dart
abstract class OiAfFieldDefinition<TField extends Enum, TValue> {
  final TField field;
  final OiAfFieldType type;
  final TValue? initialValue;
  final bool required;
  final bool save;
  final bool clearErrorsOnChange;
  final bool validateOnInit;
  final bool excludeWhenHidden;
  final bool clearValueWhenHidden;
  final bool skipValidationWhenDisabled;
  final OiAfValidateMode? validateModeOverride;
  final OiAfValueGetter<TValue>? getter;
  final OiAfValueSetter<TValue>? setter;
  final OiAfValueEquals<TValue>? equals;
  final List<OiAfValidator<TField, TValue>> validators;
  final List<TField> revalidateWhen;
  final OiAfVisibleWhen<TField>? visibleWhen;
  final OiAfEnabledWhen<TField>? enabledWhen;
  final List<TField> dependsOn;
  final OiAfDeriveMode deriveMode;
  final OiAfDerivedOverrideMode derivedOverrideMode;
  final OiAfDerivedValue<TField, TValue>? derive;

  const OiAfFieldDefinition({
    required this.field,
    required this.type,
    this.initialValue,
    this.required = false,
    this.save = true,
    this.clearErrorsOnChange = true,
    this.validateOnInit = false,
    this.excludeWhenHidden = true,
    this.clearValueWhenHidden = false,
    this.skipValidationWhenDisabled = true,
    this.validateModeOverride,
    this.getter,
    this.setter,
    this.equals,
    this.validators = const [],
    this.revalidateWhen = const [],
    this.visibleWhen,
    this.enabledWhen,
    this.dependsOn = const [],
    this.deriveMode = OiAfDeriveMode.onChange,
    this.derivedOverrideMode = OiAfDerivedOverrideMode.stopAfterUserEdit,
    this.derive,
  });
}
```

### Typed Subclasses

One per field type. Each locks `type` and may add type-specific config:

| Subclass | Value Type | Extra Config |
|---|---|---|
| `OiAfTextFieldDef<TField>` | `String` | — |
| `OiAfNumberFieldDef<TField>` | `num` | `min`, `max`, `step`, `decimalPlaces` |
| `OiAfBoolFieldDef<TField>` | `bool?` | `tristate` |
| `OiAfSelectFieldDef<TField, TValue>` | `TValue` | `options: List<OiAfOption<TValue>>` |
| `OiAfMultiSelectFieldDef<TField, TValue>` | `List<TValue>` | `options: List<OiAfOption<TValue>>` |
| `OiAfComboBoxFieldDef<TField, TValue>` | `TValue` (or `List<TValue>`) | `options`, `multiSelect` |
| `OiAfRadioFieldDef<TField, TValue>` | `TValue` | `options: List<OiAfOption<TValue>>` |
| `OiAfDateFieldDef<TField>` | `DateTime` | `minDate`, `maxDate` |
| `OiAfTimeFieldDef<TField>` | `OiTimeOfDay` | `minTime`, `maxTime` |
| `OiAfDateTimeFieldDef<TField>` | `DateTime` | `minDate`, `maxDate` |
| `OiAfDatePickerFieldDef<TField>` | `DateTime` | `minDate`, `maxDate` |
| `OiAfDateRangePickerFieldDef<TField>` | `(DateTime, DateTime)` | `minDate`, `maxDate`, `presets` |
| `OiAfTimePickerFieldDef<TField>` | `OiTimeOfDay` | `use24Hour`, `minuteInterval` |
| `OiAfTagFieldDef<TField>` | `List<String>` | `maxTags` |
| `OiAfSliderFieldDef<TField>` | `double` (or `(double, double)` for range) | `min`, `max`, `divisions`, `isRange` |
| `OiAfColorFieldDef<TField>` | `Color` | — |
| `OiAfFileFieldDef<TField>` | `List<OiAfFileValue>` | `maxFiles`, `acceptedTypes` |
| `OiAfArrayFieldDef<TField, TItem>` | `List<TItem>` | `createEmpty`, `minItems`, `maxItems` |
| `OiAfSegmentedControlFieldDef<TField, TValue>` | `TValue` | `segments: List<OiAfOption<TValue>>` |
| `OiAfRichTextFieldDef<TField>` | `String` (HTML/delta) | — |

### OiTimeOfDay (New obers_ui Foundation Type)

**NOTE:** obers_ui core must expose `OiTimeOfDay` as a foundation type. If it already exists, use it. If not, create it in `obers_ui/src/foundation/`:

```dart
/// A time of day independent of Flutter's Material TimeOfDay.
/// Zero-dependency. Comparable. Immutable.
final class OiTimeOfDay implements Comparable<OiTimeOfDay> {
  final int hour;    // 0–23
  final int minute;  // 0–59
  final int second;  // 0–59

  const OiTimeOfDay({required this.hour, this.minute = 0, this.second = 0});

  factory OiTimeOfDay.now() { /* from DateTime.now() */ }

  String format24() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  String format12() { /* AM/PM format */ }

  @override int compareTo(OiTimeOfDay other) => /* hour, minute, second */ ;
  @override bool operator ==(Object other) => /* field equality */ ;
  @override int get hashCode => Object.hash(hour, minute, second);
  @override String toString() => format24();
}
```

---

## 7. OiAfController — Form Controller

### Public API

```dart
abstract class OiAfController<TField extends Enum, TData>
    extends ChangeNotifier
    implements OiAfReader<TField> {

  OiAfController();

  // --- Lifecycle ---
  bool get isInitialized;
  bool get isAttached;

  // --- Aggregate state ---
  bool get isValid;
  bool get isDirty;
  bool get isTouched;
  bool get isEnabled;
  bool get isSubmitting;
  bool get isValidating;
  bool get hasSubmitted;
  int get submitCount;
  OiAfSubmitResult<TData>? get lastSubmitResult;

  // --- Field registry ---
  List<TField> get registeredFields;
  OiAfFieldDefinition<TField, Object?> definitionOf(TField field);

  // --- Typed value access (from OiAfReader) ---
  @override TValue? get<TValue>(TField field);
  @override TValue getOr<TValue>(TField field, TValue fallback);

  // --- Value mutation ---
  void set<TValue>(TField field, TValue? value, {bool markDirty = true});
  void patch(Map<TField, Object?> values, {bool markDirty = true, bool validate = false});
  void rebase(Map<TField, Object?> values, {bool validate = false});
  void restore(Map<TField, Object?> values, {
    OiAfRestoreMode mode = OiAfRestoreMode.patchCurrent,
    bool validate = false,
  });

  // --- Field state queries ---
  @override bool isFieldDirty(TField field);
  bool isFieldTouched(TField field);
  bool isFieldValid(TField field);
  @override bool isFieldEnabled(TField field);
  @override bool isFieldVisible(TField field);

  // --- Field state mutation ---
  void disableField(TField field);
  void enableField(TField field);
  void disable();
  void enable();

  // --- Errors ---
  String? getError(TField field);
  List<String> getErrors(TField field);
  Map<TField, List<String>> getAllFieldErrors();
  List<String> get globalErrors;
  void setBackendError(TField field, String message);
  void setBackendErrors(TField field, List<String> messages);
  void setGlobalError(String message);
  void clearBackendErrors({TField? field});
  void clearErrors({TField? field, bool includeGlobal = true});

  // --- Field controller access ---
  OiAfFieldController<TField, TValue> fieldController<TValue>(TField field);

  // --- Validation ---
  Future<bool> validate({TField? field, OiAfValidationTrigger trigger = OiAfValidationTrigger.manual});

  // --- Submit ---
  Future<OiAfSubmitResult<TData>> submit();

  // --- Reset ---
  void reset({OiAfResetMode mode = OiAfResetMode.toInitial});

  // --- Export ---
  TData buildData();
  Map<String, dynamic> json();
  bool shouldExportField(TField field);

  // --- Focus ---
  void focusField(TField field);
  void focusFirstAvailableField();
  void focusFirstInvalidField();
  void focusNextField(TField currentField);
  void focusPreviousField(TField currentField);
  bool isLastFocusableField(TField field);
  bool isFirstFocusableField(TField field);

  // --- Diagnostics ---
  Map<String, dynamic> debugSnapshot();

  // --- Abstract: developer implements ---
  @protected void defineFields();
  TData buildData();

  // --- Registration helpers (called in defineFields()) ---
  @protected void addTextField(TField field, { ... });
  @protected void addNumberField(TField field, { ... });
  @protected void addBoolField(TField field, { ... });
  @protected void addSelectField<TValue>(TField field, { ... });
  @protected void addMultiSelectField<TValue>(TField field, { ... });
  @protected void addComboBoxField<TValue>(TField field, { ... });
  @protected void addRadioField<TValue>(TField field, { ... });
  @protected void addDateField(TField field, { ... });
  @protected void addTimeField(TField field, { ... });
  @protected void addDateTimeField(TField field, { ... });
  @protected void addDatePickerField(TField field, { ... });
  @protected void addDateRangePickerField(TField field, { ... });
  @protected void addTimePickerField(TField field, { ... });
  @protected void addTagField(TField field, { ... });
  @protected void addSliderField(TField field, { ... });
  @protected void addColorField(TField field, { ... });
  @protected void addFileField(TField field, { ... });
  @protected void addArrayField<TItem>(TField field, { ... });
  @protected void addSegmentedControlField<TValue>(TField field, { ... });
  @protected void addRichTextField(TField field, { ... });
  @protected void addFormValidator(OiAfFormValidator<TField> validator);
}
```

### Registration Helper Signature Example

Each `add*Field` method creates the matching definition subclass and internal field controller. Full parameter list mirrors the field definition.

```dart
@protected
void addTextField(
  TField field, {
  String? initialValue,
  bool required = false,
  bool save = true,
  bool clearErrorsOnChange = true,
  bool validateOnInit = false,
  bool excludeWhenHidden = true,
  bool clearValueWhenHidden = false,
  OiAfValidateMode? validateModeOverride,
  List<OiAfValidator<TField, String>> validators = const [],
  List<TField> revalidateWhen = const [],
  OiAfVisibleWhen<TField>? visibleWhen,
  OiAfEnabledWhen<TField>? enabledWhen,
  List<TField> dependsOn = const [],
  OiAfDeriveMode deriveMode = OiAfDeriveMode.onChange,
  OiAfDerivedOverrideMode derivedOverrideMode = OiAfDerivedOverrideMode.stopAfterUserEdit,
  OiAfDerivedValue<TField, String>? derive,
});
```

### Controller Lifecycle

1. **Construction** — `defineFields()` runs, all field definitions sealed, internal field controllers created, initial values resolved, dependency graph built, derived fields computed in topo-order, validate-on-init fields validated.
2. **Attachment** — `OiAfForm` mounts, attaches controller to scope, applies form-level config (validateMode, enabled, submit callbacks).
3. **Field Binding** — `OiAfTextInput(field: ...)` etc. find controller via context, subscribe to their field controller only.
4. **Interaction** — Value changes → dirty/touched → dependent derivations → dependent revalidations → conditional re-evaluation.
5. **Submission** — Full validation → buildData() → callback → error mapping → result.
6. **Reset/Dispose** — State restoration or cleanup.

### Construction Guards

- Duplicate field registration → assert in debug, throw `StateError` in release
- `derive != null` but `dependsOn` empty → assert
- Dependency on unregistered field → assert
- Cycle in derived dependency graph → assert
- Controller attached to two live `OiAfForm` widgets simultaneously → assert

---

## 8. OiAfFieldController — Per-Field Runtime

### Public API

```dart
abstract class OiAfFieldController<TField extends Enum, TValue>
    extends ChangeNotifier {

  OiAfFieldDefinition<TField, TValue> get definition;
  TField get field;
  OiAfFieldType get type;

  TValue? get value;
  TValue? get initialValue;

  bool get isDirty;
  bool get isTouched;
  bool get isFocused;
  bool get isEnabled;
  bool get isVisible;
  bool get isValid;
  bool get isValidating;
  bool get hasErrors;
  bool get hasUserEdited;
  bool get isDerived;

  String? get primaryError;
  List<String> get errors;

  /// Presentation metadata registered by bound widget
  String? get displayLabel;

  void setValue(TValue? value, {
    bool markDirty = true,
    bool markTouched = true,
    bool fromUser = true,
    bool notify = true,
  });

  void setFocused(bool focused, {bool notify = true});
  void setTouched(bool touched, {bool notify = true});
  void setEnabled(bool enabled, {bool notify = true});
  void setVisible(bool visible, {bool notify = true});

  void setError(String error, {bool notify = true});
  void setErrors(List<String> errors, {bool notify = true});
  void clearErrors({bool notify = true});

  void setBackendError(String error, {bool notify = true});
  void setBackendErrors(List<String> errors, {bool notify = true});
  void clearBackendErrors({bool notify = true});

  Future<bool> validate({OiAfValidationTrigger trigger = OiAfValidationTrigger.manual});

  void reset({bool notify = true});

  // --- Widget binding (internal) ---
  void attachWidget();
  void detachWidget();
  void registerPresentationMetadata({String? label, String? semanticLabel});

  // --- Focus registration (internal) ---
  void registerFocusNode(FocusNode node);
  void unregisterFocusNode(FocusNode node);
  FocusNode? get registeredFocusNode;
}
```

### Internal Error Buckets

Each field controller stores errors in three separate buckets:

```dart
final List<String> _validationErrors = [];
final List<String> _backendErrors = [];
final List<String> _runtimeErrors = [];

List<String> get errors => List.unmodifiable([
  ..._validationErrors,
  ..._backendErrors,
  ..._runtimeErrors,
]);

String? get primaryError => errors.isEmpty ? null : errors.first;
```

### Value Setting Pipeline

When `setValue()` is called:

1. Normalize incoming value via `_normalizeIncomingValue(value)`
2. Compare with current using deep equality (respects `definition.equals`)
3. If same and no touch change needed → return early
4. Store new value
5. Mark touched if `markTouched`
6. Mark `_hasUserEdited` if `fromUser`
7. If derived with `stopAfterUserEdit` and `fromUser` → set `_manualOverrideActive`
8. Recompute dirty by comparing to `_initialValue`
9. Clear stale errors if `clearErrorsOnChange`
10. Clear backend errors if `fromUser`
11. Notify listeners
12. Tell form controller: `_handleFieldValueChanged(field, fromUser)`

### Async Validation Race Safety

Each field keeps `_validationVersion` (int). On validate():

1. Increment `_validationVersion`
2. Capture `version = _validationVersion`
3. Run validators sequentially
4. Before applying each result, check `version == _validationVersion`
5. If stale, discard and return false
6. Wrap each validator call in try/catch — thrown exceptions become fallback error messages

---

## 9. Validation System

### Validator Contract

```dart
typedef OiAfValidator<TField extends Enum, TValue> =
    FutureOr<String?> Function(OiAfValidationContext<TField, TValue> ctx);
```

Returns `null` for valid, a `String` error message for invalid.

### Validation Context

```dart
final class OiAfValidationContext<TField extends Enum, TValue> {
  final TField field;
  final TValue? value;
  final OiAfReader<TField> form;
  final OiAfValidationTrigger trigger;
  final bool isRequired;
  final bool isVisible;
  final bool isEnabled;

  const OiAfValidationContext({ ... });
}
```

### 9.1 Validation Timing — The State Machine (CRITICAL)

The `OiAfValidateMode` controls WHEN errors appear. Getting this wrong makes forms feel hostile (showing "invalid email" while the user is still typing). The default mode `onBlurThenChange` is the recommended UX-optimal behavior.

**Each field controller tracks an internal validation phase:**

```dart
enum _OiAfFieldValidationPhase {
  pristine,      // never interacted — show NO errors regardless of validity
  blurredOnce,   // user focused and left the field — now show errors
  activelyEditing, // user is changing after first blur — show errors live
}
```

**The state machine works per-field:**

```
                    ┌─────────────┐
          mount ──▶ │   pristine   │ ── no errors shown, ever
                    └──────┬──────┘
                           │ user focuses + blurs (loses focus)
                           ▼
                    ┌─────────────┐
                    │ blurredOnce  │ ── validate NOW, show errors if any
                    └──────┬──────┘
                           │ user changes value (types again)
                           ▼
                    ┌──────────────────┐
                    │ activelyEditing   │ ── validate on each change, clear when fixed
                    └──────────────────┘
```

**Exact behavior per mode:**

| Mode | On Change (typing) | On Blur (click out) | On Submit |
|---|---|---|---|
| `disabled` | never | never | never (manual only) |
| `onSubmit` | never | never | validate all |
| `onBlur` | never | validate | validate all |
| `onChange` | validate immediately | validate | validate all |
| **`onBlurThenChange`** | **only if phase ≥ blurredOnce** | **validate (sets phase)** | **validate all** |
| `onInit` | validate immediately | validate | validate all |

**The `onBlurThenChange` algorithm in detail:**

```dart
// Inside field controller — called when the form runtime decides whether to validate

bool _shouldValidateForTrigger(OiAfValidationTrigger trigger, OiAfValidateMode mode) {
  if (trigger == OiAfValidationTrigger.submit) return true;  // always
  if (trigger == OiAfValidationTrigger.manual) return true;  // always
  if (trigger == OiAfValidationTrigger.dependencyChange) return true; // always

  switch (mode) {
    case OiAfValidateMode.disabled:
      return false;
    case OiAfValidateMode.onSubmit:
      return trigger == OiAfValidationTrigger.submit;
    case OiAfValidateMode.onBlur:
      return trigger == OiAfValidationTrigger.blur;
    case OiAfValidateMode.onChange:
      return true;
    case OiAfValidateMode.onBlurThenChange:
      if (trigger == OiAfValidationTrigger.blur) {
        _validationPhase = _OiAfFieldValidationPhase.blurredOnce;
        return true;
      }
      if (trigger == OiAfValidationTrigger.change) {
        return _validationPhase.index >= _OiAfFieldValidationPhase.blurredOnce.index;
      }
      return false;
    case OiAfValidateMode.onInit:
      return true;
  }
}
```

**What the user experiences with `onBlurThenChange` (email field example):**

1. User clicks into email field → nothing happens
2. User types "j" → no error shown (phase is still `pristine`)
3. User types "john" → still no error (pristine)
4. User tabs to next field (blur) → field validates → shows "Please enter a valid email address." (phase becomes `blurredOnce`)
5. User clicks back into email field, types "@" → field re-validates on this change → still invalid → error stays
6. User types "example.com" → field re-validates → now valid → **error immediately disappears**
7. User keeps typing → continues validating on each change, errors appear/disappear in real-time

**This is the correct UX because:**
- No premature errors while the user is composing input for the first time
- Clear feedback once the user signals "I'm done with this field" (blur)
- Instant correction feedback once the user goes back to fix it
- Errors vanish the moment the input becomes valid — no waiting for another blur

**Error clearing rule:** When `clearErrorsOnChange == true` (default), field errors are cleared at the START of each `setValue()` call, even before validation re-runs. This means: user types → errors clear → validation runs → if still invalid, new errors appear. In practice this feels instant. If valid, errors stay clear. This is the "disappears as soon as we fixed it" behavior.

**Submit always validates everything regardless of phase.** After a submit attempt, all fields that had errors enter `blurredOnce` phase at minimum, so subsequent edits show/clear errors in real-time.

### Built-in Validators — `OiAfValidators`

The built-in validators are inspired by Laravel's comprehensive validation rule set (reference: https://laravel.com/docs/13.x/validation#available-validation-rules). Each accepts an optional `message` parameter for custom error text; when omitted, the `OiAfMessageResolver` provides the localized default.

**Behavior rules:**
- `required` is auto-prepended by the runtime if `definition.required == true`. Do NOT add `requiredText` manually when using `required: true`.
- ALL validators below that check content (length, pattern, etc.) **ignore empty/null values** — they do not duplicate required logic. Only `required*` validators reject empty.
- Cross-field validators read from `ctx.form`.

```dart
abstract final class OiAfValidators {

  // ═══════════════════════════════════════════
  //  PRESENCE / REQUIRED
  // ═══════════════════════════════════════════

  /// Value must be non-null and non-empty string (after trim).
  static OiAfValidator<TField, String> requiredText<TField extends Enum>({String? message});

  /// Value must be non-null. For collections, must be non-empty.
  static OiAfValidator<TField, Object?> requiredValue<TField extends Enum>({String? message});

  /// Value must be exactly `true`.
  static OiAfValidator<TField, bool?> requiredTrue<TField extends Enum>({String? message});

  /// Value must be exactly `false` (for "decline terms" patterns).
  static OiAfValidator<TField, bool?> requiredFalse<TField extends Enum>({String? message});

  /// Required only if another field equals a specific value.
  /// Laravel: required_if
  static OiAfValidator<TField, Object?> requiredIf<TField extends Enum>(
    TField otherField, Object? value, {String? message});

  /// Required unless another field equals a specific value.
  /// Laravel: required_unless
  static OiAfValidator<TField, Object?> requiredUnless<TField extends Enum>(
    TField otherField, Object? value, {String? message});

  /// Required only when another field is present and non-empty.
  /// Laravel: required_with
  static OiAfValidator<TField, Object?> requiredWith<TField extends Enum>(
    List<TField> otherFields, {String? message});

  /// Required only when ALL other fields are present and non-empty.
  /// Laravel: required_with_all
  static OiAfValidator<TField, Object?> requiredWithAll<TField extends Enum>(
    List<TField> otherFields, {String? message});

  /// Required only when another field is empty/absent.
  /// Laravel: required_without
  static OiAfValidator<TField, Object?> requiredWithout<TField extends Enum>(
    List<TField> otherFields, {String? message});

  /// Required only when ALL other fields are empty/absent.
  /// Laravel: required_without_all
  static OiAfValidator<TField, Object?> requiredWithoutAll<TField extends Enum>(
    List<TField> otherFields, {String? message});

  // ═══════════════════════════════════════════
  //  STRING RULES
  // ═══════════════════════════════════════════

  /// Minimum character length.
  /// Laravel: min (for strings)
  static OiAfValidator<TField, String> minLength<TField extends Enum>(int min, {String? message});

  /// Maximum character length.
  /// Laravel: max (for strings)
  static OiAfValidator<TField, String> maxLength<TField extends Enum>(int max, {String? message});

  /// Exact character length.
  /// Laravel: size (for strings)
  static OiAfValidator<TField, String> exactLength<TField extends Enum>(int length, {String? message});

  /// Character length must be between min and max (inclusive).
  /// Laravel: between (for strings)
  static OiAfValidator<TField, String> lengthBetween<TField extends Enum>(int min, int max, {String? message});

  /// Valid email address format.
  /// Laravel: email
  static OiAfValidator<TField, String> email<TField extends Enum>({String? message});

  /// Valid URL format (http/https).
  /// Laravel: url
  static OiAfValidator<TField, String> url<TField extends Enum>({
    List<String> protocols = const ['http', 'https'],
    String? message,
  });

  /// Matches a regular expression.
  /// Laravel: regex
  static OiAfValidator<TField, String> regex<TField extends Enum>(RegExp pattern, {String? message});

  /// Does NOT match a regular expression.
  /// Laravel: not_regex
  static OiAfValidator<TField, String> notRegex<TField extends Enum>(RegExp pattern, {String? message});

  /// Only alphabetic characters (Unicode \p{L}).
  /// Laravel: alpha
  static OiAfValidator<TField, String> alpha<TField extends Enum>({bool asciiOnly = false, String? message});

  /// Only alphanumeric characters (Unicode \p{L}\p{N}).
  /// Laravel: alpha_num
  static OiAfValidator<TField, String> alphaNumeric<TField extends Enum>({bool asciiOnly = false, String? message});

  /// Alphanumeric + dashes + underscores.
  /// Laravel: alpha_dash
  static OiAfValidator<TField, String> alphaDash<TField extends Enum>({bool asciiOnly = false, String? message});

  /// Must start with one of the given prefixes.
  /// Laravel: starts_with
  static OiAfValidator<TField, String> startsWith<TField extends Enum>(
    List<String> prefixes, {String? message});

  /// Must end with one of the given suffixes.
  /// Laravel: ends_with
  static OiAfValidator<TField, String> endsWith<TField extends Enum>(
    List<String> suffixes, {String? message});

  /// Must NOT start with any of the given prefixes.
  /// Laravel: doesnt_start_with
  static OiAfValidator<TField, String> doesntStartWith<TField extends Enum>(
    List<String> prefixes, {String? message});

  /// Must NOT end with any of the given suffixes.
  /// Laravel: doesnt_end_with
  static OiAfValidator<TField, String> doesntEndWith<TField extends Enum>(
    List<String> suffixes, {String? message});

  /// Must be entirely lowercase.
  /// Laravel: lowercase
  static OiAfValidator<TField, String> lowercase<TField extends Enum>({String? message});

  /// Must be entirely uppercase.
  /// Laravel: uppercase
  static OiAfValidator<TField, String> uppercase<TField extends Enum>({String? message});

  /// Only 7-bit ASCII characters.
  /// Laravel: ascii
  static OiAfValidator<TField, String> ascii<TField extends Enum>({String? message});

  /// Must be valid JSON.
  /// Laravel: json
  static OiAfValidator<TField, String> json<TField extends Enum>({String? message});

  /// Must be a valid UUID.
  /// Laravel: uuid
  static OiAfValidator<TField, String> uuid<TField extends Enum>({String? message});

  /// Must be a valid ULID.
  /// Laravel: ulid
  static OiAfValidator<TField, String> ulid<TField extends Enum>({String? message});

  /// Must be a valid IPv4 or IPv6 address.
  /// Laravel: ip / ipv4 / ipv6
  static OiAfValidator<TField, String> ipAddress<TField extends Enum>({
    bool v4Only = false, bool v6Only = false, String? message});

  /// Must be a valid hex color (#RGB, #RRGGBB, #RRGGBBAA).
  /// Laravel: hex_color
  static OiAfValidator<TField, String> hexColor<TField extends Enum>({String? message});

  /// Secure password with configurable requirements.
  /// Combination of Laravel: password rule features
  static OiAfValidator<TField, String> securePassword<TField extends Enum>({
    int minLength = 8,
    bool requiresUppercase = false,
    bool requiresLowercase = false,
    bool requiresDigit = false,
    bool requiresSpecialChar = false,
    String? message,
  });

  // ═══════════════════════════════════════════
  //  NUMERIC RULES
  // ═══════════════════════════════════════════

  /// Minimum numeric value.
  /// Laravel: min (for numerics), gt
  static OiAfValidator<TField, num?> min<TField extends Enum>(num min, {String? message});

  /// Maximum numeric value.
  /// Laravel: max (for numerics), lt
  static OiAfValidator<TField, num?> max<TField extends Enum>(num max, {String? message});

  /// Numeric value must be between min and max (inclusive).
  /// Laravel: between (for numerics)
  static OiAfValidator<TField, num?> range<TField extends Enum>(num min, num max, {String? message});

  /// Must be greater than another field's value.
  /// Laravel: gt:field
  static OiAfValidator<TField, num?> greaterThanField<TField extends Enum>(TField other, {String? message});

  /// Must be less than another field's value.
  /// Laravel: lt:field
  static OiAfValidator<TField, num?> lessThanField<TField extends Enum>(TField other, {String? message});

  /// Must be a multiple of the given value.
  /// Laravel: multiple_of
  static OiAfValidator<TField, num?> multipleOf<TField extends Enum>(num factor, {String? message});

  /// Must be an integer (no decimals).
  /// Laravel: integer
  static OiAfValidator<TField, num?> integer<TField extends Enum>({String? message});

  /// Must have exactly N decimal places, or between min and max.
  /// Laravel: decimal
  static OiAfValidator<TField, num?> decimal<TField extends Enum>(int minPlaces, {int? maxPlaces, String? message});

  /// Number of digits must be between min and max.
  /// Laravel: digits_between
  static OiAfValidator<TField, num?> digitsBetween<TField extends Enum>(int min, int max, {String? message});

  // ═══════════════════════════════════════════
  //  COMPARISON / CROSS-FIELD RULES
  // ═══════════════════════════════════════════

  /// Must equal another field's value (e.g., confirm password).
  /// Laravel: same, confirmed
  static OiAfValidator<TField, String> equalsField<TField extends Enum>(TField other, {String? message});

  /// Must NOT equal another field's value.
  /// Laravel: different
  static OiAfValidator<TField, Object?> differentFromField<TField extends Enum>(TField other, {String? message});

  /// Value must be in a fixed list.
  /// Laravel: in
  static OiAfValidator<TField, TValue> isIn<TField extends Enum, TValue>(
    List<TValue> allowed, {String? message});

  /// Value must NOT be in a fixed list.
  /// Laravel: not_in
  static OiAfValidator<TField, TValue> notIn<TField extends Enum, TValue>(
    List<TValue> disallowed, {String? message});

  // ═══════════════════════════════════════════
  //  DATE RULES
  // ═══════════════════════════════════════════

  /// Date must be after another date or field.
  /// Laravel: after
  static OiAfValidator<TField, DateTime?> dateAfter<TField extends Enum>(
    DateTime date, {String? message});

  /// Date must be after another field's date value.
  /// Laravel: after (with field reference)
  static OiAfValidator<TField, DateTime?> dateAfterField<TField extends Enum>(
    TField otherField, {String? message});

  /// Date must be after or equal to a date.
  /// Laravel: after_or_equal
  static OiAfValidator<TField, DateTime?> dateAfterOrEqual<TField extends Enum>(
    DateTime date, {String? message});

  /// Date must be before a date.
  /// Laravel: before
  static OiAfValidator<TField, DateTime?> dateBefore<TField extends Enum>(
    DateTime date, {String? message});

  /// Date must be before another field's date value.
  /// Laravel: before (with field reference)
  static OiAfValidator<TField, DateTime?> dateBeforeField<TField extends Enum>(
    TField otherField, {String? message});

  /// Date must be before or equal to a date.
  /// Laravel: before_or_equal
  static OiAfValidator<TField, DateTime?> dateBeforeOrEqual<TField extends Enum>(
    DateTime date, {String? message});

  /// Date must equal exactly this date (date only, ignoring time).
  /// Laravel: date_equals
  static OiAfValidator<TField, DateTime?> dateEquals<TField extends Enum>(
    DateTime date, {String? message});

  /// Date must be today or in the future.
  static OiAfValidator<TField, DateTime?> dateInFuture<TField extends Enum>({
    bool includeToday = true, String? message});

  /// Date must be today or in the past.
  static OiAfValidator<TField, DateTime?> dateInPast<TField extends Enum>({
    bool includeToday = true, String? message});

  // ═══════════════════════════════════════════
  //  COLLECTION / ARRAY RULES
  // ═══════════════════════════════════════════

  /// List must have minimum N items.
  /// Laravel: min (for arrays)
  static OiAfValidator<TField, List?> minItems<TField extends Enum>(int min, {String? message});

  /// List must have maximum N items.
  /// Laravel: max (for arrays)
  static OiAfValidator<TField, List?> maxItems<TField extends Enum>(int max, {String? message});

  /// List must have exactly N items.
  /// Laravel: size (for arrays)
  static OiAfValidator<TField, List?> exactItems<TField extends Enum>(int count, {String? message});

  /// List must contain all of the given values.
  /// Laravel: contains
  static OiAfValidator<TField, List<TValue>?> contains<TField extends Enum, TValue>(
    List<TValue> required, {String? message});

  /// List must NOT contain any of the given values.
  /// Laravel: doesnt_contain
  static OiAfValidator<TField, List<TValue>?> doesntContain<TField extends Enum, TValue>(
    List<TValue> forbidden, {String? message});

  /// All items in the list must be unique (no duplicates).
  /// Laravel: distinct
  static OiAfValidator<TField, List?> distinct<TField extends Enum>({bool ignoreCase = false, String? message});

  // ═══════════════════════════════════════════
  //  FILE RULES
  // ═══════════════════════════════════════════

  /// File must not exceed max size in KB.
  /// Laravel: max (for files)
  static OiAfValidator<TField, List<OiAfFileValue>?> maxFileSize<TField extends Enum>(
    int maxKb, {String? message});

  /// File must have one of these extensions.
  /// Laravel: extensions, mimes
  static OiAfValidator<TField, List<OiAfFileValue>?> fileExtensions<TField extends Enum>(
    List<String> allowed, {String? message});

  // ═══════════════════════════════════════════
  //  GENERAL / UTILITY
  // ═══════════════════════════════════════════

  /// Stop running further validators on this field after first failure.
  /// Laravel: bail
  static OiAfValidator<TField, TValue> bail<TField extends Enum, TValue>();

  /// Custom synchronous or async validator.
  static OiAfValidator<TField, TValue> custom<TField extends Enum, TValue>(
    FutureOr<String?> Function(OiAfValidationContext<TField, TValue>) fn,
  );
}
```

### Form-Level Validators

```dart
typedef OiAfFormValidator<TField extends Enum> =
    FutureOr<String?> Function(OiAfFormValidationContext<TField> ctx);

final class OiAfFormValidationContext<TField extends Enum> {
  final OiAfReader<TField> form;
  final OiAfValidationTrigger trigger;

  const OiAfFormValidationContext({required this.form, required this.trigger});
}
```

Form-level validator errors go into `globalErrors`, not field errors.

### Validation Execution Order (per field)

1. Skip if hidden + `excludeWhenHidden`
2. Skip if disabled + `skipValidationWhenDisabled`
3. Check `_shouldValidateForTrigger()` — if timing says "not now", skip
4. Run `required` validator if `definition.required`
5. If `bail` is in the validator list and an error exists, stop
6. Run sync validators in declared order
7. Run async validators in declared order
8. Discard stale results (version check)
9. Catch thrown validators → fallback error
10. Apply final error list, notify listeners

### Full Laravel Validation Rules Reference

The following is the complete list of Laravel validation rules (see https://laravel.com/docs/13.x/validation#available-validation-rules). Rules marked ✅ are implemented as `OiAfValidators` above. Rules marked 🔮 are not in v1 but are noted for future consideration. Rules marked ❌ are server/database-specific and not applicable to client-side Flutter forms.

**Presence / Required:**
✅ `required` — Field must be present and non-empty
✅ `required_if` — Required if another field equals a value → `requiredIf()`
✅ `required_unless` — Required unless another field equals a value → `requiredUnless()`
✅ `required_with` — Required if any of other fields are present → `requiredWith()`
✅ `required_with_all` — Required if all other fields are present → `requiredWithAll()`
✅ `required_without` — Required if any of other fields are absent → `requiredWithout()`
✅ `required_without_all` — Required if all other fields are absent → `requiredWithoutAll()`
🔮 `required_if_accepted` — Required if another field is truthy
🔮 `required_if_declined` — Required if another field is falsy
🔮 `required_array_keys` — Array must contain specific keys
🔮 `filled` — If present, must not be empty
🔮 `present` — Must be present (can be empty)
🔮 `missing` / `missing_if` / `missing_unless` — Must NOT be present
🔮 `prohibited` / `prohibited_if` / `prohibited_unless` — Must be empty or missing
🔮 `nullable` — Allow null (handled by `required: false` in our system)

**Booleans:**
✅ `accepted` — Must be truthy → `requiredTrue()`
✅ `declined` — Must be falsy → `requiredFalse()`
🔮 `accepted_if` / `declined_if` — Conditional boolean checks
🔮 `boolean` — Must be castable to bool

**Strings:**
✅ `alpha` → `alpha()`
✅ `alpha_dash` → `alphaDash()`
✅ `alpha_num` → `alphaNumeric()`
✅ `ascii` → `ascii()`
✅ `email` → `email()`
✅ `ends_with` → `endsWith()`
✅ `starts_with` → `startsWith()`
✅ `doesnt_start_with` → `doesntStartWith()`
✅ `doesnt_end_with` → `doesntEndWith()`
✅ `hex_color` → `hexColor()`
✅ `in` → `isIn()`
✅ `not_in` → `notIn()`
✅ `ip` → `ipAddress()`
✅ `json` → `json()`
✅ `lowercase` → `lowercase()`
✅ `uppercase` → `uppercase()`
✅ `regex` → `regex()`
✅ `not_regex` → `notRegex()`
✅ `url` → `url()`
✅ `uuid` → `uuid()`
✅ `ulid` → `ulid()`
🔮 `active_url` — DNS check (requires async network, consider for server-side)
🔮 `current_password` — Auth check (server-side only)
🔮 `confirmed` — Convention-based matching (we use `equalsField` explicitly)
🔮 `mac_address` — MAC address format
🔮 `timezone` — Valid timezone string
🔮 `enum` — Must be valid Dart enum value
🔮 `string` — Must be string type (implicit in typed system)

**Numbers:**
✅ `min` → `min()`
✅ `max` → `max()`
✅ `between` → `range()`
✅ `gt:field` → `greaterThanField()`
✅ `lt:field` → `lessThanField()`
✅ `integer` → `integer()`
✅ `decimal` → `decimal()`
✅ `digits_between` → `digitsBetween()`
✅ `multiple_of` → `multipleOf()`
🔮 `numeric` — Must be numeric (implicit in typed system)
🔮 `digits` — Exact digit count
🔮 `gte` / `lte` — Greater/less than or equal to field
🔮 `min_digits` / `max_digits` — Min/max digit count
🔮 `size` — Exact numeric value

**Dates:**
✅ `after` → `dateAfter()`, `dateAfterField()`
✅ `after_or_equal` → `dateAfterOrEqual()`
✅ `before` → `dateBefore()`, `dateBeforeField()`
✅ `before_or_equal` → `dateBeforeOrEqual()`
✅ `date_equals` → `dateEquals()`
🔮 `date` — Is a valid date (implicit in typed DateTime fields)
🔮 `date_format` — Matches specific format (not applicable — we use DateTime objects)

**Comparison:**
✅ `same` → `equalsField()`
✅ `different` → `differentFromField()`
✅ `confirmed` → Use `equalsField()`

**Arrays / Collections:**
✅ `min` (array) → `minItems()`
✅ `max` (array) → `maxItems()`
✅ `size` (array) → `exactItems()`
✅ `contains` → `contains()`
✅ `doesnt_contain` → `doesntContain()`
✅ `distinct` → `distinct()`
🔮 `array` — Is an array (implicit in typed List fields)
🔮 `list` — Is a sequential array
🔮 `in_array` — Value exists in another field's array
🔮 `in_array_keys` — Array has specific keys

**Files:**
✅ `max` (files) → `maxFileSize()`
✅ `extensions` / `mimes` → `fileExtensions()`
🔮 `dimensions` — Image dimensions (width/height/ratio)
🔮 `image` — Must be an image file
🔮 `encoding` — File encoding check
🔮 `file` — Is an uploaded file
🔮 `mimetypes` — Exact MIME type check

**Utility:**
✅ `bail` → `bail()` — Stop on first failure for this field
❌ `exists` — Database existence check (server-side only)
❌ `unique` — Database uniqueness check (server-side, use async custom validator)
🔮 `exclude` / `exclude_if` / `exclude_unless` — Handled by `save: false` + `visibleWhen`
🔮 `sometimes` — Validate only when present (handled by `required: false`)
🔮 `any_of` — Match any of several rule sets

---

## 10. Derived Fields & Dependency Graph

A field is derived if `definition.derive != null`.

**Rules:**
- `dependsOn` must not be empty when `derive` is set (assert at registration)
- Derived fields are evaluated in topological order (depth-first on dependency graph)
- Cycles are detected at registration time and assert
- Derivation runs after all base field controllers are initialized

**Override modes:**
- `alwaysDerived` — always recomputes, user edits are overwritten
- `stopAfterUserEdit` — stops auto-deriving once user manually edits (default)
- `allowManualOverride` — user can override, but controller tracks override state

Derived value application uses `setValue(value, fromUser: false)`.

---

## 11. Conditional Visibility & Enabled State

### Automatic Dependency Tracking

Uses `OiAfTrackingReader` (Section 4). No manual dependency lists.

**Internal: `OiAfConditionTracker<TField>`**

```dart
class OiAfConditionTracker<TField extends Enum> {
  /// Cached: which fields does each conditional field's callback read?
  final Map<TField, Set<TField>> _visibleDeps = {};
  final Map<TField, Set<TField>> _enabledDeps = {};

  /// Reverse map: when field X changes, which conditional fields need re-eval?
  Set<TField> fieldsToReevaluateOnChange(TField changedField) { ... }

  /// Evaluate all conditions, populate caches, return fields whose state changed.
  Set<TField> evaluateAll(OiAfReader<TField> reader, Map<TField, OiAfFieldDefinition> defs) { ... }

  /// Re-evaluate only conditions affected by changedField.
  Set<TField> evaluateAffected(TField changedField, OiAfReader<TField> reader, ...) { ... }
}
```

### Visibility Change Effects

When visible → hidden:
- `isVisible = false`
- If `clearValueWhenHidden` → clear value
- If `excludeWhenHidden` → clear errors, skip validation
- If currently focused → unfocus
- Remove from focus graph

When hidden → visible:
- `isVisible = true`
- Previous value preserved (unless cleared)
- Re-enters focus graph when widget mounts
- Does NOT immediately show errors unless validation mode triggers it

### Enabled Change Effects

When enabled → disabled:
- `isEnabled = false`
- Widget renders disabled
- If `skipValidationWhenDisabled` → errors cleared, validation skipped

---

## 12. Submit Pipeline

Exact sequence:

1. **Concurrent guard** — If `_activeSubmitFuture != null`, return it. No duplicate requests.
2. **Clear stale errors** — Clear previous global submit errors. Optionally clear backend field errors.
3. **Mark lifecycle** — `_hasSubmitted = true`, increment `_submitCount`, set `_lastSubmitAt`.
4. **Flush async validations** — Await any in-flight field validation.
5. **Validate all active fields** — Run field validation with trigger `submit` on all visible+enabled fields.
6. **Run form-level validators.**
7. **If invalid** → focus first invalid field (if configured), return `OiAfSubmitInvalid`.
8. **Build TData** — Call `buildData()`. If it throws → catch, return `OiAfSubmitFailure`.
9. **Set `_isSubmitting = true`**, notify listeners.
10. **Call submit callback** — `onSubmit(data, controller)`.
11. **On success** → return `OiAfSubmitSuccess(data)`.
12. **On exception** → run error mapper if provided, map to field/global errors, return `OiAfSubmitFailure`.
13. **Finally** — `_isSubmitting = false`, clear `_activeSubmitFuture`, notify.

### Backend Error Mapping

```dart
typedef OiAfSubmitErrorMapper<TField extends Enum, TData> =
    OiAfMappedSubmitError<TField> Function(
      OiAfSubmitErrorContext<TField, TData> ctx,
    );

final class OiAfMappedSubmitError<TField extends Enum> {
  final Map<TField, List<String>> fieldErrors;
  final List<String> globalErrors;
  const OiAfMappedSubmitError({this.fieldErrors = const {}, this.globalErrors = const []});
}

final class OiAfSubmitErrorContext<TField extends Enum, TData> {
  final Object error;
  final StackTrace stackTrace;
  final TData data;
  final OiAfController<TField, TData> controller;
  const OiAfSubmitErrorContext({ ... });
}
```

---

## 13. Focus, Tab, Enter & Keyboard UX

### Focus Graph

The controller maintains an internal `OiAfFocusGraph<TField>`:

- Each `OiAf*` field widget registers its `FocusNode` on mount with the field controller.
- The graph is ordered by **mount order** (default).
- Active traversal candidates: mounted + visible + enabled + `canRequestFocus`.

### Rules

| Interaction | Behavior |
|---|---|
| Tab | Next visible enabled field |
| Shift+Tab | Previous visible enabled field |
| Enter (single-line text) | Next field, or submit if last |
| Enter (multiline text) | Normal newline |
| Space (checkbox/switch) | Toggle |
| Enter (last submittable field) | Submit (if `submitOnEnterFromLastField` enabled) |
| Failed submit | Focus first invalid visible field |
| Summary item tap | Focus target field |

### TextInputAction Derivation

If not explicitly set on the widget:
- Multiline → no forced action
- Single-line, not last → `TextInputAction.next`
- Single-line, last → `TextInputAction.done`

### onBlurThenChange Tracking

Each field controller tracks `_hasValidatedAfterBlur`. Before first blur, no inline validation on change. After first blur, subsequent changes trigger validation.

---

## 14. Error Presentation

### Three Error Layers

1. **Inline field errors** — `fieldController.primaryError` → passed to underlying input's `error` prop.
2. **Global validation summary** — `OiAfErrorSummary` collects all active errors.
3. **Global submit errors** — Server/network failures shown in summary.

### Field Error Summary Items

```dart
final class OiAfErrorSummaryItem<TField extends Enum> {
  final TField? field;
  final String? fieldLabel;  // from widget's registered displayLabel
  final String message;
  final bool isGlobal;
  const OiAfErrorSummaryItem({ ... });
}
```

The controller exposes: `List<OiAfErrorSummaryItem<TField>> buildErrorSummaryItems({ ... })`.

### Error Clearing Policies

| Event | Field Validation Errors | Backend Field Errors | Global Submit Errors |
|---|---|---|---|
| User edits field | Clear (if `clearErrorsOnChange`) | Clear for that field | Optionally clear (config) |
| Reset | Clear all | Clear all | Clear all |
| New submit starts | Replaced by new validation | Clear all | Clear all |
| Rebase | Clear all | Clear all | Clear all |

---

## 15. Initialization, Reset, Patch & Restore

### Initial Value Resolution Order

Per field: controller-provided initial data → definition `initialValue` → type-default → null.

### Reset

`reset()` restores each field to its **resolved initial runtime value**, clears dirty/touched/errors/backend errors/global errors/manual override flags, invalidates in-flight async validations, recomputes derived fields.

### Patch

`patch(values)` updates current values only. Marks dirty. Triggers dependencies. Clears backend errors for affected fields.

### Rebase

`rebase(values)` updates BOTH current AND initial values. Result: `isDirty = false`. Clears all errors. Used for: async entity load, switching records.

### Restore

`restore(values, mode: patchCurrent)` — patches current, preserves original baseline.
`restore(values, mode: rebaseInitial)` — updates both current and initial (draft becomes new baseline).

---

## 16. Persistence & Draft System

### Driver

```dart
abstract class OiAfPersistenceDriver {
  Future<Map<String, dynamic>?> loadDraft({required String formId, String? key});
  Future<void> saveDraft({required String formId, String? key, required Map<String, dynamic> json});
  Future<void> deleteDraft({required String formId, String? key});
}
```

Mirrors `OiSettingsDriver` philosophy. Opt-in. Configured on the controller.

### JSON Export

`json()` on the controller serializes all `save: true` exportable fields. Hidden+excluded fields are omitted. This is the only place `Map<String, dynamic>` appears in the public API.

---

## 17. OiAfForm Widget

```dart
class OiAfForm<TField extends Enum, TData> extends StatefulWidget {
  final OiAfController<TField, TData> controller;
  final Widget child;

  final Future<void> Function(TData data, OiAfController<TField, TData> controller)? onSubmit;
  final void Function(OiAfSubmitResult<TData> result, OiAfController<TField, TData> controller)? onSubmitResult;
  final OiAfSubmitErrorMapper<TField, TData>? errorMapper;

  final OiAfValidateMode validateMode;
  final bool autofocusFirstField;
  final bool submitOnEnterFromLastField;
  final bool focusFirstInvalidFieldOnSubmitFailure;
  final bool clearGlobalErrorsOnFieldChange;
  final bool enabled;

  const OiAfForm({
    super.key,
    required this.controller,
    required this.child,
    this.onSubmit,
    this.onSubmitResult,
    this.errorMapper,
    this.validateMode = OiAfValidateMode.onBlurThenChange,
    this.autofocusFirstField = false,
    this.submitOnEnterFromLastField = true,
    this.focusFirstInvalidFieldOnSubmitFailure = true,
    this.clearGlobalErrorsOnFieldChange = true,
    this.enabled = true,
  });
}
```

**On mount:** Attach controller, apply config, run initial evaluations. Post-frame: autofocus if configured.

**On dispose:** Detach controller. Do NOT dispose controller (externally owned).

**Build tree:** `OiAfScope<TField, TData>(controller: ..., child: child)`

---

## 18. OiAf* Field Widgets — Full Catalog

Every widget follows the same contract:

1. `required TField field` — enum key, the only binding identity
2. Mirrors ALL visual props of the underlying obers_ui widget
3. Reads state from controller via context
4. Injects: `error`, `enabled`, `focusNode`, `value`, `onChanged` from field controller
5. Hides when `fieldController.isVisible == false` (returns `SizedBox.shrink()`)
6. Reports focus/blur/touch to field controller
7. Reports submit/enter to form controller
8. Optional `onChanged`, `onBlur`, `onFocus`, `onSubmitted` callbacks (secondary to controller)

### Complete Widget List

| Widget | Wraps | Value Type | Field Type |
|---|---|---|---|
| `OiAfTextInput<TField>` | `OiTextInput` | `String` | `text` |
| `OiAfNumberInput<TField>` | `OiNumberInput` | `num` | `number` |
| `OiAfCheckbox<TField>` | `OiCheckbox` | `bool?` | `checkbox` |
| `OiAfSwitch<TField>` | `OiSwitch` | `bool` | `switcher` |
| `OiAfRadio<TField, TValue>` | `OiRadio<TValue>` | `TValue` | `radio` |
| `OiAfSelect<TField, TValue>` | `OiSelect<TValue>` | `TValue` | `select` / `multiSelect` |
| `OiAfComboBox<TField, TValue>` | `OiComboBox<TValue>` | `TValue` / `List<TValue>` | `comboBox` |
| `OiAfDateInput<TField>` | `OiDateInput` | `DateTime` | `date` |
| `OiAfTimeInput<TField>` | `OiTimeInput` | `OiTimeOfDay` | `time` |
| `OiAfDateTimeInput<TField>` | `OiDateTimeInput` | `DateTime` | `dateTime` |
| `OiAfDatePickerField<TField>` | `OiDatePickerField` | `DateTime` | `datePicker` |
| `OiAfDateRangePickerField<TField>` | `OiDateRangePickerField` | `(DateTime, DateTime)` | `dateRangePicker` |
| `OiAfTimePickerField<TField>` | `OiTimePickerField` | `OiTimeOfDay` | `timePicker` |
| `OiAfTagInput<TField>` | `OiTagInput` | `List<String>` | `tags` |
| `OiAfSlider<TField>` | `OiSlider` | `double` / `(double, double)` | `slider` |
| `OiAfColorInput<TField>` | `OiColorInput` | `Color` | `color` |
| `OiAfFileInput<TField>` | `OiFileInput` | `List<OiAfFileValue>` | `file` |
| `OiAfArrayInput<TField, TItem>` | `OiArrayInput` | `List<TItem>` | `array` |
| `OiAfSegmentedControl<TField, TValue>` | `OiSegmentedControl<TValue>` | `TValue` | `segmentedControl` |
| `OiAfRichEditor<TField>` | `OiRichEditor` | `String` | `richText` |

### Example Widget Signature — OiAfTextInput

```dart
class OiAfTextInput<TField extends Enum> extends StatefulWidget {
  final TField field;

  // --- ALL OiTextInput visual props mirrored ---
  final String? label;
  final String? hint;
  final String? placeholder;
  final Widget? leading;
  final Widget? trailing;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final bool obscureText;
  final bool autofocus;
  final bool readOnly;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final bool showCounter;
  final Widget Function(int current, int? max)? counterBuilder;
  final String? semanticLabel;

  // --- Secondary callbacks ---
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final VoidCallback? onTapOutside;
  final VoidCallback? onBlur;
  final VoidCallback? onFocus;

  const OiAfTextInput({
    super.key,
    required this.field,
    this.label,
    this.hint,
    this.placeholder,
    this.leading,
    this.trailing,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.obscureText = false,
    this.autofocus = false,
    this.readOnly = false,
    this.enabled = true,
    this.inputFormatters,
    this.showCounter = false,
    this.counterBuilder,
    this.semanticLabel,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onTapOutside,
    this.onBlur,
    this.onFocus,
  });
}
```

**RULE:** Every OiAf* widget MUST mirror ALL public parameters of its underlying obers_ui widget (except `controller`, `focusNode`, `error`, `value`, `onChanged`, `validator`, `onSaved`, `autovalidateMode` which are managed by the binding). When the underlying widget adds new params, the wrapper MUST be updated to match. This is a maintenance invariant.

### Named Constructors

Where the underlying widget has named constructors, the wrapper should mirror them:

- `OiAfTextInput.search(field: ...)` wraps `OiTextInput.search()`
- `OiAfTextInput.password(field: ...)` wraps `OiTextInput.password()`
- `OiAfTextInput.multiline(field: ..., minLines: ...)` wraps `OiTextInput.multiline()`

---

## 19. OiAfErrorSummary Widget

```dart
class OiAfErrorSummary<TField extends Enum> extends StatelessWidget {
  final String? title;
  final bool showFieldErrors;
  final bool showGlobalErrors;
  final bool showOnlyAfterSubmit;
  final bool hideWhenEmpty;
  final bool focusFieldOnTap;
  final int? maxItems;

  const OiAfErrorSummary({
    super.key,
    this.title,
    this.showFieldErrors = true,
    this.showGlobalErrors = true,
    this.showOnlyAfterSubmit = false,
    this.hideWhenEmpty = true,
    this.focusFieldOnTap = true,
    this.maxItems,
  });
}
```

**Data source:** Listens to form controller aggregate state. Collects: global validation errors, global submit errors, field primary errors (visible+enabled fields only). Deduplicates by field+message. Orders: globals first, then fields in focus-graph order.

**Field labels:** Uses `fieldController.displayLabel` (registered by widget), falls back to `field.name` formatted.

---

## 20. OiAfSubmitButton Widget

```dart
class OiAfSubmitButton<TField extends Enum, TData> extends StatelessWidget {
  final String label;
  final String? loadingLabel;
  final IconData? icon;
  final OiButtonVariant variant;
  final bool disableWhenInvalid;
  final bool disableWhenClean;
  final VoidCallback? onTap; // additional callback after submit

  const OiAfSubmitButton({
    super.key,
    required this.label,
    this.loadingLabel,
    this.icon,
    this.variant = OiButtonVariant.primary,
    this.disableWhenInvalid = false,
    this.disableWhenClean = false,
    this.onTap,
  });
}
```

Listens to controller aggregate state. Shows loading when `isSubmitting`. Calls `controller.submit()`.

---

## 21. OiAfResetButton Widget

```dart
class OiAfResetButton<TField extends Enum> extends StatelessWidget {
  final String label;
  final OiButtonVariant variant;
  final bool hideWhenClean;
  final OiAfResetMode resetMode;

  const OiAfResetButton({
    super.key,
    required this.label,
    this.variant = OiButtonVariant.secondary,
    this.hideWhenClean = false,
    this.resetMode = OiAfResetMode.toInitial,
  });
}
```

---

## 22. Internal Widget Binding Layer

All OiAf* field widgets share a private base `_OiAfFieldBinderState`:

```dart
abstract class _OiAfFieldBinderState<
    TWidget extends StatefulWidget,
    TField extends Enum,
    TValue> extends State<TWidget> {

  late OiAfController<TField, Object?> form;
  late OiAfFieldController<TField, TValue> fieldCtrl;
  bool _bound = false;

  TField get fieldEnum;           // abstract — widget.field
  OiAfFieldType get expectedType; // abstract — e.g., OiAfFieldType.text

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bindField();
  }

  void _bindField() {
    form = OiAfScope.of<TField, Object?>(context);
    final next = form.fieldController<TValue>(fieldEnum);

    assert(next.type == expectedType || _isCompatibleType(next.type, expectedType),
      'OiAf widget bound to wrong field type: ${next.type} != $expectedType');

    if (_bound && fieldCtrl == next) return;

    if (_bound) {
      fieldCtrl.removeListener(_onFieldChanged);
      fieldCtrl.detachWidget();
      _onDetach();
    }

    fieldCtrl = next;
    fieldCtrl.attachWidget();
    fieldCtrl.addListener(_onFieldChanged);
    fieldCtrl.registerPresentationMetadata(label: widgetLabel);
    _onAttach();
    _bound = true;
  }

  String? get widgetLabel;  // abstract — widget.label
  void _onAttach();         // abstract — create FocusNode, sync initial value
  void _onDetach();         // abstract — unregister focus, dispose internals

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  bool get effectiveEnabled =>
      widget.enabled && form.isEnabled && fieldCtrl.isEnabled;

  @override
  void dispose() {
    if (_bound) {
      fieldCtrl.removeListener(_onFieldChanged);
      fieldCtrl.detachWidget();
      _onDetach();
    }
    super.dispose();
  }
}
```

This eliminates duplicate binding logic across 20+ widget wrappers.

---

## 23. Accessibility

- Every OiAf* widget requires `label` or `semanticLabel` (enforced by lint or assert).
- `required` state exposed semantically on the field widget.
- Invalid state announced when errors appear.
- `OiAfErrorSummary` renders as a semantic alert/status region.
- Failed submit announces error count.
- Focus moves predictably via focus graph.
- Touch targets inherit obers_ui's 48dp minimum guarantee.
- Error text connected semantically to its field via the underlying widget's accessibility support.
- Do not rely on color alone for errors — include icon or text prefix.

---

## 24. Internationalization

### Message Resolver

```dart
abstract class OiAfMessageResolver {
  String requiredText(BuildContext context);
  String invalidEmail(BuildContext context);
  String tooShort(BuildContext context, int min);
  String tooLong(BuildContext context, int max);
  String valuesDoNotMatch(BuildContext context);
  String validationFailed(BuildContext context);
  String submitFailed(BuildContext context);
  String errorSummaryTitle(BuildContext context, int count);
}
```

Built-in validators accept optional `message` overrides. When no message is provided, the resolver is used. Default: English. App can provide custom resolver through `OiAfForm` or controller config.

---

## 25. Performance

- One `ChangeNotifier` per field controller — field-level granularity.
- One aggregate `ChangeNotifier` on form controller — for summary/button.
- `OiAfScope` (InheritedWidget) only exposes controller reference, NOT rebuild trigger.
- Field widgets subscribe only to their own field controller.
- Aggregate widgets (summary, submit button) subscribe to form controller.
- Condition re-evaluation: only affected conditions per change (proxy-tracked deps).
- Derived field recomputation: only when dependencies change.
- Async validators: cancelable via version check, no wasteful redundant calls.
- No full-form rebuilds on single field change.
- FocusNode and TextEditingController are created once, not on every build.

---

## 26. Diagnostics & Debug

### Observer

```dart
abstract class OiAfObserver {
  void onFieldValueChanged(Enum field, Object? oldValue, Object? newValue);
  void onFieldValidated(Enum field, List<String> errors);
  void onValidationCrash(Enum field, Object error, StackTrace stackTrace);
  void onSubmitStarted();
  void onSubmitCompleted(OiAfSubmitResult result);
  void onFormReset();
}
```

Configurable on the controller. Optional. For logging, analytics, debugging.

### Debug Assertions

| Condition | Action |
|---|---|
| Duplicate field registration | Assert |
| Derive without dependsOn | Assert |
| Dependency on unknown field | Assert |
| Cycle in dependency graph | Assert |
| Controller attached to two forms | Assert |
| Field widget outside OiAfScope | Assert with clear message |
| Wrong widget type for field type | Assert |
| Duplicate widget mount for same field | Assert |

### debugSnapshot()

Returns a `Map<String, dynamic>` with all field states, errors, dirty/touched status, aggregate state. Useful for devtools and test diagnostics.

---

## 27. Testing Strategy

### Unit Tests

| Area | Key Tests |
|---|---|
| Controller lifecycle | Init, attach, detach, double-attach assert |
| Field registration | All types, duplicate assert, dependency assert |
| Value access | `get<T>()`, `getOr<T>()`, type safety |
| `set()` / `patch()` | Dirty, touched, dependency triggers |
| `reset()` | Restores initial, clears all state |
| `rebase()` | Updates baseline, clears dirty |
| `restore()` | Both modes correct |
| Validators (all built-ins) | Valid/invalid for each, edge cases |
| Async validation | Race safety, stale discard |
| Cross-field validation | Dependency revalidation |
| Form-level validators | Global error placement |
| Derived fields | All modes, override policies, cycles |
| Conditional state | Visibility/enabled tracking, auto-deps |
| Submit pipeline | Valid/invalid/failure, double-submit, error mapping |
| Hidden field behavior | Excluded from validation/export, value clear |
| Persistence | Save/load/delete draft roundtrip |
| JSON export | Correct fields, hidden excluded |

### Widget Tests

| Area | Key Tests |
|---|---|
| Each OiAf* wrapper | Binds, syncs, errors display, enabled/disabled |
| Text sync | No infinite loop, external set updates widget |
| Focus | Registration, traversal, enter-next, enter-submit |
| Visibility | Hidden renders nothing, re-show works |
| ErrorSummary | Correct items, tapping focuses field |
| SubmitButton | Loading state, disabled when invalid |
| Form scope | Provides controller, assert outside scope |

### Golden Tests

Default form, error states, disabled states, dense vs comfortable density.

### Accessibility Tests

Semantic labels, required announced, keyboard-only completion, screen-reader grouping.

---

## 28. Implementation Order

**Phase 1: Foundation** (no widgets, no flutter dependency)
1. All enums
2. All typedefs
3. `OiAfReader`, `OiAfTrackingReader`
4. Submit result classes
5. `OiAfOption`, `OiAfMessageResolver`

**Phase 2: Field Definitions**
6. Base `OiAfFieldDefinition`
7. All typed subclasses

**Phase 3: Validators**
8. Validation contexts
9. All built-in validators
10. Unit tests for all validators

**Phase 4: Field Controllers**
11. Base `OiAfFieldController`
12. All typed subclasses
13. Value pipeline, error buckets, async validation
14. Unit tests

**Phase 5: Form Controller**
15. `OiAfController` base
16. Registration helpers
17. Dependency graph, condition tracker
18. Submit pipeline
19. Focus graph
20. Patch/reset/rebase/restore
21. Unit tests

**Phase 6: Persistence**
22. Driver, draft payload, JSON exporter
23. Unit tests

**Phase 7: Widgets**
24. `OiAfScope`
25. `OiAfForm`
26. `_OiAfFieldBinder` base
27. `OiAfTextInput` (first, validates binding architecture)
28. All other field wrappers
29. `OiAfErrorSummary`
30. `OiAfSubmitButton`, `OiAfResetButton`
31. Widget tests

**Phase 8: Polish**
32. Diagnostics observer
33. Debug overlay
34. Golden tests
35. Accessibility tests
36. Documentation

**Phase 9: obers_ui Core**
37. Create `OiTimeOfDay` in obers_ui foundation if it doesn't exist
38. Deprecate old `OiForm`, `OiFormField`, `OiFormSection`, `OiFormController` — add `@Deprecated('Use OiAfForm from obers_ui_autoforms')` annotations

---

## 29. Migration from Legacy OiForm

The existing `OiForm`, `OiFormField`, `OiFormSection`, and `OiFormController` in obers_ui core should be deprecated:

```dart
@Deprecated('Use OiAfForm from package:obers_ui_autoforms. See migration guide.')
class OiForm extends StatefulWidget { ... }
```

The existing `OiFormSelect` stays as-is (it's a standalone form-aware select, not part of the auto-form system).

### Migration path

| Old | New |
|---|---|
| `OiForm` | `OiAfForm` |
| `OiFormController` | `OiAfController` (subclass) |
| `OiFormField` | `OiAfTextInput` / `OiAfSelect` / etc. (specific widgets) |
| `OiFormSection` | Any layout widget (`OiSection`, `OiColumn`, `OiCard`) |
| `OiFormDialog` | Use `OiAfForm` inside `OiDialog` |
| `OiWizard` | Use `OiAfForm` per step, or one `OiAfForm` with conditional fields |

---

## 30. Claude Code Rules

These rules MUST be followed when implementing this package:

1. **Every OiAf* field widget MUST mirror ALL public parameters of its underlying obers_ui input widget** (except binding-managed ones: `controller`, `focusNode`, `error`, `value`/`onChanged` that are injected by the binder). When the underlying widget changes, the wrapper MUST be updated.

2. **Never use `Map<String, dynamic>` in public API** except `json()` and persistence methods.

3. **Never use exceptions for validation flow.** Validators return `String?`. Catch unexpected throws.

4. **Never use Material/Cupertino widgets.** Use obers_ui equivalents only.

5. **All colors from theme.** Never hardcode colors.

6. **All text via OiLabel.** Never use raw `Text()`.

7. **Every interactive element needs `semanticLabel` or `label`.**

8. **Field definitions are immutable after registration.** Runtime changes go through field controllers.

9. **The `OiAf` prefix is used for ALL public types** in this package. No exceptions.

10. **Controller owns data behavior, widget owns visual behavior.** Labels, hints, icons, layout = widget. Validation, required, visibility rules, derived, save = controller.

11. **One field controller per enum key.** Duplicate mount of same field asserts in debug.

12. **Barrel export everything** through `obers_ui_autoforms.dart`. Single import.

13. **Follow obers_ui naming conventions** for all new types.

14. **Test every validator, every field type, every lifecycle transition.** Minimum coverage targets: unit 95%, widget 85%.

---

## 31. Complete Usage Example

```dart
// ─── 1. Define field enum ───
enum SignupField {
  name,
  username,
  email,
  password,
  passwordRepeat,
  newsletterSignup,
  gender,
  birthDate,
  volume,
}

// ─── 2. Define typed output ───
final class SignupFormData {
  final String name;
  final String username;
  final String email;
  final String password;
  final bool newsletterSignup;
  final String gender;
  final DateTime? birthDate;
  final double volume;

  const SignupFormData({
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.newsletterSignup,
    required this.gender,
    required this.birthDate,
    required this.volume,
  });
}

// ─── 3. Define controller ───
final class SignupFormController
    extends OiAfController<SignupField, SignupFormData> {
  SignupFormController({bool? newsletterSignup});

  @override
  void defineFields() {
    addTextField(
      SignupField.name,
      required: true,
      validators: [
        OiAfValidators.minLength(2),
        OiAfValidators.maxLength(60),
      ],
    );

    addTextField(
      SignupField.username,
      required: true,
      dependsOn: const [SignupField.name],
      deriveMode: OiAfDeriveMode.onChange,
      derive: (form) {
        final name = form.get<String>(SignupField.name) ?? '';
        return name.trim().toLowerCase().replaceAll(' ', '_');
      },
    );

    addTextField(
      SignupField.email,
      required: true,
      validators: [OiAfValidators.email()],
    );

    addTextField(
      SignupField.password,
      required: true,
      validators: [
        OiAfValidators.securePassword(
          minLength: 8,
          requiresUppercase: true,
          requiresSpecialChar: true,
        ),
      ],
    );

    addTextField(
      SignupField.passwordRepeat,
      required: true,
      save: false,
      validators: [OiAfValidators.equalsField(SignupField.password)],
      revalidateWhen: const [SignupField.password],
    );

    addBoolField(
      SignupField.newsletterSignup,
      initialValue: true,
    );

    addRadioField<String>(
      SignupField.gender,
      required: true,
      visibleWhen: (form) =>
          form.get<bool?>(SignupField.newsletterSignup) == true,
    );

    addDatePickerField(
      SignupField.birthDate,
    );

    addSliderField(
      SignupField.volume,
      initialValue: 50.0,
      min: 0.0,
      max: 100.0,
    );
  }

  @override
  SignupFormData buildData() {
    return SignupFormData(
      name: getOr<String>(SignupField.name, ''),
      username: getOr<String>(SignupField.username, ''),
      email: getOr<String>(SignupField.email, ''),
      password: getOr<String>(SignupField.password, ''),
      newsletterSignup: getOr<bool?>(SignupField.newsletterSignup, false) ?? false,
      gender: getOr<String>(SignupField.gender, ''),
      birthDate: get<DateTime>(SignupField.birthDate),
      volume: getOr<double>(SignupField.volume, 50.0),
    );
  }
}

// ─── 4. Build UI — freely laid out ───
class SignupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = SignupFormController();

    return OiAfForm<SignupField, SignupFormData>(
      controller: controller,
      onSubmit: (data, ctrl) async {
        await authRepository.signup(data);
      },
      child: OiPage(
        breakpoint: OiBreakpoint.compact,
        children: [
          OiLabel.h1('Create Account'),

          OiAfErrorSummary<SignupField>(),

          OiRow(children: [
            Expanded(child: OiAfTextInput<SignupField>(
              field: SignupField.name,
              label: 'Full Name',
            )),
            Expanded(child: OiAfTextInput<SignupField>(
              field: SignupField.username,
              label: 'Username',
              readOnly: true,
            )),
          ]),

          OiAfTextInput<SignupField>(
            field: SignupField.email,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),

          OiAfTextInput.password<SignupField>(
            field: SignupField.password,
            label: 'Password',
          ),

          OiAfTextInput.password<SignupField>(
            field: SignupField.passwordRepeat,
            label: 'Repeat Password',
          ),

          OiAfCheckbox<SignupField>(
            field: SignupField.newsletterSignup,
            label: 'Sign up for newsletter',
          ),

          OiAfRadio<SignupField, String>(
            field: SignupField.gender,
            label: 'Gender',
            options: [
              OiAfOption(value: 'male', label: 'Male'),
              OiAfOption(value: 'female', label: 'Female'),
              OiAfOption(value: 'other', label: 'Other'),
            ],
          ),

          OiAfDatePickerField<SignupField>(
            field: SignupField.birthDate,
            label: 'Birth Date',
            placeholder: 'Select your birth date',
          ),

          OiAfSlider<SignupField>(
            field: SignupField.volume,
            label: 'Volume',
            min: 0,
            max: 100,
          ),

          OiRow(children: [
            OiAfResetButton<SignupField>(label: 'Reset'),
            OiAfSubmitButton<SignupField, SignupFormData>(
              label: 'Create Account',
            ),
          ]),
        ],
      ),
    );
  }
}
```

---

## Appendix A: Edge Cases That MUST Be Handled

| Edge Case | Expected Behavior |
|---|---|
| Hidden field with existing error | Errors cleared when `excludeWhenHidden` |
| Hidden field with dirty value | Value preserved unless `clearValueWhenHidden` |
| Field disabled while focused | Unfocus, update enabled state |
| Async validator returns after value changed | Stale result discarded via version check |
| Schema changes after persisted draft exists | Restore only matching fields, ignore unknown |
| Derived field depends on hidden field | Use current value (even if hidden) for derivation |
| Submit pressed twice | Return same pending future, no duplicate requests |
| External controller override for one field | Supported via `overrideFieldController()` |
| Server-side error maps to one field | `setBackendError(field, message)` |
| Server-side error with no field target | Goes to `globalErrors` |
| Select options load after draft restore | Selected value preserved regardless of options |
| Reset should restore initial values, not draft | Default mode: `toInitial` |
| Field mounted twice for same enum | Assert in debug mode |
| Field widget built outside form scope | Assert with clear error message |
| `buildData()` throws | Caught in submit pipeline, becomes `OiAfSubmitFailure` |
| Error mapper itself throws | Caught, falls back to generic global error |
| Circular derived dependencies | Detected at registration, asserts |
| Revalidation loop from mutual revalidateWhen | Max 3 re-evaluation passes, then stop with warning |

---

*End of specification.*
