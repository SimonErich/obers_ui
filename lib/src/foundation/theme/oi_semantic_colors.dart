import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_semantic_color_interpolation.dart';
import 'package:obers_ui/src/foundation/theme/oi_chart_colors.dart';
import 'package:obers_ui/src/foundation/theme/oi_ink_colors.dart';
import 'package:obers_ui/src/foundation/theme/oi_rail_colors.dart';
import 'package:obers_ui/src/foundation/theme/oi_role_colors.dart';
import 'package:obers_ui/src/foundation/theme/oi_surface_colors.dart';

/// Immutable opt-in semantic groups, independent of legacy color schemes.
///
/// Values may be raw extended sRGB; no gamut mapping is performed.
///
/// {@category Foundation}
@immutable
class OiSemanticColors {
  /// Creates explicitly authored semantic colors.
  const OiSemanticColors({
    required this.surfaces,
    required this.inks,
    required this.primary,
    required this.secondary,
    required this.highlight,
    required this.info,
    required this.rail,
    required this.charts,
    required this.focus,
    this.focusHalo,
  });

  /// Interpolates raw extended-sRGB channels with CSS premultiplied alpha.
  ///
  /// Optional colors/ramps are carried when only one endpoint authors them;
  /// nothing is synthesized. Endpoints are returned unchanged. Throws
  /// [ArgumentError] unless [fraction] is finite and in 0–1.
  factory OiSemanticColors.lerp(
    OiSemanticColors first,
    OiSemanticColors second,
    double fraction,
  ) {
    if (!fraction.isFinite || fraction < 0 || fraction > 1) {
      throw ArgumentError.value(
        fraction,
        'fraction',
        'Must be finite and in 0–1',
      );
    }
    if (fraction == 0) return first;
    if (fraction == 1) return second;
    return OiSemanticColors(
      surfaces: OiSurfaceColors.lerp(first.surfaces, second.surfaces, fraction),
      inks: OiInkColors.lerp(first.inks, second.inks, fraction),
      primary: OiRoleColors.lerp(first.primary, second.primary, fraction),
      secondary: OiRoleColors.lerp(first.secondary, second.secondary, fraction),
      highlight: OiRoleColors.lerp(first.highlight, second.highlight, fraction),
      info: OiRoleColors.lerp(first.info, second.info, fraction),
      rail: OiRailColors.lerp(first.rail, second.rail, fraction),
      charts: OiChartColors.lerp(first.charts, second.charts, fraction),
      focus: OiSemanticColorInterpolation.color(
        first.focus,
        second.focus,
        fraction,
      ),
      focusHalo: OiSemanticColorInterpolation.optional(
        first.focusHalo,
        second.focusHalo,
        fraction,
      ),
    );
  }

  /// Surface, outline and wash colors.
  final OiSurfaceColors surfaces;

  /// Text and icon colors.
  final OiInkColors inks;

  /// Primary brand role.
  final OiRoleColors primary;

  /// Secondary brand role.
  final OiRoleColors secondary;

  /// Highlight brand role.
  final OiRoleColors highlight;

  /// Informational role; distinct from success/warning/error swatches.
  final OiRoleColors info;

  /// Navigation rail colors.
  final OiRailColors rail;

  /// Chart categorical, sequential and divergent colors.
  final OiChartColors charts;

  /// Focus outline ink.
  final Color focus;

  /// Optional uncomposited focus halo.
  final Color? focusHalo;

  /// Returns an independent value with supplied colors overridden.
  /// [clearFocusHalo] takes precedence over a supplied halo.
  OiSemanticColors copyWith({
    OiSurfaceColors? surfaces,
    OiInkColors? inks,
    OiRoleColors? primary,
    OiRoleColors? secondary,
    OiRoleColors? highlight,
    OiRoleColors? info,
    OiRailColors? rail,
    OiChartColors? charts,
    Color? focus,
    Color? focusHalo,
    bool clearFocusHalo = false,
  }) => OiSemanticColors(
    surfaces: surfaces ?? this.surfaces,
    inks: inks ?? this.inks,
    primary: primary ?? this.primary,
    secondary: secondary ?? this.secondary,
    highlight: highlight ?? this.highlight,
    info: info ?? this.info,
    rail: rail ?? this.rail,
    charts: charts ?? this.charts,
    focus: focus ?? this.focus,
    focusHalo: clearFocusHalo ? null : focusHalo ?? this.focusHalo,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiSemanticColors &&
          other.surfaces == surfaces &&
          other.inks == inks &&
          other.primary == primary &&
          other.secondary == secondary &&
          other.highlight == highlight &&
          other.info == info &&
          other.rail == rail &&
          other.charts == charts &&
          other.focus == focus &&
          other.focusHalo == focusHalo;

  @override
  int get hashCode => Object.hash(
    surfaces,
    inks,
    primary,
    secondary,
    highlight,
    info,
    rail,
    charts,
    focus,
    focusHalo,
  );
}
