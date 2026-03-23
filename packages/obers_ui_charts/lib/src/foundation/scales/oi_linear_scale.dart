import 'package:flutter/foundation.dart';

/// Maps continuous numeric values from a domain to a range.
///
/// Supports forward mapping ([scale]), inverse mapping ([invert]),
/// and tick generation ([ticks]).
@immutable
class OiLinearScale {
  const OiLinearScale({
    required this.domainMin,
    required this.domainMax,
    required this.rangeMin,
    required this.rangeMax,
    this.clamp = false,
  });

  final double domainMin;
  final double domainMax;
  final double rangeMin;
  final double rangeMax;
  final bool clamp;

  double get _domainSpan {
    final span = domainMax - domainMin;
    return span == 0 ? 1 : span;
  }

  double get _rangeSpan => rangeMax - rangeMin;

  /// Maps a [value] from the domain to the range.
  double scale(double value) {
    final normalized = (value - domainMin) / _domainSpan;
    final result = rangeMin + normalized * _rangeSpan;
    if (clamp) {
      final lo = rangeMin < rangeMax ? rangeMin : rangeMax;
      final hi = rangeMin < rangeMax ? rangeMax : rangeMin;
      return result.clamp(lo, hi);
    }
    return result;
  }

  /// Maps a [value] from the range back to the domain.
  double invert(double value) {
    final rangeSpan = _rangeSpan;
    if (rangeSpan == 0) return domainMin;
    final normalized = (value - rangeMin) / rangeSpan;
    return domainMin + normalized * _domainSpan;
  }

  /// Generates [count] evenly spaced tick values spanning the domain.
  List<double> ticks([int count = 5]) {
    if (count <= 0) return [];
    if (count == 1) return [(domainMin + domainMax) / 2];

    return List.generate(count, (i) {
      final fraction = i / (count - 1);
      return domainMin + fraction * (domainMax - domainMin);
    });
  }

  OiLinearScale copyWith({
    double? domainMin,
    double? domainMax,
    double? rangeMin,
    double? rangeMax,
    bool? clamp,
  }) => OiLinearScale(
    domainMin: domainMin ?? this.domainMin,
    domainMax: domainMax ?? this.domainMax,
    rangeMin: rangeMin ?? this.rangeMin,
    rangeMax: rangeMax ?? this.rangeMax,
    clamp: clamp ?? this.clamp,
  );
}
