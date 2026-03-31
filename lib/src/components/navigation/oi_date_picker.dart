import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/navigation/oi_month_picker.dart';
import 'package:obers_ui/src/components/overlays/oi_dialog_shell.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// Weekday abbreviations, index 0=Monday ... 6=Sunday (matches DateTime.weekday-1).
const List<String> _kWeekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];


/// A calendar date picker with optional date-range selection.
///
/// Displays a month-view calendar grid. The user can navigate between months
/// with the previous/next arrows. Tapping a day fires [onChanged] with the
/// selected [DateTime].
///
/// When [rangeMode] is `true`, tapping days updates [rangeStart] and
/// [rangeEnd] via [onRangeChanged]. Days between the two endpoints are
/// highlighted. Today's date is marked with an underline dot.
///
/// [firstDate] and [lastDate] constrain the selectable range.
///
/// {@category Components}
class OiDatePicker extends StatefulWidget {
  /// Creates an [OiDatePicker].
  const OiDatePicker({
    this.value,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.rangeStart,
    this.rangeEnd,
    this.onRangeChanged,
    this.rangeMode = false,
    this.displayMonth,
    this.onDisplayMonthChanged,
    this.disabledDates,
    this.disabledDaysOfWeek,
    this.firstDayOfWeek,
    super.key,
  });

  /// The currently selected date (single-selection mode).
  final DateTime? value;

  /// Called when the user selects a day in single-selection mode.
  final ValueChanged<DateTime>? onChanged;

  /// The earliest selectable date.
  final DateTime? firstDate;

  /// The latest selectable date.
  final DateTime? lastDate;

  /// The start of the selected range (range mode).
  final DateTime? rangeStart;

  /// The end of the selected range (range mode).
  final DateTime? rangeEnd;

  /// Called when both range endpoints are selected.
  final void Function(DateTime start, DateTime end)? onRangeChanged;

  /// When `true`, the picker operates in date-range selection mode.
  final bool rangeMode;

  /// Specific dates that cannot be selected. Rendered with muted styling.
  final Set<DateTime>? disabledDates;

  /// Days of the week that cannot be selected (1=Monday, 7=Sunday).
  final Set<int>? disabledDaysOfWeek;

  /// First day of the week (1=Monday, 7=Sunday). Defaults to Sunday.
  final int? firstDayOfWeek;

  /// Externally controlled display month. When provided, the picker shows
  /// this month instead of managing its own display month state.
  final DateTime? displayMonth;

  /// Called when the user navigates to a different month via the
  /// previous/next arrows. Only fires when [displayMonth] is provided,
  /// allowing the parent to update the controlled month.
  final ValueChanged<DateTime>? onDisplayMonthChanged;

  /// Shows a date picker in a dialog and returns the selected date.
  ///
  /// Returns `null` if the dialog is dismissed without selecting a date.
  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String semanticLabel = 'Select date',
  }) {
    return OiDialogShell.show<DateTime>(
      context: context,
      semanticLabel: semanticLabel,
      width: 350,
      initialFocus: false,
      builder: (close) => Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OiDatePicker(
              value: initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
              onChanged: close,
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<OiDatePicker> createState() => _OiDatePickerState();
}

class _OiDatePickerState extends State<OiDatePicker> {
  late DateTime _displayMonth;
  DateTime? _pendingRangeStart;

  bool get _isControlled => widget.displayMonth != null;

  DateTime get _effectiveDisplayMonth {
    if (_isControlled) {
      final dm = widget.displayMonth!;
      return DateTime(dm.year, dm.month);
    }
    return _displayMonth;
  }

  @override
  void initState() {
    super.initState();
    final ref =
        widget.displayMonth ??
        widget.value ??
        widget.rangeStart ??
        DateTime.now();
    _displayMonth = DateTime(ref.year, ref.month);
  }

  @override
  void didUpdateWidget(OiDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isControlled && widget.displayMonth != oldWidget.displayMonth) {
      final dm = widget.displayMonth!;
      _displayMonth = DateTime(dm.year, dm.month);
    }
  }

  void _prevMonth() {
    final prev = DateTime(
      _effectiveDisplayMonth.year,
      _effectiveDisplayMonth.month - 1,
    );
    if (_isControlled) {
      widget.onDisplayMonthChanged?.call(prev);
    } else {
      setState(() => _displayMonth = prev);
    }
  }

  void _nextMonth() {
    final next = DateTime(
      _effectiveDisplayMonth.year,
      _effectiveDisplayMonth.month + 1,
    );
    if (_isControlled) {
      widget.onDisplayMonthChanged?.call(next);
    } else {
      setState(() => _displayMonth = next);
    }
  }

  void _onDayTap(DateTime day) {
    if (widget.rangeMode) {
      if (_pendingRangeStart == null) {
        setState(() => _pendingRangeStart = day);
      } else {
        final start = _pendingRangeStart!;
        final end = day;
        setState(() => _pendingRangeStart = null);
        if (end.isBefore(start)) {
          widget.onRangeChanged?.call(end, start);
        } else {
          widget.onRangeChanged?.call(start, end);
        }
      }
    } else {
      widget.onChanged?.call(day);
    }
  }

  bool _isSelected(DateTime day) {
    if (widget.rangeMode) return false;
    final v = widget.value;
    return v != null && _sameDay(day, v);
  }

  bool _isInRange(DateTime day) {
    final start = widget.rangeStart ?? _pendingRangeStart;
    final end = widget.rangeEnd;
    if (start == null || end == null) return false;
    final d = DateTime(day.year, day.month, day.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  bool _isRangeEndpoint(DateTime day) {
    final start = widget.rangeStart ?? _pendingRangeStart;
    final end = widget.rangeEnd;
    if (start != null && _sameDay(day, start)) return true;
    if (end != null && _sameDay(day, end)) return true;
    return false;
  }

  bool _isDisabled(DateTime day) {
    final first = widget.firstDate;
    final last = widget.lastDate;
    if (first != null && day.isBefore(first)) return true;
    if (last != null && day.isAfter(last)) return true;
    if (widget.disabledDates != null) {
      for (final d in widget.disabledDates!) {
        if (_sameDay(d, day)) return true;
      }
    }
    if (widget.disabledDaysOfWeek != null &&
        widget.disabledDaysOfWeek!.contains(day.weekday)) {
      return true;
    }
    return false;
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _openMonthPicker() async {
    final result = await OiMonthPicker.show(
      context,
      initialValue: OiMonth(
        year: _effectiveDisplayMonth.year,
        month: _effectiveDisplayMonth.month,
      ),
    );
    if (result == null) return;
    final target = DateTime(result.year, result.month);
    if (_isControlled) {
      widget.onDisplayMonthChanged?.call(target);
    } else {
      setState(() => _displayMonth = target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final today = DateTime.now();

    // First day of the display month.
    final firstOfMonth = _effectiveDisplayMonth;
    // Compute grid start offset respecting firstDayOfWeek.
    // DateTime.weekday: 1=Mon ... 7=Sun.
    final fdow = widget.firstDayOfWeek ?? 7; // Default Sunday (7)
    var startOffset = firstOfMonth.weekday - fdow;
    if (startOffset < 0) startOffset += 7;
    final daysInMonth = DateTime(
      firstOfMonth.year,
      firstOfMonth.month + 1,
      0,
    ).day;

    // Build grid cells — only as many rows as needed.
    final totalDays = startOffset + daysInMonth;
    final rowCount = (totalDays / 7).ceil();
    final totalCells = rowCount * 7;
    final cells = <Widget>[];
    for (var i = 0; i < totalCells; i++) {
      final dayNum = i - startOffset + 1;
      if (dayNum < 1 || dayNum > daysInMonth) {
        cells.add(const SizedBox.shrink());
        continue;
      }
      final day = DateTime(firstOfMonth.year, firstOfMonth.month, dayNum);
      final selected = _isSelected(day);
      final inRange = _isInRange(day);
      final endpoint = _isRangeEndpoint(day);
      final isToday = _sameDay(day, today);
      final disabled = _isDisabled(day);

      var cellBgColor = const Color(0x00000000);
      var textColor = disabled ? colors.textMuted : colors.text;

      if (selected || endpoint) {
        cellBgColor = colors.primary.base;
        textColor = colors.textOnPrimary;
      } else if (inRange) {
        cellBgColor = colors.primary.base.withValues(alpha: 0.15);
        textColor = colors.primary.base;
      }

      final cell = Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: cellBgColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '$dayNum',
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected || endpoint
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: textColor,
              ),
            ),
            if (isToday && !selected && !endpoint)
              Positioned(
                top: 3,
                right: 3,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.primary.base,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      );

      cells.add(
        OiTappable(
          enabled: !disabled,
          onTap: () => _onDayTap(day),
          child: cell,
        ),
      );
    }

    // Stripe color for alternating rows.
    final stripeBg = colors.surfaceSubtle;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month/year header with navigation.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            child: Row(
              children: [
                OiTappable(
                  onTap: _prevMonth,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(
                      OiIcons.chevronLeft,
                      size: 17,
                      color: colors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _MonthYearLabel(
                      label: '${kOiMonthLabels[_effectiveDisplayMonth.month - 1]} ${_effectiveDisplayMonth.year}',
                      onTap: _openMonthPicker,
                    ),
                  ),
                ),
                OiTappable(
                  onTap: _nextMonth,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(
                      OiIcons.chevronRight,
                      size: 17,
                      color: colors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          // Weekday header row.
          Row(
            children: List.generate(7, (col) {
              // Reorder weekdays to start from firstDayOfWeek.
              // DateTime.weekday: 1=Mon...7=Sun; _kWeekdays index: 0=Mon...6=Sun.
              final dayIndex = (fdow - 1 + col) % 7;
              return Expanded(
                child: Center(
                  child: Text(
                    _kWeekdays[dayIndex],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colors.textMuted,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 2),
          // Day grid with alternating row backgrounds.
          for (int row = 0; row < rowCount; row++)
            Container(
              decoration: BoxDecoration(
                color: row.isOdd ? stripeBg : null,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: List.generate(7, (col) {
                  final idx = row * 7 + col;
                  return Expanded(
                    child: AspectRatio(aspectRatio: 1.3, child: cells[idx]),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Month/year header label with hover color ────────────────────────────────

class _MonthYearLabel extends StatefulWidget {
  const _MonthYearLabel({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_MonthYearLabel> createState() => _MonthYearLabelState();
}

class _MonthYearLabelState extends State<_MonthYearLabel> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = _hovered ? colors.primary.base : colors.text;

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
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              OiIcons.chevronDown,
              size: 14,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
