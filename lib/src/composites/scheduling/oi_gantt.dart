import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_mixin.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/settings/oi_gantt_settings.dart';

/// A task in the Gantt chart.
///
/// Represents a single work item displayed as a horizontal bar in [OiGantt].
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

  /// The start date of the task.
  final DateTime start;

  /// The end date of the task.
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
  final DateTime? viewStart;

  /// The end of the visible date range. Defaults to the latest task end.
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

  @override
  State<OiGantt> createState() => _OiGanttState();
}

class _OiGanttState extends State<OiGantt>
    with OiSettingsMixin<OiGantt, OiGanttSettings> {
  late ScrollController _horizontalScroll;

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
    _horizontalScroll = ScrollController();
    _horizontalScroll.addListener(_onScroll);
    if (settingsLoaded && settingsDriver != null) {
      _applySettings(currentSettings);
    }
  }

  void _onScroll() {
    updateSettings(_toSettings(), debounce: widget.settingsSaveDebounce);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newDriver = widget.settingsDriver ?? OiSettingsProvider.of(context);
    if (newDriver != _resolvedDriver) {
      _resolvedDriver = newDriver;
      if (settingsLoaded) {
        unawaited(reloadSettings());
      }
    }
    if (settingsLoaded && settingsDriver != null) {
      _applySettings(currentSettings);
    }
  }

  void _applySettings(OiGanttSettings settings) {
    if (settings.scrollPosition > 0 && _horizontalScroll.hasClients) {
      _horizontalScroll.jumpTo(settings.scrollPosition);
    }
  }

  OiGanttSettings _toSettings() {
    return OiGanttSettings(
      scrollPosition: _horizontalScroll.hasClients
          ? _horizontalScroll.offset
          : 0.0,
    );
  }

  @override
  void dispose() {
    _horizontalScroll.dispose();
    super.dispose();
  }

  // ── Computed properties ───────────────────────────────────────────────────

  /// The effective start of the visible date range.
  DateTime get _viewStart {
    if (widget.viewStart != null) return _dateOnly(widget.viewStart!);
    if (widget.tasks.isEmpty) return _dateOnly(DateTime.now());
    return _dateOnly(
      widget.tasks.map((t) => t.start).reduce((a, b) => a.isBefore(b) ? a : b),
    );
  }

  /// The effective end of the visible date range.
  DateTime get _viewEnd {
    if (widget.viewEnd != null) return _dateOnly(widget.viewEnd!);
    if (widget.tasks.isEmpty) {
      return _dateOnly(DateTime.now().add(const Duration(days: 30)));
    }
    return _dateOnly(
      widget.tasks.map((t) => t.end).reduce((a, b) => a.isAfter(b) ? a : b),
    ).add(const Duration(days: 1));
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

  /// The total number of days in the view range.
  int get _totalDays => _viewEnd.difference(_viewStart).inDays;

  /// The total width of the timeline area.
  double get _timelineWidth => _totalDays * _columnWidth;

  /// The height of each task row.
  static const _rowHeight = 36.0;

  /// The width of the label column on the left.
  static const _labelColumnWidth = 160.0;

  /// Strips time from a [DateTime].
  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// Returns the horizontal offset of a date within the timeline.
  double _dateToX(DateTime date) {
    final d = _dateOnly(date);
    final daysDiff = d.difference(_viewStart).inDays;
    return daysDiff * _columnWidth;
  }

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

    return Semantics(
      label: widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTimelineHeader(context),
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
                      controller: _horizontalScroll,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: math.max(_timelineWidth, 100),
                        child: Stack(
                          children: [
                            // Weekend shading.
                            if (widget.showWeekends)
                              _buildWeekendShading(context),
                            // Dependency arrows (behind bars).
                            if (widget.showDependencies)
                              IgnorePointer(
                                child: CustomPaint(
                                  size: Size(
                                    math.max(_timelineWidth, 100),
                                    rows.length * _rowHeight,
                                  ),
                                  painter: _DependencyPainter(
                                    tasks: widget.tasks,
                                    rows: rows,
                                    viewStart: _viewStart,
                                    columnWidth: _columnWidth,
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
                                    index,
                                  ),
                              ],
                            ),
                            // Today line (on top of bars).
                            if (widget.showToday) _buildTodayLine(context),
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

  Widget _buildTimelineHeader(BuildContext context) {
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
                'Task',
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
              controller: _horizontalScroll,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: math.max(_timelineWidth, 100),
                child: CustomPaint(
                  size: Size(math.max(_timelineWidth, 100), 28),
                  painter: _HeaderPainter(
                    viewStart: _viewStart,
                    totalDays: _totalDays,
                    columnWidth: _columnWidth,
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

  Widget _buildTimelineRow(BuildContext context, _GanttRow row, int index) {
    if (row.isHeader) {
      return const SizedBox(height: _rowHeight);
    }

    final task = row.task!;
    final colors = context.colors;
    final barColor = task.color ?? colors.primary.base;
    // Blend bar color at 30% over the background to produce an opaque tint.
    final barTint = Color.lerp(colors.background, barColor, 0.3)!;
    final startX = _dateToX(task.start);
    final endX = _dateToX(task.end);
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

  Widget _buildWeekendShading(BuildContext context) {
    final colors = context.colors;
    return Positioned.fill(
      child: CustomPaint(
        painter: _WeekendPainter(
          viewStart: _viewStart,
          totalDays: _totalDays,
          columnWidth: _columnWidth,
          shadingColor: colors.surfaceSubtle,
        ),
      ),
    );
  }

  Widget _buildTodayLine(BuildContext context) {
    final colors = context.colors;
    final today = _dateOnly(DateTime.now());
    final todayX = _dateToX(today);
    if (todayX < 0 || todayX > _timelineWidth) {
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
    required this.viewStart,
    required this.columnWidth,
    required this.rowHeight,
    required this.arrowColor,
  });

  final List<OiGanttTask> tasks;
  final List<_GanttRow> rows;
  final DateTime viewStart;
  final double columnWidth;
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
        final fromX = _dateToX(fromTask.end);
        final fromY = fromIdx * rowHeight + rowHeight / 2;
        final toX = _dateToX(toTask.start);
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

  double _dateToX(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final daysDiff = d.difference(viewStart).inDays;
    return daysDiff * columnWidth;
  }

  @override
  bool shouldRepaint(_DependencyPainter oldDelegate) =>
      oldDelegate.tasks != tasks ||
      oldDelegate.viewStart != viewStart ||
      oldDelegate.columnWidth != columnWidth;
}

// ── Header painter ────────────────────────────────────────────────────────────

/// Paints the timeline header labels (dates).
class _HeaderPainter extends CustomPainter {
  const _HeaderPainter({
    required this.viewStart,
    required this.totalDays,
    required this.columnWidth,
    required this.zoom,
    required this.textColor,
    required this.lineColor,
  });

  final DateTime viewStart;
  final int totalDays;
  final double columnWidth;
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

    for (var d = 0; d < totalDays; d += step) {
      final date = viewStart.add(Duration(days: d));
      final x = d * columnWidth;

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
      oldDelegate.viewStart != viewStart ||
      oldDelegate.totalDays != totalDays ||
      oldDelegate.columnWidth != columnWidth ||
      oldDelegate.zoom != zoom;
}

// ── Weekend painter ───────────────────────────────────────────────────────────

/// Paints shaded rectangles on weekend columns.
class _WeekendPainter extends CustomPainter {
  const _WeekendPainter({
    required this.viewStart,
    required this.totalDays,
    required this.columnWidth,
    required this.shadingColor,
  });

  final DateTime viewStart;
  final int totalDays;
  final double columnWidth;
  final Color shadingColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = shadingColor;

    for (var d = 0; d < totalDays; d++) {
      final date = viewStart.add(Duration(days: d));
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
      oldDelegate.viewStart != viewStart ||
      oldDelegate.totalDays != totalDays ||
      oldDelegate.columnWidth != columnWidth;
}
