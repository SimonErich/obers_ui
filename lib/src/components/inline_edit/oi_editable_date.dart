import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inputs/oi_date_input.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// An inline-editable date field that toggles between a formatted date label
/// and an [OiDateInput] picker.
///
/// In display mode the date is rendered as formatted text using [dateFormat]
/// (default `'yyyy-MM-dd'`). Tapping enters edit mode. Selecting a date
/// commits the edit immediately.
///
/// {@category Components}
class OiEditableDate extends StatefulWidget {
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

  @override
  State<OiEditableDate> createState() => _OiEditableDateState();
}

class _OiEditableDateState extends State<OiEditableDate> {
  bool _editing = false;
  DateTime? _pendingValue;

  String _formatDate(DateTime d) {
    final fmt = widget.dateFormat ?? 'yyyy-MM-dd';
    return fmt
        .replaceAll('yyyy', d.year.toString().padLeft(4, '0'))
        .replaceAll('MM', d.month.toString().padLeft(2, '0'))
        .replaceAll('dd', d.day.toString().padLeft(2, '0'));
  }

  void _startEdit() {
    if (!widget.enabled || _editing) return;
    setState(() {
      _editing = true;
      _pendingValue = widget.value;
    });
  }

  void _handleDateChanged(DateTime? newVal) {
    setState(() => _pendingValue = newVal);
    widget.onChanged?.call(newVal);
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_editing) {
      return OiDateInput(
        value: _pendingValue,
        dateFormat: widget.dateFormat,
        enabled: widget.enabled,
        onChanged: _handleDateChanged,
      );
    }

    final label = widget.value != null ? _formatDate(widget.value!) : '—';
    return OiTappable(
      onTap: _startEdit,
      enabled: widget.enabled,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Text(
          label,
          style: TextStyle(fontSize: 14, color: colors.text),
        ),
      ),
    );
  }
}
