import 'package:flutter/widgets.dart';

import 'package:obers_ui_charts/src/components/oi_chart_empty_state.dart';
import 'package:obers_ui_charts/src/components/oi_chart_error_state.dart';
import 'package:obers_ui_charts/src/components/oi_chart_loading_state.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_accessibility_config.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_viewport.dart';
import 'package:obers_ui_charts/src/models/oi_polar_series.dart';

/// Base composite widget for radial/polar chart types (pie, donut, radar).
///
/// Orchestrates arc layout, radial label placement, center content,
/// angular hit testing, and behavior dispatch.
///
/// {@category Composites}
class OiPolarChart<T> extends StatefulWidget {
  /// Creates a polar chart.
  const OiPolarChart({
    super.key,
    required this.label,
    required this.series,
    this.seriesBuilder,
    this.centerContent,
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
  final List<OiPolarSeries<T>> series;

  /// Builder that renders polar series data.
  final Widget Function(
    BuildContext context,
    OiChartViewport viewport,
    List<OiPolarSeries<T>> visibleSeries,
  )?
  seriesBuilder;

  /// Optional content to display in the center (e.g., donut label).
  final Widget? centerContent;

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
  State<OiPolarChart<T>> createState() => _OiPolarChartState<T>();
}

class _OiPolarChartState<T> extends State<OiPolarChart<T>> {
  List<OiPolarSeries<T>> get _visibleSeries =>
      widget.series.where((s) => s.visible).toList();

  bool get _hasData =>
      _visibleSeries.any((s) => s.data != null && s.data!.isNotEmpty);

  String get _effectiveLabel {
    if (widget.semanticLabel != null) return widget.semanticLabel!;
    if (widget.label.isNotEmpty) return widget.label;
    final count = widget.series.length;
    return 'Polar chart with $count ${count == 1 ? 'series' : 'series'}';
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
          final h = constraints.maxHeight.isFinite ? constraints.maxHeight : w;
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
