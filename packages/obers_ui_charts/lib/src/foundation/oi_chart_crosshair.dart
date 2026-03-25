import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_canvas.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Crosshair snap mode
// ─────────────────────────────────────────────────────────────────────────────

/// How the crosshair position is determined.
///
/// {@category Foundation}
enum OiChartCrosshairSnap {
  /// Crosshair follows the pointer freely within the plot area.
  free,

  /// Crosshair snaps to the nearest data point.
  nearestPoint,
}

// ─────────────────────────────────────────────────────────────────────────────
// Crosshair axis mode
// ─────────────────────────────────────────────────────────────────────────────

/// Which crosshair lines to render.
///
/// {@category Foundation}
enum OiChartCrosshairAxis {
  /// Render only the vertical crosshair line.
  vertical,

  /// Render only the horizontal crosshair line.
  horizontal,

  /// Render both vertical and horizontal crosshair lines.
  both,
}

// ─────────────────────────────────────────────────────────────────────────────
// Crosshair configuration
// ─────────────────────────────────────────────────────────────────────────────

/// Configuration for crosshair visual appearance and behavior.
///
/// {@category Foundation}
@immutable
class OiChartCrosshairConfig {
  /// Creates an [OiChartCrosshairConfig].
  const OiChartCrosshairConfig({
    this.enabled = true,
    this.snap = OiChartCrosshairSnap.free,
    this.axis = OiChartCrosshairAxis.both,
    this.color,
    this.width = 1.0,
    this.dashPattern,
    this.showLabel = false,
    this.hitTestTolerance = 24.0,
  });

  /// Whether the crosshair is enabled.
  final bool enabled;

  /// Snap mode: free-follow or snap-to-point.
  final OiChartCrosshairSnap snap;

  /// Which crosshair lines to show.
  final OiChartCrosshairAxis axis;

  /// Color of the crosshair lines. When null, uses theme default.
  final Color? color;

  /// Width of the crosshair lines in logical pixels.
  final double width;

  /// Optional dash pattern for the crosshair lines.
  final List<double>? dashPattern;

  /// Whether to show axis labels at the crosshair intersection.
  final bool showLabel;

  /// The hit test tolerance for finding the nearest data point in
  /// snap mode.
  final double hitTestTolerance;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiChartCrosshairConfig &&
          other.enabled == enabled &&
          other.snap == snap &&
          other.axis == axis &&
          other.color == color &&
          other.width == width &&
          other.showLabel == showLabel &&
          other.hitTestTolerance == hitTestTolerance;

  @override
  int get hashCode => Object.hash(
    enabled,
    snap,
    axis,
    color,
    width,
    showLabel,
    hitTestTolerance,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Crosshair state
// ─────────────────────────────────────────────────────────────────────────────

/// The current state of the crosshair.
///
/// {@category Foundation}
@immutable
class OiChartCrosshairState {
  /// Creates an [OiChartCrosshairState].
  const OiChartCrosshairState({
    required this.position,
    this.snappedPosition,
    this.normalizedX,
    this.normalizedY,
    this.snappedRef,
  });

  /// The widget-local position of the crosshair.
  final Offset position;

  /// When snap mode is active, the position of the snapped data point.
  final Offset? snappedPosition;

  /// The normalized x position (0–1) within the plot area.
  final double? normalizedX;

  /// The normalized y position (0–1) within the plot area.
  final double? normalizedY;

  /// When snap mode is active, the data reference of the snapped point.
  final OiChartDataRef? snappedRef;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiChartCrosshairState &&
          other.position == position &&
          other.snappedPosition == snappedPosition &&
          other.normalizedX == normalizedX &&
          other.normalizedY == normalizedY &&
          other.snappedRef == snappedRef;

  @override
  int get hashCode => Object.hash(
    position,
    snappedPosition,
    normalizedX,
    normalizedY,
    snappedRef,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Crosshair behavior
// ─────────────────────────────────────────────────────────────────────────────

/// A chart behavior that renders crosshair tracking lines.
///
/// The crosshair follows the pointer/touch position across the chart
/// plot area. It can snap to data points or follow the cursor freely,
/// and synchronizes across charts sharing a syncGroup.
///
/// {@category Foundation}
class OiChartCrosshairBehavior extends OiChartBehavior {
  /// Creates an [OiChartCrosshairBehavior].
  OiChartCrosshairBehavior({
    this.config = const OiChartCrosshairConfig(),
    this.onCrosshairUpdate,
  });

  /// The crosshair configuration.
  final OiChartCrosshairConfig config;

  /// Called whenever the crosshair state changes.
  final ValueChanged<OiChartCrosshairState?>? onCrosshairUpdate;

  OiChartCrosshairState? _state;
  final _repaintNotifier = ChangeNotifier();

  /// The current crosshair state, or null if not visible.
  OiChartCrosshairState? get state => _state;

  /// A listenable that fires when the crosshair needs repainting.
  Listenable get repaintListenable => _repaintNotifier;

  @override
  void attach(OiChartBehaviorContext context) {
    super.attach(context);
    context.syncCoordinator?.addCrosshairListener(_onSyncCrosshair);
  }

  @override
  void detach() {
    context.syncCoordinator?.removeCrosshairListener(_onSyncCrosshair);
    _state = null;
    _repaintNotifier.dispose();
    super.detach();
  }

  void _onSyncCrosshair(double? normalizedX) {
    if (!isAttached || !config.enabled) return;

    if (normalizedX == null) {
      _updateState(null);
      return;
    }

    final viewport = context.viewport;
    final plotBounds = viewport.plotBounds;

    // Convert normalized X to widget-local position.
    final widgetX = plotBounds.left + normalizedX * plotBounds.width;
    final widgetY = plotBounds.center.dy;
    final position = Offset(widgetX, widgetY);

    Offset? snappedPosition;
    OiChartDataRef? snappedRef;

    if (config.snap == OiChartCrosshairSnap.nearestPoint) {
      final hit = context.hitTester.hitTest(
        position,
        tolerance: config.hitTestTolerance,
      );
      if (hit != null) {
        snappedPosition = hit.position;
        snappedRef = hit.ref;
      }
    }

    _updateState(
      OiChartCrosshairState(
        position: snappedPosition ?? position,
        snappedPosition: snappedPosition,
        normalizedX: normalizedX,
        normalizedY: 0.5,
        snappedRef: snappedRef,
      ),
    );
  }

  @override
  void onPointerHover(PointerHoverEvent event) {
    if (!config.enabled) return;
    _handlePointerAt(event.localPosition);
  }

  @override
  void onPointerMove(PointerMoveEvent event) {
    if (!config.enabled) return;
    _handlePointerAt(event.localPosition);
  }

  @override
  void onPointerDown(PointerDownEvent event) {
    if (!config.enabled) return;
    _handlePointerAt(event.localPosition);
  }

  @override
  void onPointerCancel(PointerCancelEvent event) {
    _clearCrosshair();
  }

  void _handlePointerAt(Offset localPosition) {
    final viewport = context.viewport;
    if (!viewport.hitTestPlot(localPosition)) {
      _clearCrosshair();
      return;
    }

    final normalized = viewport.widgetToNormalized(localPosition);
    var effectivePosition = localPosition;
    Offset? snappedPosition;
    OiChartDataRef? snappedRef;

    if (config.snap == OiChartCrosshairSnap.nearestPoint) {
      final hit = context.hitTester.hitTest(
        localPosition,
        tolerance: config.hitTestTolerance,
      );
      if (hit != null) {
        snappedPosition = hit.position;
        snappedRef = hit.ref;
        effectivePosition = hit.position;
      }
    }

    final newState = OiChartCrosshairState(
      position: effectivePosition,
      snappedPosition: snappedPosition,
      normalizedX: normalized.dx,
      normalizedY: normalized.dy,
      snappedRef: snappedRef,
    );

    _updateState(newState);

    // Broadcast to sync group.
    context.syncCoordinator?.syncCrosshair(normalized.dx);
  }

  void _clearCrosshair() {
    _updateState(null);
    if (isAttached) {
      context.syncCoordinator?.syncCrosshair(null);
    }
  }

  void _updateState(OiChartCrosshairState? newState) {
    if (_state == newState) return;
    _state = newState;
    onCrosshairUpdate?.call(newState);
    // Repaint notification for chart canvas integration.
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    _repaintNotifier.notifyListeners();
  }

  /// Creates a [OiChartCrosshairPainter] for rendering the crosshair
  /// on a chart canvas.
  OiChartCrosshairPainter createPainter() {
    return OiChartCrosshairPainter(behavior: this);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Crosshair painter
// ─────────────────────────────────────────────────────────────────────────────

/// A chart layer painter that renders crosshair lines.
///
/// {@category Foundation}
class OiChartCrosshairPainter extends OiChartLayerPainter {
  /// Creates an [OiChartCrosshairPainter].
  OiChartCrosshairPainter({required this.behavior});

  /// The crosshair behavior providing state.
  final OiChartCrosshairBehavior behavior;

  @override
  void paint(OiChartCanvasContext context) {
    final state = behavior.state;
    if (state == null) return;

    final config = behavior.config;
    final plotBounds = context.plotBounds;
    final pos = state.snappedPosition ?? state.position;

    final color = config.color ?? const Color(0x80888888);
    final paint = Paint()
      ..color = color
      ..strokeWidth = config.width
      ..style = PaintingStyle.stroke;

    final canvas = context.canvas;

    if (config.dashPattern != null && config.dashPattern!.isNotEmpty) {
      _paintDashedCrosshair(canvas, plotBounds, pos, paint, config);
    } else {
      _paintSolidCrosshair(canvas, plotBounds, pos, paint, config);
    }

    // Draw a small circle at the intersection point.
    if (state.snappedPosition != null) {
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(state.snappedPosition!, 3, dotPaint);
    }
  }

  void _paintSolidCrosshair(
    ui.Canvas canvas,
    ui.Rect plotBounds,
    Offset pos,
    Paint paint,
    OiChartCrosshairConfig config,
  ) {
    if (config.axis == OiChartCrosshairAxis.vertical ||
        config.axis == OiChartCrosshairAxis.both) {
      canvas.drawLine(
        Offset(pos.dx, plotBounds.top),
        Offset(pos.dx, plotBounds.bottom),
        paint,
      );
    }

    if (config.axis == OiChartCrosshairAxis.horizontal ||
        config.axis == OiChartCrosshairAxis.both) {
      canvas.drawLine(
        Offset(plotBounds.left, pos.dy),
        Offset(plotBounds.right, pos.dy),
        paint,
      );
    }
  }

  void _paintDashedCrosshair(
    ui.Canvas canvas,
    ui.Rect plotBounds,
    Offset pos,
    Paint paint,
    OiChartCrosshairConfig config,
  ) {
    final dashPattern = config.dashPattern!;

    if (config.axis == OiChartCrosshairAxis.vertical ||
        config.axis == OiChartCrosshairAxis.both) {
      _drawDashedLine(
        canvas,
        Offset(pos.dx, plotBounds.top),
        Offset(pos.dx, plotBounds.bottom),
        paint,
        dashPattern,
      );
    }

    if (config.axis == OiChartCrosshairAxis.horizontal ||
        config.axis == OiChartCrosshairAxis.both) {
      _drawDashedLine(
        canvas,
        Offset(plotBounds.left, pos.dy),
        Offset(plotBounds.right, pos.dy),
        paint,
        dashPattern,
      );
    }
  }

  static void _drawDashedLine(
    ui.Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    List<double> dashPattern,
  ) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = Offset(dx, dy).distance;
    if (distance == 0) return;

    final dirX = dx / distance;
    final dirY = dy / distance;

    var drawn = 0.0;
    var dashIndex = 0;
    var drawing = true;

    while (drawn < distance) {
      final dashLen = dashPattern[dashIndex % dashPattern.length];
      final segEnd = (drawn + dashLen).clamp(0.0, distance);

      if (drawing) {
        canvas.drawLine(
          Offset(start.dx + dirX * drawn, start.dy + dirY * drawn),
          Offset(start.dx + dirX * segEnd, start.dy + dirY * segEnd),
          paint,
        );
      }

      drawn = segEnd;
      dashIndex++;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(covariant OiChartCrosshairPainter oldPainter) {
    return behavior.state != oldPainter.behavior.state ||
        behavior.config != oldPainter.behavior.config;
  }
}
