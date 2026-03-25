import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';

/// A behavior that broadcasts hover position to synchronized chart siblings
/// via the sync coordinator.
///
/// When a user hovers over a data point in one chart, all charts sharing
/// the same sync group highlight the corresponding position.
///
/// {@category Behaviors}
class OiHoverSyncBehavior extends OiChartBehavior {
  /// Creates a hover sync behavior.
  OiHoverSyncBehavior({this.onHoverPositionChanged});

  /// Called when the hover position changes.
  final void Function(double? domainPosition)? onHoverPositionChanged;

  double? _currentPosition;

  /// The current domain-space hover position, or null if not hovering.
  double? get currentPosition => _currentPosition;

  /// Updates the hover position and broadcasts to sync group.
  void updatePosition(double? domainPosition) {
    if (_currentPosition == domainPosition) return;
    _currentPosition = domainPosition;
    onHoverPositionChanged?.call(domainPosition);
    if (isAttached) {
      context.syncCoordinator?.syncCrosshair(domainPosition);
    }
  }

  /// Clears the hover position.
  void clearHover() => updatePosition(null);
}
