// ignore_for_file: public_member_api_docs // No public API docs needed in test files.

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/theme/oi_radius_scale.dart';

void main() {
  group('OiRadiusPreference', () {
    test('enum has three values', () {
      expect(OiRadiusPreference.values.length, 3);
    });
  });

  group('OiRadiusScale', () {
    group('forPreference(sharp)', () {
      late OiRadiusScale scale;
      setUp(
        () => scale = OiRadiusScale.forPreference(OiRadiusPreference.sharp),
      );

      test('none is zero', () => expect(scale.none, BorderRadius.zero));
      test('xs is zero', () => expect(scale.xs, BorderRadius.zero));
      test('sm is zero', () => expect(scale.sm, BorderRadius.zero));
      test('md is zero', () => expect(scale.md, BorderRadius.zero));
      test('lg is zero', () => expect(scale.lg, BorderRadius.zero));
      test('xl is zero', () => expect(scale.xl, BorderRadius.zero));
      test('full is zero', () => expect(scale.full, BorderRadius.zero));
    });

    group('forPreference(medium)', () {
      late OiRadiusScale scale;
      setUp(
        () => scale = OiRadiusScale.forPreference(OiRadiusPreference.medium),
      );

      test('none is zero', () => expect(scale.none, BorderRadius.zero));
      test('xs is non-zero', () {
        expect(scale.xs, isNot(BorderRadius.zero));
      });
      test('md has circular radius 8', () {
        expect(scale.md, const BorderRadius.all(Radius.circular(8)));
      });
      test('full has circular radius 9999', () {
        expect(scale.full, const BorderRadius.all(Radius.circular(9999)));
      });
    });

    group('forPreference(rounded)', () {
      late OiRadiusScale roundedScale;
      late OiRadiusScale mediumScale;
      setUp(() {
        roundedScale = OiRadiusScale.forPreference(OiRadiusPreference.rounded);
        mediumScale = OiRadiusScale.forPreference(OiRadiusPreference.medium);
      });

      test('md is larger than medium md', () {
        final roundedMd = roundedScale.md.topLeft.x;
        final mediumMd = mediumScale.md.topLeft.x;
        expect(roundedMd, greaterThan(mediumMd));
      });

      test('xl is larger than medium xl', () {
        expect(
          roundedScale.xl.topLeft.x,
          greaterThan(mediumScale.xl.topLeft.x),
        );
      });

      test('full has circular radius 9999', () {
        expect(
          roundedScale.full,
          const BorderRadius.all(Radius.circular(9999)),
        );
      });
    });

    group('copyWith', () {
      test('returns same values when no overrides', () {
        final scale = OiRadiusScale.forPreference(OiRadiusPreference.medium);
        expect(scale.copyWith(), equals(scale));
      });

      test('overrides md only', () {
        final scale = OiRadiusScale.forPreference(OiRadiusPreference.medium);
        const newMd = BorderRadius.all(Radius.circular(99));
        final copy = scale.copyWith(md: newMd);
        expect(copy.md, newMd);
        expect(copy.sm, scale.sm);
        expect(copy.lg, scale.lg);
        expect(copy.xl, scale.xl);
        expect(copy.full, scale.full);
      });

      test('overrides none and full', () {
        final scale = OiRadiusScale.forPreference(OiRadiusPreference.rounded);
        const newFull = BorderRadius.all(Radius.circular(500));
        final copy = scale.copyWith(full: newFull);
        expect(copy.full, newFull);
        expect(copy.md, scale.md);
      });
    });

    group('equality', () {
      test('same preference produces equal instances', () {
        expect(
          OiRadiusScale.forPreference(OiRadiusPreference.medium),
          equals(OiRadiusScale.forPreference(OiRadiusPreference.medium)),
        );
      });

      test('different preferences are not equal', () {
        expect(
          OiRadiusScale.forPreference(OiRadiusPreference.sharp),
          isNot(equals(OiRadiusScale.forPreference(OiRadiusPreference.medium))),
        );
      });

      test('hashCode is consistent', () {
        expect(
          OiRadiusScale.forPreference(OiRadiusPreference.medium).hashCode,
          equals(
            OiRadiusScale.forPreference(OiRadiusPreference.medium).hashCode,
          ),
        );
      });

      test('identical instance equals itself', () {
        final scale = OiRadiusScale.forPreference(OiRadiusPreference.rounded);
        expect(scale == scale, isTrue);
      });
    });

    test('const constructor stores all fields', () {
      const scale = OiRadiusScale(
        none: BorderRadius.zero,
        xs: BorderRadius.all(Radius.circular(1)),
        sm: BorderRadius.all(Radius.circular(2)),
        md: BorderRadius.all(Radius.circular(4)),
        lg: BorderRadius.all(Radius.circular(8)),
        xl: BorderRadius.all(Radius.circular(16)),
        full: BorderRadius.all(Radius.circular(9999)),
      );
      expect(scale.none, BorderRadius.zero);
      expect(scale.xs, const BorderRadius.all(Radius.circular(1)));
      expect(scale.full, const BorderRadius.all(Radius.circular(9999)));
    });
  });
}
