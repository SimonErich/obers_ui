import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/flow/oi_flow_data.dart';
import 'package:obers_ui_charts/src/foundation/theme/chart_theme_data.dart';

/// Abstract base widget for flow chart types (e.g. Sankey, funnel).
abstract class OiFlowChart extends StatefulWidget {
  const OiFlowChart({
    required this.data,
    required this.label,
    super.key,
    this.theme,
  });

  final OiFlowData data;
  final String label;
  final OiChartThemeData? theme;
}

/// Base state for flow chart widgets.
abstract class OiFlowChartState<T extends OiFlowChart> extends State<T> {
  /// Resolves the effective chart theme.
  OiChartThemeData resolveTheme(BuildContext context) {
    if (widget.theme != null) return widget.theme!;
    if (OiTheme.maybeOf(context) != null) {
      return OiChartThemeData.fromContext(context);
    }
    return OiChartThemeData.light();
  }

  /// Creates the flow-specific painter. Subclasses must implement this.
  CustomPainter createFlowPainter(OiChartThemeData theme);

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return Semantics(label: widget.label, child: const SizedBox.shrink());
    }

    final theme = resolveTheme(context);
    final hasOiTheme = OiTheme.maybeOf(context) != null;

    final chartContent = Semantics(
      label: widget.label,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: createFlowPainter(theme),
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
