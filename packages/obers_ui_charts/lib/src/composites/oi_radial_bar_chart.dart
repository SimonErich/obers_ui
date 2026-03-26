import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';

/// A mapper-first series for [OiRadialBarChart] that extracts a category
/// label and numeric value from a domain model [T].
///
/// One [OiRadialBarSeries] maps to one set of concentric rings drawn by the
/// chart. Each item in [data] becomes a separate ring.
///
/// {@category Composites}
class OiRadialBarSeries<T> {
  /// Creates an [OiRadialBarSeries].
  const OiRadialBarSeries({
    required this.id,
    required this.label,
    required this.data,
    required this.categoryMapper,
    required this.valueMapper,
    this.maxValue = 100,
    this.color,
    this.visible = true,
  });

  /// A unique identifier for this series.
  final String id;

  /// The display name for this series (shown in legend).
  final String label;

  /// The domain objects — one per concentric ring.
  final List<T> data;

  /// Extracts the category label from a domain object.
  ///
  /// This label is shown beside or at the end of each ring.
  final String Function(T item) categoryMapper;

  /// Extracts the numeric value from a domain object.
  ///
  /// Values are clamped to [0, maxValue] when rendering.
  final double Function(T item) valueMapper;

  /// The maximum value used to compute sweep angles. Defaults to 100.
  final double maxValue;

  /// An optional color override for all rings in this series.
  ///
  /// When null, the first color from the theme's chart palette is used
  /// and successive rings are rendered at decreasing opacities.
  final Color? color;

  /// Whether this series is visible. Defaults to `true`.
  final bool visible;
}

/// A radial bar chart rendering concentric arc rings.
///
/// Each item in the first visible [OiRadialBarSeries] is drawn as a ring.
/// Rings are ordered from the innermost radius outward. The sweep angle of
/// each ring is proportional to `value / maxValue * 2π`. An optional
/// background track (full circle) is drawn behind each ring.
///
/// Labels are drawn to the right of each ring's bar end when [showLabels]
/// is `true`.
///
/// ## Layout
///
/// The chart uses [LayoutBuilder] and fills all available width. The height
/// is kept square. When [compact] is `true` (or the available width is
/// narrower than 120 px), labels are hidden.
///
/// ## Accessibility
///
/// Set [semanticLabel] to override the default Semantics label built from
/// [label].
///
/// {@category Composites}
class OiRadialBarChart<T> extends StatefulWidget {
  /// Creates an [OiRadialBarChart].
  const OiRadialBarChart({
    required this.label,
    required this.series,
    super.key,
    this.startAngle = -90,
    this.innerRadius = 0.3,
    this.barSpacing = 4,
    this.showLabels = true,
    this.showBackground = true,
    this.behaviors = const [],
    this.controller,
    this.compact,
    this.semanticLabel,
  });

  /// The accessibility label for the chart.
  final String label;

  /// The series data to render. Only the first visible series is rendered.
  final List<OiRadialBarSeries<T>> series;

  /// The start angle in degrees measured clockwise from the positive x-axis.
  ///
  /// -90 places the start at the top (12 o'clock). Defaults to -90.
  final double startAngle;

  /// The inner radius as a fraction of the chart's available radius (0–1).
  ///
  /// Controls the hollow center. 0.3 means the innermost ring starts at 30 %
  /// of the total radius. Defaults to 0.3.
  final double innerRadius;

  /// The gap in logical pixels between concentric rings. Defaults to 4.
  final double barSpacing;

  /// Whether to draw category labels beside each ring. Defaults to `true`.
  final bool showLabels;

  /// Whether to draw a full-circle background track behind each ring.
  ///
  /// The background track is drawn at reduced opacity to indicate the
  /// available range. Defaults to `true`.
  final bool showBackground;

  /// Composable interaction behaviors.
  final List<OiChartBehavior> behaviors;

  /// External chart controller.
  final OiChartController? controller;

  /// When `true`, labels are hidden and the chart uses a minimal layout.
  ///
  /// When `null`, compactness is determined by the available width.
  final bool? compact;

  /// Override for the Semantics label. Defaults to [label].
  final String? semanticLabel;

  @override
  State<OiRadialBarChart<T>> createState() => _OiRadialBarChartState<T>();
}

class _OiRadialBarChartState<T> extends State<OiRadialBarChart<T>> {
  static const double _minViableSize = 60;
  static const double _compactBreakpoint = 120;

  // ── Helpers ──────────────────────────────────────────────────────────────

  OiRadialBarSeries<T>? get _activeSeries {
    for (final s in widget.series) {
      if (s.visible) return s;
    }
    return null;
  }

  bool _isCompact(double availableWidth) =>
      widget.compact ?? (availableWidth < _compactBreakpoint);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveSemanticLabel = widget.semanticLabel ?? widget.label;

    return Semantics(
      label: effectiveSemanticLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;

          if (w < _minViableSize) {
            return SizedBox(
              width: w,
              height: w,
              child: const Center(
                key: Key('oi_radial_bar_chart_fallback'),
                child: OiLabel.caption('…'),
              ),
            );
          }

          final isCompact = _isCompact(w);
          // Reserve space on the right for labels when not compact.
          final labelReserve = isCompact ? 0.0 : 64.0;
          final chartDim = w - labelReserve;

          final activeSeries = _activeSeries;
          if (activeSeries == null || activeSeries.data.isEmpty) {
            return SizedBox(
              key: const Key('oi_radial_bar_chart_empty'),
              width: w,
              height: w,
            );
          }

          final items = activeSeries.data;
          final n = items.length;
          final chartColors = colors.chart;
          final baseColor =
              activeSeries.color ?? chartColors[0 % chartColors.length];

          // Resolve per-ring colors: same hue, fading opacity for inner rings.
          final resolvedColors = List<Color>.generate(n, (i) {
            final opacity = 1.0 - (i / n) * 0.45;
            return baseColor.withValues(alpha: opacity);
          });

          return SizedBox(
            key: const Key('oi_radial_bar_chart'),
            width: w,
            height: chartDim,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Chart painter.
                Positioned(
                  left: 0,
                  top: 0,
                  width: chartDim,
                  height: chartDim,
                  child: CustomPaint(
                    key: const Key('oi_radial_bar_chart_painter'),
                    size: Size(chartDim, chartDim),
                    painter: _OiRadialBarPainter(
                      items: items,
                      categoryMapper: activeSeries.categoryMapper,
                      valueMapper: activeSeries.valueMapper,
                      maxValue: activeSeries.maxValue,
                      startAngle: widget.startAngle * math.pi / 180,
                      innerRadius: widget.innerRadius,
                      barSpacing: widget.barSpacing,
                      showBackground: widget.showBackground,
                      colors: resolvedColors,
                      trackColor: colors.borderSubtle,
                    ),
                  ),
                ),
                // Labels overlay — placed to the right of the painter.
                if (!isCompact)
                  Positioned(
                    left: chartDim + 8,
                    top: 0,
                    width: labelReserve - 8,
                    height: chartDim,
                    child: _buildLabels(
                      context,
                      items,
                      activeSeries,
                      chartDim,
                      resolvedColors,
                      colors,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabels(
    BuildContext context,
    List<T> items,
    OiRadialBarSeries<T> activeSeries,
    double chartDim,
    List<Color> resolvedColors,
    OiColorScheme colors,
  ) {
    final n = items.length;
    if (n == 0) return const SizedBox.shrink();

    // Mirror the ring layout so labels align with their ring's centre.
    final radius = chartDim / 2;
    final innerR = radius * widget.innerRadius;
    final totalAnnular = radius - innerR;
    final ringThickness = (totalAnnular - widget.barSpacing * (n - 1)) / n;

    return CustomPaint(
      size: Size(56, chartDim),
      painter: _OiRadialBarLabelPainter(
        items: items,
        categoryMapper: activeSeries.categoryMapper,
        valueMapper: activeSeries.valueMapper,
        maxValue: activeSeries.maxValue,
        n: n,
        innerRadius: innerR,
        ringThickness: ringThickness,
        barSpacing: widget.barSpacing,
        chartDim: chartDim,
        colors: resolvedColors,
        textColor: colors.textMuted,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter: arcs
// ─────────────────────────────────────────────────────────────────────────────

class _OiRadialBarPainter<T> extends CustomPainter {
  _OiRadialBarPainter({
    required this.items,
    required this.categoryMapper,
    required this.valueMapper,
    required this.maxValue,
    required this.startAngle,
    required this.innerRadius,
    required this.barSpacing,
    required this.showBackground,
    required this.colors,
    required this.trackColor,
  });

  final List<T> items;
  final String Function(T) categoryMapper;
  final double Function(T) valueMapper;
  final double maxValue;

  /// Start angle in radians.
  final double startAngle;

  /// Inner radius as a fraction of the available radius (0–1).
  final double innerRadius;

  final double barSpacing;
  final bool showBackground;
  final List<Color> colors;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    final n = items.length;
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2 * 0.92;
    final innerR = outerRadius * innerRadius;
    final totalAnnular = outerRadius - innerR;
    final ringThickness = n > 0
        ? (totalAnnular - barSpacing * (n - 1)) / n
        : totalAnnular;

    for (var i = 0; i < n; i++) {
      // Rings from inner → outer, reversed so index 0 is outermost.
      final ringIndex = n - 1 - i;
      final midRadius =
          innerR + ringIndex * (ringThickness + barSpacing) + ringThickness / 2;
      final rect = Rect.fromCircle(center: center, radius: midRadius);

      // Background track.
      if (showBackground) {
        final trackPaint = Paint()
          ..color = trackColor.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringThickness
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(rect, startAngle, 2 * math.pi, false, trackPaint);
      }

      // Value arc.
      final value = valueMapper(items[i]).clamp(0.0, maxValue);
      final sweep = maxValue > 0 ? (value / maxValue) * 2 * math.pi : 0.0;

      final barPaint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringThickness
        ..strokeCap = StrokeCap.round;

      if (sweep > 0) {
        canvas.drawArc(rect, startAngle, sweep, false, barPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_OiRadialBarPainter<T> old) =>
      old.items != items ||
      old.maxValue != maxValue ||
      old.startAngle != startAngle ||
      old.innerRadius != innerRadius ||
      old.barSpacing != barSpacing ||
      old.showBackground != showBackground ||
      old.colors != colors ||
      old.trackColor != trackColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter: labels aligned with rings
// ─────────────────────────────────────────────────────────────────────────────

class _OiRadialBarLabelPainter<T> extends CustomPainter {
  _OiRadialBarLabelPainter({
    required this.items,
    required this.categoryMapper,
    required this.valueMapper,
    required this.maxValue,
    required this.n,
    required this.innerRadius,
    required this.ringThickness,
    required this.barSpacing,
    required this.chartDim,
    required this.colors,
    required this.textColor,
  });

  final List<T> items;
  final String Function(T) categoryMapper;
  final double Function(T) valueMapper;
  final double maxValue;
  final int n;
  final double innerRadius;
  final double ringThickness;
  final double barSpacing;
  final double chartDim;
  final List<Color> colors;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    final chartCenter = chartDim / 2;

    for (var i = 0; i < n; i++) {
      final ringIndex = n - 1 - i;
      final midRadius =
          innerRadius +
          ringIndex * (ringThickness + barSpacing) +
          ringThickness / 2;
      // The y-centre of this ring in the chart's coordinate space maps to the
      // same y in the label overlay (both are chartDim tall, same vertical
      // origin, since the chart circle is centred at chartDim/2).
      final ringCenterY = chartCenter - midRadius;

      final label = categoryMapper(items[i]);
      final value = valueMapper(items[i]);
      final valueText = value.toStringAsFixed(0);

      final labelTp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: colors[i % colors.length],
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        ellipsis: '…',
        maxLines: 1,
      )..layout(maxWidth: size.width);

      final valueTp = TextPainter(
        text: TextSpan(
          text: valueText,
          style: TextStyle(color: textColor, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width);

      final totalTextHeight = labelTp.height + valueTp.height;
      final yTop = ringCenterY - totalTextHeight / 2;

      labelTp.paint(canvas, Offset(0, yTop));
      valueTp.paint(canvas, Offset(0, yTop + labelTp.height));
    }
  }

  @override
  bool shouldRepaint(_OiRadialBarLabelPainter<T> old) =>
      old.items != items ||
      old.n != n ||
      old.innerRadius != innerRadius ||
      old.ringThickness != ringThickness ||
      old.chartDim != chartDim ||
      old.colors != colors ||
      old.textColor != textColor;
}
