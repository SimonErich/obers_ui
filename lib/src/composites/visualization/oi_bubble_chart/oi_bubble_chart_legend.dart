import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

import 'package:obers_ui/src/composites/visualization/oi_bubble_chart/oi_bubble_chart_data.dart';
import 'package:obers_ui/src/composites/visualization/oi_bubble_chart/oi_bubble_chart_theme.dart';

/// A keyboard-operable legend for [OiBubbleChart] series.
///
/// Each series is shown as a colored circle with its name. Items are
/// focusable and activatable via keyboard for accessibility.
///
/// {@category Composites}
class OiBubbleChartLegend extends StatelessWidget {
  /// Creates an [OiBubbleChartLegend].
  const OiBubbleChartLegend({
    required this.series,
    super.key,
    this.chartTheme,
    this.onSeriesTap,
  });

  /// The series to display in the legend.
  final List<OiBubbleSeries> series;

  /// The chart theme for resolving series colors.
  final OiBubbleChartTheme? chartTheme;

  /// Called when a legend item is tapped or activated via keyboard.
  final ValueChanged<int>? onSeriesTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      label: 'Chart legend',
      child: Wrap(
        key: const Key('oi_bubble_chart_legend'),
        spacing: 16,
        runSpacing: 4,
        children: [
          for (var i = 0; i < series.length; i++)
            Focus(
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent &&
                    (event.logicalKey == LogicalKeyboardKey.enter ||
                        event.logicalKey == LogicalKeyboardKey.space)) {
                  onSeriesTap?.call(i);
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: Builder(
                builder: (focusContext) {
                  final hasFocus = Focus.of(focusContext).hasFocus;
                  final color = OiBubbleChartTheme.resolveColor(
                    i,
                    series[i].style,
                    null,
                    context,
                    chartTheme: chartTheme,
                  );

                  return GestureDetector(
                    onTap: onSeriesTap != null ? () => onSeriesTap!(i) : null,
                    child: Semantics(
                      button: true,
                      label: series[i].name,
                      child: Container(
                        key: Key('oi_bubble_chart_legend_item_$i'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: hasFocus
                            ? BoxDecoration(
                                border: Border.all(
                                  color: colors.borderFocus,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              )
                            : null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              series[i].name,
                              style: TextStyle(
                                color: colors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
