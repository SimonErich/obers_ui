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
  // ─────────────────────────────────────────────────────────────────────────
  // OiBreakpoint
  // ─────────────────────────────────────────────────────────────────────────

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

  // ─────────────────────────────────────────────────────────────────────────
  // OiBreakpointScale
  // ─────────────────────────────────────────────────────────────────────────

  group('OiBreakpointScale', () {
    test('standard has 5 breakpoints', () {
      final scale = OiBreakpointScale.standard();
      expect(scale.values.length, 5);
    });

    test('standard breakpoints are in ascending order', () {
      final scale = OiBreakpointScale.standard();
      for (var i = 1; i < scale.values.length; i++) {
        expect(scale.values[i].minWidth,
            greaterThan(scale.values[i - 1].minWidth));
      }
    });

    test('extended has 7 breakpoints', () {
      final scale = OiBreakpointScale.extended();
      expect(scale.values.length, 7);
    });

    test('extended includes tablet and ultraWide', () {
      final scale = OiBreakpointScale.extended();
      expect(scale.values.any((b) => b.name == 'tablet'), isTrue);
      expect(scale.values.any((b) => b.name == 'ultraWide'), isTrue);
    });

    test('custom scale sorts automatically', () {
      final scale = OiBreakpointScale([
        OiBreakpoint.large,
        OiBreakpoint.compact,
        OiBreakpoint.medium,
      ]);
      expect(scale.values[0], OiBreakpoint.compact);
      expect(scale.values[1], OiBreakpoint.medium);
      expect(scale.values[2], OiBreakpoint.large);
    });

    test('throws when no breakpoint has minWidth 0', () {
      expect(
        () => OiBreakpointScale([OiBreakpoint.medium, OiBreakpoint.large]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('resolve returns compact at width 0', () {
      final scale = OiBreakpointScale.standard();
      expect(scale.resolve(0), OiBreakpoint.compact);
    });

    test('resolve returns medium at width 600', () {
      final scale = OiBreakpointScale.standard();
      expect(scale.resolve(600), OiBreakpoint.medium);
    });

    test('resolve returns expanded at width 840', () {
      final scale = OiBreakpointScale.standard();
      expect(scale.resolve(840), OiBreakpoint.expanded);
    });

    test('resolve returns large at width 1200', () {
      final scale = OiBreakpointScale.standard();
      expect(scale.resolve(1200), OiBreakpoint.large);
    });

    test('resolve returns extraLarge at width 1600', () {
      final scale = OiBreakpointScale.standard();
      expect(scale.resolve(1600), OiBreakpoint.extraLarge);
    });

    test('resolve returns compact at width 599', () {
      final scale = OiBreakpointScale.standard();
      expect(scale.resolve(599), OiBreakpoint.compact);
    });

    test('resolveIndex returns correct indices', () {
      final scale = OiBreakpointScale.standard();
      expect(scale.resolveIndex(0), 0);
      expect(scale.resolveIndex(599), 0);
      expect(scale.resolveIndex(600), 1);
      expect(scale.resolveIndex(840), 2);
      expect(scale.resolveIndex(1200), 3);
      expect(scale.resolveIndex(1600), 4);
    });

    test('equality works', () {
      final a = OiBreakpointScale.standard();
      final b = OiBreakpointScale.standard();
      expect(a, equals(b));
    });

    test('inequality works', () {
      final a = OiBreakpointScale.standard();
      final b = OiBreakpointScale.extended();
      expect(a, isNot(equals(b)));
    });

    test('resolve with extended scale includes tablet', () {
      final scale = OiBreakpointScale.extended();
      final bp = scale.resolve(500);
      expect(bp.name, 'tablet');
    });

    test('resolve with extended scale includes ultraWide', () {
      final scale = OiBreakpointScale.extended();
      final bp = scale.resolve(2000);
      expect(bp.name, 'ultraWide');
    });

    // ── Registry utility methods ──────────────────────────────────────────

    test('contains returns true for present breakpoint', () {
      final scale = OiBreakpointScale.standard();
      expect(scale.contains(OiBreakpoint.compact), isTrue);
      expect(scale.contains(OiBreakpoint.medium), isTrue);
      expect(scale.contains(OiBreakpoint.extraLarge), isTrue);
    });

    test('contains returns false for absent breakpoint', () {
      final scale = OiBreakpointScale.standard();
      expect(scale.contains(const OiBreakpoint('tablet', 480)), isFalse);
    });

    test('byName returns breakpoint for known name', () {
      final scale = OiBreakpointScale.standard();
      expect(scale.byName('compact'), OiBreakpoint.compact);
      expect(scale.byName('extraLarge'), OiBreakpoint.extraLarge);
    });

    test('byName returns null for unknown name', () {
      final scale = OiBreakpointScale.standard();
      expect(scale.byName('tablet'), isNull);
    });

    test('indexOf returns correct index', () {
      final scale = OiBreakpointScale.standard();
      expect(scale.indexOf(OiBreakpoint.compact), 0);
      expect(scale.indexOf(OiBreakpoint.medium), 1);
      expect(scale.indexOf(OiBreakpoint.expanded), 2);
      expect(scale.indexOf(OiBreakpoint.large), 3);
      expect(scale.indexOf(OiBreakpoint.extraLarge), 4);
    });

    test('indexOf returns -1 for absent breakpoint', () {
      final scale = OiBreakpointScale.standard();
      expect(scale.indexOf(const OiBreakpoint('tablet', 480)), -1);
    });

    // ── Page gutter resolution ────────────────────────────────────────────

    test('resolvePageGutter returns standard values', () {
      final scale = OiBreakpointScale.standard();
      expect(scale.resolvePageGutter(OiBreakpoint.compact), 16);
      expect(scale.resolvePageGutter(OiBreakpoint.medium), 24);
      expect(scale.resolvePageGutter(OiBreakpoint.expanded), 32);
      expect(scale.resolvePageGutter(OiBreakpoint.large), 40);
      expect(scale.resolvePageGutter(OiBreakpoint.extraLarge), 48);
    });

    test('resolvePageGutter cascades for custom breakpoints', () {
      final scale = OiBreakpointScale.extended();
      // tablet (480) has no entry in standard gutters if not explicitly set.
      // The extended scale provides tablet: 16.
      expect(scale.resolvePageGutter(const OiBreakpoint('tablet', 480)), 16);
    });

    test('resolvePageGutter with custom gutters', () {
      final scale = OiBreakpointScale(
        [
          OiBreakpoint.compact,
          const OiBreakpoint('custom', 500),
          OiBreakpoint.medium,
        ],
        pageGutters: {'compact': 12, 'custom': 20, 'medium': 28},
      );
      expect(scale.resolvePageGutter(const OiBreakpoint('custom', 500)), 20);
      expect(scale.resolvePageGutter(OiBreakpoint.compact), 12);
      expect(scale.resolvePageGutter(OiBreakpoint.medium), 28);
    });

    test('resolvePageGutter cascades to nearest smaller', () {
      final scale = OiBreakpointScale(
        [
          OiBreakpoint.compact,
          const OiBreakpoint('mid', 500),
          OiBreakpoint.medium,
        ],
        pageGutters: {'compact': 10},
      );
      // 'mid' has no entry, should cascade to 'compact'
      expect(scale.resolvePageGutter(const OiBreakpoint('mid', 500)), 10);
    });

    // ── Content max-width resolution ──────────────────────────────────────

    test('resolveContentMaxWidth returns standard values', () {
      final scale = OiBreakpointScale.standard();
      expect(scale.resolveContentMaxWidth(OiBreakpoint.compact), double.infinity);
      expect(scale.resolveContentMaxWidth(OiBreakpoint.medium), 720);
      expect(scale.resolveContentMaxWidth(OiBreakpoint.expanded), 960);
      expect(scale.resolveContentMaxWidth(OiBreakpoint.large), 1200);
      expect(scale.resolveContentMaxWidth(OiBreakpoint.extraLarge), 1400);
    });

    test('resolveContentMaxWidth cascades for custom breakpoints', () {
      final scale = OiBreakpointScale(
        [
          OiBreakpoint.compact,
          const OiBreakpoint('mid', 500),
          OiBreakpoint.medium,
        ],
        contentMaxWidths: {'compact': double.infinity, 'medium': 720},
      );
      // 'mid' cascades to 'compact'
      expect(
        scale.resolveContentMaxWidth(const OiBreakpoint('mid', 500)),
        double.infinity,
      );
    });

    // ── Custom scale with custom page gutters ─────────────────────────────

    test('custom scale accepts page gutters and content max widths', () {
      final scale = OiBreakpointScale(
        [
          OiBreakpoint.compact,
          const OiBreakpoint('tablet', 480),
          OiBreakpoint.medium,
        ],
        pageGutters: {'compact': 8, 'tablet': 12, 'medium': 20},
        contentMaxWidths: {
          'compact': double.infinity,
          'tablet': double.infinity,
          'medium': 600,
        },
      );
      expect(scale.resolvePageGutter(const OiBreakpoint('tablet', 480)), 12);
      expect(
        scale.resolveContentMaxWidth(const OiBreakpoint('tablet', 480)),
        double.infinity,
      );
      expect(scale.resolveContentMaxWidth(OiBreakpoint.medium), 600);
    });

    // ── Equality with maps ────────────────────────────────────────────────

    test('equality includes pageGutters and contentMaxWidths', () {
      final a = OiBreakpointScale(
        [OiBreakpoint.compact, OiBreakpoint.medium],
        pageGutters: {'compact': 10},
      );
      final b = OiBreakpointScale(
        [OiBreakpoint.compact, OiBreakpoint.medium],
        pageGutters: {'compact': 10},
      );
      expect(a, equals(b));
    });

    test('inequality when pageGutters differ', () {
      final a = OiBreakpointScale(
        [OiBreakpoint.compact, OiBreakpoint.medium],
        pageGutters: {'compact': 10},
      );
      final b = OiBreakpointScale(
        [OiBreakpoint.compact, OiBreakpoint.medium],
        pageGutters: {'compact': 20},
      );
      expect(a, isNot(equals(b)));
    });

    test('extended scale has page gutters for all breakpoints', () {
      final scale = OiBreakpointScale.extended();
      expect(scale.pageGutters.containsKey('tablet'), isTrue);
      expect(scale.pageGutters.containsKey('ultraWide'), isTrue);
      expect(scale.pageGutters.containsKey('compact'), isTrue);
    });

    test('extended scale has content max widths for all breakpoints', () {
      final scale = OiBreakpointScale.extended();
      expect(scale.contentMaxWidths.containsKey('tablet'), isTrue);
      expect(scale.contentMaxWidths.containsKey('ultraWide'), isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // OiResponsive<T>
  // ─────────────────────────────────────────────────────────────────────────

  group('OiResponsive', () {
    final scale = OiBreakpointScale.standard();

    test('static value returns same at every breakpoint', () {
      const r = OiResponsive<int>(3);
      expect(r.isStatic, isTrue);
      expect(r.resolve(OiBreakpoint.compact, scale), 3);
      expect(r.resolve(OiBreakpoint.large, scale), 3);
      expect(r.resolve(OiBreakpoint.extraLarge, scale), 3);
    });

    test('breakpoints map returns value for exact breakpoint', () {
      final r = OiResponsive<int>.breakpoints({
        OiBreakpoint.compact: 1,
        OiBreakpoint.medium: 2,
        OiBreakpoint.large: 4,
      });
      expect(r.isStatic, isFalse);
      expect(r.resolve(OiBreakpoint.compact, scale), 1);
      expect(r.resolve(OiBreakpoint.medium, scale), 2);
      expect(r.resolve(OiBreakpoint.large, scale), 4);
    });

    test('cascades to nearest smaller breakpoint', () {
      final r = OiResponsive<int>.breakpoints({
        OiBreakpoint.compact: 1,
        OiBreakpoint.large: 4,
      });
      // expanded (index 2) should cascade down to compact (index 0)
      expect(r.resolve(OiBreakpoint.expanded, scale), 1);
      // extraLarge (index 4) should cascade down to large (index 3)
      expect(r.resolve(OiBreakpoint.extraLarge, scale), 4);
    });

    test('falls back to defaultValue when no breakpoint matches', () {
      final r = OiResponsive<int>.breakpoints(
        {OiBreakpoint.medium: 2},
        defaultValue: 99,
      );
      // compact (index 0) has no entry, should use defaultValue
      expect(r.resolve(OiBreakpoint.compact, scale), 99);
    });

    test('works with extended scale', () {
      final extended = OiBreakpointScale.extended();
      const tablet = OiBreakpoint('tablet', 480);
      final r = OiResponsive<String>.breakpoints({
        OiBreakpoint.compact: 'phone',
        tablet: 'tablet',
        OiBreakpoint.large: 'desktop',
      });
      expect(r.resolve(OiBreakpoint.compact, extended), 'phone');
      expect(r.resolve(tablet, extended), 'tablet');
      expect(r.resolve(OiBreakpoint.medium, extended), 'tablet');
      expect(r.resolve(OiBreakpoint.large, extended), 'desktop');
    });

    test('equality for static values', () {
      const a = OiResponsive<int>(3);
      const b = OiResponsive<int>(3);
      expect(a, equals(b));
    });

    test('inequality for different static values', () {
      const a = OiResponsive<int>(3);
      const b = OiResponsive<int>(4);
      expect(a, isNot(equals(b)));
    });

    test('equality for breakpoint maps', () {
      final a = OiResponsive<int>.breakpoints({OiBreakpoint.compact: 1});
      final b = OiResponsive<int>.breakpoints({OiBreakpoint.compact: 1});
      expect(a, equals(b));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Convenience extensions
  // ─────────────────────────────────────────────────────────────────────────

  group('Convenience extensions', () {
    test('int.responsive creates static OiResponsive<int>', () {
      final r = 3.responsive;
      expect(r.isStatic, isTrue);
      expect(
        r.resolve(OiBreakpoint.compact, OiBreakpointScale.standard()),
        3,
      );
    });

    test('double.responsive creates static OiResponsive<double>', () {
      final r = 16.0.responsive;
      expect(r.isStatic, isTrue);
      expect(
        r.resolve(OiBreakpoint.compact, OiBreakpointScale.standard()),
        16.0,
      );
    });

    test('bool.responsive creates static OiResponsive<bool>', () {
      final r = true.responsive;
      expect(r.isStatic, isTrue);
      expect(
        r.resolve(OiBreakpoint.compact, OiBreakpointScale.standard()),
        isTrue,
      );
    });

    test('Map.responsive creates breakpoint OiResponsive', () {
      final r = {OiBreakpoint.compact: 1, OiBreakpoint.large: 4}.responsive;
      expect(r.isStatic, isFalse);
      final scale = OiBreakpointScale.standard();
      expect(r.resolve(OiBreakpoint.compact, scale), 1);
      expect(r.resolve(OiBreakpoint.large, scale), 4);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // OiResponsiveValue<T> (backward compatibility)
  // ─────────────────────────────────────────────────────────────────────────

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

  // ─────────────────────────────────────────────────────────────────────────
  // BuildContext responsive extensions
  // ─────────────────────────────────────────────────────────────────────────

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

    testWidgets('resolveResponsive resolves OiResponsive value',
        (tester) async {
      late int result;
      final responsive = OiResponsive<int>.breakpoints({
        OiBreakpoint.compact: 1,
        OiBreakpoint.medium: 2,
        OiBreakpoint.large: 4,
      });
      await tester.pumpWidget(
        buildWithWidth(
          600,
          Builder(
            builder: (ctx) {
              result = ctx.resolveResponsive(responsive);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, 2);
    });

    testWidgets('breakpointScale defaults to standard without theme',
        (tester) async {
      late OiBreakpointScale captured;
      await tester.pumpWidget(
        buildWithWidth(
          400,
          Builder(
            builder: (ctx) {
              captured = ctx.breakpointScale;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(captured.values.length, 5);
    });

    // ── Generic breakpoint helpers ──────────────────────────────────────

    testWidgets('isBreakpointActive returns true for active breakpoint',
        (tester) async {
      late bool result;
      await tester.pumpWidget(
        buildWithWidth(
          700,
          Builder(
            builder: (ctx) {
              result = ctx.isBreakpointActive(OiBreakpoint.medium);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, isTrue);
    });

    testWidgets('isBreakpointActive returns false for inactive breakpoint',
        (tester) async {
      late bool result;
      await tester.pumpWidget(
        buildWithWidth(
          700,
          Builder(
            builder: (ctx) {
              result = ctx.isBreakpointActive(OiBreakpoint.compact);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, isFalse);
    });

    testWidgets('isAtLeast returns true when at breakpoint', (tester) async {
      late bool result;
      await tester.pumpWidget(
        buildWithWidth(
          600,
          Builder(
            builder: (ctx) {
              result = ctx.isAtLeast(OiBreakpoint.medium);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, isTrue);
    });

    testWidgets('isAtLeast returns true when above breakpoint', (tester) async {
      late bool result;
      await tester.pumpWidget(
        buildWithWidth(
          1200,
          Builder(
            builder: (ctx) {
              result = ctx.isAtLeast(OiBreakpoint.medium);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, isTrue);
    });

    testWidgets('isAtLeast returns false when below breakpoint',
        (tester) async {
      late bool result;
      await tester.pumpWidget(
        buildWithWidth(
          400,
          Builder(
            builder: (ctx) {
              result = ctx.isAtLeast(OiBreakpoint.medium);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, isFalse);
    });

    testWidgets('pageGutter is 40 at large width', (tester) async {
      late double result;
      await tester.pumpWidget(
        buildWithWidth(
          1200,
          Builder(
            builder: (ctx) {
              result = ctx.pageGutter;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, 40);
    });

    testWidgets('pageGutter is 48 at extraLarge width', (tester) async {
      late double result;
      await tester.pumpWidget(
        buildWithWidth(
          1600,
          Builder(
            builder: (ctx) {
              result = ctx.pageGutter;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, 48);
    });

    testWidgets('contentMaxWidth is 960 at expanded width', (tester) async {
      late double result;
      await tester.pumpWidget(
        buildWithWidth(
          840,
          Builder(
            builder: (ctx) {
              result = ctx.contentMaxWidth;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, 960);
    });

    testWidgets('contentMaxWidth is 1200 at large width', (tester) async {
      late double result;
      await tester.pumpWidget(
        buildWithWidth(
          1200,
          Builder(
            builder: (ctx) {
              result = ctx.contentMaxWidth;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, 1200);
    });

    testWidgets('contentMaxWidth is 1400 at extraLarge width', (tester) async {
      late double result;
      await tester.pumpWidget(
        buildWithWidth(
          1600,
          Builder(
            builder: (ctx) {
              result = ctx.contentMaxWidth;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, 1400);
    });
  });
}
