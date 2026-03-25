import 'package:flutter/foundation.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_canvas.dart';

/// The semantic role of a chart layer.
///
/// Used for default z-ordering and for selective invalidation.
///
/// {@category Foundation}
enum OiChartLayerRole {
  /// Background fills, reference bands, or shaded regions.
  background,

  /// Grid lines, tick marks, and axis lines.
  grid,

  /// Data series marks (lines, bars, points, areas).
  series,

  /// Annotations such as threshold lines, labels, or callouts.
  annotation,

  /// Interactive overlays like crosshairs, tooltips, and selection
  /// highlights.
  overlay,
}

/// A z-ordered compositing layer for chart visual elements.
///
/// [OiChartLayer] enables correct draw ordering by assigning each
/// visual element a [zOrder] value. Layers with lower z-order are
/// painted first (behind), and higher z-order layers are painted last
/// (on top).
///
/// Each layer can be independently toggled with [visible],
/// faded with [opacity], and configured to clip to the plot area
/// with [clipToPlotArea]. This supports selective invalidation —
/// only layers whose painters report [OiChartLayerPainter.shouldRepaint]
/// as `true` trigger a repaint.
///
/// ## Default z-ordering by role
///
/// | Role | Default z-order |
/// |------|----------------|
/// | [OiChartLayerRole.background] | 0 |
/// | [OiChartLayerRole.grid] | 10 |
/// | [OiChartLayerRole.series] | 20 |
/// | [OiChartLayerRole.annotation] | 30 |
/// | [OiChartLayerRole.overlay] | 40 |
///
/// ## Usage
///
/// ```dart
/// OiChartLayer(
///   id: 'grid',
///   role: OiChartLayerRole.grid,
///   painter: myGridPainter,
/// )
/// ```
///
/// ```dart
/// OiChartLayer(
///   id: 'highlight',
///   role: OiChartLayerRole.overlay,
///   zOrder: 50,  // Custom z-order overrides the role default.
///   painter: highlightPainter,
///   opacity: 0.6,
/// )
/// ```
///
/// {@category Foundation}
@immutable
class OiChartLayer {
  /// Creates an [OiChartLayer] with a role-based default z-order.
  ///
  /// If [zOrder] is not provided, it defaults based on [role]:
  /// - [OiChartLayerRole.background]: 0
  /// - [OiChartLayerRole.grid]: 10
  /// - [OiChartLayerRole.series]: 20
  /// - [OiChartLayerRole.annotation]: 30
  /// - [OiChartLayerRole.overlay]: 40
  OiChartLayer({
    required this.id,
    this.role = OiChartLayerRole.series,
    int? zOrder,
    this.painter,
    this.visible = true,
    this.opacity = 1.0,
    this.clipToPlotArea = true,
  }) : zOrder = zOrder ?? _defaultZOrder(role);

  /// A unique identifier for this layer.
  ///
  /// Used for selective invalidation and debugging.
  final String id;

  /// The semantic role of this layer.
  final OiChartLayerRole role;

  /// The z-order for compositing. Lower values paint first (behind).
  final int zOrder;

  /// The painter responsible for rendering this layer's content.
  ///
  /// When `null`, the layer is a no-op (useful as a placeholder).
  final OiChartLayerPainter? painter;

  /// Whether this layer is currently visible.
  ///
  /// Invisible layers are skipped during painting. Toggle this to
  /// temporarily hide layers without removing them from the list.
  final bool visible;

  /// The opacity applied to this layer, from 0.0 (fully transparent)
  /// to 1.0 (fully opaque).
  final double opacity;

  /// Whether this layer should be clipped to the plot area bounds.
  ///
  /// Set to `false` for overlays or annotations that extend beyond
  /// the plot area (e.g. axis labels, external tooltips).
  final bool clipToPlotArea;

  /// Creates a copy with optionally overridden values.
  OiChartLayer copyWith({
    String? id,
    OiChartLayerRole? role,
    int? zOrder,
    OiChartLayerPainter? painter,
    bool? visible,
    double? opacity,
    bool? clipToPlotArea,
  }) {
    return OiChartLayer(
      id: id ?? this.id,
      role: role ?? this.role,
      zOrder: zOrder ?? this.zOrder,
      painter: painter ?? this.painter,
      visible: visible ?? this.visible,
      opacity: opacity ?? this.opacity,
      clipToPlotArea: clipToPlotArea ?? this.clipToPlotArea,
    );
  }

  static int _defaultZOrder(OiChartLayerRole role) {
    return switch (role) {
      OiChartLayerRole.background => 0,
      OiChartLayerRole.grid => 10,
      OiChartLayerRole.series => 20,
      OiChartLayerRole.annotation => 30,
      OiChartLayerRole.overlay => 40,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiChartLayer &&
          other.id == id &&
          other.role == role &&
          other.zOrder == zOrder &&
          other.visible == visible &&
          other.opacity == opacity &&
          other.clipToPlotArea == clipToPlotArea;

  @override
  int get hashCode =>
      Object.hash(id, role, zOrder, visible, opacity, clipToPlotArea);

  @override
  String toString() =>
      'OiChartLayer(id: $id, role: $role, z: $zOrder, '
      'visible: $visible, opacity: $opacity)';
}
