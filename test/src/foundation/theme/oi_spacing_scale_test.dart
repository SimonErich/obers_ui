import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/theme/oi_spacing_scale.dart';

void main() {
  group('OiSpacingScale', () {
    group('standard()', () {
      test('produces correct named spacing values', () {
        final scale = OiSpacingScale.standard();
        expect(scale.xs, 4);
        expect(scale.sm, 8);
        expect(scale.md, 16);
        expect(scale.lg, 24);
        expect(scale.xl, 32);
        expect(scale.xxl, 48);
      });

      test('base is the 4dp grid unit', () {
        expect(OiSpacingScale.standard().base, 4);
      });

      test('every named value is a whole number of grid units', () {
        final scale = OiSpacingScale.standard();
        for (final value in [
          scale.xs,
          scale.sm,
          scale.md,
          scale.lg,
          scale.xl,
          scale.xxl,
        ]) {
          expect(value % scale.base, 0, reason: '$value is off the grid');
        }
      });
    });

    group('copyWith', () {
      test('returns same values when no overrides', () {
        final scale = OiSpacingScale.standard();
        final copy = scale.copyWith();
        expect(copy, equals(scale));
      });

      test('overrides xs only', () {
        final scale = OiSpacingScale.standard();
        final copy = scale.copyWith(xs: 99);
        expect(copy.xs, 99);
        expect(copy.sm, scale.sm);
        expect(copy.md, scale.md);
        expect(copy.lg, scale.lg);
        expect(copy.xl, scale.xl);
        expect(copy.xxl, scale.xxl);
      });

      test('overrides base only, and step follows it', () {
        final scale = OiSpacingScale.standard();
        final copy = scale.copyWith(base: 8);
        expect(copy.base, 8);
        expect(copy.step(3), 24);
        expect(copy.xs, scale.xs);
      });

      test('overrides multiple fields', () {
        final scale = OiSpacingScale.standard();
        final copy = scale.copyWith(sm: 10, xl: 36);
        expect(copy.sm, 10);
        expect(copy.xl, 36);
        expect(copy.md, scale.md);
      });
    });

    group('equality', () {
      test('two standard() instances are equal', () {
        expect(OiSpacingScale.standard(), equals(OiSpacingScale.standard()));
      });

      test('different values are not equal', () {
        final a = OiSpacingScale.standard();
        final b = a.copyWith(xs: 99);
        expect(a, isNot(equals(b)));
      });

      test('identical instance equals itself', () {
        final scale = OiSpacingScale.standard();
        // Comparing a value to itself via == to verify the identity fast-path.
        expect(scale == scale, isTrue);
      });

      test('hashCode is consistent', () {
        expect(
          OiSpacingScale.standard().hashCode,
          equals(OiSpacingScale.standard().hashCode),
        );
      });

      test('different hashCode when values differ', () {
        final a = OiSpacingScale.standard();
        final b = a.copyWith(xxl: 64);
        expect(a.hashCode, isNot(equals(b.hashCode)));
      });
    });

    test('const constructor stores all fields', () {
      const scale = OiSpacingScale(
        xs: 2,
        sm: 4,
        md: 8,
        lg: 12,
        xl: 16,
        xxl: 24,
        base: 2,
      );
      expect(scale.xs, 2);
      expect(scale.sm, 4);
      expect(scale.md, 8);
      expect(scale.lg, 12);
      expect(scale.xl, 16);
      expect(scale.xxl, 24);
      expect(scale.base, 2);
    });

    group('step', () {
      test('returns whole grid units', () {
        final scale = OiSpacingScale.standard();
        expect(scale.step(1), 4);
        expect(scale.step(2), 8);
        // The step the named ladder skips, and the reason this exists: call
        // sites were writing `spacing.sm + 4` to reach it.
        expect(scale.step(3), 12);
        expect(scale.step(4), 16);
      });

      test('agrees with the named ladder where they overlap', () {
        final scale = OiSpacingScale.standard();
        expect(scale.step(1), scale.xs);
        expect(scale.step(2), scale.sm);
        expect(scale.step(4), scale.md);
        expect(scale.step(6), scale.lg);
        expect(scale.step(8), scale.xl);
        expect(scale.step(12), scale.xxl);
      });

      test('step(0) is no spacing', () {
        expect(OiSpacingScale.standard().step(0), 0);
      });
    });
  });
}
