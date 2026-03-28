import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_canvas.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Grid Line Config
// ─────────────────────────────────────────────────────────────────────────────

/// Configuration for a single set of grid lines (major or minor) on one axis.
///
/// {@category Foundation}
@immutable
class OiChartGridLineConfig {
  /// Creates an [OiChartGridLineConfig].
  const OiChartGridLineConfig({
    this.color,
    this.width,
    this.dashPattern,
    this.visible = true,
  });

  /// The grid line color. Falls back to theme or a default grey.
  final Color? color;

  /// The grid line width in logical pixels.
  final double? width;

  /// An optional dash pattern (e.g. `[4, 2]`). Solid when `null`.
  final List<double>? dashPattern;

  /// Whether these grid lines are drawn.
  final bool visible;

  /// Creates a copy with optionally overridden values.
  OiChartGridLineConfig copyWith({
    Color? color,
    double? width,
    List<double>? dashPattern,
    bool? visible,
  }) {
    return OiChartGridLineConfig(
      color: color ?? this.color,
      width: width ?? this.width,
      dashPattern: dashPattern ?? this.dashPattern,
      visible: visible ?? this.visible,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiChartGridLineConfig) return false;
    if (dashPattern != null && other.dashPattern != null) {
      if (!listEquals(dashPattern, other.dashPattern)) return false;
    } else if (dashPattern != other.dashPattern) {
      return false;
    }
    return other.color == color &&
        other.width == width &&
        other.visible == visible;
  }

  @override
  int get hashCode => Object.hash(
    color,
    width,
    dashPattern == null ? null : Object.hashAll(dashPattern!),
    visible,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// OiChartGridPainter
// ─────────────────────────────────────────────────────────────────────────────

/// A chart layer painter that renders major and minor grid lines for
/// Cartesian charts.
///
/// Grid lines are drawn at the [horizontalPositions] (horizontal lines,
/// for y-axis values) and [verticalPositions] (vertical lines, for x-axis
/// values). Positions are in widget-local pixel coordinates.
///
/// When no explicit colors or widths are provided, the painter derives
/// its appearance from [themeGrid] (the [OiChartGridTheme] from the
/// chart theme).
///
/// ## Usage
///
/// ```dart
/// OiChartLayer(
///   id: 'grid',
///   role: OiChartLayerRole.grid,
///   painter: OiChartGridPainter(
///     horizontalPositions: yTicks.map((t) => t.position).toList(),
///     verticalPositions: xTicks.map((t) => t.position).toList(),
///   ),
/// )
/// ```
///
/// {@category Foundation}
class OiChartGridPainter extends OiChartLayerPainter {
  /// Creates an [OiChartGridPainter].
  OiChartGridPainter({
    this.horizontalPositions = const [],
    this.verticalPositions = const [],
    this.majorHorizontal = const OiChartGridLineConfig(),
    this.majorVertical = const OiChartGridLineConfig(),
    this.minorHorizontal = const OiChartGridLineConfig(visible: false),
    this.minorVertical = const OiChartGridLineConfig(visible: false),
    this.minorHorizontalPositions = const [],
    this.minorVerticalPositions = const [],
    this.themeGrid,
  });

  /// Pixel y-positions for major horizontal grid lines.
  final List<double> horizontalPositions;

  /// Pixel x-positions for major vertical grid lines.
  final List<double> verticalPositions;

  /// Style for major horizontal lines.
  final OiChartGridLineConfig majorHorizontal;

  /// Style for major vertical lines.
  final OiChartGridLineConfig majorVertical;

  /// Style for minor horizontal lines.
  final OiChartGridLineConfig minorHorizontal;

  /// Style for minor vertical lines.
  final OiChartGridLineConfig minorVertical;

  /// Pixel y-positions for minor horizontal grid lines.
  final List<double> minorHorizontalPositions;

  /// Pixel x-positions for minor vertical grid lines.
  final List<double> minorVerticalPositions;

  /// Optional theme data for default colors / widths.
  final OiChartGridTheme? themeGrid;

  // ── Defaults ──────────────────────────────────────────────────────────

  static const Color _fallbackColor = Color(0x1A000000);
  static const double _fallbackMajorWidth = 1;
  static const double _fallbackMinorWidth = .5;

  // ── Painting ──────────────────────────────────────────────────────────

  @override
  void paint(OiChartCanvasContext context) {
    final bounds = context.plotBounds;

    // Minor lines first (behind major).
    if (minorHorizontal.visible && minorHorizontalPositions.isNotEmpty) {
      _paintHorizontalLines(
        context.canvas,
        bounds,
        minorHorizontalPositions,
        _resolveConfig(minorHorizontal, isMajor: false),
      );
    }
    if (minorVertical.visible && minorVerticalPositions.isNotEmpty) {
      _paintVerticalLines(
        context.canvas,
        bounds,
        minorVerticalPositions,
        _resolveConfig(minorVertical, isMajor: false),
      );
    }

    // Major lines.
    if (majorHorizontal.visible && horizontalPositions.isNotEmpty) {
      _paintHorizontalLines(
        context.canvas,
        bounds,
        horizontalPositions,
        _resolveConfig(majorHorizontal, isMajor: true),
      );
    }
    if (majorVertical.visible && verticalPositions.isNotEmpty) {
      _paintVerticalLines(
        context.canvas,
        bounds,
        verticalPositions,
        _resolveConfig(majorVertical, isMajor: true),
      );
    }
  }

  _ResolvedGridLine _resolveConfig(
    OiChartGridLineConfig config, {
    required bool isMajor,
  }) {
    final color = config.color ?? themeGrid?.color ?? _fallbackColor;
    final width =
        config.width ??
        themeGrid?.width ??
        (isMajor ? _fallbackMajorWidth : _fallbackMinorWidth);
    return _ResolvedGridLine(
      color: color,
      width: width,
      dash: config.dashPattern ?? themeGrid?.dashPattern,
    );
  }

  void _paintHorizontalLines(
    Canvas canvas,
    Rect bounds,
    List<double> positions,
    _ResolvedGridLine resolved,
  ) {
    final paint = Paint()
      ..color = resolved.color
      ..strokeWidth = resolved.width;

    for (final y in positions) {
      if (y < bounds.top || y > bounds.bottom) continue;
      final start = Offset(bounds.left, y);
      final end = Offset(bounds.right, y);
      if (resolved.dash != null && resolved.dash!.isNotEmpty) {
        _drawDashedLine(canvas, start, end, paint, resolved.dash!);
      } else {
        canvas.drawLine(start, end, paint);
      }
    }
  }

  void _paintVerticalLines(
    Canvas canvas,
    Rect bounds,
    List<double> positions,
    _ResolvedGridLine resolved,
  ) {
    final paint = Paint()
      ..color = resolved.color
      ..strokeWidth = resolved.width;

    for (final x in positions) {
      if (x < bounds.left || x > bounds.right) continue;
      final start = Offset(x, bounds.top);
      final end = Offset(x, bounds.bottom);
      if (resolved.dash != null && resolved.dash!.isNotEmpty) {
        _drawDashedLine(canvas, start, end, paint, resolved.dash!);
      } else {
        canvas.drawLine(start, end, paint);
      }
    }
  }

  /// Draws a dashed line from [start] to [end] using the [dashPattern].
  ///
  /// The pattern alternates between dash length and gap length.
  static void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    List<double> dashPattern,
  ) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final totalLength = Offset(dx, dy).distance;
    if (totalLength == 0) return;

    final unitDx = dx / totalLength;
    final unitDy = dy / totalLength;

    var travelled = 0.0;
    var dashIndex = 0;
    var drawing = true;

    while (travelled < totalLength) {
      final segmentLength = dashPattern[dashIndex % dashPattern.length];
      final remaining = totalLength - travelled;
      final length = segmentLength < remaining ? segmentLength : remaining;

      if (drawing) {
        final segStart = Offset(
          start.dx + unitDx * travelled,
          start.dy + unitDy * travelled,
        );
        final segEnd = Offset(
          start.dx + unitDx * (travelled + length),
          start.dy + unitDy * (travelled + length),
        );
        canvas.drawLine(segStart, segEnd, paint);
      }

      travelled += length;
      dashIndex++;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(covariant OiChartGridPainter oldPainter) {
    return !listEquals(oldPainter.horizontalPositions, horizontalPositions) ||
        !listEquals(oldPainter.verticalPositions, verticalPositions) ||
        !listEquals(
          oldPainter.minorHorizontalPositions,
          minorHorizontalPositions,
        ) ||
        !listEquals(
          oldPainter.minorVerticalPositions,
          minorVerticalPositions,
        ) ||
        oldPainter.majorHorizontal != majorHorizontal ||
        oldPainter.majorVertical != majorVertical ||
        oldPainter.minorHorizontal != minorHorizontal ||
        oldPainter.minorVertical != minorVertical ||
        oldPainter.themeGrid != themeGrid;
  }
}

/// Resolved (non-nullable) grid line appearance.
@immutable
class _ResolvedGridLine {
  const _ResolvedGridLine({
    required this.color,
    required this.width,
    this.dash,
  });

  final Color color;
  final double width;
  final List<double>? dash;
}
