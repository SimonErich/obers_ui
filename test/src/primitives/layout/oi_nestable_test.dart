// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';
import 'package:obers_ui/src/primitives/layout/oi_container.dart';
import 'package:obers_ui/src/primitives/layout/oi_grid.dart';
import 'package:obers_ui/src/primitives/layout/oi_masonry.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';
import 'package:obers_ui/src/primitives/layout/oi_wrap_layout.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Column ↔ Column ──────────────────────────────────────────────────────

  testWidgets('OiColumn inside OiColumn renders without error', (tester) async {
    await tester.pumpObers(
      const OiColumn(
        gap: OiResponsive<double>(8),
        children: [
          Text('outer-A'),
          OiColumn(
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
        gap: OiResponsive<double>(8),
        children: [
          Text('outer-A'),
          OiRow(
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
        gap: OiResponsive<double>(8),
        children: [
          Text('col-A'),
          OiRow(
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
        gap: OiResponsive<double>(8),
        children: [
          Text('row-A'),
          OiColumn(
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
        children: [
          Text('header'),
          OiGrid(
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

  testWidgets('OiGrid inside OiRow degrades to single column', (
    tester,
  ) async {
    // Row gives unbounded width → Grid falls back to single-column layout.
    await tester.pumpObers(
      const OiRow(
        children: [
          Text('left'),
          OiGrid(
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
  });

  // ── Masonry inside flex layouts ──────────────────────────────────────────

  testWidgets('OiMasonry inside OiColumn renders without error', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiColumn(
        children: [
          Text('above'),
          OiMasonry(
            columns: OiResponsive<int>(2),
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
        children: [
          Text('left'),
          OiMasonry(
            columns: OiResponsive<int>(2),
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
        children: [
          OiContainer(
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

  testWidgets('OiContainer inside OiRow renders without error', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiRow(
        children: [
          OiContainer(
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
        children: [
          OiWrapLayout(children: [Text('w1'), Text('w2'), Text('w3')]),
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
        children: [
          OiWrapLayout(children: [Text('w1'), Text('w2')]),
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
        maxWidth: OiResponsive<double>(400),
        child: OiGrid(
          columns: OiResponsive<int>(2),
          children: [Text('a'), Text('b'), Text('c'), Text('d')],
        ),
      ),
    );
    expect(find.text('a'), findsOneWidget);
    expect(find.text('d'), findsOneWidget);
  });

  // ── Row inside Grid ──────────────────────────────────────────────────────

  testWidgets('OiRow inside OiGrid cell renders without error', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiGrid(
        columns: OiResponsive<int>(2),
        children: [
          OiRow(children: [Text('r1'), Text('r2')]),
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
        columns: OiResponsive<int>(2),
        children: [
          OiColumn(children: [Text('c1'), Text('c2')]),
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
        gap: OiResponsive<double>(8),
        children: [
          Text('sidebar'),
          OiColumn(
            gap: OiResponsive<double>(4),
            children: [
              Text('section-title'),
              OiGrid(
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
        children: [
          Text('page-header'),
          OiContainer(
            maxWidth: OiResponsive<double>(600),
            child: OiMasonry(
              columns: OiResponsive<int>(2),
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
        gap: OiResponsive<double>(8),
        children: [
          Text('page-top'),
          OiRow(
            gap: OiResponsive<double>(4),
            children: [
              Text('left-nav'),
              OiContainer(
                maxWidth: OiResponsive<double>(400),
                child: OiGrid(
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
        columns: OiResponsive<int>(2),
        children: [
          OiMasonry(
            columns: OiResponsive<int>(2),
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
        columns: OiResponsive<int>(2),
        children: [
          OiGrid(
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
        columns: OiResponsive<int>(2),
        children: [
          OiWrapLayout(children: [Text('w1'), Text('w2')]),
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
      const OiColumn(children: [Text('A')]),
    );
    final col = tester.widget<Column>(find.byType(Column));
    expect(col.mainAxisSize, MainAxisSize.min);
  });

  testWidgets('OiRow defaults to MainAxisSize.min', (tester) async {
    await tester.pumpObers(
      const OiRow(children: [Text('A')]),
    );
    final row = tester.widget<Row>(find.byType(Row));
    expect(row.mainAxisSize, MainAxisSize.min);
  });

  testWidgets('OiColumn accepts MainAxisSize.max override', (tester) async {
    await tester.pumpObers(
      const OiColumn(mainAxisSize: MainAxisSize.max, children: [Text('A')]),
    );
    final col = tester.widget<Column>(find.byType(Column));
    expect(col.mainAxisSize, MainAxisSize.max);
  });

  testWidgets('OiRow accepts MainAxisSize.max override', (tester) async {
    await tester.pumpObers(
      const OiRow(mainAxisSize: MainAxisSize.max, children: [Text('A')]),
    );
    final row = tester.widget<Row>(find.byType(Row));
    expect(row.mainAxisSize, MainAxisSize.max);
  });
}
