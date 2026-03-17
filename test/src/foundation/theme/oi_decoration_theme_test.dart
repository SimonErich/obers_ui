// Tests for OiDecorationTheme — no public API docs needed in test files.
// ignore_for_file: public_member_api_docs

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';

void main() {
  group('OiBorderStyle', () {
    group('.solid', () {
      test('sets lineStyle to solid', () {
        final border = OiBorderStyle.solid(const Color(0xFF000000), 1);
        expect(border.lineStyle, equals(OiBorderLineStyle.solid));
      });

      test('sets color correctly', () {
        const color = Color(0xFF2563EB);
        final border = OiBorderStyle.solid(color, 2);
        expect(border.color, equals(color));
      });

      test('sets width correctly', () {
        final border = OiBorderStyle.solid(const Color(0xFF000000), 3);
        expect(border.width, equals(3));
      });

      test('accepts optional borderRadius', () {
        final radius = BorderRadius.circular(8);
        final border = OiBorderStyle.solid(
          const Color(0xFF000000),
          1,
          borderRadius: radius,
        );
        expect(border.borderRadius, equals(radius));
      });
    });

    group('.dashed', () {
      test('sets lineStyle to dashed', () {
        final border = OiBorderStyle.dashed(const Color(0xFF000000), 1);
        expect(border.lineStyle, equals(OiBorderLineStyle.dashed));
      });
    });

    group('.dotted', () {
      test('sets lineStyle to dotted', () {
        final border = OiBorderStyle.dotted(const Color(0xFF000000), 1);
        expect(border.lineStyle, equals(OiBorderLineStyle.dotted));
      });
    });

    group('.gradient', () {
      test('stores gradient', () {
        const gradient = LinearGradient(
          colors: [Color(0xFF000000), Color(0xFFFFFFFF)],
        );
        final border = OiBorderStyle.gradient(gradient, 2);
        expect(border.gradient, equals(gradient));
      });

      test('color is fully transparent', () {
        const gradient = LinearGradient(
          colors: [Color(0xFF000000), Color(0xFFFFFFFF)],
        );
        final border = OiBorderStyle.gradient(gradient, 2);
        expect(border.color.a, equals(0.0));
      });
    });

    group('.none', () {
      test('color is fully transparent', () {
        final border = OiBorderStyle.none();
        expect(border.color.a, equals(0.0));
      });

      test('width is zero', () {
        final border = OiBorderStyle.none();
        expect(border.width, equals(0));
      });
    });

    test('copyWith overrides only specified fields', () {
      final original = OiBorderStyle.solid(const Color(0xFF000000), 1);
      final copy = original.copyWith(width: 3);
      expect(copy.width, equals(3));
      expect(copy.color, equals(original.color));
      expect(copy.lineStyle, equals(original.lineStyle));
    });

    test('equality holds for same values', () {
      final a = OiBorderStyle.solid(const Color(0xFF000000), 1);
      final b = OiBorderStyle.solid(const Color(0xFF000000), 1);
      expect(a, equals(b));
    });

    test('hashCode is consistent', () {
      final a = OiBorderStyle.solid(const Color(0xFF000000), 1);
      final b = OiBorderStyle.solid(const Color(0xFF000000), 1);
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('OiGradientStyle', () {
    group('.linear', () {
      test('toGradient() returns a LinearGradient', () {
        final style = OiGradientStyle.linear(const [
          Color(0xFF000000),
          Color(0xFFFFFFFF),
        ]);
        expect(style.toGradient(), isA<LinearGradient>());
      });

      test('linear is true', () {
        final style = OiGradientStyle.linear(const [
          Color(0xFF000000),
          Color(0xFFFFFFFF),
        ]);
        expect(style.linear, isTrue);
      });

      test('colors are stored correctly', () {
        const colors = [Color(0xFF000000), Color(0xFFFFFFFF)];
        final style = OiGradientStyle.linear(colors);
        expect(style.colors, equals(colors));
      });

      test('stops are stored correctly', () {
        final style = OiGradientStyle.linear(
          const [Color(0xFF000000), Color(0xFFFFFFFF)],
          stops: const [0.0, 1.0],
        );
        expect(style.stops, equals(const [0.0, 1.0]));
      });
    });

    group('.radial', () {
      test('toGradient() returns a RadialGradient', () {
        final style = OiGradientStyle.radial(const [
          Color(0xFF000000),
          Color(0xFFFFFFFF),
        ]);
        expect(style.toGradient(), isA<RadialGradient>());
      });

      test('linear is false', () {
        final style = OiGradientStyle.radial(const [
          Color(0xFF000000),
          Color(0xFFFFFFFF),
        ]);
        expect(style.linear, isFalse);
      });

      test('radius is stored correctly', () {
        final style = OiGradientStyle.radial(const [
          Color(0xFF000000),
          Color(0xFFFFFFFF),
        ], radius: 0.8);
        expect(style.radius, equals(0.8));
      });
    });

    test('copyWith overrides only specified fields', () {
      final original = OiGradientStyle.linear(const [
        Color(0xFF000000),
        Color(0xFFFFFFFF),
      ]);
      final copy = original.copyWith(
        colors: const [Color(0xFFFF0000), Color(0xFF0000FF)],
      );
      expect(copy.colors, equals(const [Color(0xFFFF0000), Color(0xFF0000FF)]));
      expect(copy.linear, equals(original.linear));
    });

    test('equality holds for same values', () {
      final a = OiGradientStyle.linear(const [
        Color(0xFF000000),
        Color(0xFFFFFFFF),
      ]);
      final b = OiGradientStyle.linear(const [
        Color(0xFF000000),
        Color(0xFFFFFFFF),
      ]);
      expect(a, equals(b));
    });

    test('hashCode is consistent', () {
      final a = OiGradientStyle.linear(const [
        Color(0xFF000000),
        Color(0xFFFFFFFF),
      ]);
      final b = OiGradientStyle.linear(const [
        Color(0xFF000000),
        Color(0xFFFFFFFF),
      ]);
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('OiDecorationTheme.standard', () {
    const primary = Color(0xFF2563EB);
    const error = Color(0xFFDC2626);
    late OiDecorationTheme theme;

    setUp(() {
      theme = OiDecorationTheme.standard(
        primaryColor: primary,
        errorColor: error,
      );
    });

    test('creates non-null defaultBorder', () {
      expect(theme.defaultBorder, isNotNull);
    });

    test('creates non-null focusBorder', () {
      expect(theme.focusBorder, isNotNull);
    });

    test('creates non-null errorBorder', () {
      expect(theme.errorBorder, isNotNull);
    });

    test('focusBorder color matches primaryColor', () {
      expect(theme.focusBorder.color, equals(primary));
    });

    test('errorBorder color matches errorColor', () {
      expect(theme.errorBorder.color, equals(error));
    });

    test('gradients map is non-empty', () {
      expect(theme.gradients, isNotEmpty);
    });
  });

  group('OiDecorationTheme.copyWith', () {
    test('overrides only specified field', () {
      final theme = OiDecorationTheme.standard(
        primaryColor: const Color(0xFF2563EB),
        errorColor: const Color(0xFFDC2626),
      );
      final newBorder = OiBorderStyle.dashed(const Color(0xFF000000), 1);
      final copy = theme.copyWith(defaultBorder: newBorder);
      expect(copy.defaultBorder, equals(newBorder));
      expect(copy.focusBorder, equals(theme.focusBorder));
      expect(copy.errorBorder, equals(theme.errorBorder));
    });

    test('equality holds when no fields change', () {
      final theme = OiDecorationTheme.standard(
        primaryColor: const Color(0xFF2563EB),
        errorColor: const Color(0xFFDC2626),
      );
      final copy = theme.copyWith();
      expect(copy, equals(theme));
    });

    test('hashCode is consistent', () {
      final a = OiDecorationTheme.standard(
        primaryColor: const Color(0xFF2563EB),
        errorColor: const Color(0xFFDC2626),
      );
      final b = OiDecorationTheme.standard(
        primaryColor: const Color(0xFF2563EB),
        errorColor: const Color(0xFFDC2626),
      );
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
