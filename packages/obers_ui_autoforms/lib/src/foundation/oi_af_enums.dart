/// All enums used in the obers_ui_autoforms package.
library;

/// The type of a field definition.
enum OiAfFieldType {
  /// Single-line or multi-line text.
  text,

  /// Numeric input with stepper buttons.
  number,

  /// Boolean checkbox (supports tristate).
  checkbox,

  /// Boolean toggle switch.
  switcher,

  /// Radio button group.
  radio,

  /// Single-select dropdown.
  select,

  /// Multi-select dropdown.
  multiSelect,

  /// Searchable combo box.
  comboBox,

  /// Date wheel picker.
  date,

  /// Time wheel picker.
  time,

  /// Combined date + time.
  dateTime,

  /// Calendar date picker.
  datePicker,

  /// Calendar date range picker.
  dateRangePicker,

  /// Dialog time picker.
  timePicker,

  /// String tag chips.
  tags,

  /// Draggable slider.
  slider,

  /// Color picker.
  color,

  /// File browser.
  file,

  /// Repeatable item array.
  array,

  /// Segmented toggle control.
  segmentedControl,

  /// Rich text editor.
  richText,
}

/// Controls when validation runs for a field.
enum OiAfValidateMode {
  /// Never auto-validate. Manual only.
  disabled,

  /// Validate only on form submit.
  onSubmit,

  /// Validate when the field loses focus.
  onBlur,

  /// Validate on every value change.
  onChange,

  /// Validate on blur first, then on every change. Recommended default.
  onBlurThenChange,

  /// Validate immediately when the field initializes.
  onInit,
}

/// What triggered a validation run.
enum OiAfValidationTrigger {
  /// Validation on field initialization.
  init,

  /// Validation triggered by a value change.
  change,

  /// Validation triggered by losing focus.
  blur,

  /// Validation triggered by form submit.
  submit,

  /// Validation triggered manually via `validate()`.
  manual,

  /// Validation triggered because a dependency changed.
  dependencyChange,

  /// Validation triggered by restoring saved state.
  restore,
}

/// When derived fields recompute.
enum OiAfDeriveMode {
  /// Recompute whenever a dependency changes.
  onChange,

  /// Compute once on initialization.
  onInit,

  /// Compute just before submit.
  onSubmit,
}

/// How derived fields handle user edits.
enum OiAfDerivedOverrideMode {
  /// Always recompute; user edits are overwritten.
  alwaysDerived,

  /// Stop deriving once the user manually edits. Recommended default.
  stopAfterUserEdit,

  /// User can override, but controller tracks the override state.
  allowManualOverride,
}

/// The mode for resetting a form.
enum OiAfResetMode {
  /// Reset to initial values resolved at construction.
  toInitial,

  /// Reset to current patched values (keep current as new baseline).
  toCurrentPatchedValues,

  /// Clear all values to null/default.
  clear,
}

/// The mode for restoring persisted state.
enum OiAfRestoreMode {
  /// Update current values only; original baseline is preserved.
  patchCurrent,

  /// Update both current and initial (draft becomes new baseline).
  rebaseInitial,
}

/// Where a field's current value originated.
enum OiAfValueSource {
  /// From the field definition's `initialValue`.
  definitionInitial,

  /// From the controller's initial data.
  controllerInitialData,

  /// From a persisted draft restore.
  restore,

  /// From a `patch()` call.
  patch,

  /// From a user interaction.
  user,

  /// From a derived field computation.
  derived,

  /// From a `reset()` call.
  reset,
}
