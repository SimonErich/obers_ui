import 'package:flutter/widgets.dart';

import 'package:obers_ui/src/foundation/scales/oi_chart_behavior.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_canvas.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Brush axis mode
// ─────────────────────────────────────────────────────────────────────────────

/// The axis along which the brush operates.
///
/// {@category Foundation}
enum OiChartBrushAxis {
  /// Brush selects along the x-axis only. The selection spans the
  /// full y-axis range.
  x,

  /// Brush selects along the y-axis only. The selection spans the
  /// full x-axis range.
  y,

  /// Brush selects a rectangular region on both axes.
  xy,
}

// ─────────────────────────────────────────────────────────────────────────────
// Brush selection model
// ─────────────────────────────────────────────────────────────────────────────

/// The result of a brush selection, reported as normalized (0–1) domain
/// values within the plot area.
///
/// {@category Foundation}
@immutable
class OiChartBrushSelection {
  /// Creates an [OiChartBrushSelection].
  const OiChartBrushSelection({
    required this.startNormalized,
    required this.endNormalized,
    required this.startWidget,
    required this.endWidget,
    required this.axis,
  });

  /// The start position in normalized (0–1) plot coordinates.
  final Offset startNormalized;

  /// The end position in normalized (0–1) plot coordinates.
  final Offset endNormalized;

  /// The start position in widget-local coordinates.
  final Offset startWidget;

  /// The end position in widget-local coordinates.
  final Offset endWidget;

  /// The axis mode that produced this selection.
  final OiChartBrushAxis axis;

  /// Returns the normalized x-range as a pair [min, max].
  (double, double) get xRange {
    final minX = startNormalized.dx < endNormalized.dx
        ? startNormalized.dx
        : endNormalized.dx;
    final maxX = startNormalized.dx > endNormalized.dx
        ? startNormalized.dx
        : endNormalized.dx;
    return (minX.clamp(0.0, 1.0), maxX.clamp(0.0, 1.0));
  }

  /// Returns the normalized y-range as a pair [min, max].
  (double, double) get yRange {
    final minY = startNormalized.dy < endNormalized.dy
        ? startNormalized.dy
        : endNormalized.dy;
    final maxY = startNormalized.dy > endNormalized.dy
        ? startNormalized.dy
        : endNormalized.dy;
    return (minY.clamp(0.0, 1.0), maxY.clamp(0.0, 1.0));
  }

  /// The brush selection rectangle in widget-local coordinates.
  Rect get widgetRect {
    return Rect.fromPoints(startWidget, endWidget);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiChartBrushSelection &&
          other.startNormalized == startNormalized &&
          other.endNormalized == endNormalized &&
          other.startWidget == startWidget &&
          other.endWidget == endWidget &&
          other.axis == axis;

  @override
  int get hashCode => Object.hash(
        startNormalized,
        endNormalized,
        startWidget,
        endWidget,
        axis,
      );

  @override
  String toString() =>
      'OiChartBrushSelection(x: $xRange, y: $yRange, axis: $axis)';
}

// ─────────────────────────────────────────────────────────────────────────────
// Brush configuration
// ─────────────────────────────────────────────────────────────────────────────

/// Configuration for the brush selection behavior.
///
/// {@category Foundation}
@immutable
class OiChartBrushConfig {
  /// Creates an [OiChartBrushConfig].
  const OiChartBrushConfig({
    this.enabled = true,
    this.axis = OiChartBrushAxis.x,
    this.color,
    this.borderColor,
    this.borderWidth = 1.0,
    this.minDragDistance = 8.0,
  });

  /// Whether the brush is enabled.
  final bool enabled;

  /// The axis along which the brush operates.
  final OiChartBrushAxis axis;

  /// Fill color for the brush selection region. When null, uses a
  /// semi-transparent theme accent.
  final Color? color;

  /// Border color for the brush selection region. When null, uses
  /// the fill color at higher opacity.
  final Color? borderColor;

  /// Border width for the brush selection region.
  final double borderWidth;

  /// Minimum drag distance in logical pixels before a brush gesture
  /// is recognized (to distinguish from taps).
  final double minDragDistance;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiChartBrushConfig &&
          other.enabled == enabled &&
          other.axis == axis &&
          other.color == color &&
          other.borderColor == borderColor &&
          other.borderWidth == borderWidth &&
          other.minDragDistance == minDragDistance;

  @override
  int get hashCode => Object.hash(
        enabled,
        axis,
        color,
        borderColor,
        borderWidth,
        minDragDistance,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Brush behavior
// ─────────────────────────────────────────────────────────────────────────────

/// A chart behavior that enables range selection via click-and-drag.
///
/// The selected brush range is reported as normalized domain values
/// and can be used for zoom, filtering, or external callbacks.
///
/// {@category Foundation}
class OiChartBrushBehavior extends OiChartBehavior {
  /// Creates an [OiChartBrushBehavior].
  OiChartBrushBehavior({
    this.config = const OiChartBrushConfig(),
    this.onBrushStart,
    this.onBrushUpdate,
    this.onBrushEnd,
  });

  /// The brush configuration.
  final OiChartBrushConfig config;

  /// Called when a brush gesture starts.
  final ValueChanged<OiChartBrushSelection>? onBrushStart;

  /// Called when the brush region changes during dragging.
  final ValueChanged<OiChartBrushSelection>? onBrushUpdate;

  /// Called when the brush gesture ends with the final selection.
  final ValueChanged<OiChartBrushSelection>? onBrushEnd;

  Offset? _startWidget;
  Offset? _currentWidget;
  bool _isDragging = false;
  OiChartBrushSelection? _currentSelection;
  final _repaintNotifier = ChangeNotifier();

  /// The current brush selection, or null if no brush is active.
  OiChartBrushSelection? get currentSelection => _currentSelection;

  /// Whether a brush gesture is currently in progress.
  bool get isDragging => _isDragging;

  /// A listenable that fires when the brush overlay needs repainting.
  Listenable get repaintListenable => _repaintNotifier;

  @override
  void detach() {
    _reset();
    _repaintNotifier.dispose();
    super.detach();
  }

  @override
  void onPointerDown(PointerDownEvent event) {
    if (!config.enabled) return;

    final localPos = event.localPosition;
    if (!context.viewport.hitTestPlot(localPos)) return;

    _startWidget = localPos;
    _currentWidget = localPos;
    _isDragging = false;
  }

  @override
  void onPointerMove(PointerMoveEvent event) {
    if (!config.enabled || _startWidget == null) return;

    final localPos = _clampToPlotArea(event.localPosition);
    _currentWidget = localPos;

    final distance = (_startWidget! - localPos).distance;
    if (!_isDragging && distance < config.minDragDistance) return;

    if (!_isDragging) {
      _isDragging = true;
      final selection = _buildSelection();
      _currentSelection = selection;
      onBrushStart?.call(selection);
    } else {
      final selection = _buildSelection();
      _currentSelection = selection;
      onBrushUpdate?.call(selection);
    }

    _notifyRepaint();
  }

  @override
  void onPointerUp(PointerUpEvent event) {
    if (!config.enabled || _startWidget == null) return;

    if (_isDragging) {
      _currentWidget = _clampToPlotArea(event.localPosition);
      final selection = _buildSelection();
      _currentSelection = selection;
      onBrushEnd?.call(selection);
    }

    _reset();
    _notifyRepaint();
  }

  @override
  void onPointerCancel(PointerCancelEvent event) {
    _reset();
    _notifyRepaint();
  }

  Offset _clampToPlotArea(Offset position) {
    final plotBounds = context.viewport.plotBounds;
    return Offset(
      position.dx.clamp(plotBounds.left, plotBounds.right),
      position.dy.clamp(plotBounds.top, plotBounds.bottom),
    );
  }

  OiChartBrushSelection _buildSelection() {
    final viewport = context.viewport;
    final plotBounds = viewport.plotBounds;
    final start = _startWidget!;
    final end = _currentWidget!;

    Offset effectiveStart;
    Offset effectiveEnd;

    switch (config.axis) {
      case OiChartBrushAxis.x:
        effectiveStart = Offset(start.dx, plotBounds.top);
        effectiveEnd = Offset(end.dx, plotBounds.bottom);
      case OiChartBrushAxis.y:
        effectiveStart = Offset(plotBounds.left, start.dy);
        effectiveEnd = Offset(plotBounds.right, end.dy);
      case OiChartBrushAxis.xy:
        effectiveStart = start;
        effectiveEnd = end;
    }

    final startNorm = viewport.widgetToNormalized(effectiveStart);
    final endNorm = viewport.widgetToNormalized(effectiveEnd);

    return OiChartBrushSelection(
      startNormalized: startNorm,
      endNormalized: endNorm,
      startWidget: effectiveStart,
      endWidget: effectiveEnd,
      axis: config.axis,
    );
  }

  void _reset() {
    _startWidget = null;
    _currentWidget = null;
    _isDragging = false;
    _currentSelection = null;
  }

  void _notifyRepaint() {
    // Repaint notification for chart canvas integration.
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    _repaintNotifier.notifyListeners();
  }

  /// Creates an [OiChartBrushPainter] for rendering the brush
  /// selection region on a chart canvas.
  OiChartBrushPainter createPainter() {
    return OiChartBrushPainter(behavior: this);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Brush painter
// ─────────────────────────────────────────────────────────────────────────────

/// A chart layer painter that renders the brush selection region.
///
/// {@category Foundation}
class OiChartBrushPainter extends OiChartLayerPainter {
  /// Creates an [OiChartBrushPainter].
  OiChartBrushPainter({required this.behavior});

  /// The brush behavior providing state.
  final OiChartBrushBehavior behavior;

  @override
  void paint(OiChartCanvasContext context) {
    final selection = behavior.currentSelection;
    if (selection == null || !behavior.isDragging) return;

    final config = behavior.config;
    final rect = selection.widgetRect;

    // Fill.
    final fillColor = config.color ?? const Color(0x203388FF);
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    context.canvas.drawRect(rect, fillPaint);

    // Border.
    final borderColor = config.borderColor ?? const Color(0x803388FF);
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = config.borderWidth
      ..style = PaintingStyle.stroke;
    context.canvas.drawRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant OiChartBrushPainter oldPainter) {
    return behavior.currentSelection != oldPainter.behavior.currentSelection ||
        behavior.isDragging != oldPainter.behavior.isDragging;
  }
}
