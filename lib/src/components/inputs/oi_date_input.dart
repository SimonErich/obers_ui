import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:obers_ui/src/primitives/overlay/oi_floating.dart'
    show OiFloating;

/// A date-picker input that displays a formatted date and opens an overlay
/// picker when tapped.
///
/// The picker overlay presents three [ListWheelScrollView] columns — year,
/// month, and day — so no Material dependency is required.
///
/// {@category Components}
class OiDateInput extends StatefulWidget {
  /// Creates an [OiDateInput].
  const OiDateInput({
    this.value,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.label,
    this.hint,
    this.error,
    this.enabled = true,
    this.dateFormat,
    super.key,
  });

  /// The currently selected date.
  final DateTime? value;

  /// Called when the user selects a date.
  final ValueChanged<DateTime?>? onChanged;

  /// The earliest selectable date.
  final DateTime? firstDate;

  /// The latest selectable date.
  final DateTime? lastDate;

  /// Optional label rendered above the frame.
  final String? label;

  /// Optional hint rendered below the frame.
  final String? hint;

  /// Validation error message.
  final String? error;

  /// Whether the field accepts interaction.
  final bool enabled;

  /// Date format string, e.g. `'yyyy-MM-dd'`. Defaults to `'yyyy-MM-dd'`.
  final String? dateFormat;

  @override
  State<OiDateInput> createState() => _OiDateInputState();
}

class _OiDateInputState extends State<OiDateInput> {
  bool _open = false;

  // Picker scroll state.
  late int _pickerYear;
  late int _pickerMonth;
  late int _pickerDay;

  late FixedExtentScrollController _yearCtrl;
  late FixedExtentScrollController _monthCtrl;
  late FixedExtentScrollController _dayCtrl;

  // Derived year range.
  int get _firstYear => (widget.firstDate ?? DateTime(1900)).year;
  int get _lastYear => (widget.lastDate ?? DateTime(2100)).year;
  int get _yearCount => _lastYear - _firstYear + 1;

  @override
  void initState() {
    super.initState();
    final ref = widget.value ?? DateTime.now();
    _pickerYear = ref.year.clamp(_firstYear, _lastYear);
    _pickerMonth = ref.month;
    _pickerDay = ref.day;
    _initControllers();
  }

  void _initControllers() {
    _yearCtrl = FixedExtentScrollController(
      initialItem: _pickerYear - _firstYear,
    );
    _monthCtrl = FixedExtentScrollController(initialItem: _pickerMonth - 1);
    _dayCtrl = FixedExtentScrollController(initialItem: _pickerDay - 1);
  }

  @override
  void dispose() {
    _yearCtrl.dispose();
    _monthCtrl.dispose();
    _dayCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    final fmt = widget.dateFormat ?? 'yyyy-MM-dd';
    return fmt
        .replaceAll('yyyy', d.year.toString().padLeft(4, '0'))
        .replaceAll('MM', d.month.toString().padLeft(2, '0'))
        .replaceAll('dd', d.day.toString().padLeft(2, '0'));
  }

  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  void _confirmPicker() {
    final days = _daysInMonth(_pickerYear, _pickerMonth);
    final day = _pickerDay.clamp(1, days);
    widget.onChanged?.call(DateTime(_pickerYear, _pickerMonth, day));
    setState(() => _open = false);
  }

  void _cancelPicker() {
    setState(() => _open = false);
  }

  Widget _buildPicker(BuildContext context) {
    final colors = context.colors;
    const itemExtent = 40.0;
    const visibleItems = 5;
    const pickerHeight = itemExtent * visibleItems;
    final months = List.generate(12, (i) => i + 1);

    Widget column(
      int itemCount,
      String Function(int) label,
      FixedExtentScrollController ctrl,
      void Function(int) onChanged,
    ) {
      return SizedBox(
        width: 70,
        height: pickerHeight,
        child: ListWheelScrollView.useDelegate(
          controller: ctrl,
          itemExtent: itemExtent,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: onChanged,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: itemCount,
            builder: (context, index) => Center(
              child: Text(
                label(index),
                style: TextStyle(fontSize: 16, color: colors.text),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.overlay,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              column(
                _yearCount,
                (i) => (_firstYear + i).toString(),
                _yearCtrl,
                (i) => setState(() => _pickerYear = _firstYear + i),
              ),
              const SizedBox(width: 8),
              column(
                months.length,
                (i) => (i + 1).toString().padLeft(2, '0'),
                _monthCtrl,
                (i) => setState(() => _pickerMonth = i + 1),
              ),
              const SizedBox(width: 8),
              column(
                _daysInMonth(_pickerYear, _pickerMonth),
                (i) => (i + 1).toString().padLeft(2, '0'),
                _dayCtrl,
                (i) => setState(() => _pickerDay = i + 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OiTappable(
                onTap: _cancelPicker,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colors.textMuted),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OiTappable(
                onTap: _confirmPicker,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: colors.primary.base,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final displayText = widget.value != null ? _formatDate(widget.value!) : '';

    final calendarIcon = Icon(
      OiIcons.calendarDays,
      size: 18,
      color: colors.textMuted,
    );

    final anchor = GestureDetector(
      onTap: widget.enabled ? () => setState(() => _open = !_open) : null,
      behavior: HitTestBehavior.opaque,
      child: OiInputFrame(
        label: widget.label,
        hint: widget.hint,
        error: widget.error,
        focused: _open,
        enabled: widget.enabled,
        trailing: calendarIcon,
        child: Text(
          displayText,
          style: TextStyle(
            fontSize: 14,
            color: displayText.isEmpty ? colors.textMuted : colors.text,
          ),
        ),
      ),
    );

    return OiFloating(
      visible: _open,
      anchor: anchor,
      child: UnconstrainedBox(
        alignment: Alignment.topLeft,
        child: _buildPicker(context),
      ),
    );
  }
}
