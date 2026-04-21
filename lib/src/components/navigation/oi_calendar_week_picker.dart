import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/navigation/oi_month_picker.dart';
import 'package:obers_ui/src/components/overlays/oi_dialog_shell.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/utils/calendar_utils.dart';

/// A calendar week identified by ISO week number and year.
@immutable
class OiCalendarWeek {
  /// Creates an [OiCalendarWeek].
  const OiCalendarWeek({required this.week, required this.year});

  /// Creates an [OiCalendarWeek] from a [DateTime].
  factory OiCalendarWeek.fromDateTime(DateTime date) {
    final week = OiCalendarUtils.weekNumber(date);
    // ISO week year: week 1 may belong to the previous/next year.
    var year = date.year;
    if (week >= 52 && date.month == 1) year--;
    if (week == 1 && date.month == 12) year++;
    return OiCalendarWeek(week: week, year: year);
  }

  /// The ISO week number (1–53).
  final int week;

  /// The year this week belongs to (ISO week year).
  final int year;

  /// Default format: "KW {week} ({year})".
  String format() => 'KW $week ($year)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiCalendarWeek && other.week == week && other.year == year;

  @override
  int get hashCode => Object.hash(week, year);

  @override
  String toString() =>
      'OiCalendarWeek($year-W${week.toString().padLeft(2, '0')})';
}

/// A calendar-week picker with a scrollable wheel.
///
/// Displays a [ListWheelScrollView] of weeks (1–52/53) that snaps to discrete
/// values. The year is derived from [value] (or the current year when null).
/// Highlighted weeks are rendered with a tinted background.
///
/// {@category Components}
class OiCalendarWeekPicker extends StatefulWidget {
  /// Creates an [OiCalendarWeekPicker].
  const OiCalendarWeekPicker({
    this.value,
    this.onChanged,
    this.highlightedWeeks,
    this.weekFormatter,
    super.key,
  });

  /// The currently selected calendar week.
  final OiCalendarWeek? value;

  /// Called whenever the selected week changes.
  final ValueChanged<OiCalendarWeek>? onChanged;

  /// Weeks to visually highlight in the picker (e.g. weeks with data).
  final Set<OiCalendarWeek>? highlightedWeeks;

  /// Custom formatter for week labels. Receives the week number and year,
  /// returns the display string.
  ///
  /// Defaults to "KW {week} ({year})".
  final String Function(int week, int year)? weekFormatter;

  /// Shows a calendar week picker in a dialog and returns the selected week.
  ///
  /// Returns `null` if the dialog is dismissed without selecting a week.
  static Future<OiCalendarWeek?> show(
    BuildContext context, {
    OiCalendarWeek? initialValue,
    Set<OiCalendarWeek>? highlightedWeeks,
    String Function(int week, int year)? weekFormatter,
    String semanticLabel = 'Select calendar week',
  }) {
    return OiDialogShell.show<OiCalendarWeek>(
      context: context,
      semanticLabel: semanticLabel,
      width: 280,
      builder: (close) => _OiCalendarWeekPickerDialog(
        initialValue: initialValue,
        highlightedWeeks: highlightedWeeks,
        weekFormatter: weekFormatter,
        onConfirm: close,
      ),
    );
  }

  @override
  State<OiCalendarWeekPicker> createState() => _OiCalendarWeekPickerState();
}

class _OiCalendarWeekPickerState extends State<OiCalendarWeekPicker> {
  late int _week; // 1-based
  late int _year;
  late int _weeksInYear;

  late FixedExtentScrollController _weekCtrl;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final ref = widget.value ?? OiCalendarWeek.fromDateTime(now);
    _year = ref.year;
    _weeksInYear = _isoWeeksInYear(_year);
    _week = ref.week.clamp(1, _weeksInYear);

    _weekCtrl = FixedExtentScrollController(initialItem: _week - 1);
  }

  @override
  void didUpdateWidget(OiCalendarWeekPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != null) {
      final newYear = widget.value!.year;
      final newWeeksInYear = _isoWeeksInYear(newYear);
      final newWeek = widget.value!.week.clamp(1, newWeeksInYear);
      if (newYear != _year || newWeek != _week) {
        setState(() {
          _year = newYear;
          _weeksInYear = newWeeksInYear;
          _week = newWeek;
        });
        // Jump to the new week in the wheel.
        _weekCtrl.jumpToItem(_week - 1);
      }
    }
  }

  @override
  void dispose() {
    _weekCtrl.dispose();
    super.dispose();
  }

  String _formatWeek(int week, int year) {
    if (widget.weekFormatter != null) return widget.weekFormatter!(week, year);
    return 'KW $week ($year)';
  }

  bool _isHighlighted(int week, int year) {
    if (widget.highlightedWeeks == null) return false;
    return widget.highlightedWeeks!.contains(
      OiCalendarWeek(week: week, year: year),
    );
  }

  void _onWeekChanged(int index) {
    setState(() => _week = index + 1);
    widget.onChanged?.call(OiCalendarWeek(week: _week, year: _year));
  }

  static int _isoWeeksInYear(int year) {
    final dec28 = DateTime.utc(year, 12, 28);
    final dayOfYear = dec28.difference(DateTime.utc(year)).inDays + 1;
    return ((dayOfYear - dec28.weekday + 10) / 7).floor();
  }

  @override
  Widget build(BuildContext context) {
    const itemExtent = 32.0;
    const visibleItems = 5;
    const pickerHeight = itemExtent * visibleItems;

    return SizedBox(
      width: 200,
      height: pickerHeight,
      child: ListWheelScrollView.useDelegate(
        controller: _weekCtrl,
        itemExtent: itemExtent,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: _onWeekChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: _weeksInYear,
          builder: (ctx, index) {
            final w = index + 1;
            return _WeekWheelItem(
              label: _formatWeek(w, _year),
              selected: w == _week,
              highlighted: _isHighlighted(w, _year),
              onTap: () => _weekCtrl.animateToItem(
                index,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Wheel item with selected/highlighted styling ─────────────────────────────

class _WeekWheelItem extends StatefulWidget {
  const _WeekWheelItem({
    required this.label,
    required this.selected,
    this.highlighted = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  State<_WeekWheelItem> createState() => _WeekWheelItemState();
}

class _WeekWheelItemState extends State<_WeekWheelItem> {
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
    } else if (widget.highlighted) {
      bg = colors.primary.base.withValues(alpha: 0.15);
      textColor = colors.primary.base;
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

// ── Dialog wrapper ───────────────────────────────────────────────────────────

class _OiCalendarWeekPickerDialog extends StatefulWidget {
  const _OiCalendarWeekPickerDialog({
    required this.onConfirm,
    this.initialValue,
    this.highlightedWeeks,
    this.weekFormatter,
  });

  final OiCalendarWeek? initialValue;
  final Set<OiCalendarWeek>? highlightedWeeks;
  final String Function(int week, int year)? weekFormatter;
  final void Function([OiCalendarWeek?]) onConfirm;

  @override
  State<_OiCalendarWeekPickerDialog> createState() =>
      _OiCalendarWeekPickerDialogState();
}

class _OiCalendarWeekPickerDialogState
    extends State<_OiCalendarWeekPickerDialog> {
  late OiCalendarWeek _current;

  @override
  void initState() {
    super.initState();
    _current =
        widget.initialValue ?? OiCalendarWeek.fromDateTime(DateTime.now());
  }

  Future<void> _openMonthPicker() async {
    final result = await OiMonthPicker.show(
      context,
      initialValue: OiMonth(year: _current.year, month: 1),
    );
    if (result == null) return;
    // Switch to the selected year, keep week clamped.
    final maxWeeks = _isoWeeksInYear(result.year);
    setState(() {
      _current = OiCalendarWeek(
        week: _current.week.clamp(1, maxWeeks),
        year: result.year,
      );
    });
  }

  static int _isoWeeksInYear(int year) {
    final dec28 = DateTime.utc(year, 12, 28);
    final dayOfYear = dec28.difference(DateTime.utc(year)).inDays + 1;
    return ((dayOfYear - dec28.weekday + 10) / 7).floor();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OiCalendarWeekPicker(
            value: _current,
            highlightedWeeks: widget.highlightedWeeks,
            weekFormatter: widget.weekFormatter,
            onChanged: (value) => setState(() => _current = value),
          ),
          const SizedBox(height: 8),
          // Year navigation label (opens month picker for year selection).
          _YearLabel(
            year: _current.year,
            onTap: _openMonthPicker,
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

// ── Year label with prev/next arrows ─────────────────────────────────────────

class _YearLabel extends StatefulWidget {
  const _YearLabel({required this.year, required this.onTap});

  final int year;
  final VoidCallback onTap;

  @override
  State<_YearLabel> createState() => _YearLabelState();
}

class _YearLabelState extends State<_YearLabel> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = _hovered ? colors.primary.base : colors.textMuted;

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.year}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Icon(OiIcons.chevronDown, size: 12, color: color),
          ],
        ),
      ),
    );
  }
}
