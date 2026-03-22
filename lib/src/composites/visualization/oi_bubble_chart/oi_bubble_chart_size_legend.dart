import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

import 'package:obers_ui/src/composites/visualization/oi_bubble_chart/oi_bubble_chart_data.dart';
import 'package:obers_ui/src/composites/visualization/oi_bubble_chart/oi_bubble_chart_theme.dart';

/// A legend showing the size dimension mapping for [OiBubbleChart].
///
/// Displays two or three reference circles of increasing size with labels
/// indicating the value they represent. All circles are keyboard-focusable.
///
/// {@category Composites}
class OiBubbleChartSizeLegend extends StatelessWidget {
  /// Creates an [OiBubbleChartSizeLegend].
  const OiBubbleChartSizeLegend({
    required this.config,
    super.key,
    this.style,
  });

  /// The size configuration to visualize.
  final OiBubbleSizeConfig config;

  /// Optional style overrides for this legend.
  final OiBubbleSizeLegendStyle? style;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final borderColor = style?.borderColor ?? colors.borderSubtle;
    final labelStyle = style?.labelStyle ??
        TextStyle(color: colors.textMuted, fontSize: 10);

    final radii = [config.minRadius, (config.minRadius + config.maxRadius) / 2, config.maxRadius];
    final labels = ['Small', 'Medium', 'Large'];

    return Semantics(
      label: config.sizeLabel != null
          ? 'Size legend: ${config.sizeLabel}'
          : 'Size legend',
      child: Row(
        key: const Key('oi_bubble_chart_size_legend'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (config.sizeLabel != null)
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 2),
              child: Text(
                config.sizeLabel!,
                style: labelStyle.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          for (var i = 0; i < radii.length; i++)
            Focus(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Semantics(
                  label: '${labels[i]} size bubble',
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        key: Key('oi_bubble_chart_size_legend_circle_$i'),
                        width: radii[i] * 2,
                        height: radii[i] * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(labels[i], style: labelStyle),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
