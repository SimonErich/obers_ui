import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/oi_sparkline.dart';
import 'package:obers_ui_charts/src/modules/oi_kpi_format.dart';
import 'package:obers_ui_charts/src/modules/oi_kpi_metric.dart';

/// A single-metric display card for use inside `OiKpiBoard`.
///
/// Renders a [metric] in one of three [style] modes:
/// - [OiKpiCardStyle.standard] — title, value, delta, sparkline, target bar.
/// - [OiKpiCardStyle.compact] — title, value, and delta only.
/// - [OiKpiCardStyle.detailed] — standard plus trend description and sparkline
///   statistics (min / max / avg).
///
/// Visual appearance adapts to [OiKpiMetric.status] for color-coded emphasis:
/// - [OiKpiStatus.onTrack] → success green
/// - [OiKpiStatus.needsAttention] → warning amber
/// - [OiKpiStatus.critical] → error red
/// - [OiKpiStatus.neutral] → primary
///
/// The delta indicator shows a directional arrow (↑ / ↓) with the percentage
/// change and is colored green for positive, red for negative.
///
/// {@category Modules}
class OiKpiCard extends StatelessWidget {
  /// Creates an [OiKpiCard].
  const OiKpiCard({
    required this.metric,
    super.key,
    this.style = OiKpiCardStyle.standard,
    this.showSparkline = true,
    this.showDelta = true,
    this.showTarget = true,
  });

  /// The metric data to display.
  final OiKpiMetric metric;

  /// The visual layout style for this card.
  final OiKpiCardStyle style;

  /// Whether to display the inline sparkline (if [OiKpiMetric.sparklineData]
  /// is provided). Only shown for [OiKpiCardStyle.standard] and
  /// [OiKpiCardStyle.detailed].
  final bool showSparkline;

  /// Whether to display the delta arrow and percentage change.
  final bool showDelta;

  /// Whether to display the target progress bar
  /// (if [OiKpiMetric.target] is provided). Only shown for
  /// [OiKpiCardStyle.standard] and [OiKpiCardStyle.detailed].
  final bool showTarget;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusColor = _statusColor(colors);
    final isCompact = style == OiKpiCardStyle.compact;

    return Semantics(
      label: _semanticDescription(),
      child: OiSurface(
        color: colors.surface,
        border: OiBorderStyle.solid(colors.borderSubtle, 1),
        borderRadius: BorderRadius.circular(8),
        padding: EdgeInsets.all(isCompact ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Title ─────────────────────────────────────────────────────
            OiLabel.caption(
              metric.title,
              color: colors.textMuted,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              key: const Key('oi_kpi_card_title'),
            ),
            const SizedBox(height: 6),

            // ── Primary value + delta row ──────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: OiLabel.h3(
                    metric.formattedValue,
                    color: statusColor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    key: const Key('oi_kpi_card_value'),
                  ),
                ),
                if (showDelta && metric.deltaPercent != null) ...[
                  const SizedBox(width: 8),
                  _DeltaBadge(percent: metric.deltaPercent!, colors: colors),
                ],
              ],
            ),

            // ── Sparkline ─────────────────────────────────────────────────
            if (!isCompact &&
                showSparkline &&
                metric.sparklineData != null &&
                metric.sparklineData!.isNotEmpty) ...[
              const SizedBox(height: 10),
              OiSparkline(
                label: '${metric.title} trend',
                values: metric.sparklineData!,
                color: statusColor,
                fill: true,
                height: 36,
                key: const Key('oi_kpi_card_sparkline'),
              ),
            ],

            // ── Target progress bar ────────────────────────────────────────
            if (!isCompact &&
                showTarget &&
                metric.target != null &&
                metric.targetProgress != null) ...[
              const SizedBox(height: 10),
              _TargetProgressBar(
                progress: metric.targetProgress!,
                target: metric.target!,
                format: metric.format,
                progressColor: statusColor,
                trackColor: colors.borderSubtle,
                colors: colors,
              ),
            ],

            // ── Detailed stats (min / max / avg from sparkline) ────────────
            if (style == OiKpiCardStyle.detailed &&
                metric.sparklineData != null &&
                metric.sparklineData!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _SparklineStats(
                data: metric.sparklineData!,
                format: metric.format,
                colors: colors,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(OiColorScheme colors) => switch (metric.status) {
    OiKpiStatus.onTrack => colors.success.base,
    OiKpiStatus.needsAttention => colors.warning.base,
    OiKpiStatus.critical => colors.error.base,
    OiKpiStatus.neutral => colors.primary.base,
  };

  String _semanticDescription() {
    final delta = metric.deltaPercent;
    final deltaStr = delta == null
        ? ''
        : ', ${delta >= 0 ? 'up' : 'down'} ${delta.abs().toStringAsFixed(1)} percent';
    return '${metric.title}: ${metric.formattedValue}$deltaStr';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DeltaBadge — arrow + percentage change
// ─────────────────────────────────────────────────────────────────────────────

class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge({required this.percent, required this.colors});

  final double percent;
  final OiColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final isPositive = percent >= 0;
    final arrow = isPositive ? '↑' : '↓';
    final color = isPositive ? colors.success.base : colors.error.base;
    final text = '$arrow${percent.abs().toStringAsFixed(1)}%';

    return OiLabel.small(
      text,
      color: color,
      key: const Key('oi_kpi_card_delta'),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TargetProgressBar — value vs. target
// ─────────────────────────────────────────────────────────────────────────────

class _TargetProgressBar extends StatelessWidget {
  const _TargetProgressBar({
    required this.progress,
    required this.target,
    required this.progressColor,
    required this.trackColor,
    required this.colors,
    this.format,
  });

  final double progress;
  final num target;
  final OiKpiFormat? format;
  final Color progressColor;
  final Color trackColor;
  final OiColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final targetLabel = format?.format(target) ?? target.toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar track.
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Track.
                Container(
                  height: 4,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: trackColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Fill.
                Container(
                  height: 4,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 4),
        OiLabel.caption(
          'Target: $targetLabel',
          color: colors.textMuted,
          key: const Key('oi_kpi_card_target_label'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SparklineStats — min / max / avg shown in detailed mode
// ─────────────────────────────────────────────────────────────────────────────

class _SparklineStats extends StatelessWidget {
  const _SparklineStats({
    required this.data,
    required this.colors,
    this.format,
  });

  final List<double> data;
  final OiKpiFormat? format;
  final OiColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final avg = data.reduce((a, b) => a + b) / data.length;

    String fmt(double v) => format?.format(v) ?? v.toStringAsFixed(0);

    return Row(
      children: [
        _StatChip(label: 'Min', value: fmt(min), colors: colors),
        const SizedBox(width: 12),
        _StatChip(label: 'Avg', value: fmt(avg), colors: colors),
        const SizedBox(width: 12),
        _StatChip(label: 'Max', value: fmt(max), colors: colors),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.colors,
  });

  final String label;
  final String value;
  final OiColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OiLabel.caption(label, color: colors.textMuted),
        OiLabel.small(value, color: colors.text),
      ],
    );
  }
}
