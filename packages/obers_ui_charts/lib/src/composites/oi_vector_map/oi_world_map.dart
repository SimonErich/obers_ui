import 'dart:ui' show Color, Offset;

import 'package:obers_ui_charts/src/composites/oi_vector_map/_world_centroid_data.dart';
import 'package:obers_ui_charts/src/composites/oi_vector_map/_world_geometry_data.dart';
import 'package:obers_ui_charts/src/composites/oi_vector_map/oi_vector_map_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OiWorldMap
// ─────────────────────────────────────────────────────────────────────────────

/// Bundled world map data, so `OiVectorMap` renders a world map with zero
/// setup.
///
/// Provides simplified country outlines ([regions]) and a label-point
/// table covering every country ([centroidsByIsoCode]), both keyed by ISO
/// 3166-1 alpha-2 code. Derived from Natural Earth (public domain) and
/// heavily simplified for compact dashboard rendering — shapes are
/// recognizable, not survey-grade.
///
/// ```dart
/// OiVectorMap(
///   label: 'Users by country',
///   values: {'US': 1240, 'DE': 830, 'BR': 410},
/// )
/// ```
///
/// {@category Composites}
abstract final class OiWorldMap {
  static List<OiMapRegion>? _regions;
  static Map<String, OiMapRegion>? _regionsById;
  static Map<String, Offset>? _centroids;

  /// The simplified country outlines, one region per country, keyed by
  /// ISO 3166-1 alpha-2 [OiMapRegion.id].
  ///
  /// Decoded lazily on first access and cached; the list and its regions
  /// are unmodifiable.
  static List<OiMapRegion> get regions {
    return _regions ??= List.unmodifiable(
      worldGeometryByIsoCode.entries.map(
        (entry) => OiMapRegion(
          id: entry.key,
          label: worldRegionLabelsByIsoCode[entry.key] ?? entry.key,
          polygons: List.unmodifiable(entry.value.map(_decodeRing)),
        ),
      ),
    );
  }

  /// Returns the bundled region for [isoCode], or `null` when the country
  /// has no bundled outline.
  static OiMapRegion? region(String isoCode) {
    final byId = _regionsById ??= {
      for (final region in regions) region.id: region,
    };
    return byId[isoCode.toUpperCase()];
  }

  /// Label-point coordinates for every country, keyed by ISO 3166-1
  /// alpha-2 code.
  ///
  /// Each entry is an `Offset(longitude, latitude)` in degrees — the same
  /// axis order used by [OiMapRegion.polygons].
  static Map<String, Offset> get centroidsByIsoCode {
    return _centroids ??= Map.unmodifiable({
      for (final entry in worldCentroidsByIsoCode.entries)
        entry.key: _decodeCentroid(entry.value),
    });
  }

  /// Returns the label-point for [isoCode] as an
  /// `Offset(longitude, latitude)` in degrees, or `null` for unknown
  /// codes.
  static Offset? centroid(String isoCode) {
    return centroidsByIsoCode[isoCode.toUpperCase()];
  }

  /// Returns the English country name for [isoCode], or `null` for
  /// unknown codes.
  static String? countryLabel(String isoCode) {
    return worldCountryLabelsByIsoCode[isoCode.toUpperCase()];
  }

  /// Builds an [OiMapMarker] at the label-point of [isoCode], or `null`
  /// for unknown codes.
  ///
  /// [label] defaults to the English country name and [value] drives the
  /// bubble size.
  static OiMapMarker? marker({
    required String isoCode,
    required num value,
    String? label,
    Color? color,
  }) {
    final position = centroid(isoCode);
    if (position == null) return null;
    return OiMapMarker(
      latitude: position.dy,
      longitude: position.dx,
      label: label ?? countryLabel(isoCode) ?? isoCode.toUpperCase(),
      value: value,
      color: color,
    );
  }

  /// Decodes a `'longitude latitude …'` ring string into vertices.
  static List<Offset> _decodeRing(String encoded) {
    final numbers = encoded.split(' ');
    return List.unmodifiable([
      for (var i = 0; i + 1 < numbers.length; i += 2)
        Offset(double.parse(numbers[i]), double.parse(numbers[i + 1])),
    ]);
  }

  /// Decodes a `'latitude longitude'` centroid string into an
  /// `Offset(longitude, latitude)`.
  static Offset _decodeCentroid(String encoded) {
    final numbers = encoded.split(' ');
    return Offset(double.parse(numbers[1]), double.parse(numbers[0]));
  }
}
