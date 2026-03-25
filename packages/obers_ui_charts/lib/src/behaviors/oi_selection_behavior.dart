import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';

/// Selection mode for chart data points.
///
/// {@category Behaviors}
enum OiSelectionMode {
  /// Select individual data points.
  point,

  /// Select all points in a series.
  series,

  /// Select all points sharing the same domain (x) value.
  domainGroup,

  /// Drag to select a range of domain values.
  brush,
}

/// A behavior that manages point and series selection state.
///
/// {@category Behaviors}
class OiSelectionBehavior extends OiChartBehavior {
  /// Creates a selection behavior with the given [mode].
  OiSelectionBehavior({
    this.mode = OiSelectionMode.point,
    this.multiSelect = false,
    this.onChanged,
  });

  /// The selection mode.
  final OiSelectionMode mode;

  /// Whether multiple items can be selected simultaneously.
  final bool multiSelect;

  /// Called when the selection changes.
  final void Function(Set<(String seriesId, int index)> selection)? onChanged;

  final Set<(String, int)> _selection = {};

  /// The current set of selected (seriesId, pointIndex) pairs.
  Set<(String, int)> get selection => Set.unmodifiable(_selection);

  /// Selects a data point. In single-select mode, clears previous selection.
  void select(String seriesId, int index) {
    if (!multiSelect) _selection.clear();
    _selection.add((seriesId, index));
    onChanged?.call(selection);
  }

  /// Deselects a specific data point.
  void deselect(String seriesId, int index) {
    _selection.remove((seriesId, index));
    onChanged?.call(selection);
  }

  /// Clears all selections.
  void clearSelection() {
    _selection.clear();
    onChanged?.call(selection);
  }

  /// Whether the given point is selected.
  bool isSelected(String seriesId, int index) =>
      _selection.contains((seriesId, index));
}
