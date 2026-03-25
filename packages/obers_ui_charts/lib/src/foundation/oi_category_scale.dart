import 'package:flutter/foundation.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_scale.dart';

/// A category scale that maps discrete string values to point positions.
///
/// Each category is placed at the center of an equal subdivision of the
/// output range. This is suitable for categorical axes where items have
/// no inherent width (use `OiBandScale` when width matters).
///
/// {@category Foundation}
@immutable
class OiCategoryScale extends OiChartScale<String> {
  /// Creates an [OiCategoryScale].
  const OiCategoryScale({
    required this.domain,
    required super.rangeMin,
    required super.rangeMax,
    super.clamp,
  });

  /// The ordered list of category values.
  final List<String> domain;

  @override
  OiScaleType get type => OiScaleType.category;

  /// The step distance between adjacent category positions.
  double get step => domain.isEmpty ? 0 : rangeExtent / domain.length;

  @override
  double get atom => step.abs();

  @override
  double toPixel(String value) {
    final index = domain.indexOf(value);
    if (index < 0) return rangeMin;
    return clampPixel(rangeMin + (index + 0.5) * step);
  }

  @override
  String fromPixel(double position) {
    if (domain.isEmpty) return '';
    final s = step;
    if (s == 0) return domain.first;
    var index = ((position - rangeMin) / s - 0.5).round();
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
  OiCategoryScale withDomain(String min, String max) {
    final startIdx = domain.indexOf(min);
    final endIdx = domain.indexOf(max);
    if (startIdx == -1 || endIdx == -1) return this;
    final sub = domain.sublist(
      startIdx < endIdx ? startIdx : endIdx,
      (startIdx < endIdx ? endIdx : startIdx) + 1,
    );
    return OiCategoryScale(
      domain: sub,
      rangeMin: rangeMin,
      rangeMax: rangeMax,
      clamp: clamp,
    );
  }

  /// Creates a copy with optionally overridden values.
  OiCategoryScale copyWith({
    List<String>? domain,
    double? rangeMin,
    double? rangeMax,
    bool? clamp,
  }) {
    return OiCategoryScale(
      domain: domain ?? this.domain,
      rangeMin: rangeMin ?? this.rangeMin,
      rangeMax: rangeMax ?? this.rangeMax,
      clamp: clamp ?? this.clamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiCategoryScale &&
          listEquals(other.domain, domain) &&
          other.rangeMin == rangeMin &&
          other.rangeMax == rangeMax &&
          other.clamp == clamp;

  @override
  int get hashCode =>
      Object.hashAll([Object.hashAll(domain), rangeMin, rangeMax, clamp]);
}
