import 'package:flutter/widgets.dart';

import 'package:obers_ui_charts/src/composites/oi_pie_chart.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';

/// A donut chart — a [OiPieChart] variant with a hollow center.
///
/// Convenience widget that delegates to [OiPieChart] with `donut: true`.
/// Provides a typed API for the inner radius and center content.
///
/// {@category Composites}
class OiDonutChart extends StatelessWidget {
  /// Creates an [OiDonutChart].
  const OiDonutChart({
    required this.label,
    required this.segments,
    super.key,
    this.innerRadiusFraction = 0.4,
    this.centerLabel,
    this.showLabels = true,
    this.showPercentages = true,
    this.showValues = false,
    this.showLegend = true,
    this.onSegmentTap,
    this.compact,
    this.semanticLabel,
    this.behaviors = const [],
    this.controller,
  });

  /// Accessibility label for the chart.
  final String label;

  /// The data segments to render.
  final List<OiPieSegment> segments;

  /// The inner radius as a fraction of the outer radius (0.0–1.0).
  ///
  /// Controls the thickness of the donut ring. Higher values create
  /// a thinner ring. Defaults to 0.4.
  final double innerRadiusFraction;

  /// Optional text displayed in the hollow center.
  ///
  /// Commonly used for a summary value or label.
  final String? centerLabel;

  /// Whether to show segment labels.
  final bool showLabels;

  /// Whether to show percentage values on segments.
  final bool showPercentages;

  /// Whether to show raw values on segments.
  final bool showValues;

  /// Whether to show the legend.
  final bool showLegend;

  /// Called when a segment is tapped.
  final void Function(int index)? onSegmentTap;

  /// Whether to use compact layout mode.
  final bool? compact;

  /// Override for the semantic label.
  final String? semanticLabel;

  /// Composable interaction behaviors.
  final List<OiChartBehavior> behaviors;

  /// External chart controller.
  final OiChartController? controller;

  @override
  Widget build(BuildContext context) {
    return OiPieChart(
      label: semanticLabel ?? label,
      segments: segments,
      donut: true,
      donutWidth: innerRadiusFraction,
      centerLabel: centerLabel,
      showLabels: showLabels,
      showPercentages: showPercentages,
      showValues: showValues,
      showLegend: showLegend,
      onSegmentTap: onSegmentTap,
      compact: compact,
      behaviors: behaviors,
      controller: controller,
    );
  }
}
