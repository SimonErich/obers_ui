import 'dart:ui' show Color, Offset;

import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OiMapRegion
// ─────────────────────────────────────────────────────────────────────────────

/// A named geographic region rendered by `OiVectorMap`.
///
/// A region is identified by [id] (conventionally an ISO 3166-1 alpha-2
/// country code such as `'DE'`), displayed as [label], and outlined by one
/// or more [polygons]. The optional [value] drives the choropleth fill
/// color; regions without a value are painted with a neutral fill.
///
/// {@category Composites}
@immutable
class OiMapRegion {
  /// Creates an [OiMapRegion].
  const OiMapRegion({
    required this.id,
    required this.label,
    required this.polygons,
    this.value,
  });

  /// The unique identifier for this region, e.g. an ISO 3166-1 alpha-2
  /// country code.
  final String id;

  /// The human-readable name for this region.
  final String label;

  /// The outline polygons of this region.
  ///
  /// Each polygon is a list of `Offset(longitude, latitude)` vertices in
  /// degrees forming a closed ring; the closing edge back to the first
  /// vertex is implicit. Longitude runs −180…180 and latitude −90…90.
  final List<List<Offset>> polygons;

  /// The numeric value used for the choropleth fill; `null` renders the
  /// region with a neutral fill.
  final num? value;

  /// Returns a copy of this region carrying [value], sharing the same
  /// geometry.
  OiMapRegion withValue(num? value) {
    return OiMapRegion(id: id, label: label, polygons: polygons, value: value);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OiMapMarker
// ─────────────────────────────────────────────────────────────────────────────

/// A point marker rendered by `OiVectorMap` as a bubble at a geographic
/// position.
///
/// The bubble is centered at [latitude]/[longitude] and its area is
/// proportional to [value] (its radius scales with the square root of the
/// value).
///
/// {@category Composites}
@immutable
class OiMapMarker {
  /// Creates an [OiMapMarker].
  const OiMapMarker({
    required this.latitude,
    required this.longitude,
    required this.label,
    required this.value,
    this.color,
  });

  /// The latitude of the marker in degrees, −90…90.
  final double latitude;

  /// The longitude of the marker in degrees, −180…180.
  final double longitude;

  /// The human-readable name shown in the tooltip.
  final String label;

  /// The numeric value driving the bubble size (area proportional).
  final num value;

  /// An optional override color. When `null`, the theme accent color is
  /// used.
  final Color? color;
}
