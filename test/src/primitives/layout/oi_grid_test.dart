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
        columns: OiResponsive<int>(3),
        children: [Text('A'), Text('B'), Text('C'), Text('D')],
      ),
    );
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
  });

  testWidgets('uses LayoutBuilder and Wrap internally', (tester) async {
    await tester.pumpObers(
      const OiGrid(
        columns: OiResponsive<int>(2),
        children: [Text('X'), Text('Y')],
      ),
    );
    expect(find.byType(LayoutBuilder), findsOneWidget);
    expect(find.byType(Wrap), findsOneWidget);
  });

  testWidgets('each child wrapped in SizedBox with computed width', (
    tester,
  ) async {
    // Surface 800px wide, 2 columns, gap 0 → each item = 400px.
    await tester.pumpObers(
      const OiGrid(
        columns: OiResponsive<int>(2),
        children: [Text('A'), Text('B')],
      ),
      surfaceSize: const Size(800, 600),
    );
    final boxes = tester
        .widgetList<SizedBox>(find.byType(SizedBox))
        .where((b) => b.width != null && b.width! > 0)
        .toList();
    expect(boxes, isNotEmpty);
    // Each box should be half the available width.
    for (final box in boxes) {
      expect(box.width, closeTo(400, 1));
    }
  });

  // ── Gap ───────────────────────────────────────────────────────────────────

  testWidgets('gap is applied to Wrap spacing', (tester) async {
    await tester.pumpObers(
      const OiGrid(
        columns: OiResponsive<int>(2),
        gap: OiResponsive<double>(8),
        children: [Text('A'), Text('B')],
      ),
    );
    final wrap = tester.widget<Wrap>(find.byType(Wrap));
    expect(wrap.spacing, 8);
    expect(wrap.runSpacing, 8);
  });

  testWidgets('rowGap overrides run spacing', (tester) async {
    await tester.pumpObers(
      const OiGrid(
        columns: OiResponsive<int>(2),
        gap: OiResponsive<double>(8),
        rowGap: OiResponsive<double>(24),
        children: [Text('A'), Text('B')],
      ),
    );
    final wrap = tester.widget<Wrap>(find.byType(Wrap));
    expect(wrap.spacing, 8);
    expect(wrap.runSpacing, 24);
  });

  // ── minColumnWidth ────────────────────────────────────────────────────────

  testWidgets('minColumnWidth auto-computes column count', (tester) async {
    // Surface 800px, minColumnWidth=200 → 4 columns, each ~200px wide (gap=0).
    await tester.pumpObers(
      const OiGrid(
        minColumnWidth: OiResponsive<double>(200),
        children: [Text('A'), Text('B'), Text('C'), Text('D')],
      ),
      surfaceSize: const Size(800, 600),
    );
    final boxes = tester
        .widgetList<SizedBox>(find.byType(SizedBox))
        .where((b) => b.width != null && b.width! > 0)
        .toList();
    expect(boxes, isNotEmpty);
    for (final box in boxes) {
      expect(box.width, closeTo(200, 1));
    }
  });

  // ── Span: columnSpan ──────────────────────────────────────────────────────

  group('columnSpan', () {
    testWidgets('child with columnSpan 2 gets double-wide SizedBox', (
      tester,
    ) async {
      // 4 columns, gap 0, 800px → unitWidth = 200.
      // Item A spans 2 cols → width = 2 * 200 = 400.
      await tester.pumpObers(
        OiGrid(
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

    testWidgets('columnSpan with gap includes internal gaps', (
      tester,
    ) async {
      // 4 columns, gap 8, 800px → unitWidth = (800 - 3*8) / 4 = 194.
      // Item A spans 2 → width = 2 * 194 + 1 * 8 = 396.
      await tester.pumpObers(
        OiGrid(
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
          columns: 4.responsive,
          gap: 8.0.responsive,
          children: [
            const Text('full').spanFull(),
            const Text('B'),
          ],
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
      // Row 1: A, B → cursor at 2; C needs 2 but only 1 left → new row.
      // Row 2: C (span 2).
      await tester.pumpObers(
        OiGrid(
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

    testWidgets('columnStart with gap accounts for gap pixels', (
      tester,
    ) async {
      // 4 columns, gap 8, 800px → unitWidth = (800 - 24) / 4 = 194.
      // Start col 3 → spacer(2 cols) = 2*194 + 1*8 = 396, then gap = 8.
      // Item A.left = 396 + 8 = 404.
      await tester.pumpObers(
        OiGrid(
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
      // B should be on a different row since col 0 is behind cursor 2.
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
  });

  // ── Span: combined properties ─────────────────────────────────────────────

  group('combined span properties', () {
    testWidgets('columnStart + columnSpan positions and sizes correctly', (
      tester,
    ) async {
      await tester.pumpObers(
        OiGrid(
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

  // ── Backward compatibility ────────────────────────────────────────────────

  group('backward compatibility', () {
    testWidgets('grid without span children uses Wrap', (tester) async {
      await tester.pumpObers(
        const OiGrid(
          columns: OiResponsive<int>(2),
          children: [Text('X'), Text('Y')],
        ),
      );
      // Fast path: should still use Wrap.
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('grid with span children uses Row-based layout', (
      tester,
    ) async {
      await tester.pumpObers(
        OiGrid(
          columns: 2.responsive,
          children: [
            const Text('X').span(columnSpan: const OiResponsive<int>(1)),
            const Text('Y'),
          ],
        ),
      );
      // Span path: should use Row, not Wrap.
      expect(find.byType(Wrap), findsNothing);
      expect(find.byType(Row), findsOneWidget);
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
      );

      var wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, 4);

      // Expanded → gap 16.
      await tester.pumpObers(
        OiGrid(
          columns: const OiResponsive<int>(2),
          gap: responsiveGap,
          breakpoint: OiBreakpoint.expanded,
          children: const [Text('A'), Text('B')],
        ),
      );

      wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, 16);
    });
  });
}
