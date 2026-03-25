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

  late ScrollController _yearCtrl;
  late ScrollController _monthCtrl;
  late ScrollController _dayCtrl;

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

  static const double _itemHeight = 36;
  static const int _visibleItems = 5;
  static const double _centerOffset = (_visibleItems ~/ 2) * _itemHeight;

  void _initControllers() {
    _yearCtrl = ScrollController(
      initialScrollOffset:
          ((_pickerYear - _firstYear) * _itemHeight - _centerOffset)
              .clamp(0.0, double.infinity),
    );
    _monthCtrl = ScrollController(
      initialScrollOffset:
          ((_pickerMonth - 1) * _itemHeight - _centerOffset)
              .clamp(0.0, double.infinity),
    );
    _dayCtrl = ScrollController(
      initialScrollOffset:
          ((_pickerDay - 1) * _itemHeight - _centerOffset)
              .clamp(0.0, double.infinity),
    );
  }

  @override
  void didUpdateWidget(OiDateInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_open) {
      final ref = widget.value ?? DateTime.now();
      _pickerYear = ref.year.clamp(_firstYear, _lastYear);
      _pickerMonth = ref.month;
      _pickerDay = ref.day;
    }
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

  void _togglePicker() {
    if (_open) {
      setState(() => _open = false);
      return;
    }
    // Re-initialise controllers so the wheels reflect the current value.
    _yearCtrl.dispose();
    _monthCtrl.dispose();
    _dayCtrl.dispose();
    final ref = widget.value ?? DateTime.now();
    _pickerYear = ref.year.clamp(_firstYear, _lastYear);
    _pickerMonth = ref.month;
    _pickerDay = ref.day;
    _initControllers();
    setState(() => _open = true);
  }

  Widget _buildPickerColumn({
    required BuildContext context,
    required int itemCount,
    required String Function(int) label,
    required int selectedIndex,
    required void Function(int) onSelected,
    required ScrollController scrollCtrl,
  }) {
    final colors = context.colors;
    const itemHeight = 36.0;
    const visibleItems = 5;
    const columnHeight = itemHeight * visibleItems;

    return SizedBox(
      width: 70,
      height: columnHeight,
      child: ListView.builder(
        controller: scrollCtrl,
        itemCount: itemCount,
        itemExtent: itemHeight,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return OiTappable(
            onTap: () => onSelected(index),
            child: Container(
              height: itemHeight,
              alignment: Alignment.center,
              decoration: isSelected
                  ? BoxDecoration(
                      color: colors.primary.base.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    )
                  : null,
              child: Text(
                label(index),
                style: TextStyle(
                  fontSize: 15,
                  color: isSelected ? colors.primary.base : colors.text,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPicker(BuildContext context) {
    final colors = context.colors;

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
              _buildPickerColumn(
                context: context,
                itemCount: _yearCount,
                label: (i) => (_firstYear + i).toString(),
                selectedIndex: _pickerYear - _firstYear,
                onSelected: (i) =>
                    setState(() => _pickerYear = _firstYear + i),
                scrollCtrl: _yearCtrl,
              ),
              const SizedBox(width: 8),
              _buildPickerColumn(
                context: context,
                itemCount: 12,
                label: (i) => (i + 1).toString().padLeft(2, '0'),
                selectedIndex: _pickerMonth - 1,
                onSelected: (i) => setState(() => _pickerMonth = i + 1),
                scrollCtrl: _monthCtrl,
              ),
              const SizedBox(width: 8),
              _buildPickerColumn(
                context: context,
                itemCount: _daysInMonth(_pickerYear, _pickerMonth),
                label: (i) => (i + 1).toString().padLeft(2, '0'),
                selectedIndex: _pickerDay - 1,
                onSelected: (i) => setState(() => _pickerDay = i + 1),
                scrollCtrl: _dayCtrl,
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
      onTap: widget.enabled ? _togglePicker : null,
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
      onDismiss: _cancelPicker,
      anchor: anchor,
      child: UnconstrainedBox(
        alignment: Alignment.topLeft,
        child: _buildPicker(context),
      ),
    );
  }
}
