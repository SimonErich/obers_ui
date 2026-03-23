import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/components/navigation/oi_date_picker.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A date input field that displays a formatted date and opens a calendar
/// dialog ([OiDatePicker]) when tapped.
///
/// The field renders an [OiInputFrame] with a read-only display of the
/// formatted [value] and a trailing calendar icon. Tapping the field opens
/// an [OiDatePicker] dialog. When the user selects a date the dialog closes
/// and [onChanged] fires with the chosen [DateTime].
///
/// Date formatting uses the `intl` [DateFormat]. Supply [dateFormat] to
/// override the default pattern (`'MMM d, yyyy'`).
///
/// When [clearable] is `true` and a [value] is set, a small clear button
/// appears before the calendar icon.
///
/// When [validator] is non-null the widget wraps itself in a [FormField] so
/// it participates in ancestor [Form] validation, saving, and auto-validate
/// flows. The manually supplied [error] takes precedence over the form-field
/// error text.
///
/// {@category Components}
class OiDatePickerField extends StatelessWidget {
  /// Creates an [OiDatePickerField].
  const OiDatePickerField({
    this.value,
    this.onChanged,
    this.minDate,
    this.maxDate,
    this.selectableDayPredicate,
    this.label,
    this.hint,
    this.placeholder,
    this.error,
    this.dateFormat,
    this.clearable = false,
    this.enabled = true,
    this.readOnly = false,
    this.validator,
    this.onSaved,
    this.autovalidateMode,
    this.semanticLabel,
    super.key,
  });

  /// The currently selected date, or `null` if no date is selected.
  final DateTime? value;

  /// Called when the user selects or clears a date.
  final ValueChanged<DateTime?>? onChanged;

  /// The earliest selectable date.
  final DateTime? minDate;

  /// The latest selectable date.
  final DateTime? maxDate;

  /// Optional predicate that returns `true` for selectable days.
  ///
  /// Days for which this returns `false` are visually disabled in the
  /// calendar. Note: the underlying `OiDatePicker` constrains via
  /// `firstDate`/`lastDate`; this predicate is reserved for future use.
  final bool Function(DateTime)? selectableDayPredicate;

  /// Optional label rendered above the input frame.
  final String? label;

  /// Optional hint rendered below the input frame when no error is present.
  final String? hint;

  /// Placeholder text shown when no [value] is selected.
  final String? placeholder;

  /// Manual validation error message.
  ///
  /// When non-null this takes precedence over the error produced by
  /// [validator].
  final String? error;

  /// Date format pattern string (e.g. `'yyyy-MM-dd'`).
  ///
  /// Defaults to `'MMM d, yyyy'` which renders dates like "Mar 23, 2026".
  final String? dateFormat;

  /// When `true` and a [value] is set, a small clear icon appears allowing
  /// the user to reset the field to `null`.
  final bool clearable;

  /// Whether the field accepts interaction.
  final bool enabled;

  /// Whether the field is read-only (visually distinct from disabled).
  final bool readOnly;

  /// Validation function called by ancestor `Form.validate()`.
  ///
  /// Return `null` when valid, or an error string when invalid. When
  /// non-null, the widget internally wraps with `FormField<DateTime>`.
  final String? Function(DateTime?)? validator;

  /// Called by `Form.save()` with the current value.
  final void Function(DateTime?)? onSaved;

  /// Controls when validation runs automatically.
  final AutovalidateMode? autovalidateMode;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  String _formatDate(DateTime date) {
    final pattern = dateFormat ?? 'MMM d, yyyy';
    return DateFormat(pattern).format(date);
  }

  Future<void> _openPicker(BuildContext context) async {
    if (!enabled || readOnly) return;

    final selected = await OiDatePicker.show(
      context,
      initialDate: value,
      firstDate: minDate,
      lastDate: maxDate,
      semanticLabel: semanticLabel ?? 'Select date',
    );

    if (selected != null) {
      onChanged?.call(selected);
    }
  }

  void _clear() {
    onChanged?.call(null);
  }

  Widget _buildField(BuildContext context, String? resolvedError) {
    final colors = context.colors;
    final hasValue = value != null;
    final displayText =
        hasValue ? _formatDate(value!) : (placeholder ?? 'Select date');

    final trailing = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (clearable && hasValue && enabled && !readOnly)
          OiTappable(
            onTap: _clear,
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                OiIcons.x,
                size: 16,
                color: colors.textMuted,
              ),
            ),
          ),
        Icon(
          OiIcons.calendarDays,
          size: 18,
          color: colors.textMuted,
        ),
      ],
    );

    Widget field = GestureDetector(
      onTap: enabled && !readOnly ? () => _openPicker(context) : null,
      behavior: HitTestBehavior.opaque,
      child: OiInputFrame(
        label: label,
        hint: hint,
        error: resolvedError,
        enabled: enabled,
        readOnly: readOnly,
        trailing: trailing,
        child: Text(
          displayText,
          style: TextStyle(
            fontSize: 14,
            color: hasValue ? colors.text : colors.textMuted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    if (semanticLabel != null) {
      field = Semantics(label: semanticLabel, child: field);
    }

    return field;
  }

  @override
  Widget build(BuildContext context) {
    if (validator != null) {
      return FormField<DateTime>(
        validator: validator,
        autovalidateMode: autovalidateMode,
        onSaved: onSaved,
        initialValue: value,
        builder: (FormFieldState<DateTime> state) {
          final resolvedError = error ?? state.errorText;
          return _buildField(context, resolvedError);
        },
      );
    }

    return _buildField(context, error);
  }
}
