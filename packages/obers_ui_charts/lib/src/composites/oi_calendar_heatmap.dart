import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';
import 'package:obers_ui_charts/src/models/oi_color_scale.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OiCalendarHeatmap
// ─────────────────────────────────────────────────────────────────────────────

/// A GitHub-style calendar heatmap that renders activity over a date range.
///
/// Columns represent weeks, rows represent days of the week (0 = weekStart
/// through 6). Each cell is colored according to its value using [colorScale].
/// Month labels are displayed above the column headers when
/// [showMonthLabels] is `true`. Day-of-week labels (Mon, Wed, Fri) are shown
/// on the left when [showDayLabels] is `true`.
///
/// ## Generics
///
/// Supply any domain type `T`. Provide:
/// - [dateMapper] — extracts the `DateTime` from a domain object.
/// - [valueMapper] — extracts the numeric value from a domain object.
///
/// Multiple items mapping to the same date are summed.
///
/// ## Date range
///
/// [startDate] and [endDate] bound the visible grid. When omitted they default
/// to one year ending today.
///
/// ## Color scale
///
/// [colorScale] maps values to colors. Defaults to a linear green gradient
/// matching the GitHub contribution style. When a date has no data, the
/// [colorScale]'s minimum color is used.
///
/// ## Interaction
///
/// On pointer devices a tooltip is shown on hover with the date and value.
///
/// ## Accessibility
///
/// [semanticLabel] overrides the default label built from [label].
///
/// {@category Composites}
class OiCalendarHeatmap<T> extends StatefulWidget {
  /// Creates an [OiCalendarHeatmap].
  const OiCalendarHeatmap({
    required this.label,
    required this.data,
    required this.dateMapper,
    required this.valueMapper,
    super.key,
    this.startDate,
    this.endDate,
    this.colorScale,
    this.weekStartsOn = DateTime.monday,
    this.showMonthLabels = true,
    this.showDayLabels = true,
    this.cellSize = 12,
    this.cellSpacing = 2,
    this.behaviors = const [],
    this.controller,
    this.compact,
    this.semanticLabel,
  });

  /// Accessibility label for the chart.
  final String label;

  /// The domain objects providing activity data.
  final List<T> data;

  /// Extracts the date from a domain object.
  final DateTime Function(T item) dateMapper;

  /// Extracts the numeric value from a domain object.
  final num Function(T item) valueMapper;

  /// First date to display. Defaults to one year before [endDate].
  final DateTime? startDate;

  /// Last date to display. Defaults to today.
  final DateTime? endDate;

  /// Mapping from numeric values to cell colors.
  ///
  /// Defaults to a linear green scale from `#ebedf0` → `#216e39`
  /// spanning the observed data range.
  final OiColorScale? colorScale;

  /// Day of week that starts each column row.
  ///
  /// Use [DateTime.monday] through [DateTime.sunday]. Defaults to
  /// [DateTime.monday].
  final int weekStartsOn;

  /// Whether to render month labels above the week columns.
  final bool showMonthLabels;

  /// Whether to render Mon / Wed / Fri labels on the left axis.
  final bool showDayLabels;

  /// Width and height of each cell in logical pixels. Defaults to 12.
  final double cellSize;

  /// Gap between cells in logical pixels. Defaults to 2.
  final double cellSpacing;

  /// Composable interaction behaviors.
  final List<OiChartBehavior> behaviors;

  /// External chart controller.
  final OiChartController? controller;

  /// When `true`, month and day labels are hidden.
  ///
  /// When `null`, compactness is determined by available width.
  final bool? compact;

  /// Override for the semantic label. Defaults to [label].
  final String? semanticLabel;

  @override
  State<OiCalendarHeatmap<T>> createState() => _OiCalendarHeatmapState<T>();
}

class _OiCalendarHeatmapState<T> extends State<OiCalendarHeatmap<T>> {
  static const double _compactBreakpoint = 300;

  // Hovered cell: (weekCol, dayRow).
  (int, int)? _hoveredCell;

  // ── Date helpers ──────────────────────────────────────────────────────────

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Returns the day-of-week index (0–6) for [date], adjusted so that
  /// [widget.weekStartsOn] maps to row 0.
  int _dayRow(DateTime date) {
    // DateTime.weekday: monday=1 … sunday=7
    return (date.weekday - widget.weekStartsOn + 7) % 7;
  }

  /// Returns the start of the week (i.e., the date on row 0) for [date].
  DateTime _weekStart(DateTime date) {
    final row = _dayRow(date);
    return _dateOnly(date).subtract(Duration(days: row));
  }

  // ── Compute grid ──────────────────────────────────────────────────────────

  /// Aggregates [widget.data] into a map from date-only to total value.
  Map<DateTime, num> _aggregateData() {
    final map = <DateTime, num>{};
    for (final item in widget.data) {
      final date = _dateOnly(widget.dateMapper(item));
      final value = widget.valueMapper(item);
      map[date] = (map[date] ?? 0) + value;
    }
    return map;
  }

  /// Returns the effective [DateTime] bounds for the visible grid.
  ({DateTime start, DateTime end}) _effectiveBounds() {
    final end = widget.endDate != null
        ? _dateOnly(widget.endDate!)
        : _dateOnly(DateTime.now());
    final start = widget.startDate != null
        ? _dateOnly(widget.startDate!)
        : end.subtract(const Duration(days: 364));
    return (start: start, end: end);
  }

  /// Builds the list of week-start dates spanning the full grid.
  List<DateTime> _buildWeekStarts(DateTime start, DateTime end) {
    final firstWeekStart = _weekStart(start);
    final lastWeekStart = _weekStart(end);

    final weeks = <DateTime>[];
    var current = firstWeekStart;
    while (!current.isAfter(lastWeekStart)) {
      weeks.add(current);
      current = current.add(const Duration(days: 7));
    }
    return weeks;
  }

  // ── Color scale ───────────────────────────────────────────────────────────

  OiColorScale _buildDefaultColorScale(Map<DateTime, num> aggregated) {
    var maxVal = 0.0;
    for (final v in aggregated.values) {
      if (v > maxVal) maxVal = v.toDouble();
    }
    return OiColorScale.linear(
      minColor: const Color(0xFFebedf0),
      maxColor: const Color(0xFF216e39),
      min: 0,
      max: maxVal > 0 ? maxVal : 1,
    );
  }

  // ── Month label helpers ───────────────────────────────────────────────────

  static const _monthAbbr = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const _dayAbbr = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _dayLabel(int row) {
    // Map row 0 → weekStartsOn-1, etc.
    final dow = (widget.weekStartsOn - 1 + row) % 7;
    return _dayAbbr[dow];
  }

  bool _shouldShowDayLabel(int row) {
    // Show Mon (row 0 when weekStartsOn==monday), Wed, Fri equivalent rows.
    final dow = (widget.weekStartsOn - 1 + row) % 7;
    // Monday=0, Wednesday=2, Friday=4 (0-indexed Monday start)
    return dow == 0 || dow == 2 || dow == 4;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = widget.semanticLabel ?? widget.label;
    final colors = context.colors;

    final aggregated = _aggregateData();
    final bounds = _effectiveBounds();
    final weeks = _buildWeekStarts(bounds.start, bounds.end);

    if (weeks.isEmpty) {
      return Semantics(
        label: effectiveLabel,
        child: const SizedBox.shrink(key: Key('oi_calendar_heatmap_empty')),
      );
    }

    final scale = widget.colorScale ?? _buildDefaultColorScale(aggregated);

    final cellStep = widget.cellSize + widget.cellSpacing;

    return Semantics(
      label: effectiveLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availW = constraints.maxWidth;
          final isCompact = widget.compact ?? availW < _compactBreakpoint;

          final showMonth = widget.showMonthLabels && !isCompact;
          final showDay = widget.showDayLabels && !isCompact;

          const monthLabelHeight = 18.0;
          const dayLabelWidth = 28.0;

          final monthOffset = showMonth ? monthLabelHeight : 0.0;
          final dayOffset = showDay ? dayLabelWidth : 0.0;

          final gridWidth = weeks.length * cellStep - widget.cellSpacing;
          final gridHeight = 7 * cellStep - widget.cellSpacing;

          final totalWidth = dayOffset + gridWidth;
          final totalHeight = monthOffset + gridHeight;

          return SizedBox(
            key: const Key('oi_calendar_heatmap'),
            width: totalWidth,
            height: totalHeight,
            child: Stack(
              children: [
                // Month labels.
                if (showMonth)
                  _buildMonthLabels(
                    weeks: weeks,
                    cellStep: cellStep,
                    dayOffset: dayOffset,
                    labelHeight: monthLabelHeight,
                    textColor: colors.textMuted,
                  ),

                // Day-of-week labels.
                if (showDay)
                  _buildDayLabels(
                    cellStep: cellStep,
                    monthOffset: monthOffset,
                    labelWidth: dayLabelWidth,
                    textColor: colors.textMuted,
                  ),

                // Cell grid.
                Positioned(
                  left: dayOffset,
                  top: monthOffset,
                  width: gridWidth,
                  height: gridHeight,
                  child: MouseRegion(
                    onHover: (event) {
                      final col = (event.localPosition.dx / cellStep).floor();
                      final row = (event.localPosition.dy / cellStep).floor();
                      if (col >= 0 &&
                          col < weeks.length &&
                          row >= 0 &&
                          row < 7) {
                        if (_hoveredCell != (col, row)) {
                          setState(() => _hoveredCell = (col, row));
                        }
                      }
                    },
                    onExit: (_) => setState(() => _hoveredCell = null),
                    child: CustomPaint(
                      key: const Key('oi_calendar_heatmap_painter'),
                      size: Size(gridWidth, gridHeight),
                      painter: _CalendarHeatmapPainter(
                        weeks: weeks,
                        aggregated: aggregated,
                        scale: scale,
                        cellSize: widget.cellSize,
                        cellSpacing: widget.cellSpacing,
                        startDate: bounds.start,
                        endDate: bounds.end,
                        weekStartsOn: widget.weekStartsOn,
                        emptyColor: colors.borderSubtle.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),

                // Tooltip overlay.
                if (_hoveredCell != null)
                  _buildTooltip(
                    context: context,
                    weeks: weeks,
                    aggregated: aggregated,
                    cell: _hoveredCell!,
                    cellStep: cellStep,
                    dayOffset: dayOffset,
                    monthOffset: monthOffset,
                    bounds: bounds,
                    colors: colors,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Month label row ───────────────────────────────────────────────────────

  Widget _buildMonthLabels({
    required List<DateTime> weeks,
    required double cellStep,
    required double dayOffset,
    required double labelHeight,
    required Color textColor,
  }) {
    // Show a month label above the first column that starts in a new month.
    final labels = <Widget>[];
    int? lastMonth;

    for (var i = 0; i < weeks.length; i++) {
      final weekStart = weeks[i];
      if (lastMonth != weekStart.month) {
        lastMonth = weekStart.month;
        labels.add(
          Positioned(
            left: dayOffset + i * cellStep,
            top: 0,
            child: OiLabel.caption(
              _monthAbbr[weekStart.month - 1],
              color: textColor,
            ),
          ),
        );
      }
    }

    return Stack(children: labels);
  }

  // ── Day label column ──────────────────────────────────────────────────────

  Widget _buildDayLabels({
    required double cellStep,
    required double monthOffset,
    required double labelWidth,
    required Color textColor,
  }) {
    return Positioned(
      left: 0,
      top: monthOffset,
      width: labelWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var row = 0; row < 7; row++)
            SizedBox(
              height: cellStep,
              child: _shouldShowDayLabel(row)
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: OiLabel.caption(
                          _dayLabel(row),
                          color: textColor,
                        ),
                      ),
                    )
                  : null,
            ),
        ],
      ),
    );
  }

  // ── Tooltip ───────────────────────────────────────────────────────────────

  Widget _buildTooltip({
    required BuildContext context,
    required List<DateTime> weeks,
    required Map<DateTime, num> aggregated,
    required (int, int) cell,
    required double cellStep,
    required double dayOffset,
    required double monthOffset,
    required ({DateTime start, DateTime end}) bounds,
    required OiColorScheme colors,
  }) {
    final (col, row) = cell;
    if (col >= weeks.length) return const SizedBox.shrink();

    final date = weeks[col].add(Duration(days: row));
    if (date.isBefore(bounds.start) || date.isAfter(bounds.end)) {
      return const SizedBox.shrink();
    }

    final value = aggregated[_dateOnly(date)] ?? 0;
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final tooltipText = '$dateStr: $value';

    final cellLeft = dayOffset + col * cellStep;
    final cellTop = monthOffset + row * cellStep;

    return Positioned(
      left: math.max(0, cellLeft - 20),
      top: cellTop > 40 ? cellTop - 28 : cellTop + widget.cellSize + 4,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: colors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: colors.overlay.withValues(alpha: 0.12),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: OiLabel.caption(tooltipText, color: colors.text),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter: cell grid
// ─────────────────────────────────────────────────────────────────────────────

class _CalendarHeatmapPainter extends CustomPainter {
  _CalendarHeatmapPainter({
    required this.weeks,
    required this.aggregated,
    required this.scale,
    required this.cellSize,
    required this.cellSpacing,
    required this.startDate,
    required this.endDate,
    required this.weekStartsOn,
    required this.emptyColor,
  });

  final List<DateTime> weeks;
  final Map<DateTime, num> aggregated;
  final OiColorScale scale;
  final double cellSize;
  final double cellSpacing;
  final DateTime startDate;
  final DateTime endDate;
  final int weekStartsOn;
  final Color emptyColor;

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void paint(Canvas canvas, Size size) {
    final step = cellSize + cellSpacing;
    final radius = Radius.circular(cellSize * 0.18);

    for (var col = 0; col < weeks.length; col++) {
      final weekStart = weeks[col];
      for (var row = 0; row < 7; row++) {
        final date = weekStart.add(Duration(days: row));
        final dateOnly = _dateOnly(date);

        // Clip to visible range.
        final inRange =
            !dateOnly.isBefore(startDate) && !dateOnly.isAfter(endDate);

        if (!inRange) continue;

        final value = aggregated[dateOnly];
        final cellColor = value != null ? scale.resolve(value) : emptyColor;

        final left = col * step;
        final top = row * step;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, cellSize, cellSize),
          radius,
        );

        canvas.drawRRect(rect, Paint()..color = cellColor);
      }
    }
  }

  @override
  bool shouldRepaint(_CalendarHeatmapPainter old) =>
      old.weeks != weeks ||
      old.aggregated != aggregated ||
      old.scale != scale ||
      old.cellSize != cellSize ||
      old.cellSpacing != cellSpacing ||
      old.startDate != startDate ||
      old.endDate != endDate ||
      old.weekStartsOn != weekStartsOn ||
      old.emptyColor != emptyColor;
}
