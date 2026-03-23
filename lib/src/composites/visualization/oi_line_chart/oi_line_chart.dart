import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/composites/visualization/_chart_grid_painter.dart';
import 'package:obers_ui/src/composites/visualization/oi_bubble_chart/oi_bubble_chart_interaction.dart';
import 'package:obers_ui/src/composites/visualization/oi_chart_axis.dart';
import 'package:obers_ui/src/composites/visualization/oi_line_chart/oi_line_chart_accessibility.dart';
import 'package:obers_ui/src/composites/visualization/oi_line_chart/oi_line_chart_data.dart';
import 'package:obers_ui/src/composites/visualization/oi_line_chart/oi_line_chart_legend.dart';
import 'package:obers_ui/src/composites/visualization/oi_line_chart/oi_line_chart_painter.dart';
import 'package:obers_ui/src/composites/visualization/oi_line_chart/oi_line_chart_theme.dart';
import 'package:obers_ui/src/foundation/oi_accessibility.dart';
import 'package:obers_ui/src/foundation/oi_platform.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A line chart for visualising time series and metric data.
///
/// Renders one or more [series] as polylines on a Cartesian grid.
/// The [mode] controls interpolation between data points.
/// Supports dashed lines, area fill, stacked mode, and touch/pointer
/// interaction.
///
/// Use the named constructors for common variants:
/// - [OiLineChart.straight]: straight line segments (default).
/// - [OiLineChart.stepped]: staircase step segments.
/// - [OiLineChart.smooth]: smooth Catmull-Rom curves.
///
/// {@category Composites}
class OiLineChart extends StatefulWidget {
  /// Creates an [OiLineChart] with the given [mode].
  const OiLineChart({
    required this.label,
    required this.series,
    super.key,
    this.mode = OiLineChartMode.straight,
    this.xAxis,
    this.yAxis,
    this.showGrid = true,
    this.showLegend = true,
    this.showPoints = false,
    this.stacked = false,
    this.onPointTap,
    this.theme,
    this.interactionMode,
    this.compact,
  });

  /// Creates a straight-line [OiLineChart].
  const OiLineChart.straight({
    required this.label,
    required this.series,
    super.key,
    this.xAxis,
    this.yAxis,
    this.showGrid = true,
    this.showLegend = true,
    this.showPoints = false,
    this.stacked = false,
    this.onPointTap,
    this.theme,
    this.interactionMode,
    this.compact,
  }) : mode = OiLineChartMode.straight;

  /// Creates a stepped-line [OiLineChart].
  const OiLineChart.stepped({
    required this.label,
    required this.series,
    super.key,
    this.xAxis,
    this.yAxis,
    this.showGrid = true,
    this.showLegend = true,
    this.showPoints = false,
    this.stacked = false,
    this.onPointTap,
    this.theme,
    this.interactionMode,
    this.compact,
  }) : mode = OiLineChartMode.stepped;

  /// Creates a smooth-curve [OiLineChart].
  const OiLineChart.smooth({
    required this.label,
    required this.series,
    super.key,
    this.xAxis,
    this.yAxis,
    this.showGrid = true,
    this.showLegend = true,
    this.showPoints = false,
    this.stacked = false,
    this.onPointTap,
    this.theme,
    this.interactionMode,
    this.compact,
  }) : mode = OiLineChartMode.smooth;

  /// Accessibility label for the chart.
  final String label;

  /// The data series to render.
  final List<OiLineSeries> series;

  /// The line interpolation mode.
  final OiLineChartMode mode;

  /// Configuration for the x-axis.
  final OiChartAxis<num>? xAxis;

  /// Configuration for the y-axis.
  final OiChartAxis<num>? yAxis;

  /// Whether to show grid lines.
  final bool showGrid;

  /// Whether to show a legend when there are multiple series.
  final bool showLegend;

  /// Whether to show dots at each data point.
  final bool showPoints;

  /// Whether to stack series values cumulatively (stacked area chart).
  final bool stacked;

  /// Callback when a data point is tapped.
  final void Function(int seriesIndex, int pointIndex)? onPointTap;

  /// Optional theme overrides.
  final OiLineChartTheme? theme;

  /// Interaction mode. Defaults to [OiChartInteractionMode.auto].
  final OiChartInteractionMode? interactionMode;

  /// Whether to use compact layout. When null, determined by available width.
  final bool? compact;

  @override
  State<OiLineChart> createState() => _OiLineChartState();
}

class _OiLineChartState extends State<OiLineChart> {
  int? _hoveredSeriesIndex;
  int? _hoveredPointIndex;
  int? _selectedSeriesIndex;
  int? _selectedPointIndex;

  static const double _compactThreshold = 400;
  static const double _minViableWidth = 120;
  static const double _minViableHeight = 80;

  String get _effectiveLabel =>
      widget.label.isNotEmpty
          ? widget.label
          : OiLineChartAccessibility.generateSummary(widget.series);

  OiChartInteractionMode _resolveInteractionMode(BuildContext context) {
    if (widget.interactionMode != null &&
        widget.interactionMode != OiChartInteractionMode.auto) {
      return widget.interactionMode!;
    }
    final modality = OiPlatform.of(context).inputModality;
    return modality == OiInputModality.touch
        ? OiChartInteractionMode.touch
        : OiChartInteractionMode.pointer;
  }

  ({double minX, double maxX, double minY, double maxY}) _computeRange() {
    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    var minY = double.infinity;
    var maxY = double.negativeInfinity;

    if (widget.stacked) {
      // For stacked, compute cumulative max.
      final xValues = <double>{};
      for (final s in widget.series) {
        for (final p in s.points) {
          xValues.add(p.x);
          minX = math.min(minX, p.x);
          maxX = math.max(maxX, p.x);
        }
      }
      for (final x in xValues) {
        var cumY = 0.0;
        for (final s in widget.series) {
          for (final p in s.points) {
            if (p.x == x) cumY += p.y;
          }
        }
        minY = math.min(minY, 0);
        maxY = math.max(maxY, cumY);
      }
    } else {
      for (final s in widget.series) {
        for (final p in s.points) {
          minX = math.min(minX, p.x);
          maxX = math.max(maxX, p.x);
          minY = math.min(minY, p.y);
          maxY = math.max(maxY, p.y);
        }
      }
    }

    return (
      minX: widget.xAxis?.min ?? minX,
      maxX: widget.xAxis?.max ?? maxX,
      minY: widget.yAxis?.min ?? minY,
      maxY: widget.yAxis?.max ?? maxY,
    );
  }

  ({int seriesIndex, int pointIndex})? _findNearestPoint(
    Offset position,
    Rect chartRect,
    double minX,
    double maxX,
    double minY,
    double maxY,
  ) {
    const hitRadius = 20.0;
    final rangeX = maxX - minX == 0 ? 1.0 : maxX - minX;
    final rangeY = maxY - minY == 0 ? 1.0 : maxY - minY;

    var bestDist = double.infinity;
    int? bestSi;
    int? bestPi;

    for (var si = 0; si < widget.series.length; si++) {
      final series = widget.series[si];
      for (var pi = 0; pi < series.points.length; pi++) {
        final point = series.points[pi];
        final px =
            chartRect.left + chartRect.width * (point.x - minX) / rangeX;
        final py = chartRect.bottom -
            chartRect.height * (point.y - minY) / rangeY;
        final dist = (Offset(px, py) - position).distance;
        if (dist < hitRadius && dist < bestDist) {
          bestDist = dist;
          bestSi = si;
          bestPi = pi;
        }
      }
    }

    if (bestSi != null) {
      return (seriesIndex: bestSi, pointIndex: bestPi!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.series.isEmpty ||
        widget.series.every((s) => s.points.isEmpty)) {
      return const SizedBox.shrink(key: Key('oi_line_chart_empty'));
    }

    final colors = context.colors;
    final isHighContrast = OiA11y.highContrast(context);
    final reducedMotion = OiA11y.reducedMotion(context);

    return Semantics(
      label: _effectiveLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : 300.0;

          if (w < _minViableWidth || h < _minViableHeight) {
            return SizedBox(
              width: w,
              height: h,
              child: Center(
                key: const Key('oi_line_chart_fallback'),
                child: FittedBox(
                  child: Text(
                    'Chart too small',
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.textMuted,
                    ),
                  ),
                ),
              ),
            );
          }

          final isCompact = widget.compact ?? (w < _compactThreshold);
          final mode = _resolveInteractionMode(context);
          final range = _computeRange();
          final chartSize =
              Size(w, math.min(h, isCompact ? w * 0.6 : w * 0.75));
          final chartRect = OiChartGrid.computeChartRect(
            chartSize,
            compact: isCompact,
          );

          // Resolve series.
          final resolved = <ResolvedLineSeries>[
            for (var i = 0; i < widget.series.length; i++)
              ResolvedLineSeries(
                points: widget.series[i].points,
                color: OiLineChartTheme.resolveColor(
                  i,
                  widget.series[i].color,
                  context,
                  chartTheme: widget.theme,
                ),
                strokeWidth: widget.series[i].strokeWidth,
                dashed: widget.series[i].dashed,
                fill: widget.series[i].fill,
                fillOpacity: widget.series[i].fillOpacity,
                label: widget.series[i].label,
              ),
          ];

          final hoverSi = reducedMotion ? null : _hoveredSeriesIndex;
          final hoverPi = reducedMotion ? null : _hoveredPointIndex;

          // Generate axis labels.
          final xDiv = widget.xAxis?.divisions ?? (isCompact ? 3 : 5);
          final yDiv = widget.yAxis?.divisions ?? (isCompact ? 3 : 5);
          final rX = range.maxX - range.minX;
          final rY = range.maxY - range.minY;
          final xLabels = widget.xAxis?.labels ??
              List.generate(
                xDiv + 1,
                (i) => (widget.xAxis ?? const OiChartAxis()).formatValue(
                  range.minX + (rX == 0 ? 0 : rX * i / xDiv),
                ),
              );
          final yLabels = widget.yAxis?.labels ??
              List.generate(
                yDiv + 1,
                (i) => (widget.yAxis ?? const OiChartAxis()).formatValue(
                  range.minY + (rY == 0 ? 0 : rY * i / yDiv),
                ),
              );

          final chartWidget = SizedBox(
            key: const Key('oi_line_chart_canvas'),
            width: chartSize.width,
            height: chartSize.height,
            child: CustomPaint(
              key: const Key('oi_line_chart_painter'),
              size: chartSize,
              painter: OiLineChartPainter(
                resolvedSeries: resolved,
                chartRect: chartRect,
                minX: range.minX,
                maxX: range.maxX,
                minY: range.minY,
                maxY: range.maxY,
                showGrid: widget.showGrid,
                gridColor: widget.theme?.gridColor ?? colors.borderSubtle,
                axisLabelColor:
                    widget.theme?.axisLabelColor ?? colors.textMuted,
                highContrast: isHighContrast,
                compact: isCompact,
                mode: widget.mode,
                showPoints: widget.showPoints,
                stacked: widget.stacked,
                xLabels: xLabels,
                yLabels: yLabels,
                xDivisions: xDiv,
                yDivisions: yDiv,
                hoveredSeriesIndex: hoverSi,
                hoveredPointIndex: hoverPi,
              ),
            ),
          );

          // Interaction wrapper.
          Widget interactiveChart;
          if (mode == OiChartInteractionMode.touch) {
            interactiveChart = GestureDetector(
              key: const Key('oi_line_chart_touch'),
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) {
                final hit = _findNearestPoint(
                  d.localPosition,
                  chartRect,
                  range.minX,
                  range.maxX,
                  range.minY,
                  range.maxY,
                );
                if (hit != null) {
                  setState(() {
                    _selectedSeriesIndex = hit.seriesIndex;
                    _selectedPointIndex = hit.pointIndex;
                  });
                  widget.onPointTap
                      ?.call(hit.seriesIndex, hit.pointIndex);
                }
              },
              child: chartWidget,
            );
          } else {
            interactiveChart = MouseRegion(
              key: const Key('oi_line_chart_pointer'),
              onHover: (e) {
                final hit = _findNearestPoint(
                  e.localPosition,
                  chartRect,
                  range.minX,
                  range.maxX,
                  range.minY,
                  range.maxY,
                );
                final si = hit?.seriesIndex;
                final pi = hit?.pointIndex;
                if (si != _hoveredSeriesIndex ||
                    pi != _hoveredPointIndex) {
                  setState(() {
                    _hoveredSeriesIndex = si;
                    _hoveredPointIndex = pi;
                  });
                }
              },
              onExit: (_) => setState(() {
                _hoveredSeriesIndex = null;
                _hoveredPointIndex = null;
              }),
              child: chartWidget,
            );
          }

          // Narration for active point.
          final activeIdx = _selectedPointIndex ?? _hoveredPointIndex;
          final activeSi = _selectedSeriesIndex ?? _hoveredSeriesIndex;
          Widget narration = const SizedBox.shrink();
          if (activeIdx != null && activeSi != null) {
            final series = widget.series[activeSi];
            if (activeIdx < series.points.length) {
              final point = series.points[activeIdx];
              final desc = OiLineChartAccessibility.describePoint(
                point,
                series.label,
              );
              narration = Semantics(
                key: const Key('oi_line_chart_narration'),
                liveRegion: true,
                child: Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.textSubtle,
                  ),
                ),
              );
            }
          }

          // Legend.
          final showLegend =
              widget.showLegend && widget.series.length > 1;
          final legendWidget = showLegend
              ? OiLineChartLegend(
                  series: widget.series,
                  chartTheme: widget.theme,
                )
              : null;

          if (isCompact) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                interactiveChart,
                narration,
                if (legendWidget != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: legendWidget,
                  ),
              ],
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: interactiveChart),
                  if (legendWidget != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: legendWidget,
                    ),
                ],
              ),
              narration,
            ],
          );
        },
      ),
    );
  }
}
