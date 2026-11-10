import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_semantic_color_interpolation.dart';

/// Explicit navigation-rail colors, independent of content surfaces.
///
/// Values may be raw extended sRGB; no gamut mapping is performed.
///
/// {@category Foundation}
@immutable
class OiRailColors {
  /// Creates explicitly authored semantic colors.
  const OiRailColors({
    required this.surface,
    required this.ink,
    required this.hoverWash,
    required this.line,
    required this.active,
    required this.onActive,
    required this.badge,
    required this.onBadge,
  });

  /// Interpolates raw sRGB with premultiplied alpha, without gamut clipping.
  ///
  /// Exact endpoints are retained. Optional values carry a sole endpoint.
  /// Throws [ArgumentError] for fractions outside finite 0–1.
  factory OiRailColors.lerp(
    OiRailColors first,
    OiRailColors second,
    double fraction,
  ) {
    if (fraction == 0) return first;
    if (fraction == 1) return second;
    Color mix(Color firstColor, Color secondColor) =>
        OiSemanticColorInterpolation.color(firstColor, secondColor, fraction);
    return OiRailColors(
      surface: mix(first.surface, second.surface),
      ink: mix(first.ink, second.ink),
      hoverWash: mix(first.hoverWash, second.hoverWash),
      line: mix(first.line, second.line),
      active: mix(first.active, second.active),
      onActive: mix(first.onActive, second.onActive),
      badge: mix(first.badge, second.badge),
      onBadge: mix(first.onBadge, second.onBadge),
    );
  }

  /// Rail background.
  final Color surface;

  /// Default rail text and icon ink.
  final Color ink;

  /// Translucent rail hover wash.
  final Color hoverWash;

  /// Translucent rail divider.
  final Color line;

  /// Active destination fill.
  final Color active;

  /// Foreground on the active destination.
  final Color onActive;

  /// Badge fill.
  final Color badge;

  /// Foreground on a badge.
  final Color onBadge;

  /// Returns an independent value with supplied colors overridden.
  OiRailColors copyWith({
    Color? surface,
    Color? ink,
    Color? hoverWash,
    Color? line,
    Color? active,
    Color? onActive,
    Color? badge,
    Color? onBadge,
  }) => OiRailColors(
    surface: surface ?? this.surface,
    ink: ink ?? this.ink,
    hoverWash: hoverWash ?? this.hoverWash,
    line: line ?? this.line,
    active: active ?? this.active,
    onActive: onActive ?? this.onActive,
    badge: badge ?? this.badge,
    onBadge: onBadge ?? this.onBadge,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiRailColors &&
          other.surface == surface &&
          other.ink == ink &&
          other.hoverWash == hoverWash &&
          other.line == line &&
          other.active == active &&
          other.onActive == onActive &&
          other.badge == badge &&
          other.onBadge == onBadge;

  @override
  int get hashCode => Object.hash(
    surface,
    ink,
    hoverWash,
    line,
    active,
    onActive,
    badge,
    onBadge,
  );
}
