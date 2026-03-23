import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_canvas.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_chart_theme_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Label Overflow Strategy
// ─────────────────────────────────────────────────────────────────────────────

/// Strategy for handling label text that would overlap or overflow.
///
/// {@category Foundation}
enum OiChartLabelOverflow {
  /// Rotate labels by a configurable angle (default 45°).
  rotate,

  /// Truncate labels with an ellipsis to fit the available space.
  truncate,

  /// Skip (hide) labels that would overlap with their neighbours.
  skip,
}

// ─────────────────────────────────────────────────────────────────────────────
// Axis Edge
// ─────────────────────────────────────────────────────────────────────────────

/// Which edge of the plot area an axis is rendered on.
///
/// {@category Foundation}
enum OiChartAxisEdge {
  /// Bottom edge — typically the x-axis.
  bottom,

  /// Left edge — typically the y-axis.
  left,

  /// Top edge — secondary x-axis.
  top,

  /// Right edge — secondary y-axis.
  right,
}

// ─────────────────────────────────────────────────────────────────────────────
// OiChartAxisPainter
// ─────────────────────────────────────────────────────────────────────────────

/// A chart layer painter that renders an axis line and tick marks along one
/// edge of the plot area.
///
/// The painter draws:
/// 1. A continuous axis line along the specified [edge].
/// 2. Tick marks at the given [tickPositions] (pixel coordinates along the
///    axis).
///
/// Visual tokens (color, width, tick length) fall back to [themeAxis] when
/// not explicitly set.
///
/// {@category Foundation}
class OiChartAxisPainter extends OiChartLayerPainter {
  /// Creates an [OiChartAxisPainter].
  OiChartAxisPainter({
    required this.edge,
    this.tickPositions = const [],
    this.lineColor,
    this.lineWidth,
    this.tickColor,
    this.tickLength,
    this.tickWidth,
    this.themeAxis,
  });

  /// Which edge of the plot area this axis sits on.
  final OiChartAxisEdge edge;

  /// Pixel positions of each tick mark along the axis.
  ///
  /// For [OiChartAxisEdge.bottom] / [OiChartAxisEdge.top] these are
  /// x-coordinates; for [OiChartAxisEdge.left] / [OiChartAxisEdge.right]
  /// these are y-coordinates.
  final List<double> tickPositions;

  /// Axis line color override.
  final Color? lineColor;

  /// Axis line width override.
  final double? lineWidth;

  /// Tick mark color override.
  final Color? tickColor;

  /// Tick mark length override (how far it protrudes from the axis).
  final double? tickLength;

  /// Tick mark stroke width override.
  final double? tickWidth;

  /// Optional theme tokens for fallback styling.
  final OiChartAxisTheme? themeAxis;

  // ── Defaults ──────────────────────────────────────────────────────────

  static const Color _fallbackColor = Color(0xFF9E9E9E);
  static const double _fallbackLineWidth = 1.0;
  static const double _fallbackTickLength = 6.0;
  static const double _fallbackTickWidth = 1.0;

  // ── Painting ──────────────────────────────────────────────────────────

  @override
  void paint(OiChartCanvasContext context) {
    final bounds = context.plotBounds;
    final resolvedLineColor = lineColor ?? themeAxis?.lineColor ?? _fallbackColor;
    final resolvedLineWidth = lineWidth ?? themeAxis?.lineWidth ?? _fallbackLineWidth;
    final resolvedTickColor = tickColor ?? themeAxis?.tickColor ?? resolvedLineColor;
    final resolvedTickLength = tickLength ?? themeAxis?.tickLength ?? _fallbackTickLength;
    final resolvedTickWidth = tickWidth ?? themeAxis?.tickWidth ?? _fallbackTickWidth;

    final linePaint = Paint()
      ..color = resolvedLineColor
      ..strokeWidth = resolvedLineWidth;

    final tickPaint = Paint()
      ..color = resolvedTickColor
      ..strokeWidth = resolvedTickWidth;

    // Draw axis line.
    switch (edge) {
      case OiChartAxisEdge.bottom:
        canvas_drawAxisLine(context.canvas, linePaint,
          Offset(bounds.left, bounds.bottom),
          Offset(bounds.right, bounds.bottom),
        );
        for (final x in tickPositions) {
          context.canvas.drawLine(
            Offset(x, bounds.bottom),
            Offset(x, bounds.bottom + resolvedTickLength),
            tickPaint,
          );
        }
      case OiChartAxisEdge.top:
        canvas_drawAxisLine(context.canvas, linePaint,
          Offset(bounds.left, bounds.top),
          Offset(bounds.right, bounds.top),
        );
        for (final x in tickPositions) {
          context.canvas.drawLine(
            Offset(x, bounds.top),
            Offset(x, bounds.top - resolvedTickLength),
            tickPaint,
          );
        }
      case OiChartAxisEdge.left:
        canvas_drawAxisLine(context.canvas, linePaint,
          Offset(bounds.left, bounds.top),
          Offset(bounds.left, bounds.bottom),
        );
        for (final y in tickPositions) {
          context.canvas.drawLine(
            Offset(bounds.left, y),
            Offset(bounds.left - resolvedTickLength, y),
            tickPaint,
          );
        }
      case OiChartAxisEdge.right:
        canvas_drawAxisLine(context.canvas, linePaint,
          Offset(bounds.right, bounds.top),
          Offset(bounds.right, bounds.bottom),
        );
        for (final y in tickPositions) {
          context.canvas.drawLine(
            Offset(bounds.right, y),
            Offset(bounds.right + resolvedTickLength, y),
            tickPaint,
          );
        }
    }
  }

  /// Helper that draws the axis line.
  static void canvas_drawAxisLine(Canvas canvas, Paint paint, Offset a, Offset b) {
    canvas.drawLine(a, b, paint);
  }

  @override
  bool shouldRepaint(covariant OiChartAxisPainter oldPainter) {
    return oldPainter.edge != edge ||
        !listEquals(oldPainter.tickPositions, tickPositions) ||
        oldPainter.lineColor != lineColor ||
        oldPainter.lineWidth != lineWidth ||
        oldPainter.tickColor != tickColor ||
        oldPainter.tickLength != tickLength ||
        oldPainter.tickWidth != tickWidth ||
        oldPainter.themeAxis != themeAxis;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OiChartLabelPainter
// ─────────────────────────────────────────────────────────────────────────────

/// A chart layer painter that renders axis labels alongside tick marks.
///
/// Labels are positioned at the [tickPositions] along the given [edge] of
/// the plot area. The painter handles overflow via [overflow] and supports
/// responsive density reduction via [maxVisibleTicks].
///
/// ## Text Layout Caching
///
/// Internally, [TextPainter] instances are cached by label string so that
/// repeated identical labels (e.g. category names that appear on every
/// frame during animation) are not re-laid-out.
///
/// ## Responsive Density Reduction
///
/// When [maxVisibleTicks] is set (as an [OiResponsive<int>]) and the
/// resolved value is less than the number of labels, the painter evenly
/// skips labels to keep the count within the limit.
///
/// {@category Foundation}
class OiChartLabelPainter extends OiChartLayerPainter {
  /// Creates an [OiChartLabelPainter].
  OiChartLabelPainter({
    required this.edge,
    required this.labels,
    required this.tickPositions,
    this.labelStyle,
    this.labelColor,
    this.overflow = OiChartLabelOverflow.skip,
    this.rotationDegrees = 45,
    this.maxLabelWidth = 80,
    this.labelGap = 4.0,
    this.maxVisibleTicks,
    this.activeBreakpoint,
    this.breakpointScale,
    this.themeAxis,
  });

  /// Which edge of the plot area labels sit beside.
  final OiChartAxisEdge edge;

  /// The label strings, one per tick.
  final List<String> labels;

  /// Pixel positions of each tick (same coordinate system as
  /// [OiChartAxisPainter.tickPositions]).
  final List<double> tickPositions;

  /// Text style for labels.
  final TextStyle? labelStyle;

  /// Color override applied on top of [labelStyle].
  final Color? labelColor;

  /// How to handle labels that overflow or overlap.
  final OiChartLabelOverflow overflow;

  /// Rotation angle in degrees when [overflow] is [OiChartLabelOverflow.rotate].
  final double rotationDegrees;

  /// Maximum width for a single label before truncation is applied.
  final double maxLabelWidth;

  /// Gap between the axis edge and the nearest label edge.
  final double labelGap;

  /// Responsive maximum number of visible ticks / labels.
  ///
  /// When set, the resolved value limits how many labels are painted.
  /// Labels are evenly distributed (every Nth label) to meet the limit.
  final OiResponsive<int>? maxVisibleTicks;

  /// The active breakpoint used to resolve [maxVisibleTicks].
  final OiBreakpoint? activeBreakpoint;

  /// The breakpoint scale used to resolve [maxVisibleTicks].
  final OiBreakpointScale? breakpointScale;

  /// Optional theme tokens for fallback styling.
  final OiChartAxisTheme? themeAxis;

  // ── Text layout cache ─────────────────────────────────────────────────

  /// Cache of laid-out [TextPainter]s keyed by (label string, effective style).
  ///
  /// This avoids re-creating and re-laying-out text painters for identical
  /// labels across repaint frames.
  static final Map<_TextCacheKey, TextPainter> _textCache = {};

  /// Maximum cache entries before eviction.
  static const int _maxCacheSize = 512;

  // ── Painting ──────────────────────────────────────────────────────────

  @override
  void paint(OiChartCanvasContext context) {
    if (labels.isEmpty || tickPositions.isEmpty) return;

    final bounds = context.plotBounds;
    final effectiveStyle = _resolveStyle();

    // Determine which indices to paint.
    final count = math.min(labels.length, tickPositions.length);
    final visibleIndices = _computeVisibleIndices(count);

    // Prepare text painters for visible labels.
    final painters = <int, TextPainter>{};
    for (final i in visibleIndices) {
      painters[i] = _getOrCreateTextPainter(labels[i], effectiveStyle);
    }

    // Apply overflow handling and paint.
    switch (overflow) {
      case OiChartLabelOverflow.rotate:
        _paintRotated(context.canvas, bounds, painters, visibleIndices);
      case OiChartLabelOverflow.truncate:
        _paintTruncated(
          context.canvas, bounds, painters, visibleIndices, effectiveStyle,
        );
      case OiChartLabelOverflow.skip:
        _paintWithSkipping(context.canvas, bounds, painters, visibleIndices);
    }
  }

  TextStyle _resolveStyle() {
    var style = labelStyle ??
        themeAxis?.labelStyle ??
        const TextStyle(fontSize: 11);
    final color = labelColor ?? themeAxis?.labelColor;
    if (color != null) {
      style = style.copyWith(color: color);
    }
    return style;
  }

  List<int> _computeVisibleIndices(int totalCount) {
    if (maxVisibleTicks == null) {
      return List.generate(totalCount, (i) => i);
    }

    final bp = activeBreakpoint ?? OiBreakpoint.compact;
    final scale = breakpointScale ?? OiBreakpointScale.defaultScale;
    final maxTicks = maxVisibleTicks!.resolve(bp, scale);

    if (maxTicks >= totalCount) {
      return List.generate(totalCount, (i) => i);
    }
    if (maxTicks <= 0) return const [];

    // Always include first and last, then evenly distribute the rest.
    if (maxTicks == 1) return [0];
    if (maxTicks == 2) return [0, totalCount - 1];

    final indices = <int>[0];
    final step = (totalCount - 1) / (maxTicks - 1);
    for (var i = 1; i < maxTicks - 1; i++) {
      indices.add((i * step).round());
    }
    indices.add(totalCount - 1);
    return indices;
  }

  TextPainter _getOrCreateTextPainter(String text, TextStyle style) {
    final key = _TextCacheKey(text, style);
    final cached = _textCache[key];
    if (cached != null) return cached;

    // Evict oldest entries if cache is full.
    if (_textCache.length >= _maxCacheSize) {
      final keysToRemove = _textCache.keys
          .take(_textCache.length ~/ 4)
          .toList();
      for (final k in keysToRemove) {
        _textCache[k]?.dispose();
        _textCache.remove(k);
      }
    }

    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxLabelWidth);
    _textCache[key] = tp;
    return tp;
  }

  /// Clears the shared text layout cache.
  ///
  /// Call this when the theme changes or on hot-reload to free memory.
  static void clearCache() {
    for (final tp in _textCache.values) {
      tp.dispose();
    }
    _textCache.clear();
  }

  // ── Painting strategies ───────────────────────────────────────────────

  void _paintRotated(
    Canvas canvas, Rect bounds,
    Map<int, TextPainter> painters, List<int> indices,
  ) {
    final radians = rotationDegrees * math.pi / 180;

    for (final i in indices) {
      final tp = painters[i]!;
      final pos = tickPositions[i];
      final anchor = _labelAnchor(bounds, pos);

      canvas.save();
      canvas.translate(anchor.dx, anchor.dy);
      canvas.rotate(
        edge == OiChartAxisEdge.bottom || edge == OiChartAxisEdge.top
            ? -radians
            : radians,
      );
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  void _paintTruncated(
    Canvas canvas, Rect bounds,
    Map<int, TextPainter> painters, List<int> indices,
    TextStyle style,
  ) {
    // TextPainter already handles ellipsis via maxWidth.
    for (final i in indices) {
      final tp = painters[i]!;
      final pos = tickPositions[i];
      final anchor = _labelAnchor(bounds, pos);
      final offset = _labelOffset(anchor, tp);
      tp.paint(canvas, offset);
    }
  }

  void _paintWithSkipping(
    Canvas canvas, Rect bounds,
    Map<int, TextPainter> painters, List<int> indices,
  ) {
    // Paint only labels whose bounding boxes don't overlap with the
    // previously painted label.
    Rect? lastPaintedRect;

    for (final i in indices) {
      final tp = painters[i]!;
      final pos = tickPositions[i];
      final anchor = _labelAnchor(bounds, pos);
      final offset = _labelOffset(anchor, tp);
      final labelRect = offset & Size(tp.width, tp.height);

      if (lastPaintedRect != null && lastPaintedRect.overlaps(labelRect)) {
        continue; // Skip overlapping label.
      }

      tp.paint(canvas, offset);
      lastPaintedRect = labelRect;
    }
  }

  /// Returns the anchor point (center of where the label should be placed)
  /// in widget-local coordinates.
  Offset _labelAnchor(Rect bounds, double pos) {
    return switch (edge) {
      OiChartAxisEdge.bottom => Offset(pos, bounds.bottom + labelGap),
      OiChartAxisEdge.top => Offset(pos, bounds.top - labelGap),
      OiChartAxisEdge.left => Offset(bounds.left - labelGap, pos),
      OiChartAxisEdge.right => Offset(bounds.right + labelGap, pos),
    };
  }

  /// Computes the top-left offset for painting, given the anchor.
  Offset _labelOffset(Offset anchor, TextPainter tp) {
    return switch (edge) {
      OiChartAxisEdge.bottom => Offset(anchor.dx - tp.width / 2, anchor.dy),
      OiChartAxisEdge.top => Offset(anchor.dx - tp.width / 2, anchor.dy - tp.height),
      OiChartAxisEdge.left => Offset(anchor.dx - tp.width, anchor.dy - tp.height / 2),
      OiChartAxisEdge.right => Offset(anchor.dx, anchor.dy - tp.height / 2),
    };
  }

  @override
  bool shouldRepaint(covariant OiChartLabelPainter oldPainter) {
    return oldPainter.edge != edge ||
        !listEquals(oldPainter.labels, labels) ||
        !listEquals(oldPainter.tickPositions, tickPositions) ||
        oldPainter.labelStyle != labelStyle ||
        oldPainter.labelColor != labelColor ||
        oldPainter.overflow != overflow ||
        oldPainter.rotationDegrees != rotationDegrees ||
        oldPainter.maxLabelWidth != maxLabelWidth ||
        oldPainter.labelGap != labelGap ||
        oldPainter.maxVisibleTicks != maxVisibleTicks ||
        oldPainter.activeBreakpoint != activeBreakpoint ||
        oldPainter.themeAxis != themeAxis;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Text Cache Key
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class _TextCacheKey {
  const _TextCacheKey(this.text, this.style);

  final String text;
  final TextStyle style;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TextCacheKey && other.text == text && other.style == style;

  @override
  int get hashCode => Object.hash(text, style);
}
