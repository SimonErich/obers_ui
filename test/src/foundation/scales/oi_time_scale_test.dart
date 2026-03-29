// Tests do not require documentation comments.

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_scale.dart';
import 'package:obers_ui/src/foundation/scales/oi_time_scale.dart';

void main() {
  group('OiTimeScale', () {
    final jan1 = DateTime(2024);
    final jul1 = DateTime(2024, 7);
    final dec31 = DateTime(2024, 12, 31);

    test('type is time', () {
      final scale = OiTimeScale(
        domainMin: jan1,
        domainMax: dec31,
        rangeMin: 0,
        rangeMax: 500,
      );
      expect(scale.type, OiScaleType.time);
    });

    test('toPixel maps start and end correctly', () {
      final scale = OiTimeScale(
        domainMin: jan1,
        domainMax: dec31,
        rangeMin: 0,
        rangeMax: 500,
      );
      expect(scale.toPixel(jan1), closeTo(0, 0.01));
      expect(scale.toPixel(dec31), closeTo(500, 0.01));
    });

    test('toPixel maps midpoint', () {
      final scale = OiTimeScale(
        domainMin: jan1,
        domainMax: dec31,
        rangeMin: 0,
        rangeMax: 500,
      );
      final mid = scale.toPixel(jul1);
      expect(mid, greaterThan(200));
      expect(mid, lessThan(300));
    });

    test('fromPixel is inverse of toPixel', () {
      final scale = OiTimeScale(
        domainMin: jan1,
        domainMax: dec31,
        rangeMin: 0,
        rangeMax: 500,
      );
      final pixel = scale.toPixel(jul1);
      final recovered = scale.fromPixel(pixel);
      // Allow 1 second tolerance due to rounding.
      expect(recovered.difference(jul1).inSeconds.abs(), lessThan(2));
    });

    test('buildTicks returns non-empty list', () {
      final scale = OiTimeScale(
        domainMin: jan1,
        domainMax: dec31,
        rangeMin: 0,
        rangeMax: 500,
      );
      final ticks = scale.buildTicks();
      expect(ticks, isNotEmpty);
      for (final tick in ticks) {
        expect(tick.value.isAfter(jan1) || tick.value == jan1, isTrue);
        expect(tick.value.isBefore(dec31) || tick.value == dec31, isTrue);
      }
    });

    test('buildTicks with small time range', () {
      final start = DateTime(2024, 6, 15, 10);
      final end = DateTime(2024, 6, 15, 12);
      final scale = OiTimeScale(
        domainMin: start,
        domainMax: end,
        rangeMin: 0,
        rangeMax: 400,
      );
      final ticks = scale.buildTicks(count: 4);
      expect(ticks, isNotEmpty);
    });

    test('fromData creates scale from dates', () {
      final dates = [DateTime(2024, 3), DateTime(2024, 6), DateTime(2024, 9)];
      final scale = OiTimeScale.fromData(
        values: dates,
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(
        scale.domainMin.isBefore(dates.first) || scale.domainMin == dates.first,
        isTrue,
      );
      expect(
        scale.domainMax.isAfter(dates.last) || scale.domainMax == dates.last,
        isTrue,
      );
    });

    test('fromData with empty values uses now ± 1 day', () {
      final scale = OiTimeScale.fromData(
        values: const [],
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(scale.domainMin.isBefore(scale.domainMax), isTrue);
    });

    test('fromData with single value expands domain', () {
      final single = DateTime(2024, 6, 15);
      final scale = OiTimeScale.fromData(
        values: [single],
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(scale.domainMin.isBefore(single), isTrue);
      expect(scale.domainMax.isAfter(single), isTrue);
    });

    test('copyWith returns new instance', () {
      final scale = OiTimeScale(
        domainMin: jan1,
        domainMax: dec31,
        rangeMin: 0,
        rangeMax: 500,
      );
      final copy = scale.copyWith(rangeMax: 800);
      expect(copy.rangeMax, 800);
      expect(copy.domainMin, jan1);
    });

    test('equality', () {
      final a = OiTimeScale(
        domainMin: jan1,
        domainMax: dec31,
        rangeMin: 0,
        rangeMax: 500,
      );
      final b = OiTimeScale(
        domainMin: jan1,
        domainMax: dec31,
        rangeMin: 0,
        rangeMax: 500,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('clamp restricts output', () {
      final scale = OiTimeScale(
        domainMin: jan1,
        domainMax: dec31,
        rangeMin: 0,
        rangeMax: 500,
        clamp: true,
      );
      final before = DateTime(2023);
      final after = DateTime(2026);
      expect(scale.toPixel(before), 0);
      expect(scale.toPixel(after), 500);
    });
  });
}
