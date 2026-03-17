import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A time slot in the scheduler.
///
/// Represents a time-bounded appointment displayed in an [OiScheduler].
@immutable
class OiScheduleSlot {
  /// Creates an [OiScheduleSlot].
  const OiScheduleSlot({
    required this.key,
    required this.title,
    required this.start,
    required this.end,
    this.color,
    this.data,
  });

  /// A unique identifier for this slot.
  final Object key;

  /// The display title for the slot.
  final String title;

  /// The start date/time of the slot.
  final DateTime start;

  /// The end date/time of the slot.
  final DateTime end;

  /// An optional color for the slot chip.
  final Color? color;

  /// Optional arbitrary data associated with this slot.
  final Map<String, dynamic>? data;
}

/// Scheduler display mode.
///
/// Determines whether the scheduler shows a single day or a full week.
enum OiSchedulerMode {
  /// A single day view.
  day,

  /// A full week view.
  week,
}

/// A day/week schedule view for managing time-based appointments.
///
/// Supports navigation between days/weeks, slot display, and interaction
/// callbacks for tapping slots, tapping empty time cells, and moving slots.
///
/// {@category Composites}
class OiScheduler extends StatefulWidget {
  /// Creates an [OiScheduler].
  const OiScheduler({
    required this.slots,
    required this.label,
    super.key,
    this.date,
    this.mode = OiSchedulerMode.day,
    this.startHour = 8,
    this.endHour = 18,
    this.onSlotTap,
    this.onTimeSlotTap,
    this.onSlotMove,
  });

  /// The list of schedule slots to display.
  final List<OiScheduleSlot> slots;

  /// An accessibility label describing this scheduler.
  final String label;

  /// The date the scheduler focuses on. Defaults to today.
  final DateTime? date;

  /// The display mode: day or week.
  final OiSchedulerMode mode;

  /// The first hour displayed in the schedule grid.
  final int startHour;

  /// The last hour displayed in the schedule grid (exclusive).
  final int endHour;

  /// Called when an existing slot is tapped.
  final ValueChanged<OiScheduleSlot>? onSlotTap;

  /// Called when an empty time cell is tapped.
  final ValueChanged<DateTime>? onTimeSlotTap;

  /// Called when a slot is moved to a new time range.
  final void Function(OiScheduleSlot slot, DateTime start, DateTime end)?
  onSlotMove;

  @override
  State<OiScheduler> createState() => _OiSchedulerState();
}

class _OiSchedulerState extends State<OiScheduler> {
  late DateTime _focusDate;
  late OiSchedulerMode _mode;

  @override
  void initState() {
    super.initState();
    _focusDate = widget.date ?? DateTime.now();
    _mode = widget.mode;
  }

  // ── Navigation ──────────────────────────────────────────────────────────

  void _goForward() {
    setState(() {
      switch (_mode) {
        case OiSchedulerMode.day:
          _focusDate = _focusDate.add(const Duration(days: 1));
        case OiSchedulerMode.week:
          _focusDate = _focusDate.add(const Duration(days: 7));
      }
    });
  }

  void _goBackward() {
    setState(() {
      switch (_mode) {
        case OiSchedulerMode.day:
          _focusDate = _focusDate.subtract(const Duration(days: 1));
        case OiSchedulerMode.week:
          _focusDate = _focusDate.subtract(const Duration(days: 7));
      }
    });
  }

  void _setMode(OiSchedulerMode mode) {
    setState(() => _mode = mode);
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  /// Whether [a] and [b] fall on the same calendar day.
  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Returns the start of the week (Monday) containing [_focusDate].
  DateTime _weekStart() {
    final offset = (_focusDate.weekday - DateTime.monday + 7) % 7;
    return DateTime(_focusDate.year, _focusDate.month, _focusDate.day - offset);
  }

  /// The ordered day-of-week headers starting from Monday.
  static const _dayHeaders = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// The number of hour rows to display.
  int get _hourCount => widget.endHour - widget.startHour;

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
      case OiSchedulerMode.day:
        final m = months[_focusDate.month - 1];
        return '${_focusDate.day} $m ${_focusDate.year}';
      case OiSchedulerMode.week:
        final ws = _weekStart();
        final we = ws.add(const Duration(days: 6));
        return '${ws.day}/${ws.month} - ${we.day}/${we.month} ${we.year}';
    }
  }

  /// Returns slots that overlap the given [date] and [hour].
  List<OiScheduleSlot> _slotsAt(DateTime date, int hour) {
    return widget.slots.where((s) {
      if (!_sameDay(s.start, date) && !_sameDay(s.end, date)) return false;
      return s.start.hour <= hour && s.end.hour > hour;
    }).toList();
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          _buildModeSelector(context),
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
            key: const ValueKey('scheduler_back'),
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
                key: const ValueKey('scheduler_header_title'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
            ),
          ),
          GestureDetector(
            key: const ValueKey('scheduler_forward'),
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
          for (final mode in OiSchedulerMode.values)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                key: ValueKey('scheduler_mode_${mode.name}'),
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

  Widget _buildBody(BuildContext context) {
    switch (_mode) {
      case OiSchedulerMode.day:
        return _buildDayView(context);
      case OiSchedulerMode.week:
        return _buildWeekView(context);
    }
  }

  // ── Day view ────────────────────────────────────────────────────────────

  Widget _buildDayView(BuildContext context) {
    final colors = context.colors;

    return ListView.builder(
      itemCount: _hourCount,
      itemBuilder: (context, index) {
        final hour = widget.startHour + index;
        final cellTime = DateTime(
          _focusDate.year,
          _focusDate.month,
          _focusDate.day,
          hour,
        );
        final hourSlots = _slotsAt(_focusDate, hour);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTimeSlotTap != null
              ? () => widget.onTimeSlotTap!(cellTime)
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
                  child: hourSlots.isEmpty
                      ? const SizedBox.shrink()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final slot in hourSlots)
                              Expanded(
                                child: GestureDetector(
                                  onTap: widget.onSlotTap != null
                                      ? () => widget.onSlotTap!(slot)
                                      : null,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    margin: const EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                      color: slot.color ?? colors.primary.base,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      slot.title,
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

  // ── Week view ───────────────────────────────────────────────────────────

  Widget _buildWeekView(BuildContext context) {
    final colors = context.colors;
    final ws = _weekStart();

    return Column(
      children: [
        // Day headers.
        Row(
          children: [
            const SizedBox(width: 48),
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Builder(
                    builder: (_) {
                      final d = ws.add(Duration(days: i));
                      return Text(
                        '${_dayHeaders[i]} ${d.day}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.normal,
                          color: colors.textMuted,
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
            itemCount: _hourCount,
            itemBuilder: (context, index) {
              final hour = widget.startHour + index;
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
    final cellSlots = _slotsAt(date, hour);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTimeSlotTap != null
          ? () => widget.onTimeSlotTap!(cellTime)
          : null,
      child: Container(
        margin: const EdgeInsets.all(0.5),
        decoration: BoxDecoration(
          border: Border.all(color: colors.borderSubtle.withValues(alpha: 0.3)),
        ),
        child: cellSlots.isEmpty
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final slot in cellSlots.take(1))
                    Expanded(
                      child: GestureDetector(
                        onTap: widget.onSlotTap != null
                            ? () => widget.onSlotTap!(slot)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          color: slot.color ?? colors.primary.base,
                          child: Text(
                            slot.title,
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
}
