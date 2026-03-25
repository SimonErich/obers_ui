import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

void main() {
  // ── OiLinearScale ──────────────────────────────────────────────────────────

  group('OiLinearScale', () {
    const scale = OiLinearScale(
      domainMin: 0,
      domainMax: 100,
      rangeMin: 0,
      rangeMax: 400,
    );

    test('toPixel maps domain midpoint to range midpoint', () {
      expect(scale.toPixel(50), 200);
    });

    test('toPixel maps domainMin to rangeMin', () {
      expect(scale.toPixel(0), 0);
    });

    test('toPixel maps domainMax to rangeMax', () {
      expect(scale.toPixel(100), 400);
    });

    test('fromPixel inverts toPixel', () {
      expect(scale.fromPixel(200), 50);
      expect(scale.fromPixel(0), 0);
      expect(scale.fromPixel(400), 100);
    });

    test('fromPixel handles zero-extent range by returning domainMin', () {
      const degenerate = OiLinearScale(
        domainMin: 10,
        domainMax: 20,
        rangeMin: 50,
        rangeMax: 50,
      );
      expect(degenerate.fromPixel(50), 10);
    });

    test('toPixel with degenerate domain returns rangeMin', () {
      const degenerate = OiLinearScale(
        domainMin: 5,
        domainMax: 5,
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(degenerate.toPixel(5), 0);
    });

    test('clamp prevents out-of-range pixel values', () {
      const clamped = OiLinearScale(
        domainMin: 0,
        domainMax: 100,
        rangeMin: 0,
        rangeMax: 400,
        clamp: true,
      );
      expect(clamped.toPixel(-10), 0);
      expect(clamped.toPixel(110), 400);
    });

    test('buildTicks returns ticks within domain', () {
      final ticks = scale.buildTicks();
      expect(ticks, isNotEmpty);
      for (final tick in ticks) {
        expect(tick.value, greaterThanOrEqualTo(scale.domainMin));
        expect(tick.value, lessThanOrEqualTo(scale.domainMax));
      }
    });

    test('buildTicks with count 0 returns empty list', () {
      expect(scale.buildTicks(count: 0), isEmpty);
    });

    test('buildTicks with count 1 returns single midpoint tick', () {
      final ticks = scale.buildTicks(count: 1);
      expect(ticks.length, 1);
      expect(ticks.first.value, closeTo(50, 0.001));
    });

    test('atom is pixels per domain unit', () {
      expect(scale.atom, closeTo(4, 0.001)); // 400 / 100
    });

    test('fromData constructs scale from value list', () {
      final s = OiLinearScale.fromData(
        values: const [10, 20, 30, 40, 50],
        rangeMin: 0,
        rangeMax: 100,
        nice: false,
      );
      expect(s.domainMin, 10);
      expect(s.domainMax, 50);
    });

    test('fromData with empty list uses default domain', () {
      final s = OiLinearScale.fromData(
        values: const <double>[],
        rangeMin: 0,
        rangeMax: 100,
      );
      expect(s.domainMin, 0);
      expect(s.domainMax, 1);
    });

    test('fromData with single value expands domain by ±1', () {
      final s = OiLinearScale.fromData(
        values: const [5.0],
        rangeMin: 0,
        rangeMax: 100,
        nice: false,
      );
      expect(s.domainMin, 4);
      expect(s.domainMax, 6);
    });

    test('inverted range (rangeMax < rangeMin) maps correctly', () {
      const inverted = OiLinearScale(
        domainMin: 0,
        domainMax: 100,
        rangeMin: 400,
        rangeMax: 0,
      );
      // domainMin → rangeMin (400), domainMax → rangeMax (0)
      expect(inverted.toPixel(0), 400);
      expect(inverted.toPixel(100), 0);
      expect(inverted.toPixel(50), 200);
    });
  });

  // ── OiLogarithmicScale ─────────────────────────────────────────────────────

  group('OiLogarithmicScale', () {
    const scale = OiLogarithmicScale(
      domainMin: 1,
      domainMax: 1000,
      rangeMin: 0,
      rangeMax: 300,
    );

    test('toPixel maps powers of 10 to equally spaced pixel positions', () {
      // log10(1)=0, log10(10)=1, log10(100)=2, log10(1000)=3
      // Normalized: 0, 1/3, 2/3, 1 → pixels: 0, 100, 200, 300
      expect(scale.toPixel(1), closeTo(0, 0.001));
      expect(scale.toPixel(10), closeTo(100, 0.001));
      expect(scale.toPixel(100), closeTo(200, 0.001));
      expect(scale.toPixel(1000), closeTo(300, 0.001));
    });

    test('fromPixel inverts toPixel', () {
      expect(scale.fromPixel(0), closeTo(1, 0.001));
      expect(scale.fromPixel(100), closeTo(10, 0.001));
      expect(scale.fromPixel(300), closeTo(1000, 0.001));
    });

    test('toPixel with non-positive value returns rangeMin', () {
      expect(scale.toPixel(0), scale.rangeMin);
      expect(scale.toPixel(-1), scale.rangeMin);
    });

    test('buildTicks generates one tick per power of base', () {
      final ticks = scale.buildTicks();
      final values = ticks.map((t) => t.value).toList();
      expect(values, contains(1.0));
      expect(values, contains(10.0));
      expect(values, contains(100.0));
      expect(values, contains(1000.0));
    });

    test('custom base 2 maps correctly', () {
      const s = OiLogarithmicScale(
        domainMin: 1,
        domainMax: 8,
        rangeMin: 0,
        rangeMax: 300,
        base: 2,
      );
      // log2(1)=0, log2(2)=1, log2(4)=2, log2(8)=3
      expect(s.toPixel(1), closeTo(0, 0.001));
      expect(s.toPixel(2), closeTo(100, 0.001));
      expect(s.toPixel(4), closeTo(200, 0.001));
      expect(s.toPixel(8), closeTo(300, 0.001));
    });

    test('fromData constructs scale from positive values', () {
      final s = OiLogarithmicScale.fromData(
        values: const [1, 10, 100],
        rangeMin: 0,
        rangeMax: 200,
      );
      expect(s.domainMin, greaterThan(0));
      expect(s.domainMax, greaterThanOrEqualTo(100));
    });

    test('fromData with empty list defaults to 1–10', () {
      final s = OiLogarithmicScale.fromData(
        values: const <double>[],
        rangeMin: 0,
        rangeMax: 100,
      );
      expect(s.domainMin, 1);
      expect(s.domainMax, 10);
    });
  });

  // ── OiTimeScale ────────────────────────────────────────────────────────────

  group('OiTimeScale', () {
    final start = DateTime(2024);
    final end = DateTime(2024, 1, 11); // 10 days later

    late OiTimeScale scale;

    setUp(() {
      scale = OiTimeScale(
        domainMin: start,
        domainMax: end,
        rangeMin: 0,
        rangeMax: 400,
      );
    });

    test('toPixel maps domainMin to rangeMin', () {
      expect(scale.toPixel(start), closeTo(0, 0.001));
    });

    test('toPixel maps domainMax to rangeMax', () {
      expect(scale.toPixel(end), closeTo(400, 0.001));
    });

    test('toPixel maps midpoint date to range midpoint', () {
      final mid = DateTime(2024, 1, 6); // halfway through 10-day span
      expect(scale.toPixel(mid), closeTo(200, 0.1));
    });

    test('fromPixel inverts toPixel at boundaries', () {
      final recoveredMin = scale.fromPixel(0);
      final recoveredMax = scale.fromPixel(400);
      expect(
        recoveredMin.millisecondsSinceEpoch,
        closeTo(start.millisecondsSinceEpoch, 1),
      );
      expect(
        recoveredMax.millisecondsSinceEpoch,
        closeTo(end.millisecondsSinceEpoch, 1),
      );
    });

    test('fromPixel with zero-extent range returns domainMin', () {
      final degenerate = OiTimeScale(
        domainMin: start,
        domainMax: start,
        rangeMin: 0,
        rangeMax: 0,
      );
      expect(degenerate.fromPixel(0), start);
    });

    test('toPixel with degenerate domain returns rangeMin', () {
      final degenerate = OiTimeScale(
        domainMin: start,
        domainMax: start,
        rangeMin: 0,
        rangeMax: 400,
      );
      expect(degenerate.toPixel(start), 0);
    });

    test('buildTicks returns ticks within domain', () {
      final ticks = scale.buildTicks();
      expect(ticks, isNotEmpty);
      for (final tick in ticks) {
        expect(tick.value.isBefore(end.add(const Duration(days: 1))), isTrue);
        expect(
          tick.value.isAfter(start.subtract(const Duration(days: 1))),
          isTrue,
        );
      }
    });

    test('buildTicks with count 0 returns empty list', () {
      expect(scale.buildTicks(count: 0), isEmpty);
    });

    test('fromData constructs scale from DateTime list', () {
      final s = OiTimeScale.fromData(
        values: [
          DateTime(2024, 3),
          DateTime(2024, 3, 15),
          DateTime(2024, 3, 31),
        ],
        rangeMin: 0,
        rangeMax: 300,
      );
      expect(s.domainMin, DateTime(2024, 3));
      expect(s.domainMax, DateTime(2024, 3, 31));
    });

    test('fromData with single value expands domain by ±12 hours', () {
      final single = DateTime(2024, 6, 15, 12);
      final s = OiTimeScale.fromData(
        values: [single],
        rangeMin: 0,
        rangeMax: 100,
      );
      expect(s.domainMin, DateTime(2024, 6, 15)); // -12h
      expect(s.domainMax, DateTime(2024, 6, 16)); // +12h
    });
  });

  // ── OiCategoryScale ────────────────────────────────────────────────────────

  group('OiCategoryScale', () {
    const scale = OiCategoryScale(
      domain: ['A', 'B', 'C', 'D'],
      rangeMin: 0,
      rangeMax: 400,
    );

    test('toPixel places each category at its step center', () {
      // step = 400 / 4 = 100
      // A → 0 + 0.5 * 100 = 50
      // B → 0 + 1.5 * 100 = 150
      // C → 0 + 2.5 * 100 = 250
      // D → 0 + 3.5 * 100 = 350
      expect(scale.toPixel('A'), closeTo(50, 0.001));
      expect(scale.toPixel('B'), closeTo(150, 0.001));
      expect(scale.toPixel('C'), closeTo(250, 0.001));
      expect(scale.toPixel('D'), closeTo(350, 0.001));
    });

    test('toPixel returns rangeMin for unknown category', () {
      expect(scale.toPixel('Z'), 0);
    });

    test('fromPixel returns nearest category', () {
      expect(scale.fromPixel(50), 'A');
      expect(scale.fromPixel(150), 'B');
      expect(scale.fromPixel(250), 'C');
      expect(scale.fromPixel(350), 'D');
    });

    test('fromPixel clamps to valid categories at boundaries', () {
      expect(scale.fromPixel(-100), 'A');
      expect(scale.fromPixel(10000), 'D');
    });

    test('fromPixel with empty domain returns empty string', () {
      const empty = OiCategoryScale(
        domain: <String>[],
        rangeMin: 0,
        rangeMax: 100,
      );
      expect(empty.fromPixel(50), '');
    });

    test('buildTicks returns one tick per category', () {
      final ticks = scale.buildTicks();
      expect(ticks.length, 4);
      expect(ticks.map((t) => t.value).toList(), ['A', 'B', 'C', 'D']);
    });

    test('single-category scale maps to midpoint', () {
      const single = OiCategoryScale(domain: ['X'], rangeMin: 0, rangeMax: 200);
      expect(single.toPixel('X'), closeTo(100, 0.001));
    });
  });

  // ── OiBandScale ────────────────────────────────────────────────────────────

  group('OiBandScale', () {
    const scale = OiBandScale(
      domain: ['A', 'B', 'C'],
      rangeMin: 0,
      rangeMax: 300,
      paddingInner: 0,
      paddingOuter: 0,
    );

    test('bandwidth is positive for non-empty domain', () {
      expect(scale.bandwidth, greaterThan(0));
    });

    test('toPixel returns band start position', () {
      // With no padding: step = 300 / 3 = 100
      // A starts at 0, B at 100, C at 200
      expect(scale.toPixel('A'), closeTo(0, 0.001));
      expect(scale.toPixel('B'), closeTo(100, 0.001));
      expect(scale.toPixel('C'), closeTo(200, 0.001));
    });

    test('bandCenter places center at band midpoint', () {
      final centerA = scale.bandCenter('A');
      expect(centerA, closeTo(scale.toPixel('A') + scale.bandwidth / 2, 0.001));
    });

    test('buildTicks returns ticks at band centers', () {
      final ticks = scale.buildTicks();
      expect(ticks.length, 3);
      for (final tick in ticks) {
        expect(tick.position, closeTo(scale.bandCenter(tick.value), 0.001));
      }
    });

    test('toPixel returns rangeMin for unknown value', () {
      expect(scale.toPixel('Z'), scale.rangeMin);
    });

    test('fromPixel returns category containing the pixel', () {
      // Band A: 0–100, B: 100–200, C: 200–300
      expect(scale.fromPixel(50), 'A');
      expect(scale.fromPixel(150), 'B');
      expect(scale.fromPixel(250), 'C');
    });

    test('paddingInner reduces bandwidth', () {
      const padded = OiBandScale(
        domain: ['A', 'B', 'C'],
        rangeMin: 0,
        rangeMax: 300,
        paddingInner: 0.2,
        paddingOuter: 0,
      );
      expect(padded.bandwidth, lessThan(100));
    });

    test('empty domain has bandwidth 0 and step 0', () {
      const empty = OiBandScale(domain: <String>[], rangeMin: 0, rangeMax: 300);
      expect(empty.bandwidth, 0);
      expect(empty.step, 0);
    });
  });

  // ── OiPointScale ──────────────────────────────────────────────────────────

  group('OiPointScale', () {
    const scale = OiPointScale(
      domain: ['A', 'B', 'C', 'D', 'E'],
      rangeMin: 0,
      rangeMax: 400,
    );

    test('toPixel places first and last points inset from range edges', () {
      final first = scale.toPixel('A');
      final last = scale.toPixel('E');
      expect(first, greaterThan(scale.rangeMin));
      expect(last, lessThan(scale.rangeMax));
    });

    test('toPixel returns evenly spaced positions', () {
      final a = scale.toPixel('A');
      final b = scale.toPixel('B');
      final c = scale.toPixel('C');
      final step1 = b - a;
      final step2 = c - b;
      expect(step1, closeTo(step2, 0.001));
    });

    test('fromPixel inverts toPixel', () {
      expect(scale.fromPixel(scale.toPixel('A')), 'A');
      expect(scale.fromPixel(scale.toPixel('C')), 'C');
      expect(scale.fromPixel(scale.toPixel('E')), 'E');
    });

    test('buildTicks returns one tick per category', () {
      final ticks = scale.buildTicks();
      expect(ticks.length, 5);
      expect(ticks.map((t) => t.value).toList(), ['A', 'B', 'C', 'D', 'E']);
    });

    test('toPixel returns rangeMin for unknown category', () {
      expect(scale.toPixel('Z'), scale.rangeMin);
    });

    test('single-item domain places point at range midpoint', () {
      const single = OiPointScale(domain: ['X'], rangeMin: 0, rangeMax: 200);
      expect(single.toPixel('X'), closeTo(100, 0.001));
    });

    test('empty domain fromPixel returns empty string', () {
      const empty = OiPointScale(
        domain: <String>[],
        rangeMin: 0,
        rangeMax: 100,
      );
      expect(empty.fromPixel(50), '');
    });

    test('padding 0 places first point at rangeMin', () {
      const noPad = OiPointScale(
        domain: ['A', 'B', 'C'],
        rangeMin: 0,
        rangeMax: 200,
        padding: 0,
      );
      expect(noPad.toPixel('A'), closeTo(0, 0.001));
      expect(noPad.toPixel('C'), closeTo(200, 0.001));
    });
  });

  // ── OiQuantileScale ────────────────────────────────────────────────────────

  group('OiQuantileScale', () {
    // 8 uniformly distributed values → 4 quartile bins
    final scale = OiQuantileScale(
      values: const [10, 20, 30, 40, 50, 60, 70, 80],
      rangeMin: 0,
      rangeMax: 400,
    );

    test('toPixel places values below first quartile in bin 0', () {
      // Bin 0 center = 0 + 0.5 * 100 = 50
      expect(scale.toPixel(10), closeTo(50, 0.001));
    });

    test('toPixel places values in the correct quartile band', () {
      final t = scale.thresholds;
      // value just above each threshold should land in next bin
      final px0 = scale.toPixel(t[0] - 1);
      final px1 = scale.toPixel(t[0] + 1);
      expect(px1, greaterThan(px0));
    });

    test('buildTicks returns quantileCount + 1 ticks (boundaries)', () {
      final ticks = scale.buildTicks();
      expect(ticks.length, scale.quantileCount + 1);
    });

    test('buildTicks first tick is at rangeMin', () {
      final ticks = scale.buildTicks();
      expect(ticks.first.position, scale.rangeMin);
    });

    test('buildTicks last tick is at rangeMax', () {
      final ticks = scale.buildTicks();
      expect(ticks.last.position, scale.rangeMax);
    });

    test('fromPixel returns a domain value', () {
      final v = scale.fromPixel(50);
      expect(v, isA<double>());
      expect(v, greaterThan(0));
    });

    test('sortedValues is sorted ascending', () {
      final sorted = scale.sortedValues;
      for (var i = 1; i < sorted.length; i++) {
        expect(sorted[i], greaterThanOrEqualTo(sorted[i - 1]));
      }
    });

    test('thresholds has quantileCount - 1 entries', () {
      expect(scale.thresholds.length, scale.quantileCount - 1);
    });

    test('empty values list does not crash buildTicks', () {
      final empty = OiQuantileScale(
        values: const <double>[],
        rangeMin: 0,
        rangeMax: 100,
      );
      expect(empty.buildTicks(), isEmpty);
    });
  });

  // ── OiThresholdScale ───────────────────────────────────────────────────────

  group('OiThresholdScale', () {
    // 3 thresholds → 4 segments
    const scale = OiThresholdScale(
      thresholds: [25, 50, 75],
      rangeMin: 0,
      rangeMax: 400,
    );

    test('segmentCount equals thresholds.length + 1', () {
      expect(scale.segmentCount, 4);
    });

    test('toPixel maps values below first threshold to bin 0', () {
      // bin 0 center = 0 + 0.5 * (400/4) = 50
      expect(scale.toPixel(10), closeTo(50, 0.001));
      expect(scale.toPixel(24.9), closeTo(50, 0.001));
    });

    test('toPixel maps values between first and second threshold to bin 1', () {
      // bin 1 center = 0 + 1.5 * 100 = 150
      expect(scale.toPixel(25), closeTo(150, 0.001));
      expect(scale.toPixel(40), closeTo(150, 0.001));
    });

    test('toPixel maps values above last threshold to last bin', () {
      // bin 3 center = 0 + 3.5 * 100 = 350
      expect(scale.toPixel(80), closeTo(350, 0.001));
      expect(scale.toPixel(100), closeTo(350, 0.001));
    });

    test('buildTicks returns one tick per threshold', () {
      final ticks = scale.buildTicks();
      expect(ticks.length, 3);
      expect(ticks.map((t) => t.value).toList(), [25, 50, 75]);
    });

    test('buildTicks tick positions correspond to toPixel of thresholds', () {
      final ticks = scale.buildTicks();
      for (final tick in ticks) {
        expect(tick.position, closeTo(scale.toPixel(tick.value), 0.001));
      }
    });

    test('atom equals rangeExtent / segmentCount', () {
      expect(scale.atom, closeTo(400 / 4, 0.001));
    });

    test('empty thresholds produces single segment covering full range', () {
      const empty = OiThresholdScale(
        thresholds: <double>[],
        rangeMin: 0,
        rangeMax: 100,
      );
      expect(empty.segmentCount, 1);
      expect(empty.buildTicks(), isEmpty);
    });

    test('single threshold produces two segments', () {
      const single = OiThresholdScale(
        thresholds: [50],
        rangeMin: 0,
        rangeMax: 200,
      );
      // bin 0 center = 0 + 0.5 * 100 = 50
      // bin 1 center = 0 + 1.5 * 100 = 150
      expect(single.toPixel(10), closeTo(50, 0.001));
      expect(single.toPixel(60), closeTo(150, 0.001));
    });
  });

  // ── OiChartScale base ──────────────────────────────────────────────────────

  group('OiChartScale.inferType', () {
    test('infers time scale from DateTime values', () {
      expect(OiChartScale.inferType([DateTime.now()]), OiScaleType.time);
    });

    test('infers linear scale from numeric values', () {
      expect(OiChartScale.inferType([1, 2, 3]), OiScaleType.linear);
    });

    test('infers category scale from String values', () {
      expect(OiChartScale.inferType(['A', 'B']), OiScaleType.category);
    });

    test('returns null for empty list', () {
      expect(OiChartScale.inferType([]), isNull);
    });
  });

  // ── OiTick equality ────────────────────────────────────────────────────────

  group('OiTick', () {
    test('equality holds when value and position match', () {
      const a = OiTick(value: 10, position: 100);
      const b = OiTick(value: 10, position: 100);
      expect(a, equals(b));
    });

    test('inequality when value differs', () {
      const a = OiTick(value: 10, position: 100);
      const b = OiTick(value: 20, position: 100);
      expect(a, isNot(equals(b)));
    });

    test('toString includes value and position', () {
      const t = OiTick(value: 5, position: 42);
      expect(t.toString(), contains('5'));
      expect(t.toString(), contains('42'));
    });
  });
}
