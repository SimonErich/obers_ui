import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inline_edit/oi_editable.dart';
import 'package:obers_ui/src/components/inputs/oi_date_input.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// An inline-editable date field that toggles between a formatted date label
/// and an [OiDateInput] picker.
///
/// In display mode the date is rendered as formatted text using [dateFormat]
/// (default `'yyyy-MM-dd'`). Tapping enters edit mode. Selecting a date
/// commits the edit immediately.
///
/// {@category Components}
class OiEditableDate extends StatelessWidget {
  /// Creates an [OiEditableDate].
  const OiEditableDate({
    this.value,
    this.onChanged,
    this.enabled = true,
    this.dateFormat,
    super.key,
  });

  /// The currently selected date.
  final DateTime? value;

  /// Called when the user commits a new date.
  final ValueChanged<DateTime?>? onChanged;

  /// Whether editing is enabled.
  final bool enabled;

  /// Date format string, e.g. `'yyyy-MM-dd'`. Defaults to `'yyyy-MM-dd'`.
  final String? dateFormat;

  String _formatDate(DateTime d) {
    final fmt = dateFormat ?? 'yyyy-MM-dd';
    return fmt
        .replaceAll('yyyy', d.year.toString().padLeft(4, '0'))
        .replaceAll('MM', d.month.toString().padLeft(2, '0'))
        .replaceAll('dd', d.day.toString().padLeft(2, '0'));
  }

  @override
  Widget build(BuildContext context) {
    return OiEditable<DateTime?>(
      value: value,
      onChanged: onChanged,
      enabled: enabled,
      displayBuilder: (ctx, v, startEdit) {
        final colors = ctx.colors;
        final label = v != null ? _formatDate(v) : '—';
        return GestureDetector(
          onTap: enabled ? startEdit : null,
          behavior: HitTestBehavior.opaque,
          child: MouseRegion(
            cursor: enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: colors.text),
            ),
          ),
        );
      },
      editBuilder: (ctx, v, commit, cancel) {
        return OiDateInput(
          value: v,
          dateFormat: dateFormat,
          enabled: enabled,
          onChanged: (newVal) => commit(newVal),
        );
      },
    );
  }
}
