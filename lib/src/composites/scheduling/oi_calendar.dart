import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/composites/scheduling/oi_calendar_labels.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_mixin.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/settings/oi_calendar_settings.dart';
import 'package:obers_ui/src/utils/calendar_utils.dart';

/// A calendar event.
///
/// Represents a time-bounded entry displayed in an [OiCalendar].
@immutable
class OiCalendarEvent {
  /// Creates an [OiCalendarEvent].
  const OiCalendarEvent({
    required this.key,
    required this.title,
    required this.start,
    required this.end,
    this.allDay = false,
    this.color,
  });

  /// A unique identifier for this event.
  final Object key;

  /// The display title for the event.
  final String title;

  /// The start date/time of the event.
  final DateTime start;

  /// The end date/time of the event.
  final DateTime end;

  /// Whether this event spans the entire day.
  final bool allDay;

  /// An optional color for the event chip.
  final Color? color;
}

/// Calendar display mode.
///
/// Determines which time period is shown by an [OiCalendar].
enum OiCalendarMode {
  /// A single day view.
  day,

  /// A full week view.
  week,

  /// A full month grid view.
  month,
}

/// A calendar view (day/week/month) for displaying and managing events.
///
/// Supports navigation between time periods, event display, and interaction.
///
/// {@category Composites}
class OiCalendar extends StatefulWidget {
  /// Creates an [OiCalendar].
  const OiCalendar({
    required this.events,
    required this.label,
    this.weekdayLabels = const [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ],
    this.monthLabels = const [
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
    ],
    super.key,
    this.mode = OiCalendarMode.month,
    this.initialDate,
    this.onEventTap,
    this.onDateTap,
    this.onEventMove,
    this.onEventResize,
    this.showWeekNumbers = false,
    this.showAllDayRow = true,
    this.firstDayOfWeek = DateTime.monday,
    this.labels = const OiCalendarLabels(),
    this.settingsDriver,
    this.settingsKey,
    this.settingsNamespace = 'oi_calendar',
    this.settingsSaveDebounce = const Duration(milliseconds: 500),
  });

  /// The list of events to display.
  final List<OiCalendarEvent> events;

  /// An accessibility label describing this calendar.
  final String label;

  /// The display mode: day, week, or month.
  ///
  /// The user can switch modes in the calendar; passing a different value
  /// later switches it again.
  final OiCalendarMode mode;

  /// The initial date the calendar focuses on. Defaults to today.
  ///
  /// The user can navigate away from it; passing a different calendar date
  /// later moves the focus there. Only the date counts, so a parent that
  /// passes `DateTime.now()` on every build does not undo the navigation.
  final DateTime? initialDate;

  /// Called when an event is tapped.
  final ValueChanged<OiCalendarEvent>? onEventTap;

  /// Called when a date cell is tapped.
  final ValueChanged<DateTime>? onDateTap;

  /// Called when an event is moved to a new time range.
  final void Function(OiCalendarEvent event, DateTime start, DateTime end)?
  onEventMove;

  /// Called when an event is resized to a new end time.
  final void Function(OiCalendarEvent event, DateTime newEnd)? onEventResize;

  /// Whether to show ISO 8601 week numbers in the month view.
  ///
  /// Each row is labelled with the ISO week of its first day. ISO weeks run
  /// Monday to Sunday, so with [firstDayOfWeek] set to Monday the label is
  /// the week of the whole row. With any other first day a row straddles two
  /// ISO weeks and the label is the earlier one: for a Sunday start it is the
  /// week that Sunday ends, not the week of the following six days.
  final bool showWeekNumbers;

  /// Whether to show the all-day event row.
  final bool showAllDayRow;

  /// The first day of the week (1 = Monday, 7 = Sunday).
  final int firstDayOfWeek;

  /// The texts of the mode switch and the week number column; pass
  /// translations to localize them.
  final OiCalendarLabels labels;

  // ── Settings persistence ──────────────────────────────────────────────────

  /// Driver used to persist settings. When `null` settings are not persisted.
  final OiSettingsDriver? settingsDriver;

  /// Sub-key scoping this calendar's settings within [settingsNamespace].
  final String? settingsKey;

  /// Top-level namespace for settings storage.
  final String settingsNamespace;

  /// Weekday abbreviations indexed 0–6 (Monday–Sunday); pass translations to
  /// localize the day headers.
  final List<String> weekdayLabels;

  /// Month names indexed 0–11 (January–December); pass translations to
  /// localize the header title.
  final List<String> monthLabels;

  /// Debounce duration for auto-saving settings after changes.
  final Duration settingsSaveDebounce;

  @override
  State<OiCalendar> createState() => _OiCalendarState();
}

class _OiCalendarState extends State<OiCalendar>
    with OiSettingsMixin<OiCalendar, OiCalendarSettings> {
  late DateTime _focusDate;
  late OiCalendarMode _mode;

  /// Whether the settings of the initial load have been taken over.
  bool _initialSettingsAdopted = false;

  /// Whether the user or the parent set the mode after the running settings
  /// load started; such a mode outranks the loaded one.
  bool _modeSetSinceLoadStarted = false;

  /// Resolved driver: explicit widget prop → OiSettingsProvider → null.
  OiSettingsDriver? _resolvedDriver;

  // ── OiSettingsMixin contract ───────────────────────────────────────────────

  @override
  String get settingsNamespace => widget.settingsNamespace;

  @override
  String? get settingsKey => widget.settingsKey;

  @override
  OiSettingsDriver? get settingsDriver => _resolvedDriver;

  @override
  OiCalendarSettings get defaultSettings =>
      OiCalendarSettings(viewType: _calendarModeToViewType(widget.mode));

  @override
  OiCalendarSettings deserializeSettings(Map<String, dynamic> json) =>
      OiCalendarSettings.fromJson(json);

  @override
  OiCalendarSettings mergeSettings(
    OiCalendarSettings saved,
    OiCalendarSettings defaults,
  ) => saved.mergeWith(defaults);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    _resolvedDriver = widget.settingsDriver;
    super.initState();
    _focusDate = widget.initialDate ?? DateTime.now();
    _mode = widget.mode;
    if (settingsLoaded && settingsDriver != null) {
      _applySettings(currentSettings);
    }
  }

  @override
  void didUpdateWidget(OiCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mode != oldWidget.mode) {
      // Stored like a pick by the user, or the saved mode would come back
      // with the next settings load.
      _mode = widget.mode;
      _modeSetSinceLoadStarted = true;
      updateSettings(_toSettings(), debounce: widget.settingsSaveDebounce);
    }
    final oldDate = oldWidget.initialDate;
    final newDate = widget.initialDate;
    final sameDate = oldDate == null || newDate == null
        ? oldDate == newDate
        : _sameDay(oldDate, newDate);
    if (!sameDate) _focusDate = newDate ?? DateTime.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newDriver = widget.settingsDriver ?? OiSettingsProvider.of(context);
    if (newDriver != _resolvedDriver) {
      _resolvedDriver = newDriver;
      if (settingsLoaded) {
        _modeSetSinceLoadStarted = false;
        unawaited(
          reloadSettings().then((_) {
            if (mounted) setState(_adoptLoadedSettings);
          }),
        );
      }
    }
  }

  /// Takes over the mode of settings that have just been loaded.
  ///
  /// Runs once per load and never on a plain dependency change (a theme
  /// switch, say), which would undo a mode set since. A mode that the user
  /// or the parent chose while the load was running wins and is saved
  /// instead.
  void _adoptLoadedSettings() {
    if (settingsDriver == null) return;
    if (!_modeSetSinceLoadStarted) {
      _applySettings(currentSettings);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      updateSettings(_toSettings(), debounce: widget.settingsSaveDebounce);
    });
  }

  void _applySettings(OiCalendarSettings settings) {
    _mode = _viewTypeToCalendarMode(settings.viewType);
  }

  OiCalendarSettings _toSettings() {
    return OiCalendarSettings(viewType: _calendarModeToViewType(_mode));
  }

  static OiCalendarViewType _calendarModeToViewType(OiCalendarMode mode) {
    return switch (mode) {
      OiCalendarMode.day => OiCalendarViewType.day,
      OiCalendarMode.week => OiCalendarViewType.week,
      OiCalendarMode.month => OiCalendarViewType.month,
    };
  }

  static OiCalendarMode _viewTypeToCalendarMode(OiCalendarViewType type) {
    return switch (type) {
      OiCalendarViewType.day => OiCalendarMode.day,
      OiCalendarViewType.week => OiCalendarMode.week,
      OiCalendarViewType.month => OiCalendarMode.month,
    };
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _goForward() {
    setState(() {
      switch (_mode) {
        case OiCalendarMode.day:
          _focusDate = OiCalendarUtils.addDays(_focusDate, 1);
        case OiCalendarMode.week:
          _focusDate = OiCalendarUtils.addDays(_focusDate, 7);
        case OiCalendarMode.month:
          _focusDate = DateTime(_focusDate.year, _focusDate.month + 1);
      }
    });
  }

  void _goBackward() {
    setState(() {
      switch (_mode) {
        case OiCalendarMode.day:
          _focusDate = OiCalendarUtils.addDays(_focusDate, -1);
        case OiCalendarMode.week:
          _focusDate = OiCalendarUtils.addDays(_focusDate, -7);
        case OiCalendarMode.month:
          _focusDate = DateTime(_focusDate.year, _focusDate.month - 1);
      }
    });
  }

  void _setMode(OiCalendarMode mode) {
    setState(() => _mode = mode);
    _modeSetSinceLoadStarted = true;
    updateSettings(_toSettings(), debounce: widget.settingsSaveDebounce);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// The ISO 8601 week number shown for [row] of the month grid starting at
  /// [gridStart]: the week of the row's first day (see
  /// [OiCalendar.showWeekNumbers]).
  int _rowWeekNumber(DateTime gridStart, int row) {
    return OiCalendarUtils.weekNumber(
      OiCalendarUtils.addDays(gridStart, row * 7),
    );
  }

  /// Returns the ordered day-of-week headers starting from firstDayOfWeek.
  List<String> get _dayHeaders {
    final start = widget.firstDayOfWeek - 1; // 0-based index
    return [for (var i = 0; i < 7; i++) widget.weekdayLabels[(start + i) % 7]];
  }

  /// The number of week rows in the month grid.
  static const _monthGridRows = 6;

  /// Returns the first day visible in the month grid.
  DateTime _monthGridStart() {
    return OiCalendarUtils.firstDayOfWeek(
      DateTime(_focusDate.year, _focusDate.month),
      startOfWeek: widget.firstDayOfWeek,
    );
  }

  /// Returns the start of the week containing [_focusDate].
  DateTime _weekStart() {
    return OiCalendarUtils.firstDayOfWeek(
      _focusDate,
      startOfWeek: widget.firstDayOfWeek,
    );
  }

  /// Whether [a] and [b] fall on the same calendar day.
  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Whether [date] is today.
  bool _isToday(DateTime date) => _sameDay(date, DateTime.now());

  /// The title for the navigation header.
  String get _headerTitle {
    final months = widget.monthLabels;
    switch (_mode) {
      case OiCalendarMode.day:
        final m = months[_focusDate.month - 1];
        return '${_focusDate.day} $m ${_focusDate.year}';
      case OiCalendarMode.week:
        final ws = _weekStart();
        final we = OiCalendarUtils.addDays(ws, 6);
        return '${ws.day}/${ws.month} - ${we.day}/${we.month} ${we.year}';
      case OiCalendarMode.month:
        return '${months[_focusDate.month - 1]} ${_focusDate.year}';
    }
  }

  /// Events falling on [date].
  List<OiCalendarEvent> _eventsOn(DateTime date) {
    return widget.events.where((e) {
      final eventStart = DateTime(e.start.year, e.start.month, e.start.day);
      final eventEnd = DateTime(e.end.year, e.end.month, e.end.day);
      final day = DateTime(date.year, date.month, date.day);
      return !day.isBefore(eventStart) && !day.isAfter(eventEnd);
    }).toList();
  }

  /// All-day events on any of the dates the current view shows: the focused
  /// day, its week, or the whole month grid.
  List<OiCalendarEvent> _visibleAllDayEvents() {
    final DateTime first;
    final DateTime last;
    switch (_mode) {
      case OiCalendarMode.day:
        first = last = _focusDate;
      case OiCalendarMode.week:
        first = _weekStart();
        last = OiCalendarUtils.addDays(first, 6);
      case OiCalendarMode.month:
        first = _monthGridStart();
        last = OiCalendarUtils.addDays(first, _monthGridRows * 7 - 1);
    }
    return widget.events.where((e) {
      return e.allDay &&
          OiCalendarUtils.daysBetween(e.start, last) >= 0 &&
          OiCalendarUtils.daysBetween(first, e.end) >= 0;
    }).toList();
  }

  /// The start of the hour cell [hour] on the day of [date], or `null` when
  /// the clocks skip that hour on that day (a daylight-saving change).
  ///
  /// `DateTime` moves a skipped hour on to the next one, so without this the
  /// row of the skipped hour would repeat the cell below it.
  DateTime? _hourCellStart(DateTime date, int hour) {
    final start = DateTime(date.year, date.month, date.day, hour);
    return start.hour == hour ? start : null;
  }

  /// The timed (not all-day) events in the hour cell starting at
  /// [cellStart]; none for a skipped hour.
  List<OiCalendarEvent> _timedEventsIn(DateTime? cellStart) {
    if (cellStart == null) return const [];
    return widget.events
        .where((e) => !e.allDay && _occupiesHour(e, cellStart))
        .toList();
  }

  /// Whether [event] takes up any part of the hour that starts at
  /// [cellStart]: its time range overlaps `[cellStart, cellStart + 1h)`.
  ///
  /// An event without a duration counts for the hour it starts in.
  bool _occupiesHour(OiCalendarEvent event, DateTime cellStart) {
    final cellEnd = DateTime(
      cellStart.year,
      cellStart.month,
      cellStart.day,
      cellStart.hour + 1,
    );
    if (!event.end.isAfter(event.start)) {
      return !event.start.isBefore(cellStart) && event.start.isBefore(cellEnd);
    }
    return event.start.isBefore(cellEnd) && event.end.isAfter(cellStart);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // The first load finishes after initState; this is the first build that
    // sees its result.
    if (settingsLoaded && !_initialSettingsAdopted) {
      _initialSettingsAdopted = true;
      _adoptLoadedSettings();
    }

    final sp = context.spacing;
    final allDayEvents = widget.showAllDayRow
        ? _visibleAllDayEvents()
        : const <OiCalendarEvent>[];

    return Semantics(
      label: widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          _buildModeSelector(context),
          SizedBox(height: sp.sm),
          if (allDayEvents.isNotEmpty) _buildAllDayRow(context, allDayEvents),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            key: const ValueKey('calendar_back'),
            onTap: _goBackward,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(OiIcons.chevronLeft, size: 20, color: colors.text),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                _headerTitle,
                key: const ValueKey('calendar_header_title'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
            ),
          ),
          GestureDetector(
            key: const ValueKey('calendar_forward'),
            onTap: _goForward,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(OiIcons.chevronRight, size: 20, color: colors.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final mode in OiCalendarMode.values)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                key: ValueKey('calendar_mode_${mode.name}'),
                onTap: () => _setMode(mode),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _mode == mode ? colors.primary.base : colors.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.labels.modeName(mode),
                    style: TextStyle(
                      color: _mode == mode ? colors.textOnPrimary : colors.text,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAllDayRow(BuildContext context, List<OiCalendarEvent> events) {
    final colors = context.colors;
    return Container(
      key: const ValueKey('calendar_all_day_row'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: colors.surfaceSubtle,
      child: Wrap(
        spacing: 4,
        children: [
          for (final e in events)
            GestureDetector(
              onTap: widget.onEventTap != null
                  ? () => widget.onEventTap!(e)
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: e.color ?? colors.primary.base,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  e.title,
                  style: TextStyle(fontSize: 12, color: colors.textOnPrimary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_mode) {
      case OiCalendarMode.month:
        return _buildMonthView(context);
      case OiCalendarMode.week:
        return _buildWeekView(context);
      case OiCalendarMode.day:
        return _buildDayView(context);
    }
  }

  // ── Month view ────────────────────────────────────────────────────────────

  Widget _buildMonthView(BuildContext context) {
    final colors = context.colors;
    final gridStart = _monthGridStart();

    return Column(
      children: [
        // Day-of-week headers.
        Row(
          children: [
            if (widget.showWeekNumbers)
              SizedBox(
                width: 32,
                child: Center(
                  child: Text(
                    widget.labels.weekNumberHeader,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colors.textMuted,
                    ),
                  ),
                ),
              ),
            for (final h in _dayHeaders)
              Expanded(
                child: Center(
                  child: Text(
                    h,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colors.textMuted,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        // Grid rows.
        Expanded(
          child: Column(
            children: [
              for (var row = 0; row < _monthGridRows; row++)
                Expanded(
                  child: Row(
                    children: [
                      if (widget.showWeekNumbers)
                        SizedBox(
                          width: 32,
                          child: Center(
                            child: Text(
                              '${_rowWeekNumber(gridStart, row)}',
                              key: ValueKey(
                                'calendar_week_${_rowWeekNumber(gridStart, row)}',
                              ),
                              style: TextStyle(
                                fontSize: 10,
                                color: colors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      for (var col = 0; col < 7; col++)
                        Expanded(
                          child: _buildDayCell(
                            context,
                            OiCalendarUtils.addDays(gridStart, row * 7 + col),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Event drag-and-drop ───────────────────────────────────────────────────

  /// Whether events can be dragged — a move handler is wired.
  bool get _canMoveEvents => widget.onEventMove != null;

  /// Wraps an event [chip] in a long-press draggable carrying [event] when
  /// moves are enabled; [feedbackWidth] sizes the floating copy.
  Widget _draggableEvent(
    OiCalendarEvent event,
    Widget chip, {
    required double feedbackWidth,
  }) {
    if (!_canMoveEvents) return chip;
    return LongPressDraggable<OiCalendarEvent>(
      data: event,
      feedback: SizedBox(
        width: feedbackWidth,
        child: Opacity(opacity: 0.85, child: chip),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: chip),
      child: chip,
    );
  }

  /// Reports [event] moved so its start lands on [target] — keeping its
  /// time-of-day in day-granular (month) drops, or taking the target's hour
  /// in hour-granular (week/day) drops — and preserving its duration.
  void _moveEvent(
    OiCalendarEvent event,
    DateTime target, {
    required bool preserveTimeOfDay,
  }) {
    final start = DateTime(
      target.year,
      target.month,
      target.day,
      preserveTimeOfDay ? event.start.hour : target.hour,
      event.start.minute,
    );
    final end = start.add(event.end.difference(event.start));
    widget.onEventMove!(event, start, end);
  }

  /// Wraps a calendar cell in a drop target landing dragged events on
  /// [target] when moves are enabled; [builder] receives whether a drag is
  /// hovering so the cell can highlight.
  Widget _eventDropTarget({
    required DateTime? target,
    required bool preserveTimeOfDay,
    required Widget Function({required bool hovering}) builder,
  }) {
    // No target: the cell of an hour the clocks skip takes no drops.
    if (!_canMoveEvents || target == null) return builder(hovering: false);
    return DragTarget<OiCalendarEvent>(
      onAcceptWithDetails: (details) => _moveEvent(
        details.data,
        target,
        preserveTimeOfDay: preserveTimeOfDay,
      ),
      builder: (context, candidates, rejected) =>
          builder(hovering: candidates.isNotEmpty),
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date) {
    final colors = context.colors;
    final isCurrentMonth = date.month == _focusDate.month;
    final today = _isToday(date);
    final dayEvents = _eventsOn(date).where((e) => !e.allDay).toList();

    return _eventDropTarget(
      target: date,
      preserveTimeOfDay: true,
      builder: ({required hovering}) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onDateTap != null ? () => widget.onDateTap!(date) : null,
        child: Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: today ? colors.primary.base.withValues(alpha: 0.1) : null,
            border: hovering || today
                ? Border.all(color: colors.primary.base)
                : Border.all(color: colors.borderSubtle.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(2),
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: today ? FontWeight.bold : FontWeight.normal,
                    color: isCurrentMonth ? colors.text : colors.textMuted,
                  ),
                ),
              ),
              // Show up to 2 event chips.
              for (final ev in dayEvents.take(2))
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 1,
                  ),
                  child: _draggableEvent(
                    ev,
                    GestureDetector(
                      onTap: widget.onEventTap != null
                          ? () => widget.onEventTap!(ev)
                          : null,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ev.color ?? colors.primary.base,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          ev.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textOnPrimary,
                          ),
                        ),
                      ),
                    ),
                    feedbackWidth: 140,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Week view ─────────────────────────────────────────────────────────────

  Widget _buildWeekView(BuildContext context) {
    final colors = context.colors;
    final ws = _weekStart();

    return Column(
      children: [
        // Day headers.
        Row(
          children: [
            // Time gutter.
            const SizedBox(width: 48),
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Builder(
                    builder: (_) {
                      final d = OiCalendarUtils.addDays(ws, i);
                      final today = _isToday(d);
                      return Text(
                        '${_dayHeaders[i]} ${d.day}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: today
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: today ? colors.primary.base : colors.textMuted,
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        // Hour rows.
        Expanded(
          child: ListView.builder(
            itemCount: 24,
            itemBuilder: (context, hour) {
              return SizedBox(
                height: 48,
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: Center(
                        child: Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    for (var dayIdx = 0; dayIdx < 7; dayIdx++)
                      Expanded(
                        child: _buildWeekCell(
                          context,
                          OiCalendarUtils.addDays(ws, dayIdx),
                          hour,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekCell(BuildContext context, DateTime date, int hour) {
    final colors = context.colors;
    final cellTime = _hourCellStart(date, hour);
    final dayEvents = _timedEventsIn(cellTime);

    return _eventDropTarget(
      target: cellTime,
      preserveTimeOfDay: false,
      builder: ({required hovering}) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onDateTap != null && cellTime != null
            ? () => widget.onDateTap!(cellTime)
            : null,
        child: Container(
          margin: const EdgeInsets.all(0.5),
          decoration: BoxDecoration(
            border: Border.all(
              color: hovering
                  ? colors.primary.base
                  : colors.borderSubtle.withValues(alpha: 0.3),
            ),
          ),
          child: dayEvents.isEmpty
              ? null
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final ev in dayEvents.take(1))
                      Expanded(
                        child: _draggableEvent(
                          ev,
                          GestureDetector(
                            onTap: widget.onEventTap != null
                                ? () => widget.onEventTap!(ev)
                                : null,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              color: ev.color ?? colors.primary.base,
                              child: Text(
                                ev.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.textOnPrimary,
                                ),
                              ),
                            ),
                          ),
                          feedbackWidth: 120,
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  // ── Day view ──────────────────────────────────────────────────────────────

  Widget _buildDayView(BuildContext context) {
    final colors = context.colors;

    return ListView.builder(
      itemCount: 24,
      itemBuilder: (context, hour) {
        final cellTime = _hourCellStart(_focusDate, hour);
        final hourEvents = _timedEventsIn(cellTime);

        return _eventDropTarget(
          target: cellTime,
          preserveTimeOfDay: false,
          builder: ({required hovering}) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDateTap != null && cellTime != null
                ? () => widget.onDateTap!(cellTime)
                : null,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: hovering
                    ? colors.primary.base.withValues(alpha: 0.08)
                    : null,
                border: Border(bottom: BorderSide(color: colors.borderSubtle)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    child: Center(
                      child: Text(
                        '${hour.toString().padLeft(2, '0')}:00',
                        style: TextStyle(fontSize: 10, color: colors.textMuted),
                      ),
                    ),
                  ),
                  Expanded(
                    child: hourEvents.isEmpty
                        ? const SizedBox.shrink()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final ev in hourEvents)
                                Expanded(
                                  child: _draggableEvent(
                                    ev,
                                    GestureDetector(
                                      onTap: widget.onEventTap != null
                                          ? () => widget.onEventTap!(ev)
                                          : null,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        margin: const EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                          color:
                                              ev.color ?? colors.primary.base,
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                        child: Text(
                                          ev.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colors.textOnPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    feedbackWidth: 160,
                                  ),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
