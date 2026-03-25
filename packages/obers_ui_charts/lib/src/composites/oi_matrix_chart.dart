import 'package:flutter/widgets.dart';

import 'package:obers_ui_charts/src/components/oi_chart_empty_state.dart';
import 'package:obers_ui_charts/src/components/oi_chart_error_state.dart';
import 'package:obers_ui_charts/src/components/oi_chart_loading_state.dart';
import 'package:obers_ui_charts/src/composites/oi_chart_axis.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_accessibility_config.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_viewport.dart';
import 'package:obers_ui_charts/src/models/oi_matrix_series.dart';

/// Base composite widget for cell-grid chart types (heatmap, correlation).
///
/// Orchestrates: cell grid layout, color scale mapping, axis rendering,
/// and cell-level hit testing.
///
/// {@category Composites}
class OiMatrixChart<T> extends StatefulWidget {
  /// Creates a matrix chart.
  const OiMatrixChart({
    super.key,
    required this.label,
    required this.series,
    this.xAxis,
    this.yAxis,
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

  /// The data series to render.
  final List<OiMatrixSeries<T>> series;

  /// X-axis configuration.
  final OiChartAxis<dynamic>? xAxis;

  /// Y-axis configuration.
  final OiChartAxis<dynamic>? yAxis;

  /// Builder that renders matrix series data.
  final Widget Function(
    BuildContext context,
    OiChartViewport viewport,
    List<OiMatrixSeries<T>> visibleSeries,
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
  State<OiMatrixChart<T>> createState() => _OiMatrixChartState<T>();
}

class _OiMatrixChartState<T> extends State<OiMatrixChart<T>> {
  List<OiMatrixSeries<T>> get _visibleSeries =>
      widget.series.where((s) => s.visible).toList();

  bool get _hasData =>
      _visibleSeries.any((s) => s.data != null && s.data!.isNotEmpty);

  String get _effectiveLabel {
    if (widget.semanticLabel != null) return widget.semanticLabel!;
    if (widget.label.isNotEmpty) return widget.label;
    return 'Matrix chart';
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
              widget.seriesBuilder?.call(context, viewport, _visibleSeries) ??
              SizedBox(width: w, height: h);

          return SizedBox(width: w, height: h, child: content);
        },
      ),
    );
  }
}
