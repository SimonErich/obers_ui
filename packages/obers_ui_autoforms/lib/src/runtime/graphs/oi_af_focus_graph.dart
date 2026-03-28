import 'package:obers_ui_autoforms/src/runtime/controller/oi_af_field_controller.dart';

/// Manages focus traversal order for form fields.
///
/// Computes the list of focusable fields based on visibility, enabled state,
/// and focus node registration. Provides next/previous/first/last queries.
class OiAfFocusGraph<TField extends Enum> {
  OiAfFocusGraph();

  /// Computes the ordered list of currently focusable fields.
  List<TField> focusableFields({
    required List<TField> fieldOrder,
    required Map<TField, OiAfFieldController<TField>> controllers,
  }) {
    return fieldOrder.where((f) {
      final fc = controllers[f]!;
      return fc.isVisible && fc.isEnabled && fc.registeredFocusNode != null;
    }).toList();
  }

  /// Focuses the given [field] by requesting focus on its registered node.
  void focusField(
    TField field, {
    required Map<TField, OiAfFieldController<TField>> controllers,
  }) {
    controllers[field]?.registeredFocusNode?.requestFocus();
  }

  /// Focuses the first available (visible + enabled) field.
  void focusFirstAvailable({
    required List<TField> fieldOrder,
    required Map<TField, OiAfFieldController<TField>> controllers,
  }) {
    for (final field in fieldOrder) {
      final fc = controllers[field]!;
      if (fc.isVisible && fc.isEnabled && fc.registeredFocusNode != null) {
        fc.registeredFocusNode!.requestFocus();
        return;
      }
    }
  }

  /// Focuses the first field that has validation errors.
  void focusFirstInvalid({
    required List<TField> fieldOrder,
    required Map<TField, OiAfFieldController<TField>> controllers,
  }) {
    for (final field in fieldOrder) {
      final fc = controllers[field]!;
      if (fc.isVisible &&
          fc.isEnabled &&
          fc.hasErrors &&
          fc.registeredFocusNode != null) {
        fc.registeredFocusNode!.requestFocus();
        return;
      }
    }
  }

  /// Focuses the next field after [currentField] in traversal order.
  void focusNext(
    TField currentField, {
    required List<TField> fieldOrder,
    required Map<TField, OiAfFieldController<TField>> controllers,
  }) {
    final focusable = focusableFields(
      fieldOrder: fieldOrder,
      controllers: controllers,
    );
    final idx = focusable.indexOf(currentField);
    if (idx < 0 || idx >= focusable.length - 1) return;
    focusField(focusable[idx + 1], controllers: controllers);
  }

  /// Focuses the previous field before [currentField] in traversal order.
  void focusPrevious(
    TField currentField, {
    required List<TField> fieldOrder,
    required Map<TField, OiAfFieldController<TField>> controllers,
  }) {
    final focusable = focusableFields(
      fieldOrder: fieldOrder,
      controllers: controllers,
    );
    final idx = focusable.indexOf(currentField);
    if (idx <= 0) return;
    focusField(focusable[idx - 1], controllers: controllers);
  }

  /// Whether [field] is the last focusable field.
  bool isLast(
    TField field, {
    required List<TField> fieldOrder,
    required Map<TField, OiAfFieldController<TField>> controllers,
  }) {
    final focusable = focusableFields(
      fieldOrder: fieldOrder,
      controllers: controllers,
    );
    return focusable.isNotEmpty && focusable.last == field;
  }

  /// Whether [field] is the first focusable field.
  bool isFirst(
    TField field, {
    required List<TField> fieldOrder,
    required Map<TField, OiAfFieldController<TField>> controllers,
  }) {
    final focusable = focusableFields(
      fieldOrder: fieldOrder,
      controllers: controllers,
    );
    return focusable.isNotEmpty && focusable.first == field;
  }
}
