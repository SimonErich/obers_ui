import 'dart:ui' show Offset;

// ─────────────────────────────────────────────────────────────────────────────
// OiMapProjection
// ─────────────────────────────────────────────────────────────────────────────

/// Converts geographic coordinates into normalized map space.
///
/// Implementations map latitude/longitude in degrees onto a normalized
/// `Offset` where `dx` runs 0→1 from west (−180°) to east (180°) and `dy`
/// runs 0→1 from north (90°) to south (−90°). The projection is a pure
/// function, so it can be unit-tested directly and swapped (e.g. for a
/// Mercator projection) without changing `OiVectorMap`.
///
/// {@category Composites}
abstract class OiMapProjection {
  /// Allows subclasses to declare const constructors.
  const OiMapProjection();

  /// The width-to-height ratio of the full projected extent.
  double get aspectRatio;

  /// Projects [latitude]/[longitude] in degrees to normalized map space.
  ///
  /// Returns an `Offset` with both components in 0…1 for coordinates
  /// inside the projectable extent.
  Offset project({required double latitude, required double longitude});
}

// ─────────────────────────────────────────────────────────────────────────────
// OiEquirectangularProjection
// ─────────────────────────────────────────────────────────────────────────────

/// The equirectangular (plate carrée) projection.
///
/// Maps longitude linearly to `dx` and latitude linearly to `dy`, giving a
/// 2:1 world extent. Simple and fast — well suited to dashboard maps.
///
/// {@category Composites}
final class OiEquirectangularProjection extends OiMapProjection {
  /// Creates an [OiEquirectangularProjection].
  const OiEquirectangularProjection();

  @override
  double get aspectRatio => 2;

  @override
  Offset project({required double latitude, required double longitude}) {
    return Offset((longitude + 180) / 360, (90 - latitude) / 180);
  }
}
