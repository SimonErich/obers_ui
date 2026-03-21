import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inputs/oi_date_input.dart';
import 'package:obers_ui/src/components/inputs/oi_time_input.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

/// A combined date + time input that renders [OiDateInput] and [OiTimeInput]
/// side by side within a single form field sharing one label and one error
/// message.
///
/// Changing the date portion updates the date part of the [DateTime] value;
/// changing the time portion updates the time part. When [value] is `null` and
/// one half is set, the other half defaults to today / 00:00.
///
/// {@category Components}
class OiDateTimeInput extends StatefulWidget {
  /// Creates an [OiDateTimeInput].
  const OiDateTimeInput({
    this.value,
    this.onChanged,
    this.label,
    this.hint,
    this.error,
    this.min,
    this.max,
    this.required = false,
    this.readOnly = false,
    this.enabled = true,
    super.key,
  });

  /// The currently selected date and time.
  final DateTime? value;

  /// Called when the user changes the date or time portion.
  final ValueChanged<DateTime?>? onChanged;

  /// Optional label rendered above the input pair.
  final String? label;

  /// Optional hint rendered below the input pair when no error is present.
  final String? hint;

  /// Validation error message rendered below the input pair.
  final String? error;

  /// The earliest selectable date-time.
  final DateTime? min;

  /// The latest selectable date-time.
  final DateTime? max;

  /// Whether the field is required. Renders an asterisk next to the label.
  final bool required;

  /// Whether the field is read-only (visually distinct from disabled).
  final bool readOnly;

  /// Whether the field accepts interaction.
  final bool enabled;

  @override
  State<OiDateTimeInput> createState() => _OiDateTimeInputState();
}

class _OiDateTimeInputState extends State<OiDateTimeInput> {
  DateTime? _extractDate(DateTime? dt) {
    if (dt == null) return null;
    return DateTime(dt.year, dt.month, dt.day);
  }

  OiTimeOfDay? _extractTime(DateTime? dt) {
    if (dt == null) return null;
    return OiTimeOfDay(hour: dt.hour, minute: dt.minute);
  }

  DateTime? _mergeDateTime(DateTime? date, OiTimeOfDay? time) {
    if (date == null && time == null) return null;
    final d = date ?? DateTime.now();
    final t = time ?? const OiTimeOfDay(hour: 0, minute: 0);
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  DateTime _clampDateTime(DateTime dt) {
    if (widget.min != null && dt.isBefore(widget.min!)) return widget.min!;
    if (widget.max != null && dt.isAfter(widget.max!)) return widget.max!;
    return dt;
  }

  void _handleDateChanged(DateTime? date) {
    if (widget.onChanged == null) return;
    final existingTime = _extractTime(widget.value);
    final merged = _mergeDateTime(date, existingTime);
    if (merged == null) {
      widget.onChanged!(null);
      return;
    }
    widget.onChanged!(_clampDateTime(merged));
  }

  void _handleTimeChanged(OiTimeOfDay? time) {
    if (widget.onChanged == null) return;
    final existingDate = _extractDate(widget.value);
    final merged = _mergeDateTime(existingDate, time);
    if (merged == null) {
      widget.onChanged!(null);
      return;
    }
    widget.onChanged!(_clampDateTime(merged));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = widget.error != null && widget.error!.isNotEmpty;
    final effectiveEnabled = widget.enabled && !widget.readOnly;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OiLabel.small(widget.label!),
              if (widget.required)
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(
                    '*',
                    style: TextStyle(fontSize: 12, color: colors.error.base),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        Row(
          children: [
            Expanded(
              child: OiDateInput(
                value: _extractDate(widget.value),
                onChanged: _handleDateChanged,
                firstDate: widget.min,
                lastDate: widget.max,
                enabled: effectiveEnabled,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OiTimeInput(
                value: _extractTime(widget.value),
                onChanged: _handleTimeChanged,
                enabled: effectiveEnabled,
              ),
            ),
          ],
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                const IconData(0xe000, fontFamily: 'MaterialIcons'),
                size: 14,
                color: colors.error.base,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  widget.error!,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.error.base,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ] else if (widget.hint != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.hint!,
            style: TextStyle(
              fontSize: 12,
              color: colors.textMuted,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }
}
