import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/_chart_grid_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_bar_chart/oi_bar_chart_accessibility.dart';
import 'package:obers_ui_charts/src/composites/oi_bar_chart/oi_bar_chart_data.dart';
import 'package:obers_ui_charts/src/composites/oi_bar_chart/oi_bar_chart_layout.dart';
import 'package:obers_ui_charts/src/composites/oi_bar_chart/oi_bar_chart_legend.dart';
import 'package:obers_ui_charts/src/composites/oi_bar_chart/oi_bar_chart_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_bar_chart/oi_bar_chart_theme.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_interaction.dart';
import 'package:obers_ui_charts/src/composites/oi_chart_axis.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_performance_config.dart';
import 'package:obers_ui_charts/src/models/oi_chart_annotation.dart';
import 'package:obers_ui_charts/src/models/oi_chart_legend_config.dart';
import 'package:obers_ui_charts/src/models/oi_chart_threshold.dart';

/// A bar chart for categorical comparisons.
///
/// Renders [categories] as bars in the layout determined by [mode].
/// Supports grouped, stacked, horizontal-grouped, and horizontal-stacked
/// layouts, optional value labels, and touch/pointer interaction.
///
/// Use the named constructors for common variants:
/// - [OiBarChart.grouped]: vertical grouped bars (default).
/// - [OiBarChart.stacked]: vertical stacked bars.
/// - [OiBarChart.horizontalGrouped]: horizontal grouped bars.
/// - [OiBarChart.horizontalStacked]: horizontal stacked bars.
///
/// {@category Composites}
class OiBarChart extends StatefulWidget {
  /// Creates an [OiBarChart] with the given [mode].
  const OiBarChart({
    required this.label,
    required this.categories,
    super.key,
    this.mode = OiBarChartMode.grouped,
    this.series,
    this.showValues = false,
    this.showGrid = true,
    this.showLegend = true,
    this.barRadius = 4.0,
    this.yAxis,
    this.onBarTap,
    this.theme,
    this.interactionMode,
    this.compact,
    this.behaviors = const [],
    this.controller,
    this.annotations = const [],
    this.thresholds = const [],
    this.legendConfig,
    this.performance,
    this.syncGroup,
  });

  /// Creates a vertical grouped [OiBarChart].
  const OiBarChart.grouped({
    required this.label,
    required this.categories,
    super.key,
    this.series,
    this.showValues = false,
    this.showGrid = true,
    this.showLegend = true,
    this.barRadius = 4.0,
    this.yAxis,
    this.onBarTap,
    this.theme,
    this.interactionMode,
    this.compact,
    this.behaviors = const [],
    this.controller,
    this.annotations = const [],
    this.thresholds = const [],
    this.legendConfig,
    this.performance,
    this.syncGroup,
  }) : mode = OiBarChartMode.grouped;

  /// Creates a vertical stacked [OiBarChart].
  const OiBarChart.stacked({
    required this.label,
    required this.categories,
    super.key,
    this.series,
    this.showValues = false,
    this.showGrid = true,
    this.showLegend = true,
    this.barRadius = 4.0,
    this.yAxis,
    this.onBarTap,
    this.theme,
    this.interactionMode,
    this.compact,
    this.behaviors = const [],
    this.controller,
    this.annotations = const [],
    this.thresholds = const [],
    this.legendConfig,
    this.performance,
    this.syncGroup,
  }) : mode = OiBarChartMode.stacked;

  /// Creates a horizontal grouped [OiBarChart].
  const OiBarChart.horizontalGrouped({
    required this.label,
    required this.categories,
    super.key,
    this.series,
    this.showValues = false,
    this.showGrid = true,
    this.showLegend = true,
    this.barRadius = 4.0,
    this.yAxis,
    this.onBarTap,
    this.theme,
    this.interactionMode,
    this.compact,
    this.behaviors = const [],
    this.controller,
    this.annotations = const [],
    this.thresholds = const [],
    this.legendConfig,
    this.performance,
    this.syncGroup,
  }) : mode = OiBarChartMode.horizontalGrouped;

  /// Creates a horizontal stacked [OiBarChart].
  const OiBarChart.horizontalStacked({
    required this.label,
    required this.categories,
    super.key,
    this.series,
    this.showValues = false,
    this.showGrid = true,
    this.showLegend = true,
    this.barRadius = 4.0,
    this.yAxis,
    this.onBarTap,
    this.theme,
    this.interactionMode,
    this.compact,
    this.behaviors = const [],
    this.controller,
    this.annotations = const [],
    this.thresholds = const [],
    this.legendConfig,
    this.performance,
    this.syncGroup,
  }) : mode = OiBarChartMode.horizontalStacked;

  /// Accessibility label for the chart.
  final String label;

  /// The category data to render.
  final List<OiBarCategory> categories;

  /// The bar layout mode.
  final OiBarChartMode mode;

  /// Optional named series (for legend and color resolution).
  /// When null, a single implicit series is assumed.
  final List<OiBarSeries>? series;

  /// Whether to show value labels on bars.
  final bool showValues;

  /// Whether to show grid lines.
  final bool showGrid;

  /// Whether to show a legend when there are multiple series.
  final bool showLegend;

  /// The corner radius of each bar.
  final double barRadius;

  /// Configuration for the value axis.
  final OiChartAxis<num>? yAxis;

  /// Callback when a bar is tapped.
  final void Function(int categoryIndex, int? seriesIndex)? onBarTap;

  /// Optional theme overrides.
  final OiBarChartTheme? theme;

  /// Interaction mode. Defaults to [OiChartInteractionMode.auto].
  final OiChartInteractionMode? interactionMode;

  /// Whether to use compact layout.
  final bool? compact;

  /// Composable interaction behaviors.
  final List<OiChartBehavior> behaviors;

  /// External chart controller.
  final OiChartController? controller;

  /// Annotation overlays (lines, regions, points, labels).
  final List<OiChartAnnotation> annotations;

  /// Threshold lines.
  final List<OiChartThreshold> thresholds;

  /// Legend configuration.
  final OiChartLegendConfig? legendConfig;

  /// Performance configuration (decimation, rendering mode).
  final OiChartPerformanceConfig? performance;

  /// Sync group identifier for linking multiple charts.
  final String? syncGroup;

  @override
  State<OiBarChart> createState() => _OiBarChartState();
}

class _OiBarChartState extends State<OiBarChart> {
  int? _hoveredCategoryIndex;
  int? _hoveredSeriesIndex;

  static const double _compactThreshold = 400;
  static const double _minViableWidth = 120;
  static const double _minViableHeight = 80;

  bool get _isHorizontal =>
      widget.mode == OiBarChartMode.horizontalGrouped ||
      widget.mode == OiBarChartMode.horizontalStacked;

  bool get _isStacked =>
      widget.mode == OiBarChartMode.stacked ||
      widget.mode == OiBarChartMode.horizontalStacked;

  int get _numSeries {
    if (widget.series != null) return widget.series!.length;
    if (widget.categories.isEmpty) return 1;
    return widget.categories.first.values.length;
  }

  String get _effectiveLabel => widget.label.isNotEmpty
      ? widget.label
      : OiBarChartAccessibility.generateSummary(
          widget.categories,
          widget.series,
        );

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

  ({int categoryIndex, int seriesIndex})? _hitTest(
    Offset position,
    Rect chartRect,
    BarCategoryLayout layout,
  ) {
    if (widget.categories.isEmpty) return null;

    if (_isHorizontal) {
      final catHeight = chartRect.height / widget.categories.length;
      final ci = ((position.dy - chartRect.top) / catHeight).floor();
      if (ci < 0 || ci >= widget.categories.length) return null;
      // Simplified: return first series.
      return (categoryIndex: ci, seriesIndex: 0);
    } else {
      final ci = layout.categoryAt(position.dx);
      if (ci == null) return null;
      if (_isStacked || _numSeries == 1) {
        return (categoryIndex: ci, seriesIndex: 0);
      }
      final bounds = layout.bars[ci];
      final barW = bounds.width / _numSeries;
      final si = ((position.dx - bounds.left) / barW).floor().clamp(
        0,
        _numSeries - 1,
      );
      return (categoryIndex: ci, seriesIndex: si);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return const SizedBox.shrink(key: Key('oi_bar_chart_empty'));
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
                key: const Key('oi_bar_chart_fallback'),
                child: FittedBox(
                  child: OiLabel.caption(
                    'Chart too small',
                    color: colors.textMuted,
                  ),
                ),
              ),
            );
          }

          final isCompact = widget.compact ?? (w < _compactThreshold);
          final mode = _resolveInteractionMode(context);
          final chartSize = Size(
            w,
            math.min(h, isCompact ? w * 0.6 : w * 0.75),
          );
          final effectiveRadius = widget.theme?.barRadius ?? widget.barRadius;

          var chartRect = OiChartGrid.computeChartRect(
            chartSize,
            compact: isCompact,
          );
          if (context.components.chart?.density?.padding case final padding?) {
            chartRect = Rect.fromLTRB(
              padding.left,
              padding.top,
              math.max(padding.left, chartSize.width - padding.right),
              math.max(padding.top, chartSize.height - padding.bottom),
            );
          }

          if (!_isHorizontal &&
              widget.categories.any((category) => category.group != null)) {
            chartRect = Rect.fromLTRB(
              chartRect.left,
              chartRect.top,
              chartRect.right,
              math.max(chartRect.top, chartRect.bottom - 20),
            );
          }

          final categoryLayout = BarCategoryLayout(
            plot: chartRect,
            groups: [for (final category in widget.categories) category.group],
            barWidth: context.components.chart?.density?.barWidth,
            sectionSpacing:
                context.components.chart?.density?.sectionSpacing ?? 0,
          );

          // Resolve colors.
          final numSeries = _numSeries;
          final resolvedColors = <Color>[
            for (var i = 0; i < numSeries; i++)
              OiBarChartTheme.resolveColor(
                i,
                widget.series != null && i < widget.series!.length
                    ? widget.series![i].color
                    : null,
                context,
                chartTheme: widget.theme,
              ),
          ];

          // Compute max for y-axis labels.
          var maxVal = 0.0;
          final allValues = <List<double>>[];
          for (final cat in widget.categories) {
            allValues.add(cat.values);
            if (_isStacked) {
              var sum = 0.0;
              for (final v in cat.values) {
                sum += v;
              }
              maxVal = math.max(maxVal, sum);
            } else {
              for (final v in cat.values) {
                maxVal = math.max(maxVal, v);
              }
            }
          }
          final minVal = widget.yAxis?.min ?? 0.0;
          maxVal = widget.yAxis?.max ?? maxVal;
          if (maxVal <= minVal) maxVal = minVal + 1;

          final yDiv = widget.yAxis?.divisions ?? (isCompact ? 3 : 5);
          final yLabels =
              widget.yAxis?.labels ??
              List.generate(
                yDiv + 1,
                (i) => (widget.yAxis ?? const OiChartAxis()).formatValue(
                  minVal + (maxVal - minVal) * i / yDiv,
                ),
              );

          final hoverCi = reducedMotion ? null : _hoveredCategoryIndex;
          final hoverSi = reducedMotion ? null : _hoveredSeriesIndex;

          final chartWidget = SizedBox(
            key: const Key('oi_bar_chart_canvas'),
            width: chartSize.width,
            height: chartSize.height,
            child: CustomPaint(
              key: const Key('oi_bar_chart_painter'),
              size: chartSize,
              painter: OiBarChartPainter(
                categoryLabels: widget.categories.map((c) => c.label).toList(),
                categoryLayout: categoryLayout,
                axisLabelGap:
                    context.components.chart?.axis?.labelGap ??
                    context.spacing.sm,
                numericLabelGap: context.components.chart?.axis?.labelGap ?? 4,
                valueLabelGap: context.spacing.xs,
                values: allValues,
                domainMin: minVal,
                domainMax: maxVal,
                colors: resolvedColors,
                patterns: [
                  for (final category in widget.categories)
                    [
                      for (var i = 0; i < numSeries; i++)
                        if (category.patterns != null &&
                            i < category.patterns!.length)
                          category.patterns![i]
                        else if (widget.series != null &&
                            i < widget.series!.length)
                          widget.series![i].pattern
                        else
                          OiBarPattern.solid,
                    ],
                ],
                categoryColors: [
                  for (final category in widget.categories)
                    [
                      for (var i = 0; i < numSeries; i++)
                        if (category.colors != null &&
                            i < category.colors!.length)
                          category.colors![i]
                        else
                          resolvedColors[i],
                    ],
                ],
                emphasizedCategories: [
                  for (final c in widget.categories) c.emphasized,
                ],
                gridDashPattern: context.components.chart?.grid?.dashPattern,
                gridWidth: context.components.chart?.grid?.width,
                categoryGroups: [
                  for (final category in widget.categories) category.group,
                ],
                labelStyle: context.textTheme.caption.merge(
                  context.components.chart?.axis?.labelStyle,
                ),
                chartRect: chartRect,
                horizontal: _isHorizontal,
                stacked: _isStacked,
                showValues: widget.showValues,
                showGrid: widget.showGrid,
                barRadius: effectiveRadius,
                gridColor:
                    widget.theme?.gridColor ??
                    context.components.chart?.grid?.color ??
                    colors.borderSubtle,
                axisLabelColor:
                    widget.theme?.axisLabelColor ??
                    context.components.chart?.axis?.labelColor ??
                    context.components.chart?.axis?.labelStyle?.color ??
                    colors.textMuted,
                textColor: colors.text,
                highContrast: isHighContrast,
                compact: isCompact,
                numSeries: numSeries,
                yLabels: yLabels,
                yDivisions: yDiv,
                hoveredCategoryIndex: hoverCi,
                hoveredSeriesIndex: hoverSi,
              ),
            ),
          );

          // Interaction wrapper.
          Widget interactiveChart;
          if (mode == OiChartInteractionMode.touch) {
            interactiveChart = GestureDetector(
              key: const Key('oi_bar_chart_touch'),
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) {
                final hit = _hitTest(
                  d.localPosition,
                  chartRect,
                  categoryLayout,
                );
                if (hit != null) {
                  widget.onBarTap?.call(
                    hit.categoryIndex,
                    numSeries > 1 ? hit.seriesIndex : null,
                  );
                }
              },
              child: chartWidget,
            );
          } else {
            interactiveChart = MouseRegion(
              key: const Key('oi_bar_chart_pointer'),
              onHover: (e) {
                final hit = _hitTest(
                  e.localPosition,
                  chartRect,
                  categoryLayout,
                );
                if (hit?.categoryIndex != _hoveredCategoryIndex ||
                    hit?.seriesIndex != _hoveredSeriesIndex) {
                  setState(() {
                    _hoveredCategoryIndex = hit?.categoryIndex;
                    _hoveredSeriesIndex = hit?.seriesIndex;
                  });
                }
              },
              onExit: (_) => setState(() {
                _hoveredCategoryIndex = null;
                _hoveredSeriesIndex = null;
              }),
              child: chartWidget,
            );
          }

          // Legend.
          final showLegend =
              widget.showLegend && widget.series != null && numSeries > 1;
          final legendWidget = showLegend
              ? OiBarChartLegend(
                  series: widget.series!,
                  chartTheme: widget.theme,
                )
              : null;

          if (isCompact) {
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
