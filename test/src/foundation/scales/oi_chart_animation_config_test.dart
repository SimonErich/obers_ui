// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_animation_config.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiPhaseAnimationConfig', () {
    test('default values', () {
      const config = OiPhaseAnimationConfig();
      expect(config.duration, const Duration(milliseconds: 300));
      expect(config.curve, Curves.easeInOut);
    });

    test('custom values', () {
      const config = OiPhaseAnimationConfig(
        duration: Duration(milliseconds: 500),
        curve: Curves.bounceIn,
      );
      expect(config.duration, const Duration(milliseconds: 500));
      expect(config.curve, Curves.bounceIn);
    });

    test('copyWith', () {
      const original = OiPhaseAnimationConfig(
        duration: Duration(milliseconds: 200),
        curve: Curves.linear,
      );
      final copy = original.copyWith(duration: const Duration(milliseconds: 400));
      expect(copy.duration, const Duration(milliseconds: 400));
      expect(copy.curve, Curves.linear);
    });

    test('equality', () {
      const a = OiPhaseAnimationConfig(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      const b = OiPhaseAnimationConfig(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      const c = OiPhaseAnimationConfig(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('OiSeriesAnimationConfig', () {
    test('all fields optional', () {
      const config = OiSeriesAnimationConfig();
      expect(config.duration, isNull);
      expect(config.delay, isNull);
      expect(config.curve, isNull);
    });

    test('custom values', () {
      const config = OiSeriesAnimationConfig(
        duration: Duration(milliseconds: 200),
        delay: Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
      expect(config.duration, const Duration(milliseconds: 200));
      expect(config.delay, const Duration(milliseconds: 100));
      expect(config.curve, Curves.easeOut);
    });

    test('copyWith', () {
      const original = OiSeriesAnimationConfig(
        duration: Duration(milliseconds: 200),
      );
      final copy = original.copyWith(
        delay: const Duration(milliseconds: 50),
      );
      expect(copy.duration, const Duration(milliseconds: 200));
      expect(copy.delay, const Duration(milliseconds: 50));
      expect(copy.curve, isNull);
    });

    test('equality', () {
      const a = OiSeriesAnimationConfig(
        duration: Duration(milliseconds: 200),
        delay: Duration(milliseconds: 100),
      );
      const b = OiSeriesAnimationConfig(
        duration: Duration(milliseconds: 200),
        delay: Duration(milliseconds: 100),
      );
      const c = OiSeriesAnimationConfig(
        duration: Duration(milliseconds: 300),
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  group('OiChartAnimationConfig', () {
    test('default values', () {
      const config = OiChartAnimationConfig();
      expect(config.enabled, isTrue);
      expect(config.duration, const Duration(milliseconds: 300));
      expect(config.curve, Curves.easeInOut);
      expect(config.respectReducedMotion, isTrue);
      expect(config.enter.duration, const Duration(milliseconds: 400));
      expect(config.enter.curve, Curves.easeOut);
      expect(config.update.duration, const Duration(milliseconds: 300));
      expect(config.update.curve, Curves.easeInOut);
      expect(config.exit.duration, const Duration(milliseconds: 200));
      expect(config.exit.curve, Curves.easeIn);
    });

    test('disabled constructor', () {
      const config = OiChartAnimationConfig.disabled();
      expect(config.enabled, isFalse);
      expect(config.duration, Duration.zero);
      expect(config.enter.duration, Duration.zero);
      expect(config.update.duration, Duration.zero);
      expect(config.exit.duration, Duration.zero);
      expect(config.respectReducedMotion, isFalse);
    });

    test('copyWith', () {
      const original = OiChartAnimationConfig();
      final copy = original.copyWith(
        enabled: false,
        duration: const Duration(milliseconds: 500),
      );
      expect(copy.enabled, isFalse);
      expect(copy.duration, const Duration(milliseconds: 500));
      expect(copy.curve, Curves.easeInOut);
      expect(copy.enter, original.enter);
    });

    test('equality', () {
      const a = OiChartAnimationConfig();
      const b = OiChartAnimationConfig();
      const c = OiChartAnimationConfig(
        duration: Duration(milliseconds: 500),
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    group('resolve', () {
      testWidgets('returns same config when reduced motion is off',
          (tester) async {
        const config = OiChartAnimationConfig();

        await tester.pumpObers(
          Builder(
            builder: (context) {
              final resolved = config.resolve(context);
              expect(resolved.enabled, isTrue);
              expect(resolved.duration, const Duration(milliseconds: 300));
              return const SizedBox();
            },
          ),
        );
      });

      testWidgets('disables animations when reduced motion is on',
          (tester) async {
        const config = OiChartAnimationConfig();

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Builder(
                builder: (context) {
                  final resolved = config.resolve(context);
                  expect(resolved.enabled, isFalse);
                  expect(resolved.duration, Duration.zero);
                  expect(resolved.enter.duration, Duration.zero);
                  expect(resolved.update.duration, Duration.zero);
                  expect(resolved.exit.duration, Duration.zero);
                  return const SizedBox();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('respects respectReducedMotion=false', (tester) async {
        const config = OiChartAnimationConfig(respectReducedMotion: false);

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Builder(
                builder: (context) {
                  final resolved = config.resolve(context);
                  expect(resolved.enabled, isTrue);
                  expect(resolved.duration, const Duration(milliseconds: 300));
                  return const SizedBox();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('disabled config stays disabled', (tester) async {
        const config = OiChartAnimationConfig.disabled();

        await tester.pumpObers(
          Builder(
            builder: (context) {
              final resolved = config.resolve(context);
              expect(resolved.enabled, isFalse);
              expect(resolved.duration, Duration.zero);
              return const SizedBox();
            },
          ),
        );
      });
    });

    group('resolveSeriesConfig', () {
      test('falls back to chart-level defaults when series config is null',
          () {
        const config = OiChartAnimationConfig();
        final resolved = config.resolveSeriesConfig(null);
        expect(resolved.duration, const Duration(milliseconds: 300));
        expect(resolved.delay, Duration.zero);
        expect(resolved.curve, Curves.easeInOut);
      });

      test('uses series overrides when provided', () {
        const config = OiChartAnimationConfig();
        final resolved = config.resolveSeriesConfig(
          const OiSeriesAnimationConfig(
            duration: Duration(milliseconds: 500),
            delay: Duration(milliseconds: 100),
            curve: Curves.bounceOut,
          ),
        );
        expect(resolved.duration, const Duration(milliseconds: 500));
        expect(resolved.delay, const Duration(milliseconds: 100));
        expect(resolved.curve, Curves.bounceOut);
      });

      test('partial series override falls back to chart defaults', () {
        const config = OiChartAnimationConfig();
        final resolved = config.resolveSeriesConfig(
          const OiSeriesAnimationConfig(
            delay: Duration(milliseconds: 50),
          ),
        );
        expect(resolved.duration, const Duration(milliseconds: 300));
        expect(resolved.delay, const Duration(milliseconds: 50));
        expect(resolved.curve, Curves.easeInOut);
      });
    });
  });
}
