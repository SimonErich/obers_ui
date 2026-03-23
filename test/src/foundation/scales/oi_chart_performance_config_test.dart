// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_performance_config.dart';

void main() {
  group('OiChartPerformanceConfig', () {
    // ── Defaults ────────────────────────────────────────────────────────────

    test('default constructor produces expected defaults', () {
      const config = OiChartPerformanceConfig();
      expect(config.renderMode, OiChartRenderMode.auto);
      expect(config.decimationStrategy, OiChartDecimationStrategy.adaptive);
      expect(config.progressiveChunkSize, 500);
      expect(config.maxInteractivePoints, 5000);
      expect(config.cacheTextLayout, isTrue);
      expect(config.cachePaths, isTrue);
      expect(config.simplifyOffscreenGeometry, isTrue);
    });

    // ── resolveRenderMode ─────────────────────────────────────────────────

    test('resolveRenderMode returns explicit mode when not auto', () {
      const config = OiChartPerformanceConfig(
        renderMode: OiChartRenderMode.quality,
      );
      expect(
        config.resolveRenderMode(totalPoints: 100000),
        OiChartRenderMode.quality,
      );
    });

    test('resolveRenderMode returns quality for small datasets', () {
      const config = OiChartPerformanceConfig();
      expect(
        config.resolveRenderMode(totalPoints: 100),
        OiChartRenderMode.quality,
      );
    });

    test('resolveRenderMode returns balanced for medium datasets', () {
      const config = OiChartPerformanceConfig();
      expect(
        config.resolveRenderMode(totalPoints: 4000),
        OiChartRenderMode.balanced,
      );
    });

    test('resolveRenderMode returns performance for large datasets', () {
      const config = OiChartPerformanceConfig();
      expect(
        config.resolveRenderMode(totalPoints: 10000),
        OiChartRenderMode.performance,
      );
    });

    test('resolveRenderMode accounts for devicePixelRatio', () {
      const config = OiChartPerformanceConfig();
      // With dpr=2, the effective threshold is 10000.
      // 4000 points / (10000/2 = 5000 threshold half) => quality
      expect(
        config.resolveRenderMode(totalPoints: 4000, devicePixelRatio: 2),
        OiChartRenderMode.quality,
      );
    });

    // ── resolveDecimationStrategy ─────────────────────────────────────────

    test('resolveDecimationStrategy returns explicit when not adaptive', () {
      const config = OiChartPerformanceConfig(
        decimationStrategy: OiChartDecimationStrategy.lttb,
      );
      expect(
        config.resolveDecimationStrategy(
          totalPoints: 1000,
          availablePixelWidth: 100,
        ),
        OiChartDecimationStrategy.lttb,
      );
    });

    test('resolveDecimationStrategy returns none for low density', () {
      const config = OiChartPerformanceConfig();
      expect(
        config.resolveDecimationStrategy(
          totalPoints: 300,
          availablePixelWidth: 100,
        ),
        OiChartDecimationStrategy.none,
      );
    });

    test('resolveDecimationStrategy returns lttb for moderate density', () {
      const config = OiChartPerformanceConfig();
      expect(
        config.resolveDecimationStrategy(
          totalPoints: 1000,
          availablePixelWidth: 100,
        ),
        OiChartDecimationStrategy.lttb,
      );
    });

    test('resolveDecimationStrategy returns minMax for high density', () {
      const config = OiChartPerformanceConfig();
      expect(
        config.resolveDecimationStrategy(
          totalPoints: 5000,
          availablePixelWidth: 100,
        ),
        OiChartDecimationStrategy.minMax,
      );
    });

    test('resolveDecimationStrategy returns none for zero pixel width', () {
      const config = OiChartPerformanceConfig();
      expect(
        config.resolveDecimationStrategy(
          totalPoints: 5000,
          availablePixelWidth: 0,
        ),
        OiChartDecimationStrategy.none,
      );
    });

    // ── shouldUseProgressiveRendering ──────────────────────────────────────

    test('shouldUseProgressiveRendering returns false below threshold', () {
      const config = OiChartPerformanceConfig();
      expect(config.shouldUseProgressiveRendering(4999), isFalse);
    });

    test('shouldUseProgressiveRendering returns false at threshold', () {
      const config = OiChartPerformanceConfig();
      expect(config.shouldUseProgressiveRendering(5000), isFalse);
    });

    test('shouldUseProgressiveRendering returns true above threshold', () {
      const config = OiChartPerformanceConfig();
      expect(config.shouldUseProgressiveRendering(5001), isTrue);
    });

    // ── copyWith ──────────────────────────────────────────────────────────

    test('copyWith returns identical when no args provided', () {
      const config = OiChartPerformanceConfig();
      expect(config.copyWith(), equals(config));
    });

    test('copyWith updates single field', () {
      const config = OiChartPerformanceConfig();
      final updated = config.copyWith(
        renderMode: OiChartRenderMode.performance,
      );
      expect(updated.renderMode, OiChartRenderMode.performance);
      expect(updated.decimationStrategy, OiChartDecimationStrategy.adaptive);
    });

    test('copyWith updates multiple fields', () {
      const config = OiChartPerformanceConfig();
      final updated = config.copyWith(
        renderMode: OiChartRenderMode.quality,
        cacheTextLayout: false,
        progressiveChunkSize: 1000,
      );
      expect(updated.renderMode, OiChartRenderMode.quality);
      expect(updated.cacheTextLayout, isFalse);
      expect(updated.progressiveChunkSize, 1000);
    });

    // ── equality / hashCode ───────────────────────────────────────────────

    test('two identical instances are equal', () {
      const a = OiChartPerformanceConfig(
        renderMode: OiChartRenderMode.balanced,
        progressiveChunkSize: 300,
      );
      const b = OiChartPerformanceConfig(
        renderMode: OiChartRenderMode.balanced,
        progressiveChunkSize: 300,
      );
      expect(a, equals(b));
    });

    test('instances with different fields are not equal', () {
      const a = OiChartPerformanceConfig(cacheTextLayout: true);
      const b = OiChartPerformanceConfig(cacheTextLayout: false);
      expect(a, isNot(equals(b)));
    });

    test('hashCode is same for equal instances', () {
      const a = OiChartPerformanceConfig(
        decimationStrategy: OiChartDecimationStrategy.lttb,
      );
      const b = OiChartPerformanceConfig(
        decimationStrategy: OiChartDecimationStrategy.lttb,
      );
      expect(a.hashCode, equals(b.hashCode));
    });

    // ── toString ──────────────────────────────────────────────────────────

    test('toString contains key field names', () {
      const config = OiChartPerformanceConfig();
      final str = config.toString();
      expect(str, contains('renderMode'));
      expect(str, contains('decimation'));
      expect(str, contains('chunkSize'));
    });

    // ── enum values ───────────────────────────────────────────────────────

    test('OiChartRenderMode has all expected values', () {
      expect(OiChartRenderMode.values, hasLength(4));
      expect(OiChartRenderMode.values, contains(OiChartRenderMode.auto));
      expect(OiChartRenderMode.values, contains(OiChartRenderMode.quality));
      expect(OiChartRenderMode.values, contains(OiChartRenderMode.balanced));
      expect(
        OiChartRenderMode.values,
        contains(OiChartRenderMode.performance),
      );
    });

    test('OiChartDecimationStrategy has all expected values', () {
      expect(OiChartDecimationStrategy.values, hasLength(4));
      expect(
        OiChartDecimationStrategy.values,
        contains(OiChartDecimationStrategy.none),
      );
      expect(
        OiChartDecimationStrategy.values,
        contains(OiChartDecimationStrategy.minMax),
      );
      expect(
        OiChartDecimationStrategy.values,
        contains(OiChartDecimationStrategy.lttb),
      );
      expect(
        OiChartDecimationStrategy.values,
        contains(OiChartDecimationStrategy.adaptive),
      );
    });
  });
}
