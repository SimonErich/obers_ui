import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// The trend direction for an [OiMetric].
///
/// {@category Components}
enum OiMetricTrend {
  /// Value is increasing.
  up,

  /// Value is decreasing.
  down,

  /// No significant change.
  neutral,
}

/// A metric display card showing a primary value, label, optional sub-value,
/// trend indicator, and an optional sparkline slot.
///
/// {@category Components}
class OiMetric extends StatelessWidget {
  /// Creates an [OiMetric].
  const OiMetric({
    required this.label,
    required this.value,
    this.subValue,
    this.trend,
    this.trendPercent,
    this.sparkline,
    super.key,
  });

  /// The metric label rendered below the primary value.
  final String label;

  /// The primary metric value displayed prominently.
  final String value;

  /// An optional secondary value shown below [value].
  final String? subValue;

  /// The trend direction. When non-null an arrow indicator is shown.
  final OiMetricTrend? trend;

  /// The percentage change shown next to the trend arrow.
  final double? trendPercent;

  /// An optional widget for a sparkline or mini-chart.
  final Widget? sparkline;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color trendColor;
    String trendArrow;
    switch (trend) {
      case OiMetricTrend.up:
        trendColor = colors.success.base;
        trendArrow = '↑';
      case OiMetricTrend.down:
        trendColor = colors.error.base;
        trendArrow = '↓';
      case OiMetricTrend.neutral:
      case null:
        trendColor = colors.textMuted;
        trendArrow = '→';
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasHeight = constraints.hasBoundedHeight;

        final content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primary value.
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: colors.text,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            // Label.
            Text(
              label,
              style: TextStyle(fontSize: 14, color: colors.textMuted),
            ),
            if (subValue != null) ...[
              const SizedBox(height: 2),
              Text(
                subValue!,
                style: TextStyle(fontSize: 12, color: colors.textSubtle),
              ),
            ],
            if (trend != null) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trendArrow,
                    style: TextStyle(
                      fontSize: 14,
                      color: trendColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (trendPercent != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      '${trendPercent!.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: trendColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
            if (sparkline != null) ...[const SizedBox(height: 8), sparkline!],
          ],
        );

        if (!hasHeight) return content;

        return ClipRect(child: content);
      },
    );
  }
}
