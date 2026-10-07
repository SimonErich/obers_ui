import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_brand_charts.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_brand_neutrals.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_brand_rail.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_brand_role.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_oklab.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_oklch.dart';
import 'package:obers_ui/src/foundation/theme/oi_ink_colors.dart';
import 'package:obers_ui/src/foundation/theme/oi_rail_colors.dart';
import 'package:obers_ui/src/foundation/theme/oi_role_colors.dart';
import 'package:obers_ui/src/foundation/theme/oi_semantic_colors.dart';
import 'package:obers_ui/src/foundation/theme/oi_surface_colors.dart';

/// Opt-in generic brand colors, derived without intermediate gamut clipping.
///
/// This engine is distinct from hand-tuned palettes and legacy HSL swatches.
/// RGB/XYZ inputs can enter through [OiOklch.fromColor] or
/// [OiOklab.fromXyzD65] followed by [OiOklabPolar.toOklch].
///
/// {@category Foundation}
@immutable
class OiBrandPalette {
  /// Creates an explicitly authored brand result.
  const OiBrandPalette({
    required this.primary,
    required this.secondary,
    required this.highlight,
    required this.surfaces,
    required this.inks,
    required this.infoColor,
    required this.infoSoft,
    required this.rail,
    required this.focus,
    required this.focusHalo,
    required this.charts,
  });

  /// Derives brand colors using continuous luminance transitions.
  ///
  /// Authored hue is retained by typed inputs. Results are extended sRGB;
  /// clip only at an explicit display boundary, never before arithmetic.
  factory OiBrandPalette.derive({
    required OiOklch primary,
    required OiOklch secondary,
    required OiOklch highlight,
    required Brightness brightness,
    OiOklch? tint,
  }) => OiBrandPalette(
    primary: OiBrandRole.primary(primary, brightness),
    secondary: OiBrandRole.secondary(secondary, brightness),
    highlight: OiBrandRole.highlight(highlight, brightness),
    surfaces: OiBrandNeutrals.surfaces(tint ?? primary, brightness),
    inks: OiBrandNeutrals.inks(tint ?? primary, brightness),
    infoColor: OiBrandNeutrals.info(tint ?? primary, brightness),
    infoSoft: OiBrandNeutrals.infoSoft(tint ?? primary, brightness),
    rail: OiBrandRail.derive(primary, highlight, tint ?? primary, brightness),
    focus: OiBrandRole.primary(primary, brightness).ink,
    focusHalo: OiBrandRole.focusHalo(primary, brightness),
    charts: OiBrandCharts.derive(
      primary: primary,
      secondary: secondary,
      highlight: highlight,
      tint: tint,
      brightness: brightness,
    ),
  );

  /// Primary fill, foreground, surface ink and interaction versions.
  final OiRoleColors primary;

  /// Secondary fill, foreground, surface ink and soft surface.
  final OiRoleColors secondary;

  /// Highlight fill, foreground, surface ink and soft surface.
  final OiRoleColors highlight;

  /// Neutral surfaces and translucent washes; overlay and scrim are distinct.
  final OiSurfaceColors surfaces;

  /// Neutral text and icon inks.
  final OiInkColors inks;

  /// Neutral-tinted info fill; other info role fields are not derived.
  final Color infoColor;

  /// Neutral-tinted info soft surface.
  final Color infoSoft;

  /// Rail colors, independently sourced from tint, primary and highlight.
  final OiRailColors rail;

  /// Focus outline ink, equal to the derived primary ink.
  final Color focus;

  /// Uncomposited translucent focus halo.
  final Color focusHalo;

  /// Derived chart subset; categorical slots four through six are untouched.
  final OiBrandCharts charts;

  /// Applies derived values explicitly, retaining all source-undefined fields.
  ///
  /// Preserves categorical slots four–six, divergent negative, info foreground
  /// and ink, and secondary/highlight interaction colors from [base]. This
  /// never mutates a legacy scheme or generates status/shadow/focus-ring roles.
  OiSemanticColors applyTo(OiSemanticColors base) => base.copyWith(
    surfaces: surfaces,
    inks: inks,
    primary: primary,
    secondary: secondary.copyWith(
      hover: base.secondary.hover,
      pressed: base.secondary.pressed,
      softHover: base.secondary.softHover,
      clearHover: base.secondary.hover == null,
      clearPressed: base.secondary.pressed == null,
      clearSoftHover: base.secondary.softHover == null,
    ),
    highlight: highlight.copyWith(
      hover: base.highlight.hover,
      pressed: base.highlight.pressed,
      softHover: base.highlight.softHover,
      clearHover: base.highlight.hover == null,
      clearPressed: base.highlight.pressed == null,
      clearSoftHover: base.highlight.softHover == null,
    ),
    info: base.info.copyWith(base: infoColor, soft: infoSoft),
    rail: rail,
    charts: base.charts.copyWith(
      first: charts.first,
      second: charts.second,
      third: charts.third,
      muted: charts.muted,
      positive: charts.positive,
      middle: charts.middle,
      sequential: charts.sequential,
    ),
    focus: focus,
    focusHalo: focusHalo,
  );

  /// Returns an independent value with supplied groups overridden.
  OiBrandPalette copyWith({
    OiRoleColors? primary,
    OiRoleColors? secondary,
    OiRoleColors? highlight,
    OiSurfaceColors? surfaces,
    OiInkColors? inks,
    Color? infoColor,
    Color? infoSoft,
    OiRailColors? rail,
    Color? focus,
    Color? focusHalo,
    OiBrandCharts? charts,
  }) => OiBrandPalette(
    primary: primary ?? this.primary,
    secondary: secondary ?? this.secondary,
    highlight: highlight ?? this.highlight,
    surfaces: surfaces ?? this.surfaces,
    inks: inks ?? this.inks,
    infoColor: infoColor ?? this.infoColor,
    infoSoft: infoSoft ?? this.infoSoft,
    rail: rail ?? this.rail,
    focus: focus ?? this.focus,
    focusHalo: focusHalo ?? this.focusHalo,
    charts: charts ?? this.charts,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiBrandPalette &&
          other.primary == primary &&
          other.secondary == secondary &&
          other.highlight == highlight &&
          other.surfaces == surfaces &&
          other.inks == inks &&
          other.infoColor == infoColor &&
          other.infoSoft == infoSoft &&
          other.rail == rail &&
          other.focus == focus &&
          other.focusHalo == focusHalo &&
          other.charts == charts;

  @override
  int get hashCode => Object.hash(
    primary,
    secondary,
    highlight,
    surfaces,
    inks,
    infoColor,
    infoSoft,
    rail,
    focus,
    focusHalo,
    charts,
  );
}
