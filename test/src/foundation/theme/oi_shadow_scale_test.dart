// ignore_for_file: public_member_api_docs // No public API docs needed in test files.

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/theme/oi_shadow_scale.dart';

void main() {
  group('OiShadowScale', () {
    group('standard()', () {
      late OiShadowScale scale;
      setUp(() => scale = OiShadowScale.standard());

      test('none is empty', () => expect(scale.none, isEmpty));

      test('xs has 1 shadow', () => expect(scale.xs.length, 1));

      test('xs shadow has correct offset and blur', () {
        final shadow = scale.xs.first;
        expect(shadow.offset, const Offset(0, 1));
        expect(shadow.blurRadius, 2);
        expect(shadow.spreadRadius, 0);
        expect(shadow.color, const Color(0x0D000000));
      });

      test('sm has 1 shadow', () => expect(scale.sm.length, 1));

      test('sm shadow has correct offset and blur', () {
        final shadow = scale.sm.first;
        expect(shadow.offset, const Offset(0, 2));
        expect(shadow.blurRadius, 4);
        expect(shadow.spreadRadius, 0);
        expect(shadow.color, const Color(0x14000000));
      });

      test('md has 2 shadows', () => expect(scale.md.length, 2));

      test('md first shadow is correct', () {
        final shadow = scale.md.first;
        expect(shadow.offset, const Offset(0, 4));
        expect(shadow.blurRadius, 8);
        expect(shadow.color, const Color(0x14000000));
      });

      test('md second shadow is correct', () {
        final shadow = scale.md[1];
        expect(shadow.offset, const Offset(0, 2));
        expect(shadow.blurRadius, 4);
        expect(shadow.color, const Color(0x0A000000));
      });

      test('lg has 2 shadows', () => expect(scale.lg.length, 2));

      test('lg first shadow has offset (0,8) blur 16', () {
        final shadow = scale.lg.first;
        expect(shadow.offset, const Offset(0, 8));
        expect(shadow.blurRadius, 16);
        expect(shadow.color, const Color(0x14000000));
      });

      test('xl has 2 shadows', () => expect(scale.xl.length, 2));

      test('xl first shadow has offset (0,16) blur 32', () {
        final shadow = scale.xl.first;
        expect(shadow.offset, const Offset(0, 16));
        expect(shadow.blurRadius, 32);
        expect(shadow.color, const Color(0x1F000000));
      });

      test('glass has 1 shadow', () => expect(scale.glass.length, 1));

      test('glass shadow has blur 24 and correct color', () {
        final shadow = scale.glass.first;
        expect(shadow.blurRadius, 24);
        expect(shadow.spreadRadius, 0);
        expect(shadow.color, const Color(0x1A000000));
      });
    });

    group('dark()', () {
      late OiShadowScale scale;
      setUp(() => scale = OiShadowScale.dark());

      test('none is empty', () => expect(scale.none, isEmpty));
      test('xs has 1 shadow', () => expect(scale.xs.length, 1));
      test('md has 2 shadows', () => expect(scale.md.length, 2));
      test('glass has 1 shadow', () => expect(scale.glass.length, 1));
    });

    group('copyWith', () {
      test('returns same values when no overrides', () {
        final scale = OiShadowScale.standard();
        expect(scale.copyWith(), equals(scale));
      });

      test('overrides none only', () {
        final scale = OiShadowScale.standard();
        const newNone = <BoxShadow>[];
        final copy = scale.copyWith(none: newNone);
        expect(copy.none, isEmpty);
        expect(copy.xs, scale.xs);
        expect(copy.sm, scale.sm);
        expect(copy.md, scale.md);
      });

      test('overrides xs', () {
        final scale = OiShadowScale.standard();
        final newXs = [const BoxShadow(blurRadius: 99)];
        final copy = scale.copyWith(xs: newXs);
        expect(copy.xs, newXs);
        expect(copy.sm, scale.sm);
      });

      test('overrides md', () {
        final scale = OiShadowScale.standard();
        final newMd = [
          const BoxShadow(color: Color(0xFF0000FF), blurRadius: 10),
          const BoxShadow(color: Color(0xFF0000FF), blurRadius: 5),
        ];
        final copy = scale.copyWith(md: newMd);
        expect(copy.md, newMd);
        expect(copy.lg, scale.lg);
      });
    });

    group('equality', () {
      test('two standard() instances are equal', () {
        expect(OiShadowScale.standard(), equals(OiShadowScale.standard()));
      });

      test('two dark() instances are equal', () {
        expect(OiShadowScale.dark(), equals(OiShadowScale.dark()));
      });

      test('standard and dark are not equal', () {
        expect(OiShadowScale.standard(), isNot(equals(OiShadowScale.dark())));
      });

      test('hashCode is consistent for standard()', () {
        expect(
          OiShadowScale.standard().hashCode,
          equals(OiShadowScale.standard().hashCode),
        );
      });

      test('identical instance equals itself', () {
        final scale = OiShadowScale.standard();
        expect(scale == scale, isTrue);
      });
    });
  });
}
