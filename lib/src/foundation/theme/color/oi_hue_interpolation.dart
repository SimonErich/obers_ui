/// The four circular hue interpolation strategies from CSS Color 4.
///
/// {@category Foundation}
enum OiHueInterpolation {
  /// Uses the shorter arc, retaining direction when the hues differ by 180°.
  shorter,

  /// Uses the longer arc; equal hues make one full increasing revolution.
  longer,

  /// Always moves in the increasing-hue direction.
  increasing,

  /// Always moves in the decreasing-hue direction.
  decreasing;

  /// Interpolates finite degree angles, returning a hue in 0–360.
  ///
  /// [progress] must be in 0–1. This deliberately does not premultiply hue.
  double interpolate(double first, double second, double progress) {
    assert(first.isFinite && second.isFinite, 'Hue angles must be finite');
    assert(progress >= 0 && progress <= 1, 'Progress must be in 0–1');
    final start = first % 360;
    final difference = second % 360 - start;
    final delta = switch (this) {
      shorter =>
        difference > 180
            ? difference - 360
            : difference < -180
            ? difference + 360
            : difference,
      longer =>
        difference > 0 && difference < 180
            ? difference - 360
            : difference <= 0 && difference > -180
            ? difference + 360
            : difference,
      increasing => difference < 0 ? difference + 360 : difference,
      decreasing => difference > 0 ? difference - 360 : difference,
    };
    return (start + delta * progress) % 360;
  }
}
