import 'package:flutter/widgets.dart';
import 'package:obers_ui_charts/src/composites/polar/oi_polar_chart.dart';
import 'package:obers_ui_charts/src/composites/polar/oi_polar_data.dart';
import 'package:obers_ui_charts/src/composites/polar/pie/pie_chart_painter.dart';
import 'package:obers_ui_charts/src/foundation/data/chart_data.dart';
import 'package:obers_ui_charts/src/foundation/theme/chart_theme_data.dart';

/// A pie chart widget that renders data as circular slices.
///
/// Extends [OiPolarChart] to share polar coordinate system, theme resolution,
/// and accessibility.
///
/// Set [holeRadius] > 0 for a donut chart appearance. Accepts either
/// [OiPolarData] (preferred) or legacy [OiChartData] via the [data] parameter.
class OiPieChart extends OiPolarChart {
  /// Creates a pie chart from [OiPolarData].
  const OiPieChart({
    required super.data,
    required super.label,
    super.key,
    super.theme,
    super.showLegend,
    super.onSegmentTap,
    this.holeRadius = 0,
  }) : legacyData = null;

  /// Creates a pie chart from legacy [OiChartData] for backward compatibility.
  OiPieChart.fromChartData({
    required OiChartData data,
    required String label,
    Key? key,
    OiChartThemeData? theme,
    bool showLegend = false,
    ValueChanged<int>? onSegmentTap,
    this.holeRadius = 0,
  }) : legacyData = data,
       super(
         data: _convertToPolarData(data),
         label: label,
         key: key,
         theme: theme,
         showLegend: showLegend,
         onSegmentTap: onSegmentTap,
       );

  /// Inner hole radius fraction (0.0 = full pie, 0.5 = 50% hole).
  final double holeRadius;

  /// Legacy data for backward compatibility.
  final OiChartData? legacyData;

  static OiPolarData _convertToPolarData(OiChartData data) {
    if (data.isEmpty) return const OiPolarData(segments: []);
    final series = data.series.first;
    return OiPolarData(
      segments: series.dataPoints
          .map(
            (p) => OiPolarSegment(
              label: p.label ?? 'Point ${p.x.toInt()}',
              value: p.y,
              color: series.color,
            ),
          )
          .toList(),
    );
  }

  @override
  State<OiPieChart> createState() => _OiPieChartState();
}

class _OiPieChartState extends OiPolarChartState<OiPieChart> {
  @override
  CustomPainter createSegmentPainter(OiChartThemeData theme) {
    return OiPieChartPainter(
      data: widget.data,
      theme: theme,
      holeRadius: widget.holeRadius,
      legacyData: widget.legacyData,
    );
  }
}
