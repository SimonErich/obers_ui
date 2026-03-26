import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/_chart_grid_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_area_chart/oi_area_chart_accessibility.dart';
import 'package:obers_ui_charts/src/composites/oi_area_chart/oi_area_chart_data.dart';
import 'package:obers_ui_charts/src/composites/oi_area_chart/oi_area_chart_legend.dart';
import 'package:obers_ui_charts/src/composites/oi_area_chart/oi_area_chart_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_area_chart/oi_area_chart_theme.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_interaction.dart';
import 'package:obers_ui_charts/src/composites/oi_chart_axis.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';

/// An area chart for visualising trends and part-to-whole relationships.
///
/// Renders one or more [series] as filled areas on a Cartesian grid.
/// Supports independent and stacked modes, optional line strokes, and
/// touch/pointer interaction.
///
/// {@category Composites}
class OiAreaChart<T> extends StatefulWidget {
  /// Creates an [OiAreaChart].
  const OiAreaChart({
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
    this.behaviors = const [],
    this.controller,
    this.emptyState,
    this.loadingState,
    this.errorState,
    this.semanticLabel,
  });

  /// Accessibility label for the chart.
  final String label;

  /// The data series to render.
  final List<OiAreaSeries<T>> series;

  /// Configuration for the x-axis.
  final OiChartAxis<num>? xAxis;

  /// Configuration for the y-axis.
  final OiChartAxis<num>? yAxis;

  /// Whether to show grid lines. Defaults to `true`.
  final bool showGrid;

  /// Whether to show a legend when there are multiple series. Defaults to
  /// `true`.
  final bool showLegend;

  /// Whether to show dots at each data point. Defaults to `false`.
  final bool showPoints;

  /// Whether to stack series values cumulatively. Defaults to `false`.
  final bool stacked;

  /// Callback when a data point is tapped.
  final void Function(int seriesIndex, int pointIndex)? onPointTap;

  /// Optional theme overrides.
  final OiAreaChartTheme? theme;

  /// Interaction mode. Defaults to [OiChartInteractionMode.auto].
  final OiChartInteractionMode? interactionMode;

  /// Whether to use compact layout. When `null`, determined by available width.
  final bool? compact;

  /// Chart behaviors to attach (e.g. zoom/pan, tooltip).
  final List<OiChartBehavior> behaviors;

  /// Optional external controller for chart state.
  final OiChartController? controller;

  /// Widget shown when [series] is empty.
  final Widget? emptyState;

  /// Widget shown while data is loading.
  final Widget? loadingState;

  /// Widget shown when data loading has failed.
  final Widget? errorState;

  /// Overrides the auto-generated accessibility label.
  final String? semanticLabel;

  @override
  State<OiAreaChart<T>> createState() => _OiAreaChartState<T>();
}

class _OiAreaChartState<T> extends State<OiAreaChart<T>> {
  int? _hoveredSeriesIndex;
  int? _hoveredPointIndex;
  int? _selectedSeriesIndex;
  int? _selectedPointIndex;

  static const double _compactThreshold = 400;
  static const double _minViableWidth = 120;
  static const double _minViableHeight = 80;

  String get _effectiveLabel =>
      widget.semanticLabel ??
      (widget.label.isNotEmpty
          ? widget.label
          : OiAreaChartAccessibility.generateSummary(widget.series));

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
      // For stacked, compute cumulative max per x-value.
      final xValues = <double>{};
      for (final s in widget.series) {
        final data = s.data;
        if (data == null) continue;
        for (final item in data) {
          final x = (s.xMapper(item) as num).toDouble();
          xValues.add(x);
          minX = math.min(minX, x);
          maxX = math.max(maxX, x);
        }
      }
      for (final x in xValues) {
        var cumY = 0.0;
        for (final s in widget.series) {
          final data = s.data;
          if (data == null) continue;
          for (final item in data) {
            if ((s.xMapper(item) as num).toDouble() == x) {
              cumY += s.yMapper(item).toDouble();
            }
          }
        }
        minY = math.min(minY, 0);
        maxY = math.max(maxY, cumY);
      }
    } else {
      for (final s in widget.series) {
        final data = s.data;
        if (data == null) continue;
        for (final item in data) {
          final x = (s.xMapper(item) as num).toDouble();
          final y = s.yMapper(item).toDouble();
          minX = math.min(minX, x);
          maxX = math.max(maxX, x);
          minY = math.min(minY, y);
          maxY = math.max(maxY, y);
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
      final s = widget.series[si];
      final data = s.data;
      if (data == null) continue;
      for (var pi = 0; pi < data.length; pi++) {
        final item = data[pi];
        final x = (s.xMapper(item) as num).toDouble();
        final y = s.yMapper(item).toDouble();
        final px = chartRect.left + chartRect.width * (x - minX) / rangeX;
        final py = chartRect.bottom - chartRect.height * (y - minY) / rangeY;
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

  bool get _isEmpty =>
      widget.series.isEmpty ||
      widget.series.every((s) => s.data == null || s.data!.isEmpty);

  @override
  Widget build(BuildContext context) {
    if (widget.loadingState != null) {
      return widget.loadingState!;
    }

    if (widget.errorState != null) {
      return widget.errorState!;
    }

    if (_isEmpty) {
      return widget.emptyState ??
          const SizedBox.shrink(key: Key('oi_area_chart_empty'));
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
                key: const Key('oi_area_chart_fallback'),
                child: FittedBox(
                  child: Text(
                    'Chart too small',
                    style: TextStyle(fontSize: 10, color: colors.textMuted),
                  ),
                ),
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

          // Resolve series to concrete types for the painter.
          final resolved = <ResolvedAreaSeries>[
            for (var i = 0; i < widget.series.length; i++)
              _resolveSeriesAt(i, context),
          ];

          final hoverSi = reducedMotion ? null : _hoveredSeriesIndex;
          final hoverPi = reducedMotion ? null : _hoveredPointIndex;

          // Generate axis labels.
          final xDiv = widget.xAxis?.divisions ?? (isCompact ? 3 : 5);
          final yDiv = widget.yAxis?.divisions ?? (isCompact ? 3 : 5);
          final rX = range.maxX - range.minX;
          final rY = range.maxY - range.minY;
          final xLabels =
              widget.xAxis?.labels ??
              List.generate(
                xDiv + 1,
                (i) => (widget.xAxis ?? const OiChartAxis()).formatValue(
                  range.minX + (rX == 0 ? 0 : rX * i / xDiv),
                ),
              );
          final yLabels =
              widget.yAxis?.labels ??
              List.generate(
                yDiv + 1,
                (i) => (widget.yAxis ?? const OiChartAxis()).formatValue(
                  range.minY + (rY == 0 ? 0 : rY * i / yDiv),
                ),
              );

          final chartWidget = SizedBox(
            key: const Key('oi_area_chart_canvas'),
            width: chartSize.width,
            height: chartSize.height,
            child: CustomPaint(
              key: const Key('oi_area_chart_painter'),
              size: chartSize,
              painter: OiAreaChartPainter(
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
              key: const Key('oi_area_chart_touch'),
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
                  widget.onPointTap?.call(hit.seriesIndex, hit.pointIndex);
                }
              },
              child: chartWidget,
            );
          } else {
            interactiveChart = MouseRegion(
              key: const Key('oi_area_chart_pointer'),
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
                if (si != _hoveredSeriesIndex || pi != _hoveredPointIndex) {
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
            final s = widget.series[activeSi];
            final data = s.data;
            if (data != null && activeIdx < data.length) {
              final item = data[activeIdx];
              final x = (s.xMapper(item) as num).toDouble();
              final y = s.yMapper(item).toDouble();
              final desc = OiAreaChartAccessibility.describePoint(
                x,
                y,
                s.label,
              );
              narration = Semantics(
                key: const Key('oi_area_chart_narration'),
                liveRegion: true,
                child: Text(
                  desc,
                  style: TextStyle(fontSize: 11, color: colors.textSubtle),
                ),
              );
            }
          }

          // Legend.
          final showLegend = widget.showLegend && widget.series.length > 1;
          final legendWidget = showLegend
              ? OiAreaChartLegend<T>(
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

  ResolvedAreaSeries _resolveSeriesAt(int i, BuildContext context) {
    final s = widget.series[i];
    final data = s.data ?? const [];
    final xValues = <double>[];
    final yValues = <double>[];
    for (final item in data) {
      xValues.add((s.xMapper(item) as num).toDouble());
      yValues.add(s.yMapper(item).toDouble());
    }
    return ResolvedAreaSeries(
      label: s.label,
      xValues: xValues,
      yValues: yValues,
      color: OiAreaChartTheme.resolveColor(
        i,
        s.color,
        context,
        chartTheme: widget.theme,
      ),
      fillOpacity: s.fillOpacity,
      showLine: s.showLine,
      strokeWidth: s.style?.strokeWidth ?? 2.0,
      stackGroup: s.stackGroup,
    );
  }
}
