import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_scale.dart';

/// An ordinal scale that maps discrete string categories to pixel positions at
/// the center of equal-width bands.
///
/// {@category Foundation}
@immutable
class OiCategoryScale {
  /// Creates an [OiCategoryScale].
  const OiCategoryScale({
    required this.domain,
    required this.rangeMin,
    required this.rangeMax,
  });

  /// The ordered list of category labels.
  final List<String> domain;

  /// Minimum pixel position of the output range.
  final double rangeMin;

  /// Maximum pixel position of the output range.
  final double rangeMax;

  /// The type identifier for this scale.
  OiScaleType get type => OiScaleType.category;

  /// The width of each category band in pixels.
  double get step => domain.isEmpty ? 0 : (rangeMax - rangeMin) / domain.length;

  /// Maps a category [value] to the center pixel of its band.
  ///
  /// Returns [rangeMin] for unknown categories.
  double toPixel(String value) {
    final idx = domain.indexOf(value);
    if (idx < 0) return rangeMin;
    return rangeMin + (idx + 0.5) * step;
  }

  /// Returns the category nearest to the given pixel position.
  ///
  /// Returns an empty string when [domain] is empty.
  String fromPixel(double pixel) {
    if (domain.isEmpty) return '';
    final s = step;
    final idx = ((pixel - rangeMin) / s).floor().clamp(0, domain.length - 1);
    return domain[idx];
  }

  /// Generates one tick per category.
  List<OiScaleTick<String>> buildTicks() =>
      domain.map((v) => OiScaleTick(value: v)).toList();

  /// Returns a copy with any overridden fields.
  OiCategoryScale copyWith({
    List<String>? domain,
    double? rangeMin,
    double? rangeMax,
  }) {
    return OiCategoryScale(
      domain: domain ?? this.domain,
      rangeMin: rangeMin ?? this.rangeMin,
      rangeMax: rangeMax ?? this.rangeMax,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiCategoryScale &&
          runtimeType == other.runtimeType &&
          _listEquals(domain, other.domain) &&
          rangeMin == other.rangeMin &&
          rangeMax == other.rangeMax;

  @override
  int get hashCode => Object.hash(Object.hashAll(domain), rangeMin, rangeMax);

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
