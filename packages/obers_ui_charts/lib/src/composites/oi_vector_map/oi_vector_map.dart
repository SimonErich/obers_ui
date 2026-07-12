import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/components/oi_chart_empty_state.dart';
import 'package:obers_ui_charts/src/components/oi_chart_tooltip_widget.dart';
import 'package:obers_ui_charts/src/composites/oi_vector_map/oi_vector_map_data.dart';
import 'package:obers_ui_charts/src/composites/oi_vector_map/oi_vector_map_painter.dart';
import 'package:obers_ui_charts/src/composites/oi_vector_map/oi_vector_map_projection.dart';
import 'package:obers_ui_charts/src/composites/oi_vector_map/oi_world_map.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_tooltip.dart';
import 'package:obers_ui_charts/src/models/oi_color_scale.dart';

/// Formats a region or marker value for display in the tooltip and legend.
///
/// {@category Composites}
typedef OiMapValueFormatter = String Function(num value);

// ─────────────────────────────────────────────────────────────────────────────
// OiVectorMap
// ─────────────────────────────────────────────────────────────────────────────

/// A vector world/region map for dashboards.
///
/// `OiVectorMap` renders geographic [regions] as filled, outlined polygons
/// and/or [markers] as sized bubbles, combining two visualization modes:
///
/// - **Choropleth** — each region is filled by mapping its
///   [OiMapRegion.value] through a sequential [colorScale] derived from the
///   theme. Regions without a value use a neutral fill. Supply [values] to
///   attach numbers to the bundled [OiWorldMap.regions] by ISO code, or pass
///   fully custom [regions] with their own geometry and values.
/// - **Bubble / marker** — [markers] are drawn as circles whose *area* is
///   proportional to [OiMapMarker.value] (radius scales with the square
///   root of the value), painted above the base map.
///
/// With no [regions] argument the bundled low-resolution world map is used,
/// so a world choropleth needs only a [values] map:
///
/// ```dart
/// OiVectorMap(
///   label: 'Active users by country',
///   values: {'US': 1240, 'DE': 830, 'BR': 410},
///   showLegend: true,
/// )
/// ```
///
/// Geometry is painted by a single [OiVectorMapPainter] with paths built
/// once per region set and reused across frames; hit-testing uses the same
/// cached paths.
///
/// {@category Composites}
class OiVectorMap extends StatefulWidget {
  /// Creates an [OiVectorMap].
  ///
  /// When [regions] is `null`, the bundled [OiWorldMap.regions] are used.
  const OiVectorMap({
    required this.label,
    super.key,
    this.regions,
    this.values,
    this.markers = const [],
    this.projection = const OiEquirectangularProjection(),
    this.colorScale,
    this.minValue,
    this.maxValue,
    this.neutralColor,
    this.markerColor,
    this.maxMarkerRadiusInPixels = 26,
    this.valueLabel = 'Value',
    this.valueFormatter,
    this.showTooltip = true,
    this.showLegend = false,
    this.enableZoom = false,
    this.minZoomScale = 1,
    this.maxZoomScale = 8,
    this.onRegionTap,
    this.onMarkerTap,
    this.emptyState,
    this.semanticLabel,
  });

  /// The accessibility label describing the map's data.
  final String label;

  /// The regions to render. When `null`, [OiWorldMap.regions] is used.
  final List<OiMapRegion>? regions;

  /// Optional values keyed by [OiMapRegion.id] (e.g. ISO alpha-2 code).
  ///
  /// When provided, each matching region is filled by its value, taking
  /// precedence over any [OiMapRegion.value] already on the region.
  final Map<String, num>? values;

  /// The bubble markers drawn above the base map.
  final List<OiMapMarker> markers;

  /// The projection converting latitude/longitude to normalized map space.
  final OiMapProjection projection;

  /// An optional custom color scale for choropleth fills.
  ///
  /// When `null`, a sequential scale between the theme's light and dark
  /// primary tints is derived over the effective value domain.
  final OiColorScale? colorScale;

  /// Overrides the low end of the choropleth domain. When `null`, the
  /// minimum region value is used.
  final double? minValue;

  /// Overrides the high end of the choropleth domain. When `null`, the
  /// maximum region value is used.
  final double? maxValue;

  /// The fill color for regions without a value. Defaults to a muted
  /// theme surface.
  final Color? neutralColor;

  /// The default bubble color. Defaults to the theme accent color.
  final Color? markerColor;

  /// The radius in logical pixels of the largest bubble.
  final double maxMarkerRadiusInPixels;

  /// The label shown before the value in the tooltip (e.g. `'Users'`).
  final String valueLabel;

  /// Formats values for the tooltip and legend. When `null`, a compact
  /// default formatter is used.
  final OiMapValueFormatter? valueFormatter;

  /// Whether to show a tooltip on hover/tap.
  final bool showTooltip;

  /// Whether to show a min→max gradient legend below the map.
  final bool showLegend;

  /// Whether to enable pinch/scroll zoom and drag pan.
  final bool enableZoom;

  /// The minimum zoom scale when [enableZoom] is `true`.
  final double minZoomScale;

  /// The maximum zoom scale when [enableZoom] is `true`.
  final double maxZoomScale;

  /// Called when a region is tapped.
  final ValueChanged<OiMapRegion>? onRegionTap;

  /// Called when a marker is tapped.
  final ValueChanged<OiMapMarker>? onMarkerTap;

  /// Widget shown when there are no regions and no markers. Defaults to a
  /// neutral base map.
  final Widget? emptyState;

  /// Overrides the semantic label. Defaults to [label].
  final String? semanticLabel;

  @override
  State<OiVectorMap> createState() => _OiVectorMapState();
}

class _OiVectorMapState extends State<OiVectorMap> {
  final GlobalKey _boxKey = GlobalKey();

  _MapCache? _cache;
  String? _hoveredRegionId;
  int? _hoveredMarkerIndex;
  Offset? _tooltipAnchor;
  OiChartTooltipModel? _tooltipModel;

  List<OiMapRegion> get _effectiveRegions {
    final source = widget.regions ?? OiWorldMap.regions;
    final values = widget.values;
    if (values == null || values.isEmpty) return source;
    return [
      for (final region in source)
        values.containsKey(region.id)
            ? region.withValue(values[region.id])
            : region,
    ];
  }

  String _formatValue(num value) {
    final formatter = widget.valueFormatter;
    if (formatter != null) return formatter(value);
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(1);
  }

  // ── Choropleth domain & scale ──────────────────────────────────────────────

  (double, double) _domain(List<OiMapRegion> regions) {
    var min = double.infinity;
    var max = double.negativeInfinity;
    for (final region in regions) {
      final value = region.value;
      if (value == null) continue;
      final v = value.toDouble();
      if (v < min) min = v;
      if (v > max) max = v;
    }
    if (min == double.infinity) return (0, 1);
    if (min == max) return (min, max == 0 ? 1 : max);
    return (min, max);
  }

  OiColorScale _resolveScale(
    OiColorScheme colors,
    double domainMin,
    double domainMax,
  ) {
    return widget.colorScale ??
        OiColorScale.linear(
          minColor: colors.primary.light,
          maxColor: colors.primary.dark,
          min: widget.minValue ?? domainMin,
          max: widget.maxValue ?? domainMax,
        );
  }

  // ── Render cache ────────────────────────────────────────────────────────────

  _MapCache _buildCache({
    required List<OiMapRegion> regions,
    required Rect mapRect,
    required OiColorScale scale,
    required Color neutralColor,
    required Color markerColor,
  }) {
    final signature = _CacheSignature(
      regions: regions,
      markers: widget.markers,
      mapRect: mapRect,
      projection: widget.projection,
      scale: scale,
      neutralColor: neutralColor,
      markerColor: markerColor,
      maxMarkerRadius: widget.maxMarkerRadiusInPixels,
    );
    final existing = _cache;
    if (existing != null && existing.signature == signature) return existing;

    final cache = _MapCache(
      signature: signature,
      shapes: OiVectorMapGeometry.buildRegionShapes(
        regions: regions,
        projection: widget.projection,
        mapRect: mapRect,
        colorScale: scale,
        neutralColor: neutralColor,
      ),
      markerPoints: OiVectorMapGeometry.buildMarkerPoints(
        markers: widget.markers,
        projection: widget.projection,
        mapRect: mapRect,
        maxRadiusInPixels: widget.maxMarkerRadiusInPixels,
        defaultColor: markerColor,
      ),
    );
    _cache = cache;
    return cache;
  }

  // ── Hit testing ─────────────────────────────────────────────────────────────

  int? _hitMarker(_MapCache cache, Offset scenePoint) {
    for (var i = cache.markerPoints.length - 1; i >= 0; i--) {
      final point = cache.markerPoints[i];
      if ((point.center - scenePoint).distance <= point.radiusInPixels) {
        return i;
      }
    }
    return null;
  }

  OiVectorMapRegionShape? _hitRegion(_MapCache cache, Offset scenePoint) {
    for (final shape in cache.shapes) {
      if (shape.path.contains(scenePoint)) return shape;
    }
    return null;
  }

  void _updateHover(_MapCache cache, PointerEvent event) {
    if (!widget.showTooltip &&
        widget.onRegionTap == null &&
        widget.onMarkerTap == null) {
      return;
    }
    final scenePoint = event.localPosition;
    final markerIndex = _hitMarker(cache, scenePoint);
    final region = markerIndex == null ? _hitRegion(cache, scenePoint) : null;
    final anchor = _toBoxLocal(event.position);

    OiChartTooltipModel? model;
    if (widget.showTooltip && anchor != null) {
      if (markerIndex != null) {
        final marker = cache.markerPoints[markerIndex].marker;
        model = _tooltip(anchor, event.position, marker.label, marker.value);
      } else if (region != null) {
        model = _tooltip(
          anchor,
          event.position,
          region.region.label,
          region.region.value,
        );
      }
    }

    final regionId = region?.region.id;
    if (regionId == _hoveredRegionId &&
        markerIndex == _hoveredMarkerIndex &&
        model?.globalPosition == _tooltipModel?.globalPosition) {
      return;
    }
    setState(() {
      _hoveredRegionId = regionId;
      _hoveredMarkerIndex = markerIndex;
      _tooltipAnchor = anchor;
      _tooltipModel = model;
    });
  }

  void _clearHover() {
    if (_hoveredRegionId == null &&
        _hoveredMarkerIndex == null &&
        _tooltipModel == null) {
      return;
    }
    setState(() {
      _hoveredRegionId = null;
      _hoveredMarkerIndex = null;
      _tooltipModel = null;
      _tooltipAnchor = null;
    });
  }

  void _handleTap(_MapCache cache, Offset scenePoint) {
    final markerIndex = _hitMarker(cache, scenePoint);
    if (markerIndex != null) {
      widget.onMarkerTap?.call(cache.markerPoints[markerIndex].marker);
      return;
    }
    final region = _hitRegion(cache, scenePoint);
    if (region != null) widget.onRegionTap?.call(region.region);
  }

  OiChartTooltipModel _tooltip(
    Offset anchor,
    Offset global,
    String title,
    num? value,
  ) {
    return OiChartTooltipModel(
      globalPosition: global,
      title: title,
      entries: value == null
          ? const <OiChartTooltipEntry>[]
          : [
              OiChartTooltipEntry(
                seriesLabel: widget.valueLabel,
                formattedX: '',
                formattedY: _formatValue(value),
              ),
            ],
    );
  }

  Offset? _toBoxLocal(Offset global) {
    final renderObject = _boxKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return null;
    return renderObject.globalToLocal(global);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveLabel = widget.semanticLabel ?? widget.label;
    final regions = _effectiveRegions;

    if (regions.isEmpty && widget.markers.isEmpty) {
      return Semantics(
        label: effectiveLabel,
        child: KeyedSubtree(
          key: const Key('oi_vector_map_empty'),
          child: widget.emptyState ?? const OiChartEmptyState(),
        ),
      );
    }

    final neutralColor = widget.neutralColor ?? colors.surfaceHover;
    final markerColor = widget.markerColor ?? colors.accent.base;
    final (domainMin, domainMax) = _domain(regions);
    final scale = _resolveScale(colors, domainMin, domainMax);

    return Semantics(
      label: effectiveLabel,
      child: Column(
        key: _boxKey,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.hasBoundedHeight
                    ? constraints.maxHeight
                    : width / widget.projection.aspectRatio;
                final size = Size(width, height);
                final mapRect = OiVectorMapGeometry.fitMapRect(
                  size,
                  widget.projection.aspectRatio,
                );
                final cache = _buildCache(
                  regions: regions,
                  mapRect: mapRect,
                  scale: scale,
                  neutralColor: neutralColor,
                  markerColor: markerColor,
                );

                return SizedBox(
                  width: width,
                  height: height,
                  child: Stack(
                    key: const Key('oi_vector_map'),
                    children: [
                      Positioned.fill(child: _buildInteractive(cache, size)),
                      if (widget.showTooltip &&
                          _tooltipModel != null &&
                          _tooltipAnchor != null)
                        _buildTooltip(size),
                    ],
                  ),
                );
              },
            ),
          ),
          if (widget.showLegend && _hasValues(regions))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _OiVectorMapLegend(
                scale: scale,
                minLabel: _formatValue(widget.minValue ?? domainMin),
                maxLabel: _formatValue(widget.maxValue ?? domainMax),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInteractive(_MapCache cache, Size size) {
    final map = MouseRegion(
      onHover: (event) => _updateHover(cache, event),
      onExit: (_) => _clearHover(),
      child: GestureDetector(
        onTapUp: (details) => _handleTap(cache, details.localPosition),
        child: CustomPaint(
          key: const Key('oi_vector_map_painter'),
          size: size,
          painter: OiVectorMapPainter(
            shapes: cache.shapes,
            markerPoints: cache.markerPoints,
            borderColor: context.colors.border,
            highlightColor: context.colors.text,
            hoveredRegionId: _hoveredRegionId,
            hoveredMarkerIndex: _hoveredMarkerIndex,
          ),
        ),
      ),
    );

    if (!widget.enableZoom) return map;
    return InteractiveViewer(
      minScale: widget.minZoomScale,
      maxScale: widget.maxZoomScale,
      child: map,
    );
  }

  Widget _buildTooltip(Size size) {
    final anchor = _tooltipAnchor!;
    const tooltipWidth = 200.0;
    final left = (anchor.dx + 12).clamp(0.0, size.width - tooltipWidth);
    final top = (anchor.dy + 12).clamp(0.0, size.height - 40);
    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: OiChartTooltipWidget(
          key: const Key('oi_vector_map_tooltip'),
          model: _tooltipModel!,
        ),
      ),
    );
  }

  bool _hasValues(List<OiMapRegion> regions) {
    for (final region in regions) {
      if (region.value != null) return true;
    }
    return false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Render cache
// ─────────────────────────────────────────────────────────────────────────────

class _MapCache {
  const _MapCache({
    required this.signature,
    required this.shapes,
    required this.markerPoints,
  });

  final _CacheSignature signature;
  final List<OiVectorMapRegionShape> shapes;
  final List<OiVectorMapMarkerPoint> markerPoints;
}

@immutable
class _CacheSignature {
  const _CacheSignature({
    required this.regions,
    required this.markers,
    required this.mapRect,
    required this.projection,
    required this.scale,
    required this.neutralColor,
    required this.markerColor,
    required this.maxMarkerRadius,
  });

  final List<OiMapRegion> regions;
  final List<OiMapMarker> markers;
  final Rect mapRect;
  final OiMapProjection projection;
  final OiColorScale scale;
  final Color neutralColor;
  final Color markerColor;
  final double maxMarkerRadius;

  @override
  bool operator ==(Object other) {
    return other is _CacheSignature &&
        identical(other.regions, regions) &&
        identical(other.markers, markers) &&
        other.mapRect == mapRect &&
        other.projection == projection &&
        other.scale == scale &&
        other.neutralColor == neutralColor &&
        other.markerColor == markerColor &&
        other.maxMarkerRadius == maxMarkerRadius;
  }

  @override
  int get hashCode => Object.hash(
    identityHashCode(regions),
    identityHashCode(markers),
    mapRect,
    projection,
    scale,
    neutralColor,
    markerColor,
    maxMarkerRadius,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Legend
// ─────────────────────────────────────────────────────────────────────────────

/// A compact continuous legend showing a min→max color ramp with labels.
class _OiVectorMapLegend extends StatelessWidget {
  const _OiVectorMapLegend({
    required this.scale,
    required this.minLabel,
    required this.maxLabel,
  });

  final OiColorScale scale;
  final String minLabel;
  final String maxLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const steps = 24;
    final gradient = <Color>[
      for (var i = 0; i < steps; i++)
        scale.resolve(scale.min + (scale.max - scale.min) * (i / (steps - 1))),
    ];
    return Row(
      key: const Key('oi_vector_map_legend'),
      mainAxisSize: MainAxisSize.min,
      children: [
        OiLabel.caption(minLabel, color: colors.textMuted),
        const SizedBox(width: 6),
        Container(
          width: 120,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: colors.borderSubtle),
            gradient: LinearGradient(colors: gradient),
          ),
        ),
        const SizedBox(width: 6),
        OiLabel.caption(maxLabel, color: colors.textMuted),
      ],
    );
  }
}
