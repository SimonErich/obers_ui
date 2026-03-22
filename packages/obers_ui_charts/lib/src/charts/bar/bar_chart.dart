import 'package:flutter/widgets.dart';
import 'package:obers_ui_charts/src/charts/bar/bar_chart_data_processor.dart';
import 'package:obers_ui_charts/src/charts/bar/bar_chart_painter.dart';
import 'package:obers_ui_charts/src/core/chart_data.dart';
import 'package:obers_ui_charts/src/core/chart_gesture_handler.dart';
import 'package:obers_ui_charts/src/core/chart_painter.dart';
import 'package:obers_ui_charts/src/core/chart_theme.dart';

/// A bar chart widget that renders one or more data series as grouped bars.
///
/// Supports vertical and horizontal orientations.
class OiBarChart extends StatefulWidget {
  const OiBarChart({
    required this.data,
    required this.label,
    super.key,
    this.theme,
    this.orientation = OiBarChartOrientation.vertical,
    this.barSpacing = 8,
    this.onDataPointTap,
    this.padding = const OiChartPadding(),
  });

  final OiChartData data;
  final String label;
  final OiChartTheme? theme;
  final OiBarChartOrientation orientation;
  final double barSpacing;
  final ValueChanged<OiChartHitResult>? onDataPointTap;
  final OiChartPadding padding;

  @override
  State<OiBarChart> createState() => _OiBarChartState();
}

class _OiBarChartState extends State<OiBarChart> {
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
      _tooltipController.show(result);
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
            painter: OiBarChartPainter(
              data: widget.data,
              theme: _effectiveTheme,
              padding: widget.padding,
              barSpacing: widget.barSpacing,
              orientation: widget.orientation,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}
