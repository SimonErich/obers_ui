import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/oi_bubble_chart/oi_bubble_chart_interaction.dart';

/// A single segment in an [OiPieChart].
///
/// {@category Composites}
class OiPieSegment {
  /// Creates an [OiPieSegment].
  const OiPieSegment({required this.label, required this.value, this.color});

  /// The display label for this segment.
  final String label;

  /// The numeric value of this segment.
  final double value;

  /// An optional color override. When null, a color from the theme's chart
  /// palette is used.
  final Color? color;
}

/// A pie or donut chart for visualising proportional data.
///
/// Renders [segments] as arcs whose sweep angles are proportional to their
/// values. Supports a [donut] variant with a configurable ring width and
/// optional [centerLabel].
///
/// {@category Composites}
class OiPieChart extends StatefulWidget {
  /// Creates an [OiPieChart].
  const OiPieChart({
    required this.label,
    required this.segments,
    super.key,
    this.donut = false,
    this.donutWidth = 0.4,
    this.centerLabel,
    this.showLabels = true,
    this.showPercentages = true,
    this.showValues = false,
    this.showLegend = true,
    this.onSegmentTap,
    this.interactionMode,
    this.compact,
  });

  /// Accessibility label for the chart.
  final String label;

  /// The data segments to render.
  final List<OiPieSegment> segments;

  /// Whether to render as a donut chart with a hollow center.
  final bool donut;

  /// The ring width as a ratio of the radius when [donut] is `true`.
  final double donutWidth;

  /// Optional text displayed in the donut center.
  final String? centerLabel;

  /// Whether to show segment labels on the chart.
  final bool showLabels;

  /// Whether to show percentage values on the chart.
  final bool showPercentages;

  /// Whether to show raw values on the chart.
  final bool showValues;

  /// Whether to show a legend below or beside the chart.
  final bool showLegend;

  /// Callback when a segment is tapped.
  final ValueChanged<int>? onSegmentTap;

  /// Interaction mode. Defaults to [OiChartInteractionMode.auto].
  final OiChartInteractionMode? interactionMode;

  /// Whether to use compact layout. When null, determined by available width.
  final bool? compact;

  @override
  State<OiPieChart> createState() => _OiPieChartState();
}

class _OiPieChartState extends State<OiPieChart> {
  int? _hoveredSegmentIndex;

  static const double _minViableSize = 80;

  double get _total => widget.segments.fold(0, (sum, s) => sum + s.value);

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

  int? _hitTest(Offset position, Size chartSize) {
    final center = Offset(chartSize.width / 2, chartSize.height / 2);
    final radius = math.min(chartSize.width, chartSize.height) / 2 * 0.85;
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);

    if (distance > radius) return null;
    if (widget.donut) {
      final innerRadius = radius * (1 - widget.donutWidth);
      if (distance < innerRadius) return null;
    }

    var angle = math.atan2(dy, dx) - (-math.pi / 2);
    if (angle < 0) angle += 2 * math.pi;

    final total = _total;
    if (total <= 0) return null;

    var cumulative = 0.0;
    for (var i = 0; i < widget.segments.length; i++) {
      cumulative += widget.segments[i].value;
      final segmentAngle = 2 * math.pi * cumulative / total;
      if (angle <= segmentAngle) return i;
    }
    return null;
  }

  void _handleTapDown(TapDownDetails details, Size chartSize) {
    final idx = _hitTest(details.localPosition, chartSize);
    if (idx != null) {
      widget.onSegmentTap?.call(idx);
    }
  }

  void _handleHover(PointerEvent event, Size chartSize) {
    final idx = _hitTest(event.localPosition, chartSize);
    if (idx != _hoveredSegmentIndex) {
      setState(() => _hoveredSegmentIndex = idx);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.segments.isEmpty) {
      return const SizedBox.shrink(key: Key('oi_pie_chart_empty'));
    }

    final colors = context.colors;
    final chartColors = colors.chart;
    final reducedMotion = OiA11y.reducedMotion(context);
    final isHighContrast = OiA11y.highContrast(context);

    return Semantics(
      label: widget.label,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : w * 0.75;

          if (w < _minViableSize || h < _minViableSize) {
            return SizedBox(
              width: w,
              height: h,
              child: const Center(
                key: Key('oi_pie_chart_fallback'),
                child: OiLabel.caption('…'),
              ),
            );
          }

          final mode = _resolveInteractionMode(context);

          // Reserve space for legend below.
          final legendSpace = widget.showLegend && widget.segments.isNotEmpty
              ? 30.0
              : 0.0;
          final chartDim = math.min(w, h - legendSpace);
          final chartSize = Size(chartDim, chartDim);

          // Resolve segment colors.
          final resolvedColors = <Color>[
            for (var i = 0; i < widget.segments.length; i++)
              widget.segments[i].color ?? chartColors[i % chartColors.length],
          ];

          final hoverIdx = reducedMotion ? null : _hoveredSegmentIndex;

          final painter = CustomPaint(
            key: const Key('oi_pie_chart_painter'),
            size: chartSize,
            painter: _OiPieChartPainter(
              segments: widget.segments,
              colors: resolvedColors,
              total: _total,
              donut: widget.donut,
              donutWidth: widget.donutWidth,
              showLabels: widget.showLabels,
              showPercentages: widget.showPercentages,
              showValues: widget.showValues,
              hoveredIndex: hoverIdx,
              highContrast: isHighContrast,
              labelColor: colors.text,
              borderColor: colors.surface,
            ),
            child: widget.donut && widget.centerLabel != null
                ? Center(
                    child: OiLabel.body(
                      widget.centerLabel!,
                      key: const Key('oi_pie_chart_center_label'),
                      color: colors.text,
                    ),
                  )
                : null,
          );

          // Wrap with interaction handler.
          Widget interactiveChart;
          if (mode == OiChartInteractionMode.touch) {
            interactiveChart = GestureDetector(
              key: const Key('oi_pie_chart_touch'),
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) => _handleTapDown(d, chartSize),
              child: SizedBox.fromSize(size: chartSize, child: painter),
            );
          } else {
            interactiveChart = MouseRegion(
              key: const Key('oi_pie_chart_pointer'),
              onHover: (e) => _handleHover(e, chartSize),
              onExit: (_) => setState(() => _hoveredSegmentIndex = null),
              child: SizedBox.fromSize(size: chartSize, child: painter),
            );
          }

          // Legend.
          final legendWidget = widget.showLegend
              ? Wrap(
                  key: const Key('oi_pie_chart_legend'),
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    for (var i = 0; i < widget.segments.length; i++)
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
                            widget.segments[i].label,
                            color: colors.textMuted,
                          ),
                        ],
                      ),
                  ],
                )
              : null;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              interactiveChart,
              if (legendWidget != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: legendWidget,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _OiPieChartPainter extends CustomPainter {
  _OiPieChartPainter({
    required this.segments,
    required this.colors,
    required this.total,
    required this.donut,
    required this.donutWidth,
    required this.showLabels,
    required this.showPercentages,
    required this.showValues,
    required this.highContrast,
    required this.labelColor,
    required this.borderColor,
    this.hoveredIndex,
  });

  final List<OiPieSegment> segments;
  final List<Color> colors;
  final double total;
  final bool donut;
  final double donutWidth;
  final bool showLabels;
  final bool showPercentages;
  final bool showValues;
  final bool highContrast;
  final Color labelColor;
  final Color borderColor;
  final int? hoveredIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty || total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.85;
    final innerRadius = donut ? radius * (1 - donutWidth) : 0.0;

    var startAngle = -math.pi / 2; // Start at top.

    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final sweepAngle = 2 * math.pi * segment.value / total;

      final isHovered = hoveredIndex == i;
      final drawRadius = isHovered ? radius + 4 : radius;

      // Draw arc.
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      if (donut) {
        // Draw as thick arc stroke.
        final arcRadius = (drawRadius + innerRadius) / 2;
        final strokeW = drawRadius - innerRadius;
        final arcPaint = Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: arcRadius),
          startAngle,
          sweepAngle,
          false,
          arcPaint,
        );
      } else {
        final path = Path()
          ..moveTo(center.dx, center.dy)
          ..arcTo(
            Rect.fromCircle(center: center, radius: drawRadius),
            startAngle,
            sweepAngle,
            false,
          )
          ..close();
        canvas.drawPath(path, paint);
      }

      // Draw borders between segments.
      if (highContrast || segments.length > 1) {
        final borderPaint = Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = highContrast ? 3.0 : 1.5;

        if (!donut) {
          final path = Path()
            ..moveTo(center.dx, center.dy)
            ..arcTo(
              Rect.fromCircle(center: center, radius: drawRadius),
              startAngle,
              sweepAngle,
              false,
            )
            ..close();
          canvas.drawPath(path, borderPaint);
        }
      }

      // Draw label / percentage at midpoint of arc.
      final midAngle = startAngle + sweepAngle / 2;
      final labelRadius = donut
          ? (drawRadius + innerRadius) / 2
          : drawRadius * 0.65;

      // Only show labels if the segment is large enough.
      if (sweepAngle > 0.3) {
        final parts = <String>[];
        if (showLabels) parts.add(segment.label);
        if (showPercentages) {
          parts.add('${(segment.value / total * 100).toStringAsFixed(0)}%');
        }
        if (showValues) {
          parts.add(segment.value.toStringAsFixed(0));
        }

        if (parts.isNotEmpty) {
          final labelText = parts.join('\n');
          final tp = TextPainter(
            text: TextSpan(
              text: labelText,
              style: TextStyle(
                color: donut ? labelColor : borderColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          )..layout();

          final labelPos = Offset(
            center.dx + labelRadius * math.cos(midAngle) - tp.width / 2,
            center.dy + labelRadius * math.sin(midAngle) - tp.height / 2,
          );
          tp.paint(canvas, labelPos);
        }
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_OiPieChartPainter oldDelegate) =>
      oldDelegate.segments != segments ||
      oldDelegate.colors != colors ||
      oldDelegate.total != total ||
      oldDelegate.donut != donut ||
      oldDelegate.donutWidth != donutWidth ||
      oldDelegate.showLabels != showLabels ||
      oldDelegate.showPercentages != showPercentages ||
      oldDelegate.showValues != showValues ||
      oldDelegate.hoveredIndex != hoveredIndex ||
      oldDelegate.highContrast != highContrast;
}
