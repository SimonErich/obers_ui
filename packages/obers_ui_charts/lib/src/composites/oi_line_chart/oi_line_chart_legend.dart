import 'package:flutter/services.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui_charts/src/composites/oi_line_chart/oi_line_chart.dart'
    show OiLineChart;
import 'package:obers_ui_charts/src/composites/oi_line_chart/oi_line_chart_data.dart';
import 'package:obers_ui_charts/src/composites/oi_line_chart/oi_line_chart_theme.dart';

/// A keyboard-focusable legend for [OiLineChart].
///
/// Displays coloured line segments with series names.
///
/// {@category Composites}
class OiLineChartLegend extends StatelessWidget {
  /// Creates an [OiLineChartLegend].
  const OiLineChartLegend({
    required this.series,
    super.key,
    this.chartTheme,
    this.onSeriesTap,
  });

  /// The series to display in the legend.
  final List<OiLineSeries> series;

  /// Optional chart theme for color resolution.
  final OiLineChartTheme? chartTheme;

  /// Optional callback when a legend item is tapped or activated via keyboard.
  final ValueChanged<int>? onSeriesTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Wrap(
      key: const Key('oi_line_chart_legend'),
      spacing: 16,
      runSpacing: 4,
      children: [
        for (var i = 0; i < series.length; i++)
          _LegendItem(
            key: Key('oi_line_chart_legend_item_$i'),
            color: OiLineChartTheme.resolveColor(
              i,
              series[i].color,
              context,
              chartTheme: chartTheme,
            ),
            label: series[i].label,
            dashed: series[i].dashed,
            textColor: colors.textMuted,
            onTap: onSeriesTap != null ? () => onSeriesTap!(i) : null,
          ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.dashed,
    required this.textColor,
    super.key,
    this.onTap,
  });

  final Color color;
  final String label;
  final bool dashed;
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
              size: const Size(16, 2),
              painter: _LineSwatch(color: color, dashed: dashed),
            ),
            const SizedBox(width: 4),
            OiLabel.caption(label, color: textColor),
          ],
        ),
      ),
    );
  }
}

class _LineSwatch extends CustomPainter {
  _LineSwatch({required this.color, required this.dashed});

  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    if (dashed) {
      const dashW = 4.0;
      const gapW = 3.0;
      var x = 0.0;
      while (x < size.width) {
        final end = (x + dashW).clamp(0.0, size.width);
        canvas.drawLine(
          Offset(x, size.height / 2),
          Offset(end, size.height / 2),
          paint,
        );
        x += dashW + gapW;
      }
    } else {
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_LineSwatch oldDelegate) =>
      oldDelegate.color != color || oldDelegate.dashed != dashed;
}
