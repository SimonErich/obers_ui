import 'dart:ui';

import 'package:obers_ui_charts/src/components/axes/chart_axis_config.dart';
import 'package:obers_ui_charts/src/foundation/data/chart_data.dart';
import 'package:obers_ui_charts/src/foundation/theme/chart_theme_data.dart';
import 'package:obers_ui_charts/src/primitives/painters/chart_painter.dart';

/// Abstract base painter for Cartesian chart types.
///
/// Implements the template method pattern: [paint] calls grid → series → axes.
/// Subclasses implement [paintSeries] for their specific visualization.
abstract class OiCartesianPainter extends OiChartPainter {
  OiCartesianPainter({
    required super.data,
    required super.theme,
    super.padding,
    this.showGrid = true,
    this.xAxis,
    this.yAxis,
  });

  final bool showGrid;
  final OiChartAxisConfig? xAxis;
  final OiChartAxisConfig? yAxis;

  /// Paints the series-specific content. Implemented by subclasses.
  void paintSeries(Canvas canvas, Size size);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final bounds = data.bounds;

    canvas
      ..save()
      ..clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (showGrid) {
      paintGrid(canvas, size, bounds, theme);
    }
    paintSeries(canvas, size);
    paintAxes(canvas, size, bounds, theme);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant OiCartesianPainter oldDelegate) =>
      super.shouldRepaint(oldDelegate) ||
      showGrid != oldDelegate.showGrid;
}
