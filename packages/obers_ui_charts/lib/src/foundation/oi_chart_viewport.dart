import 'dart:ui' show Offset, Rect, Size;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show EdgeInsets;

/// Normalized geometry contract for all chart types.
///
/// [OiChartViewport] encapsulates the plot area bounds, padding, axis
/// insets, visible domain, device pixel ratio, and coordinate conversion
/// needed by every chart renderer.
///
/// Charts create a viewport from their layout constraints, then pass it
/// to painters, hit-testers, and annotation layers so that all rendering
/// is consistent regardless of chart type.
///
/// ```dart
/// final viewport = OiChartViewport(
///   size: Size(400, 300),
///   padding: EdgeInsets.all(16),
///   axisInsets: OiAxisInsets(left: 40, bottom: 24),
///   devicePixelRatio: 2.0,
/// );
/// // The plot area is 400 - 16*2 - 40 = 312 wide
/// // and 300 - 16*2 - 24 = 228 tall.
/// ```
///
/// {@category Foundation}
@immutable
class OiChartViewport {
  /// Creates an [OiChartViewport].
  const OiChartViewport({
    required this.size,
    this.padding = EdgeInsets.zero,
    this.axisInsets = const OiAxisInsets(),
    this.devicePixelRatio = 1.0,
    this.visibleDomain,
    this.zoomLevel = 1.0,
    this.panOffset = Offset.zero,
  });

  /// The total size of the chart widget in logical pixels.
  final Size size;

  /// Outer padding around the entire chart (including axis labels).
  final EdgeInsets padding;

  /// Space reserved for axis labels and ticks inside the padded area.
  final OiAxisInsets axisInsets;

  /// The device pixel ratio for crisp rendering on high-DPI screens.
  final double devicePixelRatio;

  /// An optional visible domain rectangle in data coordinates.
  ///
  /// When non-null, only data within this rectangle is rendered.
  /// Used for zoom/pan to restrict the visible data window.
  final Rect? visibleDomain;

  /// The current zoom level. 1.0 means no zoom.
  final double zoomLevel;

  /// The current pan offset in logical pixels, relative to the plot
  /// area origin.
  final Offset panOffset;

  // ── Visible domain ranges ───────────────────────────────────────────

  /// The visible x-domain range as (min, max), or null if not zoomed.
  ({double min, double max})? get visibleDomainX {
    final vd = visibleDomain;
    if (vd == null) return null;
    return (min: vd.left, max: vd.right);
  }

  /// The visible y-domain range as (min, max), or null if not zoomed.
  ({double min, double max})? get visibleDomainY {
    final vd = visibleDomain;
    if (vd == null) return null;
    return (min: vd.top, max: vd.bottom);
  }

  // ── Derived geometry ──────────────────────────────────────────────────

  /// The plot area bounds in widget-local coordinates.
  ///
  /// This is the region where data marks (bars, points, lines) are
  /// drawn, excluding padding and axis insets.
  Rect get plotBounds {
    final left = padding.left + axisInsets.left;
    final top = padding.top + axisInsets.top;
    final right = size.width - padding.right - axisInsets.right;
    final bottom = size.height - padding.bottom - axisInsets.bottom;
    return Rect.fromLTRB(left, top, right, bottom);
  }

  /// The width of the plot area in logical pixels.
  double get plotWidth => plotBounds.width;

  /// The height of the plot area in logical pixels.
  double get plotHeight => plotBounds.height;

  /// The width of the plot area in physical pixels.
  double get physicalPlotWidth => plotWidth * devicePixelRatio;

  /// The height of the plot area in physical pixels.
  double get physicalPlotHeight => plotHeight * devicePixelRatio;

  /// The full chart bounds in widget-local coordinates.
  Rect get chartBounds => Offset.zero & size;

  // ── Coordinate conversion ─────────────────────────────────────────────

  /// Converts a widget-local [point] to plot-area-relative coordinates.
  ///
  /// The returned offset has (0, 0) at the top-left of the plot area.
  /// Values outside the plot bounds are not clamped.
  Offset widgetToPlot(Offset point) {
    final pb = plotBounds;
    return Offset(
      (point.dx - pb.left - panOffset.dx) / zoomLevel,
      (point.dy - pb.top - panOffset.dy) / zoomLevel,
    );
  }

  /// Converts a plot-area-relative [point] to widget-local coordinates.
  Offset plotToWidget(Offset point) {
    final pb = plotBounds;
    return Offset(
      point.dx * zoomLevel + pb.left + panOffset.dx,
      point.dy * zoomLevel + pb.top + panOffset.dy,
    );
  }

  /// Converts a widget-local [point] to normalized (0–1) coordinates
  /// within the plot area.
  ///
  /// (0, 0) is the top-left of the plot area, (1, 1) is the
  /// bottom-right. Values outside 0–1 indicate points outside the
  /// plot area.
  Offset widgetToNormalized(Offset point) {
    final plotPoint = widgetToPlot(point);
    final pw = plotWidth / zoomLevel;
    final ph = plotHeight / zoomLevel;
    return Offset(
      pw == 0 ? 0 : plotPoint.dx / pw,
      ph == 0 ? 0 : plotPoint.dy / ph,
    );
  }

  /// Converts a normalized (0–1) [point] to widget-local coordinates.
  Offset normalizedToWidget(Offset point) {
    final pw = plotWidth / zoomLevel;
    final ph = plotHeight / zoomLevel;
    return plotToWidget(Offset(point.dx * pw, point.dy * ph));
  }

  /// Returns `true` if the widget-local [point] is inside the plot area.
  bool hitTestPlot(Offset point) => plotBounds.contains(point);

  /// Snaps a logical pixel [value] to the nearest physical pixel boundary
  /// for crisp rendering.
  double snapToPixel(double value) {
    return (value * devicePixelRatio).roundToDouble() / devicePixelRatio;
  }

  /// Snaps an [Offset] to the nearest physical pixel boundary.
  Offset snapOffsetToPixel(Offset offset) {
    return Offset(snapToPixel(offset.dx), snapToPixel(offset.dy));
  }

  // ── Zoom / Pan helpers ────────────────────────────────────────────────

  /// Returns a new viewport zoomed to [newZoom] centered on the
  /// widget-local [focalPoint].
  OiChartViewport zoomTo(double newZoom, {Offset? focalPoint}) {
    final focal = focalPoint ?? plotBounds.center;
    final pb = plotBounds;
    // Convert focal point to plot-relative position at current zoom.
    final plotFocal = Offset(
      (focal.dx - pb.left - panOffset.dx) / zoomLevel,
      (focal.dy - pb.top - panOffset.dy) / zoomLevel,
    );
    // Compute new pan so that the focal point stays fixed.
    final newPan = Offset(
      focal.dx - pb.left - plotFocal.dx * newZoom,
      focal.dy - pb.top - plotFocal.dy * newZoom,
    );
    return copyWith(zoomLevel: newZoom, panOffset: newPan);
  }

  /// Returns a new viewport panned by [delta] logical pixels.
  OiChartViewport panBy(Offset delta) {
    return copyWith(panOffset: panOffset + delta);
  }

  /// Returns a new viewport with zoom and pan reset to defaults.
  OiChartViewport resetTransform() {
    return copyWith(zoomLevel: 1, panOffset: Offset.zero);
  }

  // ── Copy ──────────────────────────────────────────────────────────────

  /// Creates a copy with optionally overridden values.
  OiChartViewport copyWith({
    Size? size,
    EdgeInsets? padding,
    OiAxisInsets? axisInsets,
    double? devicePixelRatio,
    Rect? visibleDomain,
    double? zoomLevel,
    Offset? panOffset,
  }) {
    return OiChartViewport(
      size: size ?? this.size,
      padding: padding ?? this.padding,
      axisInsets: axisInsets ?? this.axisInsets,
      devicePixelRatio: devicePixelRatio ?? this.devicePixelRatio,
      visibleDomain: visibleDomain ?? this.visibleDomain,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      panOffset: panOffset ?? this.panOffset,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiChartViewport &&
          other.size == size &&
          other.padding == padding &&
          other.axisInsets == axisInsets &&
          other.devicePixelRatio == devicePixelRatio &&
          other.visibleDomain == visibleDomain &&
          other.zoomLevel == zoomLevel &&
          other.panOffset == panOffset;

  @override
  int get hashCode => Object.hashAll([
    size,
    padding,
    axisInsets,
    devicePixelRatio,
    visibleDomain,
    zoomLevel,
    panOffset,
  ]);

  @override
  String toString() =>
      'OiChartViewport(size: $size, plotBounds: $plotBounds, '
      'zoom: $zoomLevel, pan: $panOffset)';
}

// ─────────────────────────────────────────────────────────────────────────────
// OiChartViewportState — mutable viewport state for zoom/pan
// ─────────────────────────────────────────────────────────────────────────────

/// Mutable viewport state tracking the current zoom and pan position.
///
/// Used by the chart controller to track the user-driven viewport
/// transformations. Unlike [OiChartViewport] (which is an immutable geometry
/// snapshot), this class is designed to be mutated and observed.
///
/// {@category Foundation}
class OiChartViewportState {
  /// Creates an [OiChartViewportState].
  OiChartViewportState({
    this.xMin,
    this.xMax,
    this.yMin,
    this.yMax,
    double zoomLevel = 1.0,
    this.panOffset = Offset.zero,
  }) : _zoomLevel = zoomLevel;

  /// The minimum visible x-domain value, or null for auto.
  double? xMin;

  /// The maximum visible x-domain value, or null for auto.
  double? xMax;

  /// The minimum visible y-domain value, or null for auto.
  double? yMin;

  /// The maximum visible y-domain value, or null for auto.
  double? yMax;

  double _zoomLevel;

  /// The current pan offset in logical pixels.
  Offset panOffset;

  /// The current zoom level. 1.0 means no zoom.
  double get zoomLevel => _zoomLevel;
  set zoomLevel(double value) {
    _zoomLevel = value.clamp(0.1, 100.0);
  }

  /// Whether the viewport is currently zoomed (not at default level).
  bool get isZoomed => _zoomLevel != 1.0 || panOffset != Offset.zero;

  /// Resets the viewport to its default state (no zoom, no pan, auto domain).
  void reset() {
    xMin = null;
    xMax = null;
    yMin = null;
    yMax = null;
    _zoomLevel = 1.0;
    panOffset = Offset.zero;
  }

  /// Creates a copy of this viewport state.
  OiChartViewportState copyWith({
    double? xMin,
    double? xMax,
    double? yMin,
    double? yMax,
    double? zoomLevel,
    Offset? panOffset,
  }) {
    return OiChartViewportState(
      xMin: xMin ?? this.xMin,
      xMax: xMax ?? this.xMax,
      yMin: yMin ?? this.yMin,
      yMax: yMax ?? this.yMax,
      zoomLevel: zoomLevel ?? _zoomLevel,
      panOffset: panOffset ?? this.panOffset,
    );
  }

  @override
  String toString() =>
      'OiChartViewportState(zoom: $_zoomLevel, pan: $panOffset, '
      'x: [$xMin, $xMax], y: [$yMin, $yMax])';
}

// ─────────────────────────────────────────────────────────────────────────────
// OiAxisInsets
// ─────────────────────────────────────────────────────────────────────────────

/// Space reserved for axis labels and tick marks inside the chart padding.
///
/// {@category Foundation}
@immutable
class OiAxisInsets {
  /// Creates [OiAxisInsets] with the given edge values.
  const OiAxisInsets({
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
  });

  /// Creates symmetric [OiAxisInsets].
  const OiAxisInsets.symmetric({double horizontal = 0, double vertical = 0})
    : left = horizontal,
      right = horizontal,
      top = vertical,
      bottom = vertical;

  /// Creates [OiAxisInsets] where all edges have the same [value].
  const OiAxisInsets.all(double value)
    : left = value,
      top = value,
      right = value,
      bottom = value;

  /// Space reserved on the left for the y-axis labels.
  final double left;

  /// Space reserved on the top (e.g. for a secondary axis).
  final double top;

  /// Space reserved on the right (e.g. for a secondary y-axis).
  final double right;

  /// Space reserved on the bottom for the x-axis labels.
  final double bottom;

  /// The total horizontal insets.
  double get horizontal => left + right;

  /// The total vertical insets.
  double get vertical => top + bottom;

  /// Creates a copy with optionally overridden values.
  OiAxisInsets copyWith({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return OiAxisInsets(
      left: left ?? this.left,
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiAxisInsets &&
          other.left == left &&
          other.top == top &&
          other.right == right &&
          other.bottom == bottom;

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() => 'OiAxisInsets(l: $left, t: $top, r: $right, b: $bottom)';
}
