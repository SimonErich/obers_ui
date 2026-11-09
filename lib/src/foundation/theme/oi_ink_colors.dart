import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_semantic_color_interpolation.dart';

/// Explicit text and icon colors on normal and inverse surfaces.
///
/// Values may be raw extended sRGB; no gamut mapping is performed.
///
/// {@category Foundation}
@immutable
class OiInkColors {
  /// Creates explicitly authored semantic colors.
  const OiInkColors({
    required this.primary,
    required this.muted,
    required this.subtle,
    required this.onInverse,
    required this.inverseMuted,
  });

  /// Interpolates raw sRGB with premultiplied alpha, without gamut clipping.
  ///
  /// Exact endpoints are retained. Optional values carry a sole endpoint.
  /// Throws [ArgumentError] for fractions outside finite 0–1.
  factory OiInkColors.lerp(
    OiInkColors first,
    OiInkColors second,
    double fraction,
  ) {
    if (fraction == 0) return first;
    if (fraction == 1) return second;
    Color mix(Color firstColor, Color secondColor) =>
        OiSemanticColorInterpolation.color(firstColor, secondColor, fraction);
    return OiInkColors(
      primary: mix(first.primary, second.primary),
      muted: mix(first.muted, second.muted),
      subtle: mix(first.subtle, second.subtle),
      onInverse: mix(first.onInverse, second.onInverse),
      inverseMuted: mix(first.inverseMuted, second.inverseMuted),
    );
  }

  /// Primary text and icon ink.
  final Color primary;

  /// Secondary text and icon ink.
  final Color muted;

  /// Tertiary text and icon ink.
  final Color subtle;

  /// Foreground on the inverse surface.
  final Color onInverse;

  /// Secondary ink on the inverse surface.
  final Color inverseMuted;

  /// Returns an independent value with supplied colors overridden.
  OiInkColors copyWith({
    Color? primary,
    Color? muted,
    Color? subtle,
    Color? onInverse,
    Color? inverseMuted,
  }) => OiInkColors(
    primary: primary ?? this.primary,
    muted: muted ?? this.muted,
    subtle: subtle ?? this.subtle,
    onInverse: onInverse ?? this.onInverse,
    inverseMuted: inverseMuted ?? this.inverseMuted,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiInkColors &&
          other.primary == primary &&
          other.muted == muted &&
          other.subtle == subtle &&
          other.onInverse == onInverse &&
          other.inverseMuted == inverseMuted;

  @override
  int get hashCode => Object.hash(
    primary,
    muted,
    subtle,
    onInverse,
    inverseMuted,
  );
}
