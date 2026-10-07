import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_semantic_color_interpolation.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_ramp.dart';

/// Explicit categorical, divergent and optional sequential chart colors.
///
/// Values may be raw extended sRGB; no gamut mapping is performed.
///
/// {@category Foundation}
@immutable
class OiChartColors {
  /// Creates explicitly authored semantic colors.
  const OiChartColors({
    required this.first,
    required this.second,
    required this.third,
    required this.fourth,
    required this.fifth,
    required this.sixth,
    required this.muted,
    required this.positive,
    required this.middle,
    required this.negative,
    this.sequential,
  });

  /// Interpolates raw sRGB with premultiplied alpha, without gamut clipping.
  ///
  /// Exact endpoints are retained. Optional values carry a sole endpoint.
  /// Throws [ArgumentError] for fractions outside finite 0–1.
  factory OiChartColors.lerp(
    OiChartColors first,
    OiChartColors second,
    double fraction,
  ) {
    if (fraction == 0) return first;
    if (fraction == 1) return second;
    Color mix(Color firstColor, Color secondColor) =>
        OiSemanticColorInterpolation.color(firstColor, secondColor, fraction);
    return OiChartColors(
      first: mix(first.first, second.first),
      second: mix(first.second, second.second),
      third: mix(first.third, second.third),
      fourth: mix(first.fourth, second.fourth),
      fifth: mix(first.fifth, second.fifth),
      sixth: mix(first.sixth, second.sixth),
      muted: mix(first.muted, second.muted),
      positive: mix(first.positive, second.positive),
      middle: mix(first.middle, second.middle),
      negative: mix(first.negative, second.negative),
      sequential: first.sequential == null
          ? second.sequential
          : second.sequential == null
          ? first.sequential
          : OiColorRamp.lerp(first.sequential!, second.sequential!, fraction),
    );
  }

  /// Categorical slot 1.
  final Color first;

  /// Categorical slot 2.
  final Color second;

  /// Categorical slot 3.
  final Color third;

  /// Categorical slot 4.
  final Color fourth;

  /// Categorical slot 5.
  final Color fifth;

  /// Categorical slot 6.
  final Color sixth;

  /// Muted chart ink.
  final Color muted;

  /// Positive divergent endpoint.
  final Color positive;

  /// Neutral divergent midpoint.
  final Color middle;

  /// Negative divergent endpoint.
  final Color negative;

  /// Optional six-color sequential ramp; never inferred.
  final OiColorRamp? sequential;

  /// Returns an independent value with supplied colors overridden.
  /// [clearSequential] takes precedence over a supplied ramp.
  OiChartColors copyWith({
    Color? first,
    Color? second,
    Color? third,
    Color? fourth,
    Color? fifth,
    Color? sixth,
    Color? muted,
    Color? positive,
    Color? middle,
    Color? negative,
    OiColorRamp? sequential,
    bool clearSequential = false,
  }) => OiChartColors(
    first: first ?? this.first,
    second: second ?? this.second,
    third: third ?? this.third,
    fourth: fourth ?? this.fourth,
    fifth: fifth ?? this.fifth,
    sixth: sixth ?? this.sixth,
    muted: muted ?? this.muted,
    positive: positive ?? this.positive,
    middle: middle ?? this.middle,
    negative: negative ?? this.negative,
    sequential: clearSequential ? null : sequential ?? this.sequential,
  );

  /// An immutable ordered view; no mutable collection is retained.
  List<Color> get categorical => List<Color>.unmodifiable([
    first,
    second,
    third,
    fourth,
    fifth,
    sixth,
  ]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiChartColors &&
          other.first == first &&
          other.second == second &&
          other.third == third &&
          other.fourth == fourth &&
          other.fifth == fifth &&
          other.sixth == sixth &&
          other.muted == muted &&
          other.positive == positive &&
          other.middle == middle &&
          other.negative == negative &&
          other.sequential == sequential;

  @override
  int get hashCode => Object.hash(
    first,
    second,
    third,
    fourth,
    fifth,
    sixth,
    muted,
    positive,
    middle,
    negative,
    sequential,
  );
}
