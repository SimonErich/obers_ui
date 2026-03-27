import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/components/inputs/oi_date_range_picker_field.dart';
import 'package:obers_ui/src/components/overlays/oi_dialog_shell.dart';
import 'package:obers_ui/src/composites/scheduling/oi_date_range_picker.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// Date range input field that opens [OiDateRangePicker] in a dialog.
///
/// Drop-in for forms — follows the same API pattern as `OiDateInput`.
///
/// {@category Composites}
class OiDateRangeInput extends StatelessWidget {
  /// Creates an [OiDateRangeInput].
  const OiDateRangeInput({
    required this.label,
    this.startDate,
    this.endDate,
    this.onChanged,
    this.presets,
    this.firstDate,
    this.lastDate,
    this.hint,
    this.error,
    this.enabled = true,
    this.required = false,
    this.clearable = true,
    this.displayFormat,
    this.semanticLabel,
    super.key,
  });

  /// Label rendered above the input frame.
  final String label;

  /// The start of the currently selected date range.
  final DateTime? startDate;

  /// The end of the currently selected date range.
  final DateTime? endDate;

  /// Called when the user selects or clears a date range.
  ///
  /// Receives `(start, end)` when applied, or `(null, null)` when cleared.
  final void Function(DateTime? start, DateTime? end)? onChanged;

  /// Quick-select presets shown in the picker dialog.
  final List<OiDateRangePreset>? presets;

  /// Earliest selectable date.
  final DateTime? firstDate;

  /// Latest selectable date.
  final DateTime? lastDate;

  /// Hint text shown when no range is selected.
  final String? hint;

  /// Error message rendered below the input frame.
  final String? error;

  /// Whether the field accepts interaction.
  final bool enabled;

  /// When `true`, a required asterisk is appended to the [label].
  final bool required;

  /// When `true` and a range is set, a clear icon is shown.
  final bool clearable;

  /// Custom formatter for the displayed date range text.
  ///
  /// When `null`, defaults to "MMM d – MMM d, yyyy" (compact same-year) or
  /// "MMM d, yyyy – MMM d, yyyy" (cross-year).
  final String Function(DateTime start, DateTime end)? displayFormat;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  // ── Formatting ──────────────────────────────────────────────────────────

  String _formatRange(DateTime start, DateTime end) {
    if (displayFormat != null) return displayFormat!(start, end);

    if (start.year == end.year) {
      final startStr = DateFormat('MMM d').format(start);
      final endStr = DateFormat('MMM d, yyyy').format(end);
      return '$startStr \u2013 $endStr';
    }
    final fmt = DateFormat('MMM d, yyyy');
    return '${fmt.format(start)} \u2013 ${fmt.format(end)}';
  }

  // ── Dialog ──────────────────────────────────────────────────────────────

  Future<void> _openDialog(BuildContext context) async {
    if (!enabled) return;

    final result = await OiDialogShell.show<(DateTime, DateTime)>(
      context: context,
      semanticLabel: semanticLabel ?? label,
      builder: (close) => OiDateRangePicker(
        label: label,
        startDate: startDate,
        endDate: endDate,
        presets: presets,
        firstDate: firstDate,
        lastDate: lastDate,
        onApply: (start, end) => close((start, end)),
        onCancel: () => close(),
      ),
    );

    if (result != null) {
      onChanged?.call(result.$1, result.$2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasValue = startDate != null && endDate != null;
    final displayText = hasValue
        ? _formatRange(startDate!, endDate!)
        : (hint ?? 'Select date range');
    final effectiveLabel = required ? '$label *' : label;

    final trailing = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (clearable && hasValue && enabled)
          OiTappable(
            onTap: () => onChanged?.call(null, null),
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(OiIcons.x, size: 16, color: colors.textMuted),
            ),
          ),
        Icon(OiIcons.calendarRange, size: 18, color: colors.textMuted),
      ],
    );

    Widget field = GestureDetector(
      onTap: enabled ? () => _openDialog(context) : null,
      behavior: HitTestBehavior.opaque,
      child: OiInputFrame(
        label: effectiveLabel,
        hint: hint,
        error: error,
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
}
