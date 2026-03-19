// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/oi_span.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';
import 'package:obers_ui/src/primitives/layout/oi_container.dart';
import 'package:obers_ui/src/primitives/layout/oi_grid.dart';
import 'package:obers_ui/src/primitives/layout/oi_masonry.dart';
import 'package:obers_ui/src/primitives/layout/oi_page.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';
import 'package:obers_ui/src/primitives/layout/oi_section.dart';
import 'package:obers_ui/src/primitives/layout/oi_wrap_layout.dart';

import '../../../helpers/pump_app.dart';

const _bp = OiBreakpoint.compact;

void main() {
  // ── Column ↔ Column ──────────────────────────────────────────────────────

  testWidgets('OiColumn inside OiColumn renders without error', (tester) async {
    await tester.pumpObers(
      const OiColumn(
        breakpoint: _bp,
        gap: OiResponsive<double>(8),
        children: [
          Text('outer-A'),
          OiColumn(
            breakpoint: _bp,
            gap: OiResponsive<double>(4),
            children: [Text('inner-A'), Text('inner-B')],
          ),
          Text('outer-B'),
        ],
      ),
    );
    expect(find.text('outer-A'), findsOneWidget);
    expect(find.text('inner-A'), findsOneWidget);
    expect(find.text('inner-B'), findsOneWidget);
    expect(find.text('outer-B'), findsOneWidget);
  });

  // ── Row ↔ Row ────────────────────────────────────────────────────────────

  testWidgets('OiRow inside OiRow renders without error', (tester) async {
    await tester.pumpObers(
      const OiRow(
        breakpoint: _bp,
        gap: OiResponsive<double>(8),
        children: [
          Text('outer-A'),
          OiRow(
            breakpoint: _bp,
            gap: OiResponsive<double>(4),
            children: [Text('inner-A'), Text('inner-B')],
          ),
          Text('outer-B'),
        ],
      ),
    );
    expect(find.text('outer-A'), findsOneWidget);
    expect(find.text('inner-A'), findsOneWidget);
    expect(find.text('inner-B'), findsOneWidget);
    expect(find.text('outer-B'), findsOneWidget);
  });

  // ── Column ↔ Row ─────────────────────────────────────────────────────────

  testWidgets('OiRow inside OiColumn renders without error', (tester) async {
    await tester.pumpObers(
      const OiColumn(
        breakpoint: _bp,
        gap: OiResponsive<double>(8),
        children: [
          Text('col-A'),
          OiRow(
            breakpoint: _bp,
            gap: OiResponsive<double>(4),
            children: [Text('row-A'), Text('row-B')],
          ),
          Text('col-B'),
        ],
      ),
    );
    expect(find.text('col-A'), findsOneWidget);
    expect(find.text('row-A'), findsOneWidget);
    expect(find.text('row-B'), findsOneWidget);
    expect(find.text('col-B'), findsOneWidget);
  });

  testWidgets('OiColumn inside OiRow renders without error', (tester) async {
    await tester.pumpObers(
      const OiRow(
        breakpoint: _bp,
        gap: OiResponsive<double>(8),
        children: [
          Text('row-A'),
          OiColumn(
            breakpoint: _bp,
            gap: OiResponsive<double>(4),
            children: [Text('col-A'), Text('col-B')],
          ),
          Text('row-B'),
        ],
      ),
    );
    expect(find.text('row-A'), findsOneWidget);
    expect(find.text('col-A'), findsOneWidget);
    expect(find.text('col-B'), findsOneWidget);
    expect(find.text('row-B'), findsOneWidget);
  });

  // ── Grid inside flex layouts ─────────────────────────────────────────────

  testWidgets('OiGrid inside OiColumn renders without error', (tester) async {
    await tester.pumpObers(
      const OiColumn(
        breakpoint: _bp,
        children: [
          Text('header'),
          OiGrid(
            breakpoint: _bp,
            columns: OiResponsive<int>(2),
            gap: OiResponsive<double>(4),
            children: [Text('g1'), Text('g2'), Text('g3'), Text('g4')],
          ),
          Text('footer'),
        ],
      ),
    );
    expect(find.text('header'), findsOneWidget);
    expect(find.text('g1'), findsOneWidget);
    expect(find.text('g4'), findsOneWidget);
    expect(find.text('footer'), findsOneWidget);
  });

  testWidgets('OiGrid inside OiRow renders multi-column', (tester) async {
    // Row gives unbounded width → Grid with explicit columns renders
    // multi-column using intrinsic sizing.
    await tester.pumpObers(
      const OiRow(
        breakpoint: _bp,
        children: [
          Text('left'),
          OiGrid(
            breakpoint: _bp,
            columns: OiResponsive<int>(2),
            children: [Text('g1'), Text('g2')],
          ),
          Text('right'),
        ],
      ),
    );
    expect(find.text('left'), findsOneWidget);
    expect(find.text('g1'), findsOneWidget);
    expect(find.text('g2'), findsOneWidget);
    expect(find.text('right'), findsOneWidget);

    // Verify g1 and g2 are on the same row (same top coordinate).
    final g1Top = tester.getTopLeft(find.text('g1')).dy;
    final g2Top = tester.getTopLeft(find.text('g2')).dy;
    expect(g1Top, equals(g2Top));
  });

  testWidgets(
    'OiGrid with minColumnWidth inside OiRow falls back to single column',
    (tester) async {
      // minColumnWidth can't compute column count without available width,
      // so single-column fallback is expected.
      await tester.pumpObers(
        const OiRow(
          breakpoint: _bp,
          children: [
            Text('left'),
            OiGrid(
              breakpoint: _bp,
              minColumnWidth: OiResponsive<double>(100),
              children: [Text('g1'), Text('g2')],
            ),
            Text('right'),
          ],
        ),
      );
      expect(find.text('left'), findsOneWidget);
      expect(find.text('g1'), findsOneWidget);
      expect(find.text('g2'), findsOneWidget);
      expect(find.text('right'), findsOneWidget);

      // Verify g1 and g2 are stacked vertically (different top coordinates).
      final g1Top = tester.getTopLeft(find.text('g1')).dy;
      final g2Top = tester.getTopLeft(find.text('g2')).dy;
      expect(g1Top, lessThan(g2Top));
    },
  );

  testWidgets('OiGrid in unbounded width respects columnOrder', (tester) async {
    await tester.pumpObers(
      OiRow(
        breakpoint: _bp,
        children: [
          OiGrid(
            breakpoint: _bp,
            columns: const OiResponsive<int>(2),
            children: [
              const Text(
                'second',
              ).span(columnOrder: const OiResponsive<int>(2)),
              const Text('first').span(columnOrder: const OiResponsive<int>(1)),
            ],
          ),
        ],
      ),
    );
    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsOneWidget);

    // 'first' (order=1) should appear to the left of 'second' (order=2).
    final firstLeft = tester.getTopLeft(find.text('first')).dx;
    final secondLeft = tester.getTopLeft(find.text('second')).dx;
    expect(firstLeft, lessThan(secondLeft));
  });

  // ── Masonry inside flex layouts ──────────────────────────────────────────

  testWidgets('OiMasonry inside OiColumn renders without error', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiColumn(
        breakpoint: _bp,
        children: [
          Text('above'),
          OiMasonry(
            breakpoint: _bp,
            gap: OiResponsive<double>(4),
            children: [Text('m1'), Text('m2'), Text('m3')],
          ),
          Text('below'),
        ],
      ),
    );
    expect(find.text('above'), findsOneWidget);
    expect(find.text('m1'), findsOneWidget);
    expect(find.text('m3'), findsOneWidget);
    expect(find.text('below'), findsOneWidget);
  });

  testWidgets('OiMasonry inside OiRow renders without error', (tester) async {
    // Row gives unbounded width → Masonry columns size to content.
    await tester.pumpObers(
      const OiRow(
        breakpoint: _bp,
        children: [
          Text('left'),
          OiMasonry(
            breakpoint: _bp,
            children: [Text('m1'), Text('m2')],
          ),
          Text('right'),
        ],
      ),
    );
    expect(find.text('left'), findsOneWidget);
    expect(find.text('m1'), findsOneWidget);
    expect(find.text('m2'), findsOneWidget);
    expect(find.text('right'), findsOneWidget);
  });

  // ── Container inside flex layouts ────────────────────────────────────────

  testWidgets('OiContainer inside OiColumn renders without error', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiColumn(
        breakpoint: _bp,
        children: [
          OiContainer(
            breakpoint: _bp,
            maxWidth: OiResponsive<double>(200),
            child: Text('contained'),
          ),
          Text('after'),
        ],
      ),
    );
    expect(find.text('contained'), findsOneWidget);
    expect(find.text('after'), findsOneWidget);
  });

  testWidgets('OiContainer inside OiRow renders without error', (tester) async {
    await tester.pumpObers(
      const OiRow(
        breakpoint: _bp,
        children: [
          OiContainer(
            breakpoint: _bp,
            maxWidth: OiResponsive<double>(200),
            child: Text('contained'),
          ),
          Text('after'),
        ],
      ),
    );
    expect(find.text('contained'), findsOneWidget);
    expect(find.text('after'), findsOneWidget);
  });

  // ── WrapLayout inside flex layouts ───────────────────────────────────────

  testWidgets('OiWrapLayout inside OiColumn renders without error', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiColumn(
        breakpoint: _bp,
        children: [
          OiWrapLayout(
            breakpoint: _bp,
            children: [Text('w1'), Text('w2'), Text('w3')],
          ),
          Text('after'),
        ],
      ),
    );
    expect(find.text('w1'), findsOneWidget);
    expect(find.text('w3'), findsOneWidget);
    expect(find.text('after'), findsOneWidget);
  });

  testWidgets('OiWrapLayout inside OiRow renders without error', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiRow(
        breakpoint: _bp,
        children: [
          OiWrapLayout(breakpoint: _bp, children: [Text('w1'), Text('w2')]),
          Text('after'),
        ],
      ),
    );
    expect(find.text('w1'), findsOneWidget);
    expect(find.text('w2'), findsOneWidget);
    expect(find.text('after'), findsOneWidget);
  });

  // ── Grid inside Container ────────────────────────────────────────────────

  testWidgets('OiGrid inside OiContainer renders with bounded width', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiContainer(
        breakpoint: _bp,
        maxWidth: OiResponsive<double>(400),
        child: OiGrid(
          breakpoint: _bp,
          columns: OiResponsive<int>(2),
          children: [Text('a'), Text('b'), Text('c'), Text('d')],
        ),
      ),
    );
    expect(find.text('a'), findsOneWidget);
    expect(find.text('d'), findsOneWidget);
  });

  // ── Row inside Grid ──────────────────────────────────────────────────────

  testWidgets('OiRow inside OiGrid cell renders without error', (tester) async {
    await tester.pumpObers(
      const OiGrid(
        breakpoint: _bp,
        columns: OiResponsive<int>(2),
        children: [
          OiRow(breakpoint: _bp, children: [Text('r1'), Text('r2')]),
          Text('plain'),
        ],
      ),
    );
    expect(find.text('r1'), findsOneWidget);
    expect(find.text('r2'), findsOneWidget);
    expect(find.text('plain'), findsOneWidget);
  });

  // ── Column inside Grid ─────────────────────────────────────────────────

  testWidgets('OiColumn inside OiGrid cell renders without error', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiGrid(
        breakpoint: _bp,
        columns: OiResponsive<int>(2),
        children: [
          OiColumn(breakpoint: _bp, children: [Text('c1'), Text('c2')]),
          Text('plain'),
        ],
      ),
    );
    expect(find.text('c1'), findsOneWidget);
    expect(find.text('c2'), findsOneWidget);
    expect(find.text('plain'), findsOneWidget);
  });

  // ── Deep nesting (3+ levels) ─────────────────────────────────────────────

  testWidgets('three-level nesting: Row > Column > Grid', (tester) async {
    await tester.pumpObers(
      const OiRow(
        breakpoint: _bp,
        gap: OiResponsive<double>(8),
        children: [
          Text('sidebar'),
          OiColumn(
            breakpoint: _bp,
            gap: OiResponsive<double>(4),
            children: [
              Text('section-title'),
              OiGrid(
                breakpoint: _bp,
                columns: OiResponsive<int>(2),
                children: [Text('g1'), Text('g2'), Text('g3'), Text('g4')],
              ),
            ],
          ),
        ],
      ),
    );
    expect(find.text('sidebar'), findsOneWidget);
    expect(find.text('section-title'), findsOneWidget);
    expect(find.text('g1'), findsOneWidget);
    expect(find.text('g4'), findsOneWidget);
  });

  testWidgets('three-level nesting: Column > Container > Masonry', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiColumn(
        breakpoint: _bp,
        children: [
          Text('page-header'),
          OiContainer(
            breakpoint: _bp,
            maxWidth: OiResponsive<double>(600),
            child: OiMasonry(
              breakpoint: _bp,
              gap: OiResponsive<double>(8),
              children: [Text('m1'), Text('m2'), Text('m3'), Text('m4')],
            ),
          ),
          Text('page-footer'),
        ],
      ),
    );
    expect(find.text('page-header'), findsOneWidget);
    expect(find.text('m1'), findsOneWidget);
    expect(find.text('m4'), findsOneWidget);
    expect(find.text('page-footer'), findsOneWidget);
  });

  testWidgets('four-level nesting: Column > Row > Container > Grid', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiColumn(
        breakpoint: _bp,
        gap: OiResponsive<double>(8),
        children: [
          Text('page-top'),
          OiRow(
            breakpoint: _bp,
            gap: OiResponsive<double>(4),
            children: [
              Text('left-nav'),
              OiContainer(
                breakpoint: _bp,
                maxWidth: OiResponsive<double>(400),
                child: OiGrid(
                  breakpoint: _bp,
                  columns: OiResponsive<int>(2),
                  children: [Text('g1'), Text('g2')],
                ),
              ),
            ],
          ),
          Text('page-bottom'),
        ],
      ),
    );
    expect(find.text('page-top'), findsOneWidget);
    expect(find.text('left-nav'), findsOneWidget);
    expect(find.text('g1'), findsOneWidget);
    expect(find.text('g2'), findsOneWidget);
    expect(find.text('page-bottom'), findsOneWidget);
  });

  // ── Masonry inside Grid ──────────────────────────────────────────────────

  testWidgets('OiMasonry inside OiGrid cell renders without error', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiGrid(
        breakpoint: _bp,
        columns: OiResponsive<int>(2),
        children: [
          OiMasonry(
            breakpoint: _bp,
            children: [Text('m1'), Text('m2')],
          ),
          Text('plain'),
        ],
      ),
    );
    expect(find.text('m1'), findsOneWidget);
    expect(find.text('m2'), findsOneWidget);
    expect(find.text('plain'), findsOneWidget);
  });

  // ── Grid inside Grid ─────────────────────────────────────────────────────

  testWidgets('OiGrid inside OiGrid renders without error', (tester) async {
    await tester.pumpObers(
      const OiGrid(
        breakpoint: _bp,
        columns: OiResponsive<int>(2),
        children: [
          OiGrid(
            breakpoint: _bp,
            columns: OiResponsive<int>(2),
            children: [Text('inner1'), Text('inner2')],
          ),
          Text('outer-cell'),
        ],
      ),
    );
    expect(find.text('inner1'), findsOneWidget);
    expect(find.text('inner2'), findsOneWidget);
    expect(find.text('outer-cell'), findsOneWidget);
  });

  // ── WrapLayout inside Grid ──────────────────────────────────────────────

  testWidgets('OiWrapLayout inside OiGrid renders without error', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiGrid(
        breakpoint: _bp,
        columns: OiResponsive<int>(2),
        children: [
          OiWrapLayout(breakpoint: _bp, children: [Text('w1'), Text('w2')]),
          Text('plain'),
        ],
      ),
    );
    expect(find.text('w1'), findsOneWidget);
    expect(find.text('w2'), findsOneWidget);
    expect(find.text('plain'), findsOneWidget);
  });

  // ── mainAxisSize parameter ───────────────────────────────────────────────

  testWidgets('OiColumn defaults to MainAxisSize.min', (tester) async {
    await tester.pumpObers(
      const OiColumn(breakpoint: _bp, children: [Text('A')]),
    );
    final col = tester.widget<Column>(find.byType(Column));
    expect(col.mainAxisSize, MainAxisSize.min);
  });

  testWidgets('OiRow defaults to MainAxisSize.min', (tester) async {
    await tester.pumpObers(const OiRow(breakpoint: _bp, children: [Text('A')]));
    final row = tester.widget<Row>(find.byType(Row));
    expect(row.mainAxisSize, MainAxisSize.min);
  });

  testWidgets('OiColumn accepts MainAxisSize.max override', (tester) async {
    await tester.pumpObers(
      const OiColumn(
        breakpoint: _bp,
        mainAxisSize: MainAxisSize.max,
        children: [Text('A')],
      ),
    );
    final col = tester.widget<Column>(find.byType(Column));
    expect(col.mainAxisSize, MainAxisSize.max);
  });

  testWidgets('OiRow accepts MainAxisSize.max override', (tester) async {
    await tester.pumpObers(
      const OiRow(
        breakpoint: _bp,
        mainAxisSize: MainAxisSize.max,
        children: [Text('A')],
      ),
    );
    final row = tester.widget<Row>(find.byType(Row));
    expect(row.mainAxisSize, MainAxisSize.max);
  });

  // ── OiSection nesting ───────────────────────────────────────────────────

  testWidgets('OiSection inside OiColumn renders without error', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiColumn(
        breakpoint: _bp,
        children: [
          Text('before'),
          OiSection(
            breakpoint: _bp,
            gap: OiResponsive<double>(4),
            children: [Text('sec-A'), Text('sec-B')],
          ),
          Text('after'),
        ],
      ),
    );
    expect(find.text('before'), findsOneWidget);
    expect(find.text('sec-A'), findsOneWidget);
    expect(find.text('sec-B'), findsOneWidget);
    expect(find.text('after'), findsOneWidget);
  });

  testWidgets('OiSection inside OiRow renders without error', (tester) async {
    await tester.pumpObers(
      const OiRow(
        breakpoint: _bp,
        children: [
          Text('left'),
          OiSection(breakpoint: _bp, children: [Text('sec-A'), Text('sec-B')]),
          Text('right'),
        ],
      ),
    );
    expect(find.text('left'), findsOneWidget);
    expect(find.text('sec-A'), findsOneWidget);
    expect(find.text('sec-B'), findsOneWidget);
    expect(find.text('right'), findsOneWidget);
  });

  testWidgets('OiGrid inside OiSection renders without error', (tester) async {
    await tester.pumpObers(
      const OiSection(
        breakpoint: _bp,
        gap: OiResponsive<double>(8),
        children: [
          Text('section-title'),
          OiGrid(
            breakpoint: _bp,
            columns: OiResponsive<int>(2),
            children: [Text('g1'), Text('g2'), Text('g3'), Text('g4')],
          ),
        ],
      ),
    );
    expect(find.text('section-title'), findsOneWidget);
    expect(find.text('g1'), findsOneWidget);
    expect(find.text('g4'), findsOneWidget);
  });

  testWidgets('OiSection inside OiSection (nested sections)', (tester) async {
    await tester.pumpObers(
      const OiSection(
        breakpoint: _bp,
        children: [
          Text('outer-section'),
          OiSection(
            breakpoint: _bp,
            children: [Text('inner-A'), Text('inner-B')],
          ),
        ],
      ),
    );
    expect(find.text('outer-section'), findsOneWidget);
    expect(find.text('inner-A'), findsOneWidget);
    expect(find.text('inner-B'), findsOneWidget);
  });

  testWidgets('OiSection inside OiGrid cell renders without error', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiGrid(
        breakpoint: _bp,
        columns: OiResponsive<int>(2),
        children: [
          OiSection(breakpoint: _bp, children: [Text('sec-A'), Text('sec-B')]),
          Text('plain'),
        ],
      ),
    );
    expect(find.text('sec-A'), findsOneWidget);
    expect(find.text('sec-B'), findsOneWidget);
    expect(find.text('plain'), findsOneWidget);
  });

  testWidgets('OiSection defaults to MainAxisSize.min', (tester) async {
    await tester.pumpObers(
      const OiSection(breakpoint: _bp, children: [Text('A')]),
    );
    final col = tester.widget<Column>(find.byType(Column));
    expect(col.mainAxisSize, MainAxisSize.min);
  });

  // ── OiPage nesting ──────────────────────────────────────────────────────

  testWidgets('OiPage renders children vertically', (tester) async {
    await tester.pumpObers(
      const OiPage(
        breakpoint: _bp,
        mainAxisSize: MainAxisSize.min,
        children: [Text('page-A'), Text('page-B')],
      ),
    );
    expect(find.text('page-A'), findsOneWidget);
    expect(find.text('page-B'), findsOneWidget);
  });

  testWidgets('OiSection inside OiPage renders without error', (tester) async {
    await tester.pumpObers(
      const OiPage(
        breakpoint: _bp,
        mainAxisSize: MainAxisSize.min,
        gap: OiResponsive<double>(8),
        children: [
          OiSection(
            breakpoint: _bp,
            children: [Text('hero'), Text('subtitle')],
          ),
          OiSection(
            breakpoint: _bp,
            children: [Text('content-A'), Text('content-B')],
          ),
        ],
      ),
    );
    expect(find.text('hero'), findsOneWidget);
    expect(find.text('subtitle'), findsOneWidget);
    expect(find.text('content-A'), findsOneWidget);
    expect(find.text('content-B'), findsOneWidget);
  });

  testWidgets('OiGrid inside OiSection inside OiPage (3-level)', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiPage(
        breakpoint: _bp,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('page-header'),
          OiSection(
            breakpoint: _bp,
            gap: OiResponsive<double>(4),
            children: [
              Text('section-title'),
              OiGrid(
                breakpoint: _bp,
                columns: OiResponsive<int>(2),
                children: [Text('g1'), Text('g2'), Text('g3'), Text('g4')],
              ),
            ],
          ),
          Text('page-footer'),
        ],
      ),
    );
    expect(find.text('page-header'), findsOneWidget);
    expect(find.text('section-title'), findsOneWidget);
    expect(find.text('g1'), findsOneWidget);
    expect(find.text('g4'), findsOneWidget);
    expect(find.text('page-footer'), findsOneWidget);
  });

  testWidgets(
    'OiRow inside OiSection inside OiPage (flex in section in page)',
    (tester) async {
      await tester.pumpObers(
        const OiPage(
          breakpoint: _bp,
          mainAxisSize: MainAxisSize.min,
          children: [
            OiSection(
              breakpoint: _bp,
              children: [
                Text('section-header'),
                OiRow(
                  breakpoint: _bp,
                  gap: OiResponsive<double>(4),
                  children: [Text('left'), Text('right')],
                ),
              ],
            ),
          ],
        ),
      );
      expect(find.text('section-header'), findsOneWidget);
      expect(find.text('left'), findsOneWidget);
      expect(find.text('right'), findsOneWidget);
    },
  );

  testWidgets('OiPage inside OiColumn (page nested in flex)', (tester) async {
    await tester.pumpObers(
      const OiColumn(
        breakpoint: _bp,
        children: [
          Text('nav'),
          OiPage(
            breakpoint: _bp,
            mainAxisSize: MainAxisSize.min,
            children: [Text('page-content')],
          ),
        ],
      ),
    );
    expect(find.text('nav'), findsOneWidget);
    expect(find.text('page-content'), findsOneWidget);
  });

  testWidgets('OiPage defaults to MainAxisSize.max', (tester) async {
    await tester.pumpObers(
      const OiPage(breakpoint: _bp, children: [Text('A')]),
    );
    final col = tester.widget<Column>(find.byType(Column));
    expect(col.mainAxisSize, MainAxisSize.max);
  });

  testWidgets('OiPage accepts MainAxisSize.min override', (tester) async {
    await tester.pumpObers(
      const OiPage(
        breakpoint: _bp,
        mainAxisSize: MainAxisSize.min,
        children: [Text('A')],
      ),
    );
    final col = tester.widget<Column>(find.byType(Column));
    expect(col.mainAxisSize, MainAxisSize.min);
  });

  // ── Full hierarchy: Page > Section > Flex > Grid ────────────────────────

  testWidgets('full hierarchy: Page > Section > Row > Container > Grid', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiPage(
        breakpoint: _bp,
        mainAxisSize: MainAxisSize.min,
        gap: OiResponsive<double>(16),
        children: [
          Text('page-title'),
          OiSection(
            breakpoint: _bp,
            gap: OiResponsive<double>(8),
            children: [
              Text('section-heading'),
              OiRow(
                breakpoint: _bp,
                gap: OiResponsive<double>(4),
                children: [
                  Text('sidebar'),
                  OiContainer(
                    breakpoint: _bp,
                    maxWidth: OiResponsive<double>(400),
                    child: OiGrid(
                      breakpoint: _bp,
                      columns: OiResponsive<int>(2),
                      children: [Text('g1'), Text('g2')],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text('page-footer'),
        ],
      ),
    );
    expect(find.text('page-title'), findsOneWidget);
    expect(find.text('section-heading'), findsOneWidget);
    expect(find.text('sidebar'), findsOneWidget);
    expect(find.text('g1'), findsOneWidget);
    expect(find.text('g2'), findsOneWidget);
    expect(find.text('page-footer'), findsOneWidget);
  });

  testWidgets('full hierarchy: Page > Section > Column > Masonry (5 levels)', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiPage(
        breakpoint: _bp,
        mainAxisSize: MainAxisSize.min,
        children: [
          OiSection(
            breakpoint: _bp,
            children: [
              OiColumn(
                breakpoint: _bp,
                children: [
                  OiContainer(
                    breakpoint: _bp,
                    maxWidth: OiResponsive<double>(500),
                    child: OiMasonry(
                      breakpoint: _bp,
                      children: [Text('m1'), Text('m2'), Text('m3')],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
    expect(find.text('m1'), findsOneWidget);
    expect(find.text('m2'), findsOneWidget);
    expect(find.text('m3'), findsOneWidget);
  });

  // ── Missing 2-level nesting combinations ────────────────────────────────

  testWidgets('OiContainer inside OiGrid cell renders without error', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiGrid(
        breakpoint: _bp,
        columns: OiResponsive<int>(2),
        children: [
          OiContainer(
            breakpoint: _bp,
            maxWidth: OiResponsive<double>(200),
            child: Text('contained'),
          ),
          Text('plain'),
        ],
      ),
    );
    expect(find.text('contained'), findsOneWidget);
    expect(find.text('plain'), findsOneWidget);
  });

  testWidgets('OiWrapLayout inside OiContainer renders without error', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiContainer(
        breakpoint: _bp,
        maxWidth: OiResponsive<double>(400),
        child: OiWrapLayout(
          breakpoint: _bp,
          children: [Text('w1'), Text('w2'), Text('w3')],
        ),
      ),
    );
    expect(find.text('w1'), findsOneWidget);
    expect(find.text('w2'), findsOneWidget);
    expect(find.text('w3'), findsOneWidget);
  });

  testWidgets('OiMasonry inside OiSection renders without error', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiSection(
        breakpoint: _bp,
        children: [
          Text('section-title'),
          OiMasonry(
            breakpoint: _bp,
            children: [Text('m1'), Text('m2'), Text('m3')],
          ),
        ],
      ),
    );
    expect(find.text('section-title'), findsOneWidget);
    expect(find.text('m1'), findsOneWidget);
    expect(find.text('m3'), findsOneWidget);
  });

  testWidgets('OiContainer inside OiSection renders without error', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiSection(
        breakpoint: _bp,
        children: [
          Text('section-header'),
          OiContainer(
            breakpoint: _bp,
            maxWidth: OiResponsive<double>(300),
            child: Text('contained'),
          ),
        ],
      ),
    );
    expect(find.text('section-header'), findsOneWidget);
    expect(find.text('contained'), findsOneWidget);
  });

  testWidgets('OiWrapLayout inside OiSection renders without error', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiSection(
        breakpoint: _bp,
        children: [
          Text('section-header'),
          OiWrapLayout(
            breakpoint: _bp,
            children: [Text('w1'), Text('w2'), Text('w3')],
          ),
        ],
      ),
    );
    expect(find.text('section-header'), findsOneWidget);
    expect(find.text('w1'), findsOneWidget);
    expect(find.text('w3'), findsOneWidget);
  });

  // ── Deep nesting (10+ levels) ──────────────────────────────────────────

  testWidgets('10-level same-type nesting: Column × 10', (tester) async {
    await tester.pumpObers(_buildDeepSameType(10, isColumn: true));
    expect(find.text('leaf'), findsOneWidget);
  });

  testWidgets('10-level same-type nesting: Row × 10', (tester) async {
    await tester.pumpObers(_buildDeepSameType(10, isColumn: false));
    expect(find.text('leaf'), findsOneWidget);
  });

  testWidgets('10-level alternating Row/Column nesting', (tester) async {
    await tester.pumpObers(
      _buildDeepNesting(10, const Text('leaf')),
    );
    expect(find.text('leaf'), findsOneWidget);
  });

  testWidgets(
    '10-level mixed-widget nesting: '
    'Page > Section > Row > Column > Container > '
    'Grid > Column > Row > Section > Column',
    (tester) async {
      await tester.pumpObers(
        const OiPage(
          breakpoint: _bp,
          mainAxisSize: MainAxisSize.min,
          children: [
            OiSection(
              breakpoint: _bp,
              children: [
                OiRow(
                  breakpoint: _bp,
                  children: [
                    OiColumn(
                      breakpoint: _bp,
                      children: [
                        OiContainer(
                          breakpoint: _bp,
                          maxWidth: OiResponsive<double>(400),
                          child: OiGrid(
                            breakpoint: _bp,
                            columns: OiResponsive<int>(1),
                            children: [
                              OiColumn(
                                breakpoint: _bp,
                                children: [
                                  OiRow(
                                    breakpoint: _bp,
                                    children: [
                                      OiSection(
                                        breakpoint: _bp,
                                        children: [
                                          OiColumn(
                                            breakpoint: _bp,
                                            children: [Text('deep-leaf')],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
      expect(find.text('deep-leaf'), findsOneWidget);
    },
  );

  testWidgets('12-level nesting with Grid at deepest level', (tester) async {
    await tester.pumpObers(
      _buildDeepNesting(
        11,
        const OiGrid(
          breakpoint: _bp,
          columns: OiResponsive<int>(2),
          children: [Text('grid-A'), Text('grid-B')],
        ),
      ),
    );
    expect(find.text('grid-A'), findsOneWidget);
    expect(find.text('grid-B'), findsOneWidget);
  });

  testWidgets('12-level nesting with Masonry at deepest level', (
    tester,
  ) async {
    await tester.pumpObers(
      _buildDeepNesting(
        11,
        const OiMasonry(
          breakpoint: _bp,
          children: [Text('mas-A'), Text('mas-B')],
        ),
      ),
    );
    expect(find.text('mas-A'), findsOneWidget);
    expect(find.text('mas-B'), findsOneWidget);
  });

  testWidgets('15-level programmatic nesting renders without error', (
    tester,
  ) async {
    await tester.pumpObers(
      _buildDeepMixedNesting(15, const Text('stress-leaf')),
    );
    expect(find.text('stress-leaf'), findsOneWidget);
  });
}

// ── Helper functions for deep nesting tests ───────────────────────────────

/// Builds [depth] levels of alternating Row/Column wrappers around [leaf].
///
/// Level 0 (even) → OiColumn, Level 1 (odd) → OiRow, etc.
Widget _buildDeepNesting(int depth, Widget leaf) {
  var current = leaf;
  for (var i = depth - 1; i >= 0; i--) {
    current =
        i.isEven
            ? OiColumn(breakpoint: _bp, children: [current])
            : OiRow(breakpoint: _bp, children: [current]);
  }
  return current;
}

/// Builds [depth] levels of the same flex type around a Text('leaf') widget.
Widget _buildDeepSameType(int depth, {required bool isColumn}) {
  Widget current = const Text('leaf');
  for (var i = 0; i < depth; i++) {
    current =
        isColumn
            ? OiColumn(breakpoint: _bp, children: [current])
            : OiRow(breakpoint: _bp, children: [current]);
  }
  return current;
}

/// Builds [depth] levels cycling through Page, Section, Row, Column,
/// Container around [leaf].
///
/// Cycle: 0→Page, 1→Section, 2→Row, 3→Column, 4→Container, 5→Page, …
Widget _buildDeepMixedNesting(int depth, Widget leaf) {
  var current = leaf;
  for (var i = depth - 1; i >= 0; i--) {
    switch (i % 5) {
      case 0:
        current = OiPage(
          breakpoint: _bp,
          mainAxisSize: MainAxisSize.min,
          children: [current],
        );
      case 1:
        current = OiSection(breakpoint: _bp, children: [current]);
      case 2:
        current = OiRow(breakpoint: _bp, children: [current]);
      case 3:
        current = OiColumn(breakpoint: _bp, children: [current]);
      case 4:
        current = OiContainer(
          breakpoint: _bp,
          maxWidth: const OiResponsive<double>(400),
          child: current,
        );
    }
  }
  return current;
}
