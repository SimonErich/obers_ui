import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';

import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

const List<String> _kDayAbbreviations = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

const List<String> _kMonthNames = [
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

/// A compact horizontal 7-day week selector.
///
/// Displays a single week as a horizontal row of day cells (abbreviation +
/// day number). Users can tap a day to select it, and swipe or use the
/// navigation arrows to change the visible week.
///
/// [selectedDate] controls the highlighted day. [onDateSelected] fires when
/// the user taps a day cell. Optionally pass [eventCounts] to show a small
/// dot indicator on days that have events.
///
/// Navigation can be constrained with [firstDate] and [lastDate]. Set
/// [showNavigation] to `false` to hide the prev/next arrows, and
/// [showMonth] to `false` to hide the month label.
///
/// {@category Components}
class OiWeekStrip extends StatefulWidget {
  /// Creates an [OiWeekStrip].
  const OiWeekStrip({
    required this.selectedDate,
    required this.onDateSelected,
    required this.label,
    this.eventCounts,
    this.eventDotColor,
    this.firstDayOfWeek = DateTime.monday,
    this.firstDate,
    this.lastDate,
    this.disabledDates,
    this.disabledDaysOfWeek,
    this.showNavigation = true,
    this.showMonth = true,
    this.showYear = false,
    this.todayLabel,
    this.locale,
    this.compact = false,
    this.semanticLabel,
    super.key,
  });

  /// The currently selected date, highlighted with the primary color.
  final DateTime selectedDate;

  /// Called when the user taps a day cell.
  final ValueChanged<DateTime> onDateSelected;

  /// Accessibility label for the widget.
  final String label;

  /// Optional map of dates to event counts. Days with a count > 0 show a
  /// small dot indicator below the day number.
  final Map<DateTime, int>? eventCounts;

  /// Color of event dot badges. Defaults to `colors.primary.base`.
  final Color? eventDotColor;

  /// The first day of the week (1 = Monday, 7 = Sunday).
  ///
  /// Defaults to [DateTime.monday].
  final int firstDayOfWeek;

  /// The earliest navigable date. When set, the previous-week arrow is
  /// disabled when the displayed week would go before this date.
  final DateTime? firstDate;

  /// The latest navigable date. When set, the next-week arrow is
  /// disabled when the displayed week would go past this date.
  final DateTime? lastDate;

  /// Specific dates that cannot be selected (shown as muted).
  final Set<DateTime>? disabledDates;

  /// Days of the week that cannot be selected (1=Mon, 7=Sun).
  final Set<int>? disabledDaysOfWeek;

  /// Whether to show the previous/next navigation arrows.
  final bool showNavigation;

  /// Whether to show the month name label above the day row.
  final bool showMonth;

  /// When provided, a "Today" jump button is shown with this label text.
  final String? todayLabel;

  /// Whether to show the year alongside the month.
  final bool showYear;

  /// Locale for day-of-week abbreviations. Defaults to app locale.
  final Locale? locale;

  /// When `true`, day cells use a smaller size.
  final bool compact;

  /// Optional semantic label for screen readers.
  final String? semanticLabel;

  @override
  State<OiWeekStrip> createState() => _OiWeekStripState();
}

class _OiWeekStripState extends State<OiWeekStrip> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _weekStart = _computeWeekStart(widget.selectedDate);
  }

  @override
  void didUpdateWidget(OiWeekStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      final newWeekStart = _computeWeekStart(widget.selectedDate);
      if (newWeekStart != _weekStart) {
        _weekStart = newWeekStart;
      }
    }
  }

  /// Computes the start of the week containing [date], using the configured
  /// [OiWeekStrip.firstDayOfWeek].
  DateTime _computeWeekStart(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    // DateTime.weekday: 1=Mon ... 7=Sun
    var diff = d.weekday - widget.firstDayOfWeek;
    if (diff < 0) diff += 7;
    return d.subtract(Duration(days: diff));
  }

  void _prevWeek() {
    final prev = _weekStart.subtract(const Duration(days: 7));
    if (_canNavigatePrev(prev)) {
      setState(() => _weekStart = prev);
    }
  }

  void _nextWeek() {
    final next = _weekStart.add(const Duration(days: 7));
    if (_canNavigateNext(next)) {
      setState(() => _weekStart = next);
    }
  }

  void _jumpToToday() {
    final todayWeekStart = _computeWeekStart(DateTime.now());
    setState(() => _weekStart = todayWeekStart);
    widget.onDateSelected(DateTime.now());
  }

  bool _canNavigatePrev(DateTime prevStart) {
    if (widget.firstDate == null) return true;
    // The previous week ends at prevStart + 6 days. If the entire previous
    // week is before firstDate, disable.
    final weekEnd = prevStart.add(const Duration(days: 6));
    return !weekEnd.isBefore(
      DateTime(
        widget.firstDate!.year,
        widget.firstDate!.month,
        widget.firstDate!.day,
      ),
    );
  }

  bool _canNavigateNext(DateTime nextStart) {
    if (widget.lastDate == null) return true;
    return !nextStart.isAfter(
      DateTime(
        widget.lastDate!.year,
        widget.lastDate!.month,
        widget.lastDate!.day,
      ),
    );
  }

  bool _isDisabled(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    if (widget.firstDate != null) {
      final first = DateTime(
        widget.firstDate!.year,
        widget.firstDate!.month,
        widget.firstDate!.day,
      );
      if (d.isBefore(first)) return true;
    }
    if (widget.lastDate != null) {
      final last = DateTime(
        widget.lastDate!.year,
        widget.lastDate!.month,
        widget.lastDate!.day,
      );
      if (d.isAfter(last)) return true;
    }
    if (widget.disabledDates != null) {
      for (final dd in widget.disabledDates!) {
        if (_sameDay(dd, d)) return true;
      }
    }
    if (widget.disabledDaysOfWeek != null &&
        widget.disabledDaysOfWeek!.contains(d.weekday)) {
      return true;
    }
    return false;
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _hasEvents(DateTime day) {
    if (widget.eventCounts == null) return false;
    for (final entry in widget.eventCounts!.entries) {
      if (_sameDay(entry.key, day) && entry.value > 0) return true;
    }
    return false;
  }

  /// Returns a month label. If the week spans two months, shows both
  /// (e.g. "Mar – Apr"). Year shown only when [OiWeekStrip.showYear] is true.
  String _monthLabel() {
    final weekEnd = _weekStart.add(const Duration(days: 6));
    final startMonth = _kMonthNames[_weekStart.month - 1];
    final year = widget.showYear ? ' ${_weekStart.year}' : '';
    if (_weekStart.month == weekEnd.month && _weekStart.year == weekEnd.year) {
      return '$startMonth$year';
    }
    final endMonth = _kMonthNames[weekEnd.month - 1];
    if (_weekStart.year == weekEnd.year) {
      return '$startMonth \u2013 $endMonth$year';
    }
    // Week spans years — always show both years.
    return '$startMonth ${_weekStart.year} \u2013 '
        '$endMonth ${weekEnd.year}';
  }

  /// Returns the day abbreviation for the given weekday, respecting
  /// [OiWeekStrip.firstDayOfWeek].
  String _dayAbbreviation(int index) {
    // _kDayAbbreviations is 0-indexed starting at Monday (index 0).
    // firstDayOfWeek: 1=Mon, 7=Sun
    final weekdayIndex = (widget.firstDayOfWeek - 1 + index) % 7;
    return _kDayAbbreviations[weekdayIndex];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final today = DateTime.now();
    final themeData = context.components.weekStrip;
    final daySize = themeData?.daySize ?? (widget.compact ? 36.0 : 44.0);
    final selectedRadius =
        themeData?.selectedRadius ?? BorderRadius.circular(daySize / 2);

    final prevEnabled = _canNavigatePrev(
      _weekStart.subtract(const Duration(days: 7)),
    );
    final nextEnabled = _canNavigateNext(
      _weekStart.add(const Duration(days: 7)),
    );

    // Build the 7 day cells.
    final dayCells = <Widget>[];
    for (var i = 0; i < 7; i++) {
      final day = _weekStart.add(Duration(days: i));
      final isSelected = _sameDay(day, widget.selectedDate);
      final isToday = _sameDay(day, today);
      final disabled = _isDisabled(day);
      final hasEvent = _hasEvents(day);

      final bgColor = isSelected
          ? colors.primary.base
          : const Color(0x00000000);
      final textColor = isSelected
          ? colors.textOnPrimary
          : disabled
          ? colors.textMuted
          : colors.text;

      dayCells.add(
        OiTappable(
          onTap: disabled ? null : () => widget.onDateSelected(day),
          enabled: !disabled,
          semanticLabel: '${_dayAbbreviation(i)} ${day.day}',
          child: Container(
            width: daySize,
            height: daySize + 16,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: selectedRadius,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OiLabel.tiny(_dayAbbreviation(i), color: textColor),
                SizedBox(height: spacing.xs / 2),
                OiLabel.bodyStrong('${day.day}', color: textColor),
                if (hasEvent)
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.textOnPrimary
                          : widget.eventDotColor ?? colors.primary.base,
                      shape: BoxShape.circle,
                    ),
                  )
                else if (isToday && !isSelected)
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: colors.primary.base,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          if (details.primaryVelocity! < -100) {
            _nextWeek();
          } else if (details.primaryVelocity! > 100) {
            _prevWeek();
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row: navigation arrows + month label + today button.
            if (widget.showMonth ||
                widget.showNavigation ||
                widget.todayLabel != null)
              Padding(
                padding: EdgeInsets.only(bottom: spacing.sm),
                child: Row(
                  children: [
                    if (widget.showNavigation) ...[
                      OiTappable(
                        onTap: prevEnabled ? _prevWeek : null,
                        enabled: prevEnabled,
                        semanticLabel: 'Previous week',
                        child: OiIcon.decorative(
                          icon: OiIcons.chevronLeft,
                          color: prevEnabled ? colors.text : colors.textMuted,
                        ),
                      ),
                    ],
                    if (widget.showMonth)
                      Expanded(
                        child: OiLabel.bodyStrong(
                          _monthLabel(),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      const Spacer(),
                    if (widget.todayLabel != null)
                      OiTappable(
                        onTap: _jumpToToday,
                        semanticLabel: widget.todayLabel,
                        child: OiLabel.small(
                          widget.todayLabel!,
                          color: colors.primary.base,
                        ),
                      ),
                    if (widget.showNavigation) ...[
                      OiTappable(
                        onTap: nextEnabled ? _nextWeek : null,
                        enabled: nextEnabled,
                        semanticLabel: 'Next week',
                        child: OiIcon.decorative(
                          icon: OiIcons.chevronRight,
                          color: nextEnabled ? colors.text : colors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            // Day cells row.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: dayCells,
            ),
          ],
        ),
      ),
    );
  }
}
