import 'package:flutter/foundation.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_scale.dart';

/// A point scale that maps discrete string values to evenly-spaced
/// pixel positions.
///
/// Unlike `OiBandScale`, a point scale assigns zero-width positions
/// with configurable outer padding. The points are evenly distributed
/// across the range.
///
/// {@category Foundation}
@immutable
class OiPointScale extends OiChartScale<String> {
  /// Creates an [OiPointScale].
  const OiPointScale({
    required this.domain,
    required super.rangeMin,
    required super.rangeMax,
    super.clamp,
    this.padding = 0.5,
  });

  /// The ordered list of category values.
  final List<String> domain;

  /// The fraction of step allocated to outer padding on each side (0–1).
  final double padding;

  @override
  OiScaleType get type => OiScaleType.point;

  /// The distance between adjacent point positions.
  double get step {
    if (domain.length <= 1) return 0;
    return rangeExtent / (domain.length - 1 + 2 * padding);
  }

  /// The offset from rangeMin to the first point.
  double get _offset {
    if (domain.length <= 1) return rangeExtent / 2;
    return step * padding;
  }

  @override
  double get atom => step.abs();

  @override
  double toPixel(String value) {
    final index = domain.indexOf(value);
    if (index < 0) return rangeMin;
    return clampPixel(rangeMin + _offset + index * step);
  }

  @override
  String fromPixel(double position) {
    if (domain.isEmpty) return '';
    if (domain.length == 1) return domain.first;
    final s = step;
    if (s == 0) return domain.first;
    var index = ((position - rangeMin - _offset) / s).round();
    index = index.clamp(0, domain.length - 1);
    return domain[index];
  }

  @override
  List<OiTick<String>> buildTicks({int count = 5}) {
    return [
      for (final value in domain)
        OiTick(value: value, position: toPixel(value)),
    ];
  }

  @override
  OiPointScale withDomain(String min, String max) {
    final startIdx = domain.indexOf(min);
    final endIdx = domain.indexOf(max);
    if (startIdx == -1 || endIdx == -1) return this;
    final sub = domain.sublist(
      startIdx < endIdx ? startIdx : endIdx,
      (startIdx < endIdx ? endIdx : startIdx) + 1,
    );
    return OiPointScale(
      domain: sub,
      rangeMin: rangeMin,
      rangeMax: rangeMax,
      clamp: clamp,
      padding: padding,
    );
  }

  /// Creates a copy with optionally overridden values.
  OiPointScale copyWith({
    List<String>? domain,
    double? rangeMin,
    double? rangeMax,
    bool? clamp,
    double? padding,
  }) {
    return OiPointScale(
      domain: domain ?? this.domain,
      rangeMin: rangeMin ?? this.rangeMin,
      rangeMax: rangeMax ?? this.rangeMax,
      clamp: clamp ?? this.clamp,
      padding: padding ?? this.padding,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiPointScale &&
          listEquals(other.domain, domain) &&
          other.rangeMin == rangeMin &&
          other.rangeMax == rangeMax &&
          other.clamp == clamp &&
          other.padding == padding;

  @override
  int get hashCode => Object.hashAll([
    Object.hashAll(domain),
    rangeMin,
    rangeMax,
    clamp,
    padding,
  ]);
}
