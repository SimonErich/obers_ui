/// Defines when a computed/virtual field should re-evaluate its value.
enum OiFormWatchMode {
  /// Re-evaluate when any watched field changes value.
  onChange,

  /// Evaluate once at registration time.
  onInit,

  /// Evaluate when the form is submitted.
  onSubmit,

  /// Evaluate when the form becomes dirty.
  onDirty,

  /// Evaluate when the form becomes valid.
  onValid,

  /// Evaluate when the form becomes invalid.
  onInvalid,
}
