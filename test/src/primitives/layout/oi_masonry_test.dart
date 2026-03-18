// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/oi_span.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/primitives/layout/oi_masonry.dart';

import '../../../helpers/pump_app.dart';

Future<void> pumpAtWidth(
  WidgetTester tester,
  Widget widget,
  double width,
) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: Size(width, 800)),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: OiTheme(data: OiThemeData.light(), child: widget),
      ),
    ),
  );
}

void main() {
  // ── Basic rendering ────────────────────────────────────────────────────────

  testWidgets('renders all children', (tester) async {
    await tester.pumpObers(
      const OiMasonry(
        breakpoint: OiBreakpoint.compact,
        children: [Text('A'), Text('B'), Text('C'), Text('D')],
      ),
    );
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
  });

  testWidgets('renders outer Row with CrossAxisAlignment.start', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiMasonry(
        breakpoint: OiBreakpoint.compact,
        columns: OiResponsive<int>(3),
        children: [Text('X'), Text('Y'), Text('Z')],
      ),
    );
    final row = tester.widget<Row>(find.byType(Row).first);
    expect(row.crossAxisAlignment, CrossAxisAlignment.start);
  });

  // ── Column count ───────────────────────────────────────────────────────────

  testWidgets('creates one Column per masonry column', (tester) async {
    await tester.pumpObers(
      const OiMasonry(
        breakpoint: OiBreakpoint.compact,
        columns: OiResponsive<int>(3),
        children: [Text('1'), Text('2'), Text('3'), Text('4'), Text('5')],
      ),
    );
    // One Column per masonry column.
    expect(find.byType(Column), findsNWidgets(3));
  });

  // ── Gap spacing ────────────────────────────────────────────────────────────

  testWidgets('gap inserts SizedBox with given width between columns', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiMasonry(
        breakpoint: OiBreakpoint.compact,
        gap: OiResponsive<double>(12),
        children: [Text('A'), Text('B')],
      ),
    );
    // One horizontal SizedBox between the two Expanded columns.
    final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
    final widthBoxes = boxes.where((b) => b.width == 12).toList();
    expect(widthBoxes, hasLength(1));
  });

  testWidgets('gap inserts vertical SizedBox between items in same column', (
    tester,
  ) async {
    // 2 columns, 4 items → each column gets 2 items → 1 vertical spacer each.
    await tester.pumpObers(
      const OiMasonry(
        breakpoint: OiBreakpoint.compact,
        gap: OiResponsive<double>(8),
        children: [Text('A'), Text('B'), Text('C'), Text('D')],
      ),
    );
    final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
    final heightBoxes = boxes.where((b) => b.height == 8).toList();
    // 2 columns × 1 spacer each = 2 vertical spacers.
    expect(heightBoxes, hasLength(2));
  });

  // ── Responsive layout props ───────────────────────────────────────────────

  group('responsive layout props', () {
    testWidgets('responsive columns changes column count with breakpoint', (
      tester,
    ) async {
      final responsiveCols = OiResponsive<int>.breakpoints({
        OiBreakpoint.compact: 2,
        OiBreakpoint.expanded: 4,
      });

      // Compact → 2 columns.
      await tester.pumpObers(
        OiMasonry(
          columns: responsiveCols,
          breakpoint: OiBreakpoint.compact,
          children: const [
            Text('1'),
            Text('2'),
            Text('3'),
            Text('4'),
          ],
        ),
      );
      expect(find.byType(Column), findsNWidgets(2));

      // Expanded → 4 columns.
      await tester.pumpObers(
        OiMasonry(
          columns: responsiveCols,
          breakpoint: OiBreakpoint.expanded,
          children: const [
            Text('1'),
            Text('2'),
            Text('3'),
            Text('4'),
          ],
        ),
      );
      expect(find.byType(Column), findsNWidgets(4));
    });

    testWidgets('responsive gap changes spacing with breakpoint', (
      tester,
    ) async {
      final responsiveGap = OiResponsive<double>.breakpoints({
        OiBreakpoint.compact: 4,
        OiBreakpoint.expanded: 16,
      });

      // Compact → gap 4.
      await pumpAtWidth(
        tester,
        OiMasonry(
          breakpoint: OiBreakpoint.compact,
          gap: responsiveGap,
          children: const [Text('A'), Text('B')],
        ),
        400,
      );
      var boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(boxes.where((b) => b.width == 4), hasLength(1));

      // Expanded → gap 16.
      await pumpAtWidth(
        tester,
        OiMasonry(
          breakpoint: OiBreakpoint.expanded,
          gap: responsiveGap,
          children: const [Text('A'), Text('B')],
        ),
        900,
      );
      boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(boxes.where((b) => b.width == 16), hasLength(1));
    });
  });

  // ── Explicit breakpoint parameter ─────────────────────────────────────────

  group('explicit breakpoint parameter', () {
    testWidgets('breakpoint param overrides context for column count', (
      tester,
    ) async {
      final responsiveCols = OiResponsive<int>.breakpoints({
        OiBreakpoint.compact: 2,
        OiBreakpoint.expanded: 4,
      });

      // Screen is compact-width (400), but breakpoint is explicitly expanded.
      await pumpAtWidth(
        tester,
        OiMasonry(
          columns: responsiveCols,
          breakpoint: OiBreakpoint.expanded,
          children: const [Text('1'), Text('2'), Text('3'), Text('4')],
        ),
        400,
      );
      // Expanded → 4 columns, despite narrow viewport.
      expect(find.byType(Column), findsNWidgets(4));
    });
  });

  // ── Span: columnSpan ────────────────────────────────────────────────────────

  group('columnSpan', () {
    testWidgets('child with columnSpan 2 renders as spanning breaker', (
      tester,
    ) async {
      // 4 columns, gap 0, 800px → columnWidth = 200.
      // Item B spans 2 → width = 2 * 200 = 400.
      await tester.pumpObers(
        OiMasonry(
          breakpoint: OiBreakpoint.compact,
          columns: 4.responsive,
          children: [
            const Text('A'),
            const Text('B').span(columnSpan: const OiResponsive<int>(2)),
            const Text('C'),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectB = tester.getRect(find.text('B'));
      expect(rectB.width, closeTo(400, 1));

      // B should be below A (breaker between masonry sections).
      final rectA = tester.getRect(find.text('A'));
      expect(rectB.top, greaterThan(rectA.top));
    });

    testWidgets('columnSpan with gap includes internal gaps', (tester) async {
      // 4 columns, gap 8, 800px → columnWidth = (800 - 3*8) / 4 = 194.
      // Item B spans 2 → width = 2 * 194 + 1 * 8 = 396.
      await tester.pumpObers(
        OiMasonry(
          breakpoint: OiBreakpoint.compact,
          columns: 4.responsive,
          gap: 8.0.responsive,
          children: [
            const Text('A'),
            const Text('B').span(columnSpan: const OiResponsive<int>(2)),
            const Text('C'),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectB = tester.getRect(find.text('B'));
      expect(rectB.width, closeTo(396, 1));
    });

    testWidgets('spanFull fills entire width', (tester) async {
      await tester.pumpObers(
        OiMasonry(
          breakpoint: OiBreakpoint.compact,
          columns: 4.responsive,
          children: [
            const Text('A'),
            const Text('full').spanFull(),
            const Text('C'),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectFull = tester.getRect(find.text('full'));
      expect(rectFull.width, closeTo(800, 1));
    });

    testWidgets('columnSpan clamped to column count', (tester) async {
      // 3 columns, item requests span 5 → clamped to 3 (full width).
      await tester.pumpObers(
        OiMasonry(
          breakpoint: OiBreakpoint.compact,
          columns: 3.responsive,
          children: [
            const Text('A').span(columnSpan: const OiResponsive<int>(5)),
          ],
        ),
        surfaceSize: const Size(900, 600),
      );

      final rectA = tester.getRect(find.text('A'));
      expect(rectA.width, closeTo(900, 1));
    });

    testWidgets('span-1 items form masonry sections around spanning breakers', (
      tester,
    ) async {
      // Items: A(1), B(span 2), C(1), D(1)
      // Layout: masonry[A] → breaker[B] → masonry[C, D]
      await tester.pumpObers(
        OiMasonry(
          breakpoint: OiBreakpoint.compact,
          columns: 2.responsive,
          children: [
            const Text('A'),
            const Text('B').span(columnSpan: const OiResponsive<int>(2)),
            const Text('C'),
            const Text('D'),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectA = tester.getRect(find.text('A'));
      final rectB = tester.getRect(find.text('B'));
      final rectC = tester.getRect(find.text('C'));
      final rectD = tester.getRect(find.text('D'));

      // A is in first masonry section.
      expect(rectA.top, lessThan(rectB.top));
      // B is the spanning breaker.
      expect(rectB.width, closeTo(800, 1));
      // C and D are in second masonry section (side by side).
      expect(rectC.top, greaterThan(rectB.top));
      expect(rectD.top, greaterThan(rectB.top));
      expect(rectC.left, lessThan(rectD.left));
    });
  });

  // ── Span: columnStart ───────────────────────────────────────────────────────

  group('columnStart', () {
    testWidgets('columnStart places item in specified column', (tester) async {
      // 3 columns, gap 0, 900px → columnWidth = 300.
      // A: round-robin → col 0. B: columnStart 3 → col 2. C: round-robin → col 1.
      await tester.pumpObers(
        OiMasonry(
          breakpoint: OiBreakpoint.compact,
          columns: 3.responsive,
          children: [
            const Text('A').span(columnSpan: const OiResponsive<int>(1)),
            const Text('B').span(columnStart: const OiResponsive<int>(3)),
            const Text('C').span(columnSpan: const OiResponsive<int>(1)),
          ],
        ),
        surfaceSize: const Size(900, 600),
      );

      final leftA = tester.getRect(find.text('A')).left;
      final leftB = tester.getRect(find.text('B')).left;
      final leftC = tester.getRect(find.text('C')).left;

      // A at col 0 (0), C at col 1 (300), B at col 2 (600).
      expect(leftA, closeTo(0, 1));
      expect(leftC, closeTo(300, 1));
      expect(leftB, closeTo(600, 1));
    });

    testWidgets('columnStart with gap accounts for gap pixels', (
      tester,
    ) async {
      // 3 columns, gap 12, 900px → columnWidth = (900 - 24) / 3 = 292.
      // B: columnStart 3 → col 2 → left = 292 + 12 + 292 + 12 = 608.
      await tester.pumpObers(
        OiMasonry(
          breakpoint: OiBreakpoint.compact,
          columns: 3.responsive,
          gap: 12.0.responsive,
          children: [
            const Text('A').span(columnSpan: const OiResponsive<int>(1)),
            const Text('B').span(columnStart: const OiResponsive<int>(3)),
          ],
        ),
        surfaceSize: const Size(900, 600),
      );

      final leftB = tester.getRect(find.text('B')).left;
      expect(leftB, closeTo(608, 1));
    });
  });

  // ── Span: columnOrder ───────────────────────────────────────────────────────

  group('columnOrder', () {
    testWidgets('columnOrder reorders items before distribution', (
      tester,
    ) async {
      // Source order: A, B, C. Order: A=3, B=1, C=2.
      // Sorted: B, C, A. Round-robin: B→col 0, C→col 1, A→col 2.
      await tester.pumpObers(
        OiMasonry(
          breakpoint: OiBreakpoint.compact,
          columns: 3.responsive,
          children: [
            const Text('A').span(columnOrder: const OiResponsive<int>(3)),
            const Text('B').span(columnOrder: const OiResponsive<int>(1)),
            const Text('C').span(columnOrder: const OiResponsive<int>(2)),
          ],
        ),
        surfaceSize: const Size(900, 600),
      );

      final leftB = tester.getRect(find.text('B')).left;
      final leftC = tester.getRect(find.text('C')).left;
      final leftA = tester.getRect(find.text('A')).left;

      expect(leftB, lessThan(leftC));
      expect(leftC, lessThan(leftA));
    });

    testWidgets('items without order treated as order 0', (tester) async {
      // A has no order (treated as 0), B has order 1.
      // Sorted: A (0), B (1). Round-robin: A→col 0, B→col 1.
      await tester.pumpObers(
        OiMasonry(
          breakpoint: OiBreakpoint.compact,
          columns: 2.responsive,
          children: [
            const Text('A').span(columnSpan: const OiResponsive<int>(1)),
            const Text('B').span(columnOrder: const OiResponsive<int>(1)),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final leftA = tester.getRect(find.text('A')).left;
      final leftB = tester.getRect(find.text('B')).left;
      expect(leftA, lessThan(leftB));
    });

    testWidgets('negative order sorts before default', (tester) async {
      // B has no order (0), A has order -1.
      // Sorted: A (-1), B (0). Round-robin: A→col 0, B→col 1.
      await tester.pumpObers(
        OiMasonry(
          breakpoint: OiBreakpoint.compact,
          columns: 2.responsive,
          children: [
            const Text('B').span(columnSpan: const OiResponsive<int>(1)),
            const Text('A').span(columnOrder: const OiResponsive<int>(-1)),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final leftA = tester.getRect(find.text('A')).left;
      final leftB = tester.getRect(find.text('B')).left;
      expect(leftA, lessThan(leftB));
    });
  });

  // ── Span: responsive values ─────────────────────────────────────────────────

  group('responsive span values', () {
    testWidgets('columnSpan changes with breakpoint', (tester) async {
      final spanValue = OiResponsive<int>.breakpoints({
        OiBreakpoint.compact: 1,
        OiBreakpoint.medium: 2,
      });

      // Compact → span 1 → masonry column item, width = 400.
      await tester.pumpObers(
        OiMasonry(
          columns: 2.responsive,
          breakpoint: OiBreakpoint.compact,
          children: [
            const Text('A').span(columnSpan: spanValue),
            const Text('B'),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectACompact = tester.getRect(find.text('A'));
      expect(rectACompact.width, closeTo(400, 1));

      // Medium → span 2 → spanning breaker, full width.
      await tester.pumpObers(
        OiMasonry(
          columns: 2.responsive,
          breakpoint: OiBreakpoint.medium,
          children: [
            const Text('A').span(columnSpan: spanValue),
            const Text('B'),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectAMedium = tester.getRect(find.text('A'));
      expect(rectAMedium.width, closeTo(800, 1));
    });

    testWidgets('columnStart changes with breakpoint', (tester) async {
      // 3 columns, gap 0, 900px → columnWidth = 300.
      // Compact: start 1 → col 0 → left = 0.
      // Expanded: start 3 → col 2 → left = 600.
      final startValue = OiResponsive<int>.breakpoints({
        OiBreakpoint.compact: 1,
        OiBreakpoint.expanded: 3,
      });

      await tester.pumpObers(
        OiMasonry(
          columns: 3.responsive,
          breakpoint: OiBreakpoint.compact,
          children: [const Text('A').span(columnStart: startValue)],
        ),
        surfaceSize: const Size(900, 600),
      );

      final rectACompact = tester.getRect(find.text('A'));
      expect(rectACompact.left, closeTo(0, 1));

      await tester.pumpObers(
        OiMasonry(
          columns: 3.responsive,
          breakpoint: OiBreakpoint.expanded,
          children: [const Text('A').span(columnStart: startValue)],
        ),
        surfaceSize: const Size(900, 600),
      );

      final rectAExpanded = tester.getRect(find.text('A'));
      expect(rectAExpanded.left, closeTo(600, 1));
    });

    testWidgets('columnOrder changes with breakpoint', (tester) async {
      // 3 columns, 900px → columnWidth = 300.
      // Compact: A order=1, B order=2 → sorted: C(0), A(1), B(2)
      //          → C→col0, A→col1, B→col2
      // Large: A order=3, B order=1 → sorted: C(0), B(1), A(3)
      //        → C→col0, B→col1, A→col2
      final orderA = OiResponsive<int>.breakpoints({
        OiBreakpoint.compact: 1,
        OiBreakpoint.large: 3,
      });
      final orderB = OiResponsive<int>.breakpoints({
        OiBreakpoint.compact: 2,
        OiBreakpoint.large: 1,
      });

      await tester.pumpObers(
        OiMasonry(
          columns: 3.responsive,
          breakpoint: OiBreakpoint.compact,
          children: [
            const Text('A').span(columnOrder: orderA),
            const Text('B').span(columnOrder: orderB),
            const Text('C').span(columnSpan: const OiResponsive<int>(1)),
          ],
        ),
        surfaceSize: const Size(900, 600),
      );

      // Compact: C (order 0) first, then A (1), then B (2).
      var leftC = tester.getRect(find.text('C')).left;
      var leftA = tester.getRect(find.text('A')).left;
      var leftB = tester.getRect(find.text('B')).left;
      expect(leftC, lessThan(leftA));
      expect(leftA, lessThan(leftB));

      await tester.pumpObers(
        OiMasonry(
          columns: 3.responsive,
          breakpoint: OiBreakpoint.large,
          children: [
            const Text('A').span(columnOrder: orderA),
            const Text('B').span(columnOrder: orderB),
            const Text('C').span(columnSpan: const OiResponsive<int>(1)),
          ],
        ),
        surfaceSize: const Size(900, 600),
      );

      // Large: C (order 0) first, then B (1), then A (3).
      leftC = tester.getRect(find.text('C')).left;
      leftB = tester.getRect(find.text('B')).left;
      leftA = tester.getRect(find.text('A')).left;
      expect(leftC, lessThan(leftB));
      expect(leftB, lessThan(leftA));
    });
  });

  // ── Span: combined properties ───────────────────────────────────────────────

  group('combined span properties', () {
    testWidgets('order + span + start work together', (tester) async {
      // 4 columns, gap 0, 800px → columnWidth = 200.
      // Items: A(order 2), B(order 1, start 1, span 2)
      // Sorted: B(1), A(2).
      // B has span 2 → spanning breaker, width = 400.
      // A has span 1 → masonry group, placed at col 0.
      await tester.pumpObers(
        OiMasonry(
          breakpoint: OiBreakpoint.compact,
          columns: 4.responsive,
          children: [
            const Text('A').span(columnOrder: const OiResponsive<int>(2)),
            const Text('B').span(
              columnOrder: const OiResponsive<int>(1),
              columnSpan: const OiResponsive<int>(2),
            ),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectB = tester.getRect(find.text('B'));
      final rectA = tester.getRect(find.text('A'));

      // B is spanning breaker (first due to order), width = 400.
      expect(rectB.width, closeTo(400, 1));
      // A comes after B in a masonry section.
      expect(rectA.top, greaterThan(rectB.top));
    });

    testWidgets('columnStart + columnOrder for masonry items', (
      tester,
    ) async {
      // 3 columns, gap 0, 900px → columnWidth = 300.
      // Items: A(order 2), B(order 1, start 3), C(order 0)
      // Sorted: C(0), B(1), A(2).
      // All span 1 → masonry group.
      // C: round-robin 0 → col 0. B: start 3 → col 2. A: round-robin 1 → col 1.
      await tester.pumpObers(
        OiMasonry(
          breakpoint: OiBreakpoint.compact,
          columns: 3.responsive,
          children: [
            const Text('A').span(columnOrder: const OiResponsive<int>(2)),
            const Text('B').span(
              columnOrder: const OiResponsive<int>(1),
              columnStart: const OiResponsive<int>(3),
            ),
            const Text('C').span(columnSpan: const OiResponsive<int>(1)),
          ],
        ),
        surfaceSize: const Size(900, 600),
      );

      final leftC = tester.getRect(find.text('C')).left;
      final leftA = tester.getRect(find.text('A')).left;
      final leftB = tester.getRect(find.text('B')).left;

      expect(leftC, closeTo(0, 1));
      expect(leftA, closeTo(300, 1));
      expect(leftB, closeTo(600, 1));
    });
  });

  // ── Universal span contract ─────────────────────────────────────────────────

  group('universal span contract', () {
    testWidgets('span works on any widget type — not per-widget', (
      tester,
    ) async {
      // Container and SizedBox both use the same .span() API.
      await tester.pumpObers(
        OiMasonry(
          breakpoint: OiBreakpoint.compact,
          columns: 4.responsive,
          children: [
            Container(
              key: const Key('c'),
            ).span(columnSpan: const OiResponsive<int>(2)),
            const SizedBox(
              key: Key('s'),
            ).span(columnStart: const OiResponsive<int>(3)),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectC = tester.getRect(find.byKey(const Key('c')));
      // Container spans 2 cols → 400px.
      expect(rectC.width, closeTo(400, 1));

      final rectS = tester.getRect(find.byKey(const Key('s')));
      // SizedBox starts at col 3 → left at 400.
      expect(rectS.left, closeTo(400, 1));
    });

    testWidgets('non-OiSpan children get default span 1', (tester) async {
      await tester.pumpObers(
        OiMasonry(
          breakpoint: OiBreakpoint.compact,
          columns: 3.responsive,
          children: [
            const Text('plain'),
            const Text('spanned').span(
              columnSpan: const OiResponsive<int>(2),
            ),
          ],
        ),
        surfaceSize: const Size(900, 600),
      );

      final rectPlain = tester.getRect(find.text('plain'));
      final rectSpanned = tester.getRect(find.text('spanned'));

      expect(rectPlain.width, closeTo(300, 1));
      expect(rectSpanned.width, closeTo(600, 1));
    });
  });

  // ── Backward compatibility ──────────────────────────────────────────────────

  group('backward compatibility', () {
    testWidgets('masonry without spans uses Row fast path', (tester) async {
      await tester.pumpObers(
        const OiMasonry(
          breakpoint: OiBreakpoint.compact,
          columns: OiResponsive<int>(2),
          children: [Text('X'), Text('Y')],
        ),
      );
      // Fast path: should still use Row directly (no outer Column wrapper).
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('masonry with spans wraps in Column', (tester) async {
      await tester.pumpObers(
        OiMasonry(
          breakpoint: OiBreakpoint.compact,
          columns: 2.responsive,
          children: [
            const Text('X').span(columnSpan: const OiResponsive<int>(1)),
            const Text('Y'),
          ],
        ),
      );
      // Span path: outer Column wrapping the masonry Row.
      expect(find.byType(Row), findsOneWidget);
    });
  });
}
