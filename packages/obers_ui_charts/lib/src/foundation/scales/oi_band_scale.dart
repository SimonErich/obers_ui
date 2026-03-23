import 'package:flutter/foundation.dart';

/// Maps categorical values to a continuous range with uniform band widths.
///
/// Each category occupies a band of equal width within the range.
@immutable
class OiBandScale {
  const OiBandScale({
    required this.domain,
    required this.rangeMin,
    required this.rangeMax,
    this.paddingInner = 0.1,
    this.paddingOuter = 0.05,
  });

  final List<String> domain;
  final double rangeMin;
  final double rangeMax;
  final double paddingInner;
  final double paddingOuter;

  double get _totalRange => rangeMax - rangeMin;

  /// The width of each band (category).
  double get bandwidth {
    if (domain.isEmpty) return 0;
    final n = domain.length;
    final outerSpace = _totalRange * paddingOuter * 2;
    final innerSpace = n > 1 ? _totalRange * paddingInner * (n - 1) / n : 0;
    final available = _totalRange - outerSpace - innerSpace;
    return available / n;
  }

  /// The distance from the start of one band to the start of the next.
  double get _step {
    if (domain.isEmpty) return 0;
    final n = domain.length;
    final outerSpace = _totalRange * paddingOuter * 2;
    return n == 1 ? 0 : (_totalRange - outerSpace - bandwidth) / (n - 1);
  }

  /// Returns the start position of the band for [value].
  double scale(String value) {
    if (domain.isEmpty) return 0;
    final index = domain.indexOf(value);
    if (index < 0) return 0;
    final offset = _totalRange * paddingOuter;
    if (domain.length == 1) return rangeMin + offset;
    return rangeMin + offset + index * _step;
  }

  /// Returns the nearest band label for the given range [value].
  String invert(double value) {
    if (domain.isEmpty) return '';
    final offset = _totalRange * paddingOuter;
    final step = _step;
    if (step == 0) return domain.first;
    final index =
        ((value - rangeMin - offset) / step).round().clamp(0, domain.length - 1);
    return domain[index];
  }

  /// Returns all domain values (the categories).
  List<String> get ticks => List<String>.unmodifiable(domain);
}
