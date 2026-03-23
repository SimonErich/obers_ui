import 'package:flutter/widgets.dart';
import 'package:obers_ui_charts/src/charts/line/line_chart_painter.dart';
import 'package:obers_ui_charts/src/core/chart_data.dart';
import 'package:obers_ui_charts/src/core/chart_gesture_handler.dart';
import 'package:obers_ui_charts/src/core/chart_hit_result.dart';
import 'package:obers_ui_charts/src/core/chart_padding.dart';
import 'package:obers_ui_charts/src/core/chart_theme.dart';
import 'package:obers_ui_charts/src/core/chart_tooltip_controller.dart';

/// A line chart widget that renders one or more data series as connected lines.
///
/// Uses [OiLineChartPainter] for rendering and [OiChartGestureHandler] for
/// tap interactions.
class OiLineChart extends StatefulWidget {
  const OiLineChart({
    required this.data,
    required this.label,
    super.key,
    this.theme,
    this.onDataPointTap,
    this.padding = const OiChartPadding(),
    this.showPoints = true,
  });

  final OiChartData data;
  final String label;
  final OiChartTheme? theme;
  final ValueChanged<OiChartHitResult>? onDataPointTap;
  final OiChartPadding padding;
  final bool showPoints;

  @override
  State<OiLineChart> createState() => _OiLineChartState();
}

class _OiLineChartState extends State<OiLineChart> {
  late OiChartTooltipController _tooltipController;

  @override
  void initState() {
    super.initState();
    _tooltipController = OiChartTooltipController();
  }

  @override
  void dispose() {
    _tooltipController.dispose();
    super.dispose();
  }

  OiChartTheme get _effectiveTheme => widget.theme ?? OiChartTheme.light();

  void _handleTapUp(TapUpDetails details) {
    final renderBox = context.findRenderObject()! as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final size = renderBox.size;

    final handler = OiChartGestureHandler(
      data: widget.data,
      bounds: widget.data.bounds,
      padding: widget.padding,
    );

    final result = handler.hitTest(localPosition, size);
    if (result != null) {
      _tooltipController.active = result;
      widget.onDataPointTap?.call(result);
    } else {
      _tooltipController.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      child: GestureDetector(
        onTapUp: _handleTapUp,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: OiLineChartPainter(
              data: widget.data,
              theme: _effectiveTheme,
              padding: widget.padding,
              showPoints: widget.showPoints,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}
