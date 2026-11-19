import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_mixin.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/settings/oi_gantt_settings.dart';
import 'package:obers_ui/src/utils/calendar_utils.dart';

/// A task in the Gantt chart.
///
/// Represents a single work item displayed as a horizontal bar in [OiGantt].
///
/// The task runs from [start] up to, but not including, [end]: both are
/// points in time and the bar spans exactly the time between them. A task
/// from 5 Jan 00:00 to 6 Jan 00:00 is one day long; one that should fill the
/// 5th and the 6th ends on 7 Jan 00:00. The time of day counts, so a task
/// from 09:00 to 17:00 on one day covers a third of that day's column.
@immutable
class OiGanttTask {
  /// Creates an [OiGanttTask].
  const OiGanttTask({
    required this.key,
    required this.label,
    required this.start,
    required this.end,
    this.progress = 0.0,
    this.color,
    this.group,
    this.dependsOn,
  });

  /// A unique identifier for this task.
  final Object key;

  /// The display label for this task.
  final String label;

  /// The moment the task starts (inclusive), including the time of day.
  final DateTime start;

  /// The moment the task ends (exclusive), including the time of day.
  ///
  /// For a task that lasts through a whole calendar day, pass midnight of
  /// the following day.
  final DateTime end;

  /// The completion progress from 0.0 to 1.0.
  final double progress;

  /// An optional color for the task bar.
  final Color? color;

  /// An optional group identifier for grouping tasks.
  final Object? group;

  /// Keys of tasks this task depends on.
  final List<Object>? dependsOn;
}

/// Zoom level for the Gantt chart.
///
/// Determines the time scale used for the horizontal axis.
enum OiGanttZoom {
  /// Each column represents one day.
  day,

  /// Each column represents one week.
  week,

  /// Each column represents one month.
  month,

  /// Each column represents one quarter (3 months).
  quarter,
}

/// A Gantt chart for project scheduling.
///
/// Shows tasks as horizontal bars on a timeline with dependencies,
/// grouping, and zoom levels.
///
/// {@category Composites}
class OiGantt extends StatefulWidget {
  /// Creates an [OiGantt].
  const OiGantt({
    required this.tasks,
    required this.label,
    this.taskColumnLabel = 'Task',
    super.key,
    this.viewStart,
    this.viewEnd,
    this.zoom = OiGanttZoom.week,
    this.onTaskTap,
    this.onTaskMove,
    this.onTaskResize,
    this.showDependencies = true,
    this.showToday = true,
    this.showWeekends = true,
    this.groupBy,
    this.groupHeader,
    this.settingsDriver,
    this.settingsKey,
    this.settingsNamespace = 'oi_gantt',
    this.settingsSaveDebounce = const Duration(milliseconds: 500),
  });

  /// The list of tasks to display.
  final List<OiGanttTask> tasks;

  /// An accessibility label describing this Gantt chart.
  final String label;

  /// The start of the visible date range. Defaults to the earliest task start.
  ///
  /// The timeline shows whole days and starts at midnight of this date.
  final DateTime? viewStart;

  /// The end of the visible date range (exclusive, like [OiGanttTask.end]).
  /// Defaults to the latest task end.
  ///
  /// The timeline shows whole days: it ends at this moment when it is a
  /// midnight and otherwise at the end of that day.
  final DateTime? viewEnd;

  /// The zoom level controlling horizontal scale.
  final OiGanttZoom zoom;

  /// Called when a task bar is tapped.
  final ValueChanged<OiGanttTask>? onTaskTap;

  /// Called when a task is moved to a new time range.
  final void Function(OiGanttTask task, DateTime start, DateTime end)?
  onTaskMove;

  /// Called when a task is resized to a new end date.
  final void Function(OiGanttTask task, DateTime newEnd)? onTaskResize;

  /// Whether to draw dependency arrows between tasks.
  final bool showDependencies;

  /// Whether to draw a vertical line at today's date.
  final bool showToday;

  /// Whether to shade weekend columns.
  final bool showWeekends;

  /// A function that extracts a group key from a task.
  final Object Function(OiGanttTask task)? groupBy;

  /// A builder for group header widgets.
  final Widget Function(Object key)? groupHeader;

  // ── Settings persistence ──────────────────────────────────────────────────

  /// Driver used to persist settings. When `null` settings are not persisted.
  final OiSettingsDriver? settingsDriver;

  /// Sub-key scoping this gantt's settings within [settingsNamespace].
  final String? settingsKey;

  /// Top-level namespace for settings storage.
  final String settingsNamespace;

  /// Debounce duration for auto-saving settings after changes.
  final Duration settingsSaveDebounce;

  /// Header of the task column.
  final String taskColumnLabel;

  @override
  State<OiGantt> createState() => _OiGanttState();
}

class _OiGanttState extends State<OiGantt>
    with OiSettingsMixin<OiGantt, OiGanttSettings> {
  /// Scrolls the task bars. Its offset is the one that is persisted.
  final ScrollController _bodyScroll = ScrollController();

  /// Scrolls the date header. A controller reports one offset, so the two
  /// scroll views each get their own and are kept at the same offset.
  final ScrollController _headerScroll = ScrollController();

  /// Whether the settings of the initial load have been applied.
  bool _initialSettingsApplied = false;

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
  OiGanttSettings get defaultSettings => const OiGanttSettings();

  @override
  OiGanttSettings deserializeSettings(Map<String, dynamic> json) =>
      OiGanttSettings.fromJson(json);

  @override
  OiGanttSettings mergeSettings(
    OiGanttSettings saved,
    OiGanttSettings defaults,
  ) => saved.mergeWith(defaults);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    _resolvedDriver = widget.settingsDriver;
    super.initState();
    _bodyScroll.addListener(_onBodyScroll);
    _headerScroll.addListener(_onHeaderScroll);
    if (settingsLoaded && settingsDriver != null) {
      _applySettings(currentSettings);
    }
  }

  void _onBodyScroll() {
    _mirrorOffset(from: _bodyScroll, to: _headerScroll);
    updateSettings(_toSettings(), debounce: widget.settingsSaveDebounce);
  }

  void _onHeaderScroll() => _mirrorOffset(from: _headerScroll, to: _bodyScroll);

  /// Moves [to] to the offset of [from] unless it is already there, which
  /// also ends the echo when [to] reports the jump back.
  void _mirrorOffset({
    required ScrollController from,
    required ScrollController to,
  }) {
    if (!from.hasClients || !to.hasClients) return;
    final offset = from.offset;
    if (to.offset != offset) to.jumpTo(offset);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newDriver = widget.settingsDriver ?? OiSettingsProvider.of(context);
    if (newDriver != _resolvedDriver) {
      _resolvedDriver = newDriver;
      if (settingsLoaded) {
        unawaited(
          reloadSettings().then((_) {
            if (mounted) _applySettings(currentSettings);
          }),
        );
      }
    }
    if (settingsLoaded && settingsDriver != null) {
      _applySettings(currentSettings);
    }
  }

  /// Restores the saved scroll position once the timeline is laid out.
  ///
  /// Settings arrive before the scroll views exist or know how far they can
  /// scroll, so the jump waits for the end of the frame.
  void _applySettings(OiGanttSettings settings) {
    final target = settings.scrollPosition;
    if (target <= 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_bodyScroll.hasClients) return;
      final position = _bodyScroll.position;
      if (!position.hasContentDimensions) return;
      final offset = target.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if (offset != position.pixels) _bodyScroll.jumpTo(offset);
    });
  }

  OiGanttSettings _toSettings() {
    return OiGanttSettings(
      scrollPosition: _bodyScroll.hasClients ? _bodyScroll.offset : 0.0,
    );
  }

  @override
  void dispose() {
    _bodyScroll.dispose();
    _headerScroll.dispose();
    super.dispose();
  }

  // ── Computed properties ───────────────────────────────────────────────────

  /// Resolves the visible date range and scale.
  ///
  /// Walks all tasks, so [build] calls it once and hands the result down.
  _GanttViewport _resolveViewport() {
    final tasks = widget.tasks;

    var start = widget.viewStart;
    if (start == null) {
      for (final task in tasks) {
        final taskStart = task.start;
        if (start == null || taskStart.isBefore(start)) start = taskStart;
      }
    }
    start = _dateOnly(start ?? DateTime.now());

    var end = widget.viewEnd;
    if (end == null) {
      for (final task in tasks) {
        final taskEnd = task.end;
        if (end == null || taskEnd.isAfter(end)) end = taskEnd;
      }
    }
    // Ends are exclusive: a midnight closes the day before it, any later
    // time needs the rest of its day shown as well.
    end = end == null
        ? OiCalendarUtils.addDays(DateTime.now(), 30)
        : _endOfLastDay(end);

    return _GanttViewport(
      start: start,
      // Always at least one column, e.g. for a single milestone at midnight.
      totalDays: math.max(1, OiCalendarUtils.daysBetween(start, end)),
      columnWidth: _columnWidth,
    );
  }

  /// The midnight at which the last day containing time before [end] is
  /// over: [end] itself when it is a midnight, else the following midnight.
  DateTime _endOfLastDay(DateTime end) {
    final midnight = _dateOnly(end);
    return end.isAfter(midnight) ? OiCalendarUtils.addDays(end, 1) : midnight;
  }

  /// The width of each time column in logical pixels.
  double get _columnWidth {
    switch (widget.zoom) {
      case OiGanttZoom.day:
        return 40;
      case OiGanttZoom.week:
        return 24;
      case OiGanttZoom.month:
        return 8;
      case OiGanttZoom.quarter:
        return 3;
    }
  }

  /// The height of each task row.
  static const _rowHeight = 36.0;

  /// The width of the label column on the left.
  static const _labelColumnWidth = 160.0;

  /// Strips time from a [DateTime].
  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// Ordered task list, optionally grouped.
  List<_GanttRow> get _rows {
    final rows = <_GanttRow>[];
    if (widget.groupBy != null) {
      final groups = <Object, List<OiGanttTask>>{};
      for (final task in widget.tasks) {
        final key = widget.groupBy!(task);
        groups.putIfAbsent(key, () => []).add(task);
      }
      for (final entry in groups.entries) {
        rows.add(_GanttRow.header(entry.key));
        for (final task in entry.value) {
          rows.add(_GanttRow.task(task));
        }
      }
    } else {
      for (final task in widget.tasks) {
        rows.add(_GanttRow.task(task));
      }
    }
    return rows;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    final viewport = _resolveViewport();
    final timelineWidth = math.max<double>(viewport.width, 100);

    if (settingsLoaded && !_initialSettingsApplied) {
      _initialSettingsApplied = true;
      _applySettings(currentSettings);
    }

    return Semantics(
      label: widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTimelineHeader(context, viewport, timelineWidth),
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label column.
                  SizedBox(
                    width: _labelColumnWidth,
                    child: Column(
                      children: [
                        for (var index = 0; index < rows.length; index++)
                          _buildLabelRow(context, rows[index]),
                      ],
                    ),
                  ),
                  // Timeline area.
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _bodyScroll,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: timelineWidth,
                        child: Stack(
                          children: [
                            // Weekend shading.
                            if (widget.showWeekends)
                              _buildWeekendShading(context, viewport),
                            // Dependency arrows (behind bars).
                            if (widget.showDependencies)
                              IgnorePointer(
                                child: CustomPaint(
                                  size: Size(
                                    timelineWidth,
                                    rows.length * _rowHeight,
                                  ),
                                  painter: _DependencyPainter(
                                    tasks: widget.tasks,
                                    rows: rows,
                                    viewport: viewport,
                                    rowHeight: _rowHeight,
                                    arrowColor: context.colors.textMuted,
                                  ),
                                ),
                              ),
                            // Task bars.
                            Column(
                              children: [
                                for (
                                  var index = 0;
                                  index < rows.length;
                                  index++
                                )
                                  _buildTimelineRow(
                                    context,
                                    rows[index],
                                    viewport,
                                  ),
                              ],
                            ),
                            // Today line (on top of bars).
                            if (widget.showToday)
                              _buildTodayLine(context, viewport),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineHeader(
    BuildContext context,
    _GanttViewport viewport,
    double timelineWidth,
  ) {
    final colors = context.colors;
    return Container(
      height: 28,
      color: colors.surfaceSubtle,
      child: Row(
        children: [
          SizedBox(
            width: _labelColumnWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                widget.taskColumnLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: colors.text,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _headerScroll,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: timelineWidth,
                child: CustomPaint(
                  size: Size(timelineWidth, 28),
                  painter: _HeaderPainter(
                    viewport: viewport,
                    zoom: widget.zoom,
                    textColor: colors.textMuted,
                    lineColor: colors.borderSubtle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelRow(BuildContext context, _GanttRow row) {
    final colors = context.colors;
    if (row.isHeader) {
      if (widget.groupHeader != null) {
        return SizedBox(
          height: _rowHeight,
          child: widget.groupHeader!(row.groupKey!),
        );
      }
      return Container(
        key: ValueKey('gantt_group_${row.groupKey}'),
        height: _rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        color: colors.surfaceSubtle,
        alignment: Alignment.centerLeft,
        child: Text(
          row.groupKey.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: colors.text,
          ),
        ),
      );
    }
    return SizedBox(
      height: _rowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            row.task!.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: colors.text),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineRow(
    BuildContext context,
    _GanttRow row,
    _GanttViewport viewport,
  ) {
    if (row.isHeader) {
      return const SizedBox(height: _rowHeight);
    }

    final task = row.task!;
    final colors = context.colors;
    final barColor = task.color ?? colors.primary.base;
    // Blend bar color at 30% over the background to produce an opaque tint.
    final barTint = Color.lerp(colors.background, barColor, 0.3)!;
    final startX = viewport.dateToX(task.start);
    final endX = viewport.dateToX(task.end);
    // A task without a duration keeps a sliver so it stays visible.
    final barWidth = math.max<double>(endX - startX, 4);

    return SizedBox(
      height: _rowHeight,
      child: Stack(
        children: [
          Positioned(
            left: startX,
            top: 6,
            child: GestureDetector(
              onTap: widget.onTaskTap != null
                  ? () => widget.onTaskTap!(task)
                  : null,
              child: Container(
                key: ValueKey('gantt_task_${task.key}'),
                width: barWidth,
                height: _rowHeight - 12,
                decoration: BoxDecoration(
                  color: barTint,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: barColor),
                ),
                child: Stack(
                  children: [
                    // Progress fill.
                    FractionallySizedBox(
                      widthFactor: task.progress.clamp(0, 1),
                      child: Container(
                        key: ValueKey('gantt_progress_${task.key}'),
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Label on the bar.
                    if (barWidth > 40)
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              task.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: colors.textOnPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekendShading(BuildContext context, _GanttViewport viewport) {
    final colors = context.colors;
    return Positioned.fill(
      child: CustomPaint(
        painter: _WeekendPainter(
          viewport: viewport,
          shadingColor: colors.surfaceSubtle,
        ),
      ),
    );
  }

  Widget _buildTodayLine(BuildContext context, _GanttViewport viewport) {
    final colors = context.colors;
    final today = _dateOnly(DateTime.now());
    final todayX = viewport.dateToX(today);
    if (todayX < 0 || todayX > viewport.width) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: todayX,
      top: 0,
      bottom: 0,
      child: Container(
        key: const ValueKey('gantt_today_line'),
        width: 2,
        color: colors.error.base,
      ),
    );
  }
}

// ── Viewport ──────────────────────────────────────────────────────────────────

/// The visible date range of the Gantt chart and its horizontal scale.
@immutable
class _GanttViewport {
  const _GanttViewport({
    required this.start,
    required this.totalDays,
    required this.columnWidth,
  });

  /// Local midnight of the first visible day.
  final DateTime start;

  /// The number of day columns.
  final int totalDays;

  /// The width of one day column in logical pixels.
  final double columnWidth;

  /// The width of all day columns.
  double get width => totalDays * columnWidth;

  /// The date of the day column at [index].
  DateTime dayAt(int index) => OiCalendarUtils.addDays(start, index);

  /// The horizontal offset of [date] within the timeline, with the time of
  /// day as a fraction of its column.
  double dateToX(DateTime date) =>
      OiCalendarUtils.fractionalDaysBetween(start, date) * columnWidth;

  @override
  bool operator ==(Object other) =>
      other is _GanttViewport &&
      other.start == start &&
      other.totalDays == totalDays &&
      other.columnWidth == columnWidth;

  @override
  int get hashCode => Object.hash(start, totalDays, columnWidth);
}

// ── Row model ─────────────────────────────────────────────────────────────────

/// Internal model for a row in the Gantt chart (either a task or a group header).
class _GanttRow {
  const _GanttRow._({this.task, this.groupKey});

  /// Creates a task row.
  factory _GanttRow.task(OiGanttTask task) => _GanttRow._(task: task);

  /// Creates a group header row.
  factory _GanttRow.header(Object key) => _GanttRow._(groupKey: key);

  final OiGanttTask? task;
  final Object? groupKey;
  bool get isHeader => task == null;
}

// ── Dependency painter ────────────────────────────────────────────────────────

/// Paints dependency arrows between tasks.
class _DependencyPainter extends CustomPainter {
  const _DependencyPainter({
    required this.tasks,
    required this.rows,
    required this.viewport,
    required this.rowHeight,
    required this.arrowColor,
  });

  final List<OiGanttTask> tasks;
  final List<_GanttRow> rows;
  final _GanttViewport viewport;
  final double rowHeight;
  final Color arrowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = arrowColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final arrowPaint = Paint()
      ..color = arrowColor
      ..style = PaintingStyle.fill;

    // Build a lookup from task key to row index.
    final taskRowIndex = <Object, int>{};
    for (var i = 0; i < rows.length; i++) {
      if (rows[i].task != null) {
        taskRowIndex[rows[i].task!.key] = i;
      }
    }

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      if (row.task == null || row.task!.dependsOn == null) continue;
      for (final depKey in row.task!.dependsOn!) {
        final fromIdx = taskRowIndex[depKey];
        if (fromIdx == null) continue;
        final fromTask = rows[fromIdx].task!;
        final toTask = row.task!;

        // Arrow from end of fromTask to start of toTask.
        final fromX = viewport.dateToX(fromTask.end);
        final fromY = fromIdx * rowHeight + rowHeight / 2;
        final toX = viewport.dateToX(toTask.start);
        final toY = i * rowHeight + rowHeight / 2;

        // Draw the connecting line.
        final path = Path()
          ..moveTo(fromX, fromY)
          ..lineTo(fromX + 8, fromY)
          ..lineTo(fromX + 8, toY)
          ..lineTo(toX, toY);
        canvas.drawPath(path, paint);

        // Draw arrowhead.
        final arrowPath = Path()
          ..moveTo(toX, toY)
          ..lineTo(toX - 5, toY - 3)
          ..lineTo(toX - 5, toY + 3)
          ..close();
        canvas.drawPath(arrowPath, arrowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_DependencyPainter oldDelegate) =>
      oldDelegate.tasks != tasks || oldDelegate.viewport != viewport;
}

// ── Header painter ────────────────────────────────────────────────────────────

/// Paints the timeline header labels (dates).
class _HeaderPainter extends CustomPainter {
  const _HeaderPainter({
    required this.viewport,
    required this.zoom,
    required this.textColor,
    required this.lineColor,
  });

  final _GanttViewport viewport;
  final OiGanttZoom zoom;
  final Color textColor;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.5;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Determine label step based on zoom.
    final step = switch (zoom) {
      OiGanttZoom.day => 1,
      OiGanttZoom.week => 7,
      OiGanttZoom.month => 30,
      OiGanttZoom.quarter => 90,
    };

    for (var d = 0; d < viewport.totalDays; d += step) {
      final date = viewport.dayAt(d);
      final x = d * viewport.columnWidth;

      // Vertical grid line.
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);

      // Date label.
      final label = switch (zoom) {
        OiGanttZoom.day => '${date.day}/${date.month}',
        OiGanttZoom.week => '${date.day}/${date.month}',
        OiGanttZoom.month => '${date.month}/${date.year}',
        OiGanttZoom.quarter => 'Q${((date.month - 1) ~/ 3) + 1} ${date.year}',
      };

      textPainter
        ..text = TextSpan(
          text: label,
          style: TextStyle(fontSize: 9, color: textColor),
        )
        ..layout()
        ..paint(canvas, Offset(x + 2, 4));
    }
  }

  @override
  bool shouldRepaint(_HeaderPainter oldDelegate) =>
      oldDelegate.viewport != viewport || oldDelegate.zoom != zoom;
}

// ── Weekend painter ───────────────────────────────────────────────────────────

/// Paints shaded rectangles on weekend columns.
class _WeekendPainter extends CustomPainter {
  const _WeekendPainter({required this.viewport, required this.shadingColor});

  final _GanttViewport viewport;
  final Color shadingColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = shadingColor;

    final columnWidth = viewport.columnWidth;
    for (var d = 0; d < viewport.totalDays; d++) {
      final date = viewport.dayAt(d);
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        canvas.drawRect(
          Rect.fromLTWH(d * columnWidth, 0, columnWidth, size.height),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_WeekendPainter oldDelegate) =>
      oldDelegate.viewport != viewport;
}
