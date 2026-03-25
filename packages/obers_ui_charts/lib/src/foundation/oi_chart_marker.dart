import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_canvas.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Marker Shape
// ─────────────────────────────────────────────────────────────────────────────

/// The shape of a chart data-point marker.
///
/// {@category Foundation}
enum OiChartMarkerShape {
  /// A filled or stroked circle.
  circle,

  /// A filled or stroked square.
  square,

  /// A filled or stroked diamond (rotated square).
  diamond,

  /// A filled or stroked equilateral triangle pointing up.
  triangle,

  /// A cross / plus sign (stroke only, no fill).
  cross,

  /// A user-supplied [Path] builder.
  custom,
}

// ─────────────────────────────────────────────────────────────────────────────
// Marker Visual State
// ─────────────────────────────────────────────────────────────────────────────

/// The interactive visual state of a chart marker.
///
/// {@category Foundation}
enum OiChartMarkerState {
  /// Default resting state.
  normal,

  /// The pointer is hovering over this marker.
  hovered,

  /// The marker has been selected / tapped.
  selected,

  /// The marker belongs to a series or data point that is dimmed because
  /// another element is highlighted.
  inactive,
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Path Builder
// ─────────────────────────────────────────────────────────────────────────────

/// Signature for a function that builds a custom marker [Path].
///
/// The [center] is the marker's position and [size] is the full width/height
/// of the bounding box.
///
/// {@category Foundation}
typedef OiChartMarkerPathBuilder = Path Function(Offset center, double size);

// ─────────────────────────────────────────────────────────────────────────────
// OiChartMarkerStyle
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable style definition for a single data-point marker.
///
/// {@category Foundation}
@immutable
class OiChartMarkerStyle {
  /// Creates an [OiChartMarkerStyle].
  const OiChartMarkerStyle({
    this.shape = OiChartMarkerShape.circle,
    this.size = 8.0,
    this.fillColor,
    this.strokeColor,
    this.strokeWidth = 1.5,
    this.customPathBuilder,
  });

  /// The geometric shape of the marker.
  final OiChartMarkerShape shape;

  /// The full width / height of the marker in logical pixels.
  final double size;

  /// The fill color. When `null`, the marker is not filled.
  final Color? fillColor;

  /// The stroke (outline) color. When `null`, no stroke is drawn.
  final Color? strokeColor;

  /// The stroke width in logical pixels.
  final double strokeWidth;

  /// A builder for [OiChartMarkerShape.custom] shapes.
  ///
  /// Ignored for all other shapes.
  final OiChartMarkerPathBuilder? customPathBuilder;

  /// Creates a copy with optionally overridden values.
  OiChartMarkerStyle copyWith({
    OiChartMarkerShape? shape,
    double? size,
    Color? fillColor,
    Color? strokeColor,
    double? strokeWidth,
    OiChartMarkerPathBuilder? customPathBuilder,
  }) {
    return OiChartMarkerStyle(
      shape: shape ?? this.shape,
      size: size ?? this.size,
      fillColor: fillColor ?? this.fillColor,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      customPathBuilder: customPathBuilder ?? this.customPathBuilder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartMarkerStyle &&
        other.shape == shape &&
        other.size == size &&
        other.fillColor == fillColor &&
        other.strokeColor == strokeColor &&
        other.strokeWidth == strokeWidth &&
        other.customPathBuilder == customPathBuilder;
  }

  @override
  int get hashCode => Object.hash(
    shape,
    size,
    fillColor,
    strokeColor,
    strokeWidth,
    customPathBuilder,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// OiChartMarker — Layer Painter
// ─────────────────────────────────────────────────────────────────────────────

/// A chart layer painter that renders data-point markers.
///
/// Each marker is defined by a position, a [style], and an interactive
/// state. The painter applies visual state modifiers (scale-up on hover,
/// highlight stroke on selection, reduced opacity on inactive) on top of
/// the base style.
///
/// ## Usage
///
/// ```dart
/// OiChartLayer(
///   id: 'markers',
///   role: OiChartLayerRole.series,
///   painter: OiChartMarker(
///     points: [Offset(100, 50), Offset(200, 80)],
///     style: OiChartMarkerStyle(
///       shape: OiChartMarkerShape.circle,
///       size: 8,
///       fillColor: Colors.blue,
///       strokeColor: Colors.white,
///     ),
///   ),
/// )
/// ```
///
/// {@category Foundation}
class OiChartMarker extends OiChartLayerPainter {
  /// Creates an [OiChartMarker] painter.
  OiChartMarker({
    required this.points,
    required this.style,
    this.states = const [],
    this.hoverScaleFactor = 1.3,
    this.selectedStrokeWidthExtra = 1.5,
    this.inactiveOpacity = 0.35,
  });

  /// The marker center positions in widget-local coordinates.
  final List<Offset> points;

  /// The base visual style for all markers.
  final OiChartMarkerStyle style;

  /// Per-point interactive state. When shorter than [points], remaining
  /// points default to [OiChartMarkerState.normal].
  final List<OiChartMarkerState> states;

  /// Scale factor applied to marker size on hover.
  final double hoverScaleFactor;

  /// Extra stroke width added when a marker is selected.
  final double selectedStrokeWidthExtra;

  /// Opacity multiplier for inactive markers.
  final double inactiveOpacity;

  @override
  void paint(OiChartCanvasContext context) {
    for (var i = 0; i < points.length; i++) {
      final center = points[i];
      final state = i < states.length ? states[i] : OiChartMarkerState.normal;
      _paintMarker(context.canvas, center, state);
    }
  }

  void _paintMarker(Canvas canvas, Offset center, OiChartMarkerState state) {
    var effectiveSize = style.size;
    var effectiveStrokeWidth = style.strokeWidth;
    var opacity = 1.0;

    switch (state) {
      case OiChartMarkerState.normal:
        break;
      case OiChartMarkerState.hovered:
        effectiveSize *= hoverScaleFactor;
      case OiChartMarkerState.selected:
        effectiveStrokeWidth += selectedStrokeWidthExtra;
      case OiChartMarkerState.inactive:
        opacity = inactiveOpacity;
    }

    final fillColor = style.fillColor?.withValues(
      alpha: style.fillColor!.a * opacity,
    );
    final strokeColor = style.strokeColor?.withValues(
      alpha: style.strokeColor!.a * opacity,
    );

    final halfSize = effectiveSize / 2;

    switch (style.shape) {
      case OiChartMarkerShape.circle:
        _paintCircle(
          canvas,
          center,
          halfSize,
          fillColor,
          strokeColor,
          effectiveStrokeWidth,
        );
      case OiChartMarkerShape.square:
        _paintSquare(
          canvas,
          center,
          halfSize,
          fillColor,
          strokeColor,
          effectiveStrokeWidth,
        );
      case OiChartMarkerShape.diamond:
        _paintDiamond(
          canvas,
          center,
          halfSize,
          fillColor,
          strokeColor,
          effectiveStrokeWidth,
        );
      case OiChartMarkerShape.triangle:
        _paintTriangle(
          canvas,
          center,
          halfSize,
          fillColor,
          strokeColor,
          effectiveStrokeWidth,
        );
      case OiChartMarkerShape.cross:
        _paintCross(
          canvas,
          center,
          halfSize,
          strokeColor,
          effectiveStrokeWidth,
        );
      case OiChartMarkerShape.custom:
        _paintCustom(
          canvas,
          center,
          effectiveSize,
          fillColor,
          strokeColor,
          effectiveStrokeWidth,
        );
    }
  }

  void _paintCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Color? fill,
    Color? stroke,
    double strokeWidth,
  ) {
    if (fill != null) {
      canvas.drawCircle(center, radius, Paint()..color = fill);
    }
    if (stroke != null) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
    }
  }

  void _paintSquare(
    Canvas canvas,
    Offset center,
    double halfSize,
    Color? fill,
    Color? stroke,
    double strokeWidth,
  ) {
    final rect = Rect.fromCenter(
      center: center,
      width: halfSize * 2,
      height: halfSize * 2,
    );
    if (fill != null) {
      canvas.drawRect(rect, Paint()..color = fill);
    }
    if (stroke != null) {
      canvas.drawRect(
        rect,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
    }
  }

  void _paintDiamond(
    Canvas canvas,
    Offset center,
    double halfSize,
    Color? fill,
    Color? stroke,
    double strokeWidth,
  ) {
    final path = Path()
      ..moveTo(center.dx, center.dy - halfSize)
      ..lineTo(center.dx + halfSize, center.dy)
      ..lineTo(center.dx, center.dy + halfSize)
      ..lineTo(center.dx - halfSize, center.dy)
      ..close();
    if (fill != null) {
      canvas.drawPath(path, Paint()..color = fill);
    }
    if (stroke != null) {
      canvas.drawPath(
        path,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
    }
  }

  void _paintTriangle(
    Canvas canvas,
    Offset center,
    double halfSize,
    Color? fill,
    Color? stroke,
    double strokeWidth,
  ) {
    // Equilateral triangle pointing up, inscribed in a circle of radius
    // halfSize.
    final h = halfSize * math.sqrt(3) / 2;
    final path = Path()
      ..moveTo(center.dx, center.dy - halfSize)
      ..lineTo(center.dx + h, center.dy + halfSize / 2)
      ..lineTo(center.dx - h, center.dy + halfSize / 2)
      ..close();
    if (fill != null) {
      canvas.drawPath(path, Paint()..color = fill);
    }
    if (stroke != null) {
      canvas.drawPath(
        path,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
    }
  }

  void _paintCross(
    Canvas canvas,
    Offset center,
    double halfSize,
    Color? stroke,
    double strokeWidth,
  ) {
    final paint = Paint()
      ..color = stroke ?? const Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas
      // Horizontal bar.
      ..drawLine(
        Offset(center.dx - halfSize, center.dy),
        Offset(center.dx + halfSize, center.dy),
        paint,
      )
      // Vertical bar.
      ..drawLine(
        Offset(center.dx, center.dy - halfSize),
        Offset(center.dx, center.dy + halfSize),
        paint,
      );
  }

  void _paintCustom(
    Canvas canvas,
    Offset center,
    double size,
    Color? fill,
    Color? stroke,
    double strokeWidth,
  ) {
    final builder = style.customPathBuilder;
    if (builder == null) return;
    final path = builder(center, size);
    if (fill != null) {
      canvas.drawPath(path, Paint()..color = fill);
    }
    if (stroke != null) {
      canvas.drawPath(
        path,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
    }
  }

  @override
  bool shouldRepaint(covariant OiChartMarker oldPainter) {
    return !listEquals(oldPainter.points, points) ||
        oldPainter.style != style ||
        !listEquals(oldPainter.states, states) ||
        oldPainter.hoverScaleFactor != hoverScaleFactor ||
        oldPainter.selectedStrokeWidthExtra != selectedStrokeWidthExtra ||
        oldPainter.inactiveOpacity != inactiveOpacity;
  }
}
