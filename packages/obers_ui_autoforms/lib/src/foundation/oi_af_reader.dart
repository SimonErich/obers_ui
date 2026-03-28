/// Read-only interface for accessing form field state.
///
/// Used by validators, derived field callbacks, and condition callbacks
/// to read field values without mutating state.
abstract class OiAfReader<TField extends Enum> {
  /// Returns the current value of [field], cast to [TValue].
  ///
  /// Returns `null` if the field has no value or the type doesn't match.
  TValue? get<TValue>(TField field);

  /// Returns the current value of [field] or [fallback] if null.
  TValue getOr<TValue>(TField field, TValue fallback);

  /// Whether [field] is currently visible.
  bool isFieldVisible(TField field);

  /// Whether [field] is currently enabled.
  bool isFieldEnabled(TField field);

  /// Whether [field]'s current value differs from its initial value.
  bool isFieldDirty(TField field);
}
