import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_charts/src/composites/oi_vector_map/oi_vector_map_data.dart'
    show OiMapMarker;

/// The number of logical pixels per map tile — the slippy-map standard.
const double _tileSize = 256;

/// The Web-Mercator latitude limit, beyond which the projection diverges.
const double _maxLatitude = 85.05112878;

/// A slippy (Google/OSM-style) raster **tile map**: it fetches square map
/// tiles from a `{z}/{x}/{y}` [tileUrlTemplate] for the current view and lays
/// them out under any [markers], with drag-to-pan and zoom controls.
///
/// Unlike `OiVectorMap` (a vector choropleth from embedded geometry), this
/// renders real cartographic tiles from a tile server, so it needs network
/// access. It defaults to the OpenStreetMap tiles; point [tileUrlTemplate] at
/// any other slippy-tile endpoint (Carto, Stamen, a self-hosted server, …)
/// and keep the [attribution] the provider requires.
///
/// ```dart
/// OiTileMap(
///   label: 'Offices',
///   center: const OiLatLng(48.2, 16.37),
///   zoom: 5,
///   markers: const [
///     OiMapMarker(latitude: 48.2, longitude: 16.37, label: 'HQ', value: 1),
///   ],
/// );
/// ```
class OiTileMap extends StatefulWidget {
  /// Creates a tile map centered on [center] at [zoom].
  const OiTileMap({
    required this.center,
    required this.label,
    super.key,
    this.zoom = 3,
    this.markers = const [],
    this.tileUrlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    this.attribution = '© OpenStreetMap contributors',
    this.interactive = true,
    this.minZoom = 1,
    this.maxZoom = 18,
    this.heightInPixels = 360,
  });

  /// The geographic point the map starts centered on.
  final OiLatLng center;

  /// An accessible label describing the map.
  final String label;

  /// The initial integer zoom level (higher is closer).
  final int zoom;

  /// The markers pinned on the map.
  final List<OiMapMarker> markers;

  /// The `{z}/{x}/{y}` tile URL template.
  final String tileUrlTemplate;

  /// Attribution text shown in the corner (respect the tile provider's terms).
  final String attribution;

  /// Whether the user can pan (drag) and zoom (buttons).
  final bool interactive;

  /// The lowest selectable zoom.
  final int minZoom;

  /// The highest selectable zoom.
  final int maxZoom;

  /// The map's height in logical pixels.
  final double heightInPixels;

  @override
  State<OiTileMap> createState() => _OiTileMapState();
}

/// An immutable latitude/longitude pair in degrees.
@immutable
class OiLatLng {
  /// Creates a coordinate at [latitude]/[longitude] degrees.
  const OiLatLng(this.latitude, this.longitude);

  /// Degrees north (−90…90).
  final double latitude;

  /// Degrees east (−180…180).
  final double longitude;
}

class _OiTileMapState extends State<OiTileMap> {
  late OiLatLng _center;
  late int _zoom;

  @override
  void initState() {
    super.initState();
    _center = widget.center;
    _zoom = widget.zoom.clamp(widget.minZoom, widget.maxZoom);
  }

  double get _worldSize => _tileSize * (1 << _zoom);

  Offset _project(OiLatLng point) {
    final lat = point.latitude.clamp(-_maxLatitude, _maxLatitude);
    final latRad = lat * math.pi / 180.0;
    final x = (point.longitude + 180.0) / 360.0 * _worldSize;
    final y =
        (1.0 - math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) /
        2.0 *
        _worldSize;
    return Offset(x, y);
  }

  OiLatLng _unproject(Offset pixel) {
    final lng = pixel.dx / _worldSize * 360.0 - 180.0;
    final g = math.pi * (1.0 - 2.0 * pixel.dy / _worldSize);
    final latRad = math.atan((math.exp(g) - math.exp(-g)) / 2.0);
    return OiLatLng(latRad * 180.0 / math.pi, lng);
  }

  void _panBy(Offset delta) {
    setState(() => _center = _unproject(_project(_center) - delta));
  }

  void _zoomBy(int step) {
    setState(
      () => _zoom = (_zoom + step).clamp(widget.minZoom, widget.maxZoom),
    );
  }

  String _tileUrl(int x, int y) => widget.tileUrlTemplate
      .replaceAll('{z}', '$_zoom')
      .replaceAll('{x}', '$x')
      .replaceAll('{y}', '$y');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      container: true,
      label: widget.label,
      child: SizedBox(
        height: widget.heightInPixels,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: DecoratedBox(
            decoration: BoxDecoration(color: colors.surfaceSubtle),
            child: LayoutBuilder(
              builder: (context, constraints) =>
                  _map(context, constraints.biggest, colors),
            ),
          ),
        ),
      ),
    );
  }

  Widget _map(BuildContext context, Size size, OiColorScheme colors) {
    if (size.isEmpty) {
      return const SizedBox.shrink();
    }
    final tileCount = 1 << _zoom;
    final centerPx = _project(_center);
    final topLeft = centerPx - Offset(size.width / 2, size.height / 2);

    final firstX = (topLeft.dx / _tileSize).floor();
    final lastX = ((topLeft.dx + size.width) / _tileSize).floor();
    final firstY = (topLeft.dy / _tileSize).floor();
    final lastY = ((topLeft.dy + size.height) / _tileSize).floor();

    final tiles = <Widget>[];
    for (var ty = firstY; ty <= lastY; ty++) {
      if (ty < 0 || ty >= tileCount) {
        continue;
      }
      for (var tx = firstX; tx <= lastX; tx++) {
        final wrappedX = ((tx % tileCount) + tileCount) % tileCount;
        tiles.add(
          Positioned(
            left: tx * _tileSize - topLeft.dx,
            top: ty * _tileSize - topLeft.dy,
            width: _tileSize,
            height: _tileSize,
            child: Image.network(
              _tileUrl(wrappedX, ty),
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (context, error, stack) => DecoratedBox(
                decoration: BoxDecoration(color: colors.surface),
              ),
            ),
          ),
        );
      }
    }

    final markers = <Widget>[
      for (final marker in widget.markers)
        _positionedMarker(marker, topLeft, size, colors),
    ];

    final stack = Stack(
      fit: StackFit.expand,
      children: [
        ...tiles,
        ...markers,
        Positioned(
          right: 6,
          bottom: 4,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: OiLabel.caption(widget.attribution),
            ),
          ),
        ),
        if (widget.interactive)
          Positioned(top: 8, right: 8, child: _zoomControls(colors)),
      ],
    );

    if (!widget.interactive) {
      return stack;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (details) => _panBy(details.delta),
      child: stack,
    );
  }

  Widget _positionedMarker(
    OiMapMarker marker,
    Offset topLeft,
    Size viewport,
    OiColorScheme colors,
  ) {
    final projected = _project(OiLatLng(marker.latitude, marker.longitude));
    // Place the marker on the copy of the globe nearest the viewport, so it
    // wraps at the antimeridian exactly like the tile grid (and stays put when
    // panning drives the center longitude outside [-180, 180]).
    final viewportCenterX = topLeft.dx + viewport.width / 2;
    var worldX = projected.dx;
    while (worldX - viewportCenterX > _worldSize / 2) {
      worldX -= _worldSize;
    }
    while (worldX - viewportCenterX < -_worldSize / 2) {
      worldX += _worldSize;
    }
    final pixel = Offset(worldX, projected.dy) - topLeft;
    const markerSize = 26.0;
    return Positioned(
      left: pixel.dx - markerSize / 2,
      top: pixel.dy - markerSize,
      child: Semantics(
        container: true,
        label: marker.label,
        child: OiIcon.decorative(
          icon: OiIcons.mapPin,
          size: markerSize,
          color: marker.color ?? colors.primary.base,
        ),
      ),
    );
  }

  Widget _zoomControls(OiColorScheme colors) => DecoratedBox(
    decoration: BoxDecoration(
      color: colors.surface.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: colors.border),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _zoomButton(OiIcons.plus, 'Zoom in', () => _zoomBy(1), colors),
        _zoomButton(OiIcons.minus, 'Zoom out', () => _zoomBy(-1), colors),
      ],
    ),
  );

  Widget _zoomButton(
    IconData icon,
    String label,
    VoidCallback onTap,
    OiColorScheme colors,
  ) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.all(6),
      child: Semantics(
        button: true,
        label: label,
        child: OiIcon.decorative(icon: icon, size: 18, color: colors.text),
      ),
    ),
  );
}
