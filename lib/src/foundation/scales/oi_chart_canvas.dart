import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'package:obers_ui/src/foundation/scales/oi_chart_extension.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_layer.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_viewport.dart';

/// A custom painting surface for chart rendering.
///
/// [OiChartCanvas] wraps Flutter's [CustomPaint] to provide a chart-aware
/// canvas that handles device pixel ratio, clips to the plot bounds,
/// manages render layers, and provides the canvas context to series
/// renderers and chart extensions.
///
/// ## Usage
///
/// ```dart
/// OiChartCanvas(
///   viewport: viewport,
///   layers: [
///     OiChartLayer(
///       id: 'grid',
///       zOrder: 0,
///       painter: gridPainter,
///     ),
///     OiChartLayer(
///       id: 'series',
///       zOrder: 10,
///       painter: seriesPainter,
///     ),
///   ],
/// )
/// ```
///
/// {@category Foundation}
class OiChartCanvas extends StatelessWidget {
  /// Creates an [OiChartCanvas].
  const OiChartCanvas({
    required this.viewport,
    required this.layers,
    this.extensions = const [],
    this.clipToPlotArea = true,
    this.repaint,
    super.key,
  });

  /// The chart viewport defining geometry, device pixel ratio, and
  /// coordinate conversions.
  final OiChartViewport viewport;

  /// The render layers to paint, in z-order.
  ///
  /// Layers are sorted by [OiChartLayer.zOrder] before painting.
  /// Each layer can be independently invalidated.
  final List<OiChartLayer> layers;

  /// Optional chart extensions that receive lifecycle hooks.
  final List<OiChartExtension> extensions;

  /// Whether to clip painting to the plot area bounds.
  ///
  /// When `true` (default), all layer painting is clipped to
  /// [OiChartViewport.plotBounds] so that data marks do not overflow
  /// into axis label areas.
  final bool clipToPlotArea;

  /// An optional [Listenable] that triggers repaints.
  final Listenable? repaint;

  @override
  Widget build(BuildContext context) {
    final sortedLayers = List<OiChartLayer>.of(layers)
      ..sort((a, b) => a.zOrder.compareTo(b.zOrder));

    return CustomPaint(
      key: const Key('oi_chart_canvas'),
      painter: _OiChartCanvasPainter(
        viewport: viewport,
        layers: sortedLayers,
        extensions: extensions,
        clipToPlotArea: clipToPlotArea,
        repaint: repaint,
      ),
      size: viewport.size,
    );
  }
}

/// The context provided to [OiChartLayerPainter] during painting.
///
/// Contains the canvas, viewport, and plot bounds so painters have
/// everything they need to render chart content.
///
/// {@category Foundation}
@immutable
class OiChartCanvasContext {
  /// Creates an [OiChartCanvasContext].
  const OiChartCanvasContext({
    required this.canvas,
    required this.size,
    required this.viewport,
    required this.plotBounds,
    required this.devicePixelRatio,
  });

  /// The Flutter canvas to paint on.
  final Canvas canvas;

  /// The total size of the chart widget.
  final Size size;

  /// The chart viewport with coordinate conversion helpers.
  final OiChartViewport viewport;

  /// The clipped plot area bounds in widget-local coordinates.
  final Rect plotBounds;

  /// The device pixel ratio for crisp rendering.
  final double devicePixelRatio;

  /// Snaps a logical pixel [value] to the nearest physical pixel boundary.
  double snapToPixel(double value) {
    return (value * devicePixelRatio).roundToDouble() / devicePixelRatio;
  }

  /// Snaps an [Offset] to the nearest physical pixel boundary.
  Offset snapOffsetToPixel(Offset offset) {
    return Offset(snapToPixel(offset.dx), snapToPixel(offset.dy));
  }
}

/// Abstract painter for a single chart layer.
///
/// Subclass this to implement specific rendering (grid lines, series
/// data, annotations, overlays, etc.). Each painter receives an
/// [OiChartCanvasContext] with the canvas, viewport, and plot bounds.
///
/// {@category Foundation}
abstract class OiChartLayerPainter {
  /// Paints this layer's content.
  void paint(OiChartCanvasContext context);

  /// Whether this painter should repaint when the old painter changes.
  ///
  /// Override to return `false` for static layers that do not change
  /// between frames (e.g. a fixed grid). Defaults to `true`.
  bool shouldRepaint(covariant OiChartLayerPainter oldPainter) => true;
}

class _OiChartCanvasPainter extends CustomPainter {
  _OiChartCanvasPainter({
    required this.viewport,
    required this.layers,
    required this.extensions,
    required this.clipToPlotArea,
    super.repaint,
  });

  final OiChartViewport viewport;
  final List<OiChartLayer> layers;
  final List<OiChartExtension> extensions;
  final bool clipToPlotArea;

  @override
  void paint(Canvas canvas, Size size) {
    final plotBounds = viewport.plotBounds;
    final dpr = viewport.devicePixelRatio;

    final canvasContext = OiChartCanvasContext(
      canvas: canvas,
      size: size,
      viewport: viewport,
      plotBounds: plotBounds,
      devicePixelRatio: dpr,
    );

    for (final ext in extensions) {
      ext.onBeforeCanvasPaint(canvasContext);
    }

    for (final layer in layers) {
      if (!layer.visible) continue;

      final painter = layer.painter;
      if (painter == null) continue;

      canvas.save();

      // Apply device pixel ratio aware rendering.
      // Snap the clip rect to physical pixel boundaries for crispness.
      if (clipToPlotArea && layer.clipToPlotArea) {
        final snappedBounds = Rect.fromLTRB(
          _snapDown(plotBounds.left, dpr),
          _snapDown(plotBounds.top, dpr),
          _snapUp(plotBounds.right, dpr),
          _snapUp(plotBounds.bottom, dpr),
        );
        canvas.clipRect(snappedBounds);
      }

      // Apply layer opacity.
      if (layer.opacity < 1.0) {
        canvas.saveLayer(
          Offset.zero & size,
          Paint()..color = ui.Color.fromARGB(
            (layer.opacity * 255).round(),
            255,
            255,
            255,
          ),
        );
      }

      painter.paint(canvasContext);

      if (layer.opacity < 1.0) {
        canvas.restore();
      }

      canvas.restore();
    }

    for (final ext in extensions) {
      ext.onAfterCanvasPaint(canvasContext);
    }
  }

  @override
  bool shouldRepaint(_OiChartCanvasPainter oldDelegate) {
    if (viewport != oldDelegate.viewport) return true;
    if (clipToPlotArea != oldDelegate.clipToPlotArea) return true;
    if (layers.length != oldDelegate.layers.length) return true;

    for (var i = 0; i < layers.length; i++) {
      final newLayer = layers[i];
      final oldLayer = oldDelegate.layers[i];
      if (newLayer.id != oldLayer.id) return true;
      if (newLayer.zOrder != oldLayer.zOrder) return true;
      if (newLayer.visible != oldLayer.visible) return true;
      if (newLayer.opacity != oldLayer.opacity) return true;
      if (newLayer.clipToPlotArea != oldLayer.clipToPlotArea) return true;

      final newPainter = newLayer.painter;
      final oldPainter = oldLayer.painter;
      if (newPainter == null && oldPainter == null) continue;
      if (newPainter == null || oldPainter == null) return true;
      if (newPainter.runtimeType != oldPainter.runtimeType) return true;
      if (newPainter.shouldRepaint(oldPainter)) return true;
    }

    return false;
  }

  static double _snapDown(double value, double dpr) {
    return (value * dpr).floorToDouble() / dpr;
  }

  static double _snapUp(double value, double dpr) {
    return (value * dpr).ceilToDouble() / dpr;
  }
}
