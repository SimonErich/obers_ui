import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/components/inputs/oi_time_input.dart'
    show OiTimeOfDay;
import 'package:obers_ui/src/components/navigation/oi_time_picker.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A time input field that displays a formatted time and opens an
/// [OiTimePicker] dialog when tapped.
///
/// The field renders an [OiInputFrame] with a read-only display of the
/// formatted [value] and a trailing clock icon. Tapping the field opens
/// an [OiTimePicker] dialog. When the user selects a time the dialog
/// closes and [onChanged] fires with the chosen [OiTimeOfDay].
///
/// When [use24Hour] is `true` (the default), time is displayed as `14:30`;
/// otherwise as `2:30 PM`.
///
/// When [clearable] is `true` and a [value] is set, a small clear button
/// appears before the clock icon.
///
/// When [validator] is non-null the widget wraps itself in a [FormField] so
/// it participates in ancestor [Form] validation, saving, and auto-validate
/// flows. The manually supplied [error] takes precedence over the form-field
/// error text.
///
/// {@category Components}
class OiTimePickerField extends StatelessWidget {
  /// Creates an [OiTimePickerField].
  const OiTimePickerField({
    this.value,
    this.onChanged,
    this.minTime,
    this.maxTime,
    this.minuteInterval = 1,
    this.label,
    this.hint,
    this.placeholder,
    this.error,
    this.use24Hour = true,
    this.clearable = false,
    this.enabled = true,
    this.validator,
    this.onSaved,
    this.autovalidateMode,
    this.semanticLabel,
    super.key,
  });

  /// The currently selected time, or `null` if no time is selected.
  final OiTimeOfDay? value;

  /// Called when the user selects or clears a time.
  final ValueChanged<OiTimeOfDay?>? onChanged;

  /// The earliest selectable time.
  ///
  /// Reserved for future use — the underlying [OiTimePicker] does not
  /// currently constrain by min/max time.
  final OiTimeOfDay? minTime;

  /// The latest selectable time.
  ///
  /// Reserved for future use — the underlying [OiTimePicker] does not
  /// currently constrain by min/max time.
  final OiTimeOfDay? maxTime;

  /// The granularity of minute selection.
  ///
  /// Reserved for future use — the underlying [OiTimePicker] does not
  /// currently support minute intervals.
  final int minuteInterval;

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

  /// When `true` the time is displayed in 24-hour format (e.g. `14:30`);
  /// otherwise in 12-hour format with AM/PM (e.g. `2:30 PM`).
  final bool use24Hour;

  /// When `true` and a [value] is set, a small clear icon appears allowing
  /// the user to reset the field to `null`.
  final bool clearable;

  /// Whether the field accepts interaction.
  final bool enabled;

  /// Validation function called by ancestor `Form.validate()`.
  ///
  /// Return `null` when valid, or an error string when invalid. When
  /// non-null, the widget internally wraps with `FormField<OiTimeOfDay>`.
  final String? Function(OiTimeOfDay?)? validator;

  /// Called by `Form.save()` with the current value.
  final void Function(OiTimeOfDay?)? onSaved;

  /// Controls when validation runs automatically.
  final AutovalidateMode? autovalidateMode;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  String _formatTime(OiTimeOfDay time) {
    if (use24Hour) {
      return '${time.hour.toString().padLeft(2, '0')}:'
          '${time.minute.toString().padLeft(2, '0')}';
    }
    final h = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final ampm = time.hour < 12 ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')} $ampm';
  }

  Future<void> _openPicker(BuildContext context) async {
    if (!enabled) return;

    final selected = await OiTimePicker.show(
      context,
      initialTime: value,
      use24Hour: use24Hour,
      semanticLabel: semanticLabel ?? 'Select time',
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
        hasValue ? _formatTime(value!) : (placeholder ?? 'Select time');

    final trailing = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (clearable && hasValue && enabled)
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
          OiIcons.clock,
          size: 18,
          color: colors.textMuted,
        ),
      ],
    );

    Widget field = GestureDetector(
      onTap: enabled ? () => _openPicker(context) : null,
      behavior: HitTestBehavior.opaque,
      child: OiInputFrame(
        label: label,
        hint: hint,
        error: resolvedError,
        enabled: enabled,
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
      return FormField<OiTimeOfDay>(
        validator: validator,
        autovalidateMode: autovalidateMode,
        onSaved: onSaved,
        initialValue: value,
        builder: (state) {
          final resolvedError = error ?? state.errorText;
          return _buildField(context, resolvedError);
        },
      );
    }

    return _buildField(context, error);
  }
}
