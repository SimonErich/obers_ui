import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_scale.dart';

/// A band scale that maps discrete string values to pixel bands with width.
///
/// Each category occupies a band of equal width within the output range.
/// Configurable inner and outer padding control spacing between and around
/// bands.
///
/// Use [bandwidth] to get the width of each band for rendering bars or
/// similar visual marks.
///
/// {@category Foundation}
@immutable
class OiBandScale extends OiChartScale<String> {
  /// Creates an [OiBandScale].
  const OiBandScale({
    required this.domain,
    required super.rangeMin,
    required super.rangeMax,
    super.clamp,
    this.paddingInner = 0.1,
    this.paddingOuter = 0.05,
  });

  /// The ordered list of category values.
  final List<String> domain;

  /// The fraction of step allocated to spacing between bands (0–1).
  final double paddingInner;

  /// The fraction of step allocated to spacing on the outer edges (0–1).
  final double paddingOuter;

  @override
  OiScaleType get type => OiScaleType.band;

  /// The raw step size including padding.
  double get step {
    if (domain.isEmpty) return 0;
    final n = domain.length;
    final effectiveRange =
        rangeExtent.abs() / (n - paddingInner + 2 * paddingOuter);
    return effectiveRange;
  }

  /// The width of each band in pixels.
  double get bandwidth => domain.isEmpty ? 0 : step * (1 - paddingInner);

  /// The offset from rangeMin to the first band start.
  double get _outerOffset => step * paddingOuter;

  @override
  double get atom => bandwidth.abs();

  @override
  double toPixel(String value) {
    final index = domain.indexOf(value);
    if (index < 0) return rangeMin;
    final direction = rangeExtent >= 0 ? 1.0 : -1.0;
    final pos = rangeMin + direction * (_outerOffset + index * step);
    return clampPixel(pos);
  }

  @override
  String fromPixel(double position) {
    if (domain.isEmpty) return '';
    final s = step;
    if (s == 0) return domain.first;
    final direction = rangeExtent >= 0 ? 1.0 : -1.0;
    final index = (((position - rangeMin) * direction - _outerOffset) / s)
        .floor();
    return domain[index.clamp(0, domain.length - 1)];
  }

  /// Returns the pixel position of the band center for the given [value].
  double bandCenter(String value) => toPixel(value) + bandwidth / 2;

  @override
  List<OiTick<String>> buildTicks({int count = 5}) {
    return [
      for (final value in domain)
        OiTick(value: value, position: bandCenter(value)),
    ];
  }

  /// Creates a copy with optionally overridden values.
  OiBandScale copyWith({
    List<String>? domain,
    double? rangeMin,
    double? rangeMax,
    bool? clamp,
    double? paddingInner,
    double? paddingOuter,
  }) {
    return OiBandScale(
      domain: domain ?? this.domain,
      rangeMin: rangeMin ?? this.rangeMin,
      rangeMax: rangeMax ?? this.rangeMax,
      clamp: clamp ?? this.clamp,
      paddingInner: paddingInner ?? this.paddingInner,
      paddingOuter: paddingOuter ?? this.paddingOuter,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiBandScale &&
          listEquals(other.domain, domain) &&
          other.rangeMin == rangeMin &&
          other.rangeMax == rangeMax &&
          other.clamp == clamp &&
          other.paddingInner == paddingInner &&
          other.paddingOuter == paddingOuter;

  @override
  int get hashCode => Object.hashAll([
    Object.hashAll(domain),
    rangeMin,
    rangeMax,
    clamp,
    paddingInner,
    paddingOuter,
  ]);

  /// Returns the band start position and width for the band at [index].
  ({double start, double width}) bandAt(int index) {
    final clamped = math.min(math.max(index, 0), domain.length - 1);
    return (start: toPixel(domain[clamped]), width: bandwidth);
  }
}
