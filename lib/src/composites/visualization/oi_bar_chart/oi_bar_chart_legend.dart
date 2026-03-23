import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiBarChart;
import 'package:obers_ui/src/composites/visualization/oi_bar_chart/oi_bar_chart.dart' show OiBarChart;
import 'package:obers_ui/src/composites/visualization/oi_bar_chart/oi_bar_chart_data.dart';
import 'package:obers_ui/src/composites/visualization/oi_bar_chart/oi_bar_chart_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A keyboard-focusable legend for [OiBarChart].
///
/// {@category Composites}
class OiBarChartLegend extends StatelessWidget {
  /// Creates an [OiBarChartLegend].
  const OiBarChartLegend({
    required this.series,
    super.key,
    this.chartTheme,
    this.onSeriesTap,
  });

  /// The series to display in the legend.
  final List<OiBarSeries> series;

  /// Optional chart theme for color resolution.
  final OiBarChartTheme? chartTheme;

  /// Optional callback when a legend item is tapped or activated via keyboard.
  final ValueChanged<int>? onSeriesTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Wrap(
      key: const Key('oi_bar_chart_legend'),
      spacing: 16,
      runSpacing: 4,
      children: [
        for (var i = 0; i < series.length; i++)
          Focus(
            key: Key('oi_bar_chart_legend_item_$i'),
            onKeyEvent: (node, event) {
              if (onSeriesTap != null &&
                  event is KeyDownEvent &&
                  (event.logicalKey == LogicalKeyboardKey.enter ||
                      event.logicalKey == LogicalKeyboardKey.space)) {
                onSeriesTap!(i);
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: GestureDetector(
              onTap: onSeriesTap != null ? () => onSeriesTap!(i) : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: OiBarChartTheme.resolveColor(
                        i,
                        series[i].color,
                        context,
                        chartTheme: chartTheme,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    series[i].label,
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
