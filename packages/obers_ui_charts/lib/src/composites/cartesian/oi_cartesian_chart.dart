import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/components/annotations/chart_annotation.dart';
import 'package:obers_ui_charts/src/components/axes/chart_axis_config.dart';
import 'package:obers_ui_charts/src/components/threshold/chart_threshold.dart';
import 'package:obers_ui_charts/src/components/tooltip/chart_tooltip.dart';
import 'package:obers_ui_charts/src/foundation/chart_accessibility.dart';
import 'package:obers_ui_charts/src/foundation/data/chart_data.dart';
import 'package:obers_ui_charts/src/foundation/data/chart_padding.dart';
import 'package:obers_ui_charts/src/foundation/theme/chart_theme_data.dart';
import 'package:obers_ui_charts/src/primitives/hit_testing/chart_gesture_handler.dart';
import 'package:obers_ui_charts/src/primitives/hit_testing/chart_hit_result.dart';

/// Abstract base widget for all Cartesian (x/y coordinate) chart types.
///
/// Provides shared layout, theme resolution, gesture handling, and
/// accessibility. Concrete charts implement [createSeriesPainter].
abstract class OiCartesianChart extends StatefulWidget {
  const OiCartesianChart({
    required this.data,
    required this.label,
    super.key,
    this.theme,
    this.padding = const OiChartPadding(),
    this.xAxis,
    this.yAxis,
    this.showGrid = true,
    this.showLegend = false,
    this.annotations = const [],
    this.thresholds = const [],
    this.onDataPointTap,
  });

  final OiChartData data;
  final String label;
  final OiChartThemeData? theme;
  final OiChartPadding padding;
  final OiChartAxisConfig? xAxis;
  final OiChartAxisConfig? yAxis;
  final bool showGrid;
  final bool showLegend;
  final List<OiChartAnnotation> annotations;
  final List<OiChartThresholdBand> thresholds;
  final ValueChanged<OiChartHitResult>? onDataPointTap;
}

/// Base state for Cartesian chart widgets.
///
/// Handles theme resolution, tooltip lifecycle, and gesture detection.
/// Subclasses only need to implement [createSeriesPainter].
abstract class OiCartesianChartState<T extends OiCartesianChart>
    extends State<T> {
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

  /// Resolves the effective chart theme.
  OiChartThemeData resolveTheme(BuildContext context) {
    if (widget.theme != null) return widget.theme!;
    if (OiTheme.maybeOf(context) != null) {
      return OiChartThemeData.fromContext(context);
    }
    return OiChartThemeData.light();
  }

  /// Creates the series-specific painter. Subclasses must implement this.
  CustomPainter createSeriesPainter(
    OiChartThemeData theme,
    OiChartPadding padding,
  );

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
    if (widget.data.isEmpty) {
      return Semantics(label: widget.label, child: const SizedBox.shrink());
    }

    final theme = resolveTheme(context);
    final hasOiTheme = OiTheme.maybeOf(context) != null;

    final chartContent = Semantics(
      label: OiChartA11y.describeChart(
        widget.label,
        widget.data.series.length,
        widget.data.totalPoints,
      ),
      child: GestureDetector(
        onTapUp: _handleTapUp,
        child: RepaintBoundary(
          child: CustomPaint(
            painter: createSeriesPainter(theme, widget.padding),
            size: Size.infinite,
          ),
        ),
      ),
    );

    if (hasOiTheme) {
      return OiSurface(
        color: theme.colors.backgroundColor,
        child: chartContent,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colors.backgroundColor),
      child: chartContent,
    );
  }
}
