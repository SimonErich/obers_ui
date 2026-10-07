import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:obers_ui/src/foundation/theme/color/oi_semantic_color_interpolation.dart';

/// A fixed, deeply immutable six-color sequential ramp.
///
/// Values may be raw extended sRGB; no gamut mapping is performed.
///
/// {@category Foundation}
@immutable
class OiColorRamp {
  /// Creates explicitly authored semantic colors.
  const OiColorRamp({
    required this.first,
    required this.second,
    required this.third,
    required this.fourth,
    required this.fifth,
    required this.sixth,
  });

  /// Interpolates raw sRGB with premultiplied alpha, without gamut clipping.
  ///
  /// Exact endpoints are retained. Optional values carry a sole endpoint.
  /// Throws [ArgumentError] for fractions outside finite 0–1.
  factory OiColorRamp.lerp(
    OiColorRamp first,
    OiColorRamp second,
    double fraction,
  ) {
    if (fraction == 0) return first;
    if (fraction == 1) return second;
    Color mix(Color firstColor, Color secondColor) =>
        OiSemanticColorInterpolation.color(firstColor, secondColor, fraction);
    return OiColorRamp(
      first: mix(first.first, second.first),
      second: mix(first.second, second.second),
      third: mix(first.third, second.third),
      fourth: mix(first.fourth, second.fourth),
      fifth: mix(first.fifth, second.fifth),
      sixth: mix(first.sixth, second.sixth),
    );
  }

  /// Sequential color 1.
  final Color first;

  /// Sequential color 2.
  final Color second;

  /// Sequential color 3.
  final Color third;

  /// Sequential color 4.
  final Color fourth;

  /// Sequential color 5.
  final Color fifth;

  /// Sequential color 6.
  final Color sixth;

  /// Returns an independent value with supplied colors overridden.
  OiColorRamp copyWith({
    Color? first,
    Color? second,
    Color? third,
    Color? fourth,
    Color? fifth,
    Color? sixth,
  }) => OiColorRamp(
    first: first ?? this.first,
    second: second ?? this.second,
    third: third ?? this.third,
    fourth: fourth ?? this.fourth,
    fifth: fifth ?? this.fifth,
    sixth: sixth ?? this.sixth,
  );

  /// An immutable ordered view; no mutable collection is retained.
  List<Color> get colors => List<Color>.unmodifiable([
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
      other is OiColorRamp &&
          other.first == first &&
          other.second == second &&
          other.third == third &&
          other.fourth == fourth &&
          other.fifth == fifth &&
          other.sixth == sixth;

  @override
  int get hashCode => Object.hash(
    first,
    second,
    third,
    fourth,
    fifth,
    sixth,
  );
}
