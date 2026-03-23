import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/polar/oi_polar_data.dart';
import 'package:obers_ui_charts/src/foundation/chart_accessibility.dart';
import 'package:obers_ui_charts/src/foundation/theme/chart_theme_data.dart';

/// Abstract base widget for all polar/radial chart types.
///
/// Provides shared layout, theme resolution, and accessibility.
/// Concrete charts implement [createSegmentPainter].
abstract class OiPolarChart extends StatefulWidget {
  const OiPolarChart({
    required this.data,
    required this.label,
    super.key,
    this.theme,
    this.showLegend = false,
    this.onSegmentTap,
    this.summaryBuilder,
  });

  final OiPolarData data;
  final String label;
  final OiChartThemeData? theme;
  final bool showLegend;
  final ValueChanged<int>? onSegmentTap;

  /// Optional callback to override the auto-generated accessibility summary.
  final OiChartA11ySummaryBuilder? summaryBuilder;
}

/// Base state for polar chart widgets.
abstract class OiPolarChartState<T extends OiPolarChart> extends State<T> {
  /// Resolves the effective chart theme.
  OiChartThemeData resolveTheme(BuildContext context) {
    if (widget.theme != null) return widget.theme!;
    if (OiTheme.maybeOf(context) != null) {
      return OiChartThemeData.fromContext(context);
    }
    return OiChartThemeData.light();
  }

  /// Creates the segment-specific painter. Subclasses must implement this.
  CustomPainter createSegmentPainter(OiChartThemeData theme);

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return Semantics(label: widget.label, child: const SizedBox.shrink());
    }

    final theme = resolveTheme(context);
    final hasOiTheme = OiTheme.maybeOf(context) != null;

    final summary = OiChartAccessibilitySummary(
      chartType: widget.label,
      seriesLabels: widget.data.segments.map((s) => s.label).toList(),
    );

    final chartContent = Semantics(
      label: OiChartA11y.describeChart(
        widget.label,
        1,
        widget.data.segments.length,
        summary: summary,
        summaryBuilder: widget.summaryBuilder,
      ),
      child: RepaintBoundary(
        child: CustomPaint(
          painter: createSegmentPainter(theme),
          size: Size.infinite,
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
