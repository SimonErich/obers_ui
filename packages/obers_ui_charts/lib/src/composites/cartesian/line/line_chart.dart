import 'package:flutter/widgets.dart';
import 'package:obers_ui_charts/src/composites/cartesian/line/line_chart_painter.dart';
import 'package:obers_ui_charts/src/composites/cartesian/oi_cartesian_chart.dart';
import 'package:obers_ui_charts/src/foundation/data/chart_padding.dart';
import 'package:obers_ui_charts/src/foundation/theme/chart_theme_data.dart';

/// A line chart widget that renders one or more data series as connected lines.
///
/// Extends [OiCartesianChart] to share Cartesian coordinate system, grid/axis
/// painting, theme resolution, and gesture handling.
class OiLineChart extends OiCartesianChart {
  const OiLineChart({
    required super.data,
    required super.label,
    super.key,
    super.theme,
    super.onDataPointTap,
    super.padding,
    super.xAxis,
    super.yAxis,
    super.showGrid,
    super.showLegend,
    super.annotations,
    super.thresholds,
    this.showPoints = true,
  });

  final bool showPoints;

  @override
  State<OiLineChart> createState() => _OiLineChartState();
}

class _OiLineChartState extends OiCartesianChartState<OiLineChart> {
  @override
  CustomPainter createSeriesPainter(
    OiChartThemeData theme,
    OiChartPadding padding,
  ) {
    return OiLineChartPainter(
      data: widget.data,
      theme: theme,
      padding: padding,
      showPoints: widget.showPoints,
      showGrid: widget.showGrid,
      xAxis: widget.xAxis,
      yAxis: widget.yAxis,
    );
  }
}
