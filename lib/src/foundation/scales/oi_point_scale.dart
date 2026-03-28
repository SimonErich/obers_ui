import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_scale.dart';

/// An ordinal scale that maps discrete categories to individual pixel points,
/// suitable for line/scatter charts.
///
/// Unlike a band scale, there is no band width — each category is a point.
/// The [padding] controls outer margin as a fraction of the step size.
///
/// {@category Foundation}
@immutable
class OiPointScale {
  /// Creates an [OiPointScale].
  const OiPointScale({
    required this.domain,
    required this.rangeMin,
    required this.rangeMax,
    this.padding = 0.5,
  });

  /// The ordered list of category labels.
  final List<String> domain;

  /// Minimum pixel position of the output range.
  final double rangeMin;

  /// Maximum pixel position of the output range.
  final double rangeMax;

  /// Outer padding as a fraction of the step size (default 0.5).
  final double padding;

  /// The type identifier for this scale.
  OiScaleType get type => OiScaleType.point;

  double get _step {
    final n = domain.length;
    if (n <= 1) return rangeMax - rangeMin;
    return (rangeMax - rangeMin) / (n - 1 + 2 * padding);
  }

  double _pixelOf(int index) {
    if (domain.length == 1) return (rangeMin + rangeMax) / 2;
    return rangeMin + _step * (padding + index);
  }

  /// Maps a category [value] to its pixel position.
  ///
  /// Returns [rangeMin] for unknown categories.
  double toPixel(String value) {
    final idx = domain.indexOf(value);
    if (idx < 0) return rangeMin;
    return _pixelOf(idx);
  }

  /// Returns the category nearest to the given pixel position.
  ///
  /// Returns an empty string when [domain] is empty.
  String fromPixel(double pixel) {
    if (domain.isEmpty) return '';
    var best = 0;
    var bestDist = double.infinity;
    for (var i = 0; i < domain.length; i++) {
      final d = (pixel - _pixelOf(i)).abs();
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    return domain[best];
  }

  /// Generates one tick per category.
  List<OiScaleTick<String>> buildTicks() =>
      domain.map((v) => OiScaleTick(value: v)).toList();

  /// Returns a copy with any overridden fields.
  OiPointScale copyWith({
    List<String>? domain,
    double? rangeMin,
    double? rangeMax,
    double? padding,
  }) {
    return OiPointScale(
      domain: domain ?? this.domain,
      rangeMin: rangeMin ?? this.rangeMin,
      rangeMax: rangeMax ?? this.rangeMax,
      padding: padding ?? this.padding,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiPointScale &&
          runtimeType == other.runtimeType &&
          _listEquals(domain, other.domain) &&
          rangeMin == other.rangeMin &&
          rangeMax == other.rangeMax &&
          padding == other.padding;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(domain), rangeMin, rangeMax, padding);

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
