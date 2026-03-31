import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiTimeOfDay;
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart' show OiAfController;

import 'package:obers_ui_autoforms/src/foundation/oi_af_enums.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_option.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_reader.dart';
import 'package:obers_ui_autoforms/src/foundation/oi_af_typedefs.dart';
import 'package:obers_ui_autoforms/src/validation/oi_af_validation_context.dart';
import 'package:obers_ui_autoforms/src/runtime/controller/oi_af_controller.dart'
    show OiAfController;

// ── Base Definition ──────────────────────────────────────────────────────────

/// Base class for all field definitions.
///
/// A field definition is an immutable specification of a field's data behavior.
/// It is created during [OiAfController.defineFields] and sealed after init.
@immutable
abstract class OiAfFieldDefinition<TField extends Enum, TValue> {
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

  /// The enum key identifying this field.
  final TField field;

  /// The type of field, determines which widget can bind to it.
  final OiAfFieldType type;

  /// The initial value before any user interaction or data load.
  final TValue? initialValue;

  /// Whether a non-null/non-empty value is required for validation.
  final bool required;

  /// Whether this field is included in `json()` export.
  final bool save;

  /// Whether to clear validation errors when the value changes.
  final bool clearErrorsOnChange;

  /// Whether to run validation immediately on init.
  final bool validateOnInit;

  /// Whether to exclude from validation and export when hidden.
  final bool excludeWhenHidden;

  /// Whether to clear the value when the field becomes hidden.
  final bool clearValueWhenHidden;

  /// Whether to skip validation when the field is disabled.
  final bool skipValidationWhenDisabled;

  /// Per-field override of the form's global validate mode.
  final OiAfValidateMode? validateModeOverride;

  /// Custom getter to extract a typed value from raw storage.
  final OiAfValueGetter<TValue>? getter;

  /// Custom setter to convert a typed value to raw storage.
  final OiAfValueSetter<TValue>? setter;

  /// Custom equality comparator for dirty detection.
  final OiAfValueEquals<TValue>? equals;

  /// Validators run in order during validation.
  final List<OiAfValidator<TField, TValue>> validators;

  /// Fields whose change should trigger revalidation of this field.
  final List<TField> revalidateWhen;

  /// Callback that determines visibility based on other field values.
  final OiAfVisibleWhen<TField>? visibleWhen;

  /// Callback that determines enabled state based on other field values.
  final OiAfEnabledWhen<TField>? enabledWhen;

  /// Fields this field depends on for derived value computation.
  final List<TField> dependsOn;

  /// When derived values are recomputed.
  final OiAfDeriveMode deriveMode;

  /// How user edits interact with derivation.
  final OiAfDerivedOverrideMode derivedOverrideMode;

  /// Callback to compute a derived value from form state.
  final OiAfDerivedValue<TField, TValue>? derive;

  /// Creates a [OiAfValidationContext] with the concrete [TValue] type
  /// preserved at runtime. Called via `dynamic` dispatch from the field
  /// controller so that Dart's reified generics produce the correct type
  /// (e.g. `OiAfValidationContext<TField, String>` instead of `dynamic`).
  OiAfValidationContext<TField, TValue> createValidationContext({
    required Object? value,
    required OiAfReader<TField> form,
    required OiAfValidationTrigger trigger,
    required bool isRequired,
    required bool isVisible,
    required bool isEnabled,
  }) {
    return OiAfValidationContext<TField, TValue>(
      field: field,
      value: value as TValue?,
      form: form,
      trigger: trigger,
      isRequired: isRequired,
      isVisible: isVisible,
      isEnabled: isEnabled,
    );
  }
}

// ── Typed Subclasses ─────────────────────────────────────────────────────────

/// Text field definition.
final class OiAfTextFieldDef<TField extends Enum>
    extends OiAfFieldDefinition<TField, String> {
  const OiAfTextFieldDef({
    required super.field,
    super.initialValue,
    super.required,
    super.save,
    super.clearErrorsOnChange,
    super.validateOnInit,
    super.excludeWhenHidden,
    super.clearValueWhenHidden,
    super.skipValidationWhenDisabled,
    super.validateModeOverride,
    super.getter,
    super.setter,
    super.equals,
    super.validators,
    super.revalidateWhen,
    super.visibleWhen,
    super.enabledWhen,
    super.dependsOn,
    super.deriveMode,
    super.derivedOverrideMode,
    super.derive,
  }) : super(type: OiAfFieldType.text);
}

/// Number field definition.
final class OiAfNumberFieldDef<TField extends Enum>
    extends OiAfFieldDefinition<TField, num> {
  const OiAfNumberFieldDef({
    required super.field,
    super.initialValue,
    super.required,
    super.save,
    super.clearErrorsOnChange,
    super.validateOnInit,
    super.excludeWhenHidden,
    super.clearValueWhenHidden,
    super.skipValidationWhenDisabled,
    super.validateModeOverride,
    super.getter,
    super.setter,
    super.equals,
    super.validators,
    super.revalidateWhen,
    super.visibleWhen,
    super.enabledWhen,
    super.dependsOn,
    super.deriveMode,
    super.derivedOverrideMode,
    super.derive,
    this.min,
    this.max,
    this.step = 1,
    this.decimalPlaces,
  }) : super(type: OiAfFieldType.number);

  final num? min;
  final num? max;
  final num step;
  final int? decimalPlaces;
}

/// Boolean field definition (checkbox).
final class OiAfBoolFieldDef<TField extends Enum>
    extends OiAfFieldDefinition<TField, bool?> {
  const OiAfBoolFieldDef({
    required super.field,
    super.initialValue,
    super.required,
    super.save,
    super.clearErrorsOnChange,
    super.validateOnInit,
    super.excludeWhenHidden,
    super.clearValueWhenHidden,
    super.skipValidationWhenDisabled,
    super.validateModeOverride,
    super.getter,
    super.setter,
    super.equals,
    super.validators,
    super.revalidateWhen,
    super.visibleWhen,
    super.enabledWhen,
    super.dependsOn,
    super.deriveMode,
    super.derivedOverrideMode,
    super.derive,
    this.tristate = false,
    super.type = OiAfFieldType.checkbox,
  });

  /// Whether the checkbox supports a third (indeterminate) state.
  final bool tristate;
}

/// Single-select field definition.
final class OiAfSelectFieldDef<TField extends Enum, TValue>
    extends OiAfFieldDefinition<TField, TValue> {
  const OiAfSelectFieldDef({
    required super.field,
    this.options = const [],
    super.initialValue,
    super.required,
    super.save,
    super.clearErrorsOnChange,
    super.validateOnInit,
    super.excludeWhenHidden,
    super.clearValueWhenHidden,
    super.skipValidationWhenDisabled,
    super.validateModeOverride,
    super.getter,
    super.setter,
    super.equals,
    super.validators,
    super.revalidateWhen,
    super.visibleWhen,
    super.enabledWhen,
    super.dependsOn,
    super.deriveMode,
    super.derivedOverrideMode,
    super.derive,
  }) : super(type: OiAfFieldType.select);

  final List<OiAfOption<TValue>> options;
}

/// Multi-select field definition.
final class OiAfMultiSelectFieldDef<TField extends Enum, TValue>
    extends OiAfFieldDefinition<TField, List<TValue>> {
  const OiAfMultiSelectFieldDef({
    required super.field,
    this.options = const [],
    super.initialValue,
    super.required,
    super.save,
    super.clearErrorsOnChange,
    super.validateOnInit,
    super.excludeWhenHidden,
    super.clearValueWhenHidden,
    super.skipValidationWhenDisabled,
    super.validateModeOverride,
    super.getter,
    super.setter,
    super.equals,
    super.validators,
    super.revalidateWhen,
    super.visibleWhen,
    super.enabledWhen,
    super.dependsOn,
    super.deriveMode,
    super.derivedOverrideMode,
    super.derive,
  }) : super(type: OiAfFieldType.multiSelect);

  final List<OiAfOption<TValue>> options;
}

/// Combo box field definition.
final class OiAfComboBoxFieldDef<TField extends Enum, TValue>
    extends OiAfFieldDefinition<TField, TValue> {
  const OiAfComboBoxFieldDef({
    required super.field,
    this.options = const [],
    this.multiSelect = false,
    super.initialValue,
    super.required,
    super.save,
    super.clearErrorsOnChange,
    super.validateOnInit,
    super.excludeWhenHidden,
    super.clearValueWhenHidden,
    super.skipValidationWhenDisabled,
    super.validateModeOverride,
    super.getter,
    super.setter,
    super.equals,
    super.validators,
    super.revalidateWhen,
    super.visibleWhen,
    super.enabledWhen,
    super.dependsOn,
    super.deriveMode,
    super.derivedOverrideMode,
    super.derive,
  }) : super(type: OiAfFieldType.comboBox);

  final List<OiAfOption<TValue>> options;
  final bool multiSelect;
}

/// Radio field definition.
final class OiAfRadioFieldDef<TField extends Enum, TValue>
    extends OiAfFieldDefinition<TField, TValue> {
  const OiAfRadioFieldDef({
    required super.field,
    this.options = const [],
    super.initialValue,
    super.required,
    super.save,
    super.clearErrorsOnChange,
    super.validateOnInit,
    super.excludeWhenHidden,
    super.clearValueWhenHidden,
    super.skipValidationWhenDisabled,
    super.validateModeOverride,
    super.getter,
    super.setter,
    super.equals,
    super.validators,
    super.revalidateWhen,
    super.visibleWhen,
    super.enabledWhen,
    super.dependsOn,
    super.deriveMode,
    super.derivedOverrideMode,
    super.derive,
  }) : super(type: OiAfFieldType.radio);

  final List<OiAfOption<TValue>> options;
}

/// Date (wheel picker) field definition.
final class OiAfDateFieldDef<TField extends Enum>
    extends OiAfFieldDefinition<TField, DateTime> {
  const OiAfDateFieldDef({
    required super.field,
    this.minDate,
    this.maxDate,
    super.initialValue,
    super.required,
    super.save,
    super.clearErrorsOnChange,
    super.validateOnInit,
    super.excludeWhenHidden,
    super.clearValueWhenHidden,
    super.skipValidationWhenDisabled,
    super.validateModeOverride,
    super.getter,
    super.setter,
    super.equals,
    super.validators,
    super.revalidateWhen,
    super.visibleWhen,
    super.enabledWhen,
    super.dependsOn,
    super.deriveMode,
    super.derivedOverrideMode,
    super.derive,
  }) : super(type: OiAfFieldType.date);

  final DateTime? minDate;
  final DateTime? maxDate;
}

/// Time (wheel picker) field definition.
final class OiAfTimeFieldDef<TField extends Enum>
    extends OiAfFieldDefinition<TField, OiTimeOfDay> {
  const OiAfTimeFieldDef({
    required super.field,
    this.minTime,
    this.maxTime,
    super.initialValue,
    super.required,
    super.save,
    super.clearErrorsOnChange,
    super.validateOnInit,
    super.excludeWhenHidden,
    super.clearValueWhenHidden,
    super.skipValidationWhenDisabled,
    super.validateModeOverride,
    super.getter,
    super.setter,
    super.equals,
    super.validators,
    super.revalidateWhen,
    super.visibleWhen,
    super.enabledWhen,
    super.dependsOn,
    super.deriveMode,
    super.derivedOverrideMode,
    super.derive,
  }) : super(type: OiAfFieldType.time);

  final OiTimeOfDay? minTime;
  final OiTimeOfDay? maxTime;
}

/// DateTime field definition.
final class OiAfDateTimeFieldDef<TField extends Enum>
    extends OiAfFieldDefinition<TField, DateTime> {
  const OiAfDateTimeFieldDef({
    required super.field,
    this.minDate,
    this.maxDate,
    super.initialValue,
    super.required,
    super.save,
    super.clearErrorsOnChange,
    super.validateOnInit,
    super.excludeWhenHidden,
    super.clearValueWhenHidden,
    super.skipValidationWhenDisabled,
    super.validateModeOverride,
    super.getter,
    super.setter,
    super.equals,
    super.validators,
    super.revalidateWhen,
    super.visibleWhen,
    super.enabledWhen,
    super.dependsOn,
    super.deriveMode,
    super.derivedOverrideMode,
    super.derive,
  }) : super(type: OiAfFieldType.dateTime);

  final DateTime? minDate;
  final DateTime? maxDate;
}

/// Calendar date picker field definition.
final class OiAfDatePickerFieldDef<TField extends Enum>
    extends OiAfFieldDefinition<TField, DateTime> {
  const OiAfDatePickerFieldDef({
    required super.field,
    this.minDate,
    this.maxDate,
    super.initialValue,
    super.required,
    super.save,
    super.clearErrorsOnChange,
    super.validateOnInit,
    super.excludeWhenHidden,
    super.clearValueWhenHidden,
    super.skipValidationWhenDisabled,
    super.validateModeOverride,
    super.getter,
    super.setter,
    super.equals,
    super.validators,
    super.revalidateWhen,
    super.visibleWhen,
    super.enabledWhen,
    super.dependsOn,
    super.deriveMode,
    super.derivedOverrideMode,
    super.derive,
  }) : super(type: OiAfFieldType.datePicker);

  final DateTime? minDate;
  final DateTime? maxDate;
}

/// Calendar date range picker field definition.
final class OiAfDateRangePickerFieldDef<TField extends Enum>
    extends OiAfFieldDefinition<TField, (DateTime, DateTime)> {
  const OiAfDateRangePickerFieldDef({
    required super.field,
    this.minDate,
    this.maxDate,
    super.initialValue,
    super.required,
    super.save,
    super.clearErrorsOnChange,
    super.validateOnInit,
    super.excludeWhenHidden,
    super.clearValueWhenHidden,
    super.skipValidationWhenDisabled,
    super.validateModeOverride,
    super.getter,
    super.setter,
    super.equals,
    super.validators,
    super.revalidateWhen,
    super.visibleWhen,
    super.enabledWhen,
    super.dependsOn,
    super.deriveMode,
    super.derivedOverrideMode,
    super.derive,
  }) : super(type: OiAfFieldType.dateRangePicker);

  final DateTime? minDate;
  final DateTime? maxDate;
}

/// Dialog time picker field definition.
final class OiAfTimePickerFieldDef<TField extends Enum>
    extends OiAfFieldDefinition<TField, OiTimeOfDay> {
  const OiAfTimePickerFieldDef({
    required super.field,
    this.use24Hour = true,
    this.minuteInterval = 1,
    super.initialValue,
    super.required,
    super.save,
    super.clearErrorsOnChange,
    super.validateOnInit,
    super.excludeWhenHidden,
    super.clearValueWhenHidden,
    super.skipValidationWhenDisabled,
    super.validateModeOverride,
    super.getter,
    super.setter,
    super.equals,
    super.validators,
    super.revalidateWhen,
    super.visibleWhen,
    super.enabledWhen,
    super.dependsOn,
    super.deriveMode,
    super.derivedOverrideMode,
    super.derive,
  }) : super(type: OiAfFieldType.timePicker);

  final bool use24Hour;
  final int minuteInterval;
}

/// Tag (chips) field definition.
final class OiAfTagFieldDef<TField extends Enum>
    extends OiAfFieldDefinition<TField, List<String>> {
  const OiAfTagFieldDef({
    required super.field,
    this.maxTags,
    super.initialValue,
    super.required,
    super.save,
    super.clearErrorsOnChange,
    super.validateOnInit,
    super.excludeWhenHidden,
    super.clearValueWhenHidden,
    super.skipValidationWhenDisabled,
    super.validateModeOverride,
    super.getter,
    super.setter,
    super.equals,
    super.validators,
    super.revalidateWhen,
    super.visibleWhen,
    super.enabledWhen,
    super.dependsOn,
    super.deriveMode,
    super.derivedOverrideMode,
    super.derive,
  }) : super(type: OiAfFieldType.tags);

  final int? maxTags;
}

/// Slider field definition.
final class OiAfSliderFieldDef<TField extends Enum>
    extends OiAfFieldDefinition<TField, double> {
  const OiAfSliderFieldDef({
    required super.field,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.isRange = false,
    super.initialValue,
    super.required,
    super.save,
    super.clearErrorsOnChange,
    super.validateOnInit,
    super.excludeWhenHidden,
    super.clearValueWhenHidden,
    super.skipValidationWhenDisabled,
    super.validateModeOverride,
    super.getter,
    super.setter,
    super.equals,
    super.validators,
    super.revalidateWhen,
    super.visibleWhen,
    super.enabledWhen,
    super.dependsOn,
    super.deriveMode,
    super.derivedOverrideMode,
    super.derive,
  }) : super(type: OiAfFieldType.slider);

  final double min;
  final double max;
  final int? divisions;
  final bool isRange;
}

/// Color picker field definition.
final class OiAfColorFieldDef<TField extends Enum>
    extends OiAfFieldDefinition<TField, Color> {
  const OiAfColorFieldDef({
    required super.field,
    super.initialValue,
    super.required,
    super.save,
    super.clearErrorsOnChange,
    super.validateOnInit,
    super.excludeWhenHidden,
    super.clearValueWhenHidden,
    super.skipValidationWhenDisabled,
    super.validateModeOverride,
    super.getter,
    super.setter,
    super.equals,
    super.validators,
    super.revalidateWhen,
    super.visibleWhen,
    super.enabledWhen,
    super.dependsOn,
    super.deriveMode,
    super.derivedOverrideMode,
    super.derive,
  }) : super(type: OiAfFieldType.color);
}

/// File value model.
@immutable
final class OiAfFileValue {
  const OiAfFileValue({
    required this.name,
    required this.path,
    this.sizeInBytes,
    this.extension,
  });

  final String name;
  final String path;
  final int? sizeInBytes;
  final String? extension;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiAfFileValue && other.path == path && other.name == name;

  @override
  int get hashCode => Object.hash(name, path);
}

/// File input field definition.
final class OiAfFileFieldDef<TField extends Enum>
    extends OiAfFieldDefinition<TField, List<OiAfFileValue>> {
  const OiAfFileFieldDef({
    required super.field,
    this.maxFiles,
    this.acceptedTypes,
    super.initialValue,
    super.required,
    super.save,
    super.clearErrorsOnChange,
    super.validateOnInit,
    super.excludeWhenHidden,
    super.clearValueWhenHidden,
    super.skipValidationWhenDisabled,
    super.validateModeOverride,
    super.getter,
    super.setter,
    super.equals,
    super.validators,
    super.revalidateWhen,
    super.visibleWhen,
    super.enabledWhen,
    super.dependsOn,
    super.deriveMode,
    super.derivedOverrideMode,
    super.derive,
  }) : super(type: OiAfFieldType.file);

  final int? maxFiles;
  final List<String>? acceptedTypes;
}

/// Segmented control field definition.
final class OiAfSegmentedControlFieldDef<TField extends Enum, TValue>
    extends OiAfFieldDefinition<TField, TValue> {
  const OiAfSegmentedControlFieldDef({
    required super.field,
    this.segments = const [],
    super.initialValue,
    super.required,
    super.save,
    super.clearErrorsOnChange,
    super.validateOnInit,
    super.excludeWhenHidden,
    super.clearValueWhenHidden,
    super.skipValidationWhenDisabled,
    super.validateModeOverride,
    super.getter,
    super.setter,
    super.equals,
    super.validators,
    super.revalidateWhen,
    super.visibleWhen,
    super.enabledWhen,
    super.dependsOn,
    super.deriveMode,
    super.derivedOverrideMode,
    super.derive,
  }) : super(type: OiAfFieldType.segmentedControl);

  final List<OiAfOption<TValue>> segments;
}

/// Rich text editor field definition.
final class OiAfRichTextFieldDef<TField extends Enum>
    extends OiAfFieldDefinition<TField, String> {
  const OiAfRichTextFieldDef({
    required super.field,
    super.initialValue,
    super.required,
    super.save,
    super.clearErrorsOnChange,
    super.validateOnInit,
    super.excludeWhenHidden,
    super.clearValueWhenHidden,
    super.skipValidationWhenDisabled,
    super.validateModeOverride,
    super.getter,
    super.setter,
    super.equals,
    super.validators,
    super.revalidateWhen,
    super.visibleWhen,
    super.enabledWhen,
    super.dependsOn,
    super.deriveMode,
    super.derivedOverrideMode,
    super.derive,
  }) : super(type: OiAfFieldType.richText);
}

/// Repeatable item array field definition.
final class OiAfArrayFieldDef<TField extends Enum, TItem>
    extends OiAfFieldDefinition<TField, List<TItem>> {
  const OiAfArrayFieldDef({
    required super.field,
    required this.createEmpty,
    this.minItems,
    this.maxItems,
    super.initialValue,
    super.required,
    super.save,
    super.clearErrorsOnChange,
    super.validateOnInit,
    super.excludeWhenHidden,
    super.clearValueWhenHidden,
    super.skipValidationWhenDisabled,
    super.validateModeOverride,
    super.getter,
    super.setter,
    super.equals,
    super.validators,
    super.revalidateWhen,
    super.visibleWhen,
    super.enabledWhen,
    super.dependsOn,
    super.deriveMode,
    super.derivedOverrideMode,
    super.derive,
  }) : super(type: OiAfFieldType.array);

  /// Factory to create an empty item for adding to the array.
  final TItem Function() createEmpty;

  /// Minimum number of items required.
  final int? minItems;

  /// Maximum number of items allowed.
  final int? maxItems;
}
