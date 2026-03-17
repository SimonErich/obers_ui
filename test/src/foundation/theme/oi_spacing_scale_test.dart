// ignore_for_file: public_member_api_docs // No public API docs needed in test files.

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

      test('produces correct page gutter values', () {
        final scale = OiSpacingScale.standard();
        expect(scale.pageGutterCompact, 16);
        expect(scale.pageGutterMedium, 24);
        expect(scale.pageGutterExpanded, 32);
        expect(scale.pageGutterLarge, 40);
        expect(scale.pageGutterExtraLarge, 48);
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

      test('overrides pageGutterCompact only', () {
        final scale = OiSpacingScale.standard();
        final copy = scale.copyWith(pageGutterCompact: 12);
        expect(copy.pageGutterCompact, 12);
        expect(copy.pageGutterMedium, scale.pageGutterMedium);
        expect(copy.pageGutterExpanded, scale.pageGutterExpanded);
        expect(copy.pageGutterLarge, scale.pageGutterLarge);
        expect(copy.pageGutterExtraLarge, scale.pageGutterExtraLarge);
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
        // ignore: unrelated_type_equality_checks
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
        pageGutterCompact: 10,
        pageGutterMedium: 12,
        pageGutterExpanded: 14,
        pageGutterLarge: 16,
        pageGutterExtraLarge: 18,
      );
      expect(scale.xs, 2);
      expect(scale.sm, 4);
      expect(scale.md, 8);
      expect(scale.lg, 12);
      expect(scale.xl, 16);
      expect(scale.xxl, 24);
      expect(scale.pageGutterCompact, 10);
      expect(scale.pageGutterMedium, 12);
      expect(scale.pageGutterExpanded, 14);
      expect(scale.pageGutterLarge, 16);
      expect(scale.pageGutterExtraLarge, 18);
    });
  });
}
