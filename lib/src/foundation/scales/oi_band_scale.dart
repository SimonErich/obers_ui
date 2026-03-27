import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_scale.dart';

/// Position and width of a single band.
@immutable
class OiBandInfo {
  /// Creates an [OiBandInfo].
  const OiBandInfo({required this.start, required this.width});

  /// The pixel position where this band starts.
  final double start;

  /// The pixel width of this band.
  final double width;
}

/// An ordinal scale that divides a range into bands with configurable padding,
/// suitable for bar charts.
///
/// {@category Foundation}
@immutable
class OiBandScale {
  /// Creates an [OiBandScale].
  const OiBandScale({
    required this.domain,
    required this.rangeMin,
    required this.rangeMax,
    this.paddingInner = 0.1,
    this.paddingOuter = 0.1,
  });

  /// The ordered list of category labels.
  final List<String> domain;

  /// Minimum pixel position of the output range.
  final double rangeMin;

  /// Maximum pixel position of the output range.
  final double rangeMax;

  /// Fraction of the step size used as gap between bands (0..1).
  final double paddingInner;

  /// Fraction of the step size used as outer margin (0..1).
  final double paddingOuter;

  /// The type identifier for this scale.
  OiScaleType get type => OiScaleType.band;

  bool get _inverted => rangeMax < rangeMin;
  double get _low => math.min(rangeMin, rangeMax);
  double get _high => math.max(rangeMin, rangeMax);

  /// The pixel step between band start positions.
  double get _step {
    final n = domain.length;
    if (n == 0) return 0;
    return (_high - _low) / math.max(1, n - paddingInner + paddingOuter * 2);
  }

  /// The pixel width of each band.
  double get bandwidth {
    if (domain.isEmpty) return 0;
    return _step * (1 - paddingInner);
  }

  double _startOf(int index) => _low + _step * (paddingOuter + index);

  /// Maps a category [value] to the pixel start of its band.
  ///
  /// Returns [rangeMin] for unknown categories.
  double toPixel(String value) {
    final indices = _effectiveIndices();
    final idx = domain.indexOf(value);
    if (idx < 0) return rangeMin;
    return indices[idx];
  }

  /// Returns the center pixel of the band for [value].
  double bandCenter(String value) => toPixel(value) + bandwidth / 2;

  /// Returns [OiBandInfo] for the band at [index], clamped to valid range.
  OiBandInfo bandAt(int index) {
    final indices = _effectiveIndices();
    final clamped = index.clamp(0, domain.length - 1);
    return OiBandInfo(start: indices[clamped], width: bandwidth);
  }

  /// Returns the category whose band contains [pixel], or the nearest one.
  String fromPixel(double pixel) {
    if (domain.isEmpty) return '';
    final indices = _effectiveIndices();
    final bw = bandwidth;
    // Find which band the pixel falls into.
    for (var i = 0; i < indices.length; i++) {
      final start = indices[i];
      if (pixel >= start && pixel <= start + bw) return domain[_domainIndex(i)];
    }
    // Clamp to nearest band start.
    var best = 0;
    var bestDist = double.infinity;
    for (var i = 0; i < indices.length; i++) {
      final d = (pixel - indices[i]).abs();
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    return domain[_domainIndex(best)];
  }

  /// Generates one tick per category positioned at the band center.
  List<OiScaleTick<String>> buildTicks() =>
      domain.map((v) => OiScaleTick(value: v)).toList();

  /// Returns a copy with any overridden fields.
  OiBandScale copyWith({
    List<String>? domain,
    double? rangeMin,
    double? rangeMax,
    double? paddingInner,
    double? paddingOuter,
  }) {
    return OiBandScale(
      domain: domain ?? this.domain,
      rangeMin: rangeMin ?? this.rangeMin,
      rangeMax: rangeMax ?? this.rangeMax,
      paddingInner: paddingInner ?? this.paddingInner,
      paddingOuter: paddingOuter ?? this.paddingOuter,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiBandScale &&
          runtimeType == other.runtimeType &&
          _listEquals(domain, other.domain) &&
          rangeMin == other.rangeMin &&
          rangeMax == other.rangeMax &&
          paddingInner == other.paddingInner &&
          paddingOuter == other.paddingOuter;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(domain),
    rangeMin,
    rangeMax,
    paddingInner,
    paddingOuter,
  );

  // ── Helpers ─────────────────────────────────────────────────────────────────

  // Pixel start of each band in draw order (may be reversed for inverted range).
  List<double> _effectiveIndices() {
    final starts = List.generate(domain.length, _startOf);
    return _inverted ? starts.reversed.toList() : starts;
  }

  // Maps draw-order index back to domain index.
  // _effectiveIndices already reverses positions so indices[i] maps to domain[i].
  int _domainIndex(int drawIndex) => drawIndex;

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
