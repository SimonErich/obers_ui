// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/layout/oi_grid.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Fixed columns ──────────────────────────────────────────────────────────

  testWidgets('renders children with fixed columns', (tester) async {
    await tester.pumpObers(
      const OiGrid(
        columns: 3,
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
        columns: 2,
        children: [Text('X'), Text('Y')],
      ),
    );
    expect(find.byType(LayoutBuilder), findsOneWidget);
    expect(find.byType(Wrap), findsOneWidget);
  });

  testWidgets('each child wrapped in SizedBox with computed width',
      (tester) async {
    // Surface 800px wide, 2 columns, gap 0 → each item = 400px.
    await tester.pumpObers(
      const OiGrid(
        columns: 2,
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
        columns: 2,
        gap: 8,
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
        columns: 2,
        gap: 8,
        rowGap: 24,
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
        minColumnWidth: 200,
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
}
