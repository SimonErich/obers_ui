import 'package:flutter/widgets.dart';
import 'package:obers_ui_charts/src/composites/cartesian/bar/bar_chart_orientation.dart';
import 'package:obers_ui_charts/src/composites/cartesian/bar/bar_chart_painter.dart';
import 'package:obers_ui_charts/src/composites/cartesian/oi_cartesian_chart.dart';
import 'package:obers_ui_charts/src/foundation/data/chart_padding.dart';
import 'package:obers_ui_charts/src/foundation/theme/chart_theme_data.dart';

/// A bar chart widget that renders one or more data series as grouped bars.
///
/// Extends [OiCartesianChart] to share Cartesian coordinate system, grid/axis
/// painting, theme resolution, and gesture handling.
/// Supports vertical and horizontal orientations.
class OiBarChart extends OiCartesianChart {
  const OiBarChart({
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
    this.orientation = OiBarChartOrientation.vertical,
    this.barSpacing = 8,
  });

  final OiBarChartOrientation orientation;
  final double barSpacing;

  @override
  State<OiBarChart> createState() => _OiBarChartState();
}

class _OiBarChartState extends OiCartesianChartState<OiBarChart> {
  @override
  CustomPainter createSeriesPainter(
    OiChartThemeData theme,
    OiChartPadding padding,
  ) {
    return OiBarChartPainter(
      data: widget.data,
      theme: theme,
      padding: padding,
      barSpacing: widget.barSpacing,
      orientation: widget.orientation,
      showGrid: widget.showGrid,
      xAxis: widget.xAxis,
      yAxis: widget.yAxis,
    );
  }
}
