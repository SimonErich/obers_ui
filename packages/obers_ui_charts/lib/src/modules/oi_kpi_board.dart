import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_settings_driver_binding.dart';
import 'package:obers_ui_charts/src/modules/oi_kpi_card.dart';
import 'package:obers_ui_charts/src/modules/oi_kpi_format.dart';
import 'package:obers_ui_charts/src/modules/oi_kpi_metric.dart';

/// A responsive grid of [OiKpiCard] widgets displaying key performance
/// indicators with sparklines, delta indicators, and target progress.
///
/// [OiKpiBoard] lays out [metrics] in a responsive [Wrap]-based grid that
/// adapts the number of columns to the available width. The [columns] parameter
/// sets the preferred maximum column count; cards shrink to fit when space
/// is constrained.
///
/// Each metric is rendered by an [OiKpiCard] whose appearance is controlled by
/// [cardStyle], [showSparklines], [showDeltas], and [showTargets].
///
/// The [label] is required for accessibility — it is used as the semantic
/// label for the board container.
///
/// ```dart
/// OiKpiBoard(
///   label: 'Key Metrics',
///   metrics: [
///     OiKpiMetric(
///       id: 'revenue',
///       title: 'Total Revenue',
///       value: 1_234_567,
///       previousValue: 1_100_000,
///       format: OiKpiFormat.currency(symbol: '\$'),
///       sparklineData: monthlySeries,
///       target: 1_500_000,
///       status: OiKpiStatus.onTrack,
///     ),
///   ],
///   columns: 3,
///   cardStyle: OiKpiCardStyle.standard,
///   showSparklines: true,
///   showDeltas: true,
///   showTargets: true,
/// )
/// ```
///
/// {@category Modules}
class OiKpiBoard extends StatelessWidget {
  /// Creates an [OiKpiBoard].
  const OiKpiBoard({
    required this.label,
    required this.metrics,
    super.key,
    this.columns = 3,
    this.cardStyle = OiKpiCardStyle.standard,
    this.showSparklines = true,
    this.showDeltas = true,
    this.showTargets = true,
    this.spacing = 12.0,
    this.settings,
    this.semanticLabel,
  });

  /// The accessibility label for the board.
  ///
  /// Announced by screen readers as the label for the metric grid container.
  final String label;

  /// The list of metrics to display as cards.
  ///
  /// An empty list renders an empty-state message.
  final List<OiKpiMetric> metrics;

  /// The preferred maximum number of columns in the card grid.
  ///
  /// The actual column count may be lower when available width is insufficient
  /// to accommodate [columns] cards at their minimum width (160 px). Defaults
  /// to 3.
  final int columns;

  /// The visual layout style applied to every card.
  final OiKpiCardStyle cardStyle;

  /// Whether to show inline sparklines on each card (when data is available).
  ///
  /// Has no effect for [OiKpiCardStyle.compact].
  final bool showSparklines;

  /// Whether to show the delta arrow and percentage change on each card.
  final bool showDeltas;

  /// Whether to show the target progress bar on each card (when a target is
  /// provided). Has no effect for [OiKpiCardStyle.compact].
  final bool showTargets;

  /// Gap between cards in the grid, in logical pixels. Defaults to 12.
  final double spacing;

  /// Optional settings persistence binding.
  ///
  /// When provided, the board can persist its configuration (e.g., column
  /// count, card style) across sessions.
  final OiChartSettingsDriverBinding? settings;

  /// An optional override for the semantic label.
  ///
  /// When null, [label] is used.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveSemanticLabel = semanticLabel ?? label;

    if (metrics.isEmpty) {
      return Semantics(
        label: effectiveSemanticLabel,
        child: _EmptyState(colors: colors),
      );
    }

    return Semantics(
      label: effectiveSemanticLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Minimum card width — below this we drop a column.
          const minCardWidth = 160.0;
          final availableWidth = constraints.maxWidth;

          // Compute effective column count from available space.
          final maxPossibleColumns = columns.clamp(1, metrics.length);
          var effectiveColumns = maxPossibleColumns;
          while (effectiveColumns > 1) {
            final cardWidth =
                (availableWidth - spacing * (effectiveColumns - 1)) /
                effectiveColumns;
            if (cardWidth >= minCardWidth) break;
            effectiveColumns--;
          }

          final cardWidth =
              (availableWidth - spacing * (effectiveColumns - 1)) /
              effectiveColumns;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final metric in metrics)
                SizedBox(
                  width: cardWidth,
                  child: OiKpiCard(
                    metric: metric,
                    style: cardStyle,
                    showSparkline: showSparklines,
                    showDelta: showDeltas,
                    showTarget: showTargets,
                    key: Key('oi_kpi_card_${metric.id}'),
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
// _EmptyState
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors});

  final OiColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: OiLabel.small(
          'No metrics to display',
          color: colors.textMuted,
          key: const Key('oi_kpi_board_empty'),
        ),
      ),
    );
  }
}
