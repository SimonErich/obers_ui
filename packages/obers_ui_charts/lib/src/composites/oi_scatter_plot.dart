import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/_chart_grid_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_interaction.dart';
import 'package:obers_ui_charts/src/composites/oi_chart_axis.dart';
import 'package:obers_ui_charts/src/models/oi_cartesian_series.dart';

/// Point shape in a scatter plot.
///
/// {@category Composites}
enum OiScatterShape {
  /// A filled circle.
  circle,

  /// A filled square.
  square,

  /// A filled diamond (rotated square).
  diamond,

  /// A filled upward-pointing triangle.
  triangle,
}

/// A single data point in a scatter plot.
///
/// {@category Composites}
class OiScatterPoint {
  /// Creates an [OiScatterPoint].
  const OiScatterPoint({required this.x, required this.y, this.tooltip});

  /// The x-axis value.
  final double x;

  /// The y-axis value.
  final double y;

  /// An optional tooltip description.
  final String? tooltip;
}

/// A named series of scatter data points.
///
/// {@category Composites}
class OiScatterSeries {
  /// Creates an [OiScatterSeries].
  const OiScatterSeries({
    required this.label,
    required this.points,
    this.color,
    this.pointRadius = 4.0,
    this.shape = OiScatterShape.circle,
  });

  /// The display name for this series.
  final String label;

  /// The data points in this series.
  final List<OiScatterPoint> points;

  /// An optional color override.
  final Color? color;

  /// The radius of each point marker.
  final double pointRadius;

  /// The shape of each point marker.
  final OiScatterShape shape;
}

/// A scatter plot for visualising correlation between two variables.
///
/// Renders one or more [series] of data points on a Cartesian grid.
/// Supports multiple point shapes, configurable axes, and touch/pointer
/// interaction modes.
///
/// {@category Composites}
class OiScatterPlot extends StatefulWidget {
  /// Creates an [OiScatterPlot].
  const OiScatterPlot({
    required this.label,
    required this.series,
    super.key,
    this.xAxis,
    this.yAxis,
    this.showGrid = true,
    this.showLegend = true,
    this.onPointTap,
    this.interactionMode,
    this.compact,
  });

  /// Accessibility label for the chart.
  final String label;

  /// The data series to render.
  final List<OiScatterSeries> series;

  /// Configuration for the x-axis.
  final OiChartAxis<num>? xAxis;

  /// Configuration for the y-axis.
  final OiChartAxis<num>? yAxis;

  /// Whether to show grid lines.
  final bool showGrid;

  /// Whether to show a legend when there are multiple series.
  final bool showLegend;

  /// Callback when a data point is tapped.
  final void Function(int seriesIndex, int pointIndex)? onPointTap;

  /// Interaction mode. Defaults to [OiChartInteractionMode.auto].
  final OiChartInteractionMode? interactionMode;

  /// Whether to use compact layout.
  final bool? compact;

  @override
  State<OiScatterPlot> createState() => _OiScatterPlotState();
}

class _OiScatterPlotState extends State<OiScatterPlot> {
  int? _hoveredSeriesIndex;
  int? _hoveredPointIndex;

  static const double _compactThreshold = 400;
  static const double _minViableWidth = 120;
  static const double _minViableHeight = 80;

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

  _DataRange _computeRange() {
    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    var minY = double.infinity;
    var maxY = double.negativeInfinity;

    for (final series in widget.series) {
      for (final point in series.points) {
        minX = math.min(minX, point.x);
        maxX = math.max(maxX, point.x);
        minY = math.min(minY, point.y);
        maxY = math.max(maxY, point.y);
      }
    }

    return _DataRange(
      minX: widget.xAxis?.min ?? minX,
      maxX: widget.xAxis?.max ?? maxX,
      minY: widget.yAxis?.min ?? minY,
      maxY: widget.yAxis?.max ?? maxY,
    );
  }

  ({int seriesIndex, int pointIndex})? _findNearest(
    Offset position,
    Rect chartRect,
    _DataRange range,
  ) {
    const hitRadius = 16.0;
    var bestDist = double.infinity;
    int? bestSi;
    int? bestPi;

    for (var si = 0; si < widget.series.length; si++) {
      final series = widget.series[si];
      for (var pi = 0; pi < series.points.length; pi++) {
        final point = series.points[pi];
        final px = chartRect.left + chartRect.width * range.normaliseX(point.x);
        final py =
            chartRect.bottom - chartRect.height * range.normaliseY(point.y);
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

  void _handleTapDown(
    TapDownDetails details,
    Rect chartRect,
    _DataRange range,
  ) {
    final hit = _findNearest(details.localPosition, chartRect, range);
    if (hit != null) {
      widget.onPointTap?.call(hit.seriesIndex, hit.pointIndex);
    }
  }

  void _handleHover(PointerEvent event, Rect chartRect, _DataRange range) {
    final hit = _findNearest(event.localPosition, chartRect, range);
    final si = hit?.seriesIndex;
    final pi = hit?.pointIndex;
    if (si != _hoveredSeriesIndex || pi != _hoveredPointIndex) {
      setState(() {
        _hoveredSeriesIndex = si;
        _hoveredPointIndex = pi;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.series.isEmpty || widget.series.every((s) => s.points.isEmpty)) {
      return const SizedBox.shrink(key: Key('oi_scatter_plot_empty'));
    }

    final colors = context.colors;
    final chartColors = colors.chart;
    final isHighContrast = OiA11y.highContrast(context);
    final reducedMotion = OiA11y.reducedMotion(context);

    return Semantics(
      label: widget.label,
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
              child: const Center(
                key: Key('oi_scatter_plot_fallback'),
                child: OiLabel.caption('…'),
              ),
            );
          }

          final isCompact = widget.compact ?? (w < _compactThreshold);
          final mode = _resolveInteractionMode(context);
          final range = _computeRange();
          final chartSize = Size(
            w,
            math.min(h, isCompact ? w * 0.6 : w * 0.75),
          );
          final chartRect = OiChartGrid.computeChartRect(
            chartSize,
            compact: isCompact,
          );

          // Resolve series colors.
          final resolvedColors = <Color>[
            for (var i = 0; i < widget.series.length; i++)
              widget.series[i].color ?? chartColors[i % chartColors.length],
          ];

          final hoverSi = reducedMotion ? null : _hoveredSeriesIndex;
          final hoverPi = reducedMotion ? null : _hoveredPointIndex;

          // Generate axis labels.
          final xDivisions = widget.xAxis?.divisions ?? (isCompact ? 3 : 5);
          final yDivisions = widget.yAxis?.divisions ?? (isCompact ? 3 : 5);
          final xLabels =
              widget.xAxis?.labels ??
              List.generate(
                xDivisions + 1,
                (i) => (widget.xAxis ?? const OiChartAxis()).formatValue(
                  range.minX + (range.maxX - range.minX) * i / xDivisions,
                ),
              );
          final yLabels =
              widget.yAxis?.labels ??
              List.generate(
                yDivisions + 1,
                (i) => (widget.yAxis ?? const OiChartAxis()).formatValue(
                  range.minY + (range.maxY - range.minY) * i / yDivisions,
                ),
              );

          final chartWidget = SizedBox(
            key: const Key('oi_scatter_plot_canvas'),
            width: chartSize.width,
            height: chartSize.height,
            child: CustomPaint(
              key: const Key('oi_scatter_plot_painter'),
              size: chartSize,
              painter: _OiScatterPlotPainter(
                series: widget.series,
                colors: resolvedColors,
                range: range,
                chartRect: chartRect,
                showGrid: widget.showGrid,
                gridColor: colors.borderSubtle,
                axisLabelColor: colors.textMuted,
                highContrast: isHighContrast,
                compact: isCompact,
                hoveredSeriesIndex: hoverSi,
                hoveredPointIndex: hoverPi,
                xLabels: xLabels,
                yLabels: yLabels,
                xDivisions: xDivisions,
                yDivisions: yDivisions,
              ),
            ),
          );

          // Interaction wrapper.
          Widget interactiveChart;
          if (mode == OiChartInteractionMode.touch) {
            interactiveChart = GestureDetector(
              key: const Key('oi_scatter_plot_touch'),
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) => _handleTapDown(d, chartRect, range),
              child: chartWidget,
            );
          } else {
            interactiveChart = MouseRegion(
              key: const Key('oi_scatter_plot_pointer'),
              onHover: (e) => _handleHover(e, chartRect, range),
              onExit: (_) => setState(() {
                _hoveredSeriesIndex = null;
                _hoveredPointIndex = null;
              }),
              child: chartWidget,
            );
          }

          // Legend.
          final showLegend = widget.showLegend && widget.series.length > 1;
          final legendWidget = showLegend
              ? Wrap(
                  key: const Key('oi_scatter_plot_legend'),
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    for (var i = 0; i < widget.series.length; i++)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: resolvedColors[i],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          OiLabel.caption(
                            widget.series[i].label,
                            color: colors.textMuted,
                          ),
                        ],
                      ),
                  ],
                )
              : null;

          if (isCompact || !showLegend) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                interactiveChart,
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
            ],
          );
        },
      ),
    );
  }
}

class _DataRange {
  const _DataRange({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  double get rangeX {
    final r = maxX - minX;
    return r == 0 ? 1.0 : r;
  }

  double get rangeY {
    final r = maxY - minY;
    return r == 0 ? 1.0 : r;
  }

  double normaliseX(double x) => (x - minX) / rangeX;
  double normaliseY(double y) => (y - minY) / rangeY;
}

class _OiScatterPlotPainter extends CustomPainter {
  _OiScatterPlotPainter({
    required this.series,
    required this.colors,
    required this.range,
    required this.chartRect,
    required this.showGrid,
    required this.gridColor,
    required this.axisLabelColor,
    required this.highContrast,
    required this.compact,
    required this.xLabels,
    required this.yLabels,
    required this.xDivisions,
    required this.yDivisions,
    this.hoveredSeriesIndex,
    this.hoveredPointIndex,
  });

  final List<OiScatterSeries> series;
  final List<Color> colors;
  final _DataRange range;
  final Rect chartRect;
  final bool showGrid;
  final Color gridColor;
  final Color axisLabelColor;
  final bool highContrast;
  final bool compact;
  final List<String> xLabels;
  final List<String> yLabels;
  final int xDivisions;
  final int yDivisions;
  final int? hoveredSeriesIndex;
  final int? hoveredPointIndex;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid.
    if (showGrid) {
      OiChartGrid.paintGrid(
        canvas,
        chartRect,
        gridColor: gridColor,
        highContrast: highContrast,
        horizontalDivisions: yDivisions,
        verticalDivisions: xDivisions,
      );
    }

    OiChartGrid.paintAxes(
      canvas,
      chartRect,
      axisColor: gridColor,
      highContrast: highContrast,
    );

    // Draw axis labels.
    OiChartGrid.paintXLabels(
      canvas,
      chartRect,
      labels: xLabels,
      labelColor: axisLabelColor,
    );
    OiChartGrid.paintYLabels(
      canvas,
      chartRect,
      labels: yLabels,
      labelColor: axisLabelColor,
    );

    // Draw points.
    for (var si = 0; si < series.length; si++) {
      final s = series[si];
      final color = colors[si];
      final paint = Paint()..color = color;

      for (var pi = 0; pi < s.points.length; pi++) {
        final point = s.points[pi];
        final px = chartRect.left + chartRect.width * range.normaliseX(point.x);
        final py =
            chartRect.bottom - chartRect.height * range.normaliseY(point.y);
        final center = Offset(px, py);

        final isHovered = hoveredSeriesIndex == si && hoveredPointIndex == pi;
        final r = isHovered ? s.pointRadius * 1.5 : s.pointRadius;

        _drawShape(canvas, center, r, s.shape, paint);

        if (isHovered) {
          final borderPaint = Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
          _drawShape(canvas, center, r + 2, s.shape, borderPaint);
        }
      }
    }
  }

  void _drawShape(
    Canvas canvas,
    Offset center,
    double radius,
    OiScatterShape shape,
    Paint paint,
  ) {
    switch (shape) {
      case OiScatterShape.circle:
        canvas.drawCircle(center, radius, paint);
      case OiScatterShape.square:
        canvas.drawRect(
          Rect.fromCenter(
            center: center,
            width: radius * 2,
            height: radius * 2,
          ),
          paint,
        );
      case OiScatterShape.diamond:
        final path = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx + radius, center.dy)
          ..lineTo(center.dx, center.dy + radius)
          ..lineTo(center.dx - radius, center.dy)
          ..close();
        canvas.drawPath(path, paint);
      case OiScatterShape.triangle:
        final path = Path()
          ..moveTo(center.dx, center.dy - radius)
          ..lineTo(center.dx + radius, center.dy + radius * 0.7)
          ..lineTo(center.dx - radius, center.dy + radius * 0.7)
          ..close();
        canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_OiScatterPlotPainter oldDelegate) =>
      oldDelegate.series != series ||
      oldDelegate.colors != colors ||
      oldDelegate.showGrid != showGrid ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.highContrast != highContrast ||
      oldDelegate.compact != compact ||
      oldDelegate.hoveredSeriesIndex != hoveredSeriesIndex ||
      oldDelegate.hoveredPointIndex != hoveredPointIndex;
}

// ─────────────────────────────────────────────────────────────────────────────
// Mapper-first series (concept-aligned)
// ─────────────────────────────────────────────────────────────────────────────

/// A mapper-first scatter series that extracts values from domain model `T`.
///
/// This is the concept-aligned series type. Use [OiScatterSeries] and
/// [OiScatterPoint] for the simpler pre-mapped API.
///
/// {@category Composites}
class OiScatterSeriesData<T> extends OiCartesianSeries<T> {
  /// Creates an [OiScatterSeriesData].
  OiScatterSeriesData({
    required super.id,
    required super.label,
    required super.data,
    required super.xMapper,
    required super.yMapper,
    super.visible,
    super.color,
    super.semanticLabel,
    super.pointLabel,
    super.isMissing,
    super.semanticValue,
    super.yAxisId,
  });
}
