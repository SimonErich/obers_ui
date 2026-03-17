// Tests are internal; doc comments on local helpers are not required.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';

/// Wraps [child] in a [MediaQuery] with the given [width].
Widget buildWithWidth(double width, Widget child) {
  return MediaQuery(
    data: MediaQueryData(size: Size(width, 800)),
    child: Directionality(textDirection: TextDirection.ltr, child: child),
  );
}

void main() {
  group('OiBreakpoint constants', () {
    test('compact has minWidth 0', () {
      expect(OiBreakpoint.compact.minWidth, 0);
    });

    test('medium has minWidth 600', () {
      expect(OiBreakpoint.medium.minWidth, 600);
    });

    test('expanded has minWidth 840', () {
      expect(OiBreakpoint.expanded.minWidth, 840);
    });

    test('large has minWidth 1200', () {
      expect(OiBreakpoint.large.minWidth, 1200);
    });

    test('extraLarge has minWidth 1600', () {
      expect(OiBreakpoint.extraLarge.minWidth, 1600);
    });

    test('values has 5 items', () {
      expect(OiBreakpoint.values.length, 5);
    });
  });

  group('OiBreakpoint.compareTo', () {
    test('orders by minWidth ascending', () {
      final sorted = [...OiBreakpoint.values]..sort();
      expect(sorted.map((b) => b.minWidth).toList(), [0, 600, 840, 1200, 1600]);
    });

    test('compact is less than medium', () {
      expect(OiBreakpoint.compact.compareTo(OiBreakpoint.medium), isNegative);
    });

    test('extraLarge is greater than large', () {
      expect(OiBreakpoint.extraLarge.compareTo(OiBreakpoint.large), isPositive);
    });

    test('equal minWidth returns 0', () {
      const a = OiBreakpoint('a', 600);
      const b = OiBreakpoint('b', 600);
      expect(a.compareTo(b), 0);
    });
  });

  group('OiBreakpoint equality', () {
    test('same name and minWidth are equal', () {
      expect(OiBreakpoint.compact, equals(OiBreakpoint.compact));
    });

    test('different name is not equal', () {
      const a = OiBreakpoint('other', 0);
      expect(a, isNot(equals(OiBreakpoint.compact)));
    });

    test('different minWidth is not equal', () {
      const a = OiBreakpoint('compact', 1);
      expect(a, isNot(equals(OiBreakpoint.compact)));
    });

    test('static constants are equal to themselves', () {
      expect(OiBreakpoint.compact, equals(OiBreakpoint.compact));
      expect(OiBreakpoint.medium, equals(OiBreakpoint.medium));
    });
  });

  group('OiResponsiveValue.resolve', () {
    test('returns compact value at width 0', () {
      const rv = OiResponsiveValue<String>(compact: 'c', fallback: 'fb');
      expect(rv.resolve(0), 'c');
    });

    test('returns compact value at width 599', () {
      const rv = OiResponsiveValue<String>(compact: 'c', fallback: 'fb');
      expect(rv.resolve(599), 'c');
    });

    test('returns medium value at width 600', () {
      const rv = OiResponsiveValue<String>(
        compact: 'c',
        medium: 'm',
        fallback: 'fb',
      );
      expect(rv.resolve(600), 'm');
    });

    test('returns expanded value at width 840', () {
      const rv = OiResponsiveValue<String>(
        compact: 'c',
        medium: 'm',
        expanded: 'e',
        fallback: 'fb',
      );
      expect(rv.resolve(840), 'e');
    });

    test('returns large value at width 1200', () {
      const rv = OiResponsiveValue<String>(
        compact: 'c',
        medium: 'm',
        expanded: 'e',
        large: 'l',
        fallback: 'fb',
      );
      expect(rv.resolve(1200), 'l');
    });

    test('returns extraLarge value at width 1600', () {
      const rv = OiResponsiveValue<String>(
        compact: 'c',
        medium: 'm',
        expanded: 'e',
        large: 'l',
        extraLarge: 'xl',
        fallback: 'fb',
      );
      expect(rv.resolve(1600), 'xl');
    });

    test('falls back to lower breakpoint when higher is null', () {
      // No expanded value; width 840 should fall back to medium.
      const rv = OiResponsiveValue<String>(compact: 'c', medium: 'm');
      expect(rv.resolve(840), 'm');
    });

    test('falls back to compact when only compact is set', () {
      const rv = OiResponsiveValue<String>(compact: 'c');
      expect(rv.resolve(1600), 'c');
    });

    test('returns fallback when nothing matches', () {
      const rv = OiResponsiveValue<String>(fallback: 'fb');
      expect(rv.resolve(0), 'fb');
    });

    test('returns null when no value and no fallback', () {
      const rv = OiResponsiveValue<String>();
      expect(rv.resolve(500), isNull);
    });
  });

  group('BuildContext responsive extensions', () {
    testWidgets('breakpoint is compact at width 400', (tester) async {
      late OiBreakpoint captured;
      await tester.pumpWidget(
        buildWithWidth(
          400,
          Builder(
            builder: (ctx) {
              captured = ctx.breakpoint;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured, OiBreakpoint.compact);
    });

    testWidgets('breakpoint is medium at width 600', (tester) async {
      late OiBreakpoint captured;
      await tester.pumpWidget(
        buildWithWidth(
          600,
          Builder(
            builder: (ctx) {
              captured = ctx.breakpoint;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured, OiBreakpoint.medium);
    });

    testWidgets('breakpoint is expanded at width 840', (tester) async {
      late OiBreakpoint captured;
      await tester.pumpWidget(
        buildWithWidth(
          840,
          Builder(
            builder: (ctx) {
              captured = ctx.breakpoint;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured, OiBreakpoint.expanded);
    });

    testWidgets('breakpoint is large at width 1200', (tester) async {
      late OiBreakpoint captured;
      await tester.pumpWidget(
        buildWithWidth(
          1200,
          Builder(
            builder: (ctx) {
              captured = ctx.breakpoint;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured, OiBreakpoint.large);
    });

    testWidgets('breakpoint is extraLarge at width 1600', (tester) async {
      late OiBreakpoint captured;
      await tester.pumpWidget(
        buildWithWidth(
          1600,
          Builder(
            builder: (ctx) {
              captured = ctx.breakpoint;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured, OiBreakpoint.extraLarge);
    });

    testWidgets('isCompact is true at width 400', (tester) async {
      late bool result;
      await tester.pumpWidget(
        buildWithWidth(
          400,
          Builder(
            builder: (ctx) {
              result = ctx.isCompact;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, isTrue);
    });

    testWidgets('isCompact is false at width 600', (tester) async {
      late bool result;
      await tester.pumpWidget(
        buildWithWidth(
          600,
          Builder(
            builder: (ctx) {
              result = ctx.isCompact;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, isFalse);
    });

    testWidgets('isMedium is true at width 700', (tester) async {
      late bool result;
      await tester.pumpWidget(
        buildWithWidth(
          700,
          Builder(
            builder: (ctx) {
              result = ctx.isMedium;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, isTrue);
    });

    testWidgets('isMedium is false at width 840', (tester) async {
      late bool result;
      await tester.pumpWidget(
        buildWithWidth(
          840,
          Builder(
            builder: (ctx) {
              result = ctx.isMedium;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, isFalse);
    });

    testWidgets('isExpanded is true at width 900', (tester) async {
      late bool result;
      await tester.pumpWidget(
        buildWithWidth(
          900,
          Builder(
            builder: (ctx) {
              result = ctx.isExpanded;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, isTrue);
    });

    testWidgets('pageGutter is 16 at compact width', (tester) async {
      late double result;
      await tester.pumpWidget(
        buildWithWidth(
          400,
          Builder(
            builder: (ctx) {
              result = ctx.pageGutter;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, 16);
    });

    testWidgets('pageGutter is 24 at medium width', (tester) async {
      late double result;
      await tester.pumpWidget(
        buildWithWidth(
          600,
          Builder(
            builder: (ctx) {
              result = ctx.pageGutter;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, 24);
    });

    testWidgets('pageGutter is 32 at expanded width', (tester) async {
      late double result;
      await tester.pumpWidget(
        buildWithWidth(
          840,
          Builder(
            builder: (ctx) {
              result = ctx.pageGutter;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, 32);
    });

    testWidgets('contentMaxWidth is infinity at compact width', (tester) async {
      late double result;
      await tester.pumpWidget(
        buildWithWidth(
          400,
          Builder(
            builder: (ctx) {
              result = ctx.contentMaxWidth;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, double.infinity);
    });

    testWidgets('contentMaxWidth is 720 at medium width', (tester) async {
      late double result;
      await tester.pumpWidget(
        buildWithWidth(
          600,
          Builder(
            builder: (ctx) {
              result = ctx.contentMaxWidth;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, 720);
    });
  });
}
