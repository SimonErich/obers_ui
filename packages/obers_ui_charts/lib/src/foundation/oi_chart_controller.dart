import 'dart:ui' show Offset;

import 'package:flutter/foundation.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_viewport.dart';
import 'package:obers_ui_charts/src/models/oi_chart_state_models.dart';

/// Identifies a single data element within a chart for selection and
/// hit-testing purposes.
///
/// {@category Foundation}
@immutable
class OiChartDataRef {
  /// Creates an [OiChartDataRef].
  const OiChartDataRef({required this.seriesIndex, required this.dataIndex});

  /// The zero-based index of the series this element belongs to.
  final int seriesIndex;

  /// The zero-based index of the data point within the series.
  final int dataIndex;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiChartDataRef &&
          other.seriesIndex == seriesIndex &&
          other.dataIndex == dataIndex;

  @override
  int get hashCode => Object.hash(seriesIndex, dataIndex);

  @override
  String toString() => 'OiChartDataRef(series: $seriesIndex, data: $dataIndex)';
}

/// The result of a hit test on a chart element.
///
/// {@category Foundation}
@immutable
class OiChartHitResult {
  /// Creates an [OiChartHitResult].
  const OiChartHitResult({
    required this.ref,
    required this.position,
    this.distance = 0,
  });

  /// The data reference of the hit element.
  final OiChartDataRef ref;

  /// The widget-local position of the hit element's anchor point.
  final Offset position;

  /// The distance from the query point to the element in logical pixels.
  final double distance;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiChartHitResult &&
          other.ref == ref &&
          other.position == position &&
          other.distance == distance;

  @override
  int get hashCode => Object.hash(ref, position, distance);

  @override
  String toString() =>
      'OiChartHitResult(ref: $ref, pos: $position, dist: $distance)';
}

/// Abstract controller for chart state management.
///
/// [OiChartController] is a [ChangeNotifier] that manages the current
/// selection, hover state, and data lifecycle of a chart. Concrete chart
/// widgets create specialised subclasses.
///
/// {@category Foundation}
abstract class OiChartController extends ChangeNotifier {
  // ── Selection ──────────────────────────────────────────────────────────

  /// The current selection state.
  OiChartSelectionState get selectionState;

  /// The currently selected data elements.
  Set<OiChartDataRef> get selection;

  /// Updates the selection to the given [refs] and notifies listeners.
  void select(Set<OiChartDataRef> refs);

  /// Clears the current selection and notifies listeners.
  void clearSelection();

  // ── Hover ────────────────────────────────────────────────────────────

  /// The current hover state.
  OiChartHoverState get hoverState;

  /// The currently hovered data element, or null if nothing is hovered.
  OiChartDataRef? get hovered;

  /// Updates the hovered element and notifies listeners.
  void hover(OiChartDataRef? ref);

  // ── Viewport ─────────────────────────────────────────────────────────

  /// The mutable viewport state tracking zoom and pan.
  OiChartViewportState get viewportState;

  /// Resets the viewport zoom and pan to defaults.
  void resetZoom();

  /// Sets the visible domain window.
  void setVisibleDomain({
    double? xMin,
    double? xMax,
    double? yMin,
    double? yMax,
  });

  // ── Legend ────────────────────────────────────────────────────────────

  /// The current legend state.
  OiChartLegendState get legendState;

  /// Toggles the visibility of the series with the given [seriesId].
  void toggleSeries(String seriesId);

  /// Sets exclusive focus on the series with the given [seriesId].
  ///
  /// If the series is already focused, clears the focus.
  void focusSeries(String seriesId);

  // ── Focus ────────────────────────────────────────────────────────────

  /// The current keyboard focus state.
  OiChartFocusState get focusState;

  // ── Data lifecycle ───────────────────────────────────────────────────

  /// Whether the chart data is currently being loaded.
  bool get isLoading;

  /// An optional error message when data loading fails.
  String? get error;
}
