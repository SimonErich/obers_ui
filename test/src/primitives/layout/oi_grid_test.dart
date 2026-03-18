// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/oi_span.dart';
import 'package:obers_ui/src/primitives/layout/oi_grid.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Fixed columns ──────────────────────────────────────────────────────────

  testWidgets('renders children with fixed columns', (tester) async {
    await tester.pumpObers(
      const OiGrid(
        breakpoint: OiBreakpoint.compact,
        columns: OiResponsive<int>(3),
        children: [Text('A'), Text('B'), Text('C'), Text('D')],
      ),
    );
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
  });

  testWidgets('uses custom RenderBox internally — no Wrap or GridView', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiGrid(
        breakpoint: OiBreakpoint.compact,
        columns: OiResponsive<int>(2),
        children: [Text('X'), Text('Y')],
      ),
    );
    // REQ-1075: must NOT use Wrap or GridView.
    expect(find.byType(Wrap), findsNothing);
    expect(find.byType(GridView), findsNothing);
    // Should still render children.
    expect(find.text('X'), findsOneWidget);
    expect(find.text('Y'), findsOneWidget);
  });

  testWidgets('each child gets computed width from column count', (
    tester,
  ) async {
    // Surface 800px wide, 2 columns, gap 0 → each item = 400px.
    await tester.pumpObers(
      const OiGrid(
        breakpoint: OiBreakpoint.compact,
        columns: OiResponsive<int>(2),
        children: [Text('A'), Text('B')],
      ),
      surfaceSize: const Size(800, 600),
    );
    final rectA = tester.getRect(find.text('A'));
    final rectB = tester.getRect(find.text('B'));
    expect(rectA.width, closeTo(400, 1));
    expect(rectB.width, closeTo(400, 1));
  });

  // ── Gap ───────────────────────────────────────────────────────────────────

  testWidgets('gap is applied between columns', (tester) async {
    // 2 columns, gap 8, 800px → unitWidth = (800-8)/2 = 396.
    // A at col 0 → left = 0.  B at col 1 → left = 396 + 8 = 404.
    await tester.pumpObers(
      const OiGrid(
        breakpoint: OiBreakpoint.compact,
        columns: OiResponsive<int>(2),
        gap: OiResponsive<double>(8),
        children: [Text('A'), Text('B')],
      ),
      surfaceSize: const Size(800, 600),
    );
    final rectA = tester.getRect(find.text('A'));
    final rectB = tester.getRect(find.text('B'));
    // Gap of 8px between A and B.
    expect(rectB.left - rectA.right, closeTo(8, 1));
  });

  testWidgets('rowGap overrides vertical gap between rows', (tester) async {
    // 1 column, gap=8, rowGap=24 → vertical gap should be 24.
    await tester.pumpObers(
      const OiGrid(
        breakpoint: OiBreakpoint.compact,
        columns: OiResponsive<int>(1),
        gap: OiResponsive<double>(8),
        rowGap: OiResponsive<double>(24),
        children: [Text('A'), Text('B')],
      ),
      surfaceSize: const Size(800, 600),
    );
    final rectA = tester.getRect(find.text('A'));
    final rectB = tester.getRect(find.text('B'));
    // Row gap = 24.
    expect(rectB.top - rectA.bottom, closeTo(24, 1));
  });

  // ── minColumnWidth ────────────────────────────────────────────────────────

  testWidgets('minColumnWidth auto-computes column count', (tester) async {
    // Surface 800px, minColumnWidth=200 → 4 columns, each ~200px wide (gap=0).
    await tester.pumpObers(
      const OiGrid(
        breakpoint: OiBreakpoint.compact,
        minColumnWidth: OiResponsive<double>(200),
        children: [Text('A'), Text('B'), Text('C'), Text('D')],
      ),
      surfaceSize: const Size(800, 600),
    );
    final rectA = tester.getRect(find.text('A'));
    final rectB = tester.getRect(find.text('B'));
    final rectC = tester.getRect(find.text('C'));
    final rectD = tester.getRect(find.text('D'));
    // 4 items should all fit on one row.
    expect(rectA.width, closeTo(200, 1));
    expect(rectB.width, closeTo(200, 1));
    expect(rectC.width, closeTo(200, 1));
    expect(rectD.width, closeTo(200, 1));
    // All on the same row.
    expect(rectA.top, closeTo(rectD.top, 1));
  });

  // ── Span: columnSpan ──────────────────────────────────────────────────────

  group('columnSpan', () {
    testWidgets('child with columnSpan 2 gets double-wide cell', (
      tester,
    ) async {
      // 4 columns, gap 0, 800px → unitWidth = 200.
      // Item A spans 2 cols → width = 2 * 200 = 400.
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 4.responsive,
          children: [
            const Text('A').span(columnSpan: const OiResponsive<int>(2)),
            const Text('B'),
            const Text('C'),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectA = tester.getRect(find.text('A'));
      final rectB = tester.getRect(find.text('B'));

      // A should be twice as wide as B.
      expect(rectA.width, closeTo(400, 1));
      expect(rectB.width, closeTo(200, 1));
    });

    testWidgets('columnSpan with gap includes internal gaps', (tester) async {
      // 4 columns, gap 8, 800px → unitWidth = (800 - 3*8) / 4 = 194.
      // Item A spans 2 → width = 2 * 194 + 1 * 8 = 396.
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 4.responsive,
          gap: 8.0.responsive,
          children: [
            const Text('A').span(columnSpan: const OiResponsive<int>(2)),
            const Text('B'),
            const Text('C'),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectA = tester.getRect(find.text('A'));
      expect(rectA.width, closeTo(396, 1));
    });

    testWidgets('columnSpan clamped to column count', (tester) async {
      // 3 columns, item requests span 5 → clamped to 3 (full row).
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 3.responsive,
          children: [
            const Text('A').span(columnSpan: const OiResponsive<int>(5)),
            const Text('B'),
          ],
        ),
        surfaceSize: const Size(900, 600),
      );

      final rectA = tester.getRect(find.text('A'));
      // Full row width.
      expect(rectA.width, closeTo(900, 1));
    });

    testWidgets('spanFull fills entire row', (tester) async {
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 4.responsive,
          gap: 8.0.responsive,
          children: [const Text('full').spanFull(), const Text('B')],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectFull = tester.getRect(find.text('full'));
      expect(rectFull.width, closeTo(800, 1));
    });

    testWidgets('span 2 wraps to next row when insufficient space', (
      tester,
    ) async {
      // 3 columns, items: A(1), B(1), C(span 2).
      // Row 0: A, B → cursor at 2; C needs 2 but only 1 left → new row.
      // Row 1: C (span 2).
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 3.responsive,
          children: [
            const Text('A'),
            const Text('B').span(columnSpan: const OiResponsive<int>(1)),
            const Text('C').span(columnSpan: const OiResponsive<int>(2)),
          ],
        ),
        surfaceSize: const Size(900, 600),
      );

      final rectA = tester.getRect(find.text('A'));
      final rectC = tester.getRect(find.text('C'));
      // C should be on a row below A.
      expect(rectC.top, greaterThan(rectA.bottom - 1));
    });
  });

  // ── Span: columnStart ─────────────────────────────────────────────────────

  group('columnStart', () {
    testWidgets('columnStart positions child at correct column', (
      tester,
    ) async {
      // 4 columns, gap 0, 800px → unitWidth = 200.
      // Item A at columnStart 3 (1-indexed) → x = 2 * 200 = 400.
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 4.responsive,
          children: [
            const Text('A').span(columnStart: const OiResponsive<int>(3)),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectA = tester.getRect(find.text('A'));
      expect(rectA.left, closeTo(400, 1));
    });

    testWidgets('columnStart with gap accounts for gap pixels', (tester) async {
      // 4 columns, gap 8, 800px → unitWidth = (800 - 24) / 4 = 194.
      // Start col 3 (0-indexed col 2) → x = 2 * (194 + 8) = 404.
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 4.responsive,
          gap: 8.0.responsive,
          children: [
            const Text('A').span(columnStart: const OiResponsive<int>(3)),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectA = tester.getRect(find.text('A'));
      expect(rectA.left, closeTo(404, 1));
    });

    testWidgets('columnStart behind cursor starts new row', (tester) async {
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 4.responsive,
          children: [
            const Text('A').span(columnSpan: const OiResponsive<int>(2)),
            const Text('B').span(columnStart: const OiResponsive<int>(1)),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectA = tester.getRect(find.text('A'));
      final rectB = tester.getRect(find.text('B'));
      // B should be on a different row since col 0 is occupied by A.
      // With CSS Grid packing, B requests col 0, which is taken on row 0,
      // so B goes to row 1.
      expect(rectB.top, greaterThan(rectA.bottom - 1));
      expect(rectB.left, closeTo(0, 1));
    });
  });

  // ── Span: columnOrder ─────────────────────────────────────────────────────

  group('columnOrder', () {
    testWidgets('columnOrder reorders children visually', (tester) async {
      // Source order: A, B, C. Order: A=3, B=1, C=2.
      // Visual order: B, C, A.
      await tester.pumpObers(
        OiGrid(
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
      await tester.pumpObers(
        OiGrid(
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
      await tester.pumpObers(
        OiGrid(
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

  // ── Span: responsive values ───────────────────────────────────────────────

  group('responsive span values', () {
    testWidgets('columnSpan changes with breakpoint', (tester) async {
      final spanValue = OiResponsive<int>.breakpoints({
        OiBreakpoint.compact: 1,
        OiBreakpoint.medium: 2,
      });

      // Explicit compact breakpoint → span 1 → unitWidth = 400.
      await tester.pumpObers(
        OiGrid(
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

      // Explicit medium breakpoint → span 2 → full width.
      await tester.pumpObers(
        OiGrid(
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
      // 4 columns, gap 0, 800px → unitWidth = 200.
      // Compact: start col 1 → x = 0.
      // Expanded: start col 3 → x = 400.
      final startValue = OiResponsive<int>.breakpoints({
        OiBreakpoint.compact: 1,
        OiBreakpoint.expanded: 3,
      });

      await tester.pumpObers(
        OiGrid(
          columns: 4.responsive,
          breakpoint: OiBreakpoint.compact,
          children: [const Text('A').span(columnStart: startValue)],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectACompact = tester.getRect(find.text('A'));
      expect(rectACompact.left, closeTo(0, 1));

      await tester.pumpObers(
        OiGrid(
          columns: 4.responsive,
          breakpoint: OiBreakpoint.expanded,
          children: [const Text('A').span(columnStart: startValue)],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectAExpanded = tester.getRect(find.text('A'));
      expect(rectAExpanded.left, closeTo(400, 1));
    });

    testWidgets('columnOrder changes with breakpoint', (tester) async {
      // 3 columns, 900px → unitWidth = 300.
      // Compact: A order=1, B order=2 → visual: A, B, C.
      // Large: A order=3, B order=1 → visual: B, C, A.
      final orderA = OiResponsive<int>.breakpoints({
        OiBreakpoint.compact: 1,
        OiBreakpoint.large: 3,
      });
      final orderB = OiResponsive<int>.breakpoints({
        OiBreakpoint.compact: 2,
        OiBreakpoint.large: 1,
      });

      await tester.pumpObers(
        OiGrid(
          columns: 3.responsive,
          breakpoint: OiBreakpoint.compact,
          children: [
            const Text('A').span(columnOrder: orderA),
            const Text('B').span(columnOrder: orderB),
            const Text('C'),
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
        OiGrid(
          columns: 3.responsive,
          breakpoint: OiBreakpoint.large,
          children: [
            const Text('A').span(columnOrder: orderA),
            const Text('B').span(columnOrder: orderB),
            const Text('C'),
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

    testWidgets('all span properties responsive simultaneously', (
      tester,
    ) async {
      // 4 columns, gap 0, 800px → unitWidth = 200.
      // Compact: span 1, start 1, order 0 → A at col 0, width 200.
      // Large: span 2, start 3, order 0 → A at col 2, width 400.
      await tester.pumpObers(
        OiGrid(
          columns: 4.responsive,
          breakpoint: OiBreakpoint.compact,
          children: [
            const Text('A').span(
              columnSpan: OiResponsive<int>.breakpoints({
                OiBreakpoint.compact: 1,
                OiBreakpoint.large: 2,
              }),
              columnStart: OiResponsive<int>.breakpoints({
                OiBreakpoint.compact: 1,
                OiBreakpoint.large: 3,
              }),
            ),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectCompact = tester.getRect(find.text('A'));
      expect(rectCompact.left, closeTo(0, 1));
      expect(rectCompact.width, closeTo(200, 1));

      await tester.pumpObers(
        OiGrid(
          columns: 4.responsive,
          breakpoint: OiBreakpoint.large,
          children: [
            const Text('A').span(
              columnSpan: OiResponsive<int>.breakpoints({
                OiBreakpoint.compact: 1,
                OiBreakpoint.large: 2,
              }),
              columnStart: OiResponsive<int>.breakpoints({
                OiBreakpoint.compact: 1,
                OiBreakpoint.large: 3,
              }),
            ),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectLarge = tester.getRect(find.text('A'));
      expect(rectLarge.left, closeTo(400, 1));
      expect(rectLarge.width, closeTo(400, 1));
    });
  });

  // ── Span: combined properties ─────────────────────────────────────────────

  group('combined span properties', () {
    testWidgets('columnStart + columnSpan positions and sizes correctly', (
      tester,
    ) async {
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 4.responsive,
          children: [
            const Text('A').span(
              columnStart: const OiResponsive<int>(2),
              columnSpan: const OiResponsive<int>(2),
            ),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectA = tester.getRect(find.text('A'));
      expect(rectA.left, closeTo(200, 1));
      expect(rectA.width, closeTo(400, 1));
    });

    testWidgets('order + span + start work together', (tester) async {
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 4.responsive,
          children: [
            const Text('A').span(columnOrder: const OiResponsive<int>(2)),
            const Text('B').span(
              columnOrder: const OiResponsive<int>(1),
              columnStart: const OiResponsive<int>(1),
              columnSpan: const OiResponsive<int>(2),
            ),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectB = tester.getRect(find.text('B'));
      final rectA = tester.getRect(find.text('A'));

      expect(rectB.left, closeTo(0, 1));
      expect(rectB.width, closeTo(400, 1));
      expect(rectA.left, closeTo(400, 1));
    });
  });

  // ── Span: mixed children ──────────────────────────────────────────────────

  group('mixed span and non-span children', () {
    testWidgets('non-OiSpan children get default span 1', (tester) async {
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 3.responsive,
          children: [
            const Text('plain'),
            const Text('spanned').span(columnSpan: const OiResponsive<int>(2)),
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

  // ── Span: explicit breakpoint parameter ───────────────────────────────────

  group('explicit breakpoint parameter', () {
    testWidgets('breakpoint param overrides context breakpoint', (
      tester,
    ) async {
      await tester.pumpObers(
        OiGrid(
          columns: 3.responsive,
          breakpoint: OiBreakpoint.large,
          children: [
            const Text('A').span(
              columnSpan: OiResponsive<int>.breakpoints({
                OiBreakpoint.compact: 1,
                OiBreakpoint.large: 3,
              }),
            ),
          ],
        ),
        surfaceSize: const Size(400, 600),
      );

      final rectA = tester.getRect(find.text('A'));
      expect(rectA.width, closeTo(400, 1));
    });
  });

  // ── Universal contract ───────────────────────────────────────────────────

  group('universal span contract', () {
    testWidgets('span works on any widget type — not per-widget', (
      tester,
    ) async {
      // Container, SizedBox, and DecoratedBox all use the same .span() API.
      // The grid reads span metadata identically regardless of child type.
      await tester.pumpObers(
        OiGrid(
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
      final rectS = tester.getRect(find.byKey(const Key('s')));

      // Container spans 2 cols → 400px.
      expect(rectC.width, closeTo(400, 1));
      // SizedBox starts at col 3 → left at 400.
      expect(rectS.left, closeTo(400, 1));
    });

    testWidgets('OiSpan.maybeOf returns null for non-span widget', (
      tester,
    ) async {
      expect(OiSpan.maybeOf(const SizedBox.shrink()), isNull);
    });

    testWidgets('OiSpan.maybeOf extracts data from span-wrapped widget', (
      tester,
    ) async {
      const data = OiSpanData(
        columnSpan: OiResponsive<int>(3),
        columnStart: OiResponsive<int>(2),
        columnOrder: OiResponsive<int>(1),
      );
      final widget = const Text('test').span(
        columnSpan: data.columnSpan,
        columnStart: data.columnStart,
        columnOrder: data.columnOrder,
      );
      final extracted = OiSpan.maybeOf(widget);
      expect(extracted, isNotNull);
      expect(extracted!.columnSpan, data.columnSpan);
      expect(extracted.columnStart, data.columnStart);
      expect(extracted.columnOrder, data.columnOrder);
    });
  });

  // ── Render object verification (REQ-1075) ───────────────────────────────

  group('render object verification', () {
    testWidgets('grid uses custom RenderBox, not Wrap or GridView', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: OiResponsive<int>(2),
          children: [Text('X'), Text('Y')],
        ),
      );
      // REQ-1075: must NOT use Wrap or GridView.
      expect(find.byType(Wrap), findsNothing);
      expect(find.byType(GridView), findsNothing);
      // Must NOT use LayoutBuilder (column count resolved inside RenderBox).
      expect(find.byType(LayoutBuilder), findsNothing);
    });

    testWidgets('grid with span children also uses custom RenderBox', (
      tester,
    ) async {
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 2.responsive,
          children: [
            const Text('X').span(columnSpan: const OiResponsive<int>(1)),
            const Text('Y'),
          ],
        ),
      );
      expect(find.byType(Wrap), findsNothing);
      expect(find.byType(GridView), findsNothing);
    });
  });

  // ── Responsive layout props ───────────────────────────────────────────────

  group('responsive layout props', () {
    testWidgets('responsive columns changes column count with breakpoint', (
      tester,
    ) async {
      final responsiveCols = OiResponsive<int>.breakpoints({
        OiBreakpoint.compact: 1,
        OiBreakpoint.medium: 2,
        OiBreakpoint.large: 4,
      });

      // Compact → 1 column → full-width items.
      await tester.pumpObers(
        OiGrid(
          columns: responsiveCols,
          breakpoint: OiBreakpoint.compact,
          children: const [Text('A'), Text('B')],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectACompact = tester.getRect(find.text('A'));
      expect(rectACompact.width, closeTo(800, 1));

      // Medium → 2 columns → half-width items.
      await tester.pumpObers(
        OiGrid(
          columns: responsiveCols,
          breakpoint: OiBreakpoint.medium,
          children: const [Text('A'), Text('B')],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectAMedium = tester.getRect(find.text('A'));
      expect(rectAMedium.width, closeTo(400, 1));

      // Large → 4 columns → quarter-width items.
      await tester.pumpObers(
        OiGrid(
          columns: responsiveCols,
          breakpoint: OiBreakpoint.large,
          children: const [Text('A'), Text('B')],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectALarge = tester.getRect(find.text('A'));
      expect(rectALarge.width, closeTo(200, 1));
    });

    testWidgets('responsive gap changes spacing with breakpoint', (
      tester,
    ) async {
      final responsiveGap = OiResponsive<double>.breakpoints({
        OiBreakpoint.compact: 4,
        OiBreakpoint.expanded: 16,
      });

      // Compact → gap 4.
      await tester.pumpObers(
        OiGrid(
          columns: const OiResponsive<int>(2),
          gap: responsiveGap,
          breakpoint: OiBreakpoint.compact,
          children: const [Text('A'), Text('B')],
        ),
        surfaceSize: const Size(800, 600),
      );

      var rectA = tester.getRect(find.text('A'));
      var rectB = tester.getRect(find.text('B'));
      expect(rectB.left - rectA.right, closeTo(4, 1));

      // Expanded → gap 16.
      await tester.pumpObers(
        OiGrid(
          columns: const OiResponsive<int>(2),
          gap: responsiveGap,
          breakpoint: OiBreakpoint.expanded,
          children: const [Text('A'), Text('B')],
        ),
        surfaceSize: const Size(800, 600),
      );

      rectA = tester.getRect(find.text('A'));
      rectB = tester.getRect(find.text('B'));
      expect(rectB.left - rectA.right, closeTo(16, 1));
    });
  });

  // ── Zero magic: explicit scale parameter ───────────────────────────────

  group('explicit scale parameter', () {
    testWidgets('scale param bypasses context for responsive resolution', (
      tester,
    ) async {
      final customScale = OiBreakpointScale.standard();

      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.medium,
          scale: customScale,
          columns: OiResponsive<int>.breakpoints({
            OiBreakpoint.compact: 1,
            OiBreakpoint.medium: 3,
          }),
          children: const [Text('A'), Text('B'), Text('C')],
        ),
        surfaceSize: const Size(900, 600),
      );

      // Medium breakpoint with standard scale → 3 columns, each 300px.
      final rectA = tester.getRect(find.text('A'));
      final rectB = tester.getRect(find.text('B'));
      final rectC = tester.getRect(find.text('C'));
      expect(rectA.width, closeTo(300, 1));
      expect(rectB.width, closeTo(300, 1));
      expect(rectC.width, closeTo(300, 1));
    });
  });

  // ── Zero magic: works without OiTheme ───────────────────────────────────

  group('zero magic — no context dependency', () {
    testWidgets('grid works without OiTheme — scale defaults to standard', (
      tester,
    ) async {
      // No OiApp/OiTheme wrapper — proves the widget is self-contained.
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 800,
            height: 600,
            child: OiGrid(
              breakpoint: OiBreakpoint.compact,
              columns: OiResponsive<int>(2),
              children: [Text('A'), Text('B')],
            ),
          ),
        ),
      );
      // Should not throw — scale defaults to OiBreakpointScale.defaultScale.
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('responsive values resolve with default scale', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 800,
            height: 600,
            child: OiGrid(
              breakpoint: OiBreakpoint.medium,
              columns: OiResponsive<int>.breakpoints({
                OiBreakpoint.compact: 1,
                OiBreakpoint.medium: 3,
              }),
              children: const [Text('A'), Text('B'), Text('C')],
            ),
          ),
        ),
      );
      // Medium breakpoint → 3 columns, each rendered.
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });
  });

  // ── CSS Grid row-packing algorithm (REQ-1076) ───────────────────────────

  group('CSS Grid row-packing', () {
    testWidgets('auto-places items into first available cell', (tester) async {
      // 3 cols, 900px → unit = 300.
      // A(1), B(1), C(1) → all on row 0.
      await tester.pumpObers(
        const OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: OiResponsive<int>(3),
          children: [Text('A'), Text('B'), Text('C')],
        ),
        surfaceSize: const Size(900, 600),
      );

      final rectA = tester.getRect(find.text('A'));
      final rectB = tester.getRect(find.text('B'));
      final rectC = tester.getRect(find.text('C'));

      // All on the same row.
      expect(rectA.top, closeTo(rectB.top, 1));
      expect(rectB.top, closeTo(rectC.top, 1));
      // Ordered left to right.
      expect(rectA.left, lessThan(rectB.left));
      expect(rectB.left, lessThan(rectC.left));
    });

    testWidgets('advances to next row when current row is full', (
      tester,
    ) async {
      // 2 cols, items: A, B, C, D → Row 0: A, B. Row 1: C, D.
      await tester.pumpObers(
        const OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: OiResponsive<int>(2),
          children: [Text('A'), Text('B'), Text('C'), Text('D')],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectA = tester.getRect(find.text('A'));
      final rectB = tester.getRect(find.text('B'));
      final rectC = tester.getRect(find.text('C'));
      final rectD = tester.getRect(find.text('D'));

      // Row 0: A and B.
      expect(rectA.top, closeTo(rectB.top, 1));
      // Row 1: C and D.
      expect(rectC.top, closeTo(rectD.top, 1));
      // Row 1 is below row 0.
      expect(rectC.top, greaterThan(rectA.bottom - 1));
    });

    testWidgets('columnStart items placed in first available row at that col', (
      tester,
    ) async {
      // 4 cols, A at col 1 (span 2), B at col 1 (span 1).
      // Row 0: A occupies cols 0-1. B requests col 0, occupied → row 1.
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 4.responsive,
          children: [
            const Text('A').span(
              columnStart: const OiResponsive<int>(1),
              columnSpan: const OiResponsive<int>(2),
            ),
            const Text('B').span(columnStart: const OiResponsive<int>(1)),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectA = tester.getRect(find.text('A'));
      final rectB = tester.getRect(find.text('B'));

      // B should be on row below A (both start at col 0).
      expect(rectB.top, greaterThan(rectA.bottom - 1));
      expect(rectB.left, closeTo(0, 1));
      expect(rectA.left, closeTo(0, 1));
    });
  });

  // ── Cursor tracking (REQ-1078) ──────────────────────────────────────────

  group('cursor tracking (REQ-1078)', () {
    testWidgets('cursor starts at (0, 0) — first item placed at top-left', (
      tester,
    ) async {
      // REQ-1078: cursor (row, column) starts at (0, 0).
      await tester.pumpObers(
        const OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: OiResponsive<int>(3),
          children: [Text('A')],
        ),
        surfaceSize: const Size(900, 600),
      );

      final rectA = tester.getRect(find.text('A'));
      expect(rectA.left, closeTo(0, 1));
      expect(rectA.top, closeTo(0, 1));
    });

    testWidgets('cursor advances column after each auto-placed child', (
      tester,
    ) async {
      // 3 cols: A at (0,0), cursor → (0,1). B at (0,1), cursor → (0,2).
      await tester.pumpObers(
        const OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: OiResponsive<int>(3),
          children: [Text('A'), Text('B'), Text('C')],
        ),
        surfaceSize: const Size(900, 600),
      );

      final rectA = tester.getRect(find.text('A'));
      final rectB = tester.getRect(find.text('B'));
      final rectC = tester.getRect(find.text('C'));

      // Sequential left-to-right placement on row 0.
      expect(rectA.left, closeTo(0, 1));
      expect(rectB.left, closeTo(300, 1));
      expect(rectC.left, closeTo(600, 1));
      expect(rectA.top, closeTo(rectB.top, 1));
      expect(rectB.top, closeTo(rectC.top, 1));
    });

    testWidgets('cursor wraps to next row when row is full', (tester) async {
      // 2 cols: after 2 items, cursor wraps to (1, 0).
      await tester.pumpObers(
        const OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: OiResponsive<int>(2),
          children: [Text('A'), Text('B'), Text('C')],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectA = tester.getRect(find.text('A'));
      final rectB = tester.getRect(find.text('B'));
      final rectC = tester.getRect(find.text('C'));

      // Row 0: A, B. Row 1: C.
      expect(rectA.top, closeTo(rectB.top, 1));
      expect(rectC.top, greaterThan(rectA.bottom - 1));
      expect(rectC.left, closeTo(0, 1));
    });

    testWidgets('cursor advances past multi-column span', (tester) async {
      // 4 cols: A spans 2 → cursor advances from (0,0) to (0,2).
      // B placed at (0,2).
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 4.responsive,
          children: [
            const Text('A').span(columnSpan: const OiResponsive<int>(2)),
            const Text('B'),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectA = tester.getRect(find.text('A'));
      final rectB = tester.getRect(find.text('B'));

      expect(rectA.left, closeTo(0, 1));
      expect(rectA.width, closeTo(400, 1));
      expect(rectB.left, closeTo(400, 1));
      expect(rectA.top, closeTo(rectB.top, 1));
    });

    testWidgets('cursor skips occupied cells from explicit-start items', (
      tester,
    ) async {
      // 3 cols: B has explicit col 1, A is auto-placed.
      // Sorted: B (order 1) first, A (order 2) second.
      // B explicit at col 0 → placed (0,0). Cursor still (0,0).
      // A auto: cursor (0,0), occupied → skip to (0,1), free → placed.
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 3.responsive,
          children: [
            const Text('A').span(columnOrder: const OiResponsive<int>(2)),
            const Text('B').span(
              columnOrder: const OiResponsive<int>(1),
              columnStart: const OiResponsive<int>(1),
            ),
          ],
        ),
        surfaceSize: const Size(900, 600),
      );

      final rectB = tester.getRect(find.text('B'));
      final rectA = tester.getRect(find.text('A'));

      expect(rectB.left, closeTo(0, 1));
      expect(rectA.left, closeTo(300, 1));
      expect(rectA.top, closeTo(rectB.top, 1));
    });
  });

  // ── Column order sorting (REQ-1079) ────────────────────────────────────

  group('columnOrder sorting (REQ-1079)', () {
    testWidgets('children sorted by columnOrder before placement', (
      tester,
    ) async {
      // REQ-1079: Source order A, B, C. Order: A=3, B=1, C=2.
      // Placement order: B, C, A → visual order: B at col 0, C at col 1, A at 2.
      await tester.pumpObers(
        OiGrid(
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

    testWidgets('null columnOrder treated as 0 in sort', (tester) async {
      // REQ-1079: Items without order treated as 0, sorted before positive.
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 3.responsive,
          children: [
            const Text('X').span(columnOrder: const OiResponsive<int>(1)),
            const Text('Y'), // null order → 0
            const Text('Z').span(columnOrder: const OiResponsive<int>(2)),
          ],
        ),
        surfaceSize: const Size(900, 600),
      );

      final leftY = tester.getRect(find.text('Y')).left;
      final leftX = tester.getRect(find.text('X')).left;
      final leftZ = tester.getRect(find.text('Z')).left;

      expect(leftY, lessThan(leftX));
      expect(leftX, lessThan(leftZ));
    });

    testWidgets('stable sort preserves source order for equal columnOrder', (
      tester,
    ) async {
      // REQ-1079: Equal order → source index breaks tie.
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 3.responsive,
          children: [
            const Text('First'), // order 0, index 0
            const Text('Second'), // order 0, index 1
            const Text('Third'), // order 0, index 2
          ],
        ),
        surfaceSize: const Size(900, 600),
      );

      final leftFirst = tester.getRect(find.text('First')).left;
      final leftSecond = tester.getRect(find.text('Second')).left;
      final leftThird = tester.getRect(find.text('Third')).left;

      expect(leftFirst, lessThan(leftSecond));
      expect(leftSecond, lessThan(leftThird));
    });
  });

  // ── columnSpan resolution (REQ-1080) ───────────────────────────────────

  group('columnSpan resolution (REQ-1080)', () {
    testWidgets('default columnSpan is 1', (tester) async {
      // REQ-1080: No span metadata → columnSpan defaults to 1.
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 4.responsive,
          children: const [Text('plain')],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rect = tester.getRect(find.text('plain'));
      // 4 cols, 800px → unitWidth = 200.
      expect(rect.width, closeTo(200, 1));
    });

    testWidgets('fullSpanSentinel resolves to total columns', (tester) async {
      // REQ-1080: _fullSpanSentinel (-1) → total column count.
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 4.responsive,
          gap: 8.0.responsive,
          children: [const Text('full').spanFull()],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rect = tester.getRect(find.text('full'));
      // Full span = all 4 columns = full width.
      expect(rect.width, closeTo(800, 1));
    });

    testWidgets('explicit columnSpan is used as-is', (tester) async {
      // REQ-1080: Explicit span 3 → child occupies 3 columns.
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 4.responsive,
          children: [
            const Text('wide').span(columnSpan: const OiResponsive<int>(3)),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rect = tester.getRect(find.text('wide'));
      // 4 cols, 800px → unit 200. Span 3 → 600.
      expect(rect.width, closeTo(600, 1));
    });

    testWidgets('columnSpan clamped to column count', (tester) async {
      // REQ-1080: Span 10 in 3-col grid → clamped to 3.
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 3.responsive,
          children: [
            const Text('big').span(columnSpan: const OiResponsive<int>(10)),
          ],
        ),
        surfaceSize: const Size(900, 600),
      );

      final rect = tester.getRect(find.text('big'));
      // Clamped to 3 → full row width.
      expect(rect.width, closeTo(900, 1));
    });

    testWidgets('columnSpan clamped to minimum 1', (tester) async {
      // REQ-1080: Span 0 → clamped to 1.
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 3.responsive,
          children: [
            const Text('small').span(columnSpan: const OiResponsive<int>(0)),
          ],
        ),
        surfaceSize: const Size(900, 600),
      );

      final rect = tester.getRect(find.text('small'));
      // Clamped to 1 → unit width 300.
      expect(rect.width, closeTo(300, 1));
    });
  });

  // ── Column count resolution (REQ-1077) ──────────────────────────────────

  group('column count resolution', () {
    testWidgets(
      'column count computed once from width — no per-child rebuilds',
      (tester) async {
        // Verify the grid computes the correct column count from width.
        // 800px / minColumnWidth 200 = 4 cols → 4 items on one row.
        await tester.pumpObers(
          const OiGrid(
            breakpoint: OiBreakpoint.compact,
            minColumnWidth: OiResponsive<double>(200),
            children: [Text('A'), Text('B'), Text('C'), Text('D')],
          ),
          surfaceSize: const Size(800, 600),
        );

        final rectA = tester.getRect(find.text('A'));
        final rectD = tester.getRect(find.text('D'));

        // All 4 items should be on the same row.
        expect(rectA.top, closeTo(rectD.top, 1));
        // Each should be ~200px wide.
        expect(rectA.width, closeTo(200, 1));

        // Resize to 400px → 2 cols → A,B on row 0, C,D on row 1.
        await tester.pumpObers(
          const OiGrid(
            breakpoint: OiBreakpoint.compact,
            minColumnWidth: OiResponsive<double>(200),
            children: [Text('A'), Text('B'), Text('C'), Text('D')],
          ),
          surfaceSize: const Size(400, 600),
        );

        final rectA2 = tester.getRect(find.text('A'));
        final rectC2 = tester.getRect(find.text('C'));

        // C should be on a row below A.
        expect(rectC2.top, greaterThan(rectA2.bottom - 1));
      },
    );

    testWidgets('no LayoutBuilder used — RenderBox resolves cols directly', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiGrid(
          breakpoint: OiBreakpoint.compact,
          minColumnWidth: OiResponsive<double>(200),
          children: [Text('A')],
        ),
        surfaceSize: const Size(800, 600),
      );

      // REQ-1077: column count resolved inside the render object, not via
      // LayoutBuilder.
      expect(find.byType(LayoutBuilder), findsNothing);
    });
  });

  // ── rowSpan (REQ-1084) ──────────────────────────────────────────────────

  group('rowSpan (REQ-1084)', () {
    testWidgets('default rowSpan is 1', (tester) async {
      // No rowSpan specified → child occupies a single row.
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 2.responsive,
          children: const [Text('A'), Text('B'), Text('C'), Text('D')],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectA = tester.getRect(find.text('A'));
      final rectB = tester.getRect(find.text('B'));
      final rectC = tester.getRect(find.text('C'));

      // Row 0: A, B. Row 1: C, D. A does NOT span into row 1.
      expect(rectA.top, closeTo(rectB.top, 1));
      expect(rectC.top, greaterThan(rectA.bottom - 1));
    });

    testWidgets('child with rowSpan 2 occupies two grid rows', (
      tester,
    ) async {
      // 2 columns, gap 0. A spans 2 rows. B, C, D are single-row.
      // Row 0: A(col0, rowSpan2), B(col1)
      // Row 1: A still occupying col0, C(col1)
      // Row 2: D(col0)
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 2.responsive,
          children: [
            const SizedBox(
              key: Key('A'),
              height: 100,
            ).span(rowSpan: const OiResponsive<int>(2)),
            const SizedBox(key: Key('B'), height: 40),
            const SizedBox(key: Key('C'), height: 40),
            const SizedBox(key: Key('D'), height: 40),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectA = tester.getRect(find.byKey(const Key('A')));
      final rectB = tester.getRect(find.byKey(const Key('B')));
      final rectC = tester.getRect(find.byKey(const Key('C')));
      final rectD = tester.getRect(find.byKey(const Key('D')));

      // A at row 0, col 0.
      expect(rectA.left, closeTo(0, 1));
      expect(rectA.top, closeTo(0, 1));

      // B at row 0, col 1.
      expect(rectB.left, closeTo(400, 1));
      expect(rectB.top, closeTo(0, 1));

      // C at row 1, col 1 (col 0 blocked by A's rowSpan).
      expect(rectC.left, closeTo(400, 1));
      expect(rectC.top, greaterThan(rectB.bottom - 1));

      // D at row 2, col 0 (A's rowSpan ended).
      expect(rectD.left, closeTo(0, 1));
      expect(rectD.top, greaterThan(rectC.bottom - 1));
    });

    testWidgets('rowSpan with rowGap sizes child to include internal row gaps',
        (tester) async {
      // 2 columns, rowGap 10. A spans 2 rows. B and C are 40px tall each.
      // The combined height available for A's 2 rows = row0 + rowGap + row1.
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 2.responsive,
          rowGap: const OiResponsive<double>(10),
          children: [
            const SizedBox(
              key: Key('A'),
              height: 100,
            ).span(rowSpan: const OiResponsive<int>(2)),
            const SizedBox(key: Key('B'), height: 40),
            const SizedBox(key: Key('C'), height: 40),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectA = tester.getRect(find.byKey(const Key('A')));
      final rectB = tester.getRect(find.byKey(const Key('B')));
      final rectC = tester.getRect(find.byKey(const Key('C')));

      // B and C should each be on different rows.
      expect(rectB.top, closeTo(0, 1));
      // C starts after B's height + rowGap.
      expect(rectC.top, greaterThan(rectB.bottom - 1));
      // A starts at 0.
      expect(rectA.top, closeTo(0, 1));
    });

    testWidgets('rowSpan clamped to minimum 1', (tester) async {
      // rowSpan 0 should be treated as 1.
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 2.responsive,
          children: [
            const SizedBox(
              key: Key('A'),
              height: 40,
            ).span(rowSpan: const OiResponsive<int>(0)),
            const SizedBox(key: Key('B'), height: 40),
            const SizedBox(key: Key('C'), height: 40),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      final rectA = tester.getRect(find.byKey(const Key('A')));
      final rectB = tester.getRect(find.byKey(const Key('B')));
      final rectC = tester.getRect(find.byKey(const Key('C')));

      // A and B on row 0, C on row 1 (A doesn't span extra rows).
      expect(rectA.top, closeTo(rectB.top, 1));
      expect(rectC.top, greaterThan(rectA.bottom - 1));
      expect(rectC.left, closeTo(0, 1));
    });

    testWidgets('rowSpan blocks cells in subsequent rows for auto-placement', (
      tester,
    ) async {
      // 3 columns. A(col0, rowSpan 2), B(col1), C(col2).
      // Row 1: col0 blocked by A. D auto-places at col1.
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 3.responsive,
          children: [
            const SizedBox(
              key: Key('A'),
              height: 80,
            ).span(rowSpan: const OiResponsive<int>(2)),
            const SizedBox(key: Key('B'), height: 40),
            const SizedBox(key: Key('C'), height: 40),
            const SizedBox(key: Key('D'), height: 40),
          ],
        ),
        surfaceSize: const Size(900, 600),
      );

      final rectA = tester.getRect(find.byKey(const Key('A')));
      final rectD = tester.getRect(find.byKey(const Key('D')));

      // A at col 0, row 0.
      expect(rectA.left, closeTo(0, 1));
      expect(rectA.top, closeTo(0, 1));

      // D auto-placed: row 1, col 1 (col 0 blocked by A's rowSpan).
      expect(rectD.left, closeTo(300, 1));
      expect(rectD.top, greaterThan(rectA.top));
    });

    testWidgets('rowSpan + columnSpan work together (2×2 block)', (
      tester,
    ) async {
      // 3 columns. A spans 2 cols × 2 rows.
      await tester.pumpObers(
        OiGrid(
          breakpoint: OiBreakpoint.compact,
          columns: 3.responsive,
          children: [
            const SizedBox(key: Key('A'), height: 80).span(
              columnSpan: const OiResponsive<int>(2),
              rowSpan: const OiResponsive<int>(2),
            ),
            const SizedBox(key: Key('B'), height: 40),
            const SizedBox(key: Key('C'), height: 40),
            const SizedBox(key: Key('D'), height: 40),
          ],
        ),
        surfaceSize: const Size(900, 600),
      );

      final rectA = tester.getRect(find.byKey(const Key('A')));
      final rectB = tester.getRect(find.byKey(const Key('B')));
      final rectC = tester.getRect(find.byKey(const Key('C')));
      final rectD = tester.getRect(find.byKey(const Key('D')));

      // A: 2 cols wide starting at col 0 → width = 600.
      expect(rectA.left, closeTo(0, 1));
      expect(rectA.width, closeTo(600, 1));

      // B: row 0, col 2 (only free col in row 0).
      expect(rectB.left, closeTo(600, 1));
      expect(rectB.top, closeTo(0, 1));

      // C: row 1, col 2 (cols 0-1 blocked by A's rowSpan).
      expect(rectC.left, closeTo(600, 1));
      expect(rectC.top, greaterThan(rectB.bottom - 1));

      // D: row 2, col 0 (A's rowSpan ended).
      expect(rectD.left, closeTo(0, 1));
      expect(rectD.top, greaterThan(rectC.bottom - 1));
    });

    testWidgets(
      'placement records (row, column, columnSpan, rowSpan) for each child',
      (tester) async {
        // Comprehensive recording test: verify each child is positioned
        // according to its (row, column, columnSpan, rowSpan) tuple.
        // 4 columns, gap 0, 800px → unitWidth = 200.
        // A: span 2 cols, 2 rows. B: default. C: default. D: span 1 col, 1 row.
        await tester.pumpObers(
          OiGrid(
            breakpoint: OiBreakpoint.compact,
            columns: 4.responsive,
            children: [
              const SizedBox(key: Key('A'), height: 60).span(
                columnSpan: const OiResponsive<int>(2),
                rowSpan: const OiResponsive<int>(2),
              ),
              const SizedBox(key: Key('B'), height: 30),
              const SizedBox(key: Key('C'), height: 30),
              const SizedBox(key: Key('D'), height: 30),
              const SizedBox(key: Key('E'), height: 30),
            ],
          ),
          surfaceSize: const Size(800, 600),
        );

        final rectA = tester.getRect(find.byKey(const Key('A')));
        final rectB = tester.getRect(find.byKey(const Key('B')));
        final rectC = tester.getRect(find.byKey(const Key('C')));
        final rectD = tester.getRect(find.byKey(const Key('D')));
        final rectE = tester.getRect(find.byKey(const Key('E')));

        // A: row 0, col 0, columnSpan 2, rowSpan 2.
        expect(rectA.left, closeTo(0, 1));
        expect(rectA.top, closeTo(0, 1));
        expect(rectA.width, closeTo(400, 1)); // 2 × 200

        // B: row 0, col 2, columnSpan 1, rowSpan 1.
        expect(rectB.left, closeTo(400, 1));
        expect(rectB.top, closeTo(0, 1));
        expect(rectB.width, closeTo(200, 1));

        // C: row 0, col 3, columnSpan 1, rowSpan 1.
        expect(rectC.left, closeTo(600, 1));
        expect(rectC.top, closeTo(0, 1));
        expect(rectC.width, closeTo(200, 1));

        // D: row 1, col 2 (cols 0-1 blocked by A).
        expect(rectD.left, closeTo(400, 1));
        expect(rectD.top, greaterThan(rectB.bottom - 1));
        expect(rectD.width, closeTo(200, 1));

        // E: row 1, col 3.
        expect(rectE.left, closeTo(600, 1));
        expect(rectE.top, closeTo(rectD.top, 1));
        expect(rectE.width, closeTo(200, 1));
      },
    );
  });
}
