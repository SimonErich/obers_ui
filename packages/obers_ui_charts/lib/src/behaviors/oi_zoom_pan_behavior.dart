import 'dart:math' as math;
import 'dart:ui' show Offset, Rect;

import 'package:flutter/gestures.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';

/// Configuration for zoom/pan constraints.
///
/// {@category Behaviors}
class OiZoomPanConfig {
  /// Creates an [OiZoomPanConfig].
  const OiZoomPanConfig({
    this.minZoom = 0.5,
    this.maxZoom = 20.0,
    this.wheelZoomFactor = 0.1,
    this.enableWheelZoom = true,
    this.enablePinchZoom = true,
    this.enableDragPan = true,
  });

  /// Minimum allowed zoom level.
  final double minZoom;

  /// Maximum allowed zoom level.
  final double maxZoom;

  /// Zoom factor per scroll wheel notch.
  final double wheelZoomFactor;

  /// Whether scroll wheel zoom is enabled.
  final bool enableWheelZoom;

  /// Whether pinch-to-zoom is enabled.
  final bool enablePinchZoom;

  /// Whether drag-to-pan is enabled.
  final bool enableDragPan;
}

/// A behavior that adds zoom and pan interaction to charts.
///
/// Supports three input modes:
/// - **Scroll wheel zoom**: Zooms centered on pointer position
/// - **Pinch zoom**: Two-finger pinch gesture on touch devices
/// - **Drag pan**: Click/touch and drag to pan the viewport
///
/// {@category Behaviors}
class OiZoomPanBehavior extends OiChartBehavior {
  /// Creates an [OiZoomPanBehavior].
  OiZoomPanBehavior({
    this.config = const OiZoomPanConfig(),
    this.onZoomChanged,
  });

  /// Zoom/pan constraint configuration.
  final OiZoomPanConfig config;

  /// Called when the zoom or pan changes.
  final void Function(double zoomLevel, Offset panOffset)? onZoomChanged;

  // ── Drag state ─────────────────────────────────────────────────────────

  Offset? _dragStart;
  Offset _panStart = Offset.zero;

  // ── Pinch state ────────────────────────────────────────────────────────

  final Map<int, Offset> _pointers = {};
  double? _pinchStartDistance;
  double? _pinchStartZoom;

  // ── Wheel zoom ─────────────────────────────────────────────────────────

  @override
  void onPointerScroll(PointerScrollEvent event) {
    if (!config.enableWheelZoom) return;

    final viewport = context.viewport;
    final currentZoom = viewport.zoomLevel;
    final scrollDelta = event.scrollDelta.dy;

    // Negative scroll = zoom in, positive = zoom out.
    final zoomDelta = scrollDelta > 0
        ? -config.wheelZoomFactor
        : config.wheelZoomFactor;
    final newZoom = (currentZoom * (1 + zoomDelta)).clamp(
      config.minZoom,
      config.maxZoom,
    );

    if (newZoom == currentZoom) return;

    final newViewport = viewport.zoomTo(
      newZoom,
      focalPoint: event.localPosition,
    );

    // Update the controller viewport state.
    context.controller.viewportState
      ..zoomLevel = newViewport.zoomLevel
      ..panOffset = newViewport.panOffset;

    _notifyZoomChanged();
  }

  // ── Drag pan ───────────────────────────────────────────────────────────

  @override
  void onPointerDown(PointerDownEvent event) {
    _pointers[event.pointer] = event.localPosition;

    if (_pointers.length == 1 && config.enableDragPan) {
      _dragStart = event.localPosition;
      _panStart = context.controller.viewportState.panOffset;
    } else if (_pointers.length == 2 && config.enablePinchZoom) {
      _startPinch();
    }
  }

  @override
  void onPointerMove(PointerMoveEvent event) {
    _pointers[event.pointer] = event.localPosition;

    if (_pointers.length == 2 && config.enablePinchZoom) {
      _updatePinch();
    } else if (_pointers.length == 1 &&
        config.enableDragPan &&
        _dragStart != null) {
      final delta = event.localPosition - _dragStart!;
      context.controller.viewportState.panOffset = _panStart + delta;
      _notifyZoomChanged();
    }
  }

  @override
  void onPointerUp(PointerUpEvent event) {
    _pointers.remove(event.pointer);
    if (_pointers.isEmpty) {
      _dragStart = null;
      _pinchStartDistance = null;
      _pinchStartZoom = null;
    } else if (_pointers.length == 1) {
      // Transition from pinch to drag.
      _pinchStartDistance = null;
      _pinchStartZoom = null;
      if (config.enableDragPan) {
        _dragStart = _pointers.values.first;
        _panStart = context.controller.viewportState.panOffset;
      }
    }
  }

  @override
  void onPointerCancel(PointerCancelEvent event) {
    _pointers.remove(event.pointer);
    if (_pointers.isEmpty) {
      _dragStart = null;
      _pinchStartDistance = null;
      _pinchStartZoom = null;
    }
  }

  // ── Pinch zoom ─────────────────────────────────────────────────────────

  void _startPinch() {
    final pointers = _pointers.values.toList();
    _pinchStartDistance = (pointers[0] - pointers[1]).distance;
    _pinchStartZoom = context.controller.viewportState.zoomLevel;
    _dragStart = null;
  }

  void _updatePinch() {
    if (_pinchStartDistance == null || _pinchStartZoom == null) return;

    final pointers = _pointers.values.toList();
    final currentDistance = (pointers[0] - pointers[1]).distance;
    final scale = currentDistance / _pinchStartDistance!;

    final newZoom = (_pinchStartZoom! * scale).clamp(
      config.minZoom,
      config.maxZoom,
    );

    context.controller.viewportState.zoomLevel = newZoom;
    _notifyZoomChanged();
  }

  // ── Public API ─────────────────────────────────────────────────────────

  /// Zooms to fit the given [domainRect] in the viewport.
  void zoomToRange(Rect domainRect) {
    final viewport = context.viewport;
    final plotBounds = viewport.plotBounds;

    final scaleX = plotBounds.width / math.max(domainRect.width, 1);
    final scaleY = plotBounds.height / math.max(domainRect.height, 1);
    final newZoom = math
        .min(scaleX, scaleY)
        .clamp(config.minZoom, config.maxZoom);

    context.controller.viewportState
      ..zoomLevel = newZoom
      ..panOffset = Offset.zero;
    _notifyZoomChanged();
  }

  /// Resets zoom and pan to defaults.
  void resetZoom() {
    context.controller.resetZoom();
    _notifyZoomChanged();
  }

  void _notifyZoomChanged() {
    final state = context.controller.viewportState;
    onZoomChanged?.call(state.zoomLevel, state.panOffset);
  }

  @override
  void detach() {
    _pointers.clear();
    _dragStart = null;
    _pinchStartDistance = null;
    _pinchStartZoom = null;
    super.detach();
  }
}
