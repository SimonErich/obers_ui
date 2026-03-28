import 'dart:async';

import 'package:obers_ui_autoforms/src/foundation/oi_af_reader.dart';
import 'package:obers_ui_autoforms/src/validation/oi_af_form_validation_context.dart';
import 'package:obers_ui_autoforms/src/validation/oi_af_validation_context.dart';

/// Field-level validator. Returns `null` for valid, error message for invalid.
typedef OiAfValidator<TField extends Enum, TValue> =
    FutureOr<String?> Function(OiAfValidationContext<TField, TValue> ctx);

/// Form-level validator. Returns `null` for valid, error message for invalid.
typedef OiAfFormValidator<TField extends Enum> =
    FutureOr<String?> Function(OiAfFormValidationContext<TField> ctx);

/// Condition callback for field visibility.
typedef OiAfVisibleWhen<TField extends Enum> =
    bool Function(OiAfReader<TField> form);

/// Condition callback for field enabled state.
typedef OiAfEnabledWhen<TField extends Enum> =
    bool Function(OiAfReader<TField> form);

/// Callback for computing derived field values.
typedef OiAfDerivedValue<TField extends Enum, TValue> =
    TValue? Function(OiAfReader<TField> form);

/// Custom getter for extracting a typed value from raw storage.
typedef OiAfValueGetter<TValue> = TValue? Function(Object? raw);

/// Custom setter for converting a typed value to raw storage.
typedef OiAfValueSetter<TValue> = Object? Function(TValue? value);

/// Custom equality check for comparing field values.
typedef OiAfValueEquals<TValue> = bool Function(TValue? a, TValue? b);

/// Error mapper for submit failures.
typedef OiAfSubmitErrorMapper<TField extends Enum, TData> =
    OiAfMappedSubmitError<TField> Function(
      OiAfSubmitErrorContext<TField, TData> ctx,
    );

/// Mapped submit errors split into field-level and global errors.
final class OiAfMappedSubmitError<TField extends Enum> {
  const OiAfMappedSubmitError({
    this.fieldErrors = const {},
    this.globalErrors = const [],
  });

  /// Per-field error messages.
  final Map<TField, List<String>> fieldErrors;

  /// Global error messages not tied to specific fields.
  final List<String> globalErrors;
}

/// Context available when mapping submit errors.
final class OiAfSubmitErrorContext<TField extends Enum, TData> {
  const OiAfSubmitErrorContext({
    required this.error,
    required this.stackTrace,
    required this.data,
    required this.controller,
  });

  /// The error that was thrown.
  final Object error;

  /// Stack trace of the error.
  final StackTrace stackTrace;

  /// The data that was being submitted.
  final TData data;

  /// The form controller, for reading field values during error mapping.
  final OiAfReader<TField> controller;
}
