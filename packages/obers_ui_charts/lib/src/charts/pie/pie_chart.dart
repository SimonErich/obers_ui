import 'package:flutter/widgets.dart';
import 'package:obers_ui_charts/src/charts/pie/pie_chart_painter.dart';
import 'package:obers_ui_charts/src/core/chart_data.dart';
import 'package:obers_ui_charts/src/core/chart_gesture_handler.dart';
import 'package:obers_ui_charts/src/core/chart_hit_result.dart';
import 'package:obers_ui_charts/src/core/chart_theme.dart';
import 'package:obers_ui_charts/src/core/chart_tooltip_controller.dart';

/// A pie chart widget that renders data as circular slices.
///
/// Set [holeRadius] > 0 for a donut chart appearance. Uses the first series
/// in [data] for slice computation.
class OiPieChart extends StatefulWidget {
  const OiPieChart({
    required this.data,
    required this.label,
    super.key,
    this.theme,
    this.holeRadius = 0,
    this.onDataPointTap,
  });

  final OiChartData data;
  final String label;
  final OiChartTheme? theme;

  /// Inner hole radius fraction (0.0 = full pie, 0.5 = 50% hole).
  final double holeRadius;

  final ValueChanged<OiChartHitResult>? onDataPointTap;

  @override
  State<OiPieChart> createState() => _OiPieChartState();
}

class _OiPieChartState extends State<OiPieChart> {
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
            painter: OiPieChartPainter(
              data: widget.data,
              theme: _effectiveTheme,
              holeRadius: widget.holeRadius,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}
