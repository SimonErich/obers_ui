import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/overlays/oi_dialog_shell.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';

/// Month names indexed 0–11 (January–December).
///
/// Shared by [OiMonthPicker] and [OiDatePicker].
const List<String> kOiMonthLabels = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// A month selected from an [OiMonthPicker].
///
/// Holds a [year] and a [month] (1–12).
@immutable
class OiMonth {
  /// Creates an [OiMonth].
  const OiMonth({required this.year, required this.month});

  /// Creates an [OiMonth] from a [DateTime].
  OiMonth.fromDateTime(DateTime dt)
      : year = dt.year,
        month = dt.month;

  /// The year.
  final int year;

  /// The month (1 = January, 12 = December).
  final int month;

  /// Converts to a [DateTime] on the first day of the month.
  DateTime toDateTime() => DateTime(year, month);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiMonth && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => 'OiMonth($year-${month.toString().padLeft(2, '0')})';
}

/// A month-and-year picker with scrollable wheels.
///
/// Displays two [ListWheelScrollView] columns — one for months (Jan–Dec),
/// one for years — that snap to discrete values. Changes are reported
/// continuously via [onChanged] as the user scrolls.
///
/// {@category Components}
class OiMonthPicker extends StatefulWidget {
  /// Creates an [OiMonthPicker].
  const OiMonthPicker({
    this.value,
    this.onChanged,
    this.minYear = 1900,
    this.maxYear = 2100,
    super.key,
  });

  /// The initially selected month and year.
  final OiMonth? value;

  /// Called whenever the selected month/year changes.
  final ValueChanged<OiMonth>? onChanged;

  /// The earliest selectable year. Defaults to 1900.
  final int minYear;

  /// The latest selectable year. Defaults to 2100.
  final int maxYear;

  /// Shows a month picker in a dialog and returns the selected month.
  ///
  /// The dialog stays open while the user scrolls through months and years.
  /// It closes and returns the result when the user taps the confirm button,
  /// or returns `null` if dismissed by tapping outside.
  static Future<OiMonth?> show(
    BuildContext context, {
    OiMonth? initialValue,
    int minYear = 1900,
    int maxYear = 2100,
    String semanticLabel = 'Select month and year',
  }) {
    return OiDialogShell.show<OiMonth>(
      context: context,
      semanticLabel: semanticLabel,
      width: 210,
      builder: (close) => _OiMonthPickerDialog(
        initialValue: initialValue,
        minYear: minYear,
        maxYear: maxYear,
        onConfirm: close,
      ),
    );
  }

  @override
  State<OiMonthPicker> createState() => _OiMonthPickerState();
}

class _OiMonthPickerState extends State<OiMonthPicker> {
  late int _month; // 1-based
  late int _year;

  late FixedExtentScrollController _monthCtrl;
  late FixedExtentScrollController _yearCtrl;

  int get _yearCount => widget.maxYear - widget.minYear + 1;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final ref = widget.value ?? OiMonth(year: now.year, month: now.month);
    _month = ref.month;
    _year = ref.year.clamp(widget.minYear, widget.maxYear);

    _monthCtrl = FixedExtentScrollController(initialItem: _month - 1);
    _yearCtrl = FixedExtentScrollController(initialItem: _year - widget.minYear);
  }

  @override
  void dispose() {
    _monthCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  void _onMonthChanged(int index) {
    setState(() => _month = index + 1);
    widget.onChanged?.call(OiMonth(year: _year, month: _month));
  }

  void _onYearChanged(int index) {
    setState(() => _year = widget.minYear + index);
    widget.onChanged?.call(OiMonth(year: _year, month: _month));
  }

  @override
  Widget build(BuildContext context) {
    const itemExtent = 32.0;
    const visibleItems = 5;
    const pickerHeight = itemExtent * visibleItems;

    Widget wheel({
      required double width,
      required int itemCount,
      required String Function(int) label,
      required FixedExtentScrollController controller,
      required ValueChanged<int> onChanged,
      required int selectedIndex,
    }) {
      return SizedBox(
        width: width,
        height: pickerHeight,
        child: ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: itemExtent,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: onChanged,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: itemCount,
            builder: (ctx, index) => _MonthWheelItem(
              label: label(index),
              selected: index == selectedIndex,
              onTap: () => controller.animateToItem(
                index,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        wheel(
          width: 100,
          itemCount: 12,
          label: (i) => kOiMonthLabels[i],
          controller: _monthCtrl,
          onChanged: _onMonthChanged,
          selectedIndex: _month - 1,
        ),
        const SizedBox(width: 6),
        wheel(
          width: 64,
          itemCount: _yearCount,
          label: (i) => (widget.minYear + i).toString(),
          controller: _yearCtrl,
          onChanged: _onYearChanged,
          selectedIndex: _year - widget.minYear,
        ),
      ],
    );
  }
}

// ── Wheel item with selected highlight and hover ────────────────────────────

class _MonthWheelItem extends StatefulWidget {
  const _MonthWheelItem({
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  State<_MonthWheelItem> createState() => _MonthWheelItemState();
}

class _MonthWheelItemState extends State<_MonthWheelItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selected = widget.selected;

    Color bg;
    Color textColor;
    if (selected) {
      bg = colors.primary.base;
      textColor = colors.textOnPrimary;
    } else if (_hovered) {
      bg = colors.surfaceHover;
      textColor = colors.text;
    } else {
      bg = const Color(0x00000000);
      textColor = colors.text;
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Dialog wrapper that confirms on tap ──────────────────────────────────────

class _OiMonthPickerDialog extends StatefulWidget {
  const _OiMonthPickerDialog({
    required this.onConfirm,
    this.initialValue,
    this.minYear = 1900,
    this.maxYear = 2100,
  });

  final OiMonth? initialValue;
  final int minYear;
  final int maxYear;
  final void Function([OiMonth?]) onConfirm;

  @override
  State<_OiMonthPickerDialog> createState() => _OiMonthPickerDialogState();
}

class _OiMonthPickerDialogState extends State<_OiMonthPickerDialog> {
  late OiMonth _current;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _current =
        widget.initialValue ?? OiMonth(year: now.year, month: now.month);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OiMonthPicker(
            value: _current,
            minYear: widget.minYear,
            maxYear: widget.maxYear,
            onChanged: (value) => setState(() => _current = value),
          ),
          const SizedBox(height: 12),
          const OiDivider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              OiButton.ghost(
                label: 'Cancel',
                size: OiButtonSize.small,
                onTap: () => widget.onConfirm(null),
              ),
              OiButton.primary(
                label: 'OK',
                size: OiButtonSize.small,
                onTap: () => widget.onConfirm(_current),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
