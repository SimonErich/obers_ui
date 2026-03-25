import 'package:flutter/foundation.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_scale.dart';

/// A time scale that maps [DateTime] values linearly to a pixel range.
///
/// Internally converts dates to milliseconds since epoch for linear
/// interpolation, then generates human-readable tick marks at
/// appropriate intervals (seconds, minutes, hours, days, months, years).
///
/// {@category Foundation}
@immutable
class OiTimeScale extends OiChartScale<DateTime> {
  /// Creates an [OiTimeScale].
  const OiTimeScale({
    required this.domainMin,
    required this.domainMax,
    required super.rangeMin,
    required super.rangeMax,
    super.clamp,
  });

  /// Creates an [OiTimeScale] from a list of [DateTime] values.
  factory OiTimeScale.fromData({
    required List<DateTime> values,
    required double rangeMin,
    required double rangeMax,
    bool clamp = false,
  }) {
    if (values.isEmpty) {
      final now = DateTime.now();
      return OiTimeScale(
        domainMin: now.subtract(const Duration(days: 1)),
        domainMax: now,
        rangeMin: rangeMin,
        rangeMax: rangeMax,
        clamp: clamp,
      );
    }
    var lo = values.first;
    var hi = values.first;
    for (final v in values) {
      if (v.isBefore(lo)) lo = v;
      if (v.isAfter(hi)) hi = v;
    }
    if (lo == hi) {
      lo = lo.subtract(const Duration(hours: 12));
      hi = hi.add(const Duration(hours: 12));
    }
    return OiTimeScale(
      domainMin: lo,
      domainMax: hi,
      rangeMin: rangeMin,
      rangeMax: rangeMax,
      clamp: clamp,
    );
  }

  /// The earliest date in the domain.
  final DateTime domainMin;

  /// The latest date in the domain.
  final DateTime domainMax;

  @override
  OiScaleType get type => OiScaleType.time;

  int get _msMin => domainMin.millisecondsSinceEpoch;
  int get _msMax => domainMax.millisecondsSinceEpoch;
  int get _msExtent => _msMax - _msMin;

  @override
  double get atom => _msExtent == 0 ? 0 : rangeExtent.abs() / _msExtent.abs();

  @override
  double toPixel(DateTime value) {
    if (_msExtent == 0) return rangeMin;
    final t = (value.millisecondsSinceEpoch - _msMin) / _msExtent;
    return clampPixel(rangeMin + t * rangeExtent);
  }

  @override
  DateTime fromPixel(double position) {
    if (rangeExtent == 0) return domainMin;
    final t = (position - rangeMin) / rangeExtent;
    final ms = _msMin + (t * _msExtent).round();
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  @override
  List<OiTick<DateTime>> buildTicks({int count = 5}) {
    if (count < 1) return const [];
    final durationMs = _msExtent;
    if (durationMs <= 0) {
      return [OiTick(value: domainMin, position: toPixel(domainMin))];
    }
    final interval = _bestInterval(durationMs, count);
    final ticks = <OiTick<DateTime>>[];
    final start = _ceilTo(domainMin, interval);
    var current = start;
    while (!current.isAfter(domainMax) && ticks.length < count * 2) {
      ticks.add(OiTick(value: current, position: toPixel(current)));
      current = _addInterval(current, interval);
    }
    return ticks;
  }

  @override
  OiTimeScale withDomain(DateTime min, DateTime max) {
    return OiTimeScale(
      domainMin: min,
      domainMax: max,
      rangeMin: rangeMin,
      rangeMax: rangeMax,
      clamp: clamp,
    );
  }

  /// Creates a copy with optionally overridden values.
  OiTimeScale copyWith({
    DateTime? domainMin,
    DateTime? domainMax,
    double? rangeMin,
    double? rangeMax,
    bool? clamp,
  }) {
    return OiTimeScale(
      domainMin: domainMin ?? this.domainMin,
      domainMax: domainMax ?? this.domainMax,
      rangeMin: rangeMin ?? this.rangeMin,
      rangeMax: rangeMax ?? this.rangeMax,
      clamp: clamp ?? this.clamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiTimeScale &&
          other.domainMin == domainMin &&
          other.domainMax == domainMax &&
          other.rangeMin == rangeMin &&
          other.rangeMax == rangeMax &&
          other.clamp == clamp;

  @override
  int get hashCode =>
      Object.hashAll([domainMin, domainMax, rangeMin, rangeMax, clamp]);

  // ── Interval helpers ────────────────────────────────────────────────────

  static const _intervals = <(Duration, _TimeUnit)>[
    (Duration(seconds: 1), _TimeUnit.second),
    (Duration(seconds: 5), _TimeUnit.second),
    (Duration(seconds: 15), _TimeUnit.second),
    (Duration(seconds: 30), _TimeUnit.second),
    (Duration(minutes: 1), _TimeUnit.minute),
    (Duration(minutes: 5), _TimeUnit.minute),
    (Duration(minutes: 15), _TimeUnit.minute),
    (Duration(minutes: 30), _TimeUnit.minute),
    (Duration(hours: 1), _TimeUnit.hour),
    (Duration(hours: 3), _TimeUnit.hour),
    (Duration(hours: 6), _TimeUnit.hour),
    (Duration(hours: 12), _TimeUnit.hour),
    (Duration(days: 1), _TimeUnit.day),
    (Duration(days: 7), _TimeUnit.day),
    (Duration(days: 30), _TimeUnit.month),
    (Duration(days: 90), _TimeUnit.month),
    (Duration(days: 180), _TimeUnit.month),
    (Duration(days: 365), _TimeUnit.year),
  ];

  static (Duration, _TimeUnit) _bestInterval(int durationMs, int count) {
    final target = durationMs / count;
    for (final entry in _intervals) {
      if (entry.$1.inMilliseconds >= target) return entry;
    }
    // For very large spans, use year intervals.
    final years = durationMs / (365.25 * 24 * 3600 * 1000);
    final yearStep = _niceYearStep(years / count);
    return (Duration(days: (yearStep * 365.25).round()), _TimeUnit.year);
  }

  static int _niceYearStep(double rough) {
    if (rough <= 1) return 1;
    if (rough <= 2) return 2;
    if (rough <= 5) return 5;
    if (rough <= 10) return 10;
    if (rough <= 25) return 25;
    if (rough <= 50) return 50;
    return (rough / 100).ceil() * 100;
  }

  static DateTime _ceilTo(DateTime dt, (Duration, _TimeUnit) interval) {
    final unit = interval.$2;
    switch (unit) {
      case _TimeUnit.second:
        final s = interval.$1.inSeconds;
        final sec = (dt.second / s).ceil() * s;
        final base = DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute);
        return base.add(Duration(seconds: sec));
      case _TimeUnit.minute:
        final m = interval.$1.inMinutes;
        final min = (dt.minute / m).ceil() * m;
        return DateTime(dt.year, dt.month, dt.day, dt.hour, min);
      case _TimeUnit.hour:
        final h = interval.$1.inHours;
        final hour = (dt.hour / h).ceil() * h;
        return DateTime(dt.year, dt.month, dt.day, hour);
      case _TimeUnit.day:
        if (dt.hour == 0 && dt.minute == 0 && dt.second == 0) return dt;
        return DateTime(dt.year, dt.month, dt.day + 1);
      case _TimeUnit.month:
        if (dt.day == 1 && dt.hour == 0) return dt;
        final nextMonth = dt.month + 1;
        return DateTime(dt.year, nextMonth);
      case _TimeUnit.year:
        if (dt.month == 1 && dt.day == 1 && dt.hour == 0) return dt;
        return DateTime(dt.year + 1);
    }
  }

  static DateTime _addInterval(DateTime dt, (Duration, _TimeUnit) interval) {
    final unit = interval.$2;
    switch (unit) {
      case _TimeUnit.second:
      case _TimeUnit.minute:
      case _TimeUnit.hour:
      case _TimeUnit.day:
        return dt.add(interval.$1);
      case _TimeUnit.month:
        final months = (interval.$1.inDays / 30).round();
        final m = dt.month + months;
        return DateTime(dt.year, m, dt.day, dt.hour);
      case _TimeUnit.year:
        final years = (interval.$1.inDays / 365.25).round();
        return DateTime(dt.year + years, dt.month, dt.day);
    }
  }
}

enum _TimeUnit { second, minute, hour, day, month, year }
