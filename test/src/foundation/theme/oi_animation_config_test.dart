// ignore_for_file: public_member_api_docs // No public API docs needed in test files.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/theme/oi_animation_config.dart';

void main() {
  group('OiAnimationConfig', () {
    group('standard()', () {
      test('fast is 150ms', () {
        const config = OiAnimationConfig.standard();
        expect(config.fast, const Duration(milliseconds: 150));
      });

      test('normal is 250ms', () {
        const config = OiAnimationConfig.standard();
        expect(config.normal, const Duration(milliseconds: 250));
      });

      test('slow is 400ms', () {
        const config = OiAnimationConfig.standard();
        expect(config.slow, const Duration(milliseconds: 400));
      });

      test('reducedMotion defaults to false', () {
        const config = OiAnimationConfig.standard();
        expect(config.reducedMotion, isFalse);
      });
    });

    group('standard(reducedMotion: true)', () {
      test('fast is Duration.zero', () {
        const config = OiAnimationConfig.standard(reducedMotion: true);
        expect(config.fast, Duration.zero);
      });

      test('normal is Duration.zero', () {
        const config = OiAnimationConfig.standard(reducedMotion: true);
        expect(config.normal, Duration.zero);
      });

      test('slow is Duration.zero', () {
        const config = OiAnimationConfig.standard(reducedMotion: true);
        expect(config.slow, Duration.zero);
      });

      test('reducedMotion is true', () {
        const config = OiAnimationConfig.standard(reducedMotion: true);
        expect(config.reducedMotion, isTrue);
      });
    });

    group('copyWith', () {
      test('returns same values when no overrides', () {
        const config = OiAnimationConfig.standard();
        expect(config.copyWith(), equals(config));
      });

      test('overrides fast only', () {
        const config = OiAnimationConfig.standard();
        final copy = config.copyWith(fast: const Duration(milliseconds: 50));
        expect(copy.fast, const Duration(milliseconds: 50));
        expect(copy.normal, config.normal);
        expect(copy.slow, config.slow);
        expect(copy.reducedMotion, config.reducedMotion);
      });

      test('overrides reducedMotion', () {
        const config = OiAnimationConfig.standard();
        final copy = config.copyWith(reducedMotion: true);
        expect(copy.reducedMotion, isTrue);
        expect(copy.fast, config.fast);
      });

      test('overrides multiple fields', () {
        const config = OiAnimationConfig.standard();
        final copy = config.copyWith(
          normal: const Duration(milliseconds: 300),
          slow: const Duration(milliseconds: 500),
        );
        expect(copy.normal, const Duration(milliseconds: 300));
        expect(copy.slow, const Duration(milliseconds: 500));
        expect(copy.fast, config.fast);
      });
    });

    group('equality', () {
      test('two standard() instances are equal', () {
        expect(
          const OiAnimationConfig.standard(),
          equals(const OiAnimationConfig.standard()),
        );
      });

      test('standard and reducedMotion differ', () {
        expect(
          const OiAnimationConfig.standard(),
          isNot(equals(const OiAnimationConfig.standard(reducedMotion: true))),
        );
      });

      test('hashCode is consistent', () {
        expect(
          const OiAnimationConfig.standard().hashCode,
          equals(const OiAnimationConfig.standard().hashCode),
        );
      });

      test('identical instance equals itself', () {
        const config = OiAnimationConfig.standard();
        expect(config == config, isTrue);
      });
    });
  });

  group('OiPerformanceConfig', () {
    group('high()', () {
      test('disableBlur is false', () {
        expect(const OiPerformanceConfig.high().disableBlur, isFalse);
      });

      test('disableShadows is false', () {
        expect(const OiPerformanceConfig.high().disableShadows, isFalse);
      });

      test('reduceAnimations is false', () {
        expect(const OiPerformanceConfig.high().reduceAnimations, isFalse);
      });

      test('disableHalo is false', () {
        expect(const OiPerformanceConfig.high().disableHalo, isFalse);
      });

      test('animationScale is 1.0', () {
        expect(const OiPerformanceConfig.high().animationScale, 1.0);
      });
    });

    group('mid()', () {
      test('disableBlur is true', () {
        expect(const OiPerformanceConfig.mid().disableBlur, isTrue);
      });

      test('disableShadows is false', () {
        expect(const OiPerformanceConfig.mid().disableShadows, isFalse);
      });

      test('reduceAnimations is false', () {
        expect(const OiPerformanceConfig.mid().reduceAnimations, isFalse);
      });

      test('disableHalo is false', () {
        expect(const OiPerformanceConfig.mid().disableHalo, isFalse);
      });

      test('animationScale is 1.0', () {
        expect(const OiPerformanceConfig.mid().animationScale, 1.0);
      });
    });

    group('low()', () {
      test('disableBlur is true', () {
        expect(const OiPerformanceConfig.low().disableBlur, isTrue);
      });

      test('disableShadows is true', () {
        expect(const OiPerformanceConfig.low().disableShadows, isTrue);
      });

      test('reduceAnimations is true', () {
        expect(const OiPerformanceConfig.low().reduceAnimations, isTrue);
      });

      test('disableHalo is true', () {
        expect(const OiPerformanceConfig.low().disableHalo, isTrue);
      });

      test('animationScale is 0.5', () {
        expect(const OiPerformanceConfig.low().animationScale, 0.5);
      });
    });

    group('auto()', () {
      test('returns high on non-web', () {
        // In test environment kIsWeb is false, so expect high config.
        final config = OiPerformanceConfig.auto();
        if (!kIsWeb) {
          expect(config.disableBlur, isFalse);
          expect(config.disableShadows, isFalse);
        } else {
          expect(config.disableBlur, isTrue);
          expect(config.disableShadows, isFalse);
        }
      });
    });

    group('copyWith', () {
      test('returns same values when no overrides', () {
        const config = OiPerformanceConfig.high();
        expect(config.copyWith(), equals(config));
      });

      test('overrides disableBlur only', () {
        const config = OiPerformanceConfig.high();
        final copy = config.copyWith(disableBlur: true);
        expect(copy.disableBlur, isTrue);
        expect(copy.disableShadows, config.disableShadows);
        expect(copy.reduceAnimations, config.reduceAnimations);
        expect(copy.disableHalo, config.disableHalo);
        expect(copy.animationScale, config.animationScale);
      });

      test('overrides animationScale', () {
        const config = OiPerformanceConfig.low();
        final copy = config.copyWith(animationScale: 0.75);
        expect(copy.animationScale, 0.75);
        expect(copy.disableBlur, config.disableBlur);
      });
    });

    group('equality', () {
      test('two high() instances are equal', () {
        expect(
          const OiPerformanceConfig.high(),
          equals(const OiPerformanceConfig.high()),
        );
      });

      test('high and low are not equal', () {
        expect(
          const OiPerformanceConfig.high(),
          isNot(equals(const OiPerformanceConfig.low())),
        );
      });

      test('hashCode is consistent', () {
        expect(
          const OiPerformanceConfig.high().hashCode,
          equals(const OiPerformanceConfig.high().hashCode),
        );
      });

      test('identical instance equals itself', () {
        const config = OiPerformanceConfig.mid();
        expect(config == config, isTrue);
      });
    });
  });
}
