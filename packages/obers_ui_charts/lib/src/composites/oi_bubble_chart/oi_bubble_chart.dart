import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_accessibility.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_data.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_interaction.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_legend.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_size_legend.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_theme.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_performance_config.dart';
import 'package:obers_ui_charts/src/models/oi_chart_annotation.dart';
import 'package:obers_ui_charts/src/models/oi_chart_legend_config.dart';
import 'package:obers_ui_charts/src/models/oi_chart_threshold.dart';

/// A bubble chart visualization plotting data by x, y, and size dimensions.
///
/// Supports theming via [OiBubbleChartTheme], accessibility narration,
/// responsive compact layouts, touch/pointer interaction modes, and
/// high-contrast / reduced-motion system settings.
///
/// {@category Composites}
class OiBubbleChart extends StatefulWidget {
  /// Creates an [OiBubbleChart].
  const OiBubbleChart({
    required this.data,
    super.key,
    this.semanticLabel,
    this.theme,
    this.interactionMode,
    this.compact,
    this.label,
    this.behaviors = const [],
    this.controller,
    this.annotations = const [],
    this.thresholds = const [],
    this.legendConfig,
    this.performance,
    this.syncGroup,
  });

  /// The chart data including series and size configuration.
  final OiBubbleChartData data;

  /// Optional semantic label. When null, one is auto-generated from [data].
  final String? semanticLabel;

  /// Optional theme overrides.
  final OiBubbleChartTheme? theme;

  /// Interaction mode. Defaults to [OiChartInteractionMode.auto].
  final OiChartInteractionMode? interactionMode;

  /// Whether to use compact layout. When null, determined by available width.
  final bool? compact;

  /// Accessibility label (alias for [semanticLabel]).
  final String? label;

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
  State<OiBubbleChart> createState() => _OiBubbleChartState();
}

class _OiBubbleChartState extends State<OiBubbleChart> {
  int? _hoveredBubbleIndex;
  int? _selectedBubbleIndex;

  static const double _minViableWidth = 120;
  static const double _minViableHeight = 80;
  static const double _compactThreshold = 400;

  String get _effectiveLabel =>
      widget.semanticLabel ??
      widget.label ??
      OiBubbleChartAccessibility.generateSummary(widget.data);

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

  List<ResolvedBubble> _resolveBubbles(BuildContext context) {
    final data = widget.data;
    final resolved = <ResolvedBubble>[];

    // Find data ranges for normalisation.
    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    var minY = double.infinity;
    var maxY = double.negativeInfinity;
    var minSize = double.infinity;
    var maxSize = double.negativeInfinity;

    for (final series in data.series) {
      for (final point in series.points) {
        minX = math.min(minX, point.x);
        maxX = math.max(maxX, point.x);
        minY = math.min(minY, point.y);
        maxY = math.max(maxY, point.y);
        minSize = math.min(minSize, point.size);
        maxSize = math.max(maxSize, point.size);
      }
    }

    if (data.series.isEmpty || data.series.every((s) => s.points.isEmpty)) {
      return resolved;
    }

    // Prevent division by zero.
    final rangeX = maxX - minX == 0 ? 1.0 : maxX - minX;
    final rangeY = maxY - minY == 0 ? 1.0 : maxY - minY;
    final rangeSize = maxSize - minSize;

    final sizeConfig =
        data.sizeConfig ??
        const OiBubbleSizeConfig(minRadius: 4, maxRadius: 24);

    for (var si = 0; si < data.series.length; si++) {
      final series = data.series[si];
      for (var pi = 0; pi < series.points.length; pi++) {
        final point = series.points[pi];

        final normX = (point.x - minX) / rangeX;
        final normY = (point.y - minY) / rangeY;
        final normSize = rangeSize == 0
            ? 0.5
            : (point.size - minSize) / rangeSize;

        final radius =
            sizeConfig.minRadius +
            normSize * (sizeConfig.maxRadius - sizeConfig.minRadius);

        final color = OiBubbleChartTheme.resolveColor(
          si,
          series.style,
          point.style,
          context,
          chartTheme: widget.theme,
        );

        final opacity = OiBubbleChartTheme.resolveOpacity(
          series.style,
          point.style,
          chartTheme: widget.theme,
        );

        final borderWidth = OiBubbleChartTheme.resolveBorderWidth(
          series.style,
          chartTheme: widget.theme,
        );

        resolved.add(
          ResolvedBubble(
            x: normX,
            y: normY,
            radius: radius,
            color: color,
            opacity: opacity,
            borderWidth: borderWidth,
            borderColor: color,
            seriesIndex: si,
            pointIndex: pi,
          ),
        );
      }
    }

    return resolved;
  }

  Rect _chartRect(Size size, bool isCompact) {
    const pad = 40.0;
    const compactPad = 24.0;
    final p = isCompact ? compactPad : pad;
    return Rect.fromLTRB(p, p / 2, size.width - 8, size.height - p);
  }

  void _handleTapDown(
    TapDownDetails details,
    List<ResolvedBubble> bubbles,
    Size size,
    bool isCompact,
  ) {
    final rect = _chartRect(size, isCompact);
    final idx = findNearestBubble(details.localPosition, bubbles, rect);
    if (idx != null) {
      setState(() => _selectedBubbleIndex = idx);
    }
  }

  void _handleHover(
    PointerEvent event,
    List<ResolvedBubble> bubbles,
    Size size,
    bool isCompact,
  ) {
    final rect = _chartRect(size, isCompact);
    final idx = findNearestBubble(event.localPosition, bubbles, rect);
    if (idx != _hoveredBubbleIndex) {
      setState(() => _hoveredBubbleIndex = idx);
    }
  }

  Widget _buildFallbackPresentation(BuildContext context) {
    final colors = context.colors;
    return Center(
      key: const Key('oi_bubble_chart_fallback'),
      child: FittedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OiLabel.body('◉', color: colors.textMuted),
            OiLabel.caption('Chart too small', color: colors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactLayout(
    BuildContext context,
    List<ResolvedBubble> bubbles,
    Size size,
    OiChartInteractionMode mode,
  ) {
    return _buildChartBody(
      context,
      bubbles,
      size,
      isCompact: true,
      mode: mode,
      legendPosition: _LegendPosition.below,
    );
  }

  Widget _buildChartBody(
    BuildContext context,
    List<ResolvedBubble> bubbles,
    Size size, {
    required bool isCompact,
    required OiChartInteractionMode mode,
    _LegendPosition legendPosition = _LegendPosition.beside,
  }) {
    final colors = context.colors;
    final isHighContrast = OiA11y.highContrast(context);
    final reducedMotion = OiA11y.reducedMotion(context);
    final hoverIdx = reducedMotion ? null : _hoveredBubbleIndex;
    final data = widget.data;

    final chartWidget = SizedBox(
      key: const Key('oi_bubble_chart_canvas'),
      width: size.width,
      height: size.height,
      child: CustomPaint(
        key: const Key('oi_bubble_chart_painter'),
        size: size,
        painter: OiBubbleChartPainter(
          bubbles: bubbles,
          gridColor: colors.borderSubtle,
          axisLabelColor: colors.textMuted,
          textColor: colors.text,
          highContrast: isHighContrast,
          compact: isCompact,
          hoveredIndex: hoverIdx,
        ),
      ),
    );

    // Wrap with interaction handler.
    Widget interactiveChart;
    if (mode == OiChartInteractionMode.touch) {
      interactiveChart = GestureDetector(
        key: const Key('oi_bubble_chart_touch'),
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) => _handleTapDown(d, bubbles, size, isCompact),
        child: chartWidget,
      );
    } else {
      interactiveChart = MouseRegion(
        key: const Key('oi_bubble_chart_pointer'),
        onHover: (e) => _handleHover(e, bubbles, size, isCompact),
        onExit: (_) => setState(() => _hoveredBubbleIndex = null),
        child: chartWidget,
      );
    }

    // Build the focused bubble narration.
    final activeIdx = _selectedBubbleIndex ?? _hoveredBubbleIndex;
    Widget narration = const SizedBox.shrink();
    if (activeIdx != null && activeIdx < bubbles.length) {
      final b = bubbles[activeIdx];
      final series = data.series[b.seriesIndex];
      final point = series.points[b.pointIndex];
      final desc = OiBubbleChartAccessibility.describeBubble(
        point,
        series.name,
      );
      narration = Semantics(
        key: const Key('oi_bubble_chart_narration'),
        liveRegion: true,
        child: OiLabel.caption(desc, color: colors.textSubtle),
      );
    }

    // Legend widgets.
    final showLegend = data.series.length > 1;
    final hasSizeLegend = data.sizeConfig != null;

    final legendWidget = showLegend
        ? OiBubbleChartLegend(series: data.series, chartTheme: widget.theme)
        : const SizedBox.shrink();

    final sizeLegendWidget = hasSizeLegend
        ? OiBubbleChartSizeLegend(
            config: data.sizeConfig!,
            style: widget.theme?.sizeLegendStyle,
          )
        : const SizedBox.shrink();

    if (legendPosition == _LegendPosition.below || isCompact) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          interactiveChart,
          narration,
          if (showLegend)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: legendWidget,
            ),
          if (hasSizeLegend)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: sizeLegendWidget,
            ),
        ],
      );
    }

    // Default: legend beside.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: interactiveChart),
            if (showLegend || hasSizeLegend)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showLegend) legendWidget,
                    if (hasSizeLegend)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: sizeLegendWidget,
                      ),
                  ],
                ),
              ),
          ],
        ),
        narration,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _effectiveLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : 300.0;

          // Fallback for too-small viewport.
          if (w < _minViableWidth || h < _minViableHeight) {
            return SizedBox(
              width: w,
              height: h,
              child: _buildFallbackPresentation(context),
            );
          }

          final isCompact = widget.compact ?? (w < _compactThreshold);
          final mode = _resolveInteractionMode(context);
          final bubbles = _resolveBubbles(context);

          final chartSize = Size(
            w,
            math.min(h, isCompact ? w * 0.6 : w * 0.75),
          );

          if (isCompact) {
            return _buildCompactLayout(context, bubbles, chartSize, mode);
          }

          return _buildChartBody(
            context,
            bubbles,
            chartSize,
            isCompact: false,
            mode: mode,
          );
        },
      ),
    );
  }
}

enum _LegendPosition { beside, below }
