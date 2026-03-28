import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

void main() {
  group('Size constants', () {
    test('values match expected dp', () {
      expect(s0, 0);
      expect(s1, 1);
      expect(s2, 2);
      expect(s4, 4);
      expect(s6, 6);
      expect(s8, 8);
      expect(s10, 10);
      expect(s12, 12);
      expect(s14, 14);
      expect(s16, 16);
      expect(s20, 20);
      expect(s24, 24);
      expect(s28, 28);
      expect(s32, 32);
      expect(s36, 36);
      expect(s40, 40);
      expect(s44, 44);
      expect(s48, 48);
      expect(s56, 56);
      expect(s64, 64);
      expect(s72, 72);
      expect(s80, 80);
      expect(s96, 96);
      expect(s128, 128);
    });

    test('OiSpacingScale parity', () {
      final spacing = OiSpacingScale.standard();
      expect(s4, spacing.xs);
      expect(s8, spacing.sm);
      expect(s16, spacing.md);
      expect(s24, spacing.lg);
      expect(s32, spacing.xl);
      expect(s48, spacing.xxl);
    });
  });

  group('Vertical gap widgets', () {
    test('gapH0 has zero dimensions', () {
      expect(gapH0.width, 0);
      expect(gapH0.height, 0);
    });

    test('gapH constants have correct height and null width', () {
      expect(gapH2.height, s2);
      expect(gapH2.width, isNull);

      expect(gapH4.height, s4);
      expect(gapH4.width, isNull);

      expect(gapH8.height, s8);
      expect(gapH8.width, isNull);

      expect(gapH12.height, s12);
      expect(gapH12.width, isNull);

      expect(gapH16.height, s16);
      expect(gapH16.width, isNull);

      expect(gapH20.height, s20);
      expect(gapH20.width, isNull);

      expect(gapH24.height, s24);
      expect(gapH24.width, isNull);

      expect(gapH32.height, s32);
      expect(gapH32.width, isNull);

      expect(gapH48.height, s48);
      expect(gapH48.width, isNull);

      expect(gapH64.height, s64);
      expect(gapH64.width, isNull);
    });

    test('all gapH constants are const (identical across references)', () {
      expect(identical(gapH4, gapH4), isTrue);
      expect(identical(gapH16, gapH16), isTrue);
    });
  });

  group('Horizontal gap widgets', () {
    test('gapW0 has zero dimensions', () {
      expect(gapW0.width, 0);
      expect(gapW0.height, 0);
    });

    test('gapW constants have correct width and null height', () {
      expect(gapW2.width, s2);
      expect(gapW2.height, isNull);

      expect(gapW4.width, s4);
      expect(gapW4.height, isNull);

      expect(gapW8.width, s8);
      expect(gapW8.height, isNull);

      expect(gapW12.width, s12);
      expect(gapW12.height, isNull);

      expect(gapW16.width, s16);
      expect(gapW16.height, isNull);

      expect(gapW20.width, s20);
      expect(gapW20.height, isNull);

      expect(gapW24.width, s24);
      expect(gapW24.height, isNull);

      expect(gapW32.width, s32);
      expect(gapW32.height, isNull);

      expect(gapW48.width, s48);
      expect(gapW48.height, isNull);

      expect(gapW64.width, s64);
      expect(gapW64.height, isNull);
    });

    test('all gapW constants are const (identical across references)', () {
      expect(identical(gapW4, gapW4), isTrue);
      expect(identical(gapW16, gapW16), isTrue);
    });
  });

  group('EdgeInsets presets — all sides', () {
    test('pad constants match EdgeInsets.all', () {
      expect(pad4, const EdgeInsets.all(4));
      expect(pad8, const EdgeInsets.all(8));
      expect(pad12, const EdgeInsets.all(12));
      expect(pad16, const EdgeInsets.all(16));
      expect(pad20, const EdgeInsets.all(20));
      expect(pad24, const EdgeInsets.all(24));
      expect(pad32, const EdgeInsets.all(32));
      expect(pad48, const EdgeInsets.all(48));
    });
  });

  group('EdgeInsets presets — horizontal', () {
    test('padX constants match EdgeInsets.symmetric(horizontal:)', () {
      expect(padX4, const EdgeInsets.symmetric(horizontal: 4));
      expect(padX8, const EdgeInsets.symmetric(horizontal: 8));
      expect(padX12, const EdgeInsets.symmetric(horizontal: 12));
      expect(padX16, const EdgeInsets.symmetric(horizontal: 16));
      expect(padX24, const EdgeInsets.symmetric(horizontal: 24));
      expect(padX32, const EdgeInsets.symmetric(horizontal: 32));
    });
  });

  group('EdgeInsets presets — vertical', () {
    test('padY constants match EdgeInsets.symmetric(vertical:)', () {
      expect(padY4, const EdgeInsets.symmetric(vertical: 4));
      expect(padY8, const EdgeInsets.symmetric(vertical: 8));
      expect(padY12, const EdgeInsets.symmetric(vertical: 12));
      expect(padY16, const EdgeInsets.symmetric(vertical: 16));
      expect(padY24, const EdgeInsets.symmetric(vertical: 24));
      expect(padY32, const EdgeInsets.symmetric(vertical: 32));
    });
  });

  group('shrink constant', () {
    test('is a zero-size SizedBox', () {
      expect(shrink.width, 0);
      expect(shrink.height, 0);
    });
  });
}
