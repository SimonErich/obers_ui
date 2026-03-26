import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/oi_area_chart/oi_area_chart.dart'
    show OiAreaChart;
import 'package:obers_ui_charts/src/composites/oi_area_chart/oi_area_chart_data.dart';
import 'package:obers_ui_charts/src/composites/oi_area_chart/oi_area_chart_theme.dart';

/// A keyboard-focusable legend for [OiAreaChart].
///
/// Displays coloured area swatches with series names.
///
/// {@category Composites}
class OiAreaChartLegend<T> extends StatelessWidget {
  /// Creates an [OiAreaChartLegend].
  const OiAreaChartLegend({
    required this.series,
    super.key,
    this.chartTheme,
    this.onSeriesTap,
  });

  /// The series to display in the legend.
  final List<OiAreaSeries<T>> series;

  /// Optional chart theme for color resolution.
  final OiAreaChartTheme? chartTheme;

  /// Optional callback when a legend item is tapped or activated via keyboard.
  final ValueChanged<int>? onSeriesTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Wrap(
      key: const Key('oi_area_chart_legend'),
      spacing: 16,
      runSpacing: 4,
      children: [
        for (var i = 0; i < series.length; i++)
          _AreaLegendItem(
            key: Key('oi_area_chart_legend_item_$i'),
            color: OiAreaChartTheme.resolveColor(
              i,
              series[i].color,
              context,
              chartTheme: chartTheme,
            ),
            label: series[i].label,
            fillOpacity: series[i].fillOpacity,
            textColor: colors.textMuted,
            onTap: onSeriesTap != null ? () => onSeriesTap!(i) : null,
          ),
      ],
    );
  }
}

class _AreaLegendItem extends StatelessWidget {
  const _AreaLegendItem({
    required this.color,
    required this.label,
    required this.fillOpacity,
    required this.textColor,
    super.key,
    this.onTap,
  });

  final Color color;
  final String label;
  final double fillOpacity;
  final Color textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (onTap != null &&
            event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space)) {
          onTap!();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(16, 10),
              painter: _AreaSwatch(color: color, fillOpacity: fillOpacity),
            ),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: textColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _AreaSwatch extends CustomPainter {
  _AreaSwatch({required this.color, required this.fillOpacity});

  final Color color;
  final double fillOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw a small filled rectangle to represent the area fill, then a line
    // along the top edge to represent the line stroke.
    canvas
      ..drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()
          ..color = color.withValues(alpha: fillOpacity)
          ..style = PaintingStyle.fill,
      )
      ..drawLine(
        Offset.zero,
        Offset(size.width, 0),
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(_AreaSwatch oldDelegate) =>
      oldDelegate.color != color || oldDelegate.fillOpacity != fillOpacity;
}
