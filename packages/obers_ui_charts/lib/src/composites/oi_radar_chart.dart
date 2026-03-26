import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

/// Data for a radar chart series.
///
/// Each series provides a list of [values] corresponding to each axis,
/// rendered as a polygon on the radar chart.
class OiRadarSeries {
  /// Creates an [OiRadarSeries].
  const OiRadarSeries({
    required this.label,
    required this.values,
    this.color,
    this.fillOpacity = 0.2,
  });

  /// A human-readable label for this series, shown in the legend.
  final String label;

  /// The data values for each axis. Must have the same length as the
  /// chart's [OiRadarChart.axes] list.
  final List<double> values;

  /// An optional override color for this series. When null, a color
  /// from the theme's chart palette is used.
  final Color? color;

  /// The opacity of the filled polygon area. Defaults to 0.2.
  final double fillOpacity;
}

/// A radar / spider chart for comparing multiple dimensions.
///
/// Renders one or more [series] as overlapping polygons on a grid of
/// radial [axes]. Each axis extends from the center to [maxValue].
///
/// An optional legend is shown when [showLegend] is `true`. Axis labels
/// are placed at each spoke endpoint.
///
/// {@category Composites}
class OiRadarChart extends StatelessWidget {
  /// Creates an [OiRadarChart].
  const OiRadarChart({
    required this.axes,
    required this.series,
    required this.label,
    super.key,
    this.showLegend = true,
    this.showValues = false,
    this.maxValue,
    this.size,
  });

  /// The axis labels displayed around the chart perimeter.
  final List<String> axes;

  /// The data series to render as polygons.
  final List<OiRadarSeries> series;

  /// The accessibility label for the chart.
  final String label;

  /// Whether to show a legend below the chart.
  final bool showLegend;

  /// Whether to show numeric values at each polygon vertex.
  final bool showValues;

  /// The maximum value for the radial scale. When null, the maximum
  /// value across all series is used.
  final double? maxValue;

  /// The diameter of the chart. Defaults to the available width.
  final double? size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveSize = size ?? 200;
    final chartColors = colors.chart;

    // Resolve series colors.
    final resolvedSeries = <_ResolvedSeries>[];
    for (var i = 0; i < series.length; i++) {
      final s = series[i];
      resolvedSeries.add(
        _ResolvedSeries(
          values: s.values,
          color: s.color ?? chartColors[i % chartColors.length],
          fillOpacity: s.fillOpacity,
          label: s.label,
        ),
      );
    }

    return Semantics(
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: effectiveSize,
            height: effectiveSize,
            child: CustomPaint(
              key: const Key('oi_radar_chart_painter'),
              size: Size(effectiveSize, effectiveSize),
              painter: _OiRadarChartPainter(
                axes: axes,
                series: resolvedSeries,
                maxValue: _resolvedMaxValue,
                showValues: showValues,
                gridColor: colors.borderSubtle,
                axisLabelColor: colors.textMuted,
              ),
            ),
          ),
          if (showLegend && series.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                key: const Key('oi_radar_chart_legend'),
                spacing: 16,
                runSpacing: 4,
                children: [
                  for (var i = 0; i < resolvedSeries.length; i++)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: resolvedSeries[i].color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        OiLabel.caption(
                          resolvedSeries[i].label,
                          color: colors.textMuted,
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  double get _resolvedMaxValue {
    if (maxValue != null) return maxValue!;
    var mx = 0.0;
    for (final s in series) {
      for (final v in s.values) {
        if (v > mx) mx = v;
      }
    }
    return mx == 0 ? 1 : mx;
  }
}

/// Resolved series data with a concrete color.
class _ResolvedSeries {
  const _ResolvedSeries({
    required this.values,
    required this.color,
    required this.fillOpacity,
    required this.label,
  });

  final List<double> values;
  final Color color;
  final double fillOpacity;
  final String label;
}

/// Custom painter for the radar chart grid, spokes, and polygons.
class _OiRadarChartPainter extends CustomPainter {
  _OiRadarChartPainter({
    required this.axes,
    required this.series,
    required this.maxValue,
    required this.showValues,
    required this.gridColor,
    required this.axisLabelColor,
  });

  /// Axis labels.
  final List<String> axes;

  /// The resolved series data.
  final List<_ResolvedSeries> series;

  /// The maximum scale value.
  final double maxValue;

  /// Whether to paint value labels.
  final bool showValues;

  /// Color for grid lines.
  final Color gridColor;

  /// Color for axis label text.
  final Color axisLabelColor;

  static const int _gridLevels = 4;

  @override
  void paint(Canvas canvas, Size size) {
    if (axes.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.7;
    final n = axes.length;
    final angleStep = 2 * math.pi / n;

    // Draw grid levels.
    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (var level = 1; level <= _gridLevels; level++) {
      final r = radius * level / _gridLevels;
      final path = Path();
      for (var i = 0; i < n; i++) {
        final angle = -math.pi / 2 + i * angleStep;
        final point = Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw spokes.
    for (var i = 0; i < n; i++) {
      final angle = -math.pi / 2 + i * angleStep;
      final endpoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, endpoint, gridPaint);

      // Draw axis labels.
      final labelOffset = Offset(
        center.dx + (radius + 14) * math.cos(angle),
        center.dy + (radius + 14) * math.sin(angle),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: axes[i],
          style: TextStyle(color: axisLabelColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(labelOffset.dx - tp.width / 2, labelOffset.dy - tp.height / 2),
      );
    }

    // Draw series polygons.
    for (final s in series) {
      final path = Path();
      final fillPaint = Paint()
        ..color = s.color.withValues(alpha: s.fillOpacity)
        ..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (var i = 0; i < n; i++) {
        final v = i < s.values.length ? s.values[i] : 0.0;
        final ratio = (v / maxValue).clamp(0.0, 1.0);
        final angle = -math.pi / 2 + i * angleStep;
        final point = Offset(
          center.dx + radius * ratio * math.cos(angle),
          center.dy + radius * ratio * math.sin(angle),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }

        // Draw vertex dot.
        canvas.drawCircle(point, 3, Paint()..color = s.color);

        // Draw value labels.
        if (showValues) {
          final tp = TextPainter(
            text: TextSpan(
              text: v.toStringAsFixed(0),
              style: TextStyle(color: s.color, fontSize: 9),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, Offset(point.dx + 4, point.dy - tp.height - 2));
        }
      }
      path.close();
      canvas
        ..drawPath(path, fillPaint)
        ..drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(_OiRadarChartPainter oldDelegate) =>
      oldDelegate.axes != axes ||
      oldDelegate.series != series ||
      oldDelegate.maxValue != maxValue ||
      oldDelegate.showValues != showValues ||
      oldDelegate.gridColor != gridColor;
}
