import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_mixin.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/settings/oi_calendar_settings.dart';

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
  final OiCalendarMode mode;

  /// The initial date the calendar focuses on. Defaults to today.
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

  /// Whether to show ISO week numbers in the month view.
  final bool showWeekNumbers;

  /// Whether to show the all-day event row.
  final bool showAllDayRow;

  /// The first day of the week (1 = Monday, 7 = Sunday).
  final int firstDayOfWeek;

  // ── Settings persistence ──────────────────────────────────────────────────

  /// Driver used to persist settings. When `null` settings are not persisted.
  final OiSettingsDriver? settingsDriver;

  /// Sub-key scoping this calendar's settings within [settingsNamespace].
  final String? settingsKey;

  /// Top-level namespace for settings storage.
  final String settingsNamespace;

  /// Debounce duration for auto-saving settings after changes.
  final Duration settingsSaveDebounce;

  @override
  State<OiCalendar> createState() => _OiCalendarState();
}

class _OiCalendarState extends State<OiCalendar>
    with OiSettingsMixin<OiCalendar, OiCalendarSettings> {
  late DateTime _focusDate;
  late OiCalendarMode _mode;

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
  OiCalendarSettings get defaultSettings => OiCalendarSettings(
    viewType: _calendarModeToViewType(widget.mode),
  );

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newDriver =
        widget.settingsDriver ?? OiSettingsProvider.of(context);
    if (newDriver != _resolvedDriver) {
      _resolvedDriver = newDriver;
      if (settingsLoaded) {
        reloadSettings();
      }
    }
    if (settingsLoaded && settingsDriver != null) {
      _applySettings(currentSettings);
    }
  }

  void _applySettings(OiCalendarSettings settings) {
    _mode = _viewTypeToCalendarMode(settings.viewType);
  }

  OiCalendarSettings _toSettings() {
    return OiCalendarSettings(
      viewType: _calendarModeToViewType(_mode),
    );
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
          _focusDate = _focusDate.add(const Duration(days: 1));
        case OiCalendarMode.week:
          _focusDate = _focusDate.add(const Duration(days: 7));
        case OiCalendarMode.month:
          _focusDate = DateTime(_focusDate.year, _focusDate.month + 1);
      }
    });
  }

  void _goBackward() {
    setState(() {
      switch (_mode) {
        case OiCalendarMode.day:
          _focusDate = _focusDate.subtract(const Duration(days: 1));
        case OiCalendarMode.week:
          _focusDate = _focusDate.subtract(const Duration(days: 7));
        case OiCalendarMode.month:
          _focusDate = DateTime(_focusDate.year, _focusDate.month - 1);
      }
    });
  }

  void _setMode(OiCalendarMode mode) {
    setState(() => _mode = mode);
    updateSettings(_toSettings(), debounce: widget.settingsSaveDebounce);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns the ordered day-of-week headers starting from [firstDayOfWeek].
  List<String> get _dayHeaders {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final start = widget.firstDayOfWeek - 1; // 0-based index
    return [for (var i = 0; i < 7; i++) names[(start + i) % 7]];
  }

  /// Returns the ISO 8601 week number for [date].
  int _weekNumber(DateTime date) {
    // ISO week: week 1 is the week containing the first Thursday of the year.
    final dayOfYear = date.difference(DateTime(date.year)).inDays + 1;
    final weekday = date.weekday; // 1=Mon, 7=Sun
    final woy = ((dayOfYear - weekday + 10) / 7).floor();
    if (woy < 1) return _weekNumber(DateTime(date.year - 1, 12, 31));
    if (woy > 52) {
      final dec31 = DateTime(date.year, 12, 31);
      if (dec31.weekday < 4) return 1;
    }
    return woy;
  }

  /// Returns the first day visible in the month grid.
  DateTime _monthGridStart() {
    final first = DateTime(_focusDate.year, _focusDate.month);
    final weekdayOffset = (first.weekday - widget.firstDayOfWeek + 7) % 7;
    return first.subtract(Duration(days: weekdayOffset));
  }

  /// Returns the start of the week containing [_focusDate].
  DateTime _weekStart() {
    final offset = (_focusDate.weekday - widget.firstDayOfWeek + 7) % 7;
    return DateTime(_focusDate.year, _focusDate.month, _focusDate.day - offset);
  }

  /// Whether [a] and [b] fall on the same calendar day.
  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Whether [date] is today.
  bool _isToday(DateTime date) => _sameDay(date, DateTime.now());

  /// The title for the navigation header.
  String get _headerTitle {
    const months = [
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
    switch (_mode) {
      case OiCalendarMode.day:
        final m = months[_focusDate.month - 1];
        return '${_focusDate.day} $m ${_focusDate.year}';
      case OiCalendarMode.week:
        final ws = _weekStart();
        final we = ws.add(const Duration(days: 6));
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

  /// All-day events in the current view range.
  List<OiCalendarEvent> get _allDayEvents =>
      widget.events.where((e) => e.allDay).toList();

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          _buildModeSelector(context),
          if (widget.showAllDayRow && _allDayEvents.isNotEmpty)
            _buildAllDayRow(context),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            key: const ValueKey('calendar_back'),
            onTap: _goBackward,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text('\u25C0', style: TextStyle(color: colors.text)),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                _headerTitle,
                key: const ValueKey('calendar_header_title'),
                style: TextStyle(
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
              child: Text('\u25B6', style: TextStyle(color: colors.text)),
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
                    mode.name[0].toUpperCase() + mode.name.substring(1),
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

  Widget _buildAllDayRow(BuildContext context) {
    final colors = context.colors;
    return Container(
      key: const ValueKey('calendar_all_day_row'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: colors.surfaceSubtle,
      child: Wrap(
        spacing: 4,
        children: [
          for (final e in _allDayEvents)
            GestureDetector(
              onTap: widget.onEventTap != null
                  ? () => widget.onEventTap!(e)
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: e.color ?? colors.primary.base,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  e.title,
                  style: TextStyle(fontSize: 11, color: colors.textOnPrimary),
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
                    'Wk',
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
              for (var row = 0; row < 6; row++)
                Expanded(
                  child: Row(
                    children: [
                      if (widget.showWeekNumbers)
                        SizedBox(
                          width: 32,
                          child: Center(
                            child: Text(
                              '${_weekNumber(gridStart.add(Duration(days: row * 7)))}',
                              key: ValueKey(
                                'calendar_week_${_weekNumber(gridStart.add(Duration(days: row * 7)))}',
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
                            gridStart.add(Duration(days: row * 7 + col)),
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

  Widget _buildDayCell(BuildContext context, DateTime date) {
    final colors = context.colors;
    final isCurrentMonth = date.month == _focusDate.month;
    final today = _isToday(date);
    final dayEvents = _eventsOn(date).where((e) => !e.allDay).toList();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onDateTap != null ? () => widget.onDateTap!(date) : null,
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: today ? colors.primary.base.withValues(alpha: 0.1) : null,
          border: today
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
                  fontSize: 11,
                  fontWeight: today ? FontWeight.bold : FontWeight.normal,
                  color: isCurrentMonth ? colors.text : colors.textMuted,
                ),
              ),
            ),
            // Show up to 2 event chips.
            for (final ev in dayEvents.take(2))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                child: GestureDetector(
                  onTap: widget.onEventTap != null
                      ? () => widget.onEventTap!(ev)
                      : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: ev.color ?? colors.primary.base,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      ev.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: colors.textOnPrimary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
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
                      final d = ws.add(Duration(days: i));
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
                          ws.add(Duration(days: dayIdx)),
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
    final cellTime = DateTime(date.year, date.month, date.day, hour);
    final dayEvents = _eventsOn(date).where((e) {
      if (e.allDay) return false;
      return e.start.hour <= hour && e.end.hour > hour;
    }).toList();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onDateTap != null
          ? () => widget.onDateTap!(cellTime)
          : null,
      child: Container(
        margin: const EdgeInsets.all(0.5),
        decoration: BoxDecoration(
          border: Border.all(color: colors.borderSubtle.withValues(alpha: 0.3)),
        ),
        child: dayEvents.isEmpty
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final ev in dayEvents.take(1))
                    Expanded(
                      child: GestureDetector(
                        onTap: widget.onEventTap != null
                            ? () => widget.onEventTap!(ev)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          color: ev.color ?? colors.primary.base,
                          child: Text(
                            ev.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
                              color: colors.textOnPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
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
        final cellTime = DateTime(
          _focusDate.year,
          _focusDate.month,
          _focusDate.day,
          hour,
        );
        final hourEvents = widget.events.where((e) {
          if (e.allDay) return false;
          if (!_sameDay(e.start, _focusDate) && !_sameDay(e.end, _focusDate)) {
            return false;
          }
          return e.start.hour <= hour && e.end.hour > hour;
        }).toList();

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onDateTap != null
              ? () => widget.onDateTap!(cellTime)
              : null,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
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
                                child: GestureDetector(
                                  onTap: widget.onEventTap != null
                                      ? () => widget.onEventTap!(ev)
                                      : null,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    margin: const EdgeInsets.all(1),
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
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
