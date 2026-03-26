import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';

/// A mapper-first series for [OiPolarAreaChart] that extracts a category
/// label and numeric value from a domain model [T].
///
/// Each item in [data] becomes one equal-angle wedge. All series are overlaid
/// on the same polar axis, so using more than one series shows multiple
/// layers of wedges.
///
/// {@category Composites}
class OiPolarAreaSeries<T> {
  /// Creates an [OiPolarAreaSeries].
  const OiPolarAreaSeries({
    required this.id,
    required this.label,
    required this.data,
    required this.categoryMapper,
    required this.valueMapper,
    this.color,
    this.visible = true,
  });

  /// A unique identifier for this series.
  final String id;

  /// The display name for this series (shown in legend).
  final String label;

  /// The domain objects — one per wedge.
  final List<T> data;

  /// Extracts the category label from a domain object.
  ///
  /// Labels are placed around the perimeter at each wedge's angular midpoint.
  final String Function(T item) categoryMapper;

  /// Extracts the numeric value from a domain object.
  ///
  /// The wedge's radius is proportional to `value / maxValue` where `maxValue`
  /// is the maximum value across all visible series.
  final double Function(T item) valueMapper;

  /// An optional color override for this series' wedges.
  ///
  /// When null, the theme's chart palette color at the series index is used.
  final Color? color;

  /// Whether this series is visible. Defaults to `true`.
  final bool visible;
}

/// A polar area chart in which each wedge occupies an equal arc angle and
/// its radius encodes a numeric value.
///
/// All visible [series] must have the same number of items; each item index
/// maps to the same wedge position. The maximum value across all series
/// determines the radial scale.
///
/// An optional legend is displayed below the chart when [showLegend] is
/// `true`. Category labels are placed at the perimeter when [showLabels] is
/// `true`.
///
/// ## Layout
///
/// The chart fills available width. Height equals width. When [compact] is
/// `true` (or the available width is below 120 px), labels and the legend
/// are hidden.
///
/// ## Accessibility
///
/// Set [semanticLabel] to override the Semantics label built from [label].
///
/// {@category Composites}
class OiPolarAreaChart<T> extends StatefulWidget {
  /// Creates an [OiPolarAreaChart].
  const OiPolarAreaChart({
    required this.label,
    required this.series,
    super.key,
    this.startAngle = -90,
    this.showLabels = true,
    this.showLegend = true,
    this.fillOpacity = 0.65,
    this.behaviors = const [],
    this.controller,
    this.compact,
    this.semanticLabel,
  });

  /// The accessibility label for the chart.
  final String label;

  /// The data series to render as overlapping sets of wedges.
  final List<OiPolarAreaSeries<T>> series;

  /// The start angle in degrees measured clockwise from the positive x-axis.
  ///
  /// -90 places the first wedge starting at the top (12 o'clock).
  /// Defaults to -90.
  final double startAngle;

  /// Whether to show category labels around the perimeter. Defaults to `true`.
  final bool showLabels;

  /// Whether to show a legend below the chart. Defaults to `true`.
  final bool showLegend;

  /// The fill opacity for all wedges (0.0–1.0). Defaults to 0.65.
  final double fillOpacity;

  /// Composable interaction behaviors.
  final List<OiChartBehavior> behaviors;

  /// External chart controller.
  final OiChartController? controller;

  /// When `true`, labels and legend are hidden and the chart uses a minimal
  /// layout. When `null`, compactness is determined by available width.
  final bool? compact;

  /// Override for the Semantics label. Defaults to [label].
  final String? semanticLabel;

  @override
  State<OiPolarAreaChart<T>> createState() => _OiPolarAreaChartState<T>();
}

class _OiPolarAreaChartState<T> extends State<OiPolarAreaChart<T>> {
  static const double _minViableSize = 60;
  static const double _compactBreakpoint = 120;

  bool _isCompact(double availableWidth) =>
      widget.compact ?? (availableWidth < _compactBreakpoint);

  // Compute the global max value across all visible series.
  double _computeMaxValue() {
    var mx = 0.0;
    for (final s in widget.series) {
      if (!s.visible) continue;
      for (final item in s.data) {
        final v = s.valueMapper(item);
        if (v > mx) mx = v;
      }
    }
    return mx == 0 ? 1 : mx;
  }

  List<OiPolarAreaSeries<T>> get _visibleSeries =>
      widget.series.where((s) => s.visible).toList();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveSemanticLabel = widget.semanticLabel ?? widget.label;
    final chartColors = colors.chart;

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
                key: Key('oi_polar_area_chart_fallback'),
                child: OiLabel.caption('…'),
              ),
            );
          }

          final isCompact = _isCompact(w);
          final visibleSeries = _visibleSeries;

          if (visibleSeries.isEmpty) {
            return SizedBox(
              key: const Key('oi_polar_area_chart_empty'),
              width: w,
              height: w,
            );
          }

          final maxValue = _computeMaxValue();
          final startAngleRad = widget.startAngle * math.pi / 180;

          // Resolve series colors.
          final resolvedColors = <Color>[
            for (var i = 0; i < visibleSeries.length; i++)
              visibleSeries[i].color ?? chartColors[i % chartColors.length],
          ];

          final legendSpace =
              (!isCompact && widget.showLegend && visibleSeries.isNotEmpty)
              ? 32.0
              : 0.0;

          final chartDim = w;

          return Column(
            key: const Key('oi_polar_area_chart'),
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: chartDim,
                height: chartDim,
                child: CustomPaint(
                  key: const Key('oi_polar_area_chart_painter'),
                  size: Size(chartDim, chartDim),
                  painter: _OiPolarAreaPainter<T>(
                    series: visibleSeries,
                    resolvedColors: resolvedColors,
                    maxValue: maxValue,
                    startAngle: startAngleRad,
                    showLabels: !isCompact && widget.showLabels,
                    fillOpacity: widget.fillOpacity,
                    gridColor: colors.borderSubtle,
                    labelColor: colors.textMuted,
                  ),
                ),
              ),
              if (!isCompact && widget.showLegend && visibleSeries.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    height: legendSpace,
                    child: Wrap(
                      key: const Key('oi_polar_area_chart_legend'),
                      spacing: 16,
                      runSpacing: 4,
                      children: [
                        for (var i = 0; i < visibleSeries.length; i++)
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
                                visibleSeries[i].label,
                                color: colors.textMuted,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _OiPolarAreaPainter<T> extends CustomPainter {
  _OiPolarAreaPainter({
    required this.series,
    required this.resolvedColors,
    required this.maxValue,
    required this.startAngle,
    required this.showLabels,
    required this.fillOpacity,
    required this.gridColor,
    required this.labelColor,
  });

  final List<OiPolarAreaSeries<T>> series;
  final List<Color> resolvedColors;
  final double maxValue;

  /// Start angle in radians.
  final double startAngle;

  final bool showLabels;
  final double fillOpacity;
  final Color gridColor;
  final Color labelColor;

  static const int _gridLevels = 4;
  static const double _labelPadding = 12;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;

    // All visible series are assumed to have the same number of items for
    // consistent wedge angles. Use the first series as the domain source.
    final domainSeries = series.first;
    final n = domainSeries.data.length;
    if (n == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    // Leave radial padding for labels.
    final labelPad = showLabels ? _labelPadding + 20.0 : 8.0;
    final outerRadius = math.min(size.width, size.height) / 2 - labelPad;
    if (outerRadius <= 0) return;

    final wedgeAngle = 2 * math.pi / n;

    // ── Grid circles ─────────────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (var level = 1; level <= _gridLevels; level++) {
      final r = outerRadius * level / _gridLevels;
      canvas.drawCircle(center, r, gridPaint);
    }

    // ── Grid spokes ───────────────────────────────────────────────────────
    for (var i = 0; i < n; i++) {
      final angle = startAngle + i * wedgeAngle;
      final endpoint = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );
      canvas.drawLine(center, endpoint, gridPaint);
    }

    // ── Wedges per series ─────────────────────────────────────────────────
    for (var si = 0; si < series.length; si++) {
      final s = series[si];
      final seriesColor = resolvedColors[si];

      final fillPaint = Paint()
        ..color = seriesColor.withValues(alpha: fillOpacity)
        ..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = seriesColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      for (var i = 0; i < n; i++) {
        final item = i < s.data.length ? s.data[i] : s.data.last;
        final value = s.valueMapper(item).clamp(0.0, maxValue);
        final wedgeRadius = maxValue > 0
            ? (value / maxValue) * outerRadius
            : 0.0;

        if (wedgeRadius <= 0) continue;

        final angleStart = startAngle + i * wedgeAngle;
        final rect = Rect.fromCircle(center: center, radius: wedgeRadius);

        final path = Path()
          ..moveTo(center.dx, center.dy)
          ..arcTo(rect, angleStart, wedgeAngle, false)
          ..close();

        canvas
          ..drawPath(path, fillPaint)
          ..drawPath(path, strokePaint);
      }
    }

    // ── Category labels at perimeter ──────────────────────────────────────
    if (showLabels) {
      for (var i = 0; i < n; i++) {
        final item = domainSeries.data[i];
        final categoryLabel = domainSeries.categoryMapper(item);

        // Place label at the midpoint angle of the wedge.
        final midAngle = startAngle + i * wedgeAngle + wedgeAngle / 2;
        final labelRadius = outerRadius + _labelPadding;
        final labelPos = Offset(
          center.dx + labelRadius * math.cos(midAngle),
          center.dy + labelRadius * math.sin(midAngle),
        );

        final tp = TextPainter(
          text: TextSpan(
            text: categoryLabel,
            style: TextStyle(color: labelColor, fontSize: 10),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        tp.paint(
          canvas,
          Offset(labelPos.dx - tp.width / 2, labelPos.dy - tp.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_OiPolarAreaPainter<T> old) =>
      old.series != series ||
      old.resolvedColors != resolvedColors ||
      old.maxValue != maxValue ||
      old.startAngle != startAngle ||
      old.showLabels != showLabels ||
      old.fillOpacity != fillOpacity ||
      old.gridColor != gridColor ||
      old.labelColor != labelColor;
}
