import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_oklch.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_ramp.dart';

/// Only the chart slots derived by the opt-in brand engine.
///
/// Values may be raw extended sRGB; no gamut mapping is performed.
///
/// {@category Foundation}
@immutable
class OiBrandCharts {
  /// Creates explicitly authored semantic colors.
  const OiBrandCharts({
    required this.first,
    required this.second,
    required this.third,
    required this.positive,
    required this.middle,
    required this.muted,
    required this.sequential,
  });

  /// Derives only the categorical, sequential and divergent brand subset.
  ///
  /// Raw channels/relative alpha are retained; tint defaults to primary.
  /// Slots four–six and the negative divergent endpoint are not generated.
  factory OiBrandCharts.derive({
    required OiOklch primary,
    required OiOklch secondary,
    required OiOklch highlight,
    required Brightness brightness,
    OiOklch? tint,
  }) {
    final neutral = tint ?? primary;
    final dark = brightness == Brightness.dark;
    Color slot(OiOklch source, double maximum, double cap) => OiOklch(
      lightness: source.lightness.clamp(
        dark ? 0.5 : 0.45,
        dark ? 0.66 : maximum,
      ),
      chroma: source.chroma.clamp(0.1, cap),
      hue: source.hue,
      alpha: source.alpha,
    ).toColor();
    Color sequential(double lightness, double scale, double cap) => OiOklch(
      lightness: lightness,
      chroma: math.min(primary.chroma * scale, cap),
      hue: primary.hue,
      alpha: primary.alpha,
    ).toColor();
    return OiBrandCharts(
      first: slot(primary, 0.70, 0.13),
      second: slot(highlight, 0.76, 0.12),
      third: slot(secondary, 0.74, 0.12),
      positive: slot(primary, 0.62, 0.12),
      middle: OiOklch(
        lightness: dark ? 0.36 : 0.9,
        chroma: dark ? 0.01 : 0.006,
        hue: neutral.hue,
        alpha: neutral.alpha,
      ).toColor(),
      muted: OiOklch(
        lightness: dark ? 0.42 : 0.8,
        chroma: dark ? 0.01 : 0.008,
        hue: neutral.hue,
        alpha: neutral.alpha,
      ).toColor(),
      sequential: OiColorRamp(
        first: sequential(
          dark ? 0.30 : 0.94,
          dark ? 0.6 : 0.19,
          dark ? 0.05 : 0.022,
        ),
        second: sequential(
          dark ? 0.39 : 0.865,
          dark ? 0.82 : 0.38,
          dark ? 0.07 : 0.045,
        ),
        third: sequential(
          dark ? 0.48 : 0.775,
          dark ? 1 : 0.6,
          dark ? 0.09 : 0.07,
        ),
        fourth: sequential(
          dark ? 0.58 : 0.675,
          dark ? 1 : 0.8,
          dark ? 0.1 : 0.095,
        ),
        fifth: sequential(
          dark ? 0.68 : 0.575,
          dark ? 1 : 0.95,
          dark ? 0.092 : 0.112,
        ),
        sixth: sequential(
          dark ? 0.79 : 0.465,
          dark ? 0.85 : 0.92,
          dark ? 0.072 : 0.108,
        ),
      ),
    );
  }

  /// Primary categorical slot.
  final Color first;

  /// Highlight categorical slot.
  final Color second;

  /// Secondary categorical slot.
  final Color third;

  /// Positive divergent endpoint.
  final Color positive;

  /// Neutral divergent midpoint.
  final Color middle;

  /// Muted chart ink.
  final Color muted;

  /// Primary six-color sequential ramp.
  final OiColorRamp sequential;

  /// Returns an independent value with supplied colors overridden.
  OiBrandCharts copyWith({
    Color? first,
    Color? second,
    Color? third,
    Color? positive,
    Color? middle,
    Color? muted,
    OiColorRamp? sequential,
  }) => OiBrandCharts(
    first: first ?? this.first,
    second: second ?? this.second,
    third: third ?? this.third,
    positive: positive ?? this.positive,
    middle: middle ?? this.middle,
    muted: muted ?? this.muted,
    sequential: sequential ?? this.sequential,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiBrandCharts &&
          other.first == first &&
          other.second == second &&
          other.third == third &&
          other.positive == positive &&
          other.middle == middle &&
          other.muted == muted &&
          other.sequential == sequential;

  @override
  int get hashCode => Object.hash(
    first,
    second,
    third,
    positive,
    middle,
    muted,
    sequential,
  );
}
