import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';

/// A form-integrated dropdown wrapping [OiSelect] with [FormField<T>].
///
/// When [validator] is non-null the widget wraps itself in a [FormField<T>]
/// so it participates in ancestor [Form] validation, saving, and auto-
/// validate flows. The manually supplied [error] takes precedence over the
/// form-field error text.
///
/// When [validator] is null the widget renders a plain [OiSelect<T>] and
/// passes [error] through directly.
///
/// All other parameters are forwarded to [OiSelect] unchanged.
///
/// {@category Components}
class OiFormSelect<T> extends StatelessWidget {
  /// Creates an [OiFormSelect].
  const OiFormSelect({
    required this.options,
    required this.labelOf,
    this.value,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.autovalidateMode,
    this.label,
    this.hint,
    this.placeholder,
    this.error,
    this.enabled = true,
    this.searchable = false,
    this.bottomSheetOnCompact = false,
    this.semanticLabel,
    super.key,
  });

  /// The list of values to choose from.
  ///
  /// Each value is converted into an [OiSelectOption] using [labelOf].
  final List<T> options;

  /// Converts a value of type [T] into a human-readable label.
  final String Function(T) labelOf;

  /// The currently selected value, or `null` if nothing is selected.
  final T? value;

  /// Called when the user selects an option.
  final ValueChanged<T?>? onChanged;

  /// Validation function called by an ancestor `Form.validate()`.
  ///
  /// Return `null` when valid, or an error string when invalid. When
  /// non-null, the widget internally wraps with a [FormField].
  final String? Function(T?)? validator;

  /// Called by `Form.save()` with the current value.
  final void Function(T?)? onSaved;

  /// Controls when validation runs automatically.
  final AutovalidateMode? autovalidateMode;

  /// Optional label rendered above the input frame.
  final String? label;

  /// Optional hint text rendered below the input frame.
  final String? hint;

  /// Placeholder text shown when no value is selected.
  final String? placeholder;

  /// Manual validation error message.
  ///
  /// When non-null this takes precedence over the error produced by
  /// [validator].
  final String? error;

  /// Whether the field accepts interaction.
  final bool enabled;

  /// When `true` a search field is shown at the top of the dropdown.
  final bool searchable;

  /// When `true` the dropdown appears as a bottom sheet on compact
  /// breakpoints.
  final bool bottomSheetOnCompact;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  /// Builds the list of [OiSelectOption] from [options] and [labelOf].
  List<OiSelectOption<T>> _buildSelectOptions() {
    return options
        .map((v) => OiSelectOption<T>(value: v, label: labelOf(v)))
        .toList();
  }

  /// Builds the underlying [OiSelect] with the resolved error message.
  Widget _buildSelect(String? resolvedError) {
    Widget select = OiSelect<T>(
      options: _buildSelectOptions(),
      value: value,
      onChanged: onChanged,
      label: label,
      hint: hint,
      error: resolvedError,
      placeholder: placeholder,
      enabled: enabled,
      searchable: searchable,
      bottomSheetOnCompact: bottomSheetOnCompact,
    );

    if (semanticLabel != null) {
      select = Semantics(label: semanticLabel, child: select);
    }

    return select;
  }

  @override
  Widget build(BuildContext context) {
    if (validator != null) {
      return FormField<T>(
        validator: validator,
        autovalidateMode: autovalidateMode,
        onSaved: onSaved,
        initialValue: value,
        builder: (state) {
          // Manual error wins over form-field error.
          final resolvedError = error ?? state.errorText;

          return _buildSelect(resolvedError);
        },
      );
    }

    return _buildSelect(error);
  }
}
