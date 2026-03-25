import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';

/// A behavior that enables keyboard navigation through chart data points.
///
/// - Left/Right arrows navigate between data points within a series.
/// - Up/Down arrows switch between series.
/// - Enter selects the focused point.
/// - Escape clears the selection.
///
/// Announces focused point values via the accessibility bridge.
///
/// {@category Behaviors}
class OiKeyboardExploreBehavior extends OiChartBehavior {
  /// Creates a keyboard explore behavior.
  OiKeyboardExploreBehavior({
    this.onPointFocused,
    this.onPointSelected,
    this.onSelectionCleared,
  });

  /// Called when a new data point is focused via keyboard navigation.
  final void Function(int seriesIndex, int pointIndex)? onPointFocused;

  /// Called when Enter is pressed on a focused data point.
  final void Function(int seriesIndex, int pointIndex)? onPointSelected;

  /// Called when Escape clears the current selection.
  final VoidCallback? onSelectionCleared;

  int _focusedSeriesIndex = 0;
  int _focusedPointIndex = 0;
  int _seriesCount = 0;
  int _pointCount = 0;

  /// The currently focused series index.
  int get focusedSeriesIndex => _focusedSeriesIndex;

  /// The currently focused point index.
  int get focusedPointIndex => _focusedPointIndex;

  /// Configures the data dimensions for navigation bounds.
  void configure({required int seriesCount, required int pointCount}) {
    _seriesCount = seriesCount;
    _pointCount = pointCount;
    _focusedSeriesIndex = _focusedSeriesIndex.clamp(0, _seriesCount - 1);
    _focusedPointIndex = _focusedPointIndex.clamp(0, _pointCount - 1);
  }

  /// Handles a key event for navigation.
  ///
  /// Returns true if the event was consumed.
  bool handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;
    if (_seriesCount == 0 || _pointCount == 0) return false;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowRight:
        _focusedPointIndex = (_focusedPointIndex + 1) % _pointCount;
        onPointFocused?.call(_focusedSeriesIndex, _focusedPointIndex);
        _announce();
        return true;

      case LogicalKeyboardKey.arrowLeft:
        _focusedPointIndex =
            (_focusedPointIndex - 1 + _pointCount) % _pointCount;
        onPointFocused?.call(_focusedSeriesIndex, _focusedPointIndex);
        _announce();
        return true;

      case LogicalKeyboardKey.arrowDown:
        _focusedSeriesIndex = (_focusedSeriesIndex + 1) % _seriesCount;
        onPointFocused?.call(_focusedSeriesIndex, _focusedPointIndex);
        _announce();
        return true;

      case LogicalKeyboardKey.arrowUp:
        _focusedSeriesIndex =
            (_focusedSeriesIndex - 1 + _seriesCount) % _seriesCount;
        onPointFocused?.call(_focusedSeriesIndex, _focusedPointIndex);
        _announce();
        return true;

      case LogicalKeyboardKey.enter:
        onPointSelected?.call(_focusedSeriesIndex, _focusedPointIndex);
        return true;

      case LogicalKeyboardKey.escape:
        onSelectionCleared?.call();
        return true;

      default:
        return false;
    }
  }

  void _announce() {
    if (!isAttached) return;
    context.accessibilityBridge?.announce(
      'Series ${_focusedSeriesIndex + 1}, '
      'point ${_focusedPointIndex + 1}',
    );
  }

  /// Resets the focused indices to the origin.
  void reset() {
    _focusedSeriesIndex = 0;
    _focusedPointIndex = 0;
  }
}
