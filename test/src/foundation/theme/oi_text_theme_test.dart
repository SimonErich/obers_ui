// Tests for OiTextTheme and OiLabelVariant — no public API docs needed in test files.
// ignore_for_file: public_member_api_docs

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';

void main() {
  group('OiLabelVariant', () {
    test('all enum values are defined', () {
      // Exhaustive check — if a variant is removed this will fail at compile time.
      const variants = OiLabelVariant.values;
      expect(variants, contains(OiLabelVariant.display));
      expect(variants, contains(OiLabelVariant.h1));
      expect(variants, contains(OiLabelVariant.h2));
      expect(variants, contains(OiLabelVariant.h3));
      expect(variants, contains(OiLabelVariant.h4));
      expect(variants, contains(OiLabelVariant.body));
      expect(variants, contains(OiLabelVariant.bodyStrong));
      expect(variants, contains(OiLabelVariant.small));
      expect(variants, contains(OiLabelVariant.smallStrong));
      expect(variants, contains(OiLabelVariant.tiny));
      expect(variants, contains(OiLabelVariant.caption));
      expect(variants, contains(OiLabelVariant.code));
      expect(variants, contains(OiLabelVariant.overline));
      expect(variants, contains(OiLabelVariant.link));
      expect(variants, hasLength(14));
    });
  });

  group('OiTextTheme', () {
    group('OiTextTheme.standard', () {
      test('creates non-null display style', () {
        final theme = OiTextTheme.standard();
        expect(theme.display, isA<TextStyle>());
      });

      test('creates non-null h1 style', () {
        final theme = OiTextTheme.standard();
        expect(theme.h1, isA<TextStyle>());
      });

      test('creates non-null h2 style', () {
        final theme = OiTextTheme.standard();
        expect(theme.h2, isA<TextStyle>());
      });

      test('creates non-null h3 style', () {
        final theme = OiTextTheme.standard();
        expect(theme.h3, isA<TextStyle>());
      });

      test('creates non-null h4 style', () {
        final theme = OiTextTheme.standard();
        expect(theme.h4, isA<TextStyle>());
      });

      test('creates non-null body style', () {
        final theme = OiTextTheme.standard();
        expect(theme.body, isA<TextStyle>());
      });

      test('creates non-null bodyStrong style', () {
        final theme = OiTextTheme.standard();
        expect(theme.bodyStrong, isA<TextStyle>());
      });

      test('creates non-null small style', () {
        final theme = OiTextTheme.standard();
        expect(theme.small, isA<TextStyle>());
      });

      test('creates non-null smallStrong style', () {
        final theme = OiTextTheme.standard();
        expect(theme.smallStrong, isA<TextStyle>());
      });

      test('creates non-null tiny style', () {
        final theme = OiTextTheme.standard();
        expect(theme.tiny, isA<TextStyle>());
      });

      test('creates non-null caption style', () {
        final theme = OiTextTheme.standard();
        expect(theme.caption, isA<TextStyle>());
      });

      test('creates non-null code style', () {
        final theme = OiTextTheme.standard();
        expect(theme.code, isA<TextStyle>());
      });

      test('creates non-null overline style', () {
        final theme = OiTextTheme.standard();
        expect(theme.overline, isA<TextStyle>());
      });

      test('creates non-null link style', () {
        final theme = OiTextTheme.standard();
        expect(theme.link, isA<TextStyle>());
      });

      test('display fontSize is larger than h1 fontSize', () {
        final theme = OiTextTheme.standard();
        expect(theme.display.fontSize, greaterThan(theme.h1.fontSize!));
      });

      test('h1 fontSize is larger than body fontSize', () {
        final theme = OiTextTheme.standard();
        expect(theme.h1.fontSize, greaterThan(theme.body.fontSize!));
      });

      test('h1 fontSize is larger than h2 fontSize', () {
        final theme = OiTextTheme.standard();
        expect(theme.h1.fontSize, greaterThan(theme.h2.fontSize!));
      });

      test('h2 fontSize is larger than h3 fontSize', () {
        final theme = OiTextTheme.standard();
        expect(theme.h2.fontSize, greaterThan(theme.h3.fontSize!));
      });

      test('h3 fontSize is larger than h4 fontSize', () {
        final theme = OiTextTheme.standard();
        expect(theme.h3.fontSize, greaterThan(theme.h4.fontSize!));
      });

      test('body fontSize is larger than small fontSize', () {
        final theme = OiTextTheme.standard();
        expect(theme.body.fontSize, greaterThan(theme.small.fontSize!));
      });

      test('code uses a monospace font family', () {
        final theme = OiTextTheme.standard();
        expect(theme.code.fontFamily, isNotNull);
        expect(theme.code.fontFamily, isNotEmpty);
      });

      test('code uses custom monoFontFamily when provided', () {
        final theme = OiTextTheme.standard(monoFontFamily: 'JetBrains Mono');
        expect(theme.code.fontFamily, equals('JetBrains Mono'));
      });

      test('non-code styles use custom fontFamily when provided', () {
        final theme = OiTextTheme.standard(fontFamily: 'Inter');
        expect(theme.body.fontFamily, equals('Inter'));
        expect(theme.h1.fontFamily, equals('Inter'));
        expect(theme.display.fontFamily, equals('Inter'));
      });

      test('link style has underline decoration', () {
        final theme = OiTextTheme.standard();
        expect(theme.link.decoration, equals(TextDecoration.underline));
      });

      test('overline has positive letter spacing', () {
        final theme = OiTextTheme.standard();
        expect(theme.overline.letterSpacing, greaterThan(0));
      });
    });

    group('styleFor', () {
      test('returns display style for display variant', () {
        final theme = OiTextTheme.standard();
        expect(theme.styleFor(OiLabelVariant.display), equals(theme.display));
      });

      test('returns h1 style for h1 variant', () {
        final theme = OiTextTheme.standard();
        expect(theme.styleFor(OiLabelVariant.h1), equals(theme.h1));
      });

      test('returns h2 style for h2 variant', () {
        final theme = OiTextTheme.standard();
        expect(theme.styleFor(OiLabelVariant.h2), equals(theme.h2));
      });

      test('returns h3 style for h3 variant', () {
        final theme = OiTextTheme.standard();
        expect(theme.styleFor(OiLabelVariant.h3), equals(theme.h3));
      });

      test('returns h4 style for h4 variant', () {
        final theme = OiTextTheme.standard();
        expect(theme.styleFor(OiLabelVariant.h4), equals(theme.h4));
      });

      test('returns body style for body variant', () {
        final theme = OiTextTheme.standard();
        expect(theme.styleFor(OiLabelVariant.body), equals(theme.body));
      });

      test('returns bodyStrong style for bodyStrong variant', () {
        final theme = OiTextTheme.standard();
        expect(
          theme.styleFor(OiLabelVariant.bodyStrong),
          equals(theme.bodyStrong),
        );
      });

      test('returns small style for small variant', () {
        final theme = OiTextTheme.standard();
        expect(theme.styleFor(OiLabelVariant.small), equals(theme.small));
      });

      test('returns smallStrong style for smallStrong variant', () {
        final theme = OiTextTheme.standard();
        expect(
          theme.styleFor(OiLabelVariant.smallStrong),
          equals(theme.smallStrong),
        );
      });

      test('returns tiny style for tiny variant', () {
        final theme = OiTextTheme.standard();
        expect(theme.styleFor(OiLabelVariant.tiny), equals(theme.tiny));
      });

      test('returns caption style for caption variant', () {
        final theme = OiTextTheme.standard();
        expect(theme.styleFor(OiLabelVariant.caption), equals(theme.caption));
      });

      test('returns code style for code variant', () {
        final theme = OiTextTheme.standard();
        expect(theme.styleFor(OiLabelVariant.code), equals(theme.code));
      });

      test('returns overline style for overline variant', () {
        final theme = OiTextTheme.standard();
        expect(theme.styleFor(OiLabelVariant.overline), equals(theme.overline));
      });

      test('returns link style for link variant', () {
        final theme = OiTextTheme.standard();
        expect(theme.styleFor(OiLabelVariant.link), equals(theme.link));
      });

      test('styleFor covers all OiLabelVariant values', () {
        final theme = OiTextTheme.standard();
        for (final variant in OiLabelVariant.values) {
          expect(
            () => theme.styleFor(variant),
            returnsNormally,
            reason: 'styleFor should handle variant $variant',
          );
        }
      });
    });

    group('copyWith', () {
      test('returns equal theme when no overrides', () {
        final theme = OiTextTheme.standard();
        final copy = theme.copyWith();
        expect(copy, equals(theme));
      });

      test('overrides only the body style', () {
        final theme = OiTextTheme.standard();
        const newBody = TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
        final copy = theme.copyWith(body: newBody);
        expect(copy.body, equals(newBody));
        expect(copy.h1, equals(theme.h1));
        expect(copy.display, equals(theme.display));
        expect(copy.code, equals(theme.code));
      });

      test('overrides only the code style', () {
        final theme = OiTextTheme.standard();
        const newCode = TextStyle(fontFamily: 'Fira Code', fontSize: 13);
        final copy = theme.copyWith(code: newCode);
        expect(copy.code, equals(newCode));
        expect(copy.body, equals(theme.body));
      });

      test('overrides multiple fields independently', () {
        final theme = OiTextTheme.standard();
        const newH1 = TextStyle(fontSize: 48);
        const newH2 = TextStyle(fontSize: 36);
        final copy = theme.copyWith(h1: newH1, h2: newH2);
        expect(copy.h1, equals(newH1));
        expect(copy.h2, equals(newH2));
        expect(copy.h3, equals(theme.h3));
      });
    });

    group('lerp', () {
      test('t=0 returns theme equal to a', () {
        final a = OiTextTheme.standard(fontFamily: 'Inter');
        final b = OiTextTheme.standard(fontFamily: 'Roboto');
        final result = OiTextTheme.lerp(a, b, 0);
        expect(result, equals(a));
      });

      test('t=1 returns theme equal to b', () {
        final a = OiTextTheme.standard(fontFamily: 'Inter');
        final b = OiTextTheme.standard(fontFamily: 'Roboto');
        final result = OiTextTheme.lerp(a, b, 1);
        expect(result, equals(b));
      });

      test('t=0.5 interpolates body fontSize', () {
        final a = OiTextTheme.standard();
        const bigBody = TextStyle(fontSize: 32, fontWeight: FontWeight.w400);
        final b = a.copyWith(body: bigBody);
        final mid = OiTextTheme.lerp(a, b, 0.5);
        // Should be between 16 and 32 → approximately 24
        expect(mid.body.fontSize, closeTo(24, 1));
      });
    });

    group('equality', () {
      test('two standard themes are equal', () {
        final a = OiTextTheme.standard();
        final b = OiTextTheme.standard();
        expect(a, equals(b));
      });

      test('themes with different fontFamily are not equal', () {
        final a = OiTextTheme.standard(fontFamily: 'Inter');
        final b = OiTextTheme.standard(fontFamily: 'Roboto');
        expect(a, isNot(equals(b)));
      });

      test('hashCode is consistent', () {
        final a = OiTextTheme.standard();
        final b = OiTextTheme.standard();
        expect(a.hashCode, equals(b.hashCode));
      });
    });
  });
}
