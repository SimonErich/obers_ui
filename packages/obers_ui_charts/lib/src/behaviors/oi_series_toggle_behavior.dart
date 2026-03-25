import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';

/// A behavior that manages series visibility, typically driven by legend
/// interactions.
///
/// When a series is toggled off, chart renderers skip it. When toggled back
/// on, the series is re-rendered with an optional animation.
///
/// {@category Behaviors}
class OiSeriesToggleBehavior extends OiChartBehavior {
  /// Creates a series toggle behavior.
  OiSeriesToggleBehavior({this.onVisibilityChanged});

  /// Called when series visibility changes.
  final void Function(Map<String, bool> visibility)? onVisibilityChanged;

  final Map<String, bool> _visibility = {};

  /// Returns the current visibility map (seriesId → isVisible).
  Map<String, bool> get visibility => Map.unmodifiable(_visibility);

  /// Returns whether the given series is visible (defaults to true).
  bool isVisible(String seriesId) => _visibility[seriesId] ?? true;

  /// Toggles the visibility of a series.
  void toggle(String seriesId) {
    _visibility[seriesId] = !isVisible(seriesId);
    onVisibilityChanged?.call(visibility);
  }

  /// Explicitly sets the visibility of a series.
  void setVisible(String seriesId, {required bool visible}) {
    _visibility[seriesId] = visible;
    onVisibilityChanged?.call(visibility);
  }

  /// Shows all series.
  void showAll() {
    for (final key in _visibility.keys.toList()) {
      _visibility[key] = true;
    }
    onVisibilityChanged?.call(visibility);
  }
}
