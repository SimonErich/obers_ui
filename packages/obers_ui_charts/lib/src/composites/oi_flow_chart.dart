import 'package:flutter/widgets.dart';

import 'package:obers_ui_charts/src/components/oi_chart_empty_state.dart';
import 'package:obers_ui_charts/src/components/oi_chart_error_state.dart';
import 'package:obers_ui_charts/src/components/oi_chart_loading_state.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_accessibility_config.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_viewport.dart';
import 'package:obers_ui_charts/src/models/oi_flow_series.dart';

/// Base composite widget for flow/network chart types (Sankey, alluvial).
///
/// Handles node/link layout, flow width scaling, and path routing.
///
/// {@category Composites}
class OiFlowChart<TNode, TLink> extends StatefulWidget {
  /// Creates a flow chart.
  const OiFlowChart({
    super.key,
    required this.label,
    required this.series,
    this.seriesBuilder,
    this.behaviors = const [],
    this.controller,
    this.accessibility,
    this.emptyState,
    this.loadingState,
    this.errorState,
    this.semanticLabel,
  });

  /// Accessibility label for the chart.
  final String label;

  /// The flow data series with nodes and links.
  final OiFlowSeries<TNode, TLink> series;

  /// Builder that renders the flow layout.
  final Widget Function(
    BuildContext context,
    OiChartViewport viewport,
    OiFlowSeries<TNode, TLink> series,
  )?
  seriesBuilder;

  /// Composable interaction behaviors.
  final List<OiChartBehavior> behaviors;

  /// External chart controller.
  final OiChartController? controller;

  /// Accessibility configuration.
  final OiChartAccessibilityConfig? accessibility;

  /// Custom empty state widget.
  final Widget? emptyState;

  /// Custom loading state widget.
  final Widget? loadingState;

  /// Custom error state widget.
  final Widget? errorState;

  /// Override for the semantic label.
  final String? semanticLabel;

  @override
  State<OiFlowChart<TNode, TLink>> createState() =>
      _OiFlowChartState<TNode, TLink>();
}

class _OiFlowChartState<TNode, TLink> extends State<OiFlowChart<TNode, TLink>> {
  bool get _hasData =>
      widget.series.data != null && widget.series.data!.isNotEmpty;

  String get _effectiveLabel {
    if (widget.semanticLabel != null) return widget.semanticLabel!;
    if (widget.label.isNotEmpty) return widget.label;
    return 'Flow chart';
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.controller?.isLoading ?? false;
    final error = widget.controller?.error;

    if (isLoading) {
      return widget.loadingState ?? const OiChartLoadingState();
    }
    if (error != null) {
      return widget.errorState ?? OiChartErrorState(message: error);
    }
    if (!_hasData) {
      return widget.emptyState ?? const OiChartEmptyState();
    }

    return Semantics(
      label: _effectiveLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : 300.0;
          final viewport = OiChartViewport(
            size: Size(w, h),
            devicePixelRatio:
                MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0,
          );

          final content =
              widget.seriesBuilder?.call(context, viewport, widget.series) ??
              SizedBox(width: w, height: h);

          return SizedBox(width: w, height: h, child: content);
        },
      ),
    );
  }
}
