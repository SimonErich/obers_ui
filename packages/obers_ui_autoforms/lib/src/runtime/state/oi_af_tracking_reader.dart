import 'package:obers_ui_autoforms/src/foundation/oi_af_reader.dart';

/// A reader proxy that tracks which fields are accessed.
///
/// Used internally for automatic dependency discovery in `visibleWhen`
/// and `enabledWhen` callbacks.
class OiAfTrackingReader<TField extends Enum> implements OiAfReader<TField> {
  OiAfTrackingReader(this._delegate);

  final OiAfReader<TField> _delegate;
  final Set<TField> _readFields = {};

  /// The set of fields that were accessed during evaluation.
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

  /// Clear tracked fields for reuse.
  void reset() => _readFields.clear();
}
