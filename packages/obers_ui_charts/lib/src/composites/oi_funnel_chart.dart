import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';

/// A stage in the funnel.
///
/// Each stage has a [label], a [value] representing its magnitude,
/// and an optional [color] override.
class OiFunnelStage {
  /// Creates an [OiFunnelStage].
  const OiFunnelStage({required this.label, required this.value, this.color});

  /// The human-readable label for this stage.
  final String label;

  /// The numeric value of this stage.
  final double value;

  /// An optional override color. When null, a color from the theme's
  /// chart palette is used.
  final Color? color;
}

/// A funnel chart showing conversion through stages.
///
/// Stages are rendered as progressively narrowing trapezoids from top to
/// bottom. Each stage can optionally display its value and the percentage
/// relative to the first stage.
///
/// An [onStageTap] callback is invoked when a stage is tapped.
///
/// {@category Composites}
class OiFunnelChart extends StatelessWidget {
  /// Creates an [OiFunnelChart].
  const OiFunnelChart({
    required this.stages,
    required this.label,
    super.key,
    this.showValues = true,
    this.showPercentages = true,
    this.formatValue,
    this.onStageTap,
    this.behaviors = const [],
    this.controller,
  });

  /// The funnel stages from widest (top) to narrowest (bottom).
  final List<OiFunnelStage> stages;

  /// The accessibility label for the chart.
  final String label;

  /// Whether to show the numeric value on each stage.
  final bool showValues;

  /// Whether to show the percentage relative to the first stage.
  final bool showPercentages;

  /// An optional callback to format stage values.
  final String Function(double)? formatValue;

  /// Called when a stage is tapped, with the stage index.
  final ValueChanged<int>? onStageTap;

  /// Composable interaction behaviors.
  final List<OiChartBehavior> behaviors;

  /// External chart controller.
  final OiChartController? controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final chartColors = colors.chart;

    if (stages.isEmpty) {
      return Semantics(
        label: label,
        child: const SizedBox.shrink(key: Key('oi_funnel_chart_empty')),
      );
    }

    final maxValue = stages.first.value;

    return Semantics(
      label: label,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          const stageHeight = 48.0;

          return Column(
            key: const Key('oi_funnel_chart'),
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < stages.length; i++)
                _buildStage(
                  context: context,
                  index: i,
                  stage: stages[i],
                  maxValue: maxValue,
                  availableWidth: availableWidth,
                  stageHeight: stageHeight,
                  color: stages[i].color ?? chartColors[i % chartColors.length],
                  textColor: colors.textOnPrimary,
                  percentColor: colors.textMuted,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStage({
    required BuildContext context,
    required int index,
    required OiFunnelStage stage,
    required double maxValue,
    required double availableWidth,
    required double stageHeight,
    required Color color,
    required Color textColor,
    required Color percentColor,
  }) {
    final ratio = maxValue > 0 ? (stage.value / maxValue).clamp(0.0, 1.0) : 0.0;
    // Minimum width of 20% so the narrowest stage is still visible.
    final stageWidth = availableWidth * (0.2 + 0.8 * ratio);

    final formattedValue =
        formatValue?.call(stage.value) ?? stage.value.toStringAsFixed(0);
    final percentage = maxValue > 0
        ? (stage.value / maxValue * 100).toStringAsFixed(0)
        : '0';

    return GestureDetector(
      onTap: onStageTap != null ? () => onStageTap!(index) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: CustomPaint(
          key: Key('oi_funnel_stage_$index'),
          painter: _OiFunnelStagePainter(color: color),
          child: SizedBox(
            width: stageWidth,
            height: stageHeight,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OiLabel.small(
                      stage.label,
                      color: textColor,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showValues || showPercentages)
                      OiLabel.caption(
                        [
                          if (showValues) formattedValue,
                          if (showPercentages) '$percentage%',
                        ].join(' - '),
                        color: textColor.withValues(alpha: 0.8),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints a single funnel stage as a filled rounded rectangle.
class _OiFunnelStagePainter extends CustomPainter {
  const _OiFunnelStagePainter({required this.color});

  /// The fill color for this stage.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(6),
    );
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_OiFunnelStagePainter oldDelegate) =>
      oldDelegate.color != color;
}
