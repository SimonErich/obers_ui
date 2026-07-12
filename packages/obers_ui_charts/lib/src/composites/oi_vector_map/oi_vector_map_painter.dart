import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui_charts/src/composites/oi_vector_map/oi_vector_map_data.dart';
import 'package:obers_ui_charts/src/composites/oi_vector_map/oi_vector_map_projection.dart';
import 'package:obers_ui_charts/src/models/oi_color_scale.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Resolved render data
// ─────────────────────────────────────────────────────────────────────────────

/// A region resolved to a cached screen-space [path] and [fillColor],
/// ready to be painted and hit-tested without per-frame work.
///
/// {@category Composites}
@immutable
class OiVectorMapRegionShape {
  /// Creates an [OiVectorMapRegionShape].
  const OiVectorMapRegionShape({
    required this.region,
    required this.path,
    required this.fillColor,
    required this.hasValue,
  });

  /// The source region.
  final OiMapRegion region;

  /// The cached screen-space outline path.
  final Path path;

  /// The resolved fill color.
  final Color fillColor;

  /// Whether [fillColor] was derived from a data value; `false` means the
  /// neutral fill is used.
  final bool hasValue;
}

/// A marker resolved to a screen-space [center] and [radiusInPixels].
///
/// {@category Composites}
@immutable
class OiVectorMapMarkerPoint {
  /// Creates an [OiVectorMapMarkerPoint].
  const OiVectorMapMarkerPoint({
    required this.marker,
    required this.center,
    required this.radiusInPixels,
    required this.color,
  });

  /// The source marker.
  final OiMapMarker marker;

  /// The screen-space center of the bubble.
  final Offset center;

  /// The bubble radius in logical pixels.
  final double radiusInPixels;

  /// The resolved bubble color.
  final Color color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Pure geometry helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Pure geometry helpers shared by the vector map widget, painter, and
/// tests.
///
/// {@category Composites}
class OiVectorMapGeometry {
  const OiVectorMapGeometry._();

  /// Returns the largest rectangle with [aspectRatio] (width / height)
  /// that fits centered inside [size].
  static Rect fitMapRect(Size size, double aspectRatio) {
    if (size.isEmpty) return Rect.zero;
    var width = size.width;
    var height = width / aspectRatio;
    if (height > size.height) {
      height = size.height;
      width = height * aspectRatio;
    }
    final left = (size.width - width) / 2;
    final top = (size.height - height) / 2;
    return Rect.fromLTWH(left, top, width, height);
  }

  /// Converts a [normalized] map-space offset (both components 0…1) to
  /// canvas coordinates inside [mapRect].
  static Offset toCanvas({required Offset normalized, required Rect mapRect}) {
    return Offset(
      mapRect.left + normalized.dx * mapRect.width,
      mapRect.top + normalized.dy * mapRect.height,
    );
  }

  /// Returns the bubble radius for [value] so that the bubble *area* is
  /// proportional to the value.
  ///
  /// The largest value maps to [maxRadiusInPixels]; smaller values scale
  /// with the square root of their ratio to [maxValue] and never fall
  /// below [minRadiusInPixels].
  static double markerRadius({
    required num value,
    required num maxValue,
    required double maxRadiusInPixels,
    double minRadiusInPixels = 3,
  }) {
    if (maxValue <= 0 || value <= 0) return minRadiusInPixels;
    final scaled = maxRadiusInPixels * math.sqrt(value / maxValue);
    return scaled.clamp(minRadiusInPixels, maxRadiusInPixels);
  }

  /// Resolves [regions] into cached, screen-space [OiVectorMapRegionShape]s.
  ///
  /// Each region's polygons are projected through [projection] into
  /// [mapRect] and cached as a single [Path]. Valued regions are filled by
  /// [colorScale]; regions without a value use [neutralColor]. Called once
  /// per region set, not per frame.
  static List<OiVectorMapRegionShape> buildRegionShapes({
    required List<OiMapRegion> regions,
    required OiMapProjection projection,
    required Rect mapRect,
    required OiColorScale colorScale,
    required Color neutralColor,
  }) {
    final shapes = <OiVectorMapRegionShape>[];
    for (final region in regions) {
      final path = Path();
      for (final polygon in region.polygons) {
        if (polygon.isEmpty) continue;
        final first = _projectVertex(polygon.first, projection, mapRect);
        path.moveTo(first.dx, first.dy);
        for (var i = 1; i < polygon.length; i++) {
          final point = _projectVertex(polygon[i], projection, mapRect);
          path.lineTo(point.dx, point.dy);
        }
        path.close();
      }
      final value = region.value;
      shapes.add(
        OiVectorMapRegionShape(
          region: region,
          path: path,
          fillColor: value == null ? neutralColor : colorScale.resolve(value),
          hasValue: value != null,
        ),
      );
    }
    return shapes;
  }

  /// Resolves [markers] into cached, screen-space [OiVectorMapMarkerPoint]s.
  ///
  /// Bubble radii are sized so area is proportional to value (see
  /// [markerRadius]), scaled against the largest value in [markers].
  static List<OiVectorMapMarkerPoint> buildMarkerPoints({
    required List<OiMapMarker> markers,
    required OiMapProjection projection,
    required Rect mapRect,
    required double maxRadiusInPixels,
    required Color defaultColor,
  }) {
    if (markers.isEmpty) return const [];
    var maxValue = 0.0;
    for (final marker in markers) {
      maxValue = math.max(maxValue, marker.value.toDouble());
    }
    return [
      for (final marker in markers)
        OiVectorMapMarkerPoint(
          marker: marker,
          center: toCanvas(
            normalized: projection.project(
              latitude: marker.latitude,
              longitude: marker.longitude,
            ),
            mapRect: mapRect,
          ),
          radiusInPixels: markerRadius(
            value: marker.value,
            maxValue: maxValue,
            maxRadiusInPixels: maxRadiusInPixels,
          ),
          color: marker.color ?? defaultColor,
        ),
    ];
  }

  static Offset _projectVertex(
    Offset lonLat,
    OiMapProjection projection,
    Rect mapRect,
  ) {
    return toCanvas(
      normalized: projection.project(latitude: lonLat.dy, longitude: lonLat.dx),
      mapRect: mapRect,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OiVectorMapPainter
// ─────────────────────────────────────────────────────────────────────────────

/// Paints the vector map: region fills and outlines first, marker bubbles
/// on top.
///
/// All geometry arrives pre-resolved ([shapes], [markerPoints]) so the
/// paint pass allocates nothing beyond two reused [Paint] objects and
/// never rebuilds paths.
///
/// {@category Composites}
class OiVectorMapPainter extends CustomPainter {
  /// Creates an [OiVectorMapPainter].
  const OiVectorMapPainter({
    required this.shapes,
    required this.markerPoints,
    required this.borderColor,
    required this.highlightColor,
    this.hoveredRegionId,
    this.hoveredMarkerIndex,
  });

  /// The resolved region shapes in paint order (large regions first so
  /// enclaves stay visible).
  final List<OiVectorMapRegionShape> shapes;

  /// The resolved marker bubbles, painted above the regions.
  final List<OiVectorMapMarkerPoint> markerPoints;

  /// The stroke color for region outlines.
  final Color borderColor;

  /// The stroke color emphasizing the hovered region or marker.
  final Color highlightColor;

  /// The id of the hovered region, if any.
  final String? hoveredRegionId;

  /// The index into [markerPoints] of the hovered marker, if any.
  final int? hoveredMarkerIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = borderColor;

    for (final shape in shapes) {
      fillPaint.color = shape.fillColor;
      canvas
        ..drawPath(shape.path, fillPaint)
        ..drawPath(shape.path, strokePaint);
    }

    // Hovered region emphasis on top of neighbouring outlines.
    if (hoveredRegionId != null) {
      strokePaint
        ..color = highlightColor
        ..strokeWidth = 1.4;
      for (final shape in shapes) {
        if (shape.region.id == hoveredRegionId) {
          canvas.drawPath(shape.path, strokePaint);
        }
      }
      strokePaint
        ..color = borderColor
        ..strokeWidth = 0.6;
    }

    for (var i = 0; i < markerPoints.length; i++) {
      final point = markerPoints[i];
      fillPaint.color = point.color.withValues(alpha: 0.7);
      canvas.drawCircle(point.center, point.radiusInPixels, fillPaint);
      strokePaint
        ..color = i == hoveredMarkerIndex ? highlightColor : point.color
        ..strokeWidth = i == hoveredMarkerIndex ? 2 : 1;
      canvas.drawCircle(point.center, point.radiusInPixels, strokePaint);
    }
  }

  @override
  bool shouldRepaint(OiVectorMapPainter oldDelegate) {
    return oldDelegate.shapes != shapes ||
        oldDelegate.markerPoints != markerPoints ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.highlightColor != highlightColor ||
        oldDelegate.hoveredRegionId != hoveredRegionId ||
        oldDelegate.hoveredMarkerIndex != hoveredMarkerIndex;
  }
}
