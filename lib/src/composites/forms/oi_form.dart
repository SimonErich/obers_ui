import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/widgets.dart' show Color;
import 'package:obers_ui/src/components/inputs/oi_checkbox.dart';
import 'package:obers_ui/src/components/inputs/oi_color_input.dart';
import 'package:obers_ui/src/components/inputs/oi_date_input.dart';
import 'package:obers_ui/src/components/inputs/oi_file_input.dart';
import 'package:obers_ui/src/components/inputs/oi_number_input.dart';
import 'package:obers_ui/src/components/inputs/oi_radio.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';
import 'package:obers_ui/src/components/inputs/oi_slider.dart';
import 'package:obers_ui/src/components/inputs/oi_switch.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/components/inputs/oi_time_input.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

// ── Enums ───────────────────────────────────────────────────────────────────

/// The type of a form field.
///
/// Determines which input widget is rendered by [OiForm].
///
/// {@category Composites}
enum OiFieldType {
  /// A single- or multi-line text input.
  text,

  /// A numeric input with stepper buttons.
  number,

  /// A date picker field.
  date,

  /// A time picker field.
  time,

  /// A dropdown select input.
  select,

  /// A checkbox toggle.
  checkbox,

  /// A switch toggle.
  switchField,

  /// A radio button group.
  radio,

  /// A slider input.
  slider,

  /// A color picker field.
  color,

  /// A file picker field.
  file,

  /// A custom widget supplied via [OiFormField.customBuilder].
  custom,
}

/// The layout direction of form fields.
///
/// {@category Composites}
enum OiFormLayout {
  /// Fields are stacked vertically (default).
  vertical,

  /// Fields are laid out in a horizontal row.
  horizontal,

  /// Fields are laid out inline, wrapping when needed.
  inline,
}

// ── OiFormField ─────────────────────────────────────────────────────────────

/// A declarative description of a single field within an [OiForm].
///
/// Each field has a unique [key], a display [label], and a [type] that
/// determines which widget is rendered. Optional [validate] and [required]
/// properties control validation.
///
/// {@category Composites}
@immutable
class OiFormField {
  /// Creates an [OiFormField].
  const OiFormField({
    required this.key,
    required this.label,
    required this.type,
    this.defaultValue,
    this.required = false,
    this.validate,
    this.config,
    this.customBuilder,
  });

  /// A unique identifier for this field, used as the key in form values.
  final String key;

  /// The human-readable label rendered above or beside the input.
  final String label;

  /// The type of input widget to render.
  final OiFieldType type;

  /// The default value for this field when the form is first created.
  final dynamic defaultValue;

  /// Whether this field must have a non-null, non-empty value to pass
  /// validation.
  final bool required;

  /// An optional validation function. Returns an error message string when
  /// the value is invalid, or `null` when valid.
  final String? Function(dynamic)? validate;

  /// Extra configuration passed to the rendered widget (e.g. options for
  /// a select field, min/max for a number field).
  final Map<String, dynamic>? config;

  /// A builder for [OiFieldType.custom] fields. Receives the current value
  /// and a callback to update it.
  final Widget Function(dynamic value, ValueChanged<dynamic>)? customBuilder;
}

// ── OiFormSection ───────────────────────────────────────────────────────────

/// A logical grouping of [OiFormField]s within an [OiForm].
///
/// Sections may have an optional [title] and [description] rendered above
/// the field list.
///
/// {@category Composites}
@immutable
class OiFormSection {
  /// Creates an [OiFormSection].
  const OiFormSection({this.title, this.description, required this.fields});

  /// An optional heading rendered above the section's fields.
  final String? title;

  /// An optional description rendered below the title.
  final String? description;

  /// The fields contained in this section.
  final List<OiFormField> fields;
}

// ── OiFormController ────────────────────────────────────────────────────────

/// Controller managing form state: values, validation errors, dirty flags.
///
/// Extend or compose with this controller to drive an [OiForm] widget.
/// Notifies listeners on every value or error change.
///
/// {@category Composites}
class OiFormController extends ChangeNotifier {
  /// Creates an [OiFormController] with optional [initialValues].
  OiFormController({Map<String, dynamic>? initialValues})
    : _values = Map<String, dynamic>.from(initialValues ?? {}),
      _initialValues = Map<String, dynamic>.from(initialValues ?? {});

  final Map<String, dynamic> _values;
  final Map<String, dynamic> _initialValues;
  final Map<String, String?> _errors = {};

  /// Gets all current form values as an unmodifiable map.
  Map<String, dynamic> get values => Map<String, dynamic>.unmodifiable(_values);

  /// Gets a specific field value by [key], cast to [T].
  T? getValue<T>(String key) => _values[key] as T?;

  /// Sets a field value and notifies listeners.
  void setValue(String key, dynamic value) {
    _values[key] = value;
    notifyListeners();
  }

  /// Gets the validation error for a specific field.
  String? getError(String key) => _errors[key];

  /// Sets an error for a specific field and notifies listeners.
  ///
  /// Pass `null` to clear the error.
  void setError(String key, String? error) {
    _errors[key] = error;
    notifyListeners();
  }

  /// Whether the form has no validation errors.
  bool get isValid => _errors.values.every((e) => e == null);

  /// Whether any field has been modified from its initial value.
  bool get isDirty {
    for (final entry in _values.entries) {
      if (_initialValues[entry.key] != entry.value) return true;
    }
    return false;
  }

  /// Resets all fields to their initial values and clears errors.
  void reset() {
    _values
      ..clear()
      ..addAll(Map<String, dynamic>.from(_initialValues));
    _errors.clear();
    notifyListeners();
  }

  /// Validates all fields using the provided [validators] map.
  ///
  /// Each validator receives the current field value and returns an error
  /// string or `null`. Returns `true` when all fields pass validation.
  bool validate(Map<String, String? Function(dynamic)> validators) {
    for (final entry in validators.entries) {
      final error = entry.value(_values[entry.key]);
      _errors[entry.key] = error;
    }
    notifyListeners();
    return isValid;
  }
}

// ── OiForm ──────────────────────────────────────────────────────────────────

/// A form system that renders sections of fields with validation.
///
/// Renders form fields from [OiFormField] configurations, handling
/// validation, conditional visibility, dirty detection, and submission.
/// Field values are stored in the provided [controller].
///
/// {@category Composites}
class OiForm extends StatefulWidget {
  /// Creates an [OiForm].
  const OiForm({
    super.key,
    required this.sections,
    required this.controller,
    this.onSubmit,
    this.onCancel,
    this.autoValidate = false,
    this.conditions,
    this.dependencies,
    this.autosave,
    this.dirtyDetection = true,
    this.undoRedo = false,
    this.layout = OiFormLayout.vertical,
  });

  /// The sections of fields to render.
  final List<OiFormSection> sections;

  /// The controller that manages field values, errors, and dirty state.
  final OiFormController controller;

  /// Called when the form is submitted with the current values.
  final ValueChanged<Map<String, dynamic>>? onSubmit;

  /// Called when the user cancels the form.
  final VoidCallback? onCancel;

  /// When `true`, fields are validated on every change.
  final bool autoValidate;

  /// Conditional visibility rules. Each key is a field key, and the function
  /// returns `true` when the field should be visible, based on all values.
  final Map<String, bool Function(Map<String, dynamic>)>? conditions;

  /// Dependency callbacks. When any value changes, each dependency function
  /// is called with the full value map, allowing fields to react to
  /// sibling changes.
  final Map<String, void Function(Map<String, dynamic>)>? dependencies;

  /// When non-null the form auto-saves at this interval.
  final Duration? autosave;

  /// Whether to enable dirty detection (submit disabled when not dirty).
  final bool dirtyDetection;

  /// Whether to enable undo/redo support.
  final bool undoRedo;

  /// The layout direction for form fields.
  final OiFormLayout layout;

  @override
  State<OiForm> createState() => _OiFormState();
}

class _OiFormState extends State<OiForm> {
  Timer? _autosaveTimer;
  bool _validating = false;

  @override
  void initState() {
    super.initState();
    _initDefaults();
    widget.controller.addListener(_onControllerChange);
    _startAutosave();
  }

  @override
  void didUpdateWidget(OiForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChange);
      widget.controller.addListener(_onControllerChange);
    }
    if (oldWidget.autosave != widget.autosave) {
      _autosaveTimer?.cancel();
      _startAutosave();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    _autosaveTimer?.cancel();
    super.dispose();
  }

  void _initDefaults() {
    for (final section in widget.sections) {
      for (final field in section.fields) {
        if (field.defaultValue != null &&
            widget.controller.getValue<dynamic>(field.key) == null) {
          widget.controller.setValue(field.key, field.defaultValue);
        }
      }
    }
  }

  void _startAutosave() {
    if (widget.autosave != null) {
      _autosaveTimer = Timer.periodic(widget.autosave!, (_) {
        widget.onSubmit?.call(widget.controller.values);
      });
    }
  }

  void _onControllerChange() {
    // Guard against re-entrant calls from setError -> notifyListeners.
    if (_validating) return;

    // Run dependencies.
    if (widget.dependencies != null) {
      for (final dep in widget.dependencies!.values) {
        dep(widget.controller.values);
      }
    }

    // Auto-validate.
    if (widget.autoValidate) {
      _validateAll();
    }

    setState(() {});
  }

  void _validateAll() {
    _validating = true;
    try {
      for (final section in widget.sections) {
        for (final field in section.fields) {
          _validateField(field);
        }
      }
    } finally {
      _validating = false;
    }
  }

  void _validateField(OiFormField field) {
    final value = widget.controller.getValue<dynamic>(field.key);

    // Required check.
    if (field.required) {
      if (value == null || (value is String && value.isEmpty)) {
        widget.controller.setError(field.key, '${field.label} is required');
        return;
      }
    }

    // Custom validator.
    if (field.validate != null) {
      final error = field.validate!(value);
      widget.controller.setError(field.key, error);
      return;
    }

    widget.controller.setError(field.key, null);
  }

  void _handleSubmit() {
    _validateAll();
    if (widget.controller.isValid) {
      widget.onSubmit?.call(widget.controller.values);
    }
  }

  void _handleCancel() {
    widget.controller.reset();
    widget.onCancel?.call();
  }

  bool _isFieldVisible(OiFormField field) {
    if (widget.conditions == null) return true;
    final condition = widget.conditions![field.key];
    if (condition == null) return true;
    return condition(widget.controller.values);
  }

  // ---------------------------------------------------------------------------
  // Field builders
  // ---------------------------------------------------------------------------

  Widget _buildField(BuildContext context, OiFormField field) {
    final value = widget.controller.getValue<dynamic>(field.key);
    final error = widget.controller.getError(field.key);

    switch (field.type) {
      case OiFieldType.text:
        return OiTextInput(
          key: ValueKey('oi_form_field_${field.key}'),
          label: field.label,
          error: error,
          onChanged: (v) => widget.controller.setValue(field.key, v),
          controller: TextEditingController(text: value as String? ?? ''),
        );

      case OiFieldType.number:
        return OiNumberInput(
          key: ValueKey('oi_form_field_${field.key}'),
          label: field.label,
          error: error,
          value: value as double?,
          onChanged: (v) => widget.controller.setValue(field.key, v),
          min: field.config?['min'] as double?,
          max: field.config?['max'] as double?,
          step: (field.config?['step'] as double?) ?? 1,
        );

      case OiFieldType.checkbox:
        return OiCheckbox(
          key: ValueKey('oi_form_field_${field.key}'),
          value: value as bool?,
          label: field.label,
          onChanged: (v) => widget.controller.setValue(field.key, v),
        );

      case OiFieldType.switchField:
        return OiSwitch(
          key: ValueKey('oi_form_field_${field.key}'),
          value: value as bool? ?? false,
          label: field.label,
          onChanged: (v) => widget.controller.setValue(field.key, v),
        );

      case OiFieldType.select:
        final options =
            (field.config?['options'] as List<OiSelectOption<dynamic>>?) ?? [];
        return OiSelect<dynamic>(
          key: ValueKey('oi_form_field_${field.key}'),
          label: field.label,
          error: error,
          value: value,
          options: options,
          onChanged: (v) => widget.controller.setValue(field.key, v),
        );

      case OiFieldType.custom:
        if (field.customBuilder != null) {
          return field.customBuilder!(
            value,
            (v) => widget.controller.setValue(field.key, v),
          );
        }
        return const SizedBox.shrink();

      case OiFieldType.date:
        return OiDateInput(
          key: ValueKey('oi_form_field_${field.key}'),
          label: field.label,
          error: error,
          value: value as DateTime?,
          onChanged: (v) => widget.controller.setValue(field.key, v),
        );

      case OiFieldType.time:
        return OiTimeInput(
          key: ValueKey('oi_form_field_${field.key}'),
          label: field.label,
          error: error,
          value: value as OiTimeOfDay?,
          onChanged: (v) => widget.controller.setValue(field.key, v),
        );

      case OiFieldType.radio:
        final radioOptions =
            (field.config?['options'] as List<OiRadioOption<dynamic>>?) ?? [];
        return OiRadio<dynamic>(
          key: ValueKey('oi_form_field_${field.key}'),
          options: radioOptions,
          value: value,
          onChanged: (v) => widget.controller.setValue(field.key, v),
        );

      case OiFieldType.slider:
        return OiSlider(
          key: ValueKey('oi_form_field_${field.key}'),
          value: (value as double?) ?? 0.0,
          min: (field.config?['min'] as double?) ?? 0.0,
          max: (field.config?['max'] as double?) ?? 100.0,
          divisions: field.config?['divisions'] as int?,
          label: field.label,
          onChanged: (v) => widget.controller.setValue(field.key, v),
        );

      case OiFieldType.color:
        return OiColorInput(
          key: ValueKey('oi_form_field_${field.key}'),
          label: field.label,
          error: error,
          value: value as Color?,
          onChanged: (v) => widget.controller.setValue(field.key, v),
        );

      case OiFieldType.file:
        return OiFileInput(
          key: ValueKey('oi_form_field_${field.key}'),
          label: field.label,
          error: error,
          value: value as List<String>?,
          onChanged: (v) => widget.controller.setValue(field.key, v),
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Section builder
  // ---------------------------------------------------------------------------

  Widget _buildSection(BuildContext context, OiFormSection section) {
    final colors = context.colors;
    final visibleFields = section.fields.where(_isFieldVisible).toList();

    if (visibleFields.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (section.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              section.title!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
          ),
        if (section.description != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              section.description!,
              style: TextStyle(fontSize: 13, color: colors.textMuted),
            ),
          ),
        ..._layoutFields(context, visibleFields),
      ],
    );
  }

  List<Widget> _layoutFields(BuildContext context, List<OiFormField> fields) {
    switch (widget.layout) {
      case OiFormLayout.vertical:
        return fields
            .map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildField(context, f),
              ),
            )
            .toList();

      case OiFormLayout.horizontal:
        return [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: fields
                .map(
                  (f) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _buildField(context, f),
                    ),
                  ),
                )
                .toList(),
          ),
        ];

      case OiFormLayout.inline:
        return [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: fields.map((f) => _buildField(context, f)).toList(),
          ),
        ];
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final canSubmit = !widget.dirtyDetection || widget.controller.isDirty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final section in widget.sections)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildSection(context, section),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.onCancel != null)
              GestureDetector(
                onTap: _handleCancel,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 14, color: colors.textMuted),
                  ),
                ),
              ),
            if (widget.onSubmit != null)
              GestureDetector(
                onTap: canSubmit ? _handleSubmit : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: canSubmit
                        ? colors.primary.base
                        : colors.borderSubtle,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 14,
                      color: canSubmit
                          ? colors.textOnPrimary
                          : colors.textMuted,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
